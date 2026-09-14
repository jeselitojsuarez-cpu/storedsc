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
	connections = {},
	screenGui = nil,
	window = nil,
}

-- Constants.
local GUI_NAME = "GalaxyMurderDuels"
local COMBAT_RENDER_STEP = "GalaxySniperArenaCombat"
local GUI_MOUSE_RENDER_STEP = "GalaxySniperArenaMouseUnlock"
local FREE_FOR_ALL_TEAM = "Team3"
local OFF_COLOR = Color3.fromRGB(75, 85, 99)
local DANGER_COLOR = Color3.fromRGB(248, 113, 113)
local ACCENT_COLOR = Color3.fromRGB(85, 180, 255)
local BACKGROUND_COLOR = Color3.fromRGB(10, 12, 17)
local PANEL_COLOR = Color3.fromRGB(18, 21, 29)
local SURFACE_COLOR = Color3.fromRGB(28, 33, 44)
local MUTED_COLOR = Color3.fromRGB(128, 139, 160)
local TEXT_COLOR = Color3.fromRGB(235, 240, 255)

-- Services.
local userInputService = game:GetService("UserInputService")
local coreGuiService = game:GetService("CoreGui")
local starterGuiService = game:GetService("StarterGui")

local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local lightingService = game:GetService("Lighting")
local virtualUserService = game:GetService("VirtualUser")
local teleportService = game:GetService("TeleportService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local guiService = game:GetService("GuiService")
local virtualInputManagerService = game:GetService("VirtualInputManager")


-- State.
local localPlayer = playersService.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera

local State = {
	open = true,
	activeTab = "Combat",
	noclip = false,
	infiniteJump = false,
	aimbot = false,
	triggerbot = false,
	fovCircle = true,
	aimPart = "Head",
	fovRadius = 360,
	smoothing = 1,
	triggerRadius = 24,
	triggerDelay = 0.045,
	triggerRange = 1200,
	triggerBodyScale = 1.35,
	lastTrigger = 0,
	inCombat = false,
	targetCount = 0,
	statusWarningShown = false,
	fullbright = false,
	esp = false,
	antiAfk = false,
	selectedPlayer = nil,
	originalLighting = {},
	connections = Galaxy.connections,
	espObjects = {},
	fovDrawing = nil,
	renderStepBound = false,
	mouseRenderStepBound = false,
	combatController = nil,
	combatControllerChecked = false,
	gameService = nil,
	gameServiceChecked = false,
	entityService = nil,
	entityServiceChecked = false,
	entityModule = nil,
	entityModuleChecked = false,
	gameClientModule = nil,
	gameClientModuleChecked = false,
	originalMouseBehavior = nil,
	originalMouseIconEnabled = nil,
	mouseUnlocked = false,
}


State.detached = false
State.originalCollision = {}
State.originalCameraFov = {}

local dragging = false
local dragStart = nil
local frameStart = nil

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

---Label each page so the active category remains clear while scrolling.
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

---Get character.
local function getCharacter()
	return localPlayer.Character
end

---Get humanoid.
local function getHumanoid()
	local character = getCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end

---Get root.
local function getRoot(character)
	character = character or getCharacter()
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("UpperTorso")
end

---Apply fullbright.
local function applyFullbright(enabled)
	if enabled then
		if not rawget(State.originalLighting, "saved") then
			State.originalLighting = {
				saved = true,
				Brightness = lightingService.Brightness,
				ClockTime = lightingService.ClockTime,
				FogEnd = lightingService.FogEnd,
				GlobalShadows = lightingService.GlobalShadows,
				Ambient = lightingService.Ambient,
				OutdoorAmbient = lightingService.OutdoorAmbient,
			}
		end

		lightingService.Brightness = 2.5
		lightingService.ClockTime = 14
		lightingService.FogEnd = 100000
		lightingService.GlobalShadows = false
		lightingService.Ambient = Color3.fromRGB(255, 255, 255)
		lightingService.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	elseif rawget(State.originalLighting, "saved") then
		for key, value in pairs(State.originalLighting) do
			if key ~= "saved" then
				pcall(function()
					lightingService[key] = value
				end)
			end
		end
	end
end

local BodyPartNames = {
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

local TriggerPartNames = {
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
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
}

---Get aim screen position.
local function getAimScreenPosition()
	currentCamera = workspace.CurrentCamera

	if not currentCamera then
		local mousePosition = userInputService:GetMouseLocation()
		return Vector2.new(mousePosition.X, mousePosition.Y)
	end

	local cameraCenter = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)

	if userInputService.TouchEnabled then
		local cursorGui = playerGui:FindFirstChild("Cursor")
		local viewportHeight = cursorGui and cursorGui.AbsoluteSize.Y or currentCamera.ViewportSize.Y
		return Vector2.new(currentCamera.ViewportSize.X / 2, viewportHeight / 2)
	end

	if userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or not userInputService.MouseIconEnabled then
		return cameraCenter
	end

	if playerGui:FindFirstChild("Cursor") then
		return cameraCenter
	end

	local mousePosition = userInputService:GetMouseLocation()
	return Vector2.new(mousePosition.X, mousePosition.Y)
end

---Get fire screen position.
local function getFireScreenPosition()
	local screenPosition = getAimScreenPosition()
	local inset = guiService:GetGuiInset()
	return screenPosition + Vector2.new(inset.X, inset.Y)
end

local getFocusedEnemyCharacters

---Add character.
local function addCharacter(characters, seen, character)
	if not character or seen[character] or not character:IsA("Model") then
		return
	end

	if not character:FindFirstChildOfClass("Humanoid") or not getRoot(character) then
		return
	end

	table.insert(characters, character)
	seen[character] = true
end

---Is enemy highlight folder.
local function isEnemyHighlightFolder(folder)
	return folder and folder.Name:sub(1, 5) == "Enemy"
end

---Get characters.
local function getCharacters()
	local characters = {}
	local seen = {}
	local charactersFolder = workspace:FindFirstChild("Characters")

	if getFocusedEnemyCharacters then
		for _, character in ipairs(getFocusedEnemyCharacters()) do
			addCharacter(characters, seen, character)
		end
	end

	local highlightFolder = workspace:FindFirstChild("Highlight")
	if highlightFolder then
		for _, folder in ipairs(highlightFolder:GetChildren()) do
			if not isEnemyHighlightFolder(folder) then
				continue
			end

			local highlightHolder = folder:FindFirstChild("HighlightHolder")
			if not highlightHolder then
				continue
			end

			for _, character in ipairs(highlightHolder:GetChildren()) do
				addCharacter(characters, seen, character)
			end
		end
	end

	if charactersFolder then
		for _, character in ipairs(charactersFolder:GetChildren()) do
			addCharacter(characters, seen, character)
		end
	end

	for _, player in ipairs(playersService:GetPlayers()) do
		addCharacter(characters, seen, player.Character)
		addCharacter(characters, seen, workspace:FindFirstChild(player.Name))
	end

	return characters
end

---Is highlighted enemy character.
local function isHighlightedEnemyCharacter(character)
	local parent = character and character.Parent
	if not parent or parent.Name ~= "HighlightHolder" then
		return false
	end

	return isEnemyHighlightFolder(parent.Parent)
end

---Get player health.
local function getPlayerHealth(player, character)
	-- Replicated entity health takes precedence over a lingering display humanoid.
	local healthAttribute = player and tonumber(player:GetAttribute("Health"))
	if healthAttribute ~= nil then
		return healthAttribute
	end

	local characterHealth = character and tonumber(character:GetAttribute("Health"))
	if characterHealth ~= nil then
		return characterHealth
	end

	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health or 0
end

---Restore the caller's identity even when a game module fails to load.
local function withGameIdentity(callback)
	local originalIdentity = nil

	if getthreadidentity then
		pcall(function()
			originalIdentity = getthreadidentity()
		end)
	end

	if setthreadidentity then
		pcall(setthreadidentity, 2)
	end

	local success, result = pcall(callback)

	if setthreadidentity then
		pcall(setthreadidentity, originalIdentity or 8)
	end

	if success then
		return result
	end

	return nil
end

---Get game service.
local function getGameService()
	if State.gameServiceChecked then
		return State.gameService
	end

	State.gameServiceChecked = true
	State.gameService = withGameIdentity(function()
		local remoteFolder = replicatedStorage:FindFirstChild("Remote")
		local gameServiceModule = remoteFolder and remoteFolder:FindFirstChild("GameService")
		if not gameServiceModule or not gameServiceModule:IsA("ModuleScript") then
			return nil
		end

		---@module Remote.GameService
		return require(gameServiceModule)
	end)

	return State.gameService
end

---Get entity service.
local function getEntityService()
	if State.entityServiceChecked then
		return State.entityService
	end

	State.entityServiceChecked = true
	State.entityService = withGameIdentity(function()
		local remoteFolder = replicatedStorage:FindFirstChild("Remote")
		local entityServiceModule = remoteFolder and remoteFolder:FindFirstChild("EntityService")
		if not entityServiceModule or not entityServiceModule:IsA("ModuleScript") then
			return nil
		end

		---@module Remote.EntityService
		return require(entityServiceModule)
	end)

	return State.entityService
end

---Get entity module.
local function getEntityModule()
	if State.entityModuleChecked then
		return State.entityModule
	end

	State.entityModuleChecked = true
	State.entityModule = withGameIdentity(function()
		local remoteFolder = replicatedStorage:FindFirstChild("Remote")
		local entityServiceFolder = remoteFolder and remoteFolder:FindFirstChild("EntityService")
		local entityModule = entityServiceFolder and entityServiceFolder:FindFirstChild("Entity")
		if not entityModule or not entityModule:IsA("ModuleScript") then
			return nil
		end

		---@module Remote.EntityService.Entity
		return require(entityModule)
	end)

	return State.entityModule
end

---Get game client module.
local function getGameClientModule()
	if State.gameClientModuleChecked then
		return State.gameClientModule
	end

	State.gameClientModuleChecked = true
	State.gameClientModule = withGameIdentity(function()
		local remoteFolder = replicatedStorage:FindFirstChild("Remote")
		local gameServiceFolder = remoteFolder and remoteFolder:FindFirstChild("GameService")
		local gameClientModule = gameServiceFolder and gameServiceFolder:FindFirstChild("GameClient")
		if not gameClientModule or not gameClientModule:IsA("ModuleScript") then
			return nil
		end

		---@module Remote.GameService.GameClient
		return require(gameClientModule)
	end)

	return State.gameClientModule
end

---Get player entity.
local function getPlayerEntity(player)
	local entityModule = getEntityModule()
	if typeof(entityModule) == "table" and typeof(entityModule.Get) == "function" then
		local success, entity = pcall(entityModule.Get, player)
		if success and typeof(entity) == "table" then
			return entity
		end
	end

	local entityService = getEntityService()
	if player == localPlayer and typeof(entityService) == "table" then
		return entityService.LocalEntity
	end

	return nil
end

getFocusedEnemyCharacters = function()
	local characters = {}
	local gameService = getGameService()

	if typeof(gameService) ~= "table" or typeof(gameService.RoomManager) ~= "table" then
		return characters
	end

	local room = nil
	if typeof(gameService.RoomManager.GetFocusedRoom) == "function" then
		local success, focusedRoom = pcall(gameService.RoomManager.GetFocusedRoom)
		if success then
			room = focusedRoom
		end
	end

	local modeHandler = room and room.ModeHandler
	if typeof(room) ~= "table" or typeof(modeHandler) ~= "table" or typeof(modeHandler.GetEnemyTeams) ~= "function" then
		return characters
	end

	local success, enemyTeams = pcall(modeHandler.GetEnemyTeams, modeHandler)
	if not success or typeof(enemyTeams) ~= "table" then
		return characters
	end

	for _, team in ipairs(enemyTeams) do
		local clients = room.ClientsByTeam and room.ClientsByTeam[team]
		if typeof(clients) ~= "table" then
			continue
		end

		local clientItems = rawget(clients, "_items") or clients

		for key, value in pairs(clientItems) do
			local client = if typeof(value) == "table" then value else key
			if typeof(client) ~= "table" or client.Instance == localPlayer then
				continue
			end

			local entity = nil
			if typeof(client.GetEntity) == "function" then
				local entitySuccess, clientEntity = pcall(client.GetEntity, client)
				if entitySuccess then
					entity = clientEntity
				end
			end

			if typeof(entity) ~= "table" then
				continue
			end

			if typeof(entity.IsAlive) == "function" then
				local aliveSuccess, alive = pcall(entity.IsAlive, entity)
				if aliveSuccess and not alive then
					continue
				end
			end

			local root = nil
			if typeof(entity.GetWorkspaceRoot) == "function" then
				local rootSuccess, workspaceRoot = pcall(entity.GetWorkspaceRoot, entity)
				if rootSuccess then
					root = workspaceRoot
				end
			end

			if root and root:IsA("Model") then
				table.insert(characters, root)
			end
		end
	end

	return characters
end

---Get player game client.
local function getPlayerGameClient(player)
	local gameClientModule = getGameClientModule()
	if typeof(gameClientModule) == "table" and typeof(gameClientModule.Get) == "function" then
		local success, client = pcall(gameClientModule.Get, player)
		if success and typeof(client) == "table" then
			return client
		end
	end

	return nil
end

---Is friendly target.
local function isFriendlyTarget(targetPlayer)
	local gameService = getGameService()
	local localClient = typeof(gameService) == "table" and gameService.LocalGameClient or nil
	local targetClient = getPlayerGameClient(targetPlayer)

	if typeof(localClient) == "table" and typeof(targetClient) == "table" and typeof(localClient.IsFriendly) == "function" then
		local success, friendly = pcall(localClient.IsFriendly, localClient, targetClient)
		if success and friendly ~= nil then
			return friendly
		end
	end

	local localEntity = getPlayerEntity(localPlayer)
	local targetEntity = getPlayerEntity(targetPlayer)
	if typeof(localEntity) == "table" and typeof(targetEntity) == "table" and typeof(localEntity.IsFriendly) == "function" then
		local success, friendly = pcall(localEntity.IsFriendly, localEntity, targetEntity)
		if success and friendly ~= nil then
			return friendly
		end
	end

	return nil
end

---Get entity team.
local function getEntityTeam(player)
	local entity = getPlayerEntity(player)

	if typeof(entity) ~= "table" then
		return nil
	end

	if typeof(entity.GetTeam) == "function" then
		local success, team = pcall(entity.GetTeam, entity)
		if success and team ~= nil then
			return tostring(team)
		end
	end

	local team = rawget(entity, "Team")
	if team ~= nil then
		return tostring(team)
	end

	return nil
end

---Get player team.
local function getPlayerTeam(player, character)
	if not player then
		return nil
	end

	local attributeTeam = player:GetAttribute("MatchSide") or player:GetAttribute("Team")
	if attributeTeam ~= nil then
		return tostring(attributeTeam)
	end

	local characterTeam = character and (character:GetAttribute("MatchSide") or character:GetAttribute("Team"))
	if characterTeam ~= nil then
		return tostring(characterTeam)
	end

	if player.Team then
		return player.Team.Name
	end

	return getEntityTeam(player)
end

---Is team round.
local function isTeamRound()
	local localTeam = getPlayerTeam(localPlayer, localPlayer.Character or workspace:FindFirstChild(localPlayer.Name))
	if localTeam == FREE_FOR_ALL_TEAM then
		return false
	end

	for _, player in ipairs(playersService:GetPlayers()) do
		local team = player:GetAttribute("Team") or player:GetAttribute("MatchSide")
		if team ~= nil and tostring(team) ~= FREE_FOR_ALL_TEAM then
			return true
		end
	end

	return localTeam ~= nil
end

---Is same round.
local function isSameRound(targetPlayer)
	local localClient = getPlayerGameClient(localPlayer)
	local targetClient = getPlayerGameClient(targetPlayer)

	if typeof(localClient) == "table" and typeof(targetClient) == "table" and localClient.Room and targetClient.Room then
		return localClient.Room == targetClient.Room
	end

	local localRoom = localPlayer:GetAttribute("GameRoom") or localPlayer:GetAttribute("MatchId") or localPlayer:GetAttribute("World")
	local targetRoom = targetPlayer:GetAttribute("GameRoom") or targetPlayer:GetAttribute("MatchId") or targetPlayer:GetAttribute("World")

	if localRoom and targetRoom and localRoom ~= targetRoom then
		return false
	end

	return true
end

---Is round live.
local function isRoundLive()
	if not localPlayer then
		return false
	end

	local character = localPlayer.Character or workspace:FindFirstChild(localPlayer.Name)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if character and humanoid and humanoid.Health <= 0 then
		return false
	end

	local localEntity = getPlayerEntity(localPlayer)
	local entityAlive = nil
	if typeof(localEntity) == "table" and typeof(localEntity.IsAlive) == "function" then
		local aliveSuccess, alive = pcall(localEntity.IsAlive, localEntity)
		if aliveSuccess then
			entityAlive = alive
		end
	end

	local health = getPlayerHealth(localPlayer, character)
	if entityAlive == false then
		return false
	end

	if health <= 0 and entityAlive ~= true then
		return false
	end

	if localPlayer:GetAttribute("combatPaused") == true and entityAlive ~= true then
		return false
	end

	local alive = localPlayer:GetAttribute("Alive")
	if alive ~= nil and alive ~= true then
		return false
	end

	local inMatch = localPlayer:GetAttribute("InMatch")
	if inMatch ~= nil and inMatch ~= true then
		return false
	end

	local moveUnlockAt = tonumber(localPlayer:GetAttribute("MoveUnlockAt")) or 0
	if moveUnlockAt <= 0 then
		return true
	end

	return workspace:GetServerTimeNow() >= moveUnlockAt
end

---Is valid target.
local function isValidTarget(character)
	if not character or not character:IsA("Model") or not character:IsDescendantOf(workspace) or character.Name == localPlayer.Name then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then
		return false
	end

	local targetPlayer = playersService:FindFirstChild(character.Name)
	-- Highlights alone cannot establish that an enemy is still alive.
	if not targetPlayer then
		return false
	end

	local targetEntity = getPlayerEntity(targetPlayer)
	local entityAlive = nil
	if typeof(targetEntity) == "table" and typeof(targetEntity.IsAlive) == "function" then
		local aliveSuccess, alive = pcall(targetEntity.IsAlive, targetEntity)
		if not aliveSuccess or alive ~= true then
			return false
		end
		entityAlive = true
	end

	State.inCombat = isRoundLive()
	if not State.inCombat then
		return false
	end

	if not isSameRound(targetPlayer) then
		return false
	end

	-- Death and match eligibility must be checked before any enemy shortcut.
	local targetHealth = getPlayerHealth(targetPlayer, character)
	if targetHealth <= 0 then
		return false
	end

	if typeof(targetEntity) == "table" then
		local entityHealth = tonumber(targetEntity.Health)
		if entityHealth and entityHealth <= 0 then
			return false
		end
	end

	if targetPlayer:GetAttribute("combatPaused") == true and entityAlive ~= true then
		return false
	end

	local targetInMatch = targetPlayer:GetAttribute("InMatch")
	local targetAlive = targetPlayer:GetAttribute("Alive")

	if targetInMatch ~= nil and targetInMatch ~= true then
		return false
	end

	if targetAlive ~= nil and targetAlive ~= true then
		return false
	end

	local friendly = isFriendlyTarget(targetPlayer)
	if friendly == true then
		return false
	elseif friendly == false or isHighlightedEnemyCharacter(character) then
		return true
	end

	if isTeamRound() then
		local localSide = getPlayerTeam(localPlayer, localPlayer.Character or workspace:FindFirstChild(localPlayer.Name))
		local targetSide = getPlayerTeam(targetPlayer, character)

		if not localSide or not targetSide then
			return false
		end

		if localSide ~= FREE_FOR_ALL_TEAM and localSide == targetSide then
			return false
		end
	end

	return true
end

---Get raycast params.
local function getRaycastParams(extra)
	local ignoreList = {}

	if localPlayer.Character then
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

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignoreList
	return params
end

---Should ignore ray hit.
local function shouldIgnoreRayHit(instance)
	if not instance then
		return false
	end

	if localPlayer.Character and instance:IsDescendantOf(localPlayer.Character) then
		return true
	end

	if currentCamera and instance:IsDescendantOf(currentCamera) then
		return true
	end

	local tempFolder = workspace:FindFirstChild("_Temp")
	if tempFolder and instance:IsDescendantOf(tempFolder) then
		return true
	end

	if instance:IsA("BasePart") and instance.Transparency >= 0.95 then
		return true
	end

	return false
end

---Get character from instance.
local function getCharacterFromInstance(instance)
	while instance and instance ~= workspace do
		if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") then
			return instance
		end

		instance = instance.Parent
	end

	return nil
end

---Is enemy ray hit.
local function isEnemyRayHit(instance, targetCharacter)
	if not instance or not targetCharacter then
		return false
	end

	if instance:IsDescendantOf(targetCharacter) then
		return isValidTarget(targetCharacter)
	end

	local hitCharacter = getCharacterFromInstance(instance)
	if not hitCharacter then
		return false
	end

	-- A corpse or stale highlight must not count as a live enemy ray hit.
	return isValidTarget(hitCharacter)
end

---Is visible.
local function isVisible(part, targetCharacter)
	currentCamera = workspace.CurrentCamera
	if not currentCamera or not part or not part:IsA("BasePart") then
		return false
	end

	targetCharacter = targetCharacter or part.Parent

	local origin = currentCamera.CFrame.Position
	local direction = part.Position - origin
	local ignored = {}

	for _ = 1, 8 do
		local result = workspace:Raycast(origin, direction, getRaycastParams(ignored))
		if not result then
			return true
		end

		if isEnemyRayHit(result.Instance, targetCharacter) then
			return true
		end

		if not shouldIgnoreRayHit(result.Instance) then
			return false
		end

		table.insert(ignored, result.Instance)
	end

	return false
end

---Get aim part.
local function getAimPart(character)
	local preferred = {
		State.aimPart,
		"Head",
		"UpperTorso",
		"Torso",
		"HumanoidRootPart",
	}

	for _, partName in ipairs(preferred) do
		local part = character:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

---Get closest trigger part.
local function getClosestTriggerPart(character, screenPosition)
	local closestPart = nil
	local closestDistance = math.huge

	for _, partName in ipairs(TriggerPartNames) do
		local part = character:FindFirstChild(partName)
		if not part or not part:IsA("BasePart") or not isVisible(part, character) then
			continue
		end

		local viewportPosition, onScreen = currentCamera:WorldToViewportPoint(part.Position)
		if not onScreen then
			continue
		end

		local distance = (Vector2.new(viewportPosition.X, viewportPosition.Y) - screenPosition).Magnitude
		if distance < closestDistance then
			closestPart = part
			closestDistance = distance
		end
	end

	return closestPart, closestDistance
end

---Get visible aim part.
local function getVisibleAimPart(character, screenPosition)
	local aimPart = getAimPart(character)
	if aimPart and isVisible(aimPart, character) then
		return aimPart
	end

	local fallbackPart = getClosestTriggerPart(character, screenPosition)
	if fallbackPart then
		return fallbackPart
	end

	return nil
end

---Get body part screen radius.
local function getBodyPartScreenRadius(part)
	if not currentCamera then
		return State.triggerRadius
	end

	local center = currentCamera:WorldToViewportPoint(part.Position)
	local right = currentCamera.CFrame.RightVector * part.Size.X * 0.5
	local up = currentCamera.CFrame.UpVector * part.Size.Y * 0.5
	local rightPoint = currentCamera:WorldToViewportPoint(part.Position + right)
	local upPoint = currentCamera:WorldToViewportPoint(part.Position + up)
	local rightDistance = (Vector2.new(center.X, center.Y) - Vector2.new(rightPoint.X, rightPoint.Y)).Magnitude
	local upDistance = (Vector2.new(center.X, center.Y) - Vector2.new(upPoint.X, upPoint.Y)).Magnitude

	return math.clamp(math.max(rightDistance, upDistance) * State.triggerBodyScale, 8, 48)
end

---Is mouse over body part.
local function isMouseOverBodyPart(character, mousePos)
	for _, partName in ipairs(TriggerPartNames) do
		local part = character:FindFirstChild(partName)
		if not part or not part:IsA("BasePart") or not isVisible(part, character) then
			continue
		end

		local screenPosition, onScreen = currentCamera:WorldToViewportPoint(part.Position)
		if not onScreen then
			continue
		end

		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude
		if distance <= getBodyPartScreenRadius(part) then
			return true, part
		end
	end

	return false
end

---Get mouse ray target.
local function getMouseRayTarget(mousePos)
	currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return false
	end

	local ray = currentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * State.triggerRange, getRaycastParams())
	if not result then
		return false
	end

	local hitCharacter = getCharacterFromInstance(result.Instance)
	if hitCharacter and isValidTarget(hitCharacter) then
		local hitPart = result.Instance
		if hitPart:IsA("BasePart") and hitPart:IsDescendantOf(hitCharacter) and BodyPartNames[hitPart.Name] then
			return true, hitCharacter, hitPart
		end

		return true, hitCharacter
	end

	return false
