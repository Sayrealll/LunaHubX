--AUTO HATCH, AUTO CLAIM OFFLINE, AUTO BUY GEAR & FOOD, Confi, anti afk, fps boos, server hop rejoin, fixed placed eggs, auto rebrth claim index
--auto offline rewards, auto equip best not fixed
--ANTI AFK
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local VirtualUser = game:GetService("VirtualUser")

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// SERVICES
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local MaterialService = cloneref(game:GetService("MaterialService"))
local TeleportService = cloneref(game:GetService("TeleportService"))

--// PLAYER

local Player = Players.LocalPlayer

--// WINDUI

local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if RunService:IsStudio() or not writefile then
			WindUI = require(
				ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")
			)
		else
			WindUI =
				loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
					)
				)()
		end
	end
end

--// SETTINGS & CONFIG MANAGER

local ConfigFile = "LunaHub_Config.json"
local isResetting = false

local ConfigData = {
	SelectedEggs = {},
	SelectedPlaceEgg = {},
	AutoPickup = false,
	AutoPlaceEgg = false,
	AutoHatchEgg = false,
	AutoUpgradeHatchLuck = false,
	AutoUpgradeHatchLuckMax = false,
	AutoRebirth = false,
	AutoClaimIndex = false,
	AutoClaimOffline = false,
	SelectedGear = {},
	Autobuygear = false,
	SelectedFood = {},
	Autobuyfood = false,
	SelectedESPEggs = {},
	FPSBoost = false,	
    AutoEquipBestPet = false,
	ESPEnabled = false
}

local function LoadConfig()
	if isfile and readfile and isfile(ConfigFile) then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigFile))
		end)
		if success and type(result) == "table" then
			for k, v in pairs(result) do
				ConfigData[k] = v
			end
		end
	end
end

local function SaveConfig()
	if isResetting then return end
	if writefile then
		pcall(function()
			writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
		end)
	end
end

LoadConfig()

local ThemeName = "Dark"

-- MULTI-SELECT TABLES
local SelectedEggs = ConfigData.SelectedEggs or {}
local SelectedPlaceEgg = ConfigData.SelectedPlaceEgg or {}
local SelectedESPEggs = ConfigData.SelectedESPEggs or {}
local SelectedGear = ConfigData.SelectedGear or {}
local SelectedFood = ConfigData.SelectedFood or {}

-- TOGGLES
local AutoPickup = ConfigData.AutoPickup or false
local AutoPlaceEgg = ConfigData.AutoPlaceEgg or false
local AutoHatchEgg = ConfigData.AutoHatchEgg or false
local AutoClaimIndex = ConfigData.AutoClaimIndex or false
local AutoClaimOffline = ConfigData.AutoClaimOffline or false
local AutoUpgradeHatchLuck = ConfigData.AutoUpgradeHatchLuck or false
local AutoUpgradeHatchLuckMax = ConfigData.AutoUpgradeHatchLuckMax or false
local AutoRebirth = ConfigData.AutoRebirth or false
local ESPEnabled = ConfigData.ESPEnabled or false
local Autobuygear = ConfigData.Autobuygear or false
local Autobuyfood = ConfigData.Autobuyfood or false
local FPSBoost = ConfigData.FPSBoost or false
local AutoEquipBestPet = ConfigData.AutoEquipBestPet or false


-- UI ELEMENT REFERENCES FOR RESET
local UIElements = {}

local function SetUIValue(element, newValue)
	if not element then return end
	pcall(function()
		if element.Set then
			element:Set(newValue)
		elseif element.SetValue then
			element:SetValue(newValue)
		elseif element.Value ~= nil then
			element.Value = newValue
		end
	end)
end

--==================================================
-- FPS BOOST & RESTORE SYSTEM
--==================================================

local SavedGraphicsState = {
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	ShadowSoftness = Lighting.ShadowSoftness,
	QualityLevel = settings().Rendering.QualityLevel,
	MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel,
	Materials = {},
	WaterWaveSize = nil,
	WaterWaveSpeed = nil,
	WaterReflectance = nil,
	WaterTransparency = nil,
	OriginalProps = {}
}

local function SaveOriginalGraphics()
	SavedGraphicsState.GlobalShadows = Lighting.GlobalShadows
	SavedGraphicsState.FogEnd = Lighting.FogEnd
	SavedGraphicsState.ShadowSoftness = Lighting.ShadowSoftness
	SavedGraphicsState.QualityLevel = settings().Rendering.QualityLevel
	SavedGraphicsState.MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		SavedGraphicsState.WaterWaveSize = terrain.WaterWaveSize
		SavedGraphicsState.WaterWaveSpeed = terrain.WaterWaveSpeed
		SavedGraphicsState.WaterReflectance = terrain.WaterReflectance
		SavedGraphicsState.WaterTransparency = terrain.WaterTransparency
	end
end

SaveOriginalGraphics()

local FPSConn = nil

local function ApplyFPSBoost(state)
	if state then
		SaveOriginalGraphics()

		pcall(function() Lighting.GlobalShadows = false end)
		pcall(function() Lighting.FogEnd = 9e9 end)
		pcall(function() Lighting.ShadowSoftness = 0 end)

		if sethiddenproperty then
			pcall(function() sethiddenproperty(Lighting, "Technology", 2) end)
		end

		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
		end)

		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			pcall(function()
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
				terrain.WaterTransparency = 0
				if sethiddenproperty then
					sethiddenproperty(terrain, "Decoration", false)
				end
			end)
		end

		if setfpscap then
			pcall(function() setfpscap(1e6) end)
		end

		local function CleanInstance(Inst)
			if not Inst or not Inst.Parent then return end
			pcall(function()
				if Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
					if not SavedGraphicsState.OriginalProps[Inst] then
						SavedGraphicsState.OriginalProps[Inst] = {
							Material = Inst.Material,
							Reflectance = Inst.Reflectance
						}
					end
					Inst.Material = Enum.Material.Plastic
					Inst.Reflectance = 0
				elseif Inst:IsA("MeshPart") then
					if not SavedGraphicsState.OriginalProps[Inst] then
						SavedGraphicsState.OriginalProps[Inst] = {
							Material = Inst.Material,
							Reflectance = Inst.Reflectance,
							RenderFidelity = Inst.RenderFidelity
						}
					end
					Inst.RenderFidelity = Enum.RenderFidelity.Performance
					Inst.Reflectance = 0
					Inst.Material = Enum.Material.Plastic
				elseif Inst:IsA("PostEffect")
					or Inst:IsA("ParticleEmitter")
					or Inst:IsA("Trail")
					or Inst:IsA("Smoke")
					or Inst:IsA("Fire")
					or Inst:IsA("Sparkles") then

					if not SavedGraphicsState.OriginalProps[Inst] then
						SavedGraphicsState.OriginalProps[Inst] = {
							Enabled = Inst.Enabled
						}
					end

					Inst.Enabled = false
				end
			end)
		end

		for _, v in ipairs(game:GetDescendants()) do
			CleanInstance(v)
		end

		if FPSConn then
			FPSConn:Disconnect()
		end

		FPSConn = game.DescendantAdded:Connect(function(v)
			if FPSBoost then
				CleanInstance(v)
			end
		end)

	else
		if FPSConn then
			FPSConn:Disconnect()
			FPSConn = nil
		end

		pcall(function() Lighting.GlobalShadows = SavedGraphicsState.GlobalShadows end)
		pcall(function() Lighting.FogEnd = SavedGraphicsState.FogEnd end)
		pcall(function() Lighting.ShadowSoftness = SavedGraphicsState.ShadowSoftness end)

		pcall(function()
			settings().Rendering.QualityLevel = SavedGraphicsState.QualityLevel
			settings().Rendering.MeshPartDetailLevel = SavedGraphicsState.MeshPartDetailLevel
		end)

		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			pcall(function()
				if SavedGraphicsState.WaterWaveSize then
					terrain.WaterWaveSize = SavedGraphicsState.WaterWaveSize
				end

				if SavedGraphicsState.WaterWaveSpeed then
					terrain.WaterWaveSpeed = SavedGraphicsState.WaterWaveSpeed
				end

				if SavedGraphicsState.WaterReflectance then
					terrain.WaterReflectance = SavedGraphicsState.WaterReflectance
				end

				if SavedGraphicsState.WaterTransparency then
					terrain.WaterTransparency = SavedGraphicsState.WaterTransparency
				end
			end)
		end

		if setfpscap then
			pcall(function() setfpscap(60) end)
		end

		for Inst, Props in pairs(SavedGraphicsState.OriginalProps) do
			if Inst and Inst.Parent then
				pcall(function()
					for prop, val in pairs(Props) do
						Inst[prop] = val
					end
				end)
			end
		end

		SavedGraphicsState.OriginalProps = {}
	end
