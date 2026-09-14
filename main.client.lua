-- WindUI Implementation for Chicken Farm
local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Paper"):WaitForChild("Remotes")
local RemoteFunc = Remotes:WaitForChild("__remotefunction")
local RemoteEvent = Remotes:WaitForChild("__remoteevent")

-- WindUI Loader
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
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Chicken Farm Hub",
    Author = "by Script",
    Icon = "solar:widget-bold",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.F,
})

Window:Tag({
    Title = "v1.0",
    Color = "ElementBackground",
})

-- Tabs Setup
local FarmTab = Window:Tab({
    Title = "Farm Features",
    Icon = "warehouse",
})

local TeleportTab = Window:Tab({
    Title = "Teleports",
    Icon = "locate-fixed",
})

-- State Tracker for Toggles
local States = {}

local function LoopFeature(flagName, callback, delay)
    task.spawn(function()
        while States[flagName] do
            callback()
            task.wait(delay or 0.1)
        end
    end)
end

-- Teleport Helper
local function TeleportTo(target)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        if target:IsA("BasePart") then
            character.HumanoidRootPart.CFrame = target.CFrame
        elseif target:IsA("Model") then
            local part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            if part then
                character.HumanoidRootPart.CFrame = part.CFrame
            end
        end
    end
end

-- Section: Auto Collect & TP
local TPSection = TeleportTab:Section({
    Title = "Auto Pickup Teleports",
    Box = true,
})

TPSection:Toggle({
    Title = "TP To Eggs Only",
    Desc = "Teleports directly to dropped Eggs (UUID check)",
    Value = false,
    Callback = function(state)
        States["TPEggs"] = state
        if state then
            LoopFeature("TPEggs", function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if not States["TPEggs"] then break end
                    if #v.Name == 36 and not v:FindFirstChild("Humanoid") then
                        TeleportTo(v)
                        task.wait(0.08)
                    end
                end
            end, 0.1)
        end
    end,
})

TPSection:Toggle({
    Title = "TP To Lucky Blocks Only",
    Desc = "Teleports directly to Lucky Block drops",
    Value = false,
    Callback = function(state)
        States["TPLucky"] = state
        if state then
            LoopFeature("TPLucky", function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if not States["TPLucky"] then break end
                    if v.Name:lower():find("luckyblock") or (v.Name:lower():find("lucky") and #v.Name == 36) then
                        TeleportTo(v)
                        task.wait(0.08)
                    end
                end
            end, 0.1)
        end
    end,
})

-- Section: Main Farm Toggles
local FarmSection = FarmTab:Section({
    Title = "Auto Farm Actions",
    Box = true,
})

FarmSection:Toggle({
    Title = "Offline Earnings",
    Value = false,
    Callback = function(state)
        States["Offline"] = state
        if state then
            LoopFeature("Offline", function()
                RemoteFunc:InvokeServer("Claim Offline Earnings")
            end, 0.5)
        end
    end,
})

FarmSection:Toggle({
    Title = "Open Lucky Block",
    Value = false,
    Callback = function(state)
        States["OpenLucky"] = state
        if state then
            LoopFeature("OpenLucky", function()
                RemoteFunc:InvokeServer("Open Lucky Block")
            end, 0.5)
        end
    end,
})

FarmSection:Toggle({
    Title = "Merge Chickens",
    Value = false,
    Callback = function(state)
        States["Merge"] = state
        if state then
            LoopFeature("Merge", function()
                RemoteFunc:InvokeServer("Merge Chickens")
            end, 0.5)
        end
    end,
})

FarmSection:Toggle({
    Title = "Deposit Eggs",
    Value = false,
    Callback = function(state)
        States["Deposit"] = state
        if state then
            LoopFeature("Deposit", function()
                RemoteFunc:InvokeServer("Deposit Eggs")
            end, 0.5)
        end
    end,
})

FarmSection:Toggle({
    Title = "Collect Cash",
    Value = false,
    Callback = function(state)
        States["Cash"] = state
        if state then
            LoopFeature("Cash", function()
                RemoteFunc:InvokeServer("Collect Cash")
            end, 0.5)
        end
    end,
})

-- Section: Upgrades
local UpgradeSection = FarmTab:Section({
    Title = "Upgrades & Purchases",
    Box = true,
})

UpgradeSection:Toggle({
    Title = "Upgrade Process",
    Value = false,
    Callback = function(state)
        States["UpProcess"] = state
        if state then
            LoopFeature("UpProcess", function()
                RemoteFunc:InvokeServer("Upgrade Process Level")
            end, 0.5)
        end
    end,
})

UpgradeSection:Toggle({
    Title = "Upgrade Tier",
    Value = false,
    Callback = function(state)
        States["UpTier"] = state
        if state then
            LoopFeature("UpTier", function()
                RemoteFunc:InvokeServer("Upgrade Buy Tier Level")
            end, 0.5)
        end
    end,
})

UpgradeSection:Toggle({
    Title = "Buy Chickens (100)",
    Value = false,
    Callback = function(state)
        States["BuyChicken"] = state
        if state then
            LoopFeature("BuyChicken", function()
                RemoteFunc:InvokeServer("Buy Chickens", 100)
            end, 0.5)
        end
    end,
})

UpgradeSection:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(state)
        States["Rebirth"] = state
        if state then
            LoopFeature("Rebirth", function()
                RemoteFunc:InvokeServer("Rebirth")
            end, 1)
        end
    end,
})
