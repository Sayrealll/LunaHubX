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



-- Remote Functions Setup
local networkingFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")
local askWearStillRF = networkingFolder:WaitForChild("RF/Treadmill/AskWearStill")
local askDoffRF = networkingFolder:WaitForChild("RF/Treadmill/AskDoff")
local fetchStatusRF = networkingFolder:WaitForChild("RF/Haul/FetchWearBestStatus")

-- Helper Function: Kukunin ang SARILI MONG treadmill gamit ang Status Remote
local function getMyExactTreadmill()
    -- 1. I-call ang remote para kunin ang status ng kagamitan/treadmill mo mula sa Server
    local success, myStatus = pcall(function()
        return fetchStatusRF:InvokeServer()
    end)

    if success and myStatus then
        -- Kung nagbalik ito ng Instance o Model ng treadmill mo
        if typeof(myStatus) == "Instance" then
            return myStatus:IsA("Model") and (myStatus.PrimaryPart or myStatus:FindFirstChildWhichIsA("BasePart")) or myStatus
        end

        -- Kung nagbalik ito ng Table/Data, hahanapin natin ang pangalan nito sa Workspace
        if type(myStatus) == "table" then
            for _, val in pairs(myStatus) do
                if typeof(val) == "Instance" and val.Name:lower():find("treadmill") then
                    return val:IsA("Model") and (val.PrimaryPart or val:FindFirstChildWhichIsA("BasePart")) or val
                end
            end
        end
    end

    -- 2. Fallback: Kung walang ibinalik na status, hanapin ang treadmill na pinakamalapit sa iyong pagpasok
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("treadmill") and (obj:IsA("BasePart") or obj:IsA("Model")) then
                -- Tiyakin na walang ibang player na nakatayo rito
                local isOccupied = false
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local partPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or obj.Position
                        if (plr.Character.HumanoidRootPart.Position - partPos).Magnitude < 4 then
                            isOccupied = true
                            break
                        end
                    end
                end

                if not isOccupied then
                    return obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                end
            end
        end
    end

    return nil
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
	bataura = false,
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
	Title = "v1.0.0.40",
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

--speed bypass
utility.collectgarbage = function()
    local s, r = pcall(function(...)
        return getgc()
    end)
    if s and r then
        return r    
    end
    return warn("failed to get garbage: "..tostring(r))
end

utility.safehook = function(f, c)
    local s, r = pcall(function(...)
        return hookfunction(f, newlclosure(c))
    end)
    if s and r then
        return r    
    end
    return warn("failed to hook function: "..tostring(r))
end

function utility:findfunction(nups, linedefined)
    local s, r = pcall(function(...)
        for _, f in next, self.collectgarbage() do
            if typeof(f) == 'function' and islclosure(f) then
                local upvs = debug.getupvalues(f)
                local line = debug.info(f, "l")

                if upvs and #upvs == nups and line == linedefined then
                    if nups == 10 then
                        local t = debug.getupvalue(f, 3)
                        if typeof(t) == "table" and rawget(t, "Humanoid") then
                            return f
                        end
                    else
                        return f
                    end
                end
            end
        end

        return nil
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:initbypass()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not getgc then
        self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING getgc")
    end

    if not hookfunction then
        self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING hookfunction")
    end

    if not islclosure then
        self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING islclosure")
    end

    local func3 = self:findfunction(19, 3)

    if not func3 then
        return warn("failed to get function 3")
    end

    local v7 = debug.getupvalue(func3, 2)
    if not v7 then
        return warn("failed to get v7")
    end

    local hookedfunc3; hookedfunc3 = self.safehook(v7, function(p1, p2)
        if p2 and typeof(p2) == "table" then
            setmetatable(p2, {})
        end
        return hookedfunc3(p1,p2)
    end)

    self.speedconn = self.RunService.Heartbeat:Connect(function()
        local char = self.LocalPlayer.Character
        if not char then 
            return
        end

        local hum = char:FindFirstChild("Humanoid")
        if not hum then 
            return
        end

        hum.WalkSpeed = 500
    end)

    return
end

utility:initbypass()

-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
-- ============================================================
--BAT AURA



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

    if state then
        task.spawn(function()
            while State.autoTreadmillTraining do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    local myTreadmill = getMyExactTreadmill()

                    if myTreadmill then
                        local distance = (hrp.Position - myTreadmill.Position).Magnitude

                        -- Ilapit/Teleport lang kapag malayo sa SARILI MONG treadmill
                        if distance > 5 then
                            hrp.CFrame = myTreadmill.CFrame * CFrame.new(0, 3, 0)
                            task.wait(0.3)
                        end

                        -- Invoke remote para sumakay
                        pcall(function()
                            askWearStillRF:InvokeServer()
                        end)
                    else
                        -- Pag hindi mahanap ang eksaktong model, i-fire pa rin ang Remote
                        pcall(function()
                            askWearStillRF:InvokeServer()
                        end)
                    end
                end

                task.wait(1.5)
            end
        end)
    else
        -- Turn OFF: Bumaba sa treadmill
        task.spawn(function()
            pcall(function()
                askDoffRF:InvokeServer()
            end)
        end)
    end
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


function Functions.OnToggleBatAura(state)
    State.batAura = state
    print("Bat Aura state:", state)

    if state then
        utility:Start()
    else
        utility:Stop()
    end
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
-- TAB 5: CONTEST
-- ============================================================

local Section6 = Tab5:Section({ Title = "CONTEST PLAYER", Box = true, BoxBorder = true })

Section6:Toggle({
    Title = "BAT AURA",
    Value = State.batAura,
    Callback = Functions.OnToggleBatAura,
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
