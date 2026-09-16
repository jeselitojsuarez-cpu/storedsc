-- Check for state shared across re-executions.
if not shared then
	return warn("No shared, no script.")
end

-- Keep development bundles compatible with Lycoris-style globals.
local environment = getfenv()
environment.LPH_NO_VIRTUALIZE = environment.LPH_NO_VIRTUALIZE or function(...) return ... end
environment.PP_SCRAMBLE_NUM = environment.PP_SCRAMBLE_NUM or function(...) return ... end
environment.PP_SCRAMBLE_STR = environment.PP_SCRAMBLE_STR or function(...) return ... end
environment.PP_SCRAMBLE_RE_NUM = environment.PP_SCRAMBLE_RE_NUM or function(...) return ... end

local PotentBeginner = {}

-- Constants.
local RAYFIELD_URL = "https://sirius.menu/gen2"
local TRIGGER_INTERVAL = 0.16
local ESP_INTERVAL = 0.2
local INSTANT_KILL_INTERVAL = 0.2
local INSTANT_KILL_BURST_HITS = 14
local INSTANT_KILL_REPORTS_PER_HIT = 2
local INSTANT_KILL_DAMAGE = 120
local INSTANT_KILL_HIT_DELAY = 0.025
local INSTANT_KILL_BEHIND_DISTANCE = 2.25
local INSTANT_KILL_PASS_DURATION = 30

-- Services.
local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

-- State.
local localPlayer = playersService.LocalPlayer
local cameraController
local rayfield
local window
local fovCircle
local renderConnection
local guiToggleConnection
local espFolder
local espConnections = {}
local espHighlights = {}
local espBoxes = {}
local movementDefaults = setmetatable({}, { __mode = "k" })
local lastTriggerTime = 0
local lastEspTime = 0
local lastInstantKillTime = 0
local destroyed = false
local instantKillBusy = false
local aimbotHoldKeybind
local triggerbotHoldKeybind
local aimbotKeyHeld = false
local triggerbotKeyHeld = false
local syncWeaponIdRemote
local syncCombatActionRemote
local fireHitRemote
local settings = {
	aimbot = false,
	aimbotActivation = userInputService.TouchEnabled and not userInputService.MouseEnabled and "Scope Hold" or "Right Click Hold",
	triggerbot = false,
	triggerbotActivation = "Always On",
	instantKill = false,
	speed = false,
	speedModifier = 28,
	jump = false,
	jumpModifier = 75,
	infiniteJump = false,
	esp = false,
	showFov = false,
	wallCheck = true,
	fovRadius = 180,
	smoothness = 0.3,
	targetPart = "Head",
	holdKey = "Q",
	triggerHoldKey = "T",
}
PotentBeginner.settings = settings

---Keep the current values when replacing this execution.
local function capturePreviousSettings()
	local previousSettings = shared.PotentBeginner and shared.PotentBeginner.settings
	if type(previousSettings) ~= "table" then return end
	for name, value in pairs(previousSettings) do
		if settings[name] ~= nil then
			settings[name] = value
		end
	end
end

---Return whether the selected activation condition is active.
---@param mode string
---@param keyHeld boolean?
---@return boolean
local function isActivationModeActive(mode, keyHeld)
	if mode == "Always On" then return true end
	if mode == "Scope Hold" then
		return localPlayer:GetAttribute("Aim") == true
	end
	if mode == "Key Hold" then
		return keyHeld == true
	end
	if userInputService.TouchEnabled and not userInputService.MouseEnabled then
		return localPlayer:GetAttribute("Aim") == true
	end
	return userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

---Return whether Aimbot is enabled and activated.
---@return boolean
local function isAimbotActive()
	return settings.aimbot and isActivationModeActive(settings.aimbotActivation, aimbotKeyHeld)
end

---Return whether Triggerbot is enabled and activated.
---@return boolean
local function isTriggerbotActive()
	return settings.triggerbot and isActivationModeActive(settings.triggerbotActivation, triggerbotKeyHeld)
end

---Return whether a character name belongs to the active combat roster.
---@param playerName string?
---@return boolean
local function isCombatRosterMember(playerName)
	local combatPlayers = workspace:FindFirstChild("CombatPlayers")
	return playerName ~= nil and combatPlayers ~= nil and combatPlayers:FindFirstChild(playerName) ~= nil
end