end

---Choose the nearest visible enemy inside the configured cursor FOV.
local function getClosestTarget()
	currentCamera = workspace.CurrentCamera
	State.inCombat = isRoundLive()
	State.targetCount = 0

	if not currentCamera then
		return nil
	end

	local mousePos = getAimScreenPosition()
	local closestCharacter = nil
	local closestPart = nil
	local closestDistance = math.huge

	for _, character in ipairs(getCharacters()) do
		if not isValidTarget(character) then
			continue
		end

		State.targetCount += 1

		local aimPart = getVisibleAimPart(character, mousePos)
		if not aimPart then
			continue
		end

		local screenPosition, onScreen = currentCamera:WorldToViewportPoint(aimPart.Position)
		if not onScreen then
			continue
		end

		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude
		if distance > State.fovRadius or distance >= closestDistance then
			continue
		end

		closestCharacter = character
		closestPart = aimPart
		closestDistance = distance
	end

	return closestCharacter, closestPart, closestDistance
end

---Get equipped tool.
local function getEquippedTool()
	local character = localPlayer.Character
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

---Equip combat tool.
local function equipCombatTool()
	local equippedTool = getEquippedTool()
	if equippedTool and equippedTool.Name ~= "Knife" then
		return equippedTool
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	if not humanoid or not backpack then
		return equippedTool
	end

	for _, toolName in ipairs({ "Revolver", "Gun", "Pistol" }) do
		local tool = backpack:FindFirstChild(toolName)
		if tool and tool:IsA("Tool") then
			humanoid:EquipTool(tool)
			task.wait()
			return getEquippedTool() or tool
		end
	end

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.Name ~= "Knife" then
			humanoid:EquipTool(tool)
			task.wait()
			return getEquippedTool() or tool
		end
	end

	return equippedTool
