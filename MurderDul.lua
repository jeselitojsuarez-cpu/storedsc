-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

-- Initialize Luraph globals if they do not exist.
loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()

getfenv().PP_SCRAMBLE_NUM = function(...)
	return ...
end
getfenv().PP_SCRAMBLE_STR = function(...)
	return ...
end
getfenv().PP_SCRAMBLE_RE_NUM = function(...)
	return ...
end

local Galaxy = {
	aimbot = true,
	triggerbot = false,
	instantKill = true,
	esp = true,
	tracers = true,
	fovCircle = true,
	teamCheck = false,
	aimPart = "Head",
	fovRadius = 360,
	smoothing = 1,
	triggerRadius = 24,
	triggerDelay = 0.045,
	triggerRange = 1200,
	triggerBodyScale = 1.35,
	lastTrigger = 0,
	lastInstantKillKey = nil,
	instantKillBusy = false,
	lastInstantKillHits = 0,
	instantKillPassDuration = 6,
	instantKillCooldown = 0.15,
	instantKillSweepDelay = 0.10,
	instantKillHidePov = true,
	lastInstantKillVisualUpdate = 0,
	nextInstantKillAt = 0,
	lastGunShotId = 0,
	roundWasLive = false,
	revengeTargetUserId = nil,
	lastDamageEnemyUserId = nil,
	lastDamageMatchId = nil,
	lastHealth = nil,
	targetCount = 0,
	frameCount = 0,
	lastError = nil,
	inCombat = false,
	guiOpen = false,
	window = nil,
	drawings = {},
	connections = {},
}

