--[[--!strict
local HttpGet = game.HttpGet
local GameId: number = game.GameId

local Games: {[number]: string} = loadstring(
  HttpGet(game, "https://raw.githubusercontent.com/Sayrealll/LunaHubX/refs/heads/main/loader.lua")
)() :: any

local URL: string? = Games[GameId]
if not URL then return end

loadstring(HttpGet(game, URL))() ]]


local PlaceId = game.PlaceId
local GameId = game.GameId

local SupportedGames = {

    -- ANIME DICE
    [113290951185459] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Sayrealll/LunaHubX/refs/heads/main/animedice.lua"))()
    end,

    -- RIDE A PET
    [124216119978534] = function()
        print("[LunaHubX]: Loading for Ride A Pet...")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Sayrealll/LunaHubX/refs/heads/main/rap.lua"))()
    end,

    -- STEAL AN EGG
    [10563114921] = function()
        print("[LunaHubX]: Loading for Steal An Egg...")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Sayrealll/LunaHubX/refs/heads/main/stealanegg.lua"))()
    end,

}

local function LoadScript()
    if SupportedGames[PlaceId] then
        SupportedGames[PlaceId]()
    elseif SupportedGames[GameId] then
        SupportedGames[GameId]()
    else
        warn("[LunaHubX]: Game not supported!")
    end
end

task.spawn(LoadScript)
