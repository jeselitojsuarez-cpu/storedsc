-- Keep state in an executor-global table when `shared` is unavailable.
local globalState = shared
if type(globalState) ~= "table" then
	local getGlobalEnvironment = getgenv or function()
		return _G
	end
	globalState = getGlobalEnvironment()
end

-- Initialize Luraph globals if they do not exist.
loadstring("getfenv().LPH_NO_VIRTUALIZE = getfenv().LPH_NO_VIRTUALIZE or function(...) return ... end")()

getfenv().PP_SCRAMBLE_NUM = getfenv().PP_SCRAMBLE_NUM or function(...) return ... end
getfenv().PP_SCRAMBLE_STR = getfenv().PP_SCRAMBLE_STR or function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = getfenv().PP_SCRAMBLE_RE_NUM or function(...) return ... end

-- Keep one active copy across repeated executions.
local AutoParry = {
	enabled = false,
	mode = "Legitimate",
	accuracy = 100,
	dashEnabled = false,
	dashMode = "Legitimate",
	dashAccuracy = 100,
	connections = {},
	boundAnimators = {},
	attackAnimations = {},
	scannedWeaponModules = {},
	window = nil,
	characterController = nil,
	lastParryTime = 0,
	lastDashTime = 0,
	legitimateMissUntil = 0,
	legitimateDashMissUntil = 0,
	automaticDashUntil = 0,
	forcingAutomaticParry = false,
	forcingAutomaticDash = false,
}

-- Constants.
local RAYFIELD_URL = "https://sirius.menu/gen2"
local AGGRESSIVE_PARRY_LEAD_TIME = 0.1
local AGGRESSIVE_DASH_LEAD_TIME = 0.2
local PARRY_DEBOUNCE = 0.18
local DASH_DEBOUNCE = 0.35
local DASH_INPUT_DURATION = 0.26666666666666666
local DASH_RESOLUTION_BUFFER = 0.15
local AGGRESSIVE_DISTANCE = 45
local AGGRESSIVE_HITBOX_PADDING = Vector3.new(6, 5, 8)
local TAP_DURATION = 0.13333333333333333

-- Match the local action states that represent an attack attempt or active attack.
local ATTACK_INPUT_TYPES = {
	LightAttack = true,
	HeavyAttack = true,
	Ultimate = true,
}
local ATTACK_ACTION_TYPES = {
	BasicAttack = true,
	CriticalStrike = true,
}

-- Services.
local playersService = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- State.
local localPlayer = playersService.LocalPlayer

---Disconnect everything owned by this execution.
function AutoParry.detach()
	AutoParry.enabled = false
	AutoParry.dashEnabled = false

	local localHandler = nil
	if AutoParry.characterController and type(AutoParry.characterController.GetLocalCharacterHandler) == "function" then
		pcall(function()
			localHandler = AutoParry.characterController:GetLocalCharacterHandler()
		end)
	end
	local actionManager = localHandler and localHandler.ActionManager
	if AutoParry.forcingAutomaticParry and localHandler then
		local blockAction = actionManager and actionManager.BlockAction
		local startTime = blockAction and blockAction._blockActionStartTime
		local parryDuration = blockAction and blockAction._parryDuration
		localHandler.IsParrying = type(startTime) == "number"
			and type(parryDuration) == "number"
			and os.clock() - startTime <= parryDuration
	end
	AutoParry.forcingAutomaticParry = false

	if AutoParry.forcingAutomaticDash and localHandler then
		local currentAction = actionManager and actionManager.CurrentAction
		local actionType = currentAction and currentAction.ActionType
		local actionOwnsDodge = currentAction
			and not currentAction.IsCompleted
			and (actionType == "Dodge" or actionType == "Jump" or currentAction._ownsDodgeState)
		localHandler.IsDodging = actionOwnsDodge and true or nil
	end
	AutoParry.forcingAutomaticDash = false

	for _, connection in ipairs(AutoParry.connections) do
		connection:Disconnect()
	end

	table.clear(AutoParry.connections)
	table.clear(AutoParry.boundAnimators)

	if AutoParry.window then
		pcall(AutoParry.window.Unload, AutoParry.window)
		AutoParry.window = nil
	end
end