end

---Activate tool.
local function activateTool(tool)
	if not tool then
		return
	end

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
	end)
end

---Send virtual mouse click.
local function sendVirtualMouseClick()
	local screenPosition = getFireScreenPosition()
	pcall(function()
		virtualInputManagerService:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, true, game, 0)
	end)

	task.delay(0.018, function()
		pcall(function()
			virtualInputManagerService:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, false, game, 0)
		end)
	end)
end

---Click primary input.
local function clickPrimaryInput()
	if mouse1click then
		pcall(mouse1click)
	elseif mouse1press and mouse1release then
		pcall(mouse1press)
		task.delay(0.018, function()
			pcall(mouse1release)
		end)
	end

	sendVirtualMouseClick()
end

---Get combat controller.
local function getCombatController()
	if State.combatControllerChecked then
		return State.combatController
	end

	State.combatControllerChecked = true
	State.combatController = withGameIdentity(function()
		local clientFolder = replicatedStorage:FindFirstChild("Client")
		local combatController = clientFolder and clientFolder:FindFirstChild("CombatController")
		if not combatController or not combatController:IsA("ModuleScript") then
			return nil
		end

		---@module ReplicatedStorage.Client.CombatController
		return require(combatController)
	end)

	return State.combatController
end

---Fire game primary action.
local function fireGamePrimaryAction()
	local combatController = getCombatController()
	if typeof(combatController) ~= "table" then
		return false
	end

	if typeof(combatController.IsPaused) == "function" then
		local pausedSuccess, paused = pcall(combatController.IsPaused)
		if pausedSuccess and paused then
			return false
		end
	end

	local primaryAction = combatController.PrimaryAction
	if typeof(primaryAction) ~= "table" or typeof(primaryAction.Begin) ~= "function" then
		return false
	end

	local beginSuccess, beginResult = pcall(primaryAction.Begin, "acracyTrigger")
	if not beginSuccess or beginResult == false then
		return false
	end

	task.delay(0.025, function()
		if typeof(primaryAction.End) == "function" then
			pcall(primaryAction.End, "acracyTrigger")
		end
	end)

	return true