-- Constants.
local GUI_NAME = "GalaxyMurderDuels"
local ACCENT_COLOR = Color3.fromRGB(85, 180, 255)
local BACKGROUND_COLOR = Color3.fromRGB(10, 12, 17)
local PANEL_COLOR = Color3.fromRGB(18, 21, 29)
local SURFACE_COLOR = Color3.fromRGB(28, 33, 44)
local MUTED_COLOR = Color3.fromRGB(128, 139, 160)
local TEXT_COLOR = Color3.fromRGB(235, 240, 255)
local INSTANT_KILL_BEHIND_DISTANCE = 5
local RENDER_STEP_NAME = "GalaxyMurderDuels_Render"

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local coreGuiService = game:GetService("CoreGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local guiService = game:GetService("GuiService")
local virtualInputManager = game:GetService("VirtualInputManager")
local starterGuiService = game:GetService("StarterGui")

-- State.
local localPlayer = playersService.LocalPlayer
local currentCamera = workspace.CurrentCamera
local charactersFolder = workspace:FindFirstChild("Characters")
local remotesFolder = replicatedStorage:WaitForChild("Remotes")
local reportHitRemote = remotesFolder:WaitForChild("ReportHit")
local dragging = false
local dragStart = nil
local frameStart = nil
local trackedCharacter = nil
local trackedHumanoid = nil
local inputMapModule = nil
local mouseUnlockActive = false
local savedMouseBehavior = nil
local savedMouseIconEnabled = nil

---Return the screen point used by aim and trigger features.
---@return Vector2
local function getAimScreenPosition()
	currentCamera = workspace.CurrentCamera

	if userInputService.TouchEnabled and currentCamera then
		local cursorGui = localPlayer
			and localPlayer:FindFirstChildOfClass("PlayerGui")
			and localPlayer.PlayerGui:FindFirstChild("Cursor")
		local viewportHeight = cursorGui and cursorGui.AbsoluteSize.Y or currentCamera.ViewportSize.Y

		return Vector2.new(currentCamera.ViewportSize.X / 2, viewportHeight / 2)
	end

	local mousePosition = userInputService:GetMouseLocation()
	return Vector2.new(mousePosition.X, mousePosition.Y)
end

-- Body part names keep ESP locked to the avatar instead of weapons/accessories.
local bodyPartNames = {
	Head = true,
	Torso = true,
	UpperTorso = true,
	LowerTorso = true,
	HumanoidRootPart = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

-- Trigger checks favor center-mass parts first for more reliable shots.
local triggerPartNames = {
	"Head",
	"Torso",
	"UpperTorso",
	"LowerTorso",
	"HumanoidRootPart",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftUpperLeg",
	"RightUpperLeg",
}

---Refresh local combat state from replicated player attributes.
local function updateCombatState()
	localPlayer = playersService.LocalPlayer
	Galaxy.inCombat = localPlayer
		and localPlayer:GetAttribute("InMatch") == true
		and localPlayer:GetAttribute("Alive") == true
		or false
end

---Keep the PC mouse usable while the menu is open over combat.
---@param shouldUnlock boolean
local function updateGuiMouseUnlock(shouldUnlock)
	if userInputService.TouchEnabled then
		return
	end

	if shouldUnlock then
		if not mouseUnlockActive then
			savedMouseBehavior = userInputService.MouseBehavior
			savedMouseIconEnabled = userInputService.MouseIconEnabled
			mouseUnlockActive = true
		end

		userInputService.MouseBehavior = Enum.MouseBehavior.Default
		userInputService.MouseIconEnabled = true
		return
	end

	if not mouseUnlockActive then
		return
	end

	userInputService.MouseBehavior = savedMouseBehavior or Enum.MouseBehavior.Default
	userInputService.MouseIconEnabled = savedMouseIconEnabled ~= false
	mouseUnlockActive = false
	savedMouseBehavior = nil
	savedMouseIconEnabled = nil
end

---Disconnect all connections and remove drawings.
function Galaxy.detach()
	updateGuiMouseUnlock(false)
	if type(Galaxy.restoreInstantKillVisuals) == "function" then
		pcall(Galaxy.restoreInstantKillVisuals)
	end

	pcall(function()
		runService:UnbindFromRenderStep(RENDER_STEP_NAME)
	end)

	for _, connection in ipairs(Galaxy.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	for _, group in pairs(Galaxy.drawings) do
		for _, drawing in pairs(group) do
			pcall(function()
				drawing:Remove()
			end)
		end
	end

	if Galaxy.fovDrawing then
		pcall(function()
			Galaxy.fovDrawing:Remove()
		end)

		Galaxy.fovDrawing = nil
	end

	if Galaxy.window then
		local window = Galaxy.window
		Galaxy.window = nil
		pcall(function()
			if type(window.Unload) == "function" then
				window:Unload()
			end
		end)
	end

	local oldGui = (gethui and gethui() or coreGuiService):FindFirstChild(GUI_NAME)
	if oldGui then
		oldGui:Destroy()
	end
	table.clear(Galaxy.connections)
	table.clear(Galaxy.drawings)
end

---Return whether a character should be targeted.
---@param character Model
---@return boolean
local function isValidTarget(character)
	localPlayer = playersService.LocalPlayer

	if not character or not character:IsA("Model") then
		return false
	end

	if localPlayer and character.Name == localPlayer.Name then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then
		return false
	end

	local targetPlayer = playersService:FindFirstChild(character.Name)
	local localMatchId = localPlayer and localPlayer:GetAttribute("MatchId")
	local localSide = localPlayer and localPlayer:GetAttribute("MatchSide")

	updateCombatState()

	if not Galaxy.inCombat then
		return false
	end

	if not targetPlayer then
		return false
	end

	local targetInMatch = targetPlayer:GetAttribute("InMatch") == true
	local targetAlive = targetPlayer:GetAttribute("Alive") == true
	local targetMatchId = targetPlayer:GetAttribute("MatchId")
	local targetSide = targetPlayer:GetAttribute("MatchSide")

	if not targetInMatch or not targetAlive then
		return false
	end

	if not localMatchId or not targetMatchId or localMatchId ~= targetMatchId then
		return false
	end

	if not localSide or not targetSide or localSide == targetSide then
		return false
	end

	if
		Galaxy.teamCheck
		and targetPlayer
		and localPlayer
		and targetPlayer.Team == localPlayer.Team
		and tostring(localPlayer.Team) ~= "Lobby"
	then
		return false
	end

	return true
end

---Return whether movement/combat is unlocked after countdown.
---@return boolean
local function isRoundLive()
	localPlayer = playersService.LocalPlayer

	if not localPlayer or localPlayer:GetAttribute("InMatch") ~= true or localPlayer:GetAttribute("Alive") ~= true then
		return false
	end

	local moveUnlockAt = tonumber(localPlayer:GetAttribute("MoveUnlockAt")) or 0
	if moveUnlockAt <= 0 then
		return true
	end

	return workspace:GetServerTimeNow() >= moveUnlockAt
end

---Return a player referenced by common damage creator tags.
---@param humanoid Humanoid
---@return Player?
local function getTaggedKiller(humanoid)
	local tagNames = {
		"creator",
		"killer",
		"attacker",
		"LastHitBy",
		"LastDamager",
		"DamageOwner",
	}

	for _, tagName in ipairs(tagNames) do
		local tag = humanoid:FindFirstChild(tagName)
		local value = tag and tag.Value

		if typeof(value) == "Instance" and value:IsA("Player") then
			return value
		end

		if typeof(value) == "Instance" then
			local player = playersService:FindFirstChild(value.Name)
			if player then
				return player
			end
		end
	end

	return nil
end

---Return the closest alive enemy as a fallback damage source.
---@return Player?
local function getClosestMatchEnemy()
	localPlayer = playersService.LocalPlayer
	charactersFolder = workspace:FindFirstChild("Characters")

	if not localPlayer or not localPlayer.Character or not charactersFolder then
		return nil
	end

	local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return nil
	end

	local closestPlayer = nil
	local closestDistance = math.huge

	for _, character in ipairs(charactersFolder:GetChildren()) do
		if not isValidTarget(character) then
			continue
		end

		local enemyPlayer = playersService:FindFirstChild(character.Name)
		local enemyRoot = character:FindFirstChild("HumanoidRootPart")
		if not enemyPlayer or not enemyRoot then
			continue
		end

		local distance = (enemyRoot.Position - rootPart.Position).Magnitude
		if distance >= closestDistance then
			continue
		end

		closestPlayer = enemyPlayer
		closestDistance = distance
	end

	return closestPlayer
end

---Remember the likely enemy who damaged or killed us.
---@param humanoid Humanoid
local function updateLastDamageEnemy(humanoid)
	local killer = getTaggedKiller(humanoid) or getClosestMatchEnemy()

	if not killer or killer == localPlayer then
		return
	end

	if killer:GetAttribute("MatchId") ~= localPlayer:GetAttribute("MatchId") then
		return
	end

	if killer:GetAttribute("MatchSide") == localPlayer:GetAttribute("MatchSide") then
		return
	end

	Galaxy.lastDamageEnemyUserId = killer.UserId
	Galaxy.lastDamageMatchId = localPlayer:GetAttribute("MatchId")
end

---Return all valid enemy characters in this match.
---@return table
local function getEnemyCharacters()
	local enemies = {}
	charactersFolder = workspace:FindFirstChild("Characters")

	if not charactersFolder then
		return enemies
	end

	for _, character in ipairs(charactersFolder:GetChildren()) do
		if isValidTarget(character) then
			table.insert(enemies, character)
		end
	end

	if Galaxy.revengeTargetUserId then
		local revengeAlive = false

		for _, character in ipairs(enemies) do
			local player = playersService:FindFirstChild(character.Name)
			if player and player.UserId == Galaxy.revengeTargetUserId then
				revengeAlive = true
				break
			end
		end

		if not revengeAlive then
			Galaxy.revengeTargetUserId = nil
		end
	end

	table.sort(enemies, function(left, right)
		local leftPlayer = playersService:FindFirstChild(left.Name)
		local rightPlayer = playersService:FindFirstChild(right.Name)
		local leftIsRevenge = leftPlayer and leftPlayer.UserId == Galaxy.revengeTargetUserId
		local rightIsRevenge = rightPlayer and rightPlayer.UserId == Galaxy.revengeTargetUserId

		if leftIsRevenge ~= rightIsRevenge then
			return leftIsRevenge
		end

		local leftHumanoid = left:FindFirstChildOfClass("Humanoid")
		local rightHumanoid = right:FindFirstChildOfClass("Humanoid")
		local leftHealth = leftHumanoid and leftHumanoid.Health or math.huge
		local rightHealth = rightHumanoid and rightHumanoid.Health or math.huge

		if leftHealth == rightHealth then
			return left.Name < right.Name
		end

		return leftHealth < rightHealth
	end)

	return enemies
end

---Return the currently equipped tool.
---@return Tool?
local function getEquippedTool()
	localPlayer = playersService.LocalPlayer

	local character = localPlayer and localPlayer.Character
	if not character then
		return nil
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			return child
		end
	end

	return nil
end

---Equip a combat tool for mobile activation.
---@return Tool?
local function equipCombatTool()
	local equippedTool = getEquippedTool()
	if equippedTool and equippedTool.Name ~= "Knife" then
		return equippedTool
	end

	localPlayer = playersService.LocalPlayer

	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local backpack = localPlayer and localPlayer:FindFirstChildOfClass("Backpack")
	if not humanoid or not backpack then
		return nil
	end

	local preferredNames = {
		"Revolver",
		"Gun",
		"Pistol",
	}

	for _, toolName in ipairs(preferredNames) do
		local tool = backpack:FindFirstChild(toolName)
		if tool and tool:IsA("Tool") then
			humanoid:EquipTool(tool)
			return getEquippedTool() or tool
		end
	end

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.Name ~= "Knife" then
			humanoid:EquipTool(tool)
			return getEquippedTool() or tool
		end
	end

	return equippedTool
end

---Activate a tool without touching mobile movement controls.
---@param tool Tool
local function activateTool(tool)
	pcall(function()
		tool.ManualActivationOnly = false
	end)

	pcall(function()
		tool:Activate()
	end)

	if firesignal then
		pcall(firesignal, tool.Activated)
	end

	task.delay(0.035, function()
		pcall(function()
			tool:Deactivate()
		end)

		if firesignal then
			pcall(firesignal, tool.Deactivated)
		end
	end)
end

---Return screen coordinates for synthetic fire input.
---@return Vector2
local function getFireScreenPosition()
	currentCamera = workspace.CurrentCamera

	if currentCamera then
		local viewportCenter = getAimScreenPosition()
		local inset = guiService:GetGuiInset()
		return viewportCenter + Vector2.new(inset.X, inset.Y)
	end

	local mousePosition = userInputService:GetMouseLocation()
	return Vector2.new(mousePosition.X, mousePosition.Y)
end

---Send mouse input because many mobile gun scripts still listen for mouse down.
local function clickPrimaryInput()
	if mouse1click then
		pcall(mouse1click)
		return
	end

	if mouse1press and mouse1release then
		pcall(mouse1press)
		task.delay(0.018, function()
			pcall(mouse1release)
		end)
	end
end

---Send Roblox virtual input for mobile button-backed tools.
local function clickVirtualPrimaryInput()
	local screenPosition = getFireScreenPosition()

	pcall(function()
		virtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, true, game, 0)
	end)

	task.delay(0.018, function()
		pcall(function()
			virtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, false, game, 0)
		end)
	end)
end

---Use the game's input mapper so RevolverClient receives the same attack event.
local function tapGameAttackInput()
	if not inputMapModule then
		local oldIdentity = getthreadidentity and getthreadidentity() or nil

		pcall(function()
			if setthreadidentity then
				setthreadidentity(2)
			end

			inputMapModule = require(replicatedStorage:WaitForChild("Extensions"):WaitForChild("InputMap"))
		end)

		pcall(function()
			if setthreadidentity then
				setthreadidentity(oldIdentity or 8)
			end
		end)
	end

	if inputMapModule and inputMapModule.tap then
		pcall(function()
			inputMapModule.tap("Attack")
		end)
	end
end

---Return whether a GUI button looks like a mobile fire control.
---@param button GuiButton
---@return boolean
local function isMobileFireButton(button)
	local buttonName = string.lower(button.Name or "")
	local buttonText = button:IsA("TextButton") and string.lower(button.Text or "") or ""
	local matchedName = buttonName:find("fire")
		or buttonName:find("shoot")
		or buttonName:find("shot")
		or buttonName:find("attack")
		or buttonName:find("combat")
		or buttonName:find("primary")
		or buttonName:find("m1")
	local matchedText = buttonText:find("fire")
		or buttonText:find("shoot")
		or buttonText:find("shot")
		or buttonText:find("attack")
		or buttonText:find("combat")
		or buttonText:find("primary")
		or buttonText:find("m1")

	if matchedName or matchedText then
		return true
	end

	return false
end

---Fire visible mobile shoot buttons when the gun controller ignores raw input.
local function clickMobileFireButtons()
	localPlayer = playersService.LocalPlayer

	local roots = {}
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		table.insert(roots, playerGui)
	end

	if gethui then
		table.insert(roots, gethui())
	end

	table.insert(roots, coreGuiService)

	for _, root in ipairs(roots) do
		if not root then
			continue
		end

		for _, descendant in ipairs(root:GetDescendants()) do
			if descendant:FindFirstAncestor(GUI_NAME) then
				continue
			end

			if not descendant:IsA("GuiButton") or not descendant.Visible or not isMobileFireButton(descendant) then
				continue
			end

			pcall(function()
				descendant:Activate()
			end)

			if firesignal then
				pcall(firesignal, descendant.MouseButton1Down)
				pcall(firesignal, descendant.MouseButton1Click)
				pcall(firesignal, descendant.Activated)
				task.delay(0.018, function()
					pcall(firesignal, descendant.MouseButton1Up)
				end)
			end
		end
	end
end

---Fire common character remotes used by mobile combat controllers.
local function fireCharacterPrimaryInput()
	localPlayer = playersService.LocalPlayer

	local character = localPlayer and localPlayer.Character
	if not character then
		return
	end

	local communicate = character:FindFirstChild("Communicate")
	if communicate and communicate:IsA("RemoteEvent") then
		pcall(function()
			communicate:FireServer({ Goal = "LeftClick" })
		end)

		task.delay(0.05, function()
			if communicate.Parent then
				pcall(function()
					communicate:FireServer({ Goal = "LeftClickRelease" })
				end)
			end
		end)
	end
end

---Report a visible gun hit when mobile Tool activation is ignored.
---@param targetCharacter Model?
---@param hitPart BasePart?
local function reportGunHit(targetCharacter, hitPart)
	if not targetCharacter or not hitPart then
		return
	end

	local targetPlayer = playersService:FindFirstChild(targetCharacter.Name)
	if not targetPlayer then
		return
	end

	local origin = currentCamera and currentCamera.CFrame.Position or hitPart.Position
	local direction = hitPart.Position - origin
	if direction.Magnitude <= 0 then
		return
	end

	pcall(function()
		reportHitRemote:FireServer({ forceShow = true })
		reportHitRemote:FireServer({
			kind = "gun",
			targetUserId = targetPlayer.UserId,
			targetModel = targetCharacter,
			hitPart = hitPart,
			position = hitPart.Position,
			origin = origin,
			direction = direction.Unit,
			at = workspace:GetServerTimeNow(),
			headshot = hitPart.Name == "Head",
		})
	end)
end

---Fire the local weapon across PC and mobile input modes.
---@param targetCharacter Model?
---@param hitPart BasePart?
local function firePrimaryWeapon(targetCharacter, hitPart)
	local tool = equipCombatTool()

	if userInputService.TouchEnabled then
		tapGameAttackInput()

		reportGunHit(targetCharacter, hitPart)

		return
	end

	clickPrimaryInput()

	if tool then
		activateTool(tool)
	end
end

---Return whether an enemy is still killable in the current match.
---@param enemy Model
---@return boolean
local function isEnemyStillAlive(enemy)
	localPlayer = playersService.LocalPlayer

	if not localPlayer or not enemy or not enemy.Parent then
		return false
	end

	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	local rootPart = enemy:FindFirstChild("HumanoidRootPart")
	local enemyPlayer = playersService:FindFirstChild(enemy.Name)

	if not humanoid or not rootPart or not enemyPlayer then
		return false
	end

	if enemyPlayer:GetAttribute("InMatch") ~= true then
		return false
	end

	if enemyPlayer:GetAttribute("Alive") == false then
		return false
	end

	if enemyPlayer:GetAttribute("MatchId") ~= localPlayer:GetAttribute("MatchId") then
		return false
	end

	if enemyPlayer:GetAttribute("MatchSide") == localPlayer:GetAttribute("MatchSide") then
		return false
	end

	return humanoid.Health > 0
end

---Return the best aim part for the target.
---@param character Model
---@return BasePart?
local function getAimPart(character)
	return character:FindFirstChild(Galaxy.aimPart)
end

---Return raycast params that ignore only local visual/self parts.
---@param extra table?
---@return RaycastParams
local function getRaycastParams(extra)
	local ignoreList = {}

	localPlayer = playersService.LocalPlayer
	if localPlayer and localPlayer.Character then
		table.insert(ignoreList, localPlayer.Character)
	end

	if currentCamera then
		table.insert(ignoreList, currentCamera)
	end

	if extra then
		for _, instance in ipairs(extra) do
			if instance then
				table.insert(ignoreList, instance)
			end
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = ignoreList
	return raycastParams
end

---Return whether camera has line of sight to a part.
---@param part BasePart
---@return boolean
local function isVisible(part)
	local origin = currentCamera.CFrame.Position
	local direction = part.Position - origin
	local raycastParams = getRaycastParams()

	local result = workspace:Raycast(origin, direction, raycastParams)
	return not result or result.Instance:IsDescendantOf(part.Parent)
end

---Return the visible trigger part closest to the provided screen position.
---@param character Model
---@param screenPosition Vector2
---@return BasePart?, number?
local function getClosestTriggerPart(character, screenPosition)
	local closestPart = nil
	local closestDistance = math.huge

	for _, partName in ipairs(triggerPartNames) do
		local part = character:FindFirstChild(partName)
		if not part or not part:IsA("BasePart") or not isVisible(part) then
			continue
		end

		local viewportPosition, onScreen = currentCamera:WorldToViewportPoint(part.Position)
		if not onScreen then
			continue
		end

		local distance =
			(Vector2.new(viewportPosition.X, viewportPosition.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
		if distance >= closestDistance then
			continue
		end

		closestPart = part
		closestDistance = distance
	end

	return closestPart, closestDistance
end

---Return the best body part for direct hit reports without requiring camera line of sight.
---@param targetCharacter Model
---@return BasePart?
local function getInstantKillReportPart(targetCharacter)
	local preferredParts = {
		"Head",
		Galaxy.aimPart,
		"UpperTorso",
		"Torso",
		"HumanoidRootPart",
	}

	for _, partName in ipairs(preferredParts) do
		local part = targetCharacter:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

---Mirror the game's predicted damage so the local client stops retargeting dead enemies.
---@param targetCharacter Model
---@param amount number
local function applyPredictedDamage(targetCharacter, amount)
	local humanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid:SetAttribute("PredictedHealth", (humanoid:GetAttribute("PredictedHealth") or humanoid.Health) - amount)

	humanoid.HealthChanged:Once(function()
		humanoid:SetAttribute("PredictedHealth", nil)
	end)

	task.delay(0.6, function()
		if humanoid and humanoid.Parent then
			humanoid:SetAttribute("PredictedHealth", nil)
		end
	end)
end

---Send the exact melee report shape without waiting for teleport or tool animation.
---@param enemy Model
---@return boolean
local function reportInstantMeleeHit(enemy)
	localPlayer = playersService.LocalPlayer

	if not localPlayer or not localPlayer.Character or not isEnemyStillAlive(enemy) then
		return false
	end

	local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		or localPlayer.Character:FindFirstChild("Torso")
		or localPlayer.Character:FindFirstChild("UpperTorso")
	local enemyPlayer = playersService:FindFirstChild(enemy.Name)
	local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
		or enemy:FindFirstChild("Torso")
		or enemy:FindFirstChild("UpperTorso")

	if not rootPart or not enemyPlayer or not enemyRoot then
		return false
	end

	pcall(function()
		reportHitRemote:FireServer({
			kind = "melee",
			targetUserId = enemyPlayer.UserId,
			targetModel = enemy,
			direction = rootPart.CFrame.LookVector,
			at = workspace:GetServerTimeNow(),
			backstab = true,
		})
	end)

	applyPredictedDamage(enemy, 250)

	return true
end

---Send the projectile controller's thrown-knife report shape directly.
---@param enemy Model
---@return boolean
local function reportInstantThrowHit(enemy)
	localPlayer = playersService.LocalPlayer
	currentCamera = workspace.CurrentCamera

	if not localPlayer or not localPlayer.Character or not isEnemyStillAlive(enemy) then
		return false
	end

	local hitPart = getInstantKillReportPart(enemy)
	local enemyPlayer = playersService:FindFirstChild(enemy.Name)
	local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		or localPlayer.Character:FindFirstChild("Torso")
		or localPlayer.Character:FindFirstChild("UpperTorso")
	local origin = currentCamera and currentCamera.CFrame.Position or rootPart and rootPart.Position

	if not hitPart or not enemyPlayer or not origin then
		return false
	end

	local direction = hitPart.Position - origin
	if direction.Magnitude <= 0 then
		return false
	end

	Galaxy.lastGunShotId = math.max(Galaxy.lastGunShotId + 1, math.floor(os.clock() * 1000))

	pcall(function()
		reportHitRemote:FireServer({
			kind = "throw",
			throwId = Galaxy.lastGunShotId,
			ownerUserId = localPlayer.UserId,
			targetUserId = enemyPlayer.UserId,
			targetModel = enemy,
			at = time(),
			origin = origin,
			to = hitPart.Position,
			vel = direction.Unit * 420,
			hitPart = hitPart,
			hitPos = hitPart.Position,
			headshot = hitPart.Name == "Head",
		})
	end)

	applyPredictedDamage(enemy, hitPart.Name == "Head" and 250 or 100)

	return true
end

---Send a lightweight direct kill report without equipping or animating a weapon.
---@param enemy Model
---@return boolean
local function reportEnemyInstantKill(enemy)
	if not isEnemyStillAlive(enemy) then
		return false
	end

	-- Prefer one direct head/throw report: one packet, no equip, no animation.
	if reportInstantThrowHit(enemy) then
		return true
	end

	-- Rare fallback if no valid throw hit part is available.
	return reportInstantMeleeHit(enemy)
end

---Return the target character that owns an instance.
---@param instance Instance
---@return Model?
local function getCharacterFromInstance(instance)
	charactersFolder = workspace:FindFirstChild("Characters")

	while instance and instance ~= charactersFolder do
		if instance:IsA("Model") and instance.Parent == charactersFolder then
			return instance
		end

		instance = instance.Parent
	end

	return nil
end

---Return screen-space bounds for a visible character.
---@param character Model
---@return Vector2?, Vector2?, Vector2?
local function getCharacterScreenBounds(character)
	if not currentCamera then
		return nil
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return nil
	end

	local rootPosition, rootOnScreen = currentCamera:WorldToViewportPoint(rootPart.Position)
	if not rootOnScreen or rootPosition.Z <= 0 then
		return nil
	end

	local head = character:FindFirstChild("Head")
	local topWorldPosition = head and head:IsA("BasePart") and head.Position + Vector3.new(0, head.Size.Y * 0.65, 0)
		or rootPart.Position + Vector3.new(0, 3, 0)
	local bottomWorldPosition = rootPart.Position - Vector3.new(0, 3.2, 0)
	local topPosition = currentCamera:WorldToViewportPoint(topWorldPosition)
	local bottomPosition = currentCamera:WorldToViewportPoint(bottomWorldPosition)

	if topPosition.Z <= 0 or bottomPosition.Z <= 0 then
		return nil
	end

	local rootScreenPosition = Vector2.new(rootPosition.X, rootPosition.Y)
	local height = math.clamp(math.abs(bottomPosition.Y - topPosition.Y), 24, 420)
	local width = math.clamp(height * 0.46, 14, 180)
	local paddingX = math.clamp(width * 0.08, 2, 8)
	local paddingY = math.clamp(height * 0.06, 2, 8)
	local position =
		Vector2.new(rootScreenPosition.X - width / 2 - paddingX, math.min(topPosition.Y, bottomPosition.Y) - paddingY)
	local size = Vector2.new(width + paddingX * 2, height + paddingY * 2)

	return position, size, rootScreenPosition
end

---Return whether any main body part has clear line of sight.
---@param character Model
---@return boolean
local function hasLineOfSight(character)
	local bodyParts = {
		character:FindFirstChild(Galaxy.aimPart),
		character:FindFirstChild("Head"),
		character:FindFirstChild("UpperTorso"),
		character:FindFirstChild("Torso"),
		character:FindFirstChild("HumanoidRootPart"),
	}

	for _, part in ipairs(bodyParts) do
		if part and part:IsA("BasePart") and isVisible(part) then
			return true
		end
	end

	return false
end

---Return an approximate screen radius for a body part.
---@param part BasePart
---@return number
local function getBodyPartScreenRadius(part)
	local center = currentCamera:WorldToViewportPoint(part.Position)
	local right = currentCamera.CFrame.RightVector * part.Size.X * 0.5
	local up = currentCamera.CFrame.UpVector * part.Size.Y * 0.5
	local rightPoint = currentCamera:WorldToViewportPoint(part.Position + right)
	local upPoint = currentCamera:WorldToViewportPoint(part.Position + up)
	local rightDistance = (Vector2.new(center.X, center.Y) - Vector2.new(rightPoint.X, rightPoint.Y)).Magnitude
	local upDistance = (Vector2.new(center.X, center.Y) - Vector2.new(upPoint.X, upPoint.Y)).Magnitude

	return math.clamp(math.max(rightDistance, upDistance) * Galaxy.triggerBodyScale, 8, 48)
end

---Return whether the cursor is directly over a visible body part.
---@param character Model
---@param mousePos Vector2
---@return boolean
local function isMouseOverBodyPart(character, mousePos)
	for _, partName in ipairs(triggerPartNames) do
		local part = character:FindFirstChild(partName)
		if not part or not part:IsA("BasePart") or not isVisible(part) then
			continue
		end

		local screenPosition, onScreen = currentCamera:WorldToViewportPoint(part.Position)
		if not onScreen then
			continue
		end

		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
		if distance <= getBodyPartScreenRadius(part) then
			return true
		end
	end

	return false
end

---Return whether the mouse ray directly hits an enemy before a wall.
---@param mousePos Vector2
---@return boolean, Model?, BasePart?
local function getMouseRayTarget(mousePos)
	local viewportRay = currentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local result =
		workspace:Raycast(viewportRay.Origin, viewportRay.Direction * Galaxy.triggerRange, getRaycastParams())

	if not result then
		return false
	end

	local hitCharacter = getCharacterFromInstance(result.Instance)
	if hitCharacter and isValidTarget(hitCharacter) then
		local hitPart = result.Instance
		if hitPart:IsA("BasePart") and hitPart:IsDescendantOf(hitCharacter) and bodyPartNames[hitPart.Name] then
			return true, hitCharacter, hitPart
		end

		return true, hitCharacter
	end

	return false
end

---Return closest visible target inside the configured FOV.
---@return Model?, BasePart?, number?
local function getClosestTarget()
	currentCamera = workspace.CurrentCamera
	charactersFolder = workspace:FindFirstChild("Characters")

	if not currentCamera or not charactersFolder then
		return nil
	end

	local mousePos = getAimScreenPosition()
	local closestCharacter = nil
	local closestPart = nil
	local closestDistance = math.huge
	local targetCount = 0

	for _, character in ipairs(charactersFolder:GetChildren()) do
		if not isValidTarget(character) then
			continue
		end

		targetCount += 1
		local aimPart = getAimPart(character)
		if not aimPart or not isVisible(aimPart) then
			continue
		end

		local screenPosition, onScreen = currentCamera:WorldToViewportPoint(aimPart.Position)
		if not onScreen then
			continue
		end

		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
		if (distance > Galaxy.fovRadius and not Galaxy.aimbot) or distance >= closestDistance then
			continue
		end

		closestCharacter = character
		closestPart = aimPart
		closestDistance = distance
	end

	Galaxy.targetCount = targetCount
	return closestCharacter, closestPart, closestDistance
end

---Create a drawing object with defaults.
---@param drawingType string
---@return table
local function createDrawing(drawingType)
	local drawing = Drawing.new(drawingType)
	drawing.Visible = false
	drawing.Color = ACCENT_COLOR
	drawing.Transparency = 1

	if drawingType ~= "Text" and drawingType ~= "Image" then
		drawing.Thickness = 1
	end

	return drawing
end

---Show a small Roblox notification without blocking script startup.
---@param title string
---@param text string
local function notify(title, text)
	task.spawn(function()
		for _ = 1, 5 do
			local success = pcall(function()
				starterGuiService:SetCore("SendNotification", {
					Title = title,
					Text = text,
					Duration = 5,
				})
			end)

			if success then
				return
			end

			task.wait(0.5)
		end
	end)
end

---Return the Drawing ESP group for a character.
---@param character Model
---@return table
local function getEspGroup(character)
	local group = Galaxy.drawings[character]
	if group then
		return group
	end

	group = {
		box = createDrawing("Square"),
		name = createDrawing("Text"),
		tracer = createDrawing("Line"),
	}

	group.box.Filled = false
	group.name.Center = true
	group.name.Outline = true
	group.name.Size = 13
	group.tracer.Thickness = 1
	Galaxy.drawings[character] = group

	return group
end

---Hide every drawing in a group.
---@param group table
local function hideEspGroup(group)
	for _, drawing in pairs(group) do
		drawing.Visible = false
	end
end

---Update all target ESP drawings.
local function updateEsp()
	currentCamera = workspace.CurrentCamera
	charactersFolder = workspace:FindFirstChild("Characters")

	if not charactersFolder or not currentCamera then
		return
	end

	local targetCount = 0

	for character, group in pairs(Galaxy.drawings) do
		if not character.Parent or not isValidTarget(character) or not Galaxy.esp then
			hideEspGroup(group)
		end
	end

	if not Galaxy.esp then
		return
	end

	for _, character in ipairs(charactersFolder:GetChildren()) do
		if not isValidTarget(character) then
			continue
		end

		targetCount += 1
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			continue
		end

		local boxPosition, boxSize, rootScreenPosition = getCharacterScreenBounds(character)
		if not boxPosition or not boxSize or not rootScreenPosition then
			hideEspGroup(getEspGroup(character))
			continue
		end

		local group = getEspGroup(character)

		group.box.Position = boxPosition
		group.box.Size = boxSize
		group.box.Visible = true

		group.name.Position = Vector2.new(rootScreenPosition.X, boxPosition.Y - 15)
		group.name.Text = character.Name
		group.name.Visible = true

		group.tracer.From = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y)
		group.tracer.To = rootScreenPosition
		group.tracer.Visible = Galaxy.tracers
	end

	Galaxy.targetCount = targetCount
end

---Create spacing between control groups.
---@param parent Instance
---@param height number?
local function createSpacer(parent, height)
	local spacer = Instance.new("Frame")
	spacer.BackgroundTransparency = 1
	spacer.Size = UDim2.new(1, 0, 0, height or 2)
	spacer.Parent = parent
end

---Apply rounded corners to a GUI object.
---@param object Instance
---@param radius number
local function addCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object

	return corner
end

---Apply a soft border to a GUI object.
---@param object Instance
---@param color Color3
---@param transparency number?
local function addStroke(object, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = object

	return stroke
end

---Create a grouped label for feature controls.
---@param parent Instance
---@param text string
local function createSection(parent, text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Size = UDim2.new(1, 0, 0, 16)
	label.Text = text
	label.TextColor3 = ACCENT_COLOR
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
end

---Update a toggle button from its backing state.
---@param button TextButton
---@param text string
---@param key string
local function updateToggleButton(button, text, key)
	local enabled = Galaxy[key] == true

	button.BackgroundColor3 = enabled and Color3.fromRGB(32, 72, 102) or SURFACE_COLOR
	button.TextColor3 = TEXT_COLOR
	button.Text = text .. "  " .. (enabled and "ON" or "OFF")
end

---Create a compact toggle button.
---@param parent Instance
---@param text string
---@param key string
local function createToggle(parent, text, key)
	local button = Instance.new("TextButton")
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamMedium
	button.Size = UDim2.new(1, 0, 0, 34)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextSize = 13
	button.Parent = parent

	addCorner(button, 7)
	addStroke(button, Color3.fromRGB(52, 59, 76), 0.35)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = button

	updateToggleButton(button, text, key)

	button.MouseButton1Click:Connect(function()
		Galaxy[key] = not Galaxy[key]

		if key == "instantKill" and Galaxy.instantKill then
			Galaxy.lastInstantKillKey = nil
			Galaxy.nextInstantKillAt = 0
			Galaxy.roundWasLive = false
		end

		updateToggleButton(button, text, key)
	end)

	return button
end

---Create a numeric slider bound to a Galaxy setting.
---@param parent Instance
---@param text string
---@param key string
---@param min number
---@param max number
---@param step number
local function createSlider(parent, text, key, min, max, step)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 48)
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Size = UDim2.new(1, 0, 0, 18)
	label.TextColor3 = TEXT_COLOR
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local track = Instance.new("TextButton")
	track.BackgroundColor3 = SURFACE_COLOR
	track.BorderSizePixel = 0
	track.Position = UDim2.new(0, 0, 0, 28)
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Text = ""
	track.AutoButtonColor = false
	track.Parent = frame

	addCorner(track, 99)
	addStroke(track, Color3.fromRGB(52, 59, 76), 0.45)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = ACCENT_COLOR
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = track

	addCorner(fill, 99)

	local draggingSlider = false

	local function formatValue(value)
		if step >= 1 then
			return tostring(value)
		end

		return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
	end

	local function refresh()
		local alpha = math.clamp((Galaxy[key] - min) / (max - min), 0, 1)

		label.Text = text .. ": " .. formatValue(Galaxy[key])
		fill.Size = UDim2.fromScale(alpha, 1)
	end

	local function setValueFromX(x)
		if track.AbsoluteSize.X <= 0 then
			refresh()
			return
		end

		local alpha = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local rawValue = min + (max - min) * alpha
		local stepped = math.floor(rawValue / step + 0.5) * step

		Galaxy[key] = math.clamp(stepped, min, max)
		refresh()
	end

	refresh()

	track.InputBegan:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		draggingSlider = true
		setValueFromX(input.Position.X)
	end)

	track.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			draggingSlider = false
		end
	end)

	table.insert(
		Galaxy.connections,
		userInputService.InputChanged:Connect(function(input)
			if not draggingSlider then
				return
			end

			if
				input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			setValueFromX(input.Position.X)
		end)
	)
end

---Create a cycling dropdown bound to a Galaxy setting.
---@param parent Instance
---@param text string
---@param key string
---@param options table
local function createDropdown(parent, text, key, options)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = SURFACE_COLOR
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamMedium
	button.Size = UDim2.new(1, 0, 0, 34)
	button.TextColor3 = TEXT_COLOR
	button.TextSize = 13
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = parent

	addCorner(button, 7)
	addStroke(button, Color3.fromRGB(52, 59, 76), 0.35)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = button

	local function refresh()
		button.Text = text .. "  " .. tostring(Galaxy[key])
	end

	refresh()

	button.MouseButton1Click:Connect(function()
		local currentIndex = table.find(options, Galaxy[key]) or 1
		local nextIndex = currentIndex + 1

		if nextIndex > #options then
			nextIndex = 1
		end

		Galaxy[key] = options[nextIndex]
		refresh()
	end)
end

---Create a command button.
---@param parent Instance
---@param text string
---@param callback function
local function createButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = SURFACE_COLOR
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Size = UDim2.new(1, 0, 0, 36)
	button.Text = text
	button.TextColor3 = TEXT_COLOR
	button.TextSize = 13
	button.Parent = parent

	addCorner(button, 7)
	addStroke(button, Color3.fromRGB(52, 59, 76), 0.35)

	button.MouseButton1Click:Connect(callback)
end

---Create the script control GUI.
local function createGui()
	local parent = gethui and gethui() or coreGuiService
	local isMobile = userInputService.TouchEnabled
	local mainWidth = isMobile and 270 or 320
	local mainHeight = isMobile and 390 or 500
	local screenGui = Instance.new("ScreenGui")

	screenGui.Name = GUI_NAME
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = parent

	local mainFrame = Instance.new("Frame")
	mainFrame.BackgroundColor3 = BACKGROUND_COLOR
	mainFrame.BorderSizePixel = 0
	mainFrame.Position = UDim2.new(0.5, -mainWidth / 2, 0.5, -mainHeight / 2)
	mainFrame.Size = UDim2.new(0, mainWidth, 0, mainHeight)
	mainFrame.Parent = screenGui

	addCorner(mainFrame, 10)
	addStroke(mainFrame, Color3.fromRGB(65, 75, 96), 0.15)

	local title = Instance.new("Frame")
	title.BackgroundColor3 = PANEL_COLOR
	title.BorderSizePixel = 0
	title.Size = UDim2.new(1, 0, 0, 44)
	title.Active = true
	title.Parent = mainFrame

	addCorner(title, 10)

	local titleAccent = Instance.new("Frame")
	titleAccent.BackgroundColor3 = ACCENT_COLOR
	titleAccent.BorderSizePixel = 0
	titleAccent.Position = UDim2.new(0, 14, 0.5, -9)
	titleAccent.Size = UDim2.new(0, 4, 0, 18)
	titleAccent.Parent = title

	addCorner(titleAccent, 99)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Position = UDim2.new(0, 28, 0, 0)
	titleLabel.Size = UDim2.new(1, -78, 1, 0)
	titleLabel.Text = "Galaxy"
	titleLabel.TextColor3 = TEXT_COLOR
	titleLabel.TextSize = isMobile and 16 or 17
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = title

	local closeButton = Instance.new("TextButton")
	closeButton.BackgroundColor3 = SURFACE_COLOR
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Position = UDim2.new(1, -38, 0.5, -13)
	closeButton.Size = UDim2.new(0, 26, 0, 26)
	closeButton.Text = "X"
	closeButton.TextColor3 = MUTED_COLOR
	closeButton.TextSize = 12
	closeButton.Parent = title

	addCorner(closeButton, 7)
	addStroke(closeButton, Color3.fromRGB(52, 59, 76), 0.35)

	local listHolder = Instance.new("Frame")
	listHolder.BackgroundColor3 = PANEL_COLOR
	listHolder.BorderSizePixel = 0
	listHolder.Position = UDim2.new(0, 10, 0, 54)
	listHolder.Size = UDim2.new(1, -20, 1, -64)
	listHolder.Parent = mainFrame

	addCorner(listHolder, 8)
	addStroke(listHolder, Color3.fromRGB(52, 59, 76), 0.45)

	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.CanvasSize = UDim2.new()
	list.Position = UDim2.new(0, 10, 0, 10)
	list.ScrollBarThickness = 3
	list.Size = UDim2.new(1, -20, 1, -20)
	list.Parent = listHolder

	local padding = Instance.new("UIPadding")
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = list

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
	end)

	createSection(list, "COMBAT")
	createToggle(list, "Aimbot", "aimbot")
	createToggle(list, "Triggerbot", "triggerbot")
	local instantKillButton = createToggle(list, isMobile and "Instant Kill" or "Instant Kill [T]", "instantKill")

	createSection(list, "TARGETING")
	createDropdown(list, "Aim Part", "aimPart", { "Head", "UpperTorso", "Torso", "HumanoidRootPart" })
	createToggle(list, "Team Check", "teamCheck")
	createSlider(list, "FOV Radius", "fovRadius", 80, 800, 10)
	createSlider(list, "Smoothing", "smoothing", 0.05, 1, 0.05)
	createSlider(list, "Trigger Radius", "triggerRadius", 6, 80, 2)
	createSpacer(list, 2)

	createSection(list, "VISUALS")
	createToggle(list, "ESP", "esp")
	createToggle(list, "Tracers", "tracers")
	createToggle(list, "FOV Circle", "fovCircle")
	createSpacer(list, 2)

	createSection(list, "SETTINGS")
	createButton(list, "Unload Script & UI", function()
		Galaxy.detach()

		if shared.GalaxyMurderDuels == Galaxy then
			shared.GalaxyMurderDuels = nil
		end
	end)

	local function setOpen(open)
		Galaxy.guiOpen = open
		mainFrame.Visible = open
		updateGuiMouseUnlock(open and Galaxy.inCombat)
	end

	setOpen(mainFrame.Visible)

	closeButton.MouseButton1Click:Connect(function()
		setOpen(false)
	end)

	title.InputBegan:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		dragging = true
		dragStart = input.Position
		frameStart = mainFrame.Position
	end)

	title.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
		end
	end)

	table.insert(
		Galaxy.connections,
		userInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end

			if
				input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				frameStart.X.Scale,
				frameStart.X.Offset + delta.X,
				frameStart.Y.Scale,
				frameStart.Y.Offset + delta.Y
			)
		end)
	)

	table.insert(
		Galaxy.connections,
		userInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end

			if input.KeyCode == Enum.KeyCode.P then
				setOpen(not mainFrame.Visible)
				return
			end

			if not isMobile and input.KeyCode == Enum.KeyCode.T then
				Galaxy.instantKill = not Galaxy.instantKill

				if Galaxy.instantKill then
					Galaxy.lastInstantKillKey = nil
					Galaxy.nextInstantKillAt = 0
					Galaxy.roundWasLive = false
				end

				updateToggleButton(instantKillButton, "Instant Kill [T]", "instantKill")
			end
		end)
	)

	if not isMobile then
		notify("Galaxy", "Toggle P open and close")
	end