---Require a game module while remaining compatible with executors that do not expose identity APIs.
---@param moduleScript ModuleScript
---@return boolean, any
local function requireGameModule(moduleScript)
	local getIdentity = getthreadidentity or get_thread_identity
	local setIdentity = setthreadidentity or set_thread_identity

	if type(getIdentity) ~= "function" or type(setIdentity) ~= "function" then
		return pcall(require, moduleScript)
	end

	local identitySuccess, previousIdentity = pcall(getIdentity)
	if not identitySuccess then
		return pcall(require, moduleScript)
	end

	pcall(setIdentity, 2)
	local success, result = pcall(require, moduleScript)
	pcall(setIdentity, previousIdentity)
	return success, result
end

---Fetch source through Potassium's request implementation.
---@param url string
---@return string
local function fetchSource(url)
	local response = request({
		Url = url,
		Method = "GET",
	})

	if type(response) == "string" then
		return response
	end

	if type(response) ~= "table" then
		error("HTTP request returned an unsupported response.")
	end

	if response.Success == false then
		error("HTTP request failed: " .. tostring(response.StatusCode or response.Status))
	end

	return response.Body or response.body
end

---Normalize every Roblox animation URL to its numeric asset id.
---@param animationId string
---@return string?
local function normalizeAnimationId(animationId)
	return tostring(animationId):match("%d+")
end

---Return true when an instance looks like a container for shared weapon modules.
---@param instance Instance
---@return boolean
local function isWeaponModuleContainer(instance)
	local loweredName = string.lower(instance.Name)
	return loweredName == "weaponmodulesshared"
		or loweredName == "weaponmodules"
		or (string.find(loweredName, "weapon", 1, true) and string.find(loweredName, "module", 1, true)) ~= nil
end

---Read the numeric id from the animation formats used by different gamemodes.
---@param animation any
---@return string?
local function getAttackAnimationId(animation)
	if typeof(animation) == "Instance" and animation:IsA("Animation") then
		return normalizeAnimationId(animation.AnimationId)
	end

	if type(animation) == "string" or type(animation) == "number" then
		return normalizeAnimationId(animation)
	end

	if type(animation) == "table" then
		return normalizeAnimationId(animation.AnimationId or animation.animationId or animation.id)
	end

	return nil
end

---Build every animation impact, timing, and hitbox found in the currently loaded weapon containers.
---@return number number of newly scanned weapon modules
local function buildAttackMap()
	local containers = {}
	for _, descendant in ipairs(replicatedStorage:GetDescendants()) do
		if not descendant:IsA("ModuleScript") and isWeaponModuleContainer(descendant) then
			table.insert(containers, descendant)
		end
	end

	local scannedCount = 0
	for _, container in ipairs(containers) do
		for _, weaponModule in ipairs(container:GetDescendants()) do
			if not weaponModule:IsA("ModuleScript") or AutoParry.scannedWeaponModules[weaponModule] then
				continue
			end

			local success, weaponClass = requireGameModule(weaponModule)
			if not success or type(weaponClass) ~= "table" then
				continue
			end

			local weaponInfo = type(weaponClass.WeaponInfo) == "table" and weaponClass.WeaponInfo or weaponClass
			local basicAttackTypes = weaponInfo.BasicAttackTypes or weaponInfo.basicAttackTypes
			if type(basicAttackTypes) ~= "table" then
				continue
			end

			AutoParry.scannedWeaponModules[weaponModule] = true
			scannedCount += 1

			for _, attackInfo in pairs(basicAttackTypes) do
				if type(attackInfo) ~= "table" then
					continue
				end

				local animation = attackInfo.animation or attackInfo.Animation
				local impacts = attackInfo.impacts or attackInfo.Impacts
				local animationId = getAttackAnimationId(animation)

				if not animationId or type(impacts) ~= "table" then
					continue
				end

				local speed = tonumber(attackInfo.attackSpeedMultiplier or attackInfo.attackSpeedMultipler or attackInfo.AttackSpeedMultiplier) or 1
				if speed <= 0 then
					speed = 1
				end

				local attackImpacts = AutoParry.attackAnimations[animationId] or {}
				AutoParry.attackAnimations[animationId] = attackImpacts

				for _, impact in pairs(impacts) do
					if type(impact) == "table" and type(impact.markerTime) == "number" then
						table.insert(attackImpacts, {
							impactDelay = impact.markerTime / speed,
							impactInfo = impact.impactInfo or impact.ImpactInfo,
						})
					end
				end
			end
		end
	end

	return scannedCount
end

