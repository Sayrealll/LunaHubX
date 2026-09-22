--AUTO HATCH, AUTO CLAIM OFFLINE, AUTO BUY GEAR & FOOD

--// SERVICES

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))

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

--// SETTINGS

local ThemeName = "Dark"

-- MULTI-SELECT TABLES
local SelectedEggs = {}
local SelectedESPEggs = {}
local SelectedGear = {}
local SelectedFood = {}

local SelectedPlaceEgg = ""

-- TOGGLES
local AutoPickup = false
local AutoPlaceEgg = false
local AutoHatchEgg = false
local AutoClaimIndex = false
local AutoUpgradeHatchLuck = false
local AutoUpgradeHatchLuckMax = false
local AutoRebirth = false
local ESPEnabled = false
local Autobuygear = false
local Autobuyfood = false

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
	Icon = "dog",
	Theme = ThemeName,

	ToggleKey = Enum.KeyCode.F,
	OpenButton = { Enabled = true, OnlyMobile = false }, 
})

Window:Tag({
	Title = "v.1.0.2.6",
	Color = "ElementBackground",
})

--==================================================
-- TABS
--==================================================

local Tab1 = Window:Tab({ Title = "HOME", Icon = "warehouse" })
local Tab2 = Window:Tab({ Title = "FARM", Icon = "egg" })
local Tab3 = Window:Tab({ Title = "SHOP", Icon = "shopping-cart" })
local Tab4 = Window:Tab({ Title = "VISUAL", Icon = "eye" })
local Tab5 = Window:Tab({ Title = "EGGS", Icon = "list-ordered" })
local Tab6 = Window:Tab({ Title = "INFO", Icon = "badge-info" })

--==================================================
-- TAB 1 (HOME)
--==================================================