end

---Create the Rayfield Gen2 control center without changing combat behavior.
local function createRayfieldGui()
	local isMobile = userInputService.TouchEnabled
	local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
	local window = Rayfield:CreateWindow({
		name = "Galaxy Murder Duels",
		subtitle = "Combat Control Center",
		theme = "cobalt",
		sidebarLayout = true,
		profile = "Murder Duels tools",
		showName = "Galaxy",
		fallbackFont = Enum.Font.Gotham,
		configuration = {
			autoSave = true,
			autoLoad = true,
			fileName = "GalaxyMurderDuelsGen2",
			customFolder = "Galaxy",
		},
	})

	Galaxy.window = window
	local overlay = Instance.new("ScreenGui")
	overlay.Name = GUI_NAME
	overlay.ResetOnSpawn = false
	overlay.IgnoreGuiInset = true
	overlay.DisplayOrder = 1000
	overlay.Parent = gethui and gethui() or coreGuiService
	Galaxy.screenGui = overlay

	local combatTab = window:CreateTab({
		name = "Combat",
		icon = "crosshair",
	})
	local targetingTab = window:CreateTab({
		name = "Targeting",
		icon = "target",
	})
	local visualsTab = window:CreateTab({
		name = "Visuals",
		icon = "eye",
	})
	local settingsTab = window:CreateTab({
		name = "Settings",
		icon = "settings",
	})

	combatTab:CreateSection({
		name = "Combat Automation",
	})
	combatTab:CreateToggle({
		name = "Aimbot",
		description = "Tracks the closest valid enemy target.",
		value = Galaxy.aimbot,
		flag = "GalaxyMurderDuelsAimbot",
		callback = function(value)
			Galaxy.aimbot = value
		end,
	})
	combatTab:CreateToggle({
		name = "Triggerbot",
		description = "Fires when a valid target enters the trigger area.",
		value = Galaxy.triggerbot,
		flag = "GalaxyMurderDuelsTriggerbot",
		callback = function(value)
			Galaxy.triggerbot = value
		end,
	})

	local instantKillControl = combatTab:CreateToggle({
		name = "Instant Kill",
		description = isMobile and "Runs the instant-kill routine." or "Runs the instant-kill routine. Press T to toggle.",
		value = Galaxy.instantKill,
		flag = "GalaxyMurderDuelsInstantKill",
		callback = function(value)
			Galaxy.instantKill = value
			if value then
				Galaxy.lastInstantKillKey = nil
				Galaxy.nextInstantKillAt = 0
				Galaxy.roundWasLive = false
			end
		end,
	})

	targetingTab:CreateSection({
		name = "Target Selection",
	})
	targetingTab:CreateDropdown({
		name = "Aim Part",
		description = "Body part used by the targeting controls.",
		options = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"},
		value = Galaxy.aimPart,
		multiSelect = false,
		flag = "GalaxyMurderDuelsAimPart",
		callback = function(value)
			Galaxy.aimPart = value
		end,
	})
	targetingTab:CreateToggle({
		name = "Team Check",
		description = "Ignores players on the same team when applicable.",
		value = Galaxy.teamCheck,
		flag = "GalaxyMurderDuelsTeamCheck",
		callback = function(value)
			Galaxy.teamCheck = value
		end,
	})
	targetingTab:CreateSlider({
		name = "FOV Radius",
		range = {80, 800},
		increment = 10,
		suffix = " px",
		value = Galaxy.fovRadius,
		flag = "GalaxyMurderDuelsFovRadius",
		callback = function(value)
			Galaxy.fovRadius = value
		end,
	})
	targetingTab:CreateSlider({
		name = "Smoothing",
		range = {0.05, 1},
		increment = 0.05,
		suffix = "x",
		value = Galaxy.smoothing,
		flag = "GalaxyMurderDuelsSmoothing",
		callback = function(value)
			Galaxy.smoothing = value
		end,
	})
	targetingTab:CreateSlider({
		name = "Trigger Radius",
		range = {6, 80},
		increment = 2,
		suffix = " px",
		value = Galaxy.triggerRadius,
		flag = "GalaxyMurderDuelsTriggerRadius",
		callback = function(value)
			Galaxy.triggerRadius = value
		end,
	})

	visualsTab:CreateSection({
		name = "Visual Assistance",
	})
	visualsTab:CreateToggle({
		name = "ESP",
		description = "Shows valid enemy boxes and names.",
		value = Galaxy.esp,
		flag = "GalaxyMurderDuelsEsp",
		callback = function(value)
			Galaxy.esp = value
		end,
	})
	visualsTab:CreateToggle({
		name = "Tracers",
		description = "Draws lines from the bottom of the screen to targets.",
		value = Galaxy.tracers,
		flag = "GalaxyMurderDuelsTracers",
		callback = function(value)
			Galaxy.tracers = value
		end,
	})
	visualsTab:CreateToggle({
		name = "FOV Circle",
		description = "Displays the current targeting radius.",
		value = Galaxy.fovCircle,
		flag = "GalaxyMurderDuelsFovCircle",
		callback = function(value)
			Galaxy.fovCircle = value
		end,
	})

	settingsTab:CreateSection({
		name = "Interface",
	})
	settingsTab:CreateDropdown({
		name = "Theme",
		options = {"default", "cobalt", "ember", "amethyst", "frost", "rose"},
		value = "cobalt",
		multiSelect = false,
		flag = "GalaxyMurderDuelsTheme",
		callback = function(value)
			if value then
				window:ChangeTheme(value)
			end
		end,
	})
	settingsTab:CreateButton({
		name = "Save Configuration",
		description = "Save the current Rayfield control values.",
		icon = "save",
		callback = function()
			local saved = window:Save()
			window:Notify({
				title = saved and "Configuration Saved" or "Save Failed",
				content = saved and "Your current GUI settings were saved." or "Rayfield could not save the configuration.",
			})
		end,
	})
	settingsTab:CreateButton({
		name = "Unload Script & UI",
		description = "Stops the script and removes the interface.",
		icon = "trash-2",
		callback = function()
			Galaxy.detach()
			if shared.GalaxyMurderDuels == Galaxy then
				shared.GalaxyMurderDuels = nil
			end
		end,
	})

	local function setOpen(open)
		Galaxy.guiOpen = open
		if open then
			window:Show()
		else
			window:Hide()
		end
		updateGuiMouseUnlock(open and Galaxy.inCombat)
	end

	table.insert(
		Galaxy.connections,
		userInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end

			if input.KeyCode == Enum.KeyCode.P then
				setOpen(not Galaxy.guiOpen)
				return
			end

			if not isMobile and input.KeyCode == Enum.KeyCode.T then
				instantKillControl:Set(not Galaxy.instantKill)
			end
		end)
	)

	setOpen(true)
	window:Notify({
		title = "Galaxy Murder Duels",
		content = "Press P to show or hide the GUI.",
	})