---Safely get the local character handler during loads and respawns.
---@return table?
local function getLocalCharacterHandler()
	local controller = AutoParry.characterController
	if not controller or type(controller.GetLocalCharacterHandler) ~= "function" then
		return nil
	end

	local success, handler = pcall(function()
		return controller:GetLocalCharacterHandler()
	end)
	return success and handler or nil
end

---Check whether the local player is attempting or actively performing an attack.
---@param localHandler table
---@return boolean
local function isLocalAttacking(localHandler)
	if ATTACK_INPUT_TYPES[localHandler._desiredQueuedAction] then
		return true
	end

	local actionManager = localHandler.ActionManager
	if not actionManager then
		return false
	end

	if actionManager._queuedActionType == "BasicAttack" then
		return true
	end

	local currentAction = actionManager.CurrentAction
	return currentAction ~= nil and ATTACK_ACTION_TYPES[currentAction.ActionType] == true
end

---Check whether a manual or automatic dash is queued or active.
---@param localHandler table
---@return boolean
local function isLocalDodging(localHandler)
	if localHandler._desiredDodge or localHandler.IsDodging then
		return true
	end

	local actionManager = localHandler.ActionManager
	local currentAction = actionManager and actionManager.CurrentAction
	return currentAction ~= nil and currentAction.ActionType == "Dodge"
end

---Restore the parry flag to the state owned by the game's real block action.
---@param localHandler table
local function stopForcingParry(localHandler)
	if not AutoParry.forcingAutomaticParry then
		return
	end

	AutoParry.forcingAutomaticParry = false
	local actionManager = localHandler.ActionManager
	local blockAction = actionManager and actionManager.BlockAction
	local startTime = blockAction and blockAction._blockActionStartTime
	local parryDuration = blockAction and blockAction._parryDuration
	localHandler.IsParrying = type(startTime) == "number"
		and type(parryDuration) == "number"
		and os.clock() - startTime <= parryDuration
end

---Restore dodge state after an Auto Dash resolution window.
---@param localHandler table
local function stopForcingDash(localHandler)
	if not AutoParry.forcingAutomaticDash then
		return
	end

	AutoParry.forcingAutomaticDash = false
	local actionManager = localHandler.ActionManager
	local currentAction = actionManager and actionManager.CurrentAction
	local actionType = currentAction and currentAction.ActionType
	local actionOwnsDodge = currentAction
		and not currentAction.IsCompleted
		and (actionType == "Dodge" or actionType == "Jump" or currentAction._ownsDodgeState)
	localHandler.IsDodging = actionOwnsDodge and true or nil
end

---Safely get a remote character handler.
---@param character Model
---@return table?
local function getCharacterHandler(character)
	local controller = AutoParry.characterController
	if not controller or type(controller.GetCharacterHandler) ~= "function" then
		return nil
	end

	local success, handler = pcall(function()
		return controller:GetCharacterHandler(character)
	end)
	return success and handler or nil
end

---Check whether an attack is inside aggressive parry coverage.
---@param attackerHandler table
---@param attackData table
---@return boolean
local function isThreatening(attackerHandler, attackData)
	local localHandler = getLocalCharacterHandler()
	local localRoot = localHandler and localHandler.Root
	local attackerRoot = attackerHandler and attackerHandler.Root

	if not localRoot or not attackerRoot then
		return false
	end

	local humanoid = localHandler.Humanoid
	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	local impactInfo = attackData.impactInfo
	local hitboxSize = impactInfo and impactInfo.hitboxSize
	local hitboxCFrame = impactInfo and impactInfo.hitboxCFrame
	local distance = (localRoot.Position - attackerRoot.Position).Magnitude

	if typeof(hitboxSize) ~= "Vector3" or typeof(hitboxCFrame) ~= "CFrame" then
		return distance <= AGGRESSIVE_DISTANCE
	end

	local localPosition = (attackerRoot.CFrame * hitboxCFrame):PointToObjectSpace(localRoot.Position)
	local extents = hitboxSize / 2 + AGGRESSIVE_HITBOX_PADDING
	local insideHitbox = math.abs(localPosition.X) <= extents.X
		and math.abs(localPosition.Y) <= extents.Y
		and math.abs(localPosition.Z) <= extents.Z

	return insideHitbox or distance <= AGGRESSIVE_DISTANCE
end