end

---Report gun hit.
local function reportGunHit(targetCharacter, hitPart)
	-- Recheck before sending a hit after another action may have yielded.
	if not isValidTarget(targetCharacter) then
		return
	end

	local remotesFolder = replicatedStorage:FindFirstChild("Remotes")
	local reportHitRemote = remotesFolder and remotesFolder:FindFirstChild("ReportHit")
	local targetPlayer = targetCharacter and playersService:FindFirstChild(targetCharacter.Name)

	if not reportHitRemote or not targetPlayer or not hitPart then
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

---Fire primary weapon.
local function firePrimaryWeapon(targetCharacter, hitPart)
	-- Target state can change between selection and weapon activation.
	if not isValidTarget(targetCharacter) then
		return
	end

	if not fireGamePrimaryAction() then
		local tool = equipCombatTool()
		if not isValidTarget(targetCharacter) then
			return
		end
		clickPrimaryInput()
		activateTool(tool)
	end

	if userInputService.TouchEnabled then
		reportGunHit(targetCharacter, hitPart)
	end
end

---Should trigger.
local function shouldTrigger()
	currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return false
	end

	local mousePos = getAimScreenPosition()
	local rayHit, rayCharacter, rayPart = getMouseRayTarget(mousePos)
	if rayHit then
		return true, rayCharacter, rayPart
	end

	for _, character in ipairs(getCharacters()) do
		if not isValidTarget(character) then
			continue
		end

		local overBody, part = isMouseOverBodyPart(character, mousePos)
		if overBody then
			return true, character, part
		end
	end

	return false
end

---Should mobile trigger.
local function shouldMobileTrigger(targetCharacter, aimPart, distance)
	currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return false
	end

	local screenPosition = getAimScreenPosition()
	local rayHit, rayCharacter, rayPart = getMouseRayTarget(screenPosition)

	if rayHit and rayCharacter then
		if rayPart and isVisible(rayPart, rayCharacter) then
			return true, rayCharacter, rayPart
		end

		local closestPart = getClosestTriggerPart(rayCharacter, screenPosition)
		return closestPart ~= nil, rayCharacter, closestPart
	end

	local closestCharacter = nil
	local closestPart = nil
	local closestDistance = math.huge

	for _, character in ipairs(getCharacters()) do
		if not isValidTarget(character) then
			continue
		end

		local part, partDistance = getClosestTriggerPart(character, screenPosition)
		local triggerRadius = part and math.max(State.triggerRadius, getBodyPartScreenRadius(part)) or State.triggerRadius
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

	if not isValidTarget(targetCharacter) or not aimPart or not distance or not isVisible(aimPart, targetCharacter) then
		return false
	end

	local triggerRadius = math.max(State.triggerRadius, getBodyPartScreenRadius(aimPart))
	if distance > triggerRadius then
		return false
	end

	return true, targetCharacter, aimPart