end

---Create and update the FOV circle drawing.
local function updateFovCircle()
	if not Galaxy.fovDrawing then
		Galaxy.fovDrawing = createDrawing("Circle")
		Galaxy.fovDrawing.Filled = false
		Galaxy.fovDrawing.NumSides = 96
	end

	local mousePos = getAimScreenPosition()
	Galaxy.fovDrawing.Position = mousePos
	Galaxy.fovDrawing.Radius = Galaxy.fovRadius
	Galaxy.fovDrawing.Visible = Galaxy.fovCircle
end

---Return whether the cursor is on an enemy character.
---@return boolean, Model?
local function shouldTrigger()
	currentCamera = workspace.CurrentCamera
	charactersFolder = workspace:FindFirstChild("Characters")

	if not currentCamera or not charactersFolder then
		return false
	end

	local mousePos = getAimScreenPosition()
	local rayHit, rayCharacter = getMouseRayTarget(mousePos)

	if rayHit then
		return true, rayCharacter
	end

	for _, character in ipairs(charactersFolder:GetChildren()) do
		if not isValidTarget(character) then
			continue
		end

		if isMouseOverBodyPart(character, mousePos) then
			return true, character
		end
	end

	return false
end

---Return a mobile center-screen trigger target and exact visible hit part.
---@param targetCharacter Model?
---@param aimPart BasePart?
---@param distance number?
---@return boolean, Model?, BasePart?
local function shouldMobileTrigger(targetCharacter, aimPart, distance)
	currentCamera = workspace.CurrentCamera
	charactersFolder = workspace:FindFirstChild("Characters")

	if not currentCamera or not charactersFolder then
		return false
	end

	local screenPosition = getAimScreenPosition()
	local rayHit, rayCharacter, rayPart = getMouseRayTarget(screenPosition)

	if rayHit and rayCharacter then
		if rayPart and isVisible(rayPart) then
			return true, rayCharacter, rayPart
		end

		local closestPart = getClosestTriggerPart(rayCharacter, screenPosition)
		return closestPart ~= nil, rayCharacter, closestPart
	end

	local closestCharacter = nil
	local closestPart = nil
	local closestDistance = math.huge

	for _, character in ipairs(charactersFolder:GetChildren()) do
		if not isValidTarget(character) then
			continue
		end

		local part, partDistance = getClosestTriggerPart(character, screenPosition)
		local triggerRadius = part and math.max(Galaxy.triggerRadius, getBodyPartScreenRadius(part)) or Galaxy.triggerRadius
		if not part or not partDistance or partDistance > triggerRadius or partDistance >= closestDistance then
			continue
		end

		closestCharacter = character
		closestPart = part
		closestDistance = partDistance
	end

	if closestCharacter and closestPart then
		return true, closestCharacter, closestPart
	end

	if not targetCharacter or not aimPart or not distance or not isVisible(aimPart) then
		return false
	end

	local triggerRadius = math.max(Galaxy.triggerRadius, getBodyPartScreenRadius(aimPart))
	if distance > triggerRadius then
		return false
	end

	return true, targetCharacter, aimPart