---Keep automatic parry active while Legitimate mode is not attacking.
local function maintainAutomaticParry()
	local localHandler = getLocalCharacterHandler()
	if not localHandler then
		return
	end

	local actionManager = localHandler.ActionManager
	local humanoid = localHandler.Humanoid
	local localDodging = isLocalDodging(localHandler)
	local legitimateCanParry = AutoParry.mode == "Legitimate"
		and not isLocalAttacking(localHandler)
		and os.clock() >= AutoParry.legitimateMissUntil
	local shouldForce = globalState.DuelingGroundsAutoParry == AutoParry
		and AutoParry.enabled
		and humanoid
		and humanoid.Health > 0
		and not localDodging
		and (AutoParry.mode == "Aggressive" or legitimateCanParry)

	if shouldForce then
		AutoParry.forcingAutomaticParry = true
		localHandler.IsParrying = true

		if actionManager then
			actionManager._blockStrength = 1
			actionManager._blockCooldown = 0
		end
		return
	end

	stopForcingParry(localHandler)
end

---Keep accepted Auto Dash reactions inside the client impact resolver's dodge branch.
local function maintainAutomaticDash()
	local localHandler = getLocalCharacterHandler()
	if not localHandler then
		return
	end

	local humanoid = localHandler.Humanoid
	local legitimateCanDash = AutoParry.dashMode == "Legitimate"
		and not isLocalAttacking(localHandler)
		and os.clock() >= AutoParry.legitimateDashMissUntil
	local shouldForce = globalState.DuelingGroundsAutoParry == AutoParry
		and AutoParry.dashEnabled
		and humanoid
		and humanoid.Health > 0
		and os.clock() <= AutoParry.automaticDashUntil
		and (AutoParry.dashMode == "Aggressive" or legitimateCanDash)

	if shouldForce then
		AutoParry.forcingAutomaticDash = true
		localHandler.IsDodging = true
		stopForcingParry(localHandler)
		return
	end

	stopForcingDash(localHandler)
end

---Queue the same short guard input used by a normal F-key tap.
local function performParry()
	local now = os.clock()
	if now - AutoParry.lastParryTime < PARRY_DEBOUNCE then
		return
	end

	local localHandler = getLocalCharacterHandler()
	local actionManager = localHandler and localHandler.ActionManager

	if not actionManager then
		return
	end

	if AutoParry.mode == "Legitimate" and isLocalAttacking(localHandler) then
		return
	end

	if AutoParry.mode == "Aggressive" then
		actionManager._blockStrength = 1
		actionManager._blockCooldown = 0
		localHandler.IsParrying = true
	end

	local blockInputQueue = localHandler._blockInputQueue
	if type(blockInputQueue) ~= "table" then
		return
	end

	if actionManager.BlockAction or #blockInputQueue >= 2 then
		return
	end

	if type(actionManager.CanStartBlock) ~= "function" then
		return
	end

	local success, canStartBlock = pcall(actionManager.CanStartBlock, actionManager)
	if not success or not canStartBlock then
		return
	end

	AutoParry.lastParryTime = now
	table.insert(blockInputQueue, { state = TAP_DURATION })
end

---Apply intentional misses only below full accuracy.
---@param accuracy number
---@return boolean
local function passesAccuracyRoll(accuracy)
	if accuracy >= 100 then
		return true
	end

	return math.random(1, 100) <= accuracy
end

---Schedule a parry from the attack's actual first-impact marker.
---@param attackerHandler table
---@param track AnimationTrack
---@param attackData table
local function scheduleParry(attackerHandler, track, attackData)
	local triggerDelay = math.max(0, attackData.impactDelay - AGGRESSIVE_PARRY_LEAD_TIME)

	task.delay(triggerDelay, function()
		if globalState.DuelingGroundsAutoParry ~= AutoParry or not AutoParry.enabled then
			return
		end

		if AutoParry.mode == "Legitimate" and not track.IsPlaying then
			return
		end

		if not isThreatening(attackerHandler, attackData) then
			return
		end

		-- Suppress the forced state through this impact when Legitimate intentionally misses.
		if AutoParry.mode == "Legitimate" and not passesAccuracyRoll(AutoParry.accuracy) then
			AutoParry.legitimateMissUntil = math.max(
				AutoParry.legitimateMissUntil,
				os.clock() + AGGRESSIVE_PARRY_LEAD_TIME + TAP_DURATION
			)

			local localHandler = getLocalCharacterHandler()
			if localHandler then
				stopForcingParry(localHandler)
			end
			return
		end

		performParry()
	end)