end

---Update fov circle.
local function updateFovCircle()
	if not Drawing or not workspace.CurrentCamera then
		return
	end

	if not State.fovDrawing then
		local circle = Drawing.new("Circle")
		circle.Visible = false
		circle.Filled = false
		circle.NumSides = 96
		circle.Color = ACCENT_COLOR
		circle.Thickness = 1.5
		circle.Transparency = 0.85
		State.fovDrawing = circle
	end

	State.fovDrawing.Position = getAimScreenPosition()
	State.fovDrawing.Radius = State.fovRadius
	State.fovDrawing.Visible = State.fovCircle and (State.aimbot or State.triggerbot)
end

---Unlock mouse for gui.
local function unlockMouseForGui()
	if userInputService.TouchEnabled then
		return
	end

	if not State.mouseUnlocked then
		State.originalMouseBehavior = userInputService.MouseBehavior
		State.originalMouseIconEnabled = userInputService.MouseIconEnabled
		State.mouseUnlocked = true
	end

	pcall(function()
		userInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	pcall(function()
		userInputService.MouseIconEnabled = true
	end)
end

---Restore mouse for game.
local function restoreMouseForGame()
	if userInputService.TouchEnabled or not State.mouseUnlocked then
		return
	end

	pcall(function()
		userInputService.MouseBehavior = State.originalMouseBehavior or Enum.MouseBehavior.LockCenter
	end)

	if State.originalMouseIconEnabled ~= nil then
		pcall(function()
			userInputService.MouseIconEnabled = State.originalMouseIconEnabled
		end)
	end

	State.mouseUnlocked = false
end

---Keep aiming and firing active when enabled, matching the original arena script.
local function updateCombat()
	local targetCharacter, aimPart, distance = getClosestTarget()

	if State.aimbot and aimPart and isValidTarget(targetCharacter) then
		local cameraPosition = currentCamera.CFrame.Position
		local targetCFrame = CFrame.new(cameraPosition, aimPart.Position)
		currentCamera.CFrame = currentCamera.CFrame:Lerp(targetCFrame, math.clamp(State.smoothing, 0.05, 1))
	end

	local triggerReady = os.clock() - State.lastTrigger >= State.triggerDelay
	local triggerHit = false
	local triggerTargetCharacter = targetCharacter
	local triggerHitPart = aimPart

	if State.triggerbot and triggerReady then
		if userInputService.TouchEnabled then
			local mobileHit, mobileCharacter, mobilePart = shouldMobileTrigger(targetCharacter, aimPart, distance)
			triggerHit = mobileHit
			triggerTargetCharacter = mobileCharacter or triggerTargetCharacter
			triggerHitPart = mobilePart or triggerHitPart
		else
			local rayHit, rayCharacter, rayPart = shouldTrigger()
			triggerHit = rayHit
			triggerTargetCharacter = rayCharacter or triggerTargetCharacter
			triggerHitPart = rayPart or triggerHitPart
		end
	end

	if
		State.triggerbot
		and triggerReady
		and (
			triggerHit
			or not userInputService.TouchEnabled
				and aimPart
				and distance
				and distance <= State.triggerRadius
		)
	then
		State.lastTrigger = os.clock()
		firePrimaryWeapon(triggerTargetCharacter, triggerHitPart)
	end
end


---Build controls with shared styling and optional child decorations.
local function make(className, props, children)
	local inst = Instance.new(className)

	for key, value in pairs(props or {}) do
		inst[key] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end

	return inst
end


---Create card.
local function createCard(parent, titleText)
	local card = make("Frame", {
		BackgroundColor3 = PANEL_COLOR,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 58),
		Parent = parent,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		make("UIStroke", { Color = Color3.fromRGB(47, 58, 77), Thickness = 1 }),
	})

	make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = titleText,
		TextColor3 = TEXT_COLOR,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	return card
end

---Create toggle.
local function createToggle(parent, label, initial, callback)
	local card = createCard(parent, label)
	local status = make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -86, 0, 18),
		Text = initial and "Enabled" or "Disabled",
		TextColor3 = initial and ACCENT_COLOR or MUTED_COLOR,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local button = make("TextButton", {
		BackgroundColor3 = initial and ACCENT_COLOR or OFF_COLOR,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -64, 0, 16),
		Size = UDim2.fromOffset(48, 26),
		Text = initial and "ON" or "OFF",
		TextColor3 = initial and Color3.fromRGB(8, 16, 24) or TEXT_COLOR,
		TextSize = 11,
		Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 13) }),
	})

	local enabled = initial
	local function apply(value)
		enabled = value
		button.BackgroundColor3 = enabled and ACCENT_COLOR or OFF_COLOR
		button.Text = enabled and "ON" or "OFF"
		button.TextColor3 = enabled and Color3.fromRGB(8, 16, 24) or TEXT_COLOR
		status.Text = enabled and "Enabled" or "Disabled"
		status.TextColor3 = enabled and ACCENT_COLOR or MUTED_COLOR
		callback(enabled)
	end

	button.Activated:Connect(function()
		apply(not enabled)
	end)

	return function(value)
		apply(value)
	end
end

---Create button.
local function createButton(parent, label, subtext, callback, color)
	local card = createCard(parent, label)
	card.Size = UDim2.new(1, 0, 0, 62)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -112, 0, 28),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = subtext or "",
		TextColor3 = MUTED_COLOR,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local button = make("TextButton", {
		BackgroundColor3 = color or ACCENT_COLOR,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -92, 0, 17),
		Size = UDim2.fromOffset(76, 28),
		Text = "RUN",
		TextColor3 = Color3.fromRGB(8, 16, 24),
		TextSize = 12,
		Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	button.Activated:Connect(callback)
	return button
end

---Create slider.
local function createSlider(parent, label, min, max, initial, callback)
	local card = createCard(parent, label)
	card.Size = UDim2.new(1, 0, 0, 74)
	card:FindFirstChildOfClass("TextLabel").Size = UDim2.new(1, -90, 0, 18)

	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.new(1, -72, 0, 8),
		Size = UDim2.fromOffset(56, 18),
		Text = tostring(initial),
		TextColor3 = ACCENT_COLOR,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card,
	})

	local track = make("Frame", {
		BackgroundColor3 = OFF_COLOR,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 42),
		Size = UDim2.new(1, -24, 0, 8),
		Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 4) }),
	})

	local fill = make("Frame", {
		BackgroundColor3 = ACCENT_COLOR,
		BorderSizePixel = 0,
		Size = UDim2.fromScale((initial - min) / (max - min), 1),
		Parent = track,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 4) }),
	})

	track.Active = true
	local dragging = false

	local function setFromX(x)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + ((max - min) * alpha) + 0.5)
		fill.Size = UDim2.fromScale(alpha, 1)
		valueLabel.Text = tostring(value)
		callback(value)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)

	table.insert(State.connections, userInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	table.insert(State.connections, userInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end))
end

