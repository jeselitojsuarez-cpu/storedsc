-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// Murder Duels
local MURDER_DUELS_GAME_ID = 9561553764
local MURDER_DUELS_PLACE_ID = 120851538706364
local MURDER_DUELS_URL =
	"https://raw.githubusercontent.com/jeselitojsuarez-cpu/storedsc/refs/heads/main/MurderDul.lua"

--// Sniper Arena
local SNIPER_ARENA_PLACE_ID = 122446657157717
local SNIPER_ARENA_URL =
	"https://raw.githubusercontent.com/jeselitojsuarez-cpu/storedsc/refs/heads/main/sniperare.lua"

--// Karinderya
local KARINDERYA_PLACE_ID = 116497287371701
local KARINDERYA_URL =
	"https://raw.githubusercontent.com/privatethis425/LUASCC/refs/heads/main/karinderya.lua"

--// Dueling Grounds
local DUELING_GROUNDS_PLACE_ID = 94217045453265
local DUELING_GROUNDS_URL =
	"https://raw.githubusercontent.com/jeselitojsuarez-cpu/storedsc/refs/heads/main/Dulgrounds.lua"

--// The Strongest Battlegrounds
local TSB_PLACE_ID = 10449761463
local TSB_URL =
	"https://raw.githubusercontent.com/jeselitojsuarez-cpu/storedsc/refs/heads/main/tsb.lua"

-- Get the universe/GameId that the Sniper Arena lobby belongs to.
local function getUniverseId(placeId)
	local success, result = pcall(function()
		local response = game:HttpGet(
			"https://apis.roblox.com/universes/v1/places/" .. tostring(placeId) .. "/universe"
		)

		return HttpService:JSONDecode(response).universeId
	end)

	if success then
		return result
	end

	warn("Failed to get Sniper Arena universe ID:", result)
	return nil
end

-- Cache it so we don't request it every execution.
shared.SniperArenaGameId =
	shared.SniperArenaGameId or getUniverseId(SNIPER_ARENA_PLACE_ID)

--// Detect game
if game.GameId == MURDER_DUELS_GAME_ID
	or game.PlaceId == MURDER_DUELS_PLACE_ID then

	loadstring(game:HttpGet(MURDER_DUELS_URL))()

elseif game.GameId == shared.SniperArenaGameId
	or game.PlaceId == SNIPER_ARENA_PLACE_ID then

	loadstring(game:HttpGet(SNIPER_ARENA_URL))()

elseif game.PlaceId == KARINDERYA_PLACE_ID then

	loadstring(game:HttpGet(KARINDERYA_URL))()

elseif game.PlaceId == DUELING_GROUNDS_PLACE_ID then

	loadstring(game:HttpGet(DUELING_GROUNDS_URL))()

elseif game.PlaceId == TSB_PLACE_ID then

	loadstring(game:HttpGet(TSB_URL))()

else
	Players.LocalPlayer:Kick(
		"Unsupported game.\n"
		.. "GameId: " .. tostring(game.GameId)
		.. "\nPlaceId: " .. tostring(game.PlaceId)
	)
end
