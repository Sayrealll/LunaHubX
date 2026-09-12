
--teeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeewewewe



-- ============================================================
-- ============================================================
-- ============================================================
--RUNNING BYPASS
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
local function runAutoHatch()
    if not EggState then return end

    local net = ReplicatedStorage:FindFirstChild("Packages") 
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    if not net then return end

    local AskHatch       = net:FindFirstChild("RF/EggWorld/AskHatch")
    local AskFinishHatch = net:FindFirstChild("RF/EggWorld/AskFinishHatch")
    if not AskHatch and not AskFinishHatch then return end

    local owned = EggState.ReadOwnerEggs(LocalPlayer.UserId)
    if type(owned) ~= "table" then return end

    local hatched = 0
    for uid in pairs(owned) do
        if type(uid) ~= "string" then continue end

        if AskHatch then
            pcall(function() AskHatch:InvokeServer(uid) end)
            task.wait(0.05)
        end

        if AskFinishHatch then
            local ok, success, r2, petUid = pcall(function()
                return AskFinishHatch:InvokeServer(uid)
            end)

            if ok and success then
                hatched += 1
                print("[AutoHatch] hatched uid:", uid:sub(1, 8), "pet:", tostring(petUid or r2))
            end
            task.wait(0.05)
        end
    end

    if hatched > 0 then
        print("[AutoHatch] total hatched:", hatched)
    end
end

task.spawn(function()
    while true do
        task.wait(State.hatchInterval)
        if State.hatchEnabled then
            if not EggState then loadModules() end
            pcall(runAutoHatch)
        end
    end
end)
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
	Title = "v1.0.513",
	Color = "ElementBackground",
})

local Tabdc = Window:Tab({
	Title = "DISCORD",
	Icon = "discord",
})

--[[Window:Section({
	Title = "Silent",
})
	]]

local Tab1 = Window:Tab({
	Title = "EGGS",
	Icon = "egg",
})

local Tab2 = Window:Tab({
	Title = "PROGRESSION",
	Icon = "discord",
})

local Tab3 = Window:Tab({
	Title = "PETS",
	Icon = "discord",
})

local Tab4 = Window:Tab({
	Title = "RIFT",
	Icon = "discord",
})

local Tab5 = Window:Tab({
	Title = "CONTEST",
	Icon = "sword",
})

local Tab6 = Window:Tab({
	Title = "VISUAL",
	Icon = "discord",
})

local Tab7 = Window:Tab({
	Title = "WEBHOOK",
	Icon = "discord",
})

local Tab8 = Window:Tab({
	Title = "SETTINGS",
	Icon = "settings",
})



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
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
				
local Section = Tab1:Section({
	Title = "Auto Steal",
	Box = true,
	BoxBorder = true,
})

local Section1 = Tab1:Section({
	Title = "Auto Steal Filter",
	Box = true,
	BoxBorder = true,
})

Section1:Dropdown({
	Title = "Rarities",
	Values = {			
		"Common",
		"Uncommon",
		"Rare",			
		"Epic",
		"Legendary",
		"Mythic",	
		"Cosmic",						
		"Secret",
		"Eternal",
		"Divine",
	},
	Value = nil,
	AllowNone = true,
	Multi = true,
	Callback = function(selectedValue)
		if type(selectedValue) == "table" then
			print("Selected: " .. table.concat(selectedValue, ", "))
		else
			print("Selected: " .. tostring(selectedValue))
		end
	end,
})

Section:Toggle({
	Title = "Auto Steal Egg",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

local Section2 = Tab1:Section({
	Title = "Auto Place & Hatch",
	Box = true,
	BoxBorder = true,
})

Section2:Toggle({
	Title = "Auto Place All Eggs",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

Section2:Toggle({
	Title = "Auto Hatch Ready",
	Desc = "Automatically hatches owned eggs when ready",
	Value = State.hatchEnabled,
	Callback = function(state)
		State.hatchEnabled = state
		print("Auto Hatch state:", state)
		if state then
			setclipboard("https://discord.gg/yourlink")
		end
	
})

local Section3 = Tab1:Section({
	Title = "Auto Sell Egg",
	Box = true,
	BoxBorder = true,
})

Section3:Dropdown({
	Title = "Rarities",
	Values = {
		"Common",
		"Uncommon",
		"Rare",			
		"Epic",
		"Legendary",
		"Mythic",	
		"Cosmic",						
		"Secret",
		"Eternal",
		"Divine",
	},
	Value = nil,
	AllowNone = true,
	Multi = true,
	Callback = function(selectedValue)
		if type(selectedValue) == "table" then
			print("Selected: " .. table.concat(selectedValue, ", "))
		else
			print("Selected: " .. tostring(selectedValue))
		end
	end,
})

Section3:Toggle({
	Title = "Auto Sell Eggs",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

local Section4 = Tab2:Section({
	Title = "Upgrades",
	Box = true,
	BoxBorder = true,
})

Section4:Paragraph({
	Title = "Pen",
	Box = false,
	BoxBorder = false,	
	Justify = "Center",
})

Section4:Toggle({
	Title = "Auto Upgrade Pen",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

Section4:Paragraph({
	Title = "Treadmill",
	Box = false,
	BoxBorder = false,	
	Justify = "Center",
})


Section4:Toggle({
	Title = "Auto Treadmill Training",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

Section4:Toggle({
	Title = "Auto Treadmill Upgrade",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

local Section5 = Tab3:Section({
	Title = "Pets",
	Box = true,
	BoxBorder = true,
})

Section5:Toggle({
	Title = "Auto Equip Best Pets",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

Section5:Toggle({
	Title = "Claim Offline Earnings",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

Section5:Paragraph({
	Title = "Auto Sell Pets",
	Box = false,
	BoxBorder = false,	
	Justify = "Center",
})

Section5:Dropdown({
	Title = "Rarities",
	Values = {
		"Common",
		"Uncommon",
		"Rare",			
		"Epic",
		"Legendary",
		"Mythic",	
		"Cosmic",						
		"Secret",
		"Eternal",
		"Divine",
	},
	Value = nil,
	AllowNone = true,
	Multi = true,
	Callback = function(selectedValue)
		if type(selectedValue) == "table" then
			print("Selected: " .. table.concat(selectedValue, ", "))
		else
			print("Selected: " .. tostring(selectedValue))
		end
	end,
})

Section5:Toggle({
	Title = "Auto Sell",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

local Section7 = Tab6:Section({
	Title = "EGG ESP",
	Box = true,
	BoxBorder = true,
})

Section7:Toggle({
	Title = "EGG ESP",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

Section7:Paragraph({
	Title = "PERFORMANCE",
	Box = false,
	BoxBorder = false,	
	Justify = "Center",
})

Section7:Toggle({
	Title = "FPS BOOST",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

--[[local EmptyTab = Window:Tab({
	Title = "Custom empty page tab",

	CustomEmptyPage = {
		Icon = "lucide:smile",
		Title = "This is a cool empty tab",
		Desc = "I like it. its so great tab with cool 'custom empty page'",
	},
})]]