end

---Run a lightweight instant-kill pass after the round unlocks.
local function runInstantKillPass()
	if Galaxy.instantKillBusy then
		return
	end

	Galaxy.instantKillBusy = true
	Galaxy.lastInstantKillHits = 0

	localPlayer = playersService.LocalPlayer
	if not localPlayer or not localPlayer.Character then
		Galaxy.instantKillBusy = false
		return
	end

	local deadline = workspace:GetServerTimeNow() + Galaxy.instantKillPassDuration

	while Galaxy.instantKill and isRoundLive() and workspace:GetServerTimeNow() <= deadline do
		local enemies = getEnemyCharacters()
		if #enemies <= 0 then
			break
		end

		-- First try one direct packet pair per target. No Gun/Knife equip or animation.
		for _, enemy in ipairs(enemies) do
			if not Galaxy.instantKill then
				break
			end

			if isEnemyStillAlive(enemy) and reportEnemyInstantKill(enemy) then
				Galaxy.lastInstantKillHits += 1
			end
		end

		-- Let replicated deaths settle before the next lightweight sweep.
		-- No teleport fallback and no Tool equip/activation are used here.
		task.wait(Galaxy.instantKillSweepDelay)
	end

	Galaxy.nextInstantKillAt = workspace:GetServerTimeNow() + Galaxy.instantKillCooldown
	Galaxy.instantKillBusy = false