---Return whether a live character belongs to an opponent.
---@param character Model
---@param player Player?
---@return boolean
local function isEnemy(character, player)
	if not character or not character:IsDescendantOf(workspace) or character == localPlayer.Character or character.Name == localPlayer.Name then
		return false
	end
	local localInRoster = isCombatRosterMember(localPlayer.Name)
	if localInRoster and not isCombatRosterMember(character.Name) then
		return false
	end
	if not localInRoster and player and player.Team and player.Team.Name == "Lobby" then return false end
	if player and localPlayer.Team and player.Team and localPlayer.Team == player.Team and localPlayer.Team.Name ~= "FFA" and localPlayer.Team.Name ~= "Lobby" then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0 and character:FindFirstChild("Head") ~= nil and not character:GetAttribute("FakeChar")
end

---Avoid combat input while the local character is between matches.
---@return boolean
local function isCombatReady()
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
	local gameState = workspace:FindFirstChild("GameBC") and workspace.GameBC:FindFirstChild("GameState")
	if gameState and gameState.Value == "Ready" then
		return false
	end
	return humanoid ~= nil and humanoid.Health > 0 and (isCombatRosterMember(localPlayer.Name) or not localPlayer.Team or localPlayer.Team.Name ~= "Lobby")
end

---Return the main body part used for teleporting close to a character.
---@param character Model?
---@return BasePart?
local function getRootPart(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

---Return the part the knife report should claim as the hit.
---@param character Model?
---@return BasePart?
local function getKnifeHitPart(character)
	if not character then return nil end
	return character:FindFirstChild(settings.targetPart)
		or character:FindFirstChild("Head")
		or getRootPart(character)
end

---Return whether an enemy can still be targeted by the knife routine.
---@param character Model?
---@return boolean
local function isEnemyStillAlive(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return character ~= nil and character:IsDescendantOf(workspace) and humanoid ~= nil and humanoid.Health > 0
end

---Include characters that exist before their Player object is replicated.
---@return table
local function getEnemyCharacters()
	local enemies = {}
	local seen = {}
	for _, player in ipairs(playersService:GetPlayers()) do
		local character = player.Character
		if character and not seen[character] then
			seen[character] = true
			if isEnemy(character, player) then
				table.insert(enemies, character)
			end
		end
	end
	local charactersFolder = workspace:FindFirstChild("PlayersCharacters")
	if charactersFolder then
		for _, character in ipairs(charactersFolder:GetChildren()) do
			if not character:IsA("Model") or seen[character] then continue end
			seen[character] = true
			local player = playersService:GetPlayerFromCharacter(character) or playersService:FindFirstChild(character.Name)
			if player and player.Character and player.Character ~= character then continue end
			if isEnemy(character, player) then
				table.insert(enemies, character)
			end
		end
	end
	return enemies
end

---Resolve the game's combat remotes only when the melee routine needs them.
---@return RemoteEvent?, RemoteEvent?
local function getCombatRemotes()
	if syncWeaponIdRemote and syncCombatActionRemote then
		return syncWeaponIdRemote, syncCombatActionRemote
	end
	local remoteFolder = replicatedStorage:FindFirstChild("Remote")
	local eventFolder = remoteFolder and remoteFolder:FindFirstChild("Event")
	local gameFolder = eventFolder and eventFolder:FindFirstChild("Game")
	if not gameFolder then
		return nil, nil
	end
	syncWeaponIdRemote = syncWeaponIdRemote or gameFolder:FindFirstChild("[C-S]SyncWeaponId")
	syncCombatActionRemote = syncCombatActionRemote or gameFolder:FindFirstChild("[C-S]SyncCombatAction")
	return syncWeaponIdRemote, syncCombatActionRemote
end

---Resolve the direct fire hit remote used by the game's hitbox module.
---@return RemoteEvent?
local function getFireHitRemote()
	if fireHitRemote then
		return fireHitRemote
	end
	local remoteFolder = replicatedStorage:FindFirstChild("Remote")
	local eventFolder = remoteFolder and remoteFolder:FindFirstChild("Event")
	local fireFolder = eventFolder and eventFolder:FindFirstChild("Fire")
	if not fireFolder then
		return nil
	end
	fireHitRemote = fireFolder:FindFirstChild("[C-S]FireEvent")
	return fireHitRemote
end

---Tell the game's weapon controller which weapon is active.
---@param weaponId string
local function setCombatWeapon(weaponId)
	if not weaponId then return end
	local syncWeaponId = getCombatRemotes()
	localPlayer:SetAttribute("WeaponId", weaponId)
	if syncWeaponId then
		pcall(function()
			syncWeaponId:FireServer(weaponId)
		end)
	end
end

---Trigger a combat action without clicking the player's mouse or touch UI.
---@param actionName string
---@return number
local function sendCombatAction(actionName)
	local _, syncCombatAction = getCombatRemotes()
	local actionTime = tick()
	localPlayer:SetAttribute("CanAttack", true)
	localPlayer:SetAttribute("CanAttackM2", true)
	localPlayer:SetAttribute(actionName, actionTime)
	if syncCombatAction then
		pcall(function()
			syncCombatAction:FireServer(actionName, actionTime)
		end)
	end
	return actionTime
end

---Switch to the player's equipped knife/melee weapon.
---@return any
local function equipKnife()
	localPlayer = playersService.LocalPlayer
	local character = localPlayer and localPlayer.Character
	if not localPlayer or not character then
		return nil
	end
	local equippedKnife = character:FindFirstChild("Knife")
	if equippedKnife and equippedKnife:IsA("Tool") then
		return equippedKnife
	end
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	local knife = backpack and backpack:FindFirstChild("Knife")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if knife and knife:IsA("Tool") and humanoid then
		pcall(function()
			humanoid:EquipTool(knife)
		end)
		return character:FindFirstChild("Knife") or knife
	end
	local meleeId = localPlayer:GetAttribute("UseMelee")
	if not meleeId then
		return nil
	end
	if localPlayer:GetAttribute("WeaponId") ~= meleeId then
		setCombatWeapon(meleeId)
		task.wait(0.03)
	end
	return true
end

---Point the game's camera controller at the target before its hitbox fires.
---@param targetPart BasePart
local function aimKnifeAtTarget(targetPart)
	if cameraController then
		pcall(function()
			cameraController:LerpToTarget(targetPart.Position, 1)
		end)
	end
	local camera = workspace.CurrentCamera
	if camera then
		pcall(function()
			camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
		end)
	end
end

---Send the same melee hit packet created by the game's HitBox module.
---@param enemy Model
---@param hitPart BasePart
---@param rootPart BasePart
---@return boolean
local function reportKnifeHit(enemy, hitPart, rootPart)
	local fireEvent = getFireHitRemote()
	if not fireEvent or not isEnemyStillAlive(enemy) then
		return false
	end
	local origin = rootPart.Position + Vector3.new(0, 1.5, 0)
	local distance = (hitPart.Position - origin).Magnitude
	local hitData = {
		quickAim = false,
		isHead = hitPart.Name == "Head",
		isAim = localPlayer:GetAttribute("Aim") or false,
		isAir = false,
		isSlide = false,
		damage = INSTANT_KILL_DAMAGE,
		distance = distance,
	}
	pcall(function()
		fireEvent:FireServer(enemy, hitData)
	end)
	return true
end

---Send one knife swing through the game's combat state only.
---@param knife any
local function activateKnife(knife)
	sendCombatAction("M1")
	if typeof(knife) == "Instance" and knife:IsA("Tool") then
		pcall(function()
			knife.ManualActivationOnly = false
		end)
		pcall(function()
			knife:Activate()
		end)
		if firesignal then
			pcall(firesignal, knife.Activated)
		end
		task.delay(0.02, function()
			pcall(function()
				knife:Deactivate()
			end)
			if firesignal then
				pcall(firesignal, knife.Deactivated)
			end
		end)
	end
end

---Teleport behind one enemy and stab with the active knife.
---@param enemy Model
---@return boolean
local function stabEnemyWithKnife(enemy)
	localPlayer = playersService.LocalPlayer
	if not localPlayer or not localPlayer.Character or not isCombatReady() or not isEnemyStillAlive(enemy) then
		return false
	end
	local character = localPlayer.Character
	local rootPart = getRootPart(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then
		return false
	end
	local knife = equipKnife()
	if not knife then
		return false
	end
	for _ = 1, INSTANT_KILL_BURST_HITS do
		if destroyed or not settings.instantKill or not isCombatReady() or not isEnemyStillAlive(enemy) then
			break
		end
		local enemyRoot = getRootPart(enemy)
		local hitPart = getKnifeHitPart(enemy)
		if not enemyRoot or not hitPart then
			break
		end
		local attackPosition = enemyRoot.Position - enemyRoot.CFrame.LookVector * INSTANT_KILL_BEHIND_DISTANCE + Vector3.new(0, 0.1, 0)
		local attackCFrame = CFrame.new(attackPosition, enemyRoot.Position)
		character:PivotTo(attackCFrame)
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		humanoid:Move(Vector3.zero, false)
		aimKnifeAtTarget(hitPart)
		activateKnife(knife)
		for _ = 1, INSTANT_KILL_REPORTS_PER_HIT do
			if not isEnemyStillAlive(enemy) then
				break
			end
			reportKnifeHit(enemy, hitPart, rootPart)
		end
		task.wait(INSTANT_KILL_HIT_DELAY)
	end
	return true
end

---Run one full knife sweep and restore the starting position afterward.
local function runInstantKillPass()
	if instantKillBusy then return end
	instantKillBusy = true
	localPlayer = playersService.LocalPlayer
	local character = localPlayer and localPlayer.Character
	if not character or not isCombatReady() then
		instantKillBusy = false
		return
	end
	local originalCFrame = character:GetPivot()
	local originalWeaponId = localPlayer:GetAttribute("WeaponId")
	local deadline = os.clock() + INSTANT_KILL_PASS_DURATION
	while not destroyed and settings.instantKill and isCombatReady() and os.clock() <= deadline do
		local enemies = getEnemyCharacters()
		if #enemies <= 0 then
			break
		end
		for _, enemy in ipairs(enemies) do
			if destroyed or not settings.instantKill or not isCombatReady() then
				break
			end
			if isEnemyStillAlive(enemy) then
				stabEnemyWithKnife(enemy)
			end
		end
		task.wait()
	end
	if localPlayer and localPlayer.Character == character then
		setCombatWeapon(originalWeaponId)
		localPlayer.Character:PivotTo(originalCFrame)
	end
	instantKillBusy = false
end

---Start the knife routine without creating overlapping passes.
---@param now number
local function updateInstantKill(now)
	if instantKillBusy or not settings.instantKill or not isCombatReady() or now - lastInstantKillTime < INSTANT_KILL_INTERVAL then
		return
	end
	lastInstantKillTime = now
	task.spawn(runInstantKillPass)
end

---Keep client-only view models out of enemy sight checks.
---@return RaycastParams
local function getTargetRaycastParams()
	local filter = {}
	if localPlayer.Character then table.insert(filter, localPlayer.Character) end
	for _, name in ipairs({ "HandModel", "ViewWeapon", "GroundRayDebug" }) do
		local instance = workspace:FindFirstChild(name)
		if instance then table.insert(filter, instance) end
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filter
	return raycastParams
end

---Check whether the game aim ray has an unobstructed hit on the character.
---@param character Model
---@param targetPart BasePart
---@return boolean
local function isVisible(character, targetPart)
	local origin = cameraController:GetCameraPosition()
	local direction = targetPart.Position - origin
	local result = workspace:Raycast(origin, direction, getTargetRaycastParams())
	return result ~= nil and result.Instance:IsDescendantOf(character)
end

---Return the nearest enemy part projected inside the crosshair FOV.
---@return Model?, BasePart?
local function getClosestPlayer()
	local camera = workspace.CurrentCamera
	if not camera then
		return nil, nil
	end
	local mousePosition = camera.ViewportSize / 2
	local closestCharacter, closestPart, closestDistance = nil, nil, settings.fovRadius
	for _, character in ipairs(getEnemyCharacters()) do
		local targetPart = character:FindFirstChild(settings.targetPart) or character:FindFirstChild("Head")
		if not targetPart then continue end
		local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
		if not onScreen then continue end
		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
		if distance > closestDistance then continue end
		if settings.wallCheck and not isVisible(character, targetPart) then continue end
		closestCharacter, closestPart, closestDistance = character, targetPart, distance
	end
	return closestCharacter, closestPart
end

---Clear ESP adornments owned by this execution.
local function clearEsp()
	for character, highlight in pairs(espHighlights) do
		highlight:Destroy()
		espHighlights[character] = nil
	end
	for character, box in pairs(espBoxes) do
		box:Remove()
		espBoxes[character] = nil
	end
end

---Refresh ESP only when player or character state changes.
local function refreshEsp()
	if destroyed then return end
	if not settings.esp then
		clearEsp()
		return
	end
	local seen = {}
	for _, character in ipairs(getEnemyCharacters()) do
		seen[character] = true
		local highlight = espHighlights[character]
		if not (highlight and highlight.Parent == espFolder and highlight.Adornee == character) then
			if highlight then highlight:Destroy() end
			highlight = Instance.new("Highlight")
			highlight.Name = "PotentEsp"
			highlight.Adornee = character
			highlight.Enabled = true
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = Color3.fromRGB(235, 65, 75)
			highlight.OutlineColor = Color3.fromRGB(255, 210, 70)
			highlight.FillTransparency = 0.55
			highlight.OutlineTransparency = 0
			highlight.Parent = espFolder
			espHighlights[character] = highlight
		end
		if not espBoxes[character] then
			local box = Drawing.new("Square")
			box.Color = Color3.fromRGB(255, 210, 70)
			box.Thickness = 2
			box.Filled = false
			box.Visible = false
			espBoxes[character] = box
		end
	end
	for character, highlight in pairs(espHighlights) do
		if seen[character] then continue end
		highlight:Destroy()
		espHighlights[character] = nil
	end
	for character, box in pairs(espBoxes) do
		if seen[character] then continue end
		box:Remove()
		espBoxes[character] = nil
	end
end

---Keep distant ESP outlines aligned with the current camera.
---@param camera Camera
local function updateEspBoxes(camera)
	for character, box in pairs(espBoxes) do
		local head = character:FindFirstChild("Head")
		local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
		if not settings.esp or not head or not rootPart then
			box.Visible = false
			continue
		end
		local top, topVisible = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
		local bottom, bottomVisible = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 2.5, 0))
		if not topVisible or not bottomVisible then
			box.Visible = false
			continue
		end
		local height = math.clamp(math.abs(bottom.Y - top.Y), 24, 300)
		local width = math.clamp(height * 0.45, 18, 150)
		local centerX = (top.X + bottom.X) / 2
		box.Position = Vector2.new(centerX - width / 2, math.min(top.Y, bottom.Y))
		box.Size = Vector2.new(width, height)
		box.Visible = true
	end
end

---Return an enemy directly under the game's firing ray.
---@return Model?
local function getTriggerTarget()
	local origin, direction = cameraController:GetAimRay()
	local result = workspace:Raycast(origin, direction * 1500, getTargetRaycastParams())
	if not result then return nil end
	for _, character in ipairs(getEnemyCharacters()) do
		if result.Instance:IsDescendantOf(character) then
			return character
		end
	end
	return nil
end

---Return the local humanoid used by movement modifiers.
---@return Humanoid?
local function getLocalHumanoid()
	local character = localPlayer and localPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

---Remember baseline movement values so toggles can restore cleanly.
---@param humanoid Humanoid
---@return table
local function getMovementDefaults(humanoid)
	local defaults = movementDefaults[humanoid]
	if defaults then return defaults end
	defaults = {}
	pcall(function() defaults.walkSpeed = humanoid.WalkSpeed end)
	pcall(function() defaults.jumpPower = humanoid.JumpPower end)
	pcall(function() defaults.jumpHeight = humanoid.JumpHeight end)
	pcall(function() defaults.useJumpPower = humanoid.UseJumpPower end)
	movementDefaults[humanoid] = defaults
	return defaults
end

---Set a humanoid property without breaking on game-specific rigs.
---@param humanoid Humanoid
---@param property string
---@param value any
local function setHumanoidProperty(humanoid, property, value)
	if value == nil then return end
	pcall(function()
		humanoid[property] = value
	end)
end

---Apply or restore enabled movement modifiers.
local function updateMovementModifiers()
	local humanoid = getLocalHumanoid()
	if not humanoid or humanoid.Health <= 0 then return end
	local defaults = getMovementDefaults(humanoid)
	if settings.speed then
		setHumanoidProperty(humanoid, "WalkSpeed", settings.speedModifier)
	else
		setHumanoidProperty(humanoid, "WalkSpeed", defaults.walkSpeed)
	end
	if settings.jump then
		setHumanoidProperty(humanoid, "UseJumpPower", true)
		setHumanoidProperty(humanoid, "JumpPower", settings.jumpModifier)
		setHumanoidProperty(humanoid, "JumpHeight", settings.jumpModifier / 7)
	else
		setHumanoidProperty(humanoid, "UseJumpPower", defaults.useJumpPower)
		setHumanoidProperty(humanoid, "JumpPower", defaults.jumpPower)
		setHumanoidProperty(humanoid, "JumpHeight", defaults.jumpHeight)
	end
end

---Restore the local humanoid after a movement toggle is disabled.
local function restoreMovementModifiers()
	local humanoid = getLocalHumanoid()
	if not humanoid then return end
	local defaults = movementDefaults[humanoid]
	if not defaults then return end
	setHumanoidProperty(humanoid, "WalkSpeed", defaults.walkSpeed)
	setHumanoidProperty(humanoid, "UseJumpPower", defaults.useJumpPower)
	setHumanoidProperty(humanoid, "JumpPower", defaults.jumpPower)
	setHumanoidProperty(humanoid, "JumpHeight", defaults.jumpHeight)
end

---Convert any desktop or mobile jump request into another jump.
local function performInfiniteJump()
	if not settings.infiniteJump then return end
	updateMovementModifiers()
	local humanoid = getLocalHumanoid()
	if humanoid and humanoid.Health > 0 then
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end
end

---Stop this execution and remove its visual state.
function PotentBeginner.destroy()
	if destroyed then return end
	destroyed = true
	if renderConnection then renderConnection:Disconnect() end
	if guiToggleConnection then guiToggleConnection:Disconnect() end
	for _, connection in ipairs(espConnections) do connection:Disconnect() end
	restoreMovementModifiers()
	clearEsp()
	if espFolder then espFolder:Destroy() end
	if fovCircle then fovCircle:Remove() end
	if window and not window.unloaded then window:Unload() end
	if shared.PotentBeginner == PotentBeginner then shared.PotentBeginner = nil end
end

---Load the game's camera API and build the controls.
local function initializeScript()
	assert(localPlayer, "LocalPlayer is unavailable")
	local previousIdentity = getthreadidentity and getthreadidentity() or 8
	if setthreadidentity then setthreadidentity(2) end
	local cameraLoaded, cameraResult = pcall(require, replicatedStorage.Utils.CameraController)
	if setthreadidentity then setthreadidentity(previousIdentity) end
	assert(cameraLoaded, cameraResult)
	cameraController = cameraResult

	local source = game:HttpGet(RAYFIELD_URL)
	assert(source and #source > 0, "Rayfield Gen2 download failed")
	local loader, compileError = loadstring(source)
	assert(loader, compileError)
	capturePreviousSettings()
	if shared.PotentBeginner then shared.PotentBeginner.destroy() end
	rayfield = loader()
	assert(rayfield, "Rayfield Gen2 did not initialize")
	shared.PotentBeginner = PotentBeginner

	window = rayfield:CreateWindow({
		name = "Galaxy",
		subtitle = "zyke",
		sidebarLayout = true,
		theme = "cobalt",
		showName = "Potent",
		configuration = {
			autoSave = true,
			autoLoad = true,
			fileName = "PotentUGC",
			customFolder = "Potent",
		},
	})
	local combatTab = window:CreateTab({ name = "Combat", icon = "crosshair" })
	local visualsTab = window:CreateTab({ name = "Visuals", icon = "eye" })
	local miscTab = window:CreateTab({ name = "Misc", icon = "wrench" })
	local settingsTab = window:CreateTab({ name = "Settings", icon = "settings" })

	guiToggleConnection = userInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
			window:ToggleHide()
		end
	end)
	espFolder = Instance.new("Folder")
	espFolder.Name = "PotentEspHighlights"
	espFolder.Parent = workspace

	-- Character events catch respawns before the next periodic scan.
	local function observePlayer(player)
		table.insert(espConnections, player.CharacterAdded:Connect(function() task.defer(refreshEsp) end))
		table.insert(espConnections, player.CharacterRemoving:Connect(function() task.defer(refreshEsp) end))
		table.insert(espConnections, player:GetPropertyChangedSignal("Team"):Connect(refreshEsp))
	end
	for _, player in ipairs(playersService:GetPlayers()) do observePlayer(player) end
	table.insert(espConnections, playersService.PlayerAdded:Connect(observePlayer))
	table.insert(espConnections, playersService.PlayerRemoving:Connect(function() task.defer(refreshEsp) end))
	table.insert(espConnections, userInputService.JumpRequest:Connect(performInfiniteJump))
	local charactersFolder = workspace:FindFirstChild("PlayersCharacters")
	if charactersFolder then
		table.insert(espConnections, charactersFolder.ChildAdded:Connect(function() task.defer(refreshEsp) end))
		table.insert(espConnections, charactersFolder.ChildRemoved:Connect(function() task.defer(refreshEsp) end))
	end

	combatTab:CreateSection({ name = "Aim Assistance" })

	combatTab:CreateToggle({
		name = "Aimbot",
		description = "Tracks the nearest valid target inside the selected FOV.",
		value = settings.aimbot,
		flag = "PotentAimbot",
		callback = function(value) settings.aimbot = value end,
	})
	combatTab:CreateDropdown({
		name = "Aimbot Activation",
		options = { "Right Click Hold", "Scope Hold", "Key Hold", "Always On" },
		value = settings.aimbotActivation,
		multiSelect = false,
		flag = "PotentAimbotActivation",
		callback = function(value) settings.aimbotActivation = value or "Right Click Hold" end,
	})
	aimbotHoldKeybind = combatTab:CreateKeybind({
		name = "Aimbot Hold Key",
		description = "Used when Aimbot Activation is set to Key Hold.",
		value = settings.holdKey,
		hold = true,
		flag = "PotentAimbotKey",
		callback = function(isHeld) aimbotKeyHeld = isHeld end,
		onChanged = function(key)
			settings.holdKey = tostring(key):match("[^.]+$") or settings.holdKey
		end,
	})
	combatTab:CreateSlider({
		name = "Aimbot FOV Radius",
		range = { 40, 500 },
		increment = 5,
		suffix = " px",
		value = settings.fovRadius,
		flag = "PotentFovRadius",
		callback = function(value) settings.fovRadius = value end,
	})
	combatTab:CreateSlider({
		name = "Aimbot Smoothness",
		range = { 0.05, 1 },
		increment = 0.05,
		value = settings.smoothness,
		flag = "PotentSmoothness",
		callback = function(value) settings.smoothness = value end,
	})
	combatTab:CreateToggle({
		name = "Wall Check",
		description = "Ignores targets blocked by geometry.",
		value = settings.wallCheck,
		flag = "PotentWallCheck",
		callback = function(value) settings.wallCheck = value end,
	})
	combatTab:CreateDropdown({
		name = "Target Part",
		options = { "Head", "Torso" },
		value = settings.targetPart,
		multiSelect = false,
		flag = "PotentTargetPart",
		callback = function(value) settings.targetPart = value or "Head" end,
	})

	combatTab:CreateSection({ name = "Automatic Combat" })

	combatTab:CreateToggle({
		name = "Triggerbot",
		description = "Attacks when a valid target is under the aim ray.",
		value = settings.triggerbot,
		flag = "PotentTriggerbot",
		callback = function(value) settings.triggerbot = value end,
	})
	combatTab:CreateDropdown({
		name = "Triggerbot Activation",
		options = { "Right Click Hold", "Scope Hold", "Key Hold", "Always On" },
		value = settings.triggerbotActivation,
		multiSelect = false,
		flag = "PotentTriggerbotActivation",
		callback = function(value) settings.triggerbotActivation = value or "Always On" end,
	})
	triggerbotHoldKeybind = combatTab:CreateKeybind({
		name = "Triggerbot Hold Key",
		description = "Used when Triggerbot Activation is set to Key Hold.",
		value = settings.triggerHoldKey,
		hold = true,
		flag = "PotentTriggerbotKey",
		callback = function(isHeld) triggerbotKeyHeld = isHeld end,
		onChanged = function(key)
			settings.triggerHoldKey = tostring(key):match("[^.]+$") or settings.triggerHoldKey
		end,
	})
	combatTab:CreateToggle({
		name = "Instant Kill",
		description = "Runs the existing close-range knife routine.",
		value = settings.instantKill,
		flag = "PotentInstantKill",
		callback = function(value)
			settings.instantKill = value
			lastInstantKillTime = 0
			if value then
				task.spawn(runInstantKillPass)
			end
		end,
	})

	visualsTab:CreateSection({ name = "Target Visuals" })
	visualsTab:CreateToggle({
		name = "ESP",
		description = "Draws highlights and boxes on valid targets.",
		value = settings.esp,
		flag = "PotentEsp",
		callback = function(value) settings.esp = value; refreshEsp() end,
	})
	visualsTab:CreateToggle({
		name = "Show FOV",
		description = "Shows the current aimbot radius at screen center.",
		value = settings.showFov,
		flag = "PotentShowFov",
		callback = function(value) settings.showFov = value end,
	})

	miscTab:CreateSection({ name = "Movement" })
	miscTab:CreateToggle({
		name = "Speed",
		value = settings.speed,
		flag = "PotentSpeed",
		callback = function(value) settings.speed = value; updateMovementModifiers() end,
	})
	miscTab:CreateSlider({
		name = "Speed Modifier",
		range = { 16, 120 },
		increment = 1,
		suffix = " ws",
		value = settings.speedModifier,
		flag = "PotentSpeedModifier",
		callback = function(value) settings.speedModifier = value; updateMovementModifiers() end,
	})
	miscTab:CreateToggle({
		name = "Jump",
		value = settings.jump,
		flag = "PotentJump",
		callback = function(value) settings.jump = value; updateMovementModifiers() end,
	})
	miscTab:CreateSlider({
		name = "Jump Modifier",
		range = { 50, 200 },
		increment = 5,
		suffix = " jp",
		value = settings.jumpModifier,
		flag = "PotentJumpModifier",
		callback = function(value) settings.jumpModifier = value; updateMovementModifiers() end,
	})
	miscTab:CreateToggle({
		name = "Infinite Jump",
		value = settings.infiniteJump,
		flag = "PotentInfiniteJump",
		callback = function(value) settings.infiniteJump = value end,
	})

	settingsTab:CreateSection({ name = "Interface" })
	settingsTab:CreateDropdown({
		name = "Theme",
		options = { "default", "cobalt", "ember", "amethyst", "frost", "rose" },
		value = "cobalt",
		multiSelect = false,
		flag = "PotentTheme",
		callback = function(selectedTheme)
			if selectedTheme then window:ChangeTheme(selectedTheme) end
		end,
	})
	settingsTab:CreateButton({
		name = "Show Welcome Notification",
		callback = function()
			window:Notify({
				title = "Potent | UGC",
				content = "Press K to show or hide the interface.",
			})
		end,
	})
	settingsTab:CreateButton({ name = "Unload GUI", callback = PotentBeginner.destroy })

	fovCircle = Drawing.new("Circle")
	fovCircle.Color = Color3.fromRGB(240, 190, 75)
	fovCircle.Thickness = 1.5
	fovCircle.NumSides = 64
	fovCircle.Filled = false
	fovCircle.Visible = false

	-- Render targeting after the game's camera has updated.
	renderConnection = runService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if not camera then return end
		fovCircle.Position = camera.ViewportSize / 2
		fovCircle.Radius = settings.fovRadius
		fovCircle.Visible = settings.showFov
		updateEspBoxes(camera)

		local now = os.clock()
		if now - lastEspTime >= ESP_INTERVAL then
			lastEspTime = now
			refreshEsp()
		end
		if localPlayer.Character then updateMovementModifiers() end
		if not localPlayer.Character or not cameraController then return end
		updateInstantKill(now)
		if isCombatReady() and isAimbotActive() and not userInputService:GetFocusedTextBox() then
			local _, targetPart = getClosestPlayer()
			if targetPart then cameraController:LerpToTarget(targetPart.Position, settings.smoothness) end
		end
		if isCombatReady() and isTriggerbotActive() and now - lastTriggerTime >= TRIGGER_INTERVAL and not userInputService:GetFocusedTextBox() then
			if getTriggerTarget() then
				lastTriggerTime = now
				sendCombatAction("M1")
			end
		end
	end)

	window:Notify({
		title = "Loaded",
		content = "Potent | UGC is ready. Press K to toggle the GUI.",
	})
end

---Warn on initialization errors and remove partial state.
---@param errorMessage string
local function onInitializeError(errorMessage)
	warn("Potent Beginner failed: " .. tostring(errorMessage))
	warn(debug.traceback())
	PotentBeginner.destroy()
end

-- Initialize safely so a failed download leaves no active controls.
xpcall(initializeScript, onInitializeError)