end

---Queue the same buffered dodge request used by the game's dash input.
local function performDash()
	local now = os.clock()
	if now - AutoParry.lastDashTime < DASH_DEBOUNCE then
		return
	end

	local localHandler = getLocalCharacterHandler()
	local actionManager = localHandler and localHandler.ActionManager
	local humanoid = localHandler and localHandler.Humanoid

	if not actionManager or not humanoid or humanoid.Health <= 0 then
		return
	end

	if AutoParry.dashMode == "Legitimate" and isLocalAttacking(localHandler) then
		return
	end

	if isLocalDodging(localHandler) then
		return
	end

	-- Keep every accepted automatic dodge ready when normal stamina is spent.
	actionManager._dodgeStamina = 1

	AutoParry.lastDashTime = now
	localHandler._desiredDodge = DASH_INPUT_DURATION
	stopForcingParry(localHandler)
end

---Schedule a dash from the attack's impact marker.
---@param attackerHandler table
---@param track AnimationTrack
---@param attackData table
local function scheduleDash(attackerHandler, track, attackData)
	local dashLeadTime = AGGRESSIVE_DASH_LEAD_TIME
	local triggerDelay = math.max(0, attackData.impactDelay - dashLeadTime)

	task.delay(triggerDelay, function()
		if globalState.DuelingGroundsAutoParry ~= AutoParry or not AutoParry.dashEnabled then
			return
		end

		if AutoParry.dashMode == "Legitimate" and not track.IsPlaying then
			return
		end

		if not isThreatening(attackerHandler, attackData) then
			return
		end

		local localHandler = getLocalCharacterHandler()
		if AutoParry.dashMode == "Legitimate"
			and (not localHandler or isLocalAttacking(localHandler)) then
			return
		end

		-- Suppress the forced dodge through this impact when Legitimate intentionally misses.
		if AutoParry.dashMode == "Legitimate" and not passesAccuracyRoll(AutoParry.dashAccuracy) then
			AutoParry.legitimateDashMissUntil = math.max(
				AutoParry.legitimateDashMissUntil,
				os.clock() + dashLeadTime + DASH_RESOLUTION_BUFFER
			)
			AutoParry.automaticDashUntil = 0

			if localHandler then
				stopForcingDash(localHandler)
			end
			return
		end

		performDash()

		-- Cover the impact immediately because the real Dodge action starts after impact resolution.
		AutoParry.automaticDashUntil = math.max(
			AutoParry.automaticDashUntil,
			os.clock() + dashLeadTime + DASH_RESOLUTION_BUFFER
		)

		if localHandler then
			AutoParry.forcingAutomaticDash = true
			localHandler.IsDodging = true
			stopForcingParry(localHandler)
		end
	end)
end

---Watch one remote character for mapped combat animations.
---@param character Model
local function bindCharacter(character)
	if character == localPlayer.Character then
		return
	end

	task.spawn(function()
		for _ = 1, 400 do
			if globalState.DuelingGroundsAutoParry ~= AutoParry or not character.Parent then
				return
			end

			local handler = getCharacterHandler(character)
			local animator = handler and handler.Animator
			if handler and not animator then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			end

			if animator and animator.AnimationPlayed then
				if AutoParry.boundAnimators[animator] then
					return
				end

				AutoParry.boundAnimators[animator] = true
				local connection = animator.AnimationPlayed:Connect(function(track)
					if not AutoParry.enabled and not AutoParry.dashEnabled then
						return
					end

					local animation = track.Animation
					local animationId = animation and normalizeAnimationId(animation.AnimationId)
					local attackImpacts = animationId and AutoParry.attackAnimations[animationId]

					if attackImpacts then
						for _, attackData in ipairs(attackImpacts) do
							if AutoParry.enabled then
								scheduleParry(handler, track, attackData)
							end

							if AutoParry.dashEnabled then
								scheduleDash(handler, track, attackData)
							end
						end
					end
				end)

				table.insert(AutoParry.connections, connection)
				return
			end

			task.wait(0.05)
		end
	end)
end