end

---Start a lightweight direct-hit pass after countdown unlock.
local function updateInstantKill()
	local roundLive = isRoundLive()

	if not roundLive then
		Galaxy.roundWasLive = false
	end

	if not Galaxy.instantKill or not roundLive then
		return
	end

	if Galaxy.instantKillBusy or workspace:GetServerTimeNow() < Galaxy.nextInstantKillAt then
		Galaxy.roundWasLive = roundLive
		return
	end

	localPlayer = playersService.LocalPlayer
	if not localPlayer or not localPlayer.Character then
		Galaxy.roundWasLive = roundLive
		return
	end

	local matchId = tostring(localPlayer:GetAttribute("MatchId"))
	local moveUnlockAt = tostring(localPlayer:GetAttribute("MoveUnlockAt"))
	local instantKillKey = matchId .. ":" .. moveUnlockAt
	local roundJustUnlocked = not Galaxy.roundWasLive
	Galaxy.roundWasLive = roundLive

	if roundJustUnlocked or Galaxy.lastInstantKillKey ~= instantKillKey then
		Galaxy.lastInstantKillKey = instantKillKey
		Galaxy.nextInstantKillAt = workspace:GetServerTimeNow() + Galaxy.instantKillCooldown
		task.spawn(runInstantKillPass)
		return
	end

	if #getEnemyCharacters() > 0 then
		Galaxy.nextInstantKillAt = workspace:GetServerTimeNow() + Galaxy.instantKillCooldown
		task.spawn(runInstantKillPass)
	end