end

-- Init Boost if loaded from config
if FPSBoost then
	task.spawn(function()
		task.wait(1)
		ApplyFPSBoost(true)
	end)
end

--// EGG CONTAINER

local RenderedEggs = workspace:WaitForChild("RenderedEggs")

--// EGG LIST

local EggNames = {
	"Cherub Egg",
	"Blackhole Egg",
	"Solaris Egg",
	"Aurora Egg",
	"Galaxy Egg",
	"Asteroid Egg",
	"Crystal Egg",
	"Diamond Egg",
	"Dominus Egg",
	"Flaming Egg",
	"Sinister Egg",
	"Skull Egg",
	"Soul Egg",
	"Glass Egg",
	"Golden Egg",
	"Flower Egg",
	"Ice Egg",
	"Mushroom Egg",
	"Slime Egg",
	"Cracked Egg",
	"Easter Egg",
	"Leaf Egg",
	"Stone Egg",
	"Brown Egg",
	"White Egg"
}

--==================================================
-- SHOP STOCK SYSTEM
--==================================================

local GameRemotes =
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")

local BuyWithCash =
	GameRemotes:WaitForChild("BuyWithCash")

local ShopStockRemote =
	GameRemotes:WaitForChild("ShopStock")

local RestockRemote =
	GameRemotes:WaitForChild("Restock")

local ShopStockData = {}
local ShopStockReady = false

--==================================================
-- RECEIVE STOCK DATA
--==================================================

RestockRemote.OnClientEvent:Connect(function(stockData)

	if type(stockData) ~= "table" then
		return
	end

	ShopStockData = stockData
	ShopStockReady = true

end)

--==================================================
-- REQUEST INITIAL STOCK
--==================================================

task.spawn(function()

	for i = 1, 10 do

		if ShopStockReady then
			break
		end

		pcall(function()
			ShopStockRemote:FireServer()
		end)

		task.wait(2)
	end

end)

--==================================================
-- GET CURRENT STOCK
--==================================================

local function GetShopStock(Category, ItemName)

	local CategoryData = ShopStockData[Category]

	if type(CategoryData) ~= "table" then
		return 0
	end

	local ItemData = CategoryData[ItemName]

	if type(ItemData) ~= "table" then
		return 0
	end

	return tonumber(ItemData.Amount) or 0

end

--==================================================
-- REDUCE LOCAL STOCK AFTER PURCHASE
--==================================================

local function ReduceShopStock(Category, ItemName)

	local CategoryData = ShopStockData[Category]

	if type(CategoryData) ~= "table" then
		return
	end

	local ItemData = CategoryData[ItemName]

	if type(ItemData) ~= "table" then
		return
	end

	local Amount = tonumber(ItemData.Amount) or 0

	ItemData.Amount = math.max(0, Amount - 1)

end

local GearShop = {
	"Advanced Radar",
	"Jewel Radar",
	"Royal Radar",
	"Magic Radar",
	"Angelic Radar",
	"Eternal Radar"
}

local FoodShop = {
	"Grass",
	"Bone",
	"Meat",
	"Magic Apple",
	"Dragon Fruit"
}

-- Mapping ng Priority
local EggPriority = {}

for Index, Name in ipairs(EggNames) do
	EggPriority[Name] = Index
end

--==================================================
-- WINDOW
--==================================================

local Window = WindUI:CreateWindow({
	Title = "LUNA HUB",
	Author = "RIDE A PET",
	Theme = ThemeName,

	ToggleKey = Enum.KeyCode.F,
	OpenButton = {
		Enabled = true,
		OnlyMobile = false
	},
})

Window:Tag({
	Title = "v.1.0.2.6",
	Color = "ElementBackground",
})

--==================================================
-- TABS
--==================================================

local Tab1 = Window:Tab({
	Title = "HOME",
	Icon = "warehouse"
})

local Tab2 = Window:Tab({
	Title = "FARM",
	Icon = "egg"
})

local Tab3 = Window:Tab({
	Title = "SHOP",
	Icon = "shopping-cart"
})

local Tab4 = Window:Tab({
	Title = "VISUAL",
	Icon = "eye"
})

local Tab5 = Window:Tab({
	Title = "EGGS",
	Icon = "list-ordered"
})

local Tab6 = Window:Tab({
	Title = "CONFIG",
	Icon = "pen"
})

local Tab7 = Window:Tab({
	Title = "SETTINGS",
	Icon = "settings"
})

--==================================================
-- TAB 1 (HOME)
--==================================================

Tab1:Paragraph({
	Title = "Discord",
	Desc = "Join our Discord Community",

	Buttons = {
		{
			Title = "Discord",
			Callback = function()
				local DiscordLink = "discord.gg/Ev8k5RAU3"

				if setclipboard then
					setclipboard(DiscordLink)
				end

				WindUI:Notify({
					Title = "Discord Link",
					Content = "Discord link copied to clipboard!",
					Icon = "solar:copy-bold",
					Duration = 4,
					CanClose = true,
				})
			end,
		},
	},
})