Tab1:Paragraph({
	Title = "Discord    ",
	Desc = "Join our Discord Community",
	Buttons = {
		{
			Title = "Discord",
			Callback = function()
				local DiscordLink = "discord.gg/Ev8k5RAU3"
				if setclipboard then
					setclipboard(DiscordLink)
					print("Discord link copied")
				end
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

EggSection:Dropdown({
	Title = "Select Egg",
	Desc = "Choose which eggs to auto farm",
	Values = EggNames,
	Multi = true,
	Value = {},
	Callback = function(value)
		SelectedEggs = value
	end,
})

EggSection:Toggle({
	Title = "Auto Farm",
	Desc = "Automatic to get the egg and proceed to your plot",
	Value = false,
	Callback = function(value)
		AutoPickup = value
	end,
})

EggSection:Dropdown({
	Title = "Select egg to Auto Place",
	Desc = "Choose which egg to place ( Go to your plot )",
	Values = EggNames,
	Multi = false,
	Value = "",
	Callback = function(value)
		SelectedPlaceEgg = value
	end,
})

EggSection:Toggle({
	Title = "Auto Place Eggs",
	Desc = "Automatically equip and place the selected eggs",
	Value = false,
	Callback = function(value)
		AutoPlaceEgg = value
	end,
})

EggSection:Toggle({
	Title = "Auto Hatch Egg",
	Desc = "Automatically hatch ready eggs in your plot",
	Value = false,
	Callback = function(value)
		AutoHatchEgg = value
	end,
})

EggSection:Toggle({
	Title = "Auto Upgrade Hatch Luck",
	Desc = "Auto upgrade hatch luck by 1x",
	Value = false,
	Callback = function(value)
		AutoUpgradeHatchLuck = value
	end,
})

EggSection:Toggle({
	Title = "Auto Upgrade Hatch Luck (Max)",
	Desc = "Auto upgrade hatch luck by Max",
	Value = false,
	Callback = function(value)
		AutoUpgradeHatchLuckMax = value
	end,
})

EggSection:Toggle({
	Title = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		AutoRebirth = value
	end,
})

EggSection:Toggle({
	Title = "Auto Claim Index Reward",
	Value = false,
	Callback = function(value)
		AutoClaimIndex = value
	end,
})

EggSection:Toggle({
	Title = "Auto Claim Offline Earnings",
	Value = false,
	Callback = function(value)
		if value then
			-- 1. Direct Remote Fire
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local OfflineRemote = GameRemotes and GameRemotes:FindFirstChild("OfflineEarnings")

				if OfflineRemote then
					OfflineRemote:FireServer()
				end
			end)

			-- 2. Force Click Screen UI Button
			pcall(function()
				local PlayerGui = Player:FindFirstChild("PlayerGui")
				if PlayerGui then
					for _, GuiObject in ipairs(PlayerGui:GetDescendants()) do
						if (GuiObject:IsA("TextButton") or GuiObject:IsA("ImageButton")) and GuiObject.Visible then
							local Text = (GuiObject:IsA("TextButton") and GuiObject.Text) or ""
							if GuiObject.Name:lower():find("1x") or Text:lower():find("1x") or GuiObject.Name:lower():find("claim") or Text:lower():find("claim") then
								
								if getconnections then
									for _, conn in ipairs(getconnections(GuiObject.Activated)) do
										conn:Fire()
									end
									for _, conn in ipairs(getconnections(GuiObject.MouseButton1Click)) do
										conn:Fire()
									end
								end

								local Frame = GuiObject:FindFirstAncestorWhichIsA("Frame") or GuiObject:FindFirstAncestorWhichIsA("ScreenGui")
								if Frame and Frame.Name:lower():find("offline") then
									Frame.Visible = false
								end
							end
						end
					end
				end
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

ShopSection:Dropdown({
	Title = "Select Radars",
	Values = GearShop,
	Multi = true,
	Value = {},
	Callback = function(value)
		SelectedGear = value
	end,
})

ShopSection:Toggle({
	Title = "Auto Buy Gears",
	Desc = "Automatic to buy selected gears",
	Value = false,
	Callback = function(value)
		Autobuygear = value
	end,
})

local ShopSection1 = Tab3:Section({
	Title = "Food Shop",
	Icon = "apple",
	Box = true,
	BoxBorder = true,
})

ShopSection1:Dropdown({
	Title = "Select Food",
	Values = FoodShop,
	Multi = true,
	Value = {},
	Callback = function(value)
		SelectedFood = value
	end,
})

ShopSection1:Toggle({
	Title = "Auto Buy Foods",
	Desc = "Automatic to buy selected Food",
	Value = false,
	Callback = function(value)
		Autobuyfood = value
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

VisualSection:Dropdown({
	Title = "Select ESP Egg",
	Desc = "Choose which eggs to display ESP",
	Values = EggNames,
	Multi = true,
	Value = {},
	Callback = function(value)
		SelectedESPEggs = value
	end,
})

VisualSection:Toggle({
	Title = "Egg ESP",
	Desc = "Enable ESP and Distance for selected eggs",
	Value = false,
	Callback = function(value)
		ESPEnabled = value
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
			DescriptionText = DescriptionText .. string.format("• %s (x%d)\n", Name, Count)
		end

		LiveEggParagraph:SetTitle(string.format("Spawned Eggs (%d)", TotalCount))
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
-- HELPER FUNCTIONS
--==================================================

local function GetCharacter()
	local Character = Player.Character
	if not Character then return nil end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HRP then return nil end
	return Character
end

local function GetEggPart(Egg)
	if not Egg then return nil end
	if Egg:IsA("BasePart") then return Egg end
	if Egg:IsA("Model") then
		if Egg.PrimaryPart then return Egg.PrimaryPart end
		local Pickup = Egg:FindFirstChild("Pickup", true)
		if Pickup and Pickup:IsA("ProximityPrompt") and Pickup.Parent:IsA("BasePart") then
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
	if not Egg then return false end
	pcall(function()
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
		if GameRemotes then
			local PickupRemote = GameRemotes:FindFirstChild("PickupEgg") or GameRemotes:FindFirstChild("ClaimEgg") or GameRemotes:FindFirstChild("CollectEgg")
			if PickupRemote then PickupRemote:FireServer(Egg) end
		end
	end)

	for _, Descendant in ipairs(Egg:GetDescendants()) do
		if Descendant:IsA("ProximityPrompt") then
			if typeof(fireproximityprompt) == "function" then
				pcall(function() fireproximityprompt(Descendant) end)
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
	if not Character then return false end
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	local EggPart = GetEggPart(Egg)
	if not HRP or not EggPart then return false end
	HRP.CFrame = EggPart.CFrame * CFrame.new(0, 1.5, 0)
	return true
end

local function TeleportToEggVoid(EggPosition)
	local Character = GetCharacter()
	if not Character then return false end
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP or not EggPosition then return false end
	HRP.CFrame = CFrame.new(EggPosition.X, 39771.2422, EggPosition.Z)
	return true
end

local function WaitForEggPickup(Egg, Timeout)
	Timeout = Timeout or 5
	local StartTime = os.clock()
	while Egg and Egg.Parent == RenderedEggs do
		if (os.clock() - StartTime) >= Timeout then break end
		task.wait(0.1)
	end
end

--==================================================
-- ESP SYSTEM
--==================================================

local ActiveESP = {}

local function RemoveESP(Egg)
	if ActiveESP[Egg] then
		if ActiveESP[Egg].Billboard then ActiveESP[Egg].Billboard:Destroy() end
		ActiveESP[Egg] = nil
	end
end

local function ClearAllESP()
	for Egg, _ in pairs(ActiveESP) do RemoveESP(Egg) end
end

local function CreateESP(Egg)
	if ActiveESP[Egg] then return end
	local EggPart = GetEggPart(Egg)
	if not EggPart then return end

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

	ActiveESP[Egg] = { Billboard = Billboard, TextLabel = TextLabel, Part = EggPart }
end

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then ClearAllESP() return end
	local Character = GetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

	for Egg, _ in pairs(ActiveESP) do
		if not Egg or not Egg.Parent or Egg.Parent ~= RenderedEggs then RemoveESP(Egg) end
	end

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name
		local IsSelected = false
		if type(SelectedESPEggs) == "table" then
			for _, SelectedName in ipairs(SelectedESPEggs) do
				if SelectedName == Name then IsSelected = true break end
			end
		elseif SelectedESPEggs == Name then
			IsSelected = true
		end

		if IsSelected then
			if not ActiveESP[Egg] then CreateESP(Egg) end
			if ActiveESP[Egg] and HRP and ActiveESP[Egg].Part then
				local Dist = math.floor((HRP.Position - ActiveESP[Egg].Part.Position).Magnitude)
				ActiveESP[Egg].TextLabel.Text = string.format("%s\n[%dm]", Name, Dist)
			end
		else
			RemoveESP(Egg)
		end
	end
end)

--==================================================
-- AUTOMATION LOOPS
--==================================================

-- AUTO BUY GEAR LOOP
task.spawn(function()
	while true do
		if Autobuygear then
			pcall(function()
				local BuyRemote = ReplicatedStorage:FindFirstChild("Remotes")
					and ReplicatedStorage.Remotes:FindFirstChild("Game")
					and ReplicatedStorage.Remotes.Game:FindFirstChild("BuyWithCash")

				if BuyRemote then
					if type(SelectedGear) == "table" then
						for _, GearItem in ipairs(SelectedGear) do
							BuyRemote:FireServer("Gears", GearItem)
							task.wait(0.2)
						end
					elseif type(SelectedGear) == "string" and SelectedGear ~= "" then
						BuyRemote:FireServer("Gears", SelectedGear)
					end
				end
			end)
			task.wait(0.5)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO BUY FOOD LOOP
task.spawn(function()
	while true do
		if Autobuyfood then
			pcall(function()
				local BuyRemote = ReplicatedStorage:FindFirstChild("Remotes")
					and ReplicatedStorage.Remotes:FindFirstChild("Game")
					and ReplicatedStorage.Remotes.Game:FindFirstChild("BuyWithCash")

				if BuyRemote then
					if type(SelectedFood) == "table" then
						for _, FoodItem in ipairs(SelectedFood) do
							BuyRemote:FireServer("Food", FoodItem)
							task.wait(0.2)
						end
					elseif type(SelectedFood) == "string" and SelectedFood ~= "" then
						BuyRemote:FireServer("Food", SelectedFood)
					end
				end
			end)
			task.wait(0.5)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO PLACE EGG LOOP
task.spawn(function()
	while true do
		if AutoPlaceEgg then
			pcall(function()
				if SelectedPlaceEgg == "" or SelectedPlaceEgg == nil then return end
				local Character = GetCharacter()
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
				local Backpack = Player:FindFirstChild("Backpack")

				if Character and Humanoid and HRP then
					local HeldTool = Character:FindFirstChildOfClass("Tool")
					local TargetEggTool = nil
					if HeldTool and HeldTool.Name == SelectedPlaceEgg then
						TargetEggTool = HeldTool
					else
						if Backpack then TargetEggTool = Backpack:FindFirstChild(SelectedPlaceEgg) end
						if TargetEggTool then
							Humanoid:EquipTool(TargetEggTool)
							task.wait(0.1)
						end
					end

					if TargetEggTool or (HeldTool and HeldTool.Name == SelectedPlaceEgg) then
						local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
						local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
						local EggPlacedRemote = GameRemotes and GameRemotes:FindFirstChild("EggPlaced")
						if EggPlacedRemote then
							local CurrentPos = HRP.Position
							local args = {
								{
									PlantPosition = Vector3.new(CurrentPos.X, CurrentPos.Y - 2, CurrentPos.Z),
									Egg = SelectedPlaceEgg,
									EggName = SelectedPlaceEgg
								}
							}
							EggPlacedRemote:FireServer(unpack(args))
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

-- AUTO HATCH EGG LOOP
task.spawn(function()
	while true do
		if AutoHatchEgg then
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local HatchRemote = GameRemotes and GameRemotes:FindFirstChild("Hatch")

				if HatchRemote then
					local Plots = workspace:FindFirstChild("Plots")
					if Plots then
						for _, Plot in ipairs(Plots:GetChildren()) do
							local EggsFolder = Plot:FindFirstChild("Eggs")
							if EggsFolder then
								for _, EggModel in ipairs(EggsFolder:GetChildren()) do
									local Handle = EggModel:FindFirstChild("Handle")
									local HatchObj = Handle and Handle:FindFirstChild("Hatch")
									local EggData = EggModel:FindFirstChild("EggData")
									
									local Key = nil
									if EggData then
										Key = EggData:GetAttribute("EggKey") 
											or (EggData:FindFirstChild("EggKey") and EggData.EggKey.Value)
									end
									if not Key then
										Key = EggModel:GetAttribute("EggKey") 
											or (EggModel:FindFirstChild("EggKey") and EggModel.EggKey.Value)
									end

									local CanHatch = false

									if HatchObj then
										if HatchObj:IsA("ProximityPrompt") then
											CanHatch = HatchObj.Enabled
										elseif HatchObj:IsA("ValueBase") then
											CanHatch = HatchObj.Value
										elseif HatchObj:IsA("GuiObject") or HatchObj:IsA("LayerCollector") then
											CanHatch = HatchObj.Enabled or HatchObj.Visible
										elseif HatchObj:GetAttribute("Enabled") ~= nil then
											CanHatch = HatchObj:GetAttribute("Enabled")
										else
											CanHatch = true
										end
									end

									if Key and CanHatch then
										HatchRemote:FireServer({ EggKey = tostring(Key) })
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

-- AUTO UPGRADE HATCH LUCK
task.spawn(function()
	while true do
		if AutoUpgradeHatchLuck then
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local PlotFolder = GameRemotes and GameRemotes:FindFirstChild("Plot")
				local UpgradesRemote = PlotFolder and PlotFolder:FindFirstChild("Upgrades")
				if UpgradesRemote then UpgradesRemote:FireServer("Hatch Luck", 1) end
			end)
			task.wait(0.5)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO UPGRADE HATCH LUCK MAX
task.spawn(function()
	while true do
		if AutoUpgradeHatchLuckMax then
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local PlotFolder = GameRemotes and GameRemotes:FindFirstChild("Plot")
				local UpgradesRemote = PlotFolder and PlotFolder:FindFirstChild("Upgrades")
				if UpgradesRemote then UpgradesRemote:FireServer("Max") end
			end)
			task.wait(5)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO REBIRTH LOOP
task.spawn(function()
	while true do
		if AutoRebirth then
			pcall(function()
				local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local RebirthRemote = GameRemotes and GameRemotes:FindFirstChild("Rebirth")
				if RebirthRemote then RebirthRemote:FireServer() end
			end)
			task.wait(7)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO FARM LOOP
task.spawn(function()
	while true do
		if AutoPickup then
			local Egg = FindSelectedEgg()
			if Egg then
				local EggPart = GetEggPart(Egg)
				local EggPosition = EggPart and EggPart.Position
				if TeleportToEgg(Egg) then
					task.wait(1)
					PickupEgg(Egg)
					WaitForEggPickup(Egg, 3)
					if EggPosition then TeleportToEggVoid(EggPosition) end
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