---Create the Rayfield Gen2 window for combat automation.
local function createInterface()
	local rayfieldSource = fetchSource(RAYFIELD_URL)
	local rayfieldChunk, compileError = loadstring(rayfieldSource, "RayfieldGen2")

	if not rayfieldChunk then
		error(compileError)
	end

	local Rayfield = rayfieldChunk()
	local window = Rayfield:CreateWindow({
		name = "Dueling Grounds",
		subtitle = "Combat Automation",
		sidebarLayout = true,
	})

	AutoParry.window = window
	local combatTab = window:CreateTab({
		name = "Combat",
		icon = "shield",
	})
	local accuracySlider = nil
	local dashAccuracySlider = nil

	---Show the accuracy modifier only when Legitimate mode uses it.
	local function updateAccuracyVisibility()
		if accuracySlider and accuracySlider.main then
			accuracySlider.main.Visible = AutoParry.mode == "Legitimate"
		end
	end

	---Show the dash accuracy modifier only when Legitimate mode uses it.
	local function updateDashAccuracyVisibility()
		if dashAccuracySlider and dashAccuracySlider.main then
			dashAccuracySlider.main.Visible = AutoParry.dashMode == "Legitimate"
		end
	end

	local autoParryToggle = combatTab:CreateToggle({
		name = "Auto Parry Attacks",
		description = "Parries mapped attacks from every opponent threatening you.",
		value = false,
		forgetState = true,
		callback = function(value)
			AutoParry.enabled = value
		end,
	})

	-- Keep old Rayfield state from enabling the feature on load.
	autoParryToggle:Set(false, true)
	AutoParry.enabled = false

	local modeDropdown = combatTab:CreateDropdown({
		name = "Auto Parry Mode",
		description = "Legitimate pauses while you attack; Aggressive always stays active.",
		options = { "Legitimate", "Aggressive" },
		value = "Legitimate",
		multiSelect = false,
		forgetState = true,
		callback = function(value)
			AutoParry.mode = value
			AutoParry.legitimateMissUntil = 0
			updateAccuracyVisibility()
		end,
	})

	-- Keep the safer mode selected whenever the script starts.
	modeDropdown:Set("Legitimate", true)
	AutoParry.mode = "Legitimate"

	accuracySlider = combatTab:CreateSlider({
		name = "Auto Parry Accuracy",
		description = "100% never intentionally skips a detected attack.",
		range = { 0, 100 },
		increment = 1,
		value = 100,
		suffix = "%",
		forgetState = true,
		callback = function(value)
			AutoParry.accuracy = value
		end,
	})

	-- Always start with guaranteed detection acceptance.
	accuracySlider:Set(100, true)
	AutoParry.accuracy = 100
	updateAccuracyVisibility()

	local autoDashToggle = combatTab:CreateToggle({
		name = "Auto Dash Attacks",
		description = "Dashes before mapped attacks that threaten you.",
		value = false,
		forgetState = true,
		callback = function(value)
			AutoParry.dashEnabled = value
			if not value then
				AutoParry.automaticDashUntil = 0
				AutoParry.legitimateDashMissUntil = 0
			end
		end,
	})

	-- Keep Auto Dash disabled whenever the script starts.
	autoDashToggle:Set(false, true)
	AutoParry.dashEnabled = false

	local dashModeDropdown = combatTab:CreateDropdown({
		name = "Auto Dash Mode",
		description = "Legitimate pauses while you attack; Aggressive always reacts.",
		options = { "Legitimate", "Aggressive" },
		value = "Legitimate",
		multiSelect = false,
		forgetState = true,
		callback = function(value)
			AutoParry.dashMode = value
			AutoParry.automaticDashUntil = 0
			AutoParry.legitimateDashMissUntil = 0
			updateDashAccuracyVisibility()
		end,
	})

	-- Keep Legitimate Auto Dash selected on startup.
	dashModeDropdown:Set("Legitimate", true)
	AutoParry.dashMode = "Legitimate"

	dashAccuracySlider = combatTab:CreateSlider({
		name = "Auto Dash Accuracy",
		description = "Controls the chance to dash at each detected impact.",
		range = { 0, 100 },
		increment = 1,
		value = 100,
		suffix = "%",
		forgetState = true,
		callback = function(value)
			AutoParry.dashAccuracy = value
		end,
	})

	-- Start Legitimate Auto Dash with guaranteed detection acceptance.
	dashAccuracySlider:Set(100, true)
	AutoParry.dashAccuracy = 100
	updateDashAccuracyVisibility()
end