end

---Track death source so the next round starts with that enemy.
local function updateDeathTracker()
	localPlayer = playersService.LocalPlayer
	local character = localPlayer and localPlayer.Character

	if not character or character == trackedCharacter then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid == trackedHumanoid then
		return
	end

	trackedCharacter = character
	trackedHumanoid = humanoid
	Galaxy.lastHealth = humanoid.Health
	Galaxy.lastDamageEnemyUserId = nil
	Galaxy.lastDamageMatchId = nil

	table.insert(
		Galaxy.connections,
		humanoid.HealthChanged:Connect(function(health)
			if Galaxy.lastHealth and health < Galaxy.lastHealth then
				updateLastDamageEnemy(humanoid)
			end

			Galaxy.lastHealth = health
		end)
	)

	table.insert(
		Galaxy.connections,
		humanoid.Died:Connect(function()
			updateLastDamageEnemy(humanoid)

			if
				Galaxy.instantKill
				and Galaxy.lastDamageEnemyUserId
				and Galaxy.lastDamageMatchId == localPlayer:GetAttribute("MatchId")
			then
				Galaxy.revengeTargetUserId = Galaxy.lastDamageEnemyUserId
				Galaxy.lastInstantKillKey = nil
				Galaxy.roundWasLive = false
				Galaxy.nextInstantKillAt = 0
			end
		end)
	)