--==================================================
-- TAB 2 (FARM)
--==================================================

local EggSection = Tab2:Section({
	Title = "Auto Farm",
	Icon = "egg",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedEggs = EggSection:Dropdown({
	Title = "Select Egg",
	Desc = "Choose which eggs to auto farm",
	Values = EggNames,
	Multi = true,
	Value = ConfigData.SelectedEggs,
	AllowNone = true,

	Callback = function(value)
		SelectedEggs = value
		ConfigData.SelectedEggs = value
		SaveConfig()
	end,
})

UIElements.AutoPickup = EggSection:Toggle({
	Title = "Auto Farm",
	Desc = "Automatic to get the egg and proceed to your plot",
	Value = ConfigData.AutoPickup,

	Callback = function(value)
		AutoPickup = value
		ConfigData.AutoPickup = value
		SaveConfig()
	end,
})

UIElements.SelectedPlaceEgg = EggSection:Dropdown({
	Title = "Select eggs to Auto Place",
	Desc = "Choose which eggs to place in your plot",
	Values = EggNames,
	Multi = true,
	Value = ConfigData.SelectedPlaceEgg,
    AllowNone = true,
	Callback = function(value)
		SelectedPlaceEgg = value
		ConfigData.SelectedPlaceEgg = value
		SaveConfig()
	end,
})

UIElements.AutoPlaceEgg = EggSection:Toggle({
	Title = "Auto Place Eggs",
	Desc = "Automatically place the selected eggs in your plot",
	Value = ConfigData.AutoPlaceEgg,

	Callback = function(value)
		AutoPlaceEgg = value
		ConfigData.AutoPlaceEgg = value
		SaveConfig()
	end,
})

UIElements.AutoHatchEgg = EggSection:Toggle({
	Title = "Auto Hatch Egg",
	Desc = "Automatically hatch ready eggs in your plot",
	Value = ConfigData.AutoHatchEgg,

	Callback = function(value)
		AutoHatchEgg = value
		ConfigData.AutoHatchEgg = value
		SaveConfig()
	end,
})

UIElements.AutoEquipBestPet = EggSection:Toggle({
	Title = "Auto Equip Best Pet",
	Value = ConfigData.AutoEquipBestPet,

	Callback = function(value)
		AutoEquipBestPet = value
		ConfigData.AutoEquipBestPet = value
		SaveConfig()
	end,
})

UIElements.AutoUpgradeHatchLuck = EggSection:Toggle({
	Title = "Auto Upgrade Hatch Luck",
	Desc = "Auto upgrade hatch luck by 1x",
	Value = ConfigData.AutoUpgradeHatchLuck,

	Callback = function(value)
		AutoUpgradeHatchLuck = value
		ConfigData.AutoUpgradeHatchLuck = value
		SaveConfig()
	end,
})

UIElements.AutoUpgradeHatchLuckMax = EggSection:Toggle({
	Title = "Auto Upgrade Hatch Luck (Max)",
	Desc = "Auto upgrade hatch luck by Max",
	Value = ConfigData.AutoUpgradeHatchLuckMax,

	Callback = function(value)
		AutoUpgradeHatchLuckMax = value
		ConfigData.AutoUpgradeHatchLuckMax = value
		SaveConfig()
	end,
})

UIElements.AutoRebirth = EggSection:Toggle({
	Title = "Auto Rebirth",
	Value = ConfigData.AutoRebirth,

	Callback = function(value)
		AutoRebirth = value
		ConfigData.AutoRebirth = value
		SaveConfig()
	end,
})

UIElements.AutoClaimIndex = EggSection:Toggle({
	Title = "Auto Claim Index Reward",
	Value = ConfigData.AutoClaimIndex,

	Callback = function(value)
		AutoClaimIndex = value
		ConfigData.AutoClaimIndex = value
		SaveConfig()
	end,
})

UIElements.AutoClaimOffline = EggSection:Toggle({
	Title = "Auto Claim Offline Rewards",
	Value = ConfigData.AutoClaimOffline,

	Callback = function(value)

		AutoClaimOffline = value
		ConfigData.AutoClaimOffline = value

		SaveConfig()

		if value then

			task.spawn(function()

				pcall(function()

					local OfflineEarnings =
						ReplicatedStorage
							:WaitForChild("Remotes")
							:WaitForChild("Game")
							:WaitForChild("OfflineEarnings")

					OfflineEarnings:FireServer()

				end)

			end)

		end
	end,
})

--==================================================
-- TAB 3 (SHOP)
--==================================================

local ShopSection = Tab3:Section({
	Title = "Gear Shop",
	Icon = "wrench",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedGear = ShopSection:Dropdown({
	Title = "Select Radars",
	Values = GearShop,
	Multi = true,
	Value = ConfigData.SelectedGear,
    AllowNone = true,

	Callback = function(value)
		SelectedGear = value
		ConfigData.SelectedGear = value
		SaveConfig()
	end,
})

UIElements.Autobuygear = ShopSection:Toggle({
	Title = "Auto Buy Gears",
	Desc = "Automatic to buy selected gears",
	Value = ConfigData.Autobuygear,

	Callback = function(value)
		Autobuygear = value
		ConfigData.Autobuygear = value
		SaveConfig()
	end,
})

local ShopSection1 = Tab3:Section({
	Title = "Food Shop",
	Icon = "apple",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedFood = ShopSection1:Dropdown({
	Title = "Select Food",
	Values = FoodShop,
	Multi = true,
	Value = ConfigData.SelectedFood,
	AllowNone = true,

	Callback = function(value)
		SelectedFood = value
		ConfigData.SelectedFood = value
		SaveConfig()
	end,
})

UIElements.Autobuyfood = ShopSection1:Toggle({
	Title = "Auto Buy Foods",
	Desc = "Automatic to buy selected Food",
	Value = ConfigData.Autobuyfood,

	Callback = function(value)
		Autobuyfood = value
		ConfigData.Autobuyfood = value
		SaveConfig()
	end,
})

--==================================================
-- TAB 4 (VISUAL)
--==================================================

local VisualSection = Tab4:Section({
	Title = "ESP Settings",
	Icon = "eye",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedESPEggs = VisualSection:Dropdown({
	Title = "Select ESP Egg",
	Desc = "Choose which eggs to display ESP",
	Values = EggNames,
	Multi = true,
	Value = ConfigData.SelectedESPEggs,
	AllowNone = true,

	Callback = function(value)
		SelectedESPEggs = value
		ConfigData.SelectedESPEggs = value
		SaveConfig()
	end,
})

UIElements.ESPEnabled = VisualSection:Toggle({
	Title = "Egg ESP",
	Desc = "Enable ESP and Distance for selected eggs",
	Value = ConfigData.ESPEnabled,

	Callback = function(value)
		ESPEnabled = value
		ConfigData.ESPEnabled = value
		SaveConfig()
	end,
})

--==================================================
-- TAB 5 (EGGS)
--==================================================

local EggsSection = Tab5:Section({
	Title = "Active Eggs",
	Icon = "list",
	Box = true,
	BoxBorder = true,
})

local LiveEggParagraph = EggsSection:Paragraph({
	Title = "Spawned Eggs (0)",
	Desc = "Scanning workspace for rendered eggs...",
})

local function UpdateRenderedEggList()

	local CountMap = {}
	local TotalCount = 0

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name

		CountMap[Name] = (CountMap[Name] or 0) + 1
		TotalCount = TotalCount + 1
	end

	if TotalCount == 0 then

		LiveEggParagraph:SetTitle("Spawned Eggs (0)")
		LiveEggParagraph:SetDesc("No eggs currently rendered on map.")

	else

		local SpawnedEggNames = {}

		for Name, _ in pairs(CountMap) do
			table.insert(SpawnedEggNames, Name)
		end

		table.sort(SpawnedEggNames, function(a, b)

			local priorityA = EggPriority[a] or 999
			local priorityB = EggPriority[b] or 999

			return priorityA < priorityB
		end)

		local DescriptionText = ""

		for _, Name in ipairs(SpawnedEggNames) do

			local Count = CountMap[Name]

			DescriptionText =
				DescriptionText
				.. string.format("• %s (x%d)\n", Name, Count)

		end

		LiveEggParagraph:SetTitle(
			string.format("Spawned Eggs (%d)", TotalCount)
		)

		LiveEggParagraph:SetDesc(DescriptionText)
	end
end

RenderedEggs.ChildAdded:Connect(function()
	task.defer(UpdateRenderedEggList)
end)

RenderedEggs.ChildRemoved:Connect(function()
	task.defer(UpdateRenderedEggList)
end)

task.spawn(function()
	task.wait(1)
	UpdateRenderedEggList()
end)

--==================================================
-- TAB 6 (CONFIG)
--==================================================

local ConfigSection = Tab6:Section({
	Title = "Config",
	Icon = "pen",
	Box = true,
	BoxBorder = true,
})

ConfigSection:Button({
	Title = "Reset Config",
	Desc = "Reset all your saved configurations",

	Callback = function()

		isResetting = true

		if delfile and isfile and isfile(ConfigFile) then
			pcall(function()
				delfile(ConfigFile)
			end)
		end

		if FPSBoost then
			FPSBoost = false
			ApplyFPSBoost(false)
		end

		SelectedEggs = {}
		SelectedPlaceEgg = {}
		AutoPickup = false
		AutoPlaceEgg = false
		AutoHatchEgg = false
		AutoUpgradeHatchLuck = false
		AutoUpgradeHatchLuckMax = false
		AutoRebirth = false
		AutoClaimIndex = false
		AutoClaimOffline = false
		SelectedGear = {}
		Autobuygear = false
		SelectedFood = {}
		Autobuyfood = false
		SelectedESPEggs = {}
		ESPEnabled = false
		FPSBoost = false
        AutoEquipBestPet = false

		ConfigData = {
			SelectedEggs = {},
			SelectedPlaceEgg = {},
			AutoPickup = false,
			AutoPlaceEgg = false,
			AutoHatchEgg = false,
			AutoUpgradeHatchLuck = false,
			AutoUpgradeHatchLuckMax = false,
			AutoRebirth = false,
			AutoClaimIndex = false,
			AutoClaimOffline = false,
			SelectedGear = {},
			Autobuygear = false,
			SelectedFood = {},
			Autobuyfood = false,
			SelectedESPEggs = {},
			ESPEnabled = false,
            AutoEquipBestPet = false,
			FPSBoost = false
		}

		SetUIValue(UIElements.SelectedEggs, {})
		SetUIValue(UIElements.AutoPickup, false)
		SetUIValue(UIElements.SelectedPlaceEgg, {})
		SetUIValue(UIElements.AutoPlaceEgg, false)
		SetUIValue(UIElements.AutoHatchEgg, false)
		SetUIValue(UIElements.AutoUpgradeHatchLuck, false)
		SetUIValue(UIElements.AutoUpgradeHatchLuckMax, false)
		SetUIValue(UIElements.AutoRebirth, false)
		SetUIValue(UIElements.AutoClaimIndex, false)
		SetUIValue(UIElements.AutoClaimOffline, false)
		SetUIValue(UIElements.SelectedGear, {})
		SetUIValue(UIElements.Autobuygear, false)
		SetUIValue(UIElements.SelectedFood, {})
		SetUIValue(UIElements.Autobuyfood, false)
		SetUIValue(UIElements.SelectedESPEggs, {})
		SetUIValue(UIElements.ESPEnabled, false)
		SetUIValue(UIElements.FPSBoost, false)
        SetUIValue(UIElements.AutoEquipBestPet, false)

		WindUI:Notify({
			Title = "Config Reset",
			Content = "All configurations have been reset to default!",
			Icon = "solar:bell-bold",
			Duration = 5,
			CanClose = true,
		})

		task.wait(0.1)
		isResetting = false
	end,
})

--==================================================
-- SERVER FUNCTIONS
--==================================================

local function RejoinServer()

	pcall(function()
		TeleportService:TeleportToPlaceInstance(
			game.PlaceId,
			game.JobId,
			Player
		)
	end)

end

local function ServerHop()

	task.spawn(function()

		local success, result = pcall(function()

			local CurrentJobId = game.JobId
			local Cursor = ""
			local Candidates = {}

			for _ = 1, 5 do

				local Url = string.format(
					"https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s",
					tostring(game.PlaceId),
					Cursor ~= "" and "&cursor=" .. HttpService:UrlEncode(Cursor) or ""
				)

				local Body = game:HttpGet(Url)
				local Data = HttpService:JSONDecode(Body)

				if Data and Data.data then

					for _, Server in ipairs(Data.data) do

						if Server.id
							and Server.id ~= CurrentJobId
							and Server.playing
							and Server.maxPlayers
							and Server.playing < Server.maxPlayers then

							table.insert(Candidates, Server)
						end

					end
				end

				Cursor = (Data and Data.nextPageCursor) or ""

				if Cursor == "" then
					break
				end
			end

			table.sort(Candidates, function(a, b)
				return a.playing < b.playing
			end)

			return Candidates[1]
		end)

		if success and result and result.id then

			WindUI:Notify({
				Title = "Server Hop",
				Content = string.format(
					"Hopping to a server with %d player(s)...",
					result.playing
				),
				Icon = "solar:server-bold",
				Duration = 3,
				CanClose = true,
			})

			task.wait(0.5)

			pcall(function()
				TeleportService:TeleportToPlaceInstance(
					game.PlaceId,
					result.id,
					Player
				)
			end)

		else

			WindUI:Notify({
				Title = "Server Hop",
				Content = "Server hop failed try again.",
				Icon = "solar:bell-bold",
				Duration = 4,
				CanClose = true,
			})

		end
	end)
end

--==================================================
-- TAB 7 (SETTINGS)
--==================================================

local SettingsSection = Tab7:Section({
	Title = "Performance",
	Box = true,
	BoxBorder = true,
})

UIElements.FPSBoost = SettingsSection:Toggle({
	Title = "FPS Boost",
	Desc = "Lower graphics quality to increase FPS performance",
	Value = ConfigData.FPSBoost,

	Callback = function(value)

		FPSBoost = value
		ConfigData.FPSBoost = value
		SaveConfig()

		ApplyFPSBoost(value)
	end,
})

local SettingsSection1 = Tab7:Section({
	Title = "Severs",
	Box = true,
	BoxBorder = true,
})

SettingsSection1:Button({
	Title = "Rejoin",
	Justify = "Center",
	Icon = "",

	Callback = function()
		RejoinServer()
	end,
})

SettingsSection1:Button({
	Title = "Server Hop",
	Justify = "Center",
	Icon = "",

	Callback = function()
		ServerHop()
	end,
})

--==================================================
-- HELPER FUNCTIONS
--==================================================

local function GetCharacter()

	local Character = Player.Character

	if not Character then
		return nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HRP = Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not HRP then
		return nil
	end

	return Character
end

local function GetEggPart(Egg)

	if not Egg then
		return nil
	end

	if Egg:IsA("BasePart") then
		return Egg
	end

	if Egg:IsA("Model") then

		if Egg.PrimaryPart then
			return Egg.PrimaryPart
		end

		local Pickup = Egg:FindFirstChild("Pickup", true)

		if Pickup
			and Pickup:IsA("ProximityPrompt")
			and Pickup.Parent:IsA("BasePart") then

			return Pickup.Parent
		end

		return Egg:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function FindSelectedEgg()

	local BestEgg = nil
	local HighestPriority = math.huge

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do

		local Name = Egg.Name
		local IsSelected = false

		if type(SelectedEggs) == "table" then

			for _, SelectedName in ipairs(SelectedEggs) do

				if SelectedName == Name then
					IsSelected = true
					break
				end

			end

		elseif SelectedEggs == Name then
			IsSelected = true
		end

		if IsSelected then

			local Priority = EggPriority[Name] or 999

			if Priority < HighestPriority then
				HighestPriority = Priority
				BestEgg = Egg
			end
		end
	end

	return BestEgg
end

local function PickupEgg(Egg)

	if not Egg then
		return false
	end

	pcall(function()

		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local GameRemotes = Remotes and Remotes:FindFirstChild("Game")

		if GameRemotes then

			local PickupRemote =
				GameRemotes:FindFirstChild("PickupEgg")
				or GameRemotes:FindFirstChild("ClaimEgg")
				or GameRemotes:FindFirstChild("CollectEgg")

			if PickupRemote then
				PickupRemote:FireServer(Egg)
			end
		end
	end)

	for _, Descendant in ipairs(Egg:GetDescendants()) do

		if Descendant:IsA("ProximityPrompt") then

			if typeof(fireproximityprompt) == "function" then

				pcall(function()
					fireproximityprompt(Descendant)
				end)

			end

			pcall(function()

				Descendant:InputHoldBegin()
				task.wait(0.05)
				Descendant:InputHoldEnd()

			end)
		end
	end

	local Character = GetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
	local EggPart = GetEggPart(Egg)

	if HRP and EggPart then

		pcall(function()

			firetouchinterest(HRP, EggPart, 0)
			task.wait(0.05)
			firetouchinterest(HRP, EggPart, 1)

		end)
	end

	return true
end

local function TeleportToEgg(Egg)

	local Character = GetCharacter()

	if not Character then
		return false
	end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	local EggPart = GetEggPart(Egg)

	if not HRP or not EggPart then
		return false
	end

	HRP.CFrame = EggPart.CFrame * CFrame.new(0, 1.5, 0)

	return true
end

local function TeleportToEggVoid(EggPosition)

	local Character = GetCharacter()

	if not Character then
		return false
	end

	local HRP = Character:FindFirstChild("HumanoidRootPart")

	if not HRP or not EggPosition then
		return false
	end

	HRP.CFrame = CFrame.new(
		EggPosition.X,
		39771.2422,
		EggPosition.Z
	)

	return true
end

local function WaitForEggPickup(Egg, Timeout)

	Timeout = Timeout or 5

	local StartTime = os.clock()

	while Egg and Egg.Parent == RenderedEggs do

		if (os.clock() - StartTime) >= Timeout then
			break
		end

		task.wait(0.1)
	end
end

--==================================================
-- ESP SYSTEM
--==================================================

local ActiveESP = {}

local function RemoveESP(Egg)

	if ActiveESP[Egg] then

		if ActiveESP[Egg].Billboard then
			ActiveESP[Egg].Billboard:Destroy()
		end

		ActiveESP[Egg] = nil
	end
end

local function ClearAllESP()

	for Egg, _ in pairs(ActiveESP) do
		RemoveESP(Egg)
	end
end

local function CreateESP(Egg)

	if ActiveESP[Egg] then
		return
	end

	local EggPart = GetEggPart(Egg)

	if not EggPart then
		return
	end

	local Billboard = Instance.new("BillboardGui")

	Billboard.Name = "LunaEggESP"
	Billboard.Adornee = EggPart
	Billboard.Size = UDim2.new(0, 200, 0, 50)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Parent = EggPart

	local TextLabel = Instance.new("TextLabel")

	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextStrokeTransparency = 0
	TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.TextSize = 16
	TextLabel.Text = Egg.Name .. "\n[0m]"
	TextLabel.Parent = Billboard

	ActiveESP[Egg] = {
		Billboard = Billboard,
		TextLabel = TextLabel,
		Part = EggPart
	}
end

RunService.RenderStepped:Connect(function()

	if not ESPEnabled then
		ClearAllESP()
		return
	end

	local Character = GetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

	for Egg, _ in pairs(ActiveESP) do

		if not Egg
			or not Egg.Parent
			or Egg.Parent ~= RenderedEggs then

			RemoveESP(Egg)
		end
	end

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do

		local Name = Egg.Name
		local IsSelected = false

		if type(SelectedESPEggs) == "table" then

			for _, SelectedName in ipairs(SelectedESPEggs) do

				if SelectedName == Name then
					IsSelected = true
					break
				end
			end

		elseif SelectedESPEggs == Name then
			IsSelected = true
		end

		if IsSelected then

			if not ActiveESP[Egg] then
				CreateESP(Egg)
			end

			if ActiveESP[Egg]
				and HRP
				and ActiveESP[Egg].Part then

				local Dist = math.floor(
					(HRP.Position - ActiveESP[Egg].Part.Position).Magnitude
				)

				ActiveESP[Egg].TextLabel.Text =
					string.format("%s\n[%dm]", Name, Dist)
			end

		else
			RemoveESP(Egg)
		end
	end
end)

--==================================================
-- AUTOMATION LOOPS
--==================================================

--==================================================
-- AUTO BUY GEAR LOOP
--==================================================
task.spawn(function()

	while true do

		if Autobuygear and ShopStockReady then

			pcall(function()

				if type(SelectedGear) == "table" then

					for _, GearItem in ipairs(SelectedGear) do

						if not Autobuygear then
							break
						end

						local Stock =
							GetShopStock("Gears", GearItem)

						-- ONLY FIRE WHEN STOCK EXISTS
						if Stock > 0 then

							BuyWithCash:FireServer(
								"Gears",
								GearItem
							)

							-- Prevent repeated firing
							-- before server sends next stock update
							ReduceShopStock(
								"Gears",
								GearItem
							)

							task.wait(0.2)
						end

					end

				elseif type(SelectedGear) == "string"
					and SelectedGear ~= "" then

					local Stock =
						GetShopStock(
							"Gears",
							SelectedGear
						)

					if Stock > 0 then

						BuyWithCash:FireServer(
							"Gears",
							SelectedGear
						)

						ReduceShopStock(
							"Gears",
							SelectedGear
						)

					end
				end

			end)

		end

		task.wait(0.5)

	end

end)

--==================================================
-- AUTO BUY FOOD LOOP
--==================================================

task.spawn(function()

	while true do

		if Autobuyfood and ShopStockReady then

			pcall(function()

				if type(SelectedFood) == "table" then

					for _, FoodItem in ipairs(SelectedFood) do

						if not Autobuyfood then
							break
						end

						local Stock =
							GetShopStock(
								"Food",
								FoodItem
							)

						-- ONLY FIRE WHEN STOCK EXISTS
						if Stock > 0 then

							BuyWithCash:FireServer(
								"Food",
								FoodItem
							)

							-- Prevent repeated firing
							-- before server sends next stock update
							ReduceShopStock(
								"Food",
								FoodItem
							)

							task.wait(0.2)
						end

					end

				elseif type(SelectedFood) == "string"
					and SelectedFood ~= "" then

					local Stock =
						GetShopStock(
							"Food",
							SelectedFood
						)

					if Stock > 0 then

						BuyWithCash:FireServer(
							"Food",
							SelectedFood
						)

						ReduceShopStock(
							"Food",
							SelectedFood
						)

					end
				end

			end)

		end

		task.wait(0.5)

	end

end)

--==================================================
-- AUTO PLACE EGG LOOP
--==================================================

local MAX_PLANTED_EGGS = 10

local function GetRandomPlotPosition(Baseplate)
    if not Baseplate or not Baseplate:IsA("BasePart") then
        return nil
    end

    local Size = Baseplate.Size
    local Position = Baseplate.Position

    local MarginX = math.min(3, Size.X / 4)
    local MarginZ = math.min(3, Size.Z / 4)

    local MinX = Position.X - (Size.X / 2) + MarginX
    local MaxX = Position.X + (Size.X / 2) - MarginX

    local MinZ = Position.Z - (Size.Z / 2) + MarginZ
    local MaxZ = Position.Z + (Size.Z / 2) - MarginZ

    local RandomX =
        MinX + math.random() * (MaxX - MinX)

    local RandomZ =
        MinZ + math.random() * (MaxZ - MinZ)

    local Y =
        Position.Y
        + (Size.Y / 2)
        + 1.5

    return Vector3.new(RandomX, Y, RandomZ)
end

task.spawn(function()

    while true do

        if AutoPlaceEgg then

            pcall(function()

                local EggList =
                    type(SelectedPlaceEgg) == "table"
                    and SelectedPlaceEgg
                    or (
                        SelectedPlaceEgg ~= ""
                        and {SelectedPlaceEgg}
                        or {}
                    )

                if #EggList == 0 then
                    return
                end

                local Character = GetCharacter()

                local Humanoid =
                    Character
                    and Character:FindFirstChildOfClass("Humanoid")

                local Backpack =
                    Player:FindFirstChild("Backpack")

                if not Character or not Humanoid then
                    return
                end


                --==================================================
                -- FIND YOUR OWN PLOT
                --==================================================

                local Plots =
                    workspace:FindFirstChild("Plots")

                local MyPlot = nil

                if Plots then

                    for _, Plot in ipairs(Plots:GetChildren()) do

                        local NestsOwnerLoaded =
                            Plot:GetAttribute("NestsOwnerLoaded")

                        if NestsOwnerLoaded == Player.UserId then

                            MyPlot = Plot
                            break
                        end

                        local Owner =
                            Plot:GetAttribute("Owner")

                        local OwnerUserId =
                            Plot:GetAttribute("OwnerUserId")

                        local UserId =
                            Plot:GetAttribute("UserId")

                        if Owner == Player.Name
                            or Owner == Player.UserId
                            or OwnerUserId == Player.UserId
                            or UserId == Player.UserId then

                            MyPlot = Plot
                            break
                        end
                    end
                end

                if not MyPlot then
                    return
                end


                --==================================================
                -- CHECK CURRENT PLANTED EGGS
                --==================================================

                local EggsFolder =
                    MyPlot:FindFirstChild("Eggs")

                local EggCount = 0

                if EggsFolder then
                    EggCount = #EggsFolder:GetChildren()
                end


                --==================================================
                -- STOP WHEN 10 EGGS ARE PLANTED
                --==================================================

                if EggCount >= MAX_PLANTED_EGGS then
                    return
                end


                --==================================================
                -- GET BASEPLATE
                --==================================================

                local Baseplate =
                    MyPlot:FindFirstChild("Baseplate")

                if not Baseplate
                    or not Baseplate:IsA("BasePart") then

                    return
                end


                --==================================================
                -- GET EGG REMOTE
                --==================================================

                local Remotes =
                    ReplicatedStorage:FindFirstChild("Remotes")

                local GameRemotes =
                    Remotes
                    and Remotes:FindFirstChild("Game")

                local EggPlacedRemote =
                    GameRemotes
                    and GameRemotes:FindFirstChild("EggPlaced")

                if not EggPlacedRemote then
                    return
                end


                --==================================================
                -- EQUIP + PLACE SELECTED EGGS
                --==================================================

                for _, EggName in ipairs(EggList) do

                    -- Re-check capacity BEFORE EVERY EGG
                    EggsFolder =
                        MyPlot:FindFirstChild("Eggs")

                    EggCount = 0

                    if EggsFolder then
                        EggCount = #EggsFolder:GetChildren()
                    end

                    if EggCount >= MAX_PLANTED_EGGS then
                        break
                    end


                    local HeldTool =
                        Character:FindFirstChildOfClass("Tool")

                    local TargetEggTool = nil


                    --==================================================
                    -- ALREADY EQUIPPED
                    --==================================================

                    if HeldTool
                        and HeldTool.Name == EggName then

                        TargetEggTool = HeldTool

                    else

                        --==================================================
                        -- FIND EGG IN BACKPACK
                        --==================================================

                        if Backpack then

                            TargetEggTool =
                                Backpack:FindFirstChild(EggName)

                        end


                        --==================================================
                        -- EQUIP EGG
                        --==================================================

                        if TargetEggTool then

                            Humanoid:EquipTool(TargetEggTool)

                            task.wait(0.1)

                            local NewHeldTool =
                                Character:FindFirstChildOfClass("Tool")

                            if NewHeldTool
                                and NewHeldTool.Name == EggName then

                                TargetEggTool = NewHeldTool
                            end
                        end
                    end


                    --==================================================
                    -- PLACE EGG
                    --==================================================

                    if TargetEggTool then

                        local PlantPosition =
                            GetRandomPlotPosition(Baseplate)

                        if PlantPosition then

                            EggPlacedRemote:FireServer({
                                PlantPosition = PlantPosition
                            })

                            task.wait(0.35)
                        end
                    end
                end

            end)

            task.wait(0.3)

        else

            task.wait(0.5)

        end
    end
end)

--==================================================
-- AUTO HATCH EGG LOOP
--==================================================

task.spawn(function()

	while true do

		if AutoHatchEgg then

			pcall(function()

				local Remotes =
					ReplicatedStorage:FindFirstChild("Remotes")

				local GameRemotes =
					Remotes
					and Remotes:FindFirstChild("Game")

				local HatchRemote =
					GameRemotes
					and GameRemotes:FindFirstChild("Hatch")

				if HatchRemote then

					local Plots =
						workspace:FindFirstChild("Plots")

					if Plots then

						for _, Plot in ipairs(Plots:GetChildren()) do

							local EggsFolder =
								Plot:FindFirstChild("Eggs")

							if EggsFolder then

								for _, EggModel in ipairs(EggsFolder:GetChildren()) do

									local Handle =
										EggModel:FindFirstChild("Handle")

									local HatchObj =
										Handle
										and Handle:FindFirstChild("Hatch")

									local EggData =
										EggModel:FindFirstChild("EggData")

									local Key = nil

									if EggData then

										Key =
											EggData:GetAttribute("EggKey")
											or (
												EggData:FindFirstChild("EggKey")
												and EggData.EggKey.Value
											)
									end

									if not Key then

										Key =
											EggModel:GetAttribute("EggKey")
											or (
												EggModel:FindFirstChild("EggKey")
												and EggModel.EggKey.Value
											)
									end

									local CanHatch = false

									if HatchObj then

										if HatchObj:IsA("ProximityPrompt") then

											CanHatch = HatchObj.Enabled

										elseif HatchObj:IsA("ValueBase") then

											CanHatch = HatchObj.Value

										elseif HatchObj:IsA("GuiObject")
											or HatchObj:IsA("LayerCollector") then

											CanHatch =
												HatchObj.Enabled
												or HatchObj.Visible

										elseif HatchObj:GetAttribute("Enabled") ~= nil then

											CanHatch =
												HatchObj:GetAttribute("Enabled")

										else

											CanHatch = true
										end
									end

									if Key and CanHatch then

										HatchRemote:FireServer({
											EggKey = tostring(Key)
										})

										task.wait(0.2)
									end
								end
							end
						end
					end
				end
			end)

			task.wait(0.5)

		else
			task.wait(0.5)
		end
	end
end)


--==================================================
-- AUTO EQUIP BEST PET
--==================================================

--==================================================
-- AUTO EQUIP + PLACE BEST PET
--==================================================

local PlacePet =
	ReplicatedStorage
		:WaitForChild("Remotes")
		:WaitForChild("Game")
		:WaitForChild("PlacePet")

local General_m =
	require(
		ReplicatedStorage
			:WaitForChild("GameServices")
			:WaitForChild("General")
	)

local AutoPetBusy = false
local LastPetPlace = 0


--==================================================
-- GET OWN PLOT
--==================================================

local function GetOwnPlot()

	local Plot = General_m:GetPlot(Player)

	if not Plot then
		return nil
	end

	local Baseplate =
		Plot:FindFirstChild("Baseplate")

	if not Baseplate then
		return nil
	end

	return Plot, Baseplate
end


--==================================================
-- FIND BEST PET
--==================================================

local function FindBestPetTool()

	local Character =
		Player.Character

	local Backpack =
		Player:FindFirstChildOfClass("Backpack")

	local BestPet = nil
	local BestIncome = -math.huge

	for _, Container in ipairs({
		Character,
		Backpack
	}) do

		if Container then

			for _, Tool in ipairs(Container:GetChildren()) do

				if Tool:IsA("Tool")
					and Tool:HasTag("Pet")
					and Tool:GetAttribute("PetKey") then

					local Income =
						GetPetIncome(Tool)

					if Income > BestIncome then

						BestIncome = Income
						BestPet = Tool

					end
				end
			end
		end
	end

	return BestPet
end


--==================================================
-- PLACE BEST PET
--==================================================

local function AutoPlaceBestPet()

	if AutoPetBusy then
		return
	end

	AutoPetBusy = true

	pcall(function()

		local Character =
			Player.Character

		local Humanoid =
			Character
			and Character:FindFirstChildOfClass("Humanoid")

		local HRP =
			Character
			and Character:FindFirstChild("HumanoidRootPart")

		if not Character
			or not Humanoid
			or not HRP then

			return
		end


		--==================================================
		-- OWN PLOT
		--==================================================

		local MyPlot, Baseplate =
			GetOwnPlot()

		if not MyPlot or not Baseplate then
			return
		end


		--==================================================
		-- BEST PET
		--==================================================

		local BestPet =
			FindBestPetTool()

		if not BestPet then
			return
		end


		local PetKey =
			BestPet:GetAttribute("PetKey")

		if not PetKey then
			return
		end


		--==================================================
		-- TELEPORT INSIDE OWN PLOT
		--==================================================

		local OldCFrame =
			HRP.CFrame

		local PlotCFrame =
			Baseplate.CFrame

		HRP.CFrame =
			PlotCFrame
			* CFrame.new(
				0,
				Baseplate.Size.Y / 2 + 3,
				0
			)

		task.wait(0.3)


		--==================================================
		-- EQUIP
		--==================================================

		if BestPet.Parent ~= Character then

			Humanoid:EquipTool(BestPet)

			task.wait(0.25)

		end


		--==================================================
		-- VERIFY PET IS ACTUALLY HELD
		--==================================================

		local HeldPet = nil

		for _, Tool in ipairs(Character:GetChildren()) do

			if Tool:IsA("Tool")
				and Tool:HasTag("Pet")
				and Tool:GetAttribute("PetKey") then

				HeldPet = Tool
				break

			end
		end

		if not HeldPet then

			HRP.CFrame = OldCFrame
			return

		end


		PetKey =
			HeldPet:GetAttribute("PetKey")

		if not PetKey then

			HRP.CFrame = OldCFrame
			return

		end


		--==================================================
		-- EXACT SAME POSITION AS GAME
		--==================================================

		local Position =
			(
				HRP.CFrame
				* CFrame.new(0, 0, -5)
			).Position


		--==================================================
		-- SAME REMOTE CALL AS GAME
		--==================================================

		if os.clock() - LastPetPlace >= 0.4 then

			LastPetPlace =
				os.clock()

			PlacePet:FireServer(
				PetKey,
				Position
			)

			task.wait(0.5)

		end


		--==================================================
		-- UNEQUIP
		--==================================================

		Humanoid:UnequipTools()

		task.wait(0.1)


		--==================================================
		-- RETURN
		--==================================================

		if HRP and HRP.Parent then
			HRP.CFrame = OldCFrame
		end

	end)

	AutoPetBusy = false
end


--==================================================
-- LOOP
--==================================================

task.spawn(function()

	while true do

		if AutoEquipBestPet then

			AutoPlaceBestPet()

		end

		task.wait(0.5)

	end

end)

--==================================================
-- AUTO UPGRADE HATCH LUCK
--==================================================

task.spawn(function()

	while true do

		if AutoUpgradeHatchLuck then

			pcall(function()

				local Remotes =
					ReplicatedStorage:FindFirstChild("Remotes")

				local GameRemotes =
					Remotes
					and Remotes:FindFirstChild("Game")

				local PlotFolder =
					GameRemotes
					and GameRemotes:FindFirstChild("Plot")

				local UpgradesRemote =
					PlotFolder
					and PlotFolder:FindFirstChild("Upgrades")

				if UpgradesRemote then
					UpgradesRemote:FireServer(
						"Hatch Luck",
						1
					)
				end
			end)

			task.wait(0.5)

		else
			task.wait(0.5)
		end
	end
end)

--==================================================
-- AUTO UPGRADE HATCH LUCK MAX
--==================================================

task.spawn(function()

	while true do

		if AutoUpgradeHatchLuckMax then

			pcall(function()

				local Remotes =
					ReplicatedStorage:FindFirstChild("Remotes")

				local GameRemotes =
					Remotes
					and Remotes:FindFirstChild("Game")

				local PlotFolder =
					GameRemotes
					and GameRemotes:FindFirstChild("Plot")

				local UpgradesRemote =
					PlotFolder
					and PlotFolder:FindFirstChild("Upgrades")

				if UpgradesRemote then
					UpgradesRemote:FireServer("Max")
				end
			end)

			task.wait(5)

		else
			task.wait(0.5)
		end
	end
end)

--==================================================
-- AUTO REBIRTH LOOP
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local LocalPlayer = Players.LocalPlayer
local SavedData = LocalPlayer:WaitForChild("SavedData")
local Cash = SavedData:WaitForChild("Cash")
local Rebirths = SavedData:WaitForChild("Rebirths")

local Rebirths_m = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Rebirths"))
local General_m = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local PetRenderer_m = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))

local function CanRebirth()
	local maxCap = tonumber(Rebirths_m.Cap)
	if maxCap and Rebirths.Value >= maxCap then
		return false
	end

	local currentCost = Rebirths_m.GetCost(Rebirths.Value)
	if Cash.Value < currentCost then
		return false
	end

	local nextIndex = Rebirths.Value + 1
	local reqList = General_m.RebirthRequirements
	local requiredPet = reqList[math.clamp(nextIndex, 1, math.max(#reqList, 1))]

	if not requiredPet then 
		return true -- Direct pass kung walang pet requirement
	end

	for _, val in pairs(PetRenderer_m.GetAll()) do
		if val.OwnerUserId == LocalPlayer.UserId and (val.Model.Parent and val.Model.Name == requiredPet) then
			return true
		end
	end

	local function ScanContainer(container)
		if not container then return false end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("PetKey") then
				local petName = string.match(child.Name, "^(.-) %[") or child.Name
				if petName == requiredPet then
					return true
				end
			end
		end
		return false
	end

	if ScanContainer(LocalPlayer:FindFirstChildOfClass("Backpack")) or ScanContainer(LocalPlayer.Character) then
		return true
	end

	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local mountJoint = hrp and hrp:FindFirstChild("PetMountJoint")
	local mountedPart = mountJoint and (mountJoint.Part1 and mountJoint.Part1.Parent)

	if mountedPart and mountedPart:GetAttribute("PetName") == requiredPet then
		return true
	end

	return false
end

task.spawn(function()
	while true do
		if AutoRebirth then
			pcall(function()
				if CanRebirth() then
					local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
					local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
					local RebirthRemote = GameRemotes and GameRemotes:FindFirstChild("Rebirth")

					if RebirthRemote then
						RebirthRemote:FireServer()
						print("[AutoRebirth] Rebirth Remote Fired!")
					end
				end
			end)
			task.wait(2) -- Pwede mo babaan o taasan ang wait interval
		else
			task.wait(0.5)
		end
	end
end)

--==================================================
-- AUTO CLAIM INDEX REWARD
--==================================================

local ClaimIndexReward =
	ReplicatedStorage
		:WaitForChild("Remotes")
		:WaitForChild("Game")
		:WaitForChild("ClaimIndexReward")

local IndexRewards =
	require(
		ReplicatedStorage
			:WaitForChild("GameData")
			:WaitForChild("IndexRewards")
	)

local SavedDataIndex =
	Player:WaitForChild("SavedData")

local OwnedPetsIndex =
	SavedDataIndex:WaitForChild("OwnedPets")

local IndexRewardStage =
	SavedDataIndex:WaitForChild("IndexRewardStage")


local function CanClaimIndexReward()

	local success, result = pcall(function()

		local discovered =
			IndexRewards.DiscoveredCount(
				OwnedPetsIndex.Value
			)

		local stage =
			IndexRewards.StageAt(
				IndexRewardStage.Value
			)

		if not stage then
			return false
		end

		return discovered >= stage.Goal

	end)

	return success and result == true
end


task.spawn(function()

	while true do

		if AutoClaimIndex then

			if CanClaimIndexReward() then

				pcall(function()
					ClaimIndexReward:FireServer()
				end)

				task.wait(1)
			end

		end

		task.wait(0.5)

	end

end)

--==================================================
-- AUTO FARM LOOP
--==================================================

task.spawn(function()

	while true do

		if AutoPickup then

			local Egg = FindSelectedEgg()

			if Egg then

				local EggPart = GetEggPart(Egg)
				local EggPosition =
					EggPart
					and EggPart.Position

				if TeleportToEgg(Egg) then

					task.wait(1)

					PickupEgg(Egg)

					WaitForEggPickup(Egg, 3)

					if EggPosition then
						TeleportToEggVoid(EggPosition)
					end

					task.wait(2)

				else
					task.wait(0.1)
				end

			else
				task.wait(0.2)
			end

		else
			task.wait(0.2)
		end

		task.wait(0.03)
	end
end)