---Locate and load the CharacterController regardless of which gamemode folder layout is active.
---@return table?
local function findCharacterController()
	local deadline = os.clock() + 20

	repeat
		local candidates = {}
		local controllersFolder = replicatedStorage:FindFirstChild("Controllers")
		local standardCandidate = controllersFolder and controllersFolder:FindFirstChild("CharacterController")
		if standardCandidate and standardCandidate:IsA("ModuleScript") then
			table.insert(candidates, standardCandidate)
		end

		for _, descendant in ipairs(replicatedStorage:GetDescendants()) do
			if descendant:IsA("ModuleScript") and descendant.Name == "CharacterController" and descendant ~= standardCandidate then
				table.insert(candidates, descendant)
			end
		end

		for _, candidate in ipairs(candidates) do
			local success, controller = requireGameModule(candidate)
			if success
				and type(controller) == "table"
				and type(controller.GetLocalCharacterHandler) == "function"
				and type(controller.GetCharacterHandler) == "function" then
				return controller
			end
		end

		task.wait(0.25)
	until os.clock() >= deadline

	return nil
end

---Attach character listeners for normal Roblox players in addition to CustomCharacter tags.
---@param player Player
local function bindPlayer(player)
	if player == localPlayer then
		return
	end

	if player.Character then
		bindCharacter(player.Character)
	end

	local characterConnection = player.CharacterAdded:Connect(bindCharacter)
	table.insert(AutoParry.connections, characterConnection)
end

---Initialize game data, character listeners, and the interface.
local function initializeScript()
	-- Do not lock to one PlaceId: Dueling Grounds gamemodes can run in separate places.
	local characterController = findCharacterController()
	if not characterController then
		error("Could not find a compatible Dueling Grounds CharacterController in this gamemode.")
	end

	AutoParry.characterController = characterController
	buildAttackMap()

	for _, character in ipairs(collectionService:GetTagged("CustomCharacter")) do
		bindCharacter(character)
	end

	local taggedCharacterConnection = collectionService:GetInstanceAddedSignal("CustomCharacter"):Connect(bindCharacter)
	table.insert(AutoParry.connections, taggedCharacterConnection)

	for _, player in ipairs(playersService:GetPlayers()) do
		bindPlayer(player)
	end

	local playerAddedConnection = playersService.PlayerAdded:Connect(bindPlayer)
	table.insert(AutoParry.connections, playerAddedConnection)

	-- Some gamemodes replicate weapon modules a little later than the controller.
	task.spawn(function()
		for _ = 1, 30 do
			if globalState.DuelingGroundsAutoParry ~= AutoParry then
				return
			end

			buildAttackMap()
			if next(AutoParry.attackAnimations) ~= nil then
				return
			end

			task.wait(1)
		end
	end)

	-- Refresh the attack map when a gamemode streams in additional weapon modules.
	local refreshQueued = false
	local descendantAddedConnection = replicatedStorage.DescendantAdded:Connect(function(descendant)
		if not descendant:IsA("ModuleScript") then
			return
		end

		local ancestor = descendant.Parent
		while ancestor and ancestor ~= replicatedStorage do
			if isWeaponModuleContainer(ancestor) then
				if not refreshQueued then
					refreshQueued = true
					task.delay(0.25, function()
						refreshQueued = false
						if globalState.DuelingGroundsAutoParry == AutoParry then
							buildAttackMap()
						end
					end)
				end
				return
			end
			ancestor = ancestor.Parent
		end
	end)
	table.insert(AutoParry.connections, descendantAddedConnection)

	-- Refresh automatic dash before parry so dodge takes priority during its impact window.
	local automaticDashConnection = runService.PreSimulation:Connect(maintainAutomaticDash)
	table.insert(AutoParry.connections, automaticDashConnection)

	-- Refresh automatic parry before each client impact-resolution step.
	local automaticParryConnection = runService.PreSimulation:Connect(maintainAutomaticParry)
	table.insert(AutoParry.connections, automaticParryConnection)

	createInterface()
end

---Cleanly stop after an initialization failure.
---@param errorMessage string
local function onInitializeError(errorMessage)
	warn("Failed to initialize Dueling Grounds Auto Parry.")
	warn(errorMessage)
	warn(debug.traceback())
	AutoParry.detach()
end

-- Replace the prior singleton before initializing this execution.
if globalState.DuelingGroundsAutoParry then
	globalState.DuelingGroundsAutoParry.detach()
end

globalState.DuelingGroundsAutoParry = AutoParry

-- Safely initialize the persistent script.
xpcall(initializeScript, onInitializeError)