end

---Aim and click when enabled.
local function updateCombat()
	updateCombatState()
	updateGuiMouseUnlock(Galaxy.guiOpen and Galaxy.inCombat)

	local targetCharacter, aimPart, distance = getClosestTarget()

	if Galaxy.aimbot and aimPart then
		local cameraPosition = currentCamera.CFrame.Position
		local targetCFrame = CFrame.new(cameraPosition, aimPart.Position)
		currentCamera.CFrame = currentCamera.CFrame:Lerp(targetCFrame, math.clamp(Galaxy.smoothing, 0.05, 1))
	end

	local triggerReady = os.clock() - Galaxy.lastTrigger >= Galaxy.triggerDelay
	local triggerHit = false
	local aimPartVisible = aimPart and isVisible(aimPart)
	local triggerTargetCharacter = targetCharacter
	local triggerHitPart = aimPart

	if Galaxy.triggerbot and not Galaxy.instantKill and triggerReady then
		if userInputService.TouchEnabled then
			local mobileHit, mobileCharacter, mobilePart = shouldMobileTrigger(targetCharacter, aimPart, distance)
			triggerHit = mobileHit
			triggerTargetCharacter = mobileCharacter or triggerTargetCharacter
			triggerHitPart = mobilePart or triggerHitPart
		else
			triggerHit = shouldTrigger()
		end
	end

	if
		Galaxy.triggerbot
		and not Galaxy.instantKill
		and triggerReady
		and (
			triggerHit
			or not userInputService.TouchEnabled
				and aimPartVisible
				and distance
				and distance <= Galaxy.triggerRadius
		)
	then
		Galaxy.lastTrigger = os.clock()
		firePrimaryWeapon(triggerTargetCharacter, triggerHitPart)
	end
end


-- Local-only FPS helper for Instant Kill. It hides first-person arms/tools instead of
-- destroying them, so weapon controllers keep working and visuals can be restored.
local instantKillHiddenParts = setmetatable({}, { __mode = "k" })

local function shouldHideInstantKillPart(part)
	local camera = workspace.CurrentCamera
	if camera and part:IsDescendantOf(camera) then
		-- Camera descendants are normally first-person arms/weapons/viewmodels.
		return true
	end

	local lowerName = string.lower(part.Name or "")
	if lowerName:find("hand") or lowerName:find("arm") then
		return true
	end

	if lowerName:find("knife") or lowerName:find("gun") or lowerName:find("revolver") or lowerName:find("pistol") then
		return true
	end

	return part:FindFirstAncestorOfClass("Tool") ~= nil
end

local function restoreInstantKillVisuals()
	for part, oldModifier in pairs(instantKillHiddenParts) do
		if part and part.Parent then
			pcall(function()
				part.LocalTransparencyModifier = oldModifier
			end)
		end
		instantKillHiddenParts[part] = nil
	end
end

Galaxy.restoreInstantKillVisuals = restoreInstantKillVisuals

local function updateInstantKillVisuals()
	if not Galaxy.instantKillHidePov then
		restoreInstantKillVisuals()
		return
	end

	local shouldHide = Galaxy.instantKill and Galaxy.inCombat
	if not shouldHide then
		restoreInstantKillVisuals()
		return
	end

	-- Throttle visual scanning so this helper does not become its own FPS cost.
	local now = os.clock()
	if now - Galaxy.lastInstantKillVisualUpdate < 0.20 then
		return
	end
	Galaxy.lastInstantKillVisualUpdate = now

	local roots = {}
	localPlayer = playersService.LocalPlayer
	if localPlayer and localPlayer.Character then
		table.insert(roots, localPlayer.Character)
	end
	if workspace.CurrentCamera then
		table.insert(roots, workspace.CurrentCamera)
	end

	for _, root in ipairs(roots) do
		for _, descendant in ipairs(root:GetDescendants()) do
			if descendant:IsA("BasePart") and shouldHideInstantKillPart(descendant) then
				if instantKillHiddenParts[descendant] == nil then
					instantKillHiddenParts[descendant] = descendant.LocalTransparencyModifier
				end
				descendant.LocalTransparencyModifier = 1
			end
		end
	end
end

---Return compact target diagnostics from inside this script.
---@return table
function Galaxy.scanTargets()
	local diagnostics = {
		charactersFolder = workspace:FindFirstChild("Characters") ~= nil,
		localPlayer = playersService.LocalPlayer and playersService.LocalPlayer.Name or nil,
		revengeTargetUserId = Galaxy.revengeTargetUserId,
		lastDamageEnemyUserId = Galaxy.lastDamageEnemyUserId,
		total = 0,
		valid = 0,
		samples = {},
	}

	local folder = workspace:FindFirstChild("Characters")
	if not folder then
		return diagnostics
	end

	for _, character in ipairs(folder:GetChildren()) do
		if not character:IsA("Model") then
			continue
		end

		diagnostics.total += 1

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local targetPlayer = playersService:FindFirstChild(character.Name)
		local valid = isValidTarget(character)

		if valid then
			diagnostics.valid += 1
		end

		if #diagnostics.samples < 8 then
			table.insert(diagnostics.samples, {
				name = character.Name,
				player = targetPlayer ~= nil,
				self = playersService.LocalPlayer and character.Name == playersService.LocalPlayer.Name or false,
				humanoid = humanoid ~= nil,
				rootPart = rootPart ~= nil,
				health = humanoid and humanoid.Health or nil,
				valid = valid,
			})
		end
	end

	return diagnostics
end

---Initialize singleton state and runtime loops.
function Galaxy.init()
	if shared.PotentMurderDuels then
		shared.PotentMurderDuels.detach()
		shared.PotentMurderDuels = nil
	end

	if shared.GalaxyMurderDuels then
		shared.GalaxyMurderDuels.detach()
	end

	-- Remove an orphaned GUI left by an older execution before Rayfield starts.
	local parent = gethui and gethui() or coreGuiService
	local oldGui = parent:FindFirstChild(GUI_NAME)
	if oldGui then
		oldGui:Destroy()
	end

	shared.GalaxyMurderDuels = Galaxy
	createRayfieldGui()

	runService:BindToRenderStep(RENDER_STEP_NAME, Enum.RenderPriority.Last.Value, function()
		local ok, error = pcall(function()
			Galaxy.frameCount += 1
			updateDeathTracker()
			updateInstantKill()
			updateCombat()
			updateInstantKillVisuals()
			updateFovCircle()
			updateEsp()
		end)

		if not ok then
			Galaxy.lastError = tostring(error)
			warn("Galaxy frame error: " .. tostring(error))
		end
	end)
end

---This is called when initialization errors.
---@param error string
local function onInitializeError(error)
	warn("Failed to initialize Galaxy.")
	warn(error)
	warn(debug.traceback())
	Galaxy.detach()
end

-- Safely initialize the script and clean up failures.
xpcall(Galaxy.init, onInitializeError)