---Create dropdown.
local function createDropdown(parent, label, options, initial, callback)
	local card = createCard(parent, label)
	card.Size = UDim2.new(1, 0, 0, 74)

	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -118, 0, 22),
		Text = initial,
		TextColor3 = ACCENT_COLOR,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local button = make("TextButton", {
		BackgroundColor3 = SURFACE_COLOR,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -92, 0, 30),
		Size = UDim2.fromOffset(76, 28),
		Text = "NEXT",
		TextColor3 = TEXT_COLOR,
		TextSize = 12,
		Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	local index = 1
	for i, option in ipairs(options) do
		if option == initial then
			index = i
			break
		end
	end

	button.Activated:Connect(function()
		index = (index % #options) + 1
		valueLabel.Text = options[index]
		callback(options[index])
	end)
end

---Remove a player's previous highlight before replacing or unloading it.
local function clearEspFor(player)
	local bundle = State.espObjects[player]
	if not bundle then
		return
	end

	for _, inst in pairs(bundle) do
		pcall(function()
			inst:Destroy()
		end)
	end

	State.espObjects[player] = nil
end

---Attach one highlight to the player's current character.
local function createEspFor(player)
	if player == localPlayer then
		return
	end

	clearEspFor(player)

	local character = player.Character
	if State.detached or not State.esp or not character then
		return
	end

	local root = getRoot(character)
	if not root then
		return
	end

	local highlight = make("Highlight", {
		Name = "GalaxyHighlight",
		Adornee = character,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		FillColor = ACCENT_COLOR,
		FillTransparency = 0.82,
		OutlineColor = Color3.fromRGB(255, 255, 255),
		OutlineTransparency = 0.1,
		Parent = Galaxy.screenGui,
	})

	State.espObjects[player] = {
		highlight = highlight,
	}
end

---Refresh esp.
local function refreshEsp()
	for player in pairs(State.espObjects) do
		clearEspFor(player)
	end

	if not State.esp then
		return
	end

	for _, player in ipairs(playersService:GetPlayers()) do
		createEspFor(player)
	end
end

---Teleport to player.
local function teleportToPlayer(player)
	if not player or player.Parent ~= playersService or not player.Character then
		notify("Galaxy", "Selected player is not spawned.")
		return
	end

	local localRoot = getRoot()
	local targetRoot = getRoot(player.Character)
	if not localRoot or not targetRoot then
		notify("Galaxy", "Could not find target root.")
		return
	end

	localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
end

---Keep player selection available as players join and leave.
local function makePlayerDropdown(parent)
	local card = createCard(parent, "Selected Player")
	card.Size = UDim2.new(1, 0, 0, 98)

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -24, 0, 18),
		Text = "None",
		TextColor3 = MUTED_COLOR,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local prev = make("TextButton", {
		BackgroundColor3 = SURFACE_COLOR,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(12, 58),
		Size = UDim2.fromOffset(84, 28),
		Text = "PREV",
		TextColor3 = TEXT_COLOR,
		TextSize = 12,
		Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	local next = make("TextButton", {
		BackgroundColor3 = ACCENT_COLOR,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(104, 58),
		Size = UDim2.fromOffset(84, 28),
		Text = "NEXT",
		TextColor3 = Color3.fromRGB(8, 16, 24),
		TextSize = 12,
		Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	local function candidates()
		local list = {}
		for _, player in ipairs(playersService:GetPlayers()) do
			if player ~= localPlayer then
				table.insert(list, player)
			end
		end
		table.sort(list, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)
		return list
	end

	local index = 0

	local function selectOffset(offset)
		local list = candidates()
		if #list == 0 then
			State.selectedPlayer = nil
			index = 0
			label.Text = "No other players"
			label.TextColor3 = MUTED_COLOR
			return
		end

		index = ((index - 1 + offset) % #list) + 1
		State.selectedPlayer = list[index]
		label.Text = State.selectedPlayer.DisplayName .. "  @" .. State.selectedPlayer.Name
		label.TextColor3 = ACCENT_COLOR
	end

	prev.Activated:Connect(function()
		selectOffset(-1)
	end)

	next.Activated:Connect(function()
		selectOffset(1)
	end)

	table.insert(State.connections, playersService.PlayerAdded:Connect(function() selectOffset(0) end))
	table.insert(State.connections, playersService.PlayerRemoving:Connect(function()
		task.defer(function()
			if not State.detached then selectOffset(0) end
		end)
	end))
	selectOffset(1)
end



---Restore each part's collision setting when noclip ends.
local function restoreCollision()
	for part, canCollide in pairs(State.originalCollision) do
		pcall(function() part.CanCollide = canCollide end)
	end
	table.clear(State.originalCollision)
end

---Release every feature and GUI resource before another execution starts.
function Galaxy.detach()
	if State.detached then return end
	State.detached = true
	State.open = false
	State.esp = false
	State.noclip = false
	State.aimbot = false
	State.triggerbot = false
	for _, connection in ipairs(Galaxy.connections) do
		connection:Disconnect()
	end
	table.clear(Galaxy.connections)
	if State.renderStepBound then
		runService:UnbindFromRenderStep(COMBAT_RENDER_STEP)
		State.renderStepBound = false
	end
	if State.mouseRenderStepBound then
		runService:UnbindFromRenderStep(GUI_MOUSE_RENDER_STEP)
		State.mouseRenderStepBound = false
	end
	restoreCollision()
	applyFullbright(false)
	restoreMouseForGame()
	for camera, fieldOfView in pairs(State.originalCameraFov) do
		pcall(function() camera.FieldOfView = fieldOfView end)
	end
	table.clear(State.originalCameraFov)
	refreshEsp()
	if State.fovDrawing then
		pcall(function() State.fovDrawing:Remove() end)
		State.fovDrawing = nil
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
	if Galaxy.screenGui then
		Galaxy.screenGui:Destroy()
		Galaxy.screenGui = nil
	end
	if shared.GalaxyMurderDuels == Galaxy then shared.GalaxyMurderDuels = nil end
end

---Connect migrated features only after all controls exist.
local function startFeatures()
	table.insert(State.connections, runService.Stepped:Connect(function()
		if State.noclip then
			local character = localPlayer.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						if State.originalCollision[part] == nil then
							State.originalCollision[part] = part.CanCollide
						end
						part.CanCollide = false
					end
				end
			end
		end

		if State.fullbright then
			applyFullbright(true)
		end
	end))

	table.insert(State.connections, localPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)
		if not State.detached and State.esp then
			refreshEsp()
		end
	end))

	runService:BindToRenderStep(COMBAT_RENDER_STEP, Enum.RenderPriority.Camera.Value + 101, function()
		updateFovCircle()
		updateCombat()
	end)
	State.renderStepBound = true

	runService:BindToRenderStep(GUI_MOUSE_RENDER_STEP, 1000000, function()
		if State.open then
			unlockMouseForGui()
		end
	end)
	State.mouseRenderStepBound = true

	local function watchPlayer(player)
		if player == localPlayer then
			return
		end

		table.insert(State.connections, player.CharacterAdded:Connect(function()
			task.wait(0.5)
			if not State.detached and State.esp then
				createEspFor(player)
			end
		end))
	end

	for _, player in ipairs(playersService:GetPlayers()) do
		watchPlayer(player)
	end

	table.insert(State.connections, playersService.PlayerAdded:Connect(function(player)
		watchPlayer(player)

		if not State.detached and State.esp then
			task.wait(0.5)
			createEspFor(player)
		end
	end))

	table.insert(State.connections, playersService.PlayerRemoving:Connect(function(player)
		clearEspFor(player)
	end))

	table.insert(State.connections, localPlayer.Idled:Connect(function()
		if State.antiAfk then
			virtualUserService:CaptureController()
			virtualUserService:ClickButton2(Vector2.new())
		end
	end))


	-- JumpRequest supports the mobile jump button as well as the keyboard.
	table.insert(State.connections, userInputService.JumpRequest:Connect(function()
		if State.infiniteJump and not State.open then
			local humanoid = getHumanoid()
			if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end))

end

---Create the Rayfield Gen2 control center without changing combat behavior.
local function createRayfieldGui()
	local parent = gethui and gethui() or coreGuiService
	local isMobile = userInputService.TouchEnabled
	local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
	local window = Rayfield:CreateWindow({
		name = "Galaxy Sniper Arena",
		subtitle = "Combat Control Center",
		theme = "cobalt",
		sidebarLayout = true,
		profile = "Sniper Arena tools",
		showName = "Galaxy",
		fallbackFont = Enum.Font.Gotham,
		configuration = {
			autoSave = true,
			autoLoad = true,
			fileName = "GalaxySniperArenaGen2",
			customFolder = "Galaxy",
		},
	})

	Galaxy.window = window
	local overlay = Instance.new("ScreenGui")
	overlay.Name = GUI_NAME
	overlay.ResetOnSpawn = false
	overlay.IgnoreGuiInset = true
	overlay.DisplayOrder = 1000
	overlay.Parent = parent
	Galaxy.screenGui = overlay

	local combatTab = window:CreateTab({
		name = "Combat",
		icon = "crosshair",
	})
	local targetingTab = window:CreateTab({
		name = "Targeting",
		icon = "target",
	})
	local movementTab = window:CreateTab({
		name = "Movement",
		icon = "move",
	})
	local visualsTab = window:CreateTab({
		name = "Visuals",
		icon = "eye",
	})
	local playersTab = window:CreateTab({
		name = "Players",
		icon = "users",
	})
	local utilityTab = window:CreateTab({
		name = "Utility",
		icon = "settings",
	})

	combatTab:CreateSection({
		name = "Combat Automation",
	})
	combatTab:CreateToggle({
		name = "Aimbot",
		description = "Tracks the closest valid enemy target.",
		value = State.aimbot,
		flag = "GalaxySniperArenaAimbot",
		callback = function(value)
			State.aimbot = value
		end,
	})
	combatTab:CreateToggle({
		name = "Triggerbot",
		description = "Fires when a valid target enters the trigger area.",
		value = State.triggerbot,
		flag = "GalaxySniperArenaTriggerbot",
		callback = function(value)
			State.triggerbot = value
		end,
	})

	targetingTab:CreateSection({
		name = "Target Selection",
	})
	targetingTab:CreateDropdown({
		name = "Aim Part",
		description = "Body part used by the targeting controls.",
		options = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"},
		value = State.aimPart,
		multiSelect = false,
		flag = "GalaxySniperArenaAimPart",
		callback = function(value)
			State.aimPart = value
		end,
	})
	targetingTab:CreateSlider({
		name = "FOV Radius",
		range = {80, 800},
		increment = 10,
		suffix = " px",
		value = State.fovRadius,
		flag = "GalaxySniperArenaFovRadius",
		callback = function(value)
			State.fovRadius = value
		end,
	})
	targetingTab:CreateSlider({
		name = "Smoothing",
		range = {0.05, 1},
		increment = 0.05,
		suffix = "x",
		value = State.smoothing,
		flag = "GalaxySniperArenaSmoothing",
		callback = function(value)
			State.smoothing = value
		end,
	})
	targetingTab:CreateSlider({
		name = "Trigger Radius",
		range = {6, 80},
		increment = 2,
		suffix = " px",
		value = State.triggerRadius,
		flag = "GalaxySniperArenaTriggerRadius",
		callback = function(value)
			State.triggerRadius = value
		end,
	})

	movementTab:CreateSection({
		name = "Movement Controls",
	})
	movementTab:CreateToggle({
		name = "Noclip",
		description = "Disables character collisions while enabled.",
		value = State.noclip,
		flag = "GalaxySniperArenaNoclip",
		callback = function(value)
			State.noclip = value
			if not value then
				restoreCollision()
			end
		end,
	})
	movementTab:CreateToggle({
		name = "Infinite Jump",
		description = "Allows jumping again while airborne.",
		value = State.infiniteJump,
		flag = "GalaxySniperArenaInfiniteJump",
		callback = function(value)
			State.infiniteJump = value
		end,
	})
	movementTab:CreateButton({
		name = "Safe Lift",
		description = "Moves you 25 studs upward from your current position.",
		callback = function()
			local root = getRoot()
			if root then
				root.CFrame = root.CFrame + Vector3.new(0, 25, 0)
			end
		end,
	})

	visualsTab:CreateSection({
		name = "Visual Assistance",
	})
	visualsTab:CreateToggle({
		name = "FOV Circle",
		description = "Displays the current targeting radius.",
		value = State.fovCircle,
		flag = "GalaxySniperArenaFovCircle",
		callback = function(value)
			State.fovCircle = value
		end,
	})
	visualsTab:CreateToggle({
		name = "Player ESP",
		description = "Shows highlights for tracked players.",
		value = State.esp,
		flag = "GalaxySniperArenaEsp",
		callback = function(value)
			State.esp = value
			refreshEsp()
		end,
	})
	visualsTab:CreateToggle({
		name = "Fullbright",
		description = "Brightens local lighting for visibility.",
		value = State.fullbright,
		flag = "GalaxySniperArenaFullbright",
		callback = function(value)
			State.fullbright = value
			applyFullbright(value)
		end,
	})
	visualsTab:CreateButton({
		name = "Field Of View 90",
		description = "Applies a wide but playable camera FOV.",
		callback = function()
			currentCamera = workspace.CurrentCamera
			if currentCamera then
				if State.originalCameraFov[currentCamera] == nil then
					State.originalCameraFov[currentCamera] = currentCamera.FieldOfView
				end
				currentCamera.FieldOfView = 90
			end
		end,
	})

	local playerLookup = {}
	local playerDropdown
	local function getPlayerOptions()
		table.clear(playerLookup)
		local options = {}
		for _, player in ipairs(playersService:GetPlayers()) do
			if player ~= localPlayer then
				local label = player.DisplayName .. "  @" .. player.Name
				playerLookup[label] = player
				table.insert(options, label)
			end
		end
		table.sort(options)
		return options
	end

	playersTab:CreateSection({
		name = "Player Selection",
	})
	playerDropdown = playersTab:CreateDropdown({
		name = "Target Player",
		description = "Select a player for teleport and refresh actions.",
		options = getPlayerOptions(),
		value = nil,
		placeholder = "Select a player",
		multiSelect = false,
		flag = "GalaxySniperArenaTargetPlayer",
		callback = function(value)
			State.selectedPlayer = playerLookup[value]
		end,
	})
	playersTab:CreateButton({
		name = "Teleport To Selected",
		description = "Moves your character beside the selected player.",
		callback = function()
			teleportToPlayer(State.selectedPlayer)
		end,
	})
	playersTab:CreateButton({
		name = "Refresh ESP",
		description = "Rebuilds player highlights.",
		callback = function()
			refreshEsp()
		end,
	})

	local function refreshPlayerDropdown()
		if not State.detached and playerDropdown then
			playerDropdown:Refresh(getPlayerOptions())
		end
	end
	table.insert(Galaxy.connections, playersService.PlayerAdded:Connect(function()
		task.defer(refreshPlayerDropdown)
	end))
	table.insert(Galaxy.connections, playersService.PlayerRemoving:Connect(function(player)
		if State.selectedPlayer == player then
			State.selectedPlayer = nil
		end
		task.defer(refreshPlayerDropdown)
	end))

	utilityTab:CreateSection({
		name = "Quality of Life",
	})
	utilityTab:CreateToggle({
		name = "Anti AFK",
		description = "Prevents the Roblox idle timeout while enabled.",
		value = State.antiAfk,
		flag = "GalaxySniperArenaAntiAfk",
		callback = function(value)
			State.antiAfk = value
		end,
	})
	utilityTab:CreateButton({
		name = "Reset Character",
		description = "Breaks the current humanoid cleanly.",
		callback = function()
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.Health = 0
			end
		end,
	})
	utilityTab:CreateButton({
		name = "Rejoin Server",
		description = "Reconnects to this public server.",
		callback = function()
			teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
		end,
	})
	utilityTab:CreateButton({
		name = "Copy Server Info",
		description = "Copies place and job id if clipboard is available.",
		callback = function()
			local payload = ("PlaceId: %s\nJobId: %s\nPlayers: %d"):format(tostring(game.PlaceId), game.JobId, #playersService:GetPlayers())
			if setclipboard then
				setclipboard(payload)
				notify("Galaxy", "Server info copied.")
			else
				notify("Galaxy", payload)
			end
		end,
	})

	utilityTab:CreateSection({
		name = "Interface",
	})
	utilityTab:CreateDropdown({
		name = "Theme",
		options = {"default", "cobalt", "ember", "amethyst", "frost", "rose"},
		value = "cobalt",
		multiSelect = false,
		flag = "GalaxySniperArenaTheme",
		callback = function(value)
			if value then
				window:ChangeTheme(value)
			end
		end,
	})
	utilityTab:CreateButton({
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
	utilityTab:CreateButton({
		name = "Unload Galaxy",
		description = "Stops features and removes the interface.",
		icon = "trash-2",
		callback = function()
			Galaxy.detach()
		end,
	})

	local function setOpen(open)
		State.open = open
		if open then
			window:Show()
			unlockMouseForGui()
		else
			window:Hide()
			restoreMouseForGame()
		end
	end

	table.insert(
		Galaxy.connections,
		userInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end

			if input.KeyCode == Enum.KeyCode.P or input.KeyCode == Enum.KeyCode.RightShift then
				setOpen(not State.open)
			end
		end)
	)

	setOpen(true)
	window:Notify({
		title = "Galaxy Sniper Arena",
		content = "Press P or RightShift to show or hide the GUI.",
	})
end

---Create the script control GUI.
local function createGui()
	local parent = gethui and gethui() or coreGuiService
	local isMobile = userInputService.TouchEnabled
	local mainWidth = isMobile and 300 or 360
	local mainHeight = isMobile and 460 or 540
	local screenGui = Instance.new("ScreenGui")

	Galaxy.screenGui = screenGui
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
	titleLabel.Text = "Galaxy | Sniper Arena"
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
	listHolder.Position = UDim2.new(0, 10, 0, 128)
	listHolder.Size = UDim2.new(1, -20, 1, -138)
	listHolder.Parent = mainFrame

	addCorner(listHolder, 8)
	addStroke(listHolder, Color3.fromRGB(52, 59, 76), 0.45)


	-- Keep all six categories accessible on the compact mobile window.
	local tabBar = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 54),
		Size = UDim2.new(1, -20, 0, 64),
		Parent = mainFrame,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -4, 0, 29),
		CellPadding = UDim2.fromOffset(6, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabBar,
	})
	local Pages = {}
	local TabButtons = {}
	local function setTab(name)
		State.activeTab = name
		for pageName, page in pairs(Pages) do page.Visible = pageName == name end
		for tabName, button in pairs(TabButtons) do
			button.BackgroundColor3 = tabName == name and ACCENT_COLOR or SURFACE_COLOR
			button.TextColor3 = tabName == name and BACKGROUND_COLOR or TEXT_COLOR
		end
	end
	for order, name in ipairs({"Combat", "Targeting", "Movement", "Visuals", "Players", "Utility"}) do
		local page = make("ScrollingFrame", {
			Name = name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.new(1, -16, 1, -16),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = ACCENT_COLOR,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = name == State.activeTab,
			Parent = listHolder,
		})
		make("UIPadding", {PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 6), Parent = page})
		make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page})
		Pages[name] = page
		local button = make("TextButton", {
			Name = name .. "Tab",
			LayoutOrder = order,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextSize = 11,
			Parent = tabBar,
		})
		addCorner(button, 6)
		TabButtons[name] = button
		button.Activated:Connect(function() setTab(name) end)
		createSection(page, string.upper(name))
	end
	setTab(State.activeTab)

	createButton(Pages.Utility, "Reset Character", "Breaks current humanoid cleanly.", function()
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.Health = 0
		end
	end, DANGER_COLOR)

	createButton(Pages.Movement, "Safe Lift", "Moves you 25 studs upward from current position.", function()
		local root = getRoot()
		if root then
			root.CFrame = root.CFrame + Vector3.new(0, 25, 0)
		end
	end)

	createToggle(Pages.Combat, "Aimbot", State.aimbot, function(enabled)
		State.aimbot = enabled
	end)

	createToggle(Pages.Combat, "Triggerbot", State.triggerbot, function(enabled)
		State.triggerbot = enabled
	end)

	createToggle(Pages.Visuals, "FOV Circle", State.fovCircle, function(enabled)
		State.fovCircle = enabled
	end)

	createDropdown(Pages.Targeting, "Aim Part", { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }, State.aimPart, function(value)
		State.aimPart = value
	end)

	createSlider(Pages.Targeting, "FOV Radius", 80, 800, State.fovRadius, function(value)
		State.fovRadius = value
	end)

	createSlider(Pages.Targeting, "Aim Smoothing", 5, 100, math.floor(State.smoothing * 100), function(value)
		State.smoothing = math.clamp(value / 100, 0.05, 1)
	end)

	createSlider(Pages.Targeting, "Trigger Radius", 6, 80, State.triggerRadius, function(value)
		State.triggerRadius = value
	end)

	createToggle(Pages.Movement, "Noclip", false, function(enabled)
		State.noclip = enabled
		if not enabled then restoreCollision() end
	end)

	createToggle(Pages.Movement, "Infinite Jump", false, function(enabled)
		State.infiniteJump = enabled
	end)

	createToggle(Pages.Visuals, "Player ESP", false, function(enabled)
		State.esp = enabled
		refreshEsp()
	end)

	createToggle(Pages.Visuals, "Fullbright", false, function(enabled)
		State.fullbright = enabled
		applyFullbright(enabled)
	end)

	createButton(Pages.Visuals, "Field Of View 90", "Applies a wide but playable camera FOV.", function()
		currentCamera = workspace.CurrentCamera
		if currentCamera then
			if State.originalCameraFov[currentCamera] == nil then
				State.originalCameraFov[currentCamera] = currentCamera.FieldOfView
			end
			currentCamera.FieldOfView = 90
		end
	end)

	makePlayerDropdown(Pages.Players)

	createButton(Pages.Players, "Teleport To Selected", "Moves your character beside the selected player.", function()
		teleportToPlayer(State.selectedPlayer)
	end)

	createButton(Pages.Players, "Refresh ESP", "Rebuilds player highlights.", function()
		refreshEsp()
	end)

	createToggle(Pages.Utility, "Anti AFK", false, function(enabled)
		State.antiAfk = enabled
	end)

	createButton(Pages.Utility, "Rejoin Server", "Reconnects to this public server.", function()
		teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
	end)

	createButton(Pages.Utility, "Copy Server Info", "Copies place and job id if clipboard is available.", function()
		local payload = ("PlaceId: %s\nJobId: %s\nPlayers: %d"):format(tostring(game.PlaceId), game.JobId, #playersService:GetPlayers())
		if setclipboard then
			setclipboard(payload)
			notify("Galaxy", "Server info copied.")
		else
			notify("Galaxy", payload)
		end
	end)


	createButton(Pages.Utility, "Unload Galaxy", "Stop features and restore settings.", Galaxy.detach, DANGER_COLOR)


	local function setOpen(open)
		State.open = open
		if open then unlockMouseForGui() else restoreMouseForGame() end
		mainFrame.Visible = open
	end

	-- Match the window to its initial visibility.
	setOpen(mainFrame.Visible)

	closeButton.Activated:Connect(function()
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

			if input.KeyCode == Enum.KeyCode.P or input.KeyCode == Enum.KeyCode.RightShift then
				setOpen(not mainFrame.Visible)
				return
			end

		end)
	)

	if not isMobile then
		notify("Galaxy", "Toggle P open and close")
	end
end

---Replace the previous instance and initialize the GUI and features.
function Galaxy.init()
	-- Retire the original arena GUI when switching to this version.
	if getgenv and getgenv().AcracyCleanGui then
		pcall(function() getgenv().AcracyCleanGui:Destroy() end)
	end
	if shared.PotentMurderDuels then
		shared.PotentMurderDuels.detach()
		shared.PotentMurderDuels = nil
	end

	if shared.GalaxyMurderDuels then
		shared.GalaxyMurderDuels.detach()
	end

	-- Remove an orphaned window before creating its replacement.
	local parent = gethui and gethui() or coreGuiService
	local oldGui = parent:FindFirstChild(GUI_NAME)
	if oldGui then
		oldGui:Destroy()
	end

	shared.GalaxyMurderDuels = Galaxy
	createRayfieldGui()
	startFeatures()
	table.insert(Galaxy.connections, Galaxy.screenGui.Destroying:Connect(Galaxy.detach))
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
