--// LUNA HUB LIFECYCLE (fresh start / full cleanup)
local LH = { Alive = true, Conns = {} }
local Svc, Mods, Rem, PD, Tabs, Secs = {}, {}, {}, {}, {}, {} -- grouped para hindi lumampas sa 200 local limit

LH.TrimNum = function(n)
	return (string.format("%.2f", n):gsub("%.?0+$", ""))
end

LH.ParseKG = function(text)
	text = tostring(text or ""):gsub("[%s,]", "")
	return tonumber(text:match("^%d*%.?%d+$")) or 0
end
do
	local ok, env = pcall(function() return getgenv() end)
	if ok and type(env) == "table" and type(env.LunaHubCleanup) == "function" then
		pcall(env.LunaHubCleanup) -- patayin muna ang lumang instance bago mag-load ng bago
	end
end
local function Bind(signal, fn)
	local c = signal:Connect(fn)
	table.insert(LH.Conns, c)
	return c
end

--// ANTI AFK & AUTO LOAD CHECK
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local VirtualUser = game:GetService("VirtualUser")

Bind(game:GetService("Players").LocalPlayer.Idled, function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

--// SERVICES & REFERENCES
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

Svc.ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
Svc.RunService = cloneref(game:GetService("RunService"))
Svc.Players = cloneref(game:GetService("Players"))
Svc.HttpService = cloneref(game:GetService("HttpService"))
Svc.Lighting = cloneref(game:GetService("Lighting"))
Svc.TeleportService = cloneref(game:GetService("TeleportService"))
Svc.TweenService = cloneref(game:GetService("TweenService"))
Svc.UserInputService = cloneref(game:GetService("UserInputService"))

--// PLAYER REFERENCES
local Player = Svc.Players.LocalPlayer
local LocalPlayer = Player
PD.SavedData = LocalPlayer:WaitForChild("SavedData")
PD.Cash = PD.SavedData:WaitForChild("Cash")
PD.Rebirths = PD.SavedData:WaitForChild("Rebirths")
PD.OwnedPetsIndex = PD.SavedData:WaitForChild("OwnedPets")
PD.IndexRewardStage = PD.SavedData:WaitForChild("IndexRewardStage")

--// GAME MODULES & REMOTES
local GameServices = Svc.ReplicatedStorage:WaitForChild("GameServices")
local GameData = Svc.ReplicatedStorage:WaitForChild("GameData")

Mods.General_m = require(GameServices:WaitForChild("General"))
Mods.PetAging_m = require(GameServices:WaitForChild("PetAging"))
Mods.DayNight_mData = require(GameServices:WaitForChild("DayNight"))

Mods.Pets_m = require(GameData:WaitForChild("Pets"))
Mods.Mutations_m = require(GameData:WaitForChild("Mutations"))
Mods.Eggs_mData = require(GameData:WaitForChild("Eggs"))
Mods.General_mData = require(GameData:WaitForChild("General"))
Mods.Rebirths_m = require(GameData:WaitForChild("Rebirths"))
Mods.IndexRewards = require(GameData:WaitForChild("IndexRewards"))

Mods.PetRenderer_m = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))

local GameRemotes = Svc.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
Rem.BuyWithCash = GameRemotes:WaitForChild("BuyWithCash")
Rem.ShopStockRemote = GameRemotes:WaitForChild("ShopStock")
Rem.RestockRemote = GameRemotes:WaitForChild("Restock")
Rem.PlacePetRemote = GameRemotes:WaitForChild("PlacePet")
Rem.PickupPetRemote = GameRemotes:WaitForChild("PickupPet")
Rem.ClaimIndexReward = GameRemotes:WaitForChild("ClaimIndexReward")
Rem.FavoritePetRemote = GameRemotes:WaitForChild("FavoritePet")

-- VOLCANO DIP REMOTE
Rem.VolcanoDipRemote = Svc.ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/VolcanoDip")

--// WINDUI INITIALIZATION
local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if Svc.RunService:IsStudio() or not writefile then
			WindUI = require(
				Svc.ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")
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
local ConfigFolder = "LUNA HUB/Ride A Pet"
local ConfigFile = ConfigFolder .. "/LunaHub_Config.json"
local isResetting = false

local function NewDefaultConfig()
	return {
		-- FARM
		SelectedRarities = {},
		SelectedEggs = {},
		MinWeightText = "0",
		AutoVolcanoDip = false,
		AutoPickup = false,
		SelectedPlaceRarities = {},
		SelectedPlaceEgg = {},
		AutoPlaceEgg = false,
		SelectedHatchRarities = {},
		SelectedHatchEggs = {},
		AutoHatchSelectedEggs = false,
		AutoHatchEgg = false,
		AutoEquipBestPet = false,
		AutoUpgradeHatchLuck = false,
		AutoUpgradeHatchLuckMax = false,
		AutoRebirth = false,
		AutoClaimIndex = false,
		AutoCandy = false,
		CandyTweenSpeed = 100,
		CandyMoveMode = "Tween",
		FarmTweenSpeed = 100,
		AutoKnock = false,
		AutoHaEgg = false,
		AutoRitual = false,

		-- SHOP
		SelectedGear = {},
		Autobuygear = false,
		SelectedFood = {},
		Autobuyfood = false,
		SelectedSellRarities = {},
		SelectedPetToSell = {},
		AutoSellPet = false,
		AutoSellAllPets = false,
		SelectedFavPet = {},
		AutoFavoritePet = false,

		-- FUSE
		SelectedFusePets = {},
		AutoFuse = false,
		AutoClaimFusedPets = false,

		-- VISUAL
		SelectedESPRarities = {},
		SelectedESPEggs = {},
		ESPEnabled = false,

		-- WEBHOOK
		WebhookUrl = "",
		WebhookEnabled = false,

		-- SETTINGS
		FPSBoost = false,
		HideEggs = false,
		ThemeName = "Dark",
		ThemeEnabled = false,
		AutoExecute = false,

		-- PLAYER
		noclip = false,
		infjump = false,
	}
end

local ConfigData = NewDefaultConfig()

local function EnsureFolders()
	if makefolder then
		if isfolder and not isfolder("LUNA HUB") then
			pcall(makefolder, "LUNA HUB")
		end
		if isfolder and not isfolder(ConfigFolder) then
			pcall(makefolder, ConfigFolder)
		end
	end
end

local function LoadConfig()
	EnsureFolders()
	if isfile and readfile and isfile(ConfigFile) then
		local success, result = pcall(function()
			return Svc.HttpService:JSONDecode(readfile(ConfigFile))
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
	EnsureFolders()
	if writefile then
		pcall(function()
			writefile(ConfigFile, Svc.HttpService:JSONEncode(ConfigData))
		end)
	end
end

LoadConfig()

--// THEME SYSTEM
local ThemeEnabled = ConfigData.ThemeEnabled == true
local SelectedTheme = type(ConfigData.ThemeName) == "string" and ConfigData.ThemeName or "Dark"

local function MakeTheme(name, accent, background, dialog, button, outline)
	return {
		Name = name,
		Accent = Color3.fromHex(accent),
		Dialog = Color3.fromHex(dialog),
		Outline = Color3.fromHex(outline),
		Text = Color3.fromHex("#FFFFFF"),
		Placeholder = Color3.fromHex("#9A9A9A"),
		Background = Color3.fromHex(background),
		Button = Color3.fromHex(button),
		Icon = Color3.fromHex(accent),
	}
end

local CustomThemes = {
	MakeTheme("Crimson",       "#E5383B", "#140808", "#1E0D0D", "#2C1313", "#4A1F1F"),
	MakeTheme("Ocean Blue",    "#3A86FF", "#07101E", "#0C1A2E", "#12253F", "#1F3C66"),
	MakeTheme("Forest Green",  "#2ECC71", "#07130C", "#0C1F13", "#12301D", "#1F5233"),
	MakeTheme("Royal Purple",  "#9B5DE5", "#0F0818", "#180D26", "#241338", "#3E2362"),
	MakeTheme("Sunset Orange", "#FF7B00", "#160B05", "#22110A", "#331A0D", "#5C3015"),
	MakeTheme("Sakura Pink",   "#FF5DA2", "#170811", "#240D1B", "#361429", "#5E2347"),
	MakeTheme("Cyber Cyan",    "#00E5FF", "#041316", "#081F24", "#0D2F36", "#14525C"),
	MakeTheme("Golden",        "#FFC300", "#151006", "#21190A", "#33250F", "#5C4515"),
	MakeTheme("Midnight",      "#6C7BFF", "#05060F", "#0A0C1A", "#10132A", "#1C2150"),
	MakeTheme("Mint",          "#5EF2C0", "#06130F", "#0B201A", "#11332A", "#1C5A49"),
}

local ThemeNames = { "Dark", "Light" }
for _, theme in ipairs(CustomThemes) do
	pcall(function() WindUI:AddTheme(theme) end)
	table.insert(ThemeNames, theme.Name)
end

if not table.find(ThemeNames, SelectedTheme) then
	SelectedTheme = "Dark"
end

-- default is Dark; the chosen theme only applies when the toggle is ON
local ThemeName = ThemeEnabled and SelectedTheme or "Dark"

-- MULTI-SELECT TABLES
local SelectedEggs = ConfigData.SelectedEggs or {}
local SelectedRarities = ConfigData.SelectedRarities or {}
local SelectedPlaceEgg = ConfigData.SelectedPlaceEgg or {}
local SelectedPlaceRarities = ConfigData.SelectedPlaceRarities or {}
local SelectedHatchRarities = ConfigData.SelectedHatchRarities or {}
local SelectedHatchEggs = ConfigData.SelectedHatchEggs or {}
local SelectedGear = ConfigData.SelectedGear or {}
local SelectedFood = ConfigData.SelectedFood or {}
local SelectedPetToSell = ConfigData.SelectedPetToSell or {}
local SelectedSellRarities = ConfigData.SelectedSellRarities or {}
local SelectedFavPet = ConfigData.SelectedFavPet or {}
if type(ConfigData.SelectedFusePets) ~= "table" then ConfigData.SelectedFusePets = {} end
local SelectedFusePets = ConfigData.SelectedFusePets
local SelectedESPEggs = ConfigData.SelectedESPEggs or {}
local SelectedESPRarities = ConfigData.SelectedESPRarities or {}

-- TOGGLES & INPUTS
LH.MinKG = LH.ParseKG(ConfigData.MinWeightText)
local AutoVolcanoDip = ConfigData.AutoVolcanoDip or false
local AutoPickup = ConfigData.AutoPickup or false

--// AUTO FARM PRIORITY SYSTEM
LH.FarmBusy = false -- true habang may egg na kukunin / tumatakbo ang Auto Farm
LH.FarmFails = 0    -- bilang ng sunod-sunod na bigong farm cycle
LH.BgBusy = 0       -- ilang background function ang kasalukuyang gumagana
function LH.FarmPaused()
	return AutoPickup == true and LH.FarmBusy == true
end
function LH.BgRun(fn, ...)
	LH.BgBusy += 1
	local ok, err = pcall(fn, ...)
	LH.BgBusy = math.max(0, LH.BgBusy - 1)
	return ok, err
end

--==================================================
-- PRIORITY ORDER (pinakamataas -> pinakamababa)
--  1) AUTO FARM
--  2) AUTO FUSE + AUTO CLAIM FUSED PETS
--  3) AUTO BUY HALLOWEEN EGG > AUTO RITUAL > AUTO KNOCK DOORS > AUTO COLLECT CANDY
-- Ang mas mababang priority ay naka-HOLD hangga't may trabaho ang mas mataas.
--==================================================
LH.FuseLockN = 0       -- >0 habang may tumatakbong Fuse/Claim cycle
LH.FuseHasWorkNow = nil -- itatakda sa AUTO FUSE section
LH.BuyActing = false   -- true habang tumatakbo ang bili ng Halloween Egg

-- Priority 2: Auto Fuse / Auto Claim Fused Pets ay active kapag may trabaho
function LH.FuseActive()
	if LH.FuseLockN > 0 then return true end
	if LH.FuseHasWorkNow then
		local ok, res = pcall(LH.FuseHasWorkNow)
		return ok and res == true
	end
	return false
end

-- Priority 3 group (Halloween) ay naka-pause kapag Farm O Fuse ang active
function LH.HallPaused()
	return LH.FarmPaused() or LH.FuseActive()
end

-- hintayin munang tumigil ang Halloween actions bago mag-TP ang Fuse (para walang mag-overwrite ng position)
function LH.FuseYield()
	local started = os.clock()
	while LH.Alive and (LH.CandyActing or LH.KnockActing or LH.BuyActing or LH.Tweening)
		and os.clock() - started < 3 do
		task.wait(0.05)
	end
end
local AutoPlaceEgg = ConfigData.AutoPlaceEgg or false
local AutoHatchSelectedEggs = ConfigData.AutoHatchSelectedEggs or false
local AutoHatchEgg = ConfigData.AutoHatchEgg or false
local AutoEquipBestPet = ConfigData.AutoEquipBestPet or false
local AutoUpgradeHatchLuck = ConfigData.AutoUpgradeHatchLuck or false
local AutoUpgradeHatchLuckMax = ConfigData.AutoUpgradeHatchLuckMax or false
local AutoRebirth = ConfigData.AutoRebirth or false
local AutoClaimIndex = ConfigData.AutoClaimIndex or false
LH.AutoCandy = ConfigData.AutoCandy == true
LH.CandyMoveMode = (ConfigData.CandyMoveMode == "Instant TP") and "Instant TP" or "Tween" -- "Tween" (default) | "Instant TP"
LH.AutoKnock = ConfigData.AutoKnock == true
LH.AutoHaEgg = ConfigData.AutoHaEgg == true
LH.AutoRitual = ConfigData.AutoRitual == true
LH.RitualBusyCave = false
LH.RitualLock = false   -- true habang tumatakbo ang BUONG ritual cycle (pickup + cave)
LH.CandyActing = false  -- true habang may ginagawang galaw ang Candy loop
LH.KnockActing = false  -- true habang may ginagawang galaw ang Knock loop
LH.KnockHasDoor = false -- true habang may lit door na kakatukin ang Auto Knock
-- Auto Knock ang priority: naka-hold ang Auto Collect Candy hangga't may door na kakatukin
function LH.KnockActive()
	return LH.AutoKnock == true and LH.KnockHasDoor == true
end

-- PRIORITY (Halloween group, nasa ilalim ng Auto Farm at Auto Fuse): 1) Auto Buy Halloween Egg  2) Auto Ritual  3) Auto Knock  4) Auto Collect Candy
-- Auto Ritual ay active kapag naka-ON at may Yin/Yang piece na kukunin / ilalagay (naka-hold ang Knock at Candy)
function LH.RitualActive()
	if LH.AutoRitual ~= true then return false end
	if LH.RitualLock == true then return true end
	if LH.RitualHasWorkNow then
		local ok, res = pcall(LH.RitualHasWorkNow)
		return ok and res == true
	end
	return false
end

-- Auto Buy Halloween Egg ang PINAKAMATAAS na priority (higit sa Auto Knock at Auto Collect Candy)
-- Active kapag naka-ON, sapat ang token, at hindi paulit-ulit na pumapalya ang bili
LH.HalloweenEggPrice = 350
LH.HaEggFails = 0
function LH.BuyActive()
	if LH.AutoHaEgg ~= true or LH.HaEggFails >= 3 then return false end
	local savedData = LocalPlayer:FindFirstChild("SavedData")
	local tokens = savedData and savedData:FindFirstChild("HalloweenCandy")
	return tokens ~= nil and (tonumber(tokens.Value) or 0) >= LH.HalloweenEggPrice
end
local Autobuygear = ConfigData.Autobuygear or false
local Autobuyfood = ConfigData.Autobuyfood or false
local AutoSellPet = ConfigData.AutoSellPet or false
local AutoSellAllPets = ConfigData.AutoSellAllPets or false
local AutoFavoritePet = ConfigData.AutoFavoritePet or false
local AutoFuse = ConfigData.AutoFuse == true
local AutoClaimFusedPets = ConfigData.AutoClaimFusedPets == true
local ESPEnabled = ConfigData.ESPEnabled or false
local WebhookUrl = ConfigData.WebhookUrl or ""
local WebhookEnabled = ConfigData.WebhookEnabled or false
local FPSBoost = ConfigData.FPSBoost or false
local HideEggs = ConfigData.HideEggs or false

-- forward declaration (defined sa AUTOMATION LOOPS)
local ProcessAutoFavorite

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

-- NO PROMPT
for i,v in pairs(game:GetService("Workspace"):GetDescendants()) do
	if v:IsA("ProximityPrompt") then
		v["HoldDuration"] = 0
	end
end

Bind(game:GetService("ProximityPromptService").PromptButtonHoldBegan, function(v)
	v["HoldDuration"] = 0
end)


--==================================================
-- DISCORD WEBHOOK FUNCTION
--==================================================
local function SendWebhookNotification(eggName, basketEgg)
	if not WebhookEnabled or WebhookUrl == "" then return end

	local request = (syn and syn.request)
		or (http and http.request)
		or http_request
		or (fluxus and fluxus.request)
		or request

	if not request then return end

	local eggData = Mods.Eggs_mData[eggName]
	local rarity = eggData and eggData.Rarity or "Unknown"

	-- GET MUTATION + WEIGHT FROM ACTUAL BASKET EGG
	local mutation = "None"
	local weight = "Unknown"

	if basketEgg then
		mutation = basketEgg:GetAttribute("Mutation") or "None"

		-- Same logic as ESP: raw weight -> General_mData.ShownEggKG -> formatted kg
		-- (raw attribute lang yung dating kinukuha kaya mali; kailangan i-convert)
		local okW, text = pcall(function()
			return LH.GetEggWeightText and LH.GetEggWeightText(basketEgg)
		end)
		if okW and text then
			weight = text
		else
			local raw = tonumber(basketEgg:GetAttribute("Weight"))
			if raw then
				local okK, kg = pcall(function() return Mods.General_mData.ShownEggKG(raw) end)
				weight = LH.FormatKG((okK and type(kg) == "number") and kg or raw)
			end
		end
	end

	local embedData = {
		["title"] = "🥚 Egg Collected!",
		["color"] = 65280,

		["fields"] = {
			{
				["name"] = "Player",
				["value"] = Player.Name,
				["inline"] = true
			},
			{
				["name"] = "Egg Name",
				["value"] = tostring(eggName),
				["inline"] = true
			},
			{
				["name"] = "Rarity",
				["value"] = tostring(rarity),
				["inline"] = true
			},
			{
				["name"] = "Mutation",
				["value"] = tostring(mutation),
				["inline"] = true
			},
			{
				["name"] = "Weight",
				["value"] = tostring(weight),
				["inline"] = true
			}
		},

		["footer"] = {
			["text"] = "Luna Hub Auto Farm"
		},

		["timestamp"] = DateTime.now():ToIsoDate()
	}

	local payload = Svc.HttpService:JSONEncode({
		["username"] = "Luna Hub Notifier",
		["embeds"] = { embedData }
	})

	pcall(function()
		request({
			Url = WebhookUrl,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = payload
		})
	end)
end


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


--==================================================
-- ANTI-ROGDALL
--==================================================
LH.UprightCFrame = function(pos)
	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local look = hrp and hrp.CFrame.LookVector or Vector3.new(0, 0, -1)
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 1e-3 then flat = Vector3.new(0, 0, -1) end
	return CFrame.lookAt(pos, pos + flat.Unit)
end

LH.Stabilize = function()
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	pcall(function()
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		hum.PlatformStand = false
		local st = hum:GetState()
		if st == Enum.HumanoidStateType.FallingDown
					or st == Enum.HumanoidStateType.Ragdoll
					or st == Enum.HumanoidStateType.PlatformStanding then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

function LH.GetMyPlot()
	local Plots = workspace:FindFirstChild("Plots")
	if not Plots then return nil end
	for _, Plot in ipairs(Plots:GetChildren()) do
		local Owner = Plot:GetAttribute("Owner")
		local OwnerUserId = Plot:GetAttribute("OwnerUserId")
		local UserId = Plot:GetAttribute("UserId")
		if Plot:GetAttribute("NestsOwnerLoaded") == Player.UserId
					or Owner == Player.Name or Owner == Player.UserId
					or OwnerUserId == Player.UserId or UserId == Player.UserId then
			return Plot
		end
	end
	return nil
end

local function TeleportToMyPlot()
	local Character = GetCharacter()
	if not Character then return false end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return false end

	local MyPlot = LH.GetMyPlot()
	if not MyPlot then return false end

	local Baseplate = MyPlot:FindFirstChild("Baseplate")
	if Baseplate and Baseplate:IsA("BasePart") then
		HRP.CFrame = LH.UprightCFrame((Baseplate.CFrame * CFrame.new(0, 3, 0)).Position)
		LH.Stabilize()
		return true
	end

	local PlotPart = MyPlot:FindFirstChildWhichIsA("BasePart", true)
	if PlotPart then
		HRP.CFrame = LH.UprightCFrame((PlotPart.CFrame * CFrame.new(0, 3, 0)).Position)
		LH.Stabilize()
		return true
	end

	return false
end


--==================================================
-- FPS BOOST & RESTORE SYSTEM
-- HEAVY / LOW GRAPHICS / LOW EFFECTS
--==================================================

local FPSState = {
	Enabled = false,
	Processing = false,

	Original = {
		GlobalShadows = nil,
		FogEnd = nil,
		ShadowSoftness = nil,
		QualityLevel = nil,
		MeshPartDetailLevel = nil,

		WaterWaveSize = nil,
		WaterWaveSpeed = nil,
		WaterReflectance = nil,
		WaterTransparency = nil,

		LightingTechnology = nil,
		TerrainDecoration = nil,
	},

	Instances = {},
}

local FPSConnection = nil
local FPSGeneration = 0

--==================================================
-- SAVE ORIGINAL GLOBAL SETTINGS
--==================================================

local function SaveFPSOriginals()
	if FPSState.Original.QualityLevel == nil then
		pcall(function()
			FPSState.Original.QualityLevel =
				settings().Rendering.QualityLevel
		end)
	end

	if FPSState.Original.MeshPartDetailLevel == nil then
		pcall(function()
			FPSState.Original.MeshPartDetailLevel =
				settings().Rendering.MeshPartDetailLevel
		end)
	end

	if FPSState.Original.GlobalShadows == nil then
		pcall(function()
			FPSState.Original.GlobalShadows =
				Svc.Lighting.GlobalShadows
		end)
	end

	if FPSState.Original.FogEnd == nil then
		pcall(function()
			FPSState.Original.FogEnd =
				Svc.Lighting.FogEnd
		end)
	end

	if FPSState.Original.ShadowSoftness == nil then
		pcall(function()
			FPSState.Original.ShadowSoftness =
				Svc.Lighting.ShadowSoftness
		end)
	end

	-- Lighting Technology
	if FPSState.Original.LightingTechnology == nil then
		pcall(function()
			FPSState.Original.LightingTechnology =
				Svc.Lighting.Technology
		end)
	end

	-- Terrain
	local Terrain = workspace:FindFirstChildOfClass("Terrain")

	if Terrain then
		if FPSState.Original.WaterWaveSize == nil then
			pcall(function()
				FPSState.Original.WaterWaveSize =
					Terrain.WaterWaveSize
			end)
		end

		if FPSState.Original.WaterWaveSpeed == nil then
			pcall(function()
				FPSState.Original.WaterWaveSpeed =
					Terrain.WaterWaveSpeed
			end)
		end

		if FPSState.Original.WaterReflectance == nil then
			pcall(function()
				FPSState.Original.WaterReflectance =
					Terrain.WaterReflectance
			end)
		end

		if FPSState.Original.WaterTransparency == nil then
			pcall(function()
				FPSState.Original.WaterTransparency =
					Terrain.WaterTransparency
			end)
		end

		if FPSState.Original.TerrainDecoration == nil then
			pcall(function()
				FPSState.Original.TerrainDecoration =
					Terrain.Decoration
			end)
		end
	end
end

SaveFPSOriginals()

--==================================================
-- INSTANCE STATE
--==================================================

local function SaveInstanceProperty(instance, property)
	if not instance then
		return
	end

	local data = FPSState.Instances[instance]

	if not data then
		data = {}
		FPSState.Instances[instance] = data
	end

	if data[property] == nil then
		local ok, value = pcall(function()
			return instance[property]
		end)

		if ok then
			data[property] = value
		end
	end
end

--==================================================
-- DISABLE EXPENSIVE VISUAL
--==================================================

local function OptimizeInstance(instance)
	if not FPSState.Enabled then
		return
	end

	if not instance or not instance.Parent then
		return
	end

	local class = instance.ClassName

	--==============================================
	-- PARTICLES
	--==============================================

	if class == "ParticleEmitter" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- TRAILS
	--==============================================

	if class == "Trail" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- BEAMS
	--==============================================

	if class == "Beam" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- SMOKE
	--==============================================

	if class == "Smoke" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- FIRE
	--==============================================

	if class == "Fire" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- SPARKLES
	--==============================================

	if class == "Sparkles" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- POST EFFECTS
	--==============================================

	if instance:IsA("PostEffect") then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- LIGHTS
	--==============================================

	if instance:IsA("Light") then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end

	--==============================================
	-- HIGHLIGHTS
	--==============================================

	if class == "Highlight" then
		SaveInstanceProperty(instance, "Enabled")

		pcall(function()
			instance.Enabled = false
		end)

		return
	end
end

--==================================================
-- APPLY GLOBAL LOW GRAPHICS
--==================================================

local function ApplyGlobalFPSSettings()
	if not FPSState.Enabled then
		return
	end

	--==============================================
	-- SHADOWS
	--==============================================

	pcall(function()
		Svc.Lighting.GlobalShadows = false
	end)

	pcall(function()
		Svc.Lighting.ShadowSoftness = 0
	end)

	--==============================================
	-- FOG
	--==============================================

	pcall(function()
		Svc.Lighting.FogEnd = 1000000000
	end)

	--==============================================
	-- QUALITY
	--==============================================

	pcall(function()
		settings().Rendering.QualityLevel =
			Enum.QualityLevel.Level01
	end)

	pcall(function()
		settings().Rendering.MeshPartDetailLevel =
			Enum.MeshPartDetailLevel.Level04
	end)

	--==============================================
	-- LIGHTING TECHNOLOGY
	--==============================================

	if sethiddenproperty then
		pcall(function()
			sethiddenproperty(
				Svc.Lighting,
				"Technology",
				2
			)
		end)
	end

	--==============================================
	-- TERRAIN
	--==============================================

	local Terrain = workspace:FindFirstChildOfClass("Terrain")

	if Terrain then
		pcall(function()
			Terrain.WaterWaveSize = 0
		end)

		pcall(function()
			Terrain.WaterWaveSpeed = 0
		end)

		pcall(function()
			Terrain.WaterReflectance = 0
		end)

		pcall(function()
			Terrain.WaterTransparency = 0
		end)

		if sethiddenproperty then
			pcall(function()
				sethiddenproperty(
					Terrain,
					"Decoration",
					false
				)
			end)
		end
	end
end

--==================================================
-- BACKGROUND INSTANCE OPTIMIZER
--==================================================

local function StartBackgroundOptimizer()
	FPSGeneration += 1

	local MyGeneration = FPSGeneration

	task.spawn(function()

		local processed = 0

		-- IMPORTANT:
		-- Do NOT use one huge GetDescendants() loop.
		-- Process in small batches so the FPS does not
		-- freeze when FPS Boost is enabled.

		local descendants

		pcall(function()
			descendants = workspace:GetDescendants()
		end)

		if not descendants then
			return
		end

		for i = 1, #descendants do

			if not FPSState.Enabled then
				return
			end

			if MyGeneration ~= FPSGeneration then
				return
			end

			local object = descendants[i]

			OptimizeInstance(object)

			processed += 1

			-- Small batches.
			-- This prevents a giant frame spike.
			if processed >= 80 then
				processed = 0

				task.wait()
			end
		end

	end)
end

--==================================================
-- NEW INSTANCE HANDLER
--==================================================

local function ConnectFPSWatcher()

	if FPSConnection then
		FPSConnection:Disconnect()
		FPSConnection = nil
	end

	FPSConnection = workspace.DescendantAdded:Connect(function(instance)

		if not FPSState.Enabled then
			return
		end

		-- Don't do heavy work directly inside
		-- DescendantAdded.
		task.defer(function()

			if not FPSState.Enabled then
				return
			end

			if instance and instance.Parent then
				OptimizeInstance(instance)
			end

		end)

	end)
end

--==================================================
-- RESTORE INSTANCE
--==================================================

local function RestoreAllInstances()

	for instance, properties in pairs(FPSState.Instances) do

		if instance and instance.Parent then

			for property, value in pairs(properties) do

				pcall(function()
					instance[property] = value
				end)

			end

		end

	end

	FPSState.Instances = {}
end

--==================================================
-- RESTORE GLOBAL SETTINGS
--==================================================

local function RestoreGlobalFPSSettings()

	--==============================================
	-- LIGHTING
	--==============================================

	if FPSState.Original.GlobalShadows ~= nil then
		pcall(function()
			Svc.Lighting.GlobalShadows =
				FPSState.Original.GlobalShadows
		end)
	end

	if FPSState.Original.FogEnd ~= nil then
		pcall(function()
			Svc.Lighting.FogEnd =
				FPSState.Original.FogEnd
		end)
	end

	if FPSState.Original.ShadowSoftness ~= nil then
		pcall(function()
			Svc.Lighting.ShadowSoftness =
				FPSState.Original.ShadowSoftness
		end)
	end

	--==============================================
	-- QUALITY
	--==============================================

	if FPSState.Original.QualityLevel ~= nil then
		pcall(function()
			settings().Rendering.QualityLevel =
				FPSState.Original.QualityLevel
		end)
	end

	if FPSState.Original.MeshPartDetailLevel ~= nil then
		pcall(function()
			settings().Rendering.MeshPartDetailLevel =
				FPSState.Original.MeshPartDetailLevel
		end)
	end

	--==============================================
	-- LIGHTING TECHNOLOGY
	--==============================================

	if FPSState.Original.LightingTechnology ~= nil then
		pcall(function()
			Svc.Lighting.Technology =
				FPSState.Original.LightingTechnology
		end)
	end

	--==============================================
	-- TERRAIN
	--==============================================

	local Terrain = workspace:FindFirstChildOfClass("Terrain")

	if Terrain then

		if FPSState.Original.WaterWaveSize ~= nil then
			pcall(function()
				Terrain.WaterWaveSize =
					FPSState.Original.WaterWaveSize
			end)
		end

		if FPSState.Original.WaterWaveSpeed ~= nil then
			pcall(function()
				Terrain.WaterWaveSpeed =
					FPSState.Original.WaterWaveSpeed
			end)
		end

		if FPSState.Original.WaterReflectance ~= nil then
			pcall(function()
				Terrain.WaterReflectance =
					FPSState.Original.WaterReflectance
			end)
		end

		if FPSState.Original.WaterTransparency ~= nil then
			pcall(function()
				Terrain.WaterTransparency =
					FPSState.Original.WaterTransparency
			end)
		end

		if FPSState.Original.TerrainDecoration ~= nil then
			pcall(function()
				Terrain.Decoration =
					FPSState.Original.TerrainDecoration
			end)
		end

	end
end

--==================================================
-- MAIN FPS BOOST FUNCTION
--==================================================

local function ApplyFPSBoost(state)

	state = state == true

	--==============================================
	-- TURN ON
	--==============================================

	if state then

		-- Prevent duplicate enable
		if FPSState.Enabled then
			return
		end

		SaveFPSOriginals()

		FPSState.Enabled = true

		-- Invalidate old workers
		FPSGeneration += 1

		--==========================================
		-- APPLY IMPORTANT SETTINGS IMMEDIATELY
		--==========================================

		ApplyGlobalFPSSettings()

		--==========================================
		-- WATCH NEW OBJECTS
		--==========================================

		ConnectFPSWatcher()

		--==========================================
		-- PROCESS VISUAL EFFECTS IN BACKGROUND
		--==========================================

		StartBackgroundOptimizer()

		return
	end

	--==============================================
	-- TURN OFF
	--==============================================

	if not FPSState.Enabled then
		return
	end

	FPSState.Enabled = false

	-- Stop old background workers
	FPSGeneration += 1

	-- Stop watcher
	if FPSConnection then
		pcall(function()
			FPSConnection:Disconnect()
		end)

		FPSConnection = nil
	end

	-- Restore everything
	task.spawn(function()

		RestoreAllInstances()

		RestoreGlobalFPSSettings()

	end)
end

--==================================================
-- AUTO APPLY SAVED CONFIG
--==================================================

if FPSBoost then

	task.delay(1, function()

		if FPSBoost then
			ApplyFPSBoost(true)
		end

	end)

end


--==================================================
-- HIDE ALL EGGS FUNCTION
--==================================================

local function ToggleHideEggs(state)
	local Plots = workspace:FindFirstChild("Plots")
	if not Plots then return end

	for _, plot in ipairs(Plots:GetChildren()) do
		local eggsFolder = plot:FindFirstChild("Eggs")

		if eggsFolder then
			for _, egg in ipairs(eggsFolder:GetChildren()) do
				if egg:IsA("Model") or egg:IsA("BasePart") then
					for _, child in ipairs(egg:GetDescendants()) do
						--========================================
						-- BASEPART
						--========================================
						if child:IsA("BasePart") then
							if state then
								if child:GetAttribute("HideEgg_Transparency") == nil then
									child:SetAttribute(
										"HideEgg_Transparency",
										child.Transparency
									)
								end

								if child:GetAttribute("HideEgg_CanCollide") == nil then
									child:SetAttribute(
										"HideEgg_CanCollide",
										child.CanCollide
									)
								end

								child.Transparency = 1
								child.CanCollide = false
							else
								local originalTransparency =
									child:GetAttribute("HideEgg_Transparency")

								local originalCanCollide =
									child:GetAttribute("HideEgg_CanCollide")

								if originalTransparency ~= nil then
									child.Transparency = originalTransparency
								end

								if originalCanCollide ~= nil then
									child.CanCollide = originalCanCollide
								end
							end

							--========================================
							-- DECAL / TEXTURE
							--========================================
						elseif child:IsA("Decal") or child:IsA("Texture") then
							if state then
								if child:GetAttribute("HideEgg_Transparency") == nil then
									child:SetAttribute(
										"HideEgg_Transparency",
										child.Transparency
									)
								end

								child.Transparency = 1
							else
								local originalTransparency =
									child:GetAttribute("HideEgg_Transparency")

								if originalTransparency ~= nil then
									child.Transparency = originalTransparency
								end
							end

							--========================================
							-- VISUAL OBJECTS WITH ENABLED
							--========================================
						elseif child:IsA("BillboardGui")
									or child:IsA("SurfaceGui")
									or child:IsA("ParticleEmitter")
									or child:IsA("Beam")
									or child:IsA("Trail")
									or child:IsA("Fire")
									or child:IsA("Smoke")
									or child:IsA("Sparkles")
									or child:IsA("Light")
									or child:IsA("Highlight")
									or child:IsA("SelectionBox") then
							if state then
								if child:GetAttribute("HideEgg_Enabled") == nil then
									child:SetAttribute(
										"HideEgg_Enabled",
										child.Enabled
									)
								end

								child.Enabled = false
							else
								local originalEnabled =
									child:GetAttribute("HideEgg_Enabled")

								if originalEnabled ~= nil then
									child.Enabled = originalEnabled
								end
							end
						end
					end
				end
			end
		end
	end
end


--==================================================
-- INITIAL HIDE
--==================================================

task.spawn(function()
	task.wait(1.5)

	if HideEggs then
		ToggleHideEggs(true)
	end
end)


--==================================================
-- NEW EGGS LISTENER
--==================================================

task.spawn(function()
	local PlotsFolder = workspace:WaitForChild("Plots", 10)

	if not PlotsFolder then
		return
	end

	local function AttachEggListener(plot)
		local eggsFolder = plot:WaitForChild("Eggs", 5)

		if not eggsFolder then
			return
		end

		Bind(eggsFolder.ChildAdded, function()
			if HideEggs then
				task.wait(0.2)
				ToggleHideEggs(true)
			end
		end)
	end

	for _, plot in ipairs(PlotsFolder:GetChildren()) do
		AttachEggListener(plot)
	end

	Bind(PlotsFolder.ChildAdded, function(plot)
		AttachEggListener(plot)
	end)
end)

--// EGG CONTAINER
local RenderedEggs = workspace:WaitForChild("RenderedEggs")

--// EGG LIST
local EggNames = {
	"Volcanic Egg",
    "Headless Egg",
	"Cherub Egg",
	"Halloween Egg",    
	"Solaris Egg",
	"Blackhole Egg",
	"Bloom Egg",
	"Galaxy Egg",
	"Aurora Egg",
	"Tidal Egg",
	"Soul Egg",
	"Sinister Egg",
	"Flaming Egg",
	"Dominus Egg",
	"Asteroid Egg",
	"Skull Egg",
	"Crystal Egg",
	"Diamond Egg",
	"Golden Egg",
	"Glass Egg",
	"Ice Egg",
	"Slime Egg",
	"Flower Egg",
	"Mushroom Egg",
	"Leaf Egg",
	"Stone Egg",
	"Easter Egg",
	"Cracked Egg",
	"Brown Egg",
	"White Egg"
}

local RarityNames = {
	"Secret",
	"Ethereal",
	"Divine",
	"Mythic",
	"Legendary",
	"Epic",
	"Rare",
	"Common"
}


--==================================================
-- SHOP STOCK SYSTEM
--==================================================

local ShopStockData = {}
local ShopStockReady = false

Bind(Rem.RestockRemote.OnClientEvent, function(stockData)
	if type(stockData) ~= "table" then return end
	ShopStockData = stockData
	ShopStockReady = true
end)

task.spawn(function()
	for i = 1, 10 do
		if ShopStockReady then break end
		pcall(function() Rem.ShopStockRemote:FireServer() end)
		task.wait(2)
	end
end)

local function GetShopStock(Category, ItemName)
	local CategoryData = ShopStockData[Category]
	if type(CategoryData) ~= "table" then return 0 end
	local ItemData = CategoryData[ItemName]
	if type(ItemData) ~= "table" then return 0 end
	return tonumber(ItemData.Amount) or 0
end

local function ReduceShopStock(Category, ItemName)
	local CategoryData = ShopStockData[Category]
	if type(CategoryData) ~= "table" then return end
	local ItemData = CategoryData[ItemName]
	if type(ItemData) ~= "table" then return end
	local Amount = tonumber(ItemData.Amount) or 0
	ItemData.Amount = math.max(0, Amount - 1)
end

local GearShop = {
	"Advanced Radar",
	"Jewel Radar",
	"Royal Radar",
	"Magic Radar",
	"Angelic Radar",
	"Eternal Radar",
	"Name Tag"
}

local FoodShop = {
	"Grass",
	"Bone",
	"Meat",
	"Magic Apple",
	"Dragon Fruit"
}

local PET_LIST = {
	"Snail", "Turtle", "Sloth", "Axolotl", "Koala",
	"Capybara", "Chicken", "Pig", "Elephant", "Panda",
	"Kangaroo", "Deer", "Spider", "Crocodile", "Gorilla",
	"Snake", "Horse", "Wolf", "Shark", "Llama", "Platypus",
	"Lion", "Bison", "Ostrich", "Fennec", "Fox","Boar",
    "Okapi", "Giraffe", "Pumpkin Toad", "White Tiger",
    "Cheetah", "Anaconda", "Ghostweaver", "Monkey", "Black Stallion",
    "Unicorn", "Flamingo", "Scorpion", "TRex", "Ghost Cat",
    "Grizzly Bear", "Phoenix", "Jackalope", "Vulture", "Peacock",
    "Black Panther", "Cerberus", "El Toro", "Komodo", "Frankenstein Gorilla",
    "Dryad", "Qilin", "Raptor", "Stone Golem", "Kitsune", "Mantis",
    "Wukong", "Fenrir", "Sabertooth", "Manticore", "Dragon",
    "Skeletal Dragon", "Hellhound", "Griffin", "Hydra Dragon", "Headless Horseman", "Volkaris"
}

local FUSE_PET_LIST = {
    "Horse", "Wolf", "Shark", "Llama", "Platypus",
	"Lion", "Bison", "Ostrich", "Fennec", "Fox","Boar",
    "Okapi", "Giraffe", "Pumpkin Toad", "White Tiger",
    "Cheetah", "Anaconda", "Ghostweaver", "Monkey", "Black Stallion",
    "Unicorn", "Flamingo", "Scorpion", "TRex", "Ghost Cat",
    "Grizzly Bear", "Phoenix", "Jackalope", "Vulture", "Peacock",
    "Black Panther", "Cerberus", "El Toro", "Komodo", "Frankenstein Gorilla",
    "Dryad", "Qilin", "Raptor", "Stone Golem", "Kitsune", "Mantis",
    "Wukong", "Fenrir", "Sabertooth", "Manticore", "Dragon",
    "Skeletal Dragon", "Hellhound", "Griffin", "Hydra Dragon", "Headless Horseman", "Volkaris"
}

local EggPriority = {}
for Index, Name in ipairs(EggNames) do
	EggPriority[Name] = Index
end

local RarityPriority = {}
for Index, Name in ipairs(RarityNames) do
	RarityPriority[Name] = Index
end

local platformCFrame = CFrame.new(
	-4917.03369, 41286.2031, -3704.17529, -0.76919955, 5.31099609e-08, 0.639008641, 1.79985058e-08, 1, -6.14475582e-08, -0.639008641, -3.57642307e-08, -0.76919955
)

local platform = Instance.new("Part")
platform.Name = "ClientPlatform"
platform.Size = Vector3.new(10, 1, 10)
platform.CFrame = platformCFrame
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 0
platform.Color = Color3.fromRGB(255, 0, 0)
platform.Material = Enum.Material.SmoothPlastic
platform.Parent = workspace


--==================================================
-- WINDOW
--==================================================

local Window = WindUI:CreateWindow({
	Title = "LUNA HUB",
	Author = "RIDE A PET",
	Icon = "rbxassetid://130686992475603",
	IconSize = 35,
	IconRadius = 10,

	Theme = ThemeName,

	ToggleKey = Enum.KeyCode.F,
	OpenButton = {
		Enabled = false, -- Disabled standard button to use custom floating logo
		OnlyMobile = false
	},
})

--==================================================
-- VERSION + CHANGE LOGS
--==================================================

-- >>> DITO LANG KA MAGBABAGO NG VERSION <<<
local ScriptVersion = "1.0.2.8"

-- >>> DITO MO ISULAT YUNG CHANGE LOGS <<<
local ChangeLogs = [[
* Delivery Failed?
* Slow pets = Low tween
* Fast pets = High tween

Changelogs:
* Fixed prioritize high value candies 
* Bug fixed on stuck on fuse machine
* Bug fixed on stock tweening
* Fixed Minor bugs



]]

local MaxShows = 4 -- ilang beses lang lalabas ang change logs

Window:Tag({
	Title = "v." .. ScriptVersion,
	Color = "ElementBackground",
})

do
	local LogFile = ConfigFolder .. "/ChangeLog_Seen.json"
	local data = { Version = "", Count = 0 }

	-- basahin yung na-save na data
	if isfile and readfile and isfile(LogFile) then
		local ok, res = pcall(function()
			return Svc.HttpService:JSONDecode(readfile(LogFile))
		end)
		if ok and type(res) == "table" then
			data.Version = tostring(res.Version or "")
			data.Count = tonumber(res.Count) or 0
		end
	end

	-- kapag nag-iba ang version, i-reset ang count
	if data.Version ~= ScriptVersion then
		data.Version = ScriptVersion
		data.Count = 0
	end

	-- ipakita lang kung hindi pa umabot sa 3
	if data.Count < MaxShows then
		data.Count += 1

		EnsureFolders()
		if writefile then
			pcall(function()
				writefile(LogFile, Svc.HttpService:JSONEncode(data))
			end)
		end

		task.delay(1.5, function()
			if not LH.Alive then return end
			local shown = pcall(function()
				Window:Dialog({
					Title = "Change Logs v." .. ScriptVersion,
					Content = ChangeLogs,
					Buttons = {
						{
							Title = "OK",
							Callback = function() end,
						},
					},
				})
			end)
			-- fallback kung walang Dialog sa WindUI version mo
			if not shown then
				pcall(function()
					WindUI:Notify({
						Title = "Change Logs v." .. ScriptVersion,
						Content = ChangeLogs,
						Duration = 10,
					})
				end)
			end
		end)
	end
end

--==================================================
-- CUSTOM FLOATING LOGO BUTTON
--==================================================

local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "LunaHubFloatingGui"
FloatingGui.ResetOnSpawn = false

if gethui then
	FloatingGui.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(FloatingGui)
	FloatingGui.Parent = game:GetService("CoreGui")
else
	FloatingGui.Parent = Player:WaitForChild("PlayerGui")
end

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Name = "FloatingLogo"
FloatingButton.Size = UDim2.new(0, 50, 0, 50)
FloatingButton.Position = UDim2.new(0.05, 0, 0.2, 0)
FloatingButton.Image = "rbxassetid://130686992475603"

FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatingButton.BackgroundTransparency = 0

FloatingButton.Parent = FloatingGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatingButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 0, 0)
UIStroke.Thickness = 2.5 -- Mas makapal/bold na border
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
UIStroke.Parent = FloatingButton

local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
	local delta = input.Position - dragStart
	FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

FloatingButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = FloatingButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

FloatingButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

Bind(Svc.UserInputService.InputChanged, function(input)
	if input == dragInput and dragging then
		updateInput(input)
	end
end)

FloatingButton.MouseButton1Click:Connect(function()
	if Window then
		Window:Toggle()
	end
end)


--==================================================
-- TABS
--==================================================

Tabs.Tab1 = Window:Tab({ Title = "HOME", Icon = "warehouse" })
Tabs.Tab2 = Window:Tab({ Title = "FARM", Icon = "egg" })
Tabs.Tab3 = Window:Tab({ Title = "SHOP", Icon = "shopping-cart" })
Tabs.Tab4 = Window:Tab({ Title = "EVENT", Icon = "hourglass" })
Tabs.Tab5 = Window:Tab({ Title = "VISUAL", Icon = "eye" })
Tabs.Tab6 = Window:Tab({ Title = "Tracker", Icon = "radar" })
Tabs.Tab7 = Window:Tab({ Title = "CONFIG", Icon = "file-cog" })
Tabs.Tab8 = Window:Tab({ Title = "WEBHOOK", Icon = "send" })
Tabs.Tab9 = Window:Tab({ Title = "SETTINGS", Icon = "settings" })


--==================================================
-- TAB 1 (HOME)
--==================================================

Tabs.Tab1:Paragraph({
	Title = "Discord",
	Desc = "Join our Discord Community",

	Buttons = {
		{
			Title = "Discord",
			Callback = function()
				local DiscordLink = "discord.gg/vENCWk39f7"

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

Secs.HomeSection1 = Tabs.Tab1:Section({
	Title = "Teleport",
	Icon = "compass",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

local TeleportDestinations = {
	["Market"] = CFrame.new(148.190125, 40316.3672, 916.778992, 0.728601754, 4.76895323e-08, -0.684937537, -8.04378715e-08, 1, -1.59396176e-08, 0.684937537, 6.67085516e-08, 0.728601754),
	["Volcano Entrance"] = CFrame.new(-4917.03369, 41286.2031, -3704.17529, -0.76919955, 5.31099609e-08, 0.639008641, 1.79985058e-08, 1, -6.14475582e-08, -0.639008641, -3.57642307e-08, -0.76919955),
	["Volcano Lava"] = CFrame.new( -5072.89453, 41405.6055, -3427.5437, 0.977811277, -6.61095925e-08, 0.209487602, 8.22212627e-08, 1, -6.82011105e-08, -0.209487602, 8.39121483e-08, 0.977811277),
	["Fuse Machine"] = CFrame.new( 388.936401, 40323.3242, 766.440552, 0.999475718, 4.89425434e-09, 0.0323778726, -4.80393725e-09, 1, -2.86726709e-09, -0.0323778726, 2.71022249e-09, 0.999475718),
	["Big Tree"] = CFrame.new( 2319.68896, 41319.1094, 3053.4519, -0.657276988, -1.62866147e-08, 0.753649116, -1.50426676e-08, 1, 8.49123882e-09, -0.753649116, -5.75579762e-09, -0.657276988),
	["Pyramid"] = CFrame.new( -2923.52173, 40322.625, -890.822144, 0.667084873, -4.14334913e-08, -0.744981706, -2.7274055e-08, 1, -8.00390154e-08, 0.744981706, 7.37114902e-08, 0.667084873),
    ["Halloween Event"] = CFrame.new( -46040.7734, 40371.4453, -20327.2539, -0.780875802, 0, -0.62468636, 0, 1, 0, 0.62468636, 0, -0.780875802),
    ["Drop Off Candy"] = CFrame.new( -45842.9766, 40375.2734, -20118.6797, -0.99513644, -2.46834375e-08, -0.0985061005, -2.63667683e-08, 1, 1.57867746e-08, 0.0985061005, 1.8307281e-08, -0.99513644),

}

local TeleportDestinationNames = { "My Plot", "Market", "Volcano Entrance", "Volcano Lava", "Fuse Machine", "Big Tree", "Pyramid", "Halloween Event", "Drop Off Candy" }
local SelectedTeleportDestination = "Market"

Secs.HomeSection1:Dropdown({
	Title = "Teleportation",
	Desc = "Choose a destination to teleport to",
	Values = TeleportDestinationNames,
	Multi = false,
	Value = "My Plot",
	AllowNone = false,

	Callback = function(value)
		if type(value) == "table" then
			value = value[1]
		end
		SelectedTeleportDestination = value
	end,
})

Secs.HomeSection1:Button({
	Title = "TP to Destination",
	Justify = "Center",
	Callback = function()
		if SelectedTeleportDestination == "My Plot" then
			TeleportToMyPlot()
			return
		end

		local char = LocalPlayer.Character
		local destination = TeleportDestinations[SelectedTeleportDestination]
		if char and destination then
			char:PivotTo(destination)
		end
	end,
})


--==================================================
-- TAB 2 (FARM)
--==================================================

Secs.EggSection = Tabs.Tab2:Section({
	Title = "Auto Farm",
	Icon = "egg",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

UIElements.SelectedRarities = Secs.EggSection:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to auto farm",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedRarities,
	AllowNone = true,

	Callback = function(value)
		SelectedRarities = value
		ConfigData.SelectedRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedEggs = Secs.EggSection:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to auto farm",
	Values = EggNames,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedEggs,
	AllowNone = true,

	Callback = function(value)
		SelectedEggs = value
		ConfigData.SelectedEggs = value
		SaveConfig()
	end,
})

UIElements.MinWeightInput = Secs.EggSection:Input({
	Title = "Weight Threshold",
	Desc = "Skip eggs below minimum kg (e.g.100) ",
	Value = (ConfigData.MinWeightText and ConfigData.MinWeightText ~= "") and ConfigData.MinWeightText or "0",
	Placeholder = "0",

	Callback = function(text)
		LH.MinKG = LH.ParseKG(text)

		local clean = tostring(text or "")
		if LH.MinKG <= 0 and clean ~= "0" then
			clean = "0"
			SetUIValue(UIElements.MinWeightInput, "0")
		end
		ConfigData.MinWeightText = clean
		SaveConfig()
	end,
})

UIElements.FarmTweenSpeed = Secs.EggSection:Slider({
	Title = "Tween Speed",
    Desc = "Fast speed pet = High tween speed | Low speed pet = Low tween speed ",
	Step = 1,
	Value = {
		Min = 100,
		Max = 1000,
		Default = math.clamp(tonumber(ConfigData.FarmTweenSpeed) or 100, 100, 1000),
	},
	Callback = function(value)
		LH.FarmTweenSpeed = math.clamp(tonumber(value) or 100, 100, 1000)
		ConfigData.FarmTweenSpeed = LH.FarmTweenSpeed
		SaveConfig()
	end,
})

UIElements.AutoVolcanoDip = Secs.EggSection:Toggle({
	Title = "Auto Volcano Dip",
	Desc = "Dips picked up egg into Volcano Lava before bringing to plot",
	Value = ConfigData.AutoVolcanoDip,

	Callback = function(value)
		AutoVolcanoDip = value
		ConfigData.AutoVolcanoDip = value
		SaveConfig()
	end,
})

UIElements.AutoPickup = Secs.EggSection:Toggle({
	Title = "Auto Farm",
	Desc = "Automatically get the egg and proceed to your plot",
	Value = ConfigData.AutoPickup,

	Callback = function(value)
		AutoPickup = value
		ConfigData.AutoPickup = value
		SaveConfig()
	end,
})



Secs.EggSection1 = Tabs.Tab2:Section({
	Title = "Auto Place & Hatch",
	Icon = "sparkles",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedPlaceRarities = Secs.EggSection1:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to place in your plot",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedPlaceRarities,
	AllowNone = true,
	Callback = function(value)
		SelectedPlaceRarities = value
		ConfigData.SelectedPlaceRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedPlaceEgg = Secs.EggSection1:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to place in your plot",
	Values = EggNames,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedPlaceEgg,
	AllowNone = true,
	Callback = function(value)
		SelectedPlaceEgg = value
		ConfigData.SelectedPlaceEgg = value
		SaveConfig()
	end,
})

UIElements.AutoPlaceEgg = Secs.EggSection1:Toggle({
	Title = "Auto Place Eggs",
	Desc = "Automatically place the selected eggs in your plot",
	Value = ConfigData.AutoPlaceEgg,

	Callback = function(value)
		AutoPlaceEgg = value
		ConfigData.AutoPlaceEgg = value
		SaveConfig()
	end,
})

UIElements.SelectedHatchRarities = Secs.EggSection1:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to hatch eggs",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedHatchRarities,
	AllowNone = true,
	Callback = function(value)
		SelectedHatchRarities = value
		ConfigData.SelectedHatchRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedHatchEggs = Secs.EggSection1:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to hatch eggs",
	Values = EggNames,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedHatchEggs,
	AllowNone = true,
	Callback = function(value)
		SelectedHatchEggs = value
		ConfigData.SelectedHatchEggs = value
		SaveConfig()
	end,
})

UIElements.AutoHatchSelectedEggs = Secs.EggSection1:Toggle({
	Title = "Auto Hatch Eggs",
	Desc = "Automatically hatch selected eggs",
	Value = ConfigData.AutoHatchSelectedEggs,

	Callback = function(value)
		AutoHatchSelectedEggs = value
		ConfigData.AutoHatchSelectedEggs = value
		SaveConfig()
	end,
})

UIElements.AutoHatchEgg = Secs.EggSection1:Toggle({
	Title = "Auto Hatch All Eggs",
	Desc = "Automatically hatch all ready eggs in your plot",
	Value = ConfigData.AutoHatchEgg,

	Callback = function(value)
		AutoHatchEgg = value
		ConfigData.AutoHatchEgg = value
		SaveConfig()
	end,
})

UIElements.AutoEquipBestPet = Secs.EggSection1:Toggle({
	Title = "Auto Equip Best Pet",
	Desc = "Automatically equip the best pet (go to your plot)",
	Value = ConfigData.AutoEquipBestPet,

	Callback = function(value)
		AutoEquipBestPet = value
		ConfigData.AutoEquipBestPet = value
		SaveConfig()
	end,
})

Secs.EggSection2 = Tabs.Tab2:Section({
	Title = "Upgrades",
	Icon = "trending-up",
	Box = true,
	BoxBorder = true,
})

UIElements.AutoUpgradeHatchLuck = Secs.EggSection2:Toggle({
	Title = "Auto Upgrade Hatch Luck",
	Desc = "Automatically upgrade hatch luck by 1x",
	Value = ConfigData.AutoUpgradeHatchLuck,

	Callback = function(value)
		AutoUpgradeHatchLuck = value
		ConfigData.AutoUpgradeHatchLuck = value
		SaveConfig()
	end,
})

UIElements.AutoUpgradeHatchLuckMax = Secs.EggSection2:Toggle({
	Title = "Auto Upgrade Hatch Luck (Max)",
	Desc = "Automatically upgrade hatch luck by max",
	Value = ConfigData.AutoUpgradeHatchLuckMax,

	Callback = function(value)
		AutoUpgradeHatchLuckMax = value
		ConfigData.AutoUpgradeHatchLuckMax = value
		SaveConfig()
	end,
})

UIElements.AutoRebirth = Secs.EggSection2:Toggle({
	Title = "Auto Rebirth",
	Value = ConfigData.AutoRebirth,

	Callback = function(value)
		AutoRebirth = value
		ConfigData.AutoRebirth = value
		SaveConfig()
	end,
})

UIElements.AutoClaimIndex = Secs.EggSection2:Toggle({
	Title = "Auto Claim Index Reward",
	Value = ConfigData.AutoClaimIndex,

	Callback = function(value)
		AutoClaimIndex = value
		ConfigData.AutoClaimIndex = value
		SaveConfig()
	end,
})


--==================================================
-- TAB 3 (SHOP)
--==================================================

Secs.ShopSection = Tabs.Tab3:Section({
	Title = "Gear Shop",
	Icon = "wrench",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedGear = Secs.ShopSection:Dropdown({
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

UIElements.Autobuygear = Secs.ShopSection:Toggle({
	Title = "Auto Buy Gears",
	Desc = "Automatically buy selected gear",
	Value = ConfigData.Autobuygear,

	Callback = function(value)
		Autobuygear = value
		ConfigData.Autobuygear = value
		SaveConfig()
	end,
})

Secs.ShopSection1 = Tabs.Tab3:Section({
	Title = "Food Shop",
	Icon = "apple",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedFood = Secs.ShopSection1:Dropdown({
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

UIElements.Autobuyfood = Secs.ShopSection1:Toggle({
	Title = "Auto Buy Foods",
	Desc = "Automatically buy selected food",
	Value = ConfigData.Autobuyfood,

	Callback = function(value)
		Autobuyfood = value
		ConfigData.Autobuyfood = value
		SaveConfig()
	end,
})

Secs.ShopSection2 = Tabs.Tab3:Section({
	Title = "Sell Shop",
	Icon = "dollar-sign",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedSellRarities = Secs.ShopSection2:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to auto sell",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedSellRarities,
	AllowNone = true,

	Callback = function(value)
		SelectedSellRarities = value
		ConfigData.SelectedSellRarities = SelectedSellRarities
		SaveConfig()
	end,
})

UIElements.SelectedPetToSell = Secs.ShopSection2:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to auto sell",
	Values = PET_LIST,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedPetToSell,
	AllowNone = true,

	Callback = function(value)
		SelectedPetToSell = value
		ConfigData.SelectedPetToSell = SelectedPetToSell
		SaveConfig()
	end,
})

UIElements.AutoSellPet = Secs.ShopSection2:Toggle({
	Title = "Auto Sell Pets",
	Desc = "Automatically sell selected pets",
	Value = ConfigData.AutoSellPet,

	Callback = function(value)
		AutoSellPet = value
		ConfigData.AutoSellPet = value
		SaveConfig()
	end,
})

UIElements.AutoSellAllPets = Secs.ShopSection2:Toggle({
	Title = "Auto Sell All Pets",
	Desc = "Automatically sell all pets in inventory",
	Value = ConfigData.AutoSellAllPets,

	Callback = function(value)
		AutoSellAllPets = value
		ConfigData.AutoSellAllPets = value
		SaveConfig()
	end,
})

Secs.FavSection = Tabs.Tab3:Section({
	Title = "Favorite Pet",
	Icon = "heart",
	Box = true,
	BoxBorder = true,
})

UIElements.SelectedFavPet = Secs.FavSection:Dropdown({
	Title = "Select Pet to Favorite",
	Desc = "Choose which pets to auto favorite",
	Values = PET_LIST,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedFavPet,
	AllowNone = true,

	Callback = function(value)
		SelectedFavPet = value
		ConfigData.SelectedFavPet = value
		SaveConfig()
	end,
})

UIElements.AutoFavoritePet = Secs.FavSection:Toggle({
	Title = "Auto Favorite Pet",
	Desc = "Automatically favorites selected pets then stops when finished",
	Value = ConfigData.AutoFavoritePet,

	Callback = function(value)
		AutoFavoritePet = value
		ConfigData.AutoFavoritePet = value
		SaveConfig()
		if value then
			task.spawn(ProcessAutoFavorite)
		end
	end,
})


--==================================================
-- TAB 4 (EVENT)
--==================================================

Secs.FuseSection = Tabs.Tab4:Section({
	Title = "Pet Fusion",
	Icon = "flask-conical",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

UIElements.SelectedFusePets = Secs.FuseSection:Dropdown({
	Title = "Pets to Fuse",
	Values = FUSE_PET_LIST,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedFusePets,
	AllowNone = true,

	Callback = function(value)
		SelectedFusePets = value
		ConfigData.SelectedFusePets = value
		SaveConfig()
	end,
})

UIElements.AutoFuse = Secs.FuseSection:Toggle({
	Title = "Auto Fuse",
	Value = ConfigData.AutoFuse == true,

	Callback = function(value)
		AutoFuse = value
		ConfigData.AutoFuse = value
		SaveConfig()
	end,
})

UIElements.AutoClaimFusedPets = Secs.FuseSection:Toggle({
	Title = "Auto Claim Fused Pets",
	Value = ConfigData.AutoClaimFusedPets == true,

	Callback = function(value)
		AutoClaimFusedPets = value
		ConfigData.AutoClaimFusedPets = value
		SaveConfig()
	end,
})

Secs.FuseSection1 = Tabs.Tab4:Section({
	Title = "Halloween Event",
	Icon = "candy",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

UIElements.AutoCandy = Secs.FuseSection1:Toggle({
	Title = "Auto Collect Candy",
	Value = ConfigData.AutoCandy == true,

	Callback = function(value)
		LH.AutoCandy = value
		ConfigData.AutoCandy = value
		SaveConfig()
	end,
})

UIElements.CandyMoveMode = Secs.FuseSection1:Dropdown({
	Title = "Candy Delivery Mode",
	Desc = "Tween = lipad pauwi sa Candy Home | Instant TP = teleport agad sa Candy Home",
	Values = { "Tween", "Instant TP" },
	Multi = false,
	Value = LH.CandyMoveMode,
	AllowNone = false,

	Callback = function(value)
		if type(value) == "table" then
			value = value[1]
		end
		if value ~= "Tween" and value ~= "Instant TP" then return end
		LH.CandyMoveMode = value
		ConfigData.CandyMoveMode = value
		SaveConfig()
	end,
})

UIElements.CandyTweenSpeed = Secs.FuseSection1:Slider({
	Title = "Tween Speed",
     Desc = "Fast speed pet = High tween speed | Low speed pet = Low tween speed ",
	Step = 1,
	Value = {
		Min = 100,
		Max = 1000,
		Default = math.clamp(tonumber(ConfigData.CandyTweenSpeed) or 100, 100, 1000),
	},
	Callback = function(value)
		LH.CandyTweenSpeed = math.clamp(tonumber(value) or 100, 100, 1000)
		ConfigData.CandyTweenSpeed = LH.CandyTweenSpeed
		SaveConfig()
	end,
})

UIElements.AutoKnock = Secs.FuseSection1:Toggle({
	Title = "Auto Knock Doors",
	Value = ConfigData.AutoKnock == true,

	Callback = function(value)
		LH.AutoKnock = value
		ConfigData.AutoKnock = value
		SaveConfig()
	end,
})

UIElements.AutoRitual = Secs.FuseSection1:Toggle({
	Title = "Auto Ritual",
	Value = ConfigData.AutoRitual == true,

	Callback = function(value)
		LH.AutoRitual = value
		ConfigData.AutoRitual = value
		SaveConfig()
	end,
})

UIElements.AutoHaEgg = Secs.FuseSection1:Toggle({
	Title = "Auto Buy Halloween Egg",
	Value = ConfigData.AutoHaEgg == true,

	Callback = function(value)
		LH.AutoHaEgg = value
		ConfigData.AutoHaEgg = value
		SaveConfig()
	end,
})


--==================================================
-- TAB 5 (VISUAL)
--==================================================

Secs.VisualSection = Tabs.Tab5:Section({
	Title = "ESP Settings",
	Icon = "eye",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

UIElements.SelectedESPRarities = Secs.VisualSection:Dropdown({
	Title = "Rarity Filter",
	Desc = "Choose rarity to display ESP",
	Values = RarityNames,
	Multi = true,
	Value = ConfigData.SelectedESPRarities,
	AllowNone = true,

	Callback = function(value)
		SelectedESPRarities = value
		ConfigData.SelectedESPRarities = value
		SaveConfig()
	end,
})

UIElements.SelectedESPEggs = Secs.VisualSection:Dropdown({
	Title = "Category Filter",
	Desc = "Choose category to display ESP",
	Values = EggNames,
	SearchBarEnabled = true,
	Multi = true,
	Value = ConfigData.SelectedESPEggs,
	AllowNone = true,

	Callback = function(value)
		SelectedESPEggs = value
		ConfigData.SelectedESPEggs = value
		SaveConfig()
	end,
})

UIElements.ESPEnabled = Secs.VisualSection:Toggle({
	Title = "Egg ESP",
	Desc = "Enable esp and distance for selected eggs",
	Value = ConfigData.ESPEnabled,

	Callback = function(value)
		ESPEnabled = value
		ConfigData.ESPEnabled = value
		SaveConfig()
	end,
})


--==================================================
-- TAB 6 (TRACKER)
--==================================================

Secs.EggsSection = Tabs.Tab6:Section({
	Title = "Egg Tracker",
	Icon = "radar",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

local LiveEggParagraph = Secs.EggsSection:Paragraph({
	Title = "Tracked Eggs (0)",
	Desc = "Scanning workspace for rendered eggs...",
})

-- Rarity colors (same as ESP / GetEggColor)
local TrackerRarityColors = {
	Common    = Color3.fromRGB(255, 255, 255),
	Rare      = Color3.fromRGB(85, 170, 255),
	Epic      = Color3.fromRGB(170, 85, 255),
	Legendary = Color3.fromRGB(255, 215, 0),
	Mythic    = Color3.fromRGB(255, 50, 50),
	Divine    = Color3.fromRGB(255, 255, 153),
	Ethereal  = Color3.fromRGB(255, 0, 127),
	Eternal   = Color3.fromRGB(255, 0, 127),
}

local TrackerWeightCache = setmetatable({}, { __mode = "k" })
local TrackerMissingWeight = false

-- siguraduhing naka-ON ang RichText sa labels ng paragraph para gumana ang kulay
local function EnableParagraphRichText()
	pcall(function()
		local frame = LiveEggParagraph.ElementFrame
		if not frame then return end
		for _, d in ipairs(frame:GetDescendants()) do
			if d:IsA("TextLabel") then
				d.RichText = true
			end
		end
	end)
end

local function UpdateRenderedEggList()
	local Eggs = RenderedEggs:GetChildren()
	local TotalCount = #Eggs

	if TotalCount == 0 then
		TrackerMissingWeight = false
		LiveEggParagraph:SetTitle("Tracked Eggs (0)")
		LiveEggParagraph:SetDesc("No eggs currently rendered on map.")
		return
	end

	TrackerMissingWeight = false
	local Entries = {}

	for _, Egg in ipairs(Eggs) do
		local Name = Egg.Name
		local EggInfo = Mods.Eggs_mData[Name]
		local Rarity = EggInfo and EggInfo.Rarity or "Common"

		-- weight (same helper ng ESP: converted na sa kg na ipinapakita ng game)
		local WeightText = TrackerWeightCache[Egg]
		if not WeightText then
			local ok, text = pcall(function()
				return LH.GetEggWeightText(Egg)
			end)
			if ok and text then
				TrackerWeightCache[Egg] = text
				WeightText = text
			end
		end
		if not WeightText then
			TrackerMissingWeight = true -- retry later (ESP style)
		end

		table.insert(Entries, {
			Name = Name,
			Rarity = Rarity,
			Weight = WeightText or "? kg",
		})
	end

	table.sort(Entries, function(a, b)
		local priorityA = EggPriority[a.Name] or 999
		local priorityB = EggPriority[b.Name] or 999
		if priorityA ~= priorityB then
			return priorityA < priorityB
		end
		return a.Name < b.Name
	end)

	local Lines = {}
	for _, Entry in ipairs(Entries) do
		local Color = TrackerRarityColors[Entry.Rarity] or Color3.fromRGB(255, 255, 255)
		-- format: Bloom Egg [Divine] 2.95 kg  (rarity lang ang may kulay)
		table.insert(Lines, string.format(
			'%s <font color="#%s">[%s]</font> %s',
			Entry.Name, Color:ToHex(), Entry.Rarity, Entry.Weight
		))
	end

	LiveEggParagraph:SetTitle(string.format("Tracked Eggs (%d)", TotalCount))
	LiveEggParagraph:SetDesc(table.concat(Lines, "\n"))
	EnableParagraphRichText()
end

Bind(RenderedEggs.ChildAdded, function() task.defer(UpdateRenderedEggList) end)
Bind(RenderedEggs.ChildRemoved, function() task.defer(UpdateRenderedEggList) end)

task.spawn(function()
	task.wait(1)
	UpdateRenderedEggList()

	-- kung may egg na wala pang weight, ulitin kada 2s hanggang makuha
	while LH.Alive do
		task.wait(1)
		if TrackerMissingWeight then
			UpdateRenderedEggList()
		end
	end
end)


--==================================================
-- TAB 7 (CONFIG)
--==================================================

Secs.ConfigSection = Tabs.Tab7:Section({
	Title = "Config",
	Icon = "file-cog",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

Secs.ConfigSection:Button({
	Title = "Reset Config",
	Desc = "Reset all your saved configurations",

	Callback = function()
		isResetting = true

		if delfile and isfile and isfile(ConfigFile) then
			pcall(function() delfile(ConfigFile) end)
		end

		if FPSBoost then
			FPSBoost = false
			ApplyFPSBoost(false)
		end

		-- FARM
		SelectedRarities = {}
		SelectedEggs = {}
		LH.MinKG = 0
		AutoVolcanoDip = false
		AutoPickup = false
		SelectedPlaceRarities = {}
		SelectedPlaceEgg = {}
		AutoPlaceEgg = false
		SelectedHatchRarities = {}
		SelectedHatchEggs = {}
		AutoHatchSelectedEggs = false
		AutoHatchEgg = false
		AutoEquipBestPet = false
		AutoUpgradeHatchLuck = false
		AutoUpgradeHatchLuckMax = false
		AutoRebirth = false
		AutoClaimIndex = false
		LH.AutoCandy = false
		LH.CandyMoveMode = "Tween"
		LH.AutoKnock = false
		LH.AutoHaEgg = false
		LH.AutoRitual = false

		-- SHOP
		SelectedGear = {}
		Autobuygear = false
		SelectedFood = {}
		Autobuyfood = false
		SelectedSellRarities = {}
		SelectedPetToSell = {}
		AutoSellPet = false
		AutoSellAllPets = false
		SelectedFavPet = {}
		AutoFavoritePet = false

		-- FUSE
		SelectedFusePets = {}
		AutoFuse = false
		AutoClaimFusedPets = false

		-- VISUAL
		SelectedESPRarities = {}
		SelectedESPEggs = {}
		ESPEnabled = false

		-- WEBHOOK
		WebhookUrl = ""
		WebhookEnabled = false

		-- SETTINGS
		FPSBoost = false
		HideEggs = false
		SelectedTheme = "Dark"
		ThemeEnabled = false

		-- PLAYER
		LH.StopMovement()

		ConfigData = NewDefaultConfig()

		-- ibalik ang laman ng UI sa default
		-- FARM
		SetUIValue(UIElements.SelectedRarities, {})
		SetUIValue(UIElements.SelectedEggs, {})
		SetUIValue(UIElements.MinWeightInput, "0")
		SetUIValue(UIElements.AutoVolcanoDip, false)
		SetUIValue(UIElements.AutoPickup, false)
		SetUIValue(UIElements.SelectedPlaceRarities, {})
		SetUIValue(UIElements.SelectedPlaceEgg, {})
		SetUIValue(UIElements.AutoPlaceEgg, false)
		SetUIValue(UIElements.SelectedHatchRarities, {})
		SetUIValue(UIElements.SelectedHatchEggs, {})
		SetUIValue(UIElements.AutoHatchSelectedEggs, false)
		SetUIValue(UIElements.AutoHatchEgg, false)
		SetUIValue(UIElements.AutoEquipBestPet, false)
		SetUIValue(UIElements.AutoUpgradeHatchLuck, false)
		SetUIValue(UIElements.AutoUpgradeHatchLuckMax, false)
		SetUIValue(UIElements.AutoRebirth, false)
		SetUIValue(UIElements.AutoClaimIndex, false)
		SetUIValue(UIElements.AutoCandy, false)
		SetUIValue(UIElements.CandyMoveMode, "Tween")
		SetUIValue(UIElements.AutoKnock, false)
		SetUIValue(UIElements.AutoHaEgg, false)
		SetUIValue(UIElements.AutoRitual, false)

		-- SHOP
		SetUIValue(UIElements.SelectedGear, {})
		SetUIValue(UIElements.Autobuygear, false)
		SetUIValue(UIElements.SelectedFood, {})
		SetUIValue(UIElements.Autobuyfood, false)
		SetUIValue(UIElements.SelectedSellRarities, {})
		SetUIValue(UIElements.SelectedPetToSell, {})
		SetUIValue(UIElements.AutoSellPet, false)
		SetUIValue(UIElements.AutoSellAllPets, false)
		SetUIValue(UIElements.SelectedFavPet, {})
		SetUIValue(UIElements.AutoFavoritePet, false)

		-- FUSE
		SetUIValue(UIElements.SelectedFusePets, {})
		SetUIValue(UIElements.AutoFuse, false)
		SetUIValue(UIElements.AutoClaimFusedPets, false)

		-- VISUAL
		SetUIValue(UIElements.SelectedESPRarities, {})
		SetUIValue(UIElements.SelectedESPEggs, {})
		SetUIValue(UIElements.ESPEnabled, false)

		-- WEBHOOK
		SetUIValue(UIElements.WebhookUrlInput, "")
		SetUIValue(UIElements.WebhookEnabled, false)

		-- SETTINGS
		SetUIValue(UIElements.FPSBoost, false)
		SetUIValue(UIElements.HideEggs, false)
		SetUIValue(UIElements.ThemeSelect, "Dark")
		SetUIValue(UIElements.ThemeEnabled, false)
		SetUIValue(UIElements.noclip, false)
		SetUIValue(UIElements.infjump, false)
		pcall(function() WindUI:SetTheme("Dark") end)

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
-- TAB 8 (WEBHOOK)
--==================================================

Secs.WebhookSection = Tabs.Tab8:Section({
	Title = "Discord Webhook",
	Icon = "send",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

UIElements.WebhookUrlInput = Secs.WebhookSection:Input({
	Title = "Webhook URL",
	Desc = "Paste your Discord Webhook URL here",
	Value = ConfigData.WebhookUrl or "",
	Placeholder = "https://discord.com/api/webhooks/...",
	Callback = function(text)
		WebhookUrl = text
		ConfigData.WebhookUrl = text
		SaveConfig()
	end,
})

UIElements.WebhookEnabled = Secs.WebhookSection:Toggle({
	Title = "Enable Webhook Notifications",
	Desc = "Send Discord notification whenever an egg is collected",
	Value = ConfigData.WebhookEnabled,

	Callback = function(value)
		WebhookEnabled = value
		ConfigData.WebhookEnabled = value
		SaveConfig()
	end,
})

Secs.WebhookSection:Button({
	Title = "Test Webhook",
	Justify = "Center",
	Icon = "",
	Callback = function()
		if WebhookUrl ~= "" then
			SendWebhookNotification("Test Egg")
			WindUI:Notify({
				Title = "Webhook Test",
				Content = "Sent test message to Discord!",
				Icon = "solar:bell-bold",
				Duration = 3,
				CanClose = true,
			})
		else
			WindUI:Notify({
				Title = "Webhook Error",
				Content = "Please enter a valid Webhook URL first.",
				Icon = "solar:bell-bold",
				Duration = 3,
				CanClose = true,
			})
		end
	end,
})


--==================================================
-- TAB 9 (SETTINGS)
--==================================================
LH.ScriptURL = "https://raw.githubusercontent.com/Sayrealll/LunaHubX/refs/heads/main/test.lua"
do
	local ok, env = pcall(function() return getgenv() end)
	if ok and type(env) == "table" and type(env.LunaHubURL) == "string" and env.LunaHubURL ~= "" then
		LH.ScriptURL = env.LunaHubURL
	end
end
LH.HasURL = function()
	return type(LH.ScriptURL) == "string" and LH.ScriptURL:match("^https?://") ~= nil
end
LH.AutoExecPaths = { "../autoexec/LunaHub_AutoLoad.lua", "autoexec/LunaHub_AutoLoad.lua" }
LH.QueueFn = queue_on_teleport or queueonteleport
	or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
LH.Queued = false
LH.AutoExecReady = false

LH.BuildLoaderStub = function(forAutoExec)
	local s = ""
	if forAutoExec then
		-- ang autoexec folder ay tumatakbo sa lahat ng game: ito lang ang game na ito ang mag-load
		s = s .. string.format("if game.GameId ~= %d then return end\n", game.GameId)
	end
	s = s .. [[
if not game:IsLoaded() then game.Loaded:Wait() end
local genv = (getgenv and getgenv()) or _G
if genv.LunaHubStubBusy then return end
genv.LunaHubStubBusy = true
task.delay(20, function() genv.LunaHubStubBusy = nil end)
local cfgOk, cfg = pcall(function()
	return game:GetService("HttpService"):JSONDecode(readfile("]] .. ConfigFile .. [["))
end)
if not (cfgOk and type(cfg) == "table" and cfg.AutoExecute == true) then return end
local fn = loadstring(game:HttpGet("]] .. LH.ScriptURL .. [["))
if fn then fn() end
]]
	return s
end

LH.QueueLoader = function()
	if LH.Queued then return true end
	if not LH.QueueFn then return false end
	if not LH.HasURL() then return false end
	local ok = pcall(LH.QueueFn, LH.BuildLoaderStub(false))
	if ok then LH.Queued = true end
	return ok
end

LH.QueueIfEnabled = function()
	if ConfigData.AutoExecute == true then
		return LH.QueueLoader()
	end
end

LH.WriteAutoExec = function()
	if not writefile or not LH.HasURL() then return false end
	local code = "-- LUNA HUB auto load (Ride A Pet)\n" .. LH.BuildLoaderStub(true)
	for _, path in ipairs(LH.AutoExecPaths) do
		if pcall(writefile, path, code) then
			return true
		end
	end
	return false
end

LH.RemoveAutoExec = function()
	if not (isfile and delfile) then return end
	for _, path in ipairs(LH.AutoExecPaths) do
		pcall(function()
			if isfile(path) then delfile(path) end
		end)
	end
end

Secs.PlayerSection = Tabs.Tab9:Section({
	Title = "Players",
	Icon = "user",
	Box = true,
	BoxBorder = true,
})

--[[UIElements.AutoExecute = Secs.AutoExecSection:Toggle({
	Title = "Auto Execute",
	Value = ConfigData.AutoExecute == true,

	Callback = function(value)
		ConfigData.AutoExecute = value
		SaveConfig()

		if value then
			LH.Queued = false
			local queued = LH.QueueLoader()
			local autoexec = LH.WriteAutoExec()
			if LH.AutoExecReady then
				local msg
				if not LH.HasURL() then
					msg = "Walang script URL. Ilagay ang link sa LH.ScriptURL sa script."
				elseif not LH.QueueFn then
					msg = "Walang queue_on_teleport ang executor mo."
				else
					msg = "ON: queue_on_teleport " .. (queued and "OK" or "failed")
						.. " | autoexec " .. (autoexec and "OK" or "hindi supported")
				end
				WindUI:Notify({
					Title = "Auto Execute",
					Content = msg,
					Icon = "solar:bell-bold",
					Duration = 5,
					CanClose = true,
				})
			end
		else
			LH.RemoveAutoExec()
			if LH.AutoExecReady then
				WindUI:Notify({
					Title = "Auto Execute",
					Content = "Auto Execute turned off.",
					Icon = "solar:bell-bold",
					Duration = 4,
					CanClose = true,
				})
			end
		end
	end,
})
]]

--// NO CLIP & INFINITE JUMP (functions)
LH.Noclip = { Conn = nil, Parts = setmetatable({}, { __mode = "k" }) }
LH.InfJump = { Conn = nil }

-- patayin ang collision ng buong character habang naka-ON
LH.NoclipStep = function()
	local char = LocalPlayer.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			LH.Noclip.Parts[part] = true -- tandaan para maibalik pag OFF
			part.CanCollide = false
		end
	end
end

LH.SetNoclip = function(state)
	if state then
		if LH.Noclip.Conn then return end -- naka-ON na
		LH.Noclip.Conn = Svc.RunService.Stepped:Connect(LH.NoclipStep)
	else
		if LH.Noclip.Conn then
			LH.Noclip.Conn:Disconnect()
			LH.Noclip.Conn = nil
		end
		-- ibalik ang collision ng mga parts na ginalaw natin
		for part in pairs(LH.Noclip.Parts) do
			if part.Parent then
				part.CanCollide = true
			end
		end
		table.clear(LH.Noclip.Parts)
	end
end

LH.SetInfJump = function(state)
	if state then
		if LH.InfJump.Conn then return end
		LH.InfJump.Conn = Svc.UserInputService.JumpRequest:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	elseif LH.InfJump.Conn then
		LH.InfJump.Conn:Disconnect()
		LH.InfJump.Conn = nil
	end
end

-- cleanup ng dalawa (tinatawag sa FullCleanup)
LH.StopMovement = function()
	LH.SetNoclip(false)
	LH.SetInfJump(false)
end

UIElements.noclip = Secs.PlayerSection:Toggle({
	Title = "No Clip",
	Value = ConfigData.noclip == true,

	Callback = function(value)
		ConfigData.noclip = value
		SaveConfig()
		LH.SetNoclip(value)
	end,
})

UIElements.infjump = Secs.PlayerSection:Toggle({
	Title = "Infinite Jump",
	Value = ConfigData.infjump == true,

	Callback = function(value)
		ConfigData.infjump = value
		SaveConfig()
		LH.SetInfJump(value)
	end,
})

-- i-apply agad ang saved config pagka-load
if ConfigData.noclip == true then LH.SetNoclip(true) end
if ConfigData.infjump == true then LH.SetInfJump(true) end

UIElements.AutoExecute = Secs.PlayerSection:Toggle({
	Title = "Auto Execute",
	Value = ConfigData.AutoExecute == true,

	Callback = function(value)
		ConfigData.AutoExecute = value
		SaveConfig()

		if value then
			LH.Queued = false
			LH.QueueLoader()
			LH.WriteAutoExec()
			if LH.AutoExecReady then
				WindUI:Notify({
					Title = "Auto Execute",
					Content = "Auto execute turned on.",
					Icon = "solar:bell-bold",
					Duration = 5,
					CanClose = true,
				})
			end
		else
			LH.RemoveAutoExec()
			if LH.AutoExecReady then
				WindUI:Notify({
					Title = "Auto Execute",
					Content = "Auto Execute turned off.",
					Icon = "solar:bell-bold",
					Duration = 4,
					CanClose = true,
				})
			end
		end
	end,
})

-- kapag ON na sa saved config: i-queue agad pagka-load (para sa susunod na teleport)
if ConfigData.AutoExecute == true then
	LH.QueueLoader()
	LH.WriteAutoExec()
end

-- bago ang bawat teleport (kasama ang game-initiated reconnect/kick-teleport): siguraduhing naka-queue
Bind(Player.OnTeleport, function()
	LH.QueueIfEnabled()
end)

LH.AutoExecReady = true

Secs.SettingsSection = Tabs.Tab9:Section({
	Title = "Performance",
	Icon = "zap",
	Box = true,
	BoxBorder = true,
})

UIElements.FPSBoost = Secs.SettingsSection:Toggle({
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

UIElements.HideEggs = Secs.SettingsSection:Toggle({
	Title = "Hide All Eggs",
	Desc = "Hide all eggs in your plot and other players' plots",
	Value = ConfigData.HideEggs,

	Callback = function(value)
		HideEggs = value
		ConfigData.HideEggs = value
		SaveConfig()
		ToggleHideEggs(value)
	end,
})

Secs.SettingsSection1 = Tabs.Tab9:Section({
	Title = "Servers",
	Icon = "globe",
	Box = true,
	BoxBorder = true,
})

local function RejoinServer()
	LH.QueueIfEnabled()
	pcall(function()
		Svc.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
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
					Cursor ~= "" and "&cursor=" .. Svc.HttpService:UrlEncode(Cursor) or ""
				)

				local Body = game:HttpGet(Url)
				local Data = Svc.HttpService:JSONDecode(Body)

				if Data and Data.data then
					for _, Server in ipairs(Data.data) do
						if Server.id and Server.id ~= CurrentJobId and Server.playing and Server.maxPlayers and Server.playing < Server.maxPlayers then
							table.insert(Candidates, Server)
						end
					end
				end

				Cursor = (Data and Data.nextPageCursor) or ""
				if Cursor == "" then break end
			end

			table.sort(Candidates, function(a, b) return a.playing < b.playing end)
			return Candidates[1]
		end)

		if success and result and result.id then
			WindUI:Notify({
				Title = "Server Hop",
				Content = string.format("Hopping to a server with %d player(s)...", result.playing),
				Icon = "solar:server-bold",
				Duration = 3,
				CanClose = true,
			})
			LH.QueueIfEnabled()
			task.wait(0.5)
			pcall(function()
				Svc.TeleportService:TeleportToPlaceInstance(game.PlaceId, result.id, Player)
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

Secs.SettingsSection1:Button({
	Title = "Rejoin",
	Justify = "Center",
	Icon = "",
	Callback = function() RejoinServer() end,
})

Secs.SettingsSection1:Button({
	Title = "Server Hop",
	Justify = "Center",
	Icon = "",
	Callback = function() ServerHop() end,
})

Secs.ThemeSection = Tabs.Tab9:Section({
	Title = "Theme",
	Icon = "palette",
	Box = true,
	BoxBorder = true,
})

UIElements.ThemeSelect = Secs.ThemeSection:Dropdown({
	Title = "Select Theme",
	Desc = "Choose a color theme for the UI",
	Values = ThemeNames,
	Multi = false,
	Value = SelectedTheme,
	AllowNone = false,

	Callback = function(value)
		if type(value) == "table" then
			value = value[1]
		end
		if not value then return end
		SelectedTheme = value
		ConfigData.ThemeName = value
		SaveConfig()
		if ThemeEnabled then
			pcall(function() WindUI:SetTheme(value) end)
		end
	end,
})

UIElements.ThemeEnabled = Secs.ThemeSection:Toggle({
	Title = "Activate Theme",
	Desc = "ON = use the selected theme, OFF = default Dark theme",
	Value = ThemeEnabled,

	Callback = function(value)
		ThemeEnabled = value
		ConfigData.ThemeEnabled = value
		SaveConfig()
		pcall(function()
			WindUI:SetTheme(value and SelectedTheme or "Dark")
		end)
	end,
})


--==================================================
-- ADDITIONAL HELPER FUNCTIONS
--==================================================

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
	local HighestRarityPriority = math.huge
	local HighestEggPriority = math.huge

	-- weight threshold (0 = off)
	local minKG = LH.MinKG or 0
	local function CountSel(v)
		if type(v) == "table" then return #v end
		return (v ~= nil and v ~= "") and 1 or 0
	end
	-- walang rarity/category na naka-select -> weight lang ang basehan
	local NoFilters = CountSel(SelectedEggs) == 0 and CountSel(SelectedRarities) == 0

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name
		local eggData = Mods.Eggs_mData[Name]
		local Rarity = eggData and eggData.Rarity or "Common"

		local IsNameSelected = false
		local IsRaritySelected = false

		if type(SelectedEggs) == "table" then
			for _, SelectedName in ipairs(SelectedEggs) do
				if SelectedName == Name then
					IsNameSelected = true
					break
				end
			end
		elseif SelectedEggs == Name then
			IsNameSelected = true
		end

		if type(SelectedRarities) == "table" then
			for _, SelectedRarity in ipairs(SelectedRarities) do
				if SelectedRarity == Rarity then
					IsRaritySelected = true
					break
				end
			end
		elseif SelectedRarities == Rarity then
			IsRaritySelected = true
		end

		local Qualifies = IsRaritySelected or IsNameSelected

		if minKG > 0 then
			if NoFilters then Qualifies = true end
			if Qualifies then
				local kg = LH.GetEggKG(Egg)
				-- walang weight pa o mas mababa sa minimum -> ignore
				if not kg or kg < minKG - 1e-9 then
					Qualifies = false
				end
			end
		end

		if Qualifies then
			local currentRarityPrio = (IsRaritySelected or NoFilters) and (RarityPriority[Rarity] or 99) or 999
			local currentEggPrio = IsNameSelected and (EggPriority[Name] or 999) or 9999

			if currentRarityPrio < HighestRarityPriority then
				HighestRarityPriority = currentRarityPrio
				HighestEggPriority = currentEggPrio
				BestEgg = Egg
			elseif currentRarityPrio == HighestRarityPriority then
				if currentEggPrio < HighestEggPriority then
					HighestEggPriority = currentEggPrio
					BestEgg = Egg
				end
			end
		end
	end

	return BestEgg
end

local function PickupEgg(Egg)
	if not Egg then return false end

	pcall(function()
		local Remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
		local GameRemotes = Remotes and Remotes:FindFirstChild("Game")

		if GameRemotes then
			local PickupRemote = GameRemotes:FindFirstChild("PickupEgg")
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

	HRP.CFrame = LH.UprightCFrame(EggPart.Position + Vector3.new(0, 3, 0)) -- patayo, hindi na sumusunod sa tilt ng egg
	LH.Stabilize()
	return true
end

local function TweenToCFrame(targetCFrame, speedOrTime)
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local distance = (hrp.Position - targetCFrame.Position).Magnitude
	local duration = typeof(speedOrTime) == "number" and speedOrTime or (distance / 60)
	if duration <= 0 then duration = 0.1 end

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = Svc.TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
	tween.Completed:Wait()
end


--==================================================
-- ESP SYSTEM WITH RARITY COLORS
--==================================================

local ActiveESP = {}

local function GetEggColor(eggName)
	local eggData = Mods.Eggs_mData[eggName]
	local rarity = eggData and eggData.Rarity or "Common"

	if rarity == "Common" then
		return Color3.fromRGB(255, 255, 255)
	elseif rarity == "Rare" then
		return Color3.fromRGB(85, 170, 255)
	elseif rarity == "Epic" then
		return Color3.fromRGB(170, 85, 255)
	elseif rarity == "Legendary" then
		return Color3.fromRGB(255, 215, 0)
	elseif rarity == "Mythic" then
		return Color3.fromRGB(255, 50, 50)
	elseif rarity == "Divine" then
		return Color3.fromRGB(255, 255, 153)
	elseif rarity == "Ethereal" or rarity == "Eternal" then
		return Color3.fromRGB(255, 0, 127)
	end

	return Color3.fromRGB(255, 255, 255)
end

--// ESP WEIGHT HELPERS (idinagdag)
-- Binabasa ang real weight ng egg, tapos kino-convert sa kg na ipinapakita ng game
LH.GetEggWeight = function(Egg)
	local function fromInst(inst)
		if not inst then return nil end
		local v = tonumber(inst:GetAttribute("Weight"))
		if v then return v end
		local child = inst:FindFirstChild("Weight")
		if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
			return tonumber(child.Value)
		end
		return nil
	end

	local w = fromInst(Egg)
	if w then return w end

	local handle = Egg:FindFirstChild("Handle")
	w = fromInst(handle) or fromInst(handle and handle:FindFirstChild("EggBase"))
	if w then return w end

	w = fromInst(Egg:FindFirstChild("EggData"))
	if w then return w end

	for _, d in ipairs(Egg:GetDescendants()) do
		w = fromInst(d)
		if w then return w end
	end

	-- WALANG Weight attribute sa RenderedEggs: kunin sa laki ng model
	-- (WorldEggScaleFor: scale = weight, pero kapag weight >= 1.5 ay x2)
	local scale
	local okScale, modelScale = pcall(function() return Egg:GetScale() end)
	if okScale and type(modelScale) == "number" and math.abs(modelScale - 1) > 1e-3 then
		scale = modelScale
	end

	if not scale and handle and handle:IsA("BasePart") then
		LH.EggTemplates = LH.EggTemplates or {}
		local template = LH.EggTemplates[Egg.Name]
		if template == nil then
			template = false
			for _, d in ipairs(Svc.ReplicatedStorage:GetDescendants()) do
				if d.Name == Egg.Name and d:IsA("Model") and d ~= Egg and d:FindFirstChild("Handle") then
					template = d
					break
				end
			end
			LH.EggTemplates[Egg.Name] = template
		end
		local tHandle = template and template:FindFirstChild("Handle")
		if tHandle and tHandle:IsA("BasePart") and tHandle.Size.X > 0 then
			scale = handle.Size.X / tHandle.Size.X
		end
	end

	if scale then
		local from = tonumber(Mods.General_mData.EggInflateFrom) or 1.5
		local factor = tonumber(Mods.General_mData.EggInflateFactor) or 2
		if scale > (from + from * factor) / 2 then
			scale = scale / factor
		end
		return scale, true -- true = estimate galing sa laki
	end

	return nil
end

LH.FormatKG = function(n)
	n = tonumber(n) or 0
	-- mas mababa sa 1,000: may decimal (trimmed). 1,000 pataas: whole number may comma, walang K
	if n < 1000 then
		return LH.TrimNum(n) .. " kg"
	end
	local str = string.format("%.0f", n)
	local k
	repeat
		str, k = str:gsub("^(%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return str .. " kg"
end

LH.EggKGCache = setmetatable({}, { __mode = "k" })
LH.GetEggKG = function(Egg)
	local cached = LH.EggKGCache[Egg]
	if cached then return cached end
	local real = LH.GetEggWeight(Egg)
	if not real then return nil end
	local ok, kg = pcall(function() return Mods.General_mData.ShownEggKG(real) end)
	kg = (ok and type(kg) == "number") and kg or real
	LH.EggKGCache[Egg] = kg
	return kg
end

LH.GetEggWeightText = function(Egg)
	local real = LH.GetEggWeight(Egg)
	if not real then return nil end
	local ok, kg = pcall(function() return Mods.General_mData.ShownEggKG(real) end)
	if ok and type(kg) == "number" then
		return LH.FormatKG(kg)
	end
	return LH.TrimNum(real) .. " kg"
end

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
	if ActiveESP[Egg] then return end

	local EggPart = GetEggPart(Egg)
	if not EggPart then return end

	local textColor = GetEggColor(Egg.Name)

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
	TextLabel.TextColor3 = textColor
	TextLabel.TextStrokeTransparency = 0
	TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.TextSize = 16
	local eggInfo = Mods.Eggs_mData[Egg.Name]
	local eggRarity = eggInfo and eggInfo.Rarity or "Common"
	TextLabel.Text = string.format("%s (%s)\n0m", Egg.Name, eggRarity)
	TextLabel.Parent = Billboard

	ActiveESP[Egg] = {
		Billboard = Billboard,
		TextLabel = TextLabel,
		Part = EggPart
	}
end

Bind(Svc.RunService.RenderStepped, function()
	if not ESPEnabled then
		ClearAllESP()
		return
	end

	local Character = GetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

	for Egg, _ in pairs(ActiveESP) do
		if not Egg or not Egg.Parent or Egg.Parent ~= RenderedEggs then
			RemoveESP(Egg)
		end
	end

	for _, Egg in ipairs(RenderedEggs:GetChildren()) do
		local Name = Egg.Name
		local eggData = Mods.Eggs_mData[Name]
		local Rarity = eggData and eggData.Rarity or "Common"

		local IsNameSelected = false
		local IsRaritySelected = false

		if type(SelectedESPEggs) == "table" then
			for _, SelectedName in ipairs(SelectedESPEggs) do
				if SelectedName == Name then
					IsNameSelected = true
					break
				end
			end
		elseif SelectedESPEggs == Name then
			IsNameSelected = true
		end

		if type(SelectedESPRarities) == "table" then
			for _, SelectedRarity in ipairs(SelectedESPRarities) do
				if SelectedRarity == Rarity then
					IsRaritySelected = true
					break
				end
			end
		elseif SelectedESPRarities == Rarity then
			IsRaritySelected = true
		end

		if IsNameSelected or IsRaritySelected then
			if not ActiveESP[Egg] then
				CreateESP(Egg)
			end

			if ActiveESP[Egg] and HRP and ActiveESP[Egg].Part then
				local Dist = math.floor((HRP.Position - ActiveESP[Egg].Part.Position).Magnitude)
				local entry = ActiveESP[Egg]
				if not entry.WeightText and os.clock() >= (entry.NextWeightTry or 0) then
					entry.NextWeightTry = os.clock() + 2 -- retry every 2s lang para hindi mabigat
					entry.WeightText = LH.GetEggWeightText(Egg)
				end
				entry.TextLabel.Text = string.format("%s (%s)\n%dm | %s", Name, Rarity, Dist, entry.WeightText or "? kg")
			end
		else
			RemoveESP(Egg)
		end
	end
end)


--==================================================
-- AUTOMATION LOOPS
--==================================================

-- AUTO FAVORITE PET
function ProcessAutoFavorite()
	while AutoFavoritePet do
		local favList = type(SelectedFavPet) == "table" and SelectedFavPet or (SelectedFavPet ~= "" and {SelectedFavPet} or {})

		if #favList > 0 then
			local favMap = {}
			for _, name in ipairs(favList) do
				favMap[string.lower(name)] = true
			end

			local function IsPetFavorited(inst)
				if inst:GetAttribute("IsFavorite") == true or inst:GetAttribute("Favorite") == true or inst:GetAttribute("Favorited") == true then
					return true
				end
				local favVal = inst:FindFirstChild("Favorite") or inst:FindFirstChild("IsFavorite")
				if favVal and (favVal:IsA("BoolValue") and favVal.Value == true) then
					return true
				end
				return false
			end

			local function GetTargetPets()
				local targets = {}

				local petsFolder = PD.SavedData:FindFirstChild("Pets") or PD.SavedData:FindFirstChild("OwnedPets")
				if petsFolder then
					for _, petObj in ipairs(petsFolder:GetChildren()) do
						local rawName = petObj:GetAttribute("PetName") or petObj.Name
						local petName = string.match(rawName, "^(.-) %[") or rawName

						if favMap[string.lower(petName)] and not IsPetFavorited(petObj) then
							table.insert(targets, { Instance = petObj, Key = petObj:GetAttribute("PetKey") or petObj.Name })
						end
					end
				end

				local containers = {LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character}
				for _, container in ipairs(containers) do
					if container then
						for _, child in ipairs(container:GetChildren()) do
							if child:IsA("Tool") then
								local rawName = child:GetAttribute("PetName") or child.Name
								local petName = string.match(rawName, "^(.-) %[") or rawName

								if favMap[string.lower(petName)] and not IsPetFavorited(child) then
									local key = child:GetAttribute("PetKey") or child.Name
									table.insert(targets, { Instance = child, Key = key })
								end
							end
						end
					end
				end

				return targets
			end

			local targets = GetTargetPets()

			if #targets > 0 then
				for _, item in ipairs(targets) do
					if not AutoFavoritePet then break end

					pcall(function()
						if Rem.FavoritePetRemote then
							if item.Key then
								Rem.FavoritePetRemote:FireServer(item.Key)
							else
								Rem.FavoritePetRemote:FireServer(item.Instance)
							end
						end
					end)

					task.wait(0.3)
				end
			end
		end

		task.wait(10)
	end
end

-- AUTO BUY GEAR LOOP
task.spawn(function()
	while LH.Alive do
		if Autobuygear and ShopStockReady then
			pcall(function()
				if type(SelectedGear) == "table" then
					for _, GearItem in ipairs(SelectedGear) do
						if not Autobuygear then break end
						local Stock = GetShopStock("Gears", GearItem)
						if Stock > 0 then
							Rem.BuyWithCash:FireServer("Gears", GearItem)
							ReduceShopStock("Gears", GearItem)
							task.wait(0.2)
						end
					end
				elseif type(SelectedGear) == "string" and SelectedGear ~= "" then
					local Stock = GetShopStock("Gears", SelectedGear)
					if Stock > 0 then
						Rem.BuyWithCash:FireServer("Gears", SelectedGear)
						ReduceShopStock("Gears", SelectedGear)
					end
				end
			end)
		end
		task.wait(0.5)
	end
end)

-- AUTO BUY FOOD LOOP
task.spawn(function()
	while LH.Alive do
		if Autobuyfood and ShopStockReady then
			pcall(function()
				if type(SelectedFood) == "table" then
					for _, FoodItem in ipairs(SelectedFood) do
						if not Autobuyfood then break end
						local Stock = GetShopStock("Food", FoodItem)
						if Stock > 0 then
							Rem.BuyWithCash:FireServer("Food", FoodItem)
							ReduceShopStock("Food", FoodItem)
							task.wait(0.2)
						end
					end
				elseif type(SelectedFood) == "string" and SelectedFood ~= "" then
					local Stock = GetShopStock("Food", SelectedFood)
					if Stock > 0 then
						Rem.BuyWithCash:FireServer("Food", SelectedFood)
						ReduceShopStock("Food", SelectedFood)
					end
				end
			end)
		end
		task.wait(0.5)
	end
end)

do
	-- AUTO SELL PET LOGIC (bagong SellItems remote system)
	local SellItemsRemote = GameRemotes:WaitForChild("SellItems")
	local ConfirmRequest = GameRemotes:WaitForChild("ConfirmRequest")
	local RichieNPC = workspace:WaitForChild("Stalls"):WaitForChild("Sell"):WaitForChild("Richie")
	local SellValue_m = require(GameServices:WaitForChild("SellValue"))

	local SELL_CHUNK_SIZE = 30      -- ilang pets per SellItems call
	local SELL_RESULT_TIMEOUT = 8   -- segundo na hihintayin ang sagot ng server (kasama ang Ethereal confirm)

	local sellPendingUntil = 0
	local lastSellResult = nil
	local sellBusy = false
	local confirmedIds = {}

	-- Sagot ng server sa SellItems ({Sold = n} o {Reason = "TooFar"/"Busy"/...})
	Bind(SellItemsRemote.OnClientEvent, function(result)
		lastSellResult = result or true
	end)

	-- Auto-confirm (Ethereal pets may "Sell / Keep" confirmation)
	local SELL_DEBUG = false -- gawing true para makita sa console ang args ng confirm request

	local function CollectConfirmIds(value, out, depth)
		if depth > 4 then return end
		if type(value) == "string" then
			if #value >= 30 and string.find(value, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-") then
				table.insert(out, value)
			end
		elseif type(value) == "table" then
			for _, v in pairs(value) do
				CollectConfirmIds(v, out, depth + 1)
			end
		end
	end

	local function TryAutoConfirm(remoteName, ...)
		if os.clock() > sellPendingUntil then return end
		local ids = {}
		CollectConfirmIds({...}, ids, 0)
		if SELL_DEBUG then
			warn("[AutoSell] confirm event from", remoteName, "ids:", #ids)
		end
		for _, id in ipairs(ids) do
			if not confirmedIds[id] then
				confirmedIds[id] = true
				pcall(function() ConfirmRequest:FireServer(id, true, "Yes") end)
			end
		end
	end

	-- ConfirmRequest mismo + kahit anong remote na may "confirm" sa pangalan
	for _, remote in ipairs(Svc.ReplicatedStorage:WaitForChild("Remotes"):GetDescendants()) do
		if remote:IsA("RemoteEvent") and (remote == ConfirmRequest or string.find(string.lower(remote.Name), "confirm", 1, true)) then
			Bind(remote.OnClientEvent, function(...)
				TryAutoConfirm(remote.Name, ...)
			end)
		end
	end

	-- Fallback: i-click mismo ang "Sell" button ng Sell/Keep GUI para mawala ito
	local function IsGuiShown(gui)
		local current = gui
		while current and current ~= LocalPlayer.PlayerGui do
			if current:IsA("GuiObject") and not current.Visible then return false end
			if current:IsA("ScreenGui") and not current.Enabled then return false end
			current = current.Parent
		end
		return true
	end

	local function GetButtonText(btn)
		local text = ""
		if btn:IsA("TextButton") then text = btn.Text end
		if text == "" then
			for _, d in ipairs(btn:GetDescendants()) do
				if d:IsA("TextLabel") and d.Text ~= "" then
					text = d.Text
					break
				end
			end
		end
		text = string.gsub(text, "<[^>]+>", "")
		text = string.gsub(text, "^%s+", "")
		text = string.gsub(text, "%s+$", "")
		return string.lower(text)
	end

	local function ClickGuiButton(btn)
		local clicked = false
		if typeof(getconnections) == "function" then
			for _, signal in ipairs({btn.Activated, btn.MouseButton1Click, btn.MouseButton1Down, btn.MouseButton1Up}) do
				pcall(function()
					for _, conn in ipairs(getconnections(signal)) do
						pcall(function() conn:Fire() end)
						clicked = true
					end
				end)
			end
		end
		if not clicked and typeof(firesignal) == "function" then
			pcall(function() firesignal(btn.Activated) end)
			pcall(function() firesignal(btn.MouseButton1Click) end)
		end
	end

	local function ClickConfirmSell()
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if not playerGui then return end

		for _, btn in ipairs(playerGui:GetDescendants()) do
			if btn:IsA("GuiButton") and IsGuiShown(btn) then
				local text = GetButtonText(btn)
				if text == "sell" or text == "yes" or text == "confirm" then
					-- siguraduhing may "Keep" button sa katabi (para hindi ma-click ang ibang Sell button)
					local container = btn.Parent
					for _ = 1, 4 do
						if not container or container == playerGui then break end
						local hasKeep = false
						for _, other in ipairs(container:GetDescendants()) do
							if other:IsA("GuiButton") and other ~= btn and IsGuiShown(other) then
								local otherText = GetButtonText(other)
								if otherText == "keep" or otherText == "no" or otherText == "cancel" then
									hasKeep = true
									break
								end
							end
						end
						if hasKeep then
							ClickGuiButton(btn)
							return
						end
						container = container.Parent
					end
				end
			end
		end
	end

	task.spawn(function()
		while LH.Alive do
			if os.clock() <= sellPendingUntil then
				pcall(ClickConfirmSell)
				task.wait(0.25)
			else
				task.wait(0.5)
			end
		end
	end)

	local function ToLowerSet(list)
		local set = {}
		if type(list) ~= "table" then return set end
		for key, value in pairs(list) do
			if type(value) == "string" then
				set[string.lower(value)] = true
			elseif value == true and type(key) == "string" then
				set[string.lower(key)] = true
			end
		end
		return set
	end

	local function SellTutorialFinished()
		local savedData = LocalPlayer:FindFirstChild("SavedData")
		local flag = savedData and savedData:FindFirstChild("HasFinishedTutorial")
		return flag ~= nil and flag.Value == true
	end

	local function GetSellPetName(tool)
		local name = tool:GetAttribute("PetName")
		if typeof(name) ~= "string" then
			name = string.match(tool.Name, "^(.-) %[") or tool.Name
		end
		return name
	end

	local function IsSellLocked(tool, petKey)
		if tool:GetAttribute("Favorited") == true
					or tool:GetAttribute("IsFavorite") == true
					or tool:GetAttribute("Favorite") == true then
			return true
		end
		if petKey == "TUTORIAL_Snail" and not SellTutorialFinished() then
			return true
		end
		return false
	end

	-- useFilter = true  -> gamitin ang Rarity Filter at Category Filter dropdown
	-- useFilter = false -> lahat ng pets (maliban sa favorited)
	local function CollectSellKeys(useFilter)
		local keys = {}
		local seen = {}

		local petSet, raritySet
		if useFilter then
			petSet = ToLowerSet(SelectedPetToSell)
			raritySet = ToLowerSet(SelectedSellRarities)
			if next(petSet) == nil and next(raritySet) == nil then
				return keys
			end
		end

		for _, container in ipairs({LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character}) do
			if container then
				for _, tool in ipairs(container:GetChildren()) do
					if tool:IsA("Tool") then
						local petKey = tool:GetAttribute("PetKey")
						local petName = GetSellPetName(tool)
						local petConfig = Mods.Pets_m[petName]

						if typeof(petKey) == "string" and petConfig and not seen[petKey] and not IsSellLocked(tool, petKey) then
							-- Tulad ng UI ng laro: kung walang worth, hindi mabebenta
							local okWorth, worth = pcall(function()
								return SellValue_m.PetWorth(
									petName,
									tool:GetAttribute("Weight"),
									tool:GetAttribute("Mutation"),
									tool:GetAttribute("SpawnMutation")
								)
							end)

							if okWorth and worth then
								local shouldSell = true
								if useFilter then
									local petRarity = petConfig.Rarity or tool:GetAttribute("Rarity") or "Common"
									shouldSell = (petSet[string.lower(petName)] == true)
										or (raritySet[string.lower(tostring(petRarity))] == true)
								end

								if shouldSell then
									seen[petKey] = true
									table.insert(keys, petKey)
								end
							end
						end
					end
				end
			end
		end

		return keys
	end

	local function TeleportToRichie()
		if not RichieNPC or not RichieNPC.Parent then return false end
		local character = LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end

		pcall(function()
			local targetCFrame = RichieNPC:IsA("Model") and RichieNPC:GetPivot() or RichieNPC.CFrame
			hrp.CFrame = targetCFrame * CFrame.new(0, 0, -4)
		end)
		task.wait(0.3)
		return true
	end

	local function SellPetKeys(keys, isStillEnabled)
		if sellBusy or #keys == 0 then return end
		sellBusy = true

		pcall(function()
			for index = 1, #keys, SELL_CHUNK_SIZE do
				if not isStillEnabled() or not LH.Alive then break end

				local chunk = {}
				for i = index, math.min(index + SELL_CHUNK_SIZE - 1, #keys) do
					table.insert(chunk, keys[i])
				end

				local attempts = 0
				while attempts < 3 and isStillEnabled() and LH.Alive do
					attempts += 1
					if not TeleportToRichie() then break end

					lastSellResult = nil
					sellPendingUntil = os.clock() + SELL_RESULT_TIMEOUT + 2
					SellItemsRemote:FireServer({ Pets = chunk, Eggs = {} })

					local startTime = os.clock()
					while lastSellResult == nil and (os.clock() - startTime) < SELL_RESULT_TIMEOUT do
						task.wait(0.1)
					end

					local result = lastSellResult
					local reason = type(result) == "table" and result.Reason or nil
					if reason == "Busy" or reason == "TooFar" or reason == "NotReady" then
						task.wait(1.5) -- subukan ulit
					else
						break
					end
				end

				task.wait(1.2) -- may 1 second cooldown ang sell button ng laro
			end
		end)

		sellPendingUntil = os.clock() + 6
		sellBusy = false
	end

	task.spawn(function()
		while LH.Alive do
			if AutoSellPet and not LH.FarmPaused() then
				LH.BgRun(function()
					SellPetKeys(CollectSellKeys(true), function() return AutoSellPet and not LH.FarmPaused() end)
				end)
				task.wait(2)
			else
				task.wait(0.5)
			end
		end
	end)

	task.spawn(function()
		while LH.Alive do
			if AutoSellAllPets and not LH.FarmPaused() then
				LH.BgRun(function()
					SellPetKeys(CollectSellKeys(false), function() return AutoSellAllPets and not LH.FarmPaused() end)
				end)
				task.wait(5)
			else
				task.wait(0.5)
			end
		end
	end)
end

-- AUTO PLACE EGG LOOP
local MAX_PLANTED_EGGS = 10

local function GetRandomPlotPosition(Baseplate)
	if not Baseplate or not Baseplate:IsA("BasePart") then return nil end

	local Size = Baseplate.Size
	local Position = Baseplate.Position

	local MarginX = math.min(3, Size.X / 4)
	local MarginZ = math.min(3, Size.Z / 4)

	local MinX = Position.X - (Size.X / 2) + MarginX
	local MaxX = Position.X + (Size.X / 2) - MarginX

	local MinZ = Position.Z - (Size.Z / 2) + MarginZ
	local MaxZ = Position.Z + (Size.Z / 2) - MarginZ

	local RandomX = MinX + math.random() * (MaxX - MinX)
	local RandomZ = MinZ + math.random() * (MaxZ - MinZ)

	local Y = Position.Y + (Size.Y / 2) + 1.5

	return Vector3.new(RandomX, Y, RandomZ)
end

local function GetTargetEggsToPlace()
	local targetEggTools = {}
	local containers = {Player:FindFirstChild("Backpack"), LocalPlayer.Character}

	local targetEggNames = type(SelectedPlaceEgg) == "table" and SelectedPlaceEgg or (SelectedPlaceEgg ~= "" and {SelectedPlaceEgg} or {})
	local targetRarities = type(SelectedPlaceRarities) == "table" and SelectedPlaceRarities or (SelectedPlaceRarities ~= "" and {SelectedPlaceRarities} or {})

	for _, container in ipairs(containers) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") then
					local eggName = child.Name
					local eggData = Mods.Eggs_mData[eggName]
					if not eggData then continue end

					local eggRarity = eggData and eggData.Rarity or "Common"

					local isNameSelected = false
					for _, name in ipairs(targetEggNames) do
						if name == eggName then
							isNameSelected = true
							break
						end
					end

					local isRaritySelected = false
					for _, rarity in ipairs(targetRarities) do
						if rarity == eggRarity then
							isRaritySelected = true
							break
						end
					end

					if isNameSelected or isRaritySelected then
						table.insert(targetEggTools, child)
					end
				end
			end
		end
	end

	return targetEggTools
end

task.spawn(function()
	while LH.Alive do
		if AutoPlaceEgg and not LH.FarmPaused() then
			LH.BgRun(function()
				local TargetTools = GetTargetEggsToPlace()
				if #TargetTools == 0 then return end

				local Character = GetCharacter()
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not Character or not Humanoid then return end

				local MyPlot = LH.GetMyPlot()
				if not MyPlot then return end

				local EggsFolder = MyPlot:FindFirstChild("Eggs")
				local EggCount = EggsFolder and #EggsFolder:GetChildren() or 0

				if EggCount >= MAX_PLANTED_EGGS then return end

				local Baseplate = MyPlot:FindFirstChild("Baseplate")
				if not Baseplate or not Baseplate:IsA("BasePart") then return end

				local Remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local EggPlacedRemote = GameRemotes and GameRemotes:FindFirstChild("EggPlaced")

				if not EggPlacedRemote then return end

				for _, EggTool in ipairs(TargetTools) do
					if not AutoPlaceEgg or LH.FarmPaused() then break end

					EggsFolder = MyPlot:FindFirstChild("Eggs")
					EggCount = EggsFolder and #EggsFolder:GetChildren() or 0

					if EggCount >= MAX_PLANTED_EGGS then break end

					if not EggTool or not EggTool.Parent or not Mods.Eggs_mData[EggTool.Name] then continue end

					if EggTool.Parent ~= Character then
						Humanoid:EquipTool(EggTool)
						task.wait(0.15)
					end

					if EggTool.Parent == Character then
						local PlantPosition = GetRandomPlotPosition(Baseplate)
						if PlantPosition then
							EggPlacedRemote:FireServer({ PlantPosition = PlantPosition })
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

-- AUTO HATCH EGG LOOP (ALL & FILTERED)
local function IsEggReadyToHatch(eggModel)
	local eggConfig = Mods.Eggs_mData[eggModel.Name]
	local eggData = eggModel:FindFirstChild("EggData")
	local placeTimeObj = eggData and eggData:FindFirstChild("PlaceTime")

	if not eggConfig or not placeTimeObj or placeTimeObj.Value <= 0 then
		return false
	end

	local weightObj = eggData:FindFirstChild("Weight")
	local weightVal = weightObj and tonumber(weightObj.Value) or 1
	local totalGrowthTime = Mods.General_mData.GrowthTimeFor(eggConfig.GrowthTime, weightVal)

	local elapsedTime = eggModel:GetAttribute("FlatGrow") == true
		and (workspace:GetServerTimeNow() - placeTimeObj.Value)
		or Mods.DayNight_mData.GrowthElapsed(placeTimeObj.Value)

	local timeLeft = totalGrowthTime - elapsedTime
	return timeLeft <= 0
end

local function IsEggMatchingHatchFilter(eggModel)
	local eggName = eggModel.Name
	local eggConfig = Mods.Eggs_mData[eggName]
	local rarity = eggConfig and eggConfig.Rarity or "Common"

	local isNameSelected = false
	if type(SelectedHatchEggs) == "table" then
		for _, selectedName in ipairs(SelectedHatchEggs) do
			if selectedName == eggName then
				isNameSelected = true
				break
			end
		end
	elseif SelectedHatchEggs == eggName then
		isNameSelected = true
	end

	local isRaritySelected = false
	if type(SelectedHatchRarities) == "table" then
		for _, selectedRarity in ipairs(SelectedHatchRarities) do
			if selectedRarity == rarity then
				isRaritySelected = true
				break
			end
		end
	elseif SelectedHatchRarities == rarity then
		isRaritySelected = true
	end

	return isNameSelected or isRaritySelected
end

task.spawn(function()
	while LH.Alive do
		if (AutoHatchEgg or AutoHatchSelectedEggs) and not LH.FarmPaused() then
			LH.BgRun(function()
				local HatchRemote = Svc.ReplicatedStorage:FindFirstChild("Remotes")
					and Svc.ReplicatedStorage.Remotes:FindFirstChild("Game")
					and Svc.ReplicatedStorage.Remotes.Game:FindFirstChild("Hatch")

				if HatchRemote then
					local myPlot = Mods.General_m:GetPlot(Player)
					local eggsFolder = myPlot and myPlot:FindFirstChild("Eggs")

					if eggsFolder then
						for _, eggModel in ipairs(eggsFolder:GetChildren()) do
							if LH.FarmPaused() then break end
							local eggKey = eggModel:GetAttribute("EggKey")
								or (eggModel:FindFirstChild("EggKey") and eggModel.EggKey.Value)

							if eggKey and IsEggReadyToHatch(eggModel) then
								local shouldHatch = false

								if AutoHatchEgg then
									shouldHatch = true
								elseif AutoHatchSelectedEggs and IsEggMatchingHatchFilter(eggModel) then
									shouldHatch = true
								end

								if shouldHatch then
									HatchRemote:FireServer({ EggKey = tostring(eggKey) })
									task.wait(0.2)
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

-- AUTO PLACE BEST PETS
local function GetMaxPetCapacity()
	local currentRebirths = PD.Rebirths and PD.Rebirths.Value or 0
	local attrMax = LocalPlayer:GetAttribute("MaxPets")
	local calculatedCapacity = 5 + math.floor(currentRebirths)

	if attrMax and attrMax > 0 then
		return math.max(attrMax, calculatedCapacity)
	end

	return calculatedCapacity
end

local function CalculatePetIncome(petTool)
	local petName = string.match(petTool.Name, "^(.-) %[") or petTool:GetAttribute("PetName") or petTool.Name
	local petConfig = Mods.Pets_m[petName]
	local baseIncome = petConfig and tonumber(petConfig.Income) or 0

	if baseIncome <= 0 then return 0 end

	local weight = tonumber(petTool:GetAttribute("Weight")) or 1
	local mutation = petTool:GetAttribute("Mutation")
	local spawnMutation = petTool:GetAttribute("SpawnMutation")

	local combinedFactor = Mods.Mutations_m.CombinedFactor and Mods.Mutations_m.CombinedFactor(mutation, spawnMutation) or 1
	local weightStandard = Mods.PetAging_m.WeightStandardKG or 1

	return math.floor(math.floor(baseIncome * (weight / weightStandard)) * combinedFactor)
end

local function GetAllPetsSorted()
	local petsList = {}

	for _, petData in pairs(Mods.PetRenderer_m.GetAll()) do
		if petData.OwnerUserId == LocalPlayer.UserId and petData.Model and petData.Model.Parent then
			table.insert(petsList, {
				Key = petData.PetKey,
				Income = tonumber(petData.DisplayIncome) or tonumber(petData.Income) or 0,
				Placed = true,
				Position = petData.Model:GetPivot().Position
			})
		end
	end

	local containers = {LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}
	for _, container in ipairs(containers) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("PetKey") then
					table.insert(petsList, {
						Key = child:GetAttribute("PetKey"),
						Income = CalculatePetIncome(child),
						Placed = false,
						Tool = child
					})
				end
			end
		end
	end

	table.sort(petsList, function(a, b)
		return a.Income > b.Income
	end)

	return petsList
end

local function GetPlotPlacementPos(rootPart, index)
	local targetPos = (rootPart.CFrame * CFrame.new(((index - 1) % 3 - 1) * 4, 0, -(math.floor((index - 1) / 3) * 4 + 8))).Position
	local myPlot = Mods.General_m:GetPlot(LocalPlayer)
	local baseplate = myPlot and myPlot:FindFirstChild("Baseplate")

	if not baseplate then return targetPos end

	local objSpace = baseplate.CFrame:PointToObjectSpace(targetPos)
	local sizeX = baseplate.Size.X / 2 - 2
	local sizeZ = baseplate.Size.Z / 2 - 2
	local clampedX = math.clamp(objSpace.X, -sizeX, sizeX)
	local clampedZ = math.clamp(objSpace.Z, -sizeZ, sizeZ)

	return baseplate.CFrame:PointToWorldSpace(Vector3.new(clampedX, objSpace.Y, clampedZ))
end

local function PlaceBestPets()
	if AutoSellPet or AutoSellAllPets or LH.FarmPaused() then return end

	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local allPets = GetAllPetsSorted()
	if #allPets == 0 then return end

	local maxCapacity = GetMaxPetCapacity()
	local targetPetsCount = math.min(maxCapacity, #allPets)

	local bestPetsToPlace = {}
	local bestKeysMap = {}

	for i = 1, targetPetsCount do
		bestPetsToPlace[i] = allPets[i]
		bestKeysMap[allPets[i].Key] = true
	end

	local freedPositions = {}

	for _, pet in ipairs(allPets) do
		if LH.FarmPaused() then break end
		if pet.Placed and not bestKeysMap[pet.Key] then
			table.insert(freedPositions, pet.Position)
			Mods.PetRenderer_m.Remove(LocalPlayer.UserId, pet.Key)
			Rem.PickupPetRemote:FireServer(pet.Key)
			task.wait(0.2)
		end
	end

	for slotIndex, pet in ipairs(bestPetsToPlace) do
		if AutoSellPet or AutoSellAllPets or LH.FarmPaused() then break end

		if not pet.Placed then
			local petTool = pet.Tool
			if not petTool or not petTool.Parent then
				local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
				if backpack then
					for _, item in ipairs(backpack:GetChildren()) do
						if item:GetAttribute("PetKey") == pet.Key then
							petTool = item
							break
						end
					end
				end
			end

			if petTool then
				humanoid:EquipTool(petTool)
				local timeout = os.clock() + 2
				repeat task.wait() until petTool.Parent == char or os.clock() > timeout

				if petTool.Parent == char then
					local placePos = table.remove(freedPositions, 1) or GetPlotPlacementPos(rootPart, slotIndex)
					Rem.PlacePetRemote:FireServer(pet.Key, placePos)
					task.wait(0.2)
				end
			end
		end
	end

	if LocalPlayer:GetAttribute("IsRiding") ~= true and not AutoSellPet and not AutoSellAllPets then
		humanoid:UnequipTools()
	end
end

task.spawn(function()
	while LH.Alive do
		if AutoEquipBestPet and not AutoSellPet and not AutoSellAllPets and not LH.FarmPaused() and not LH.RodeByScript then
			LH.BgRun(PlaceBestPets)
			task.wait(10)
		else
			task.wait(0.5)
		end
	end
end)

-- FUSE MACHINE POSITION
local FuseMachineCFrame = CFrame.new(
	388.60022, 40328.2148, 752.438721,
	0.994453132, 1.98315195e-08, 0.105180927,
	-3.07236547e-08, 1, 1.01935925e-07,
	-0.105180927, -1.04602044e-07, 0.994453132
)

-- AUTO FUSE
do
	local function FuseNormName(name)
		return (string.lower(tostring(name or "")):gsub("grizlly", "grizzly"))
	end

	local function FuseIsFavorited(inst)
		if inst:GetAttribute("IsFavorite") == true or inst:GetAttribute("Favorite") == true or inst:GetAttribute("Favorited") == true then
			return true
		end
		local favVal = inst:FindFirstChild("Favorite") or inst:FindFirstChild("IsFavorite")
		if favVal and favVal:IsA("BoolValue") and favVal.Value == true then
			return true
		end
		return false
	end

	local function GetFuseCandidates()
		local set = {}
		if type(SelectedFusePets) == "table" then
			for _, name in ipairs(SelectedFusePets) do
				set[FuseNormName(name)] = true
			end
		end

		local found = {}
		if next(set) == nil then return found end

		local containers = { LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character }
		for _, container in ipairs(containers) do
			if container then
				for _, child in ipairs(container:GetChildren()) do
					if child:IsA("Tool") and child:GetAttribute("PetKey") then
						local rawName = child:GetAttribute("PetName") or child.Name
						local petName = string.match(rawName, "^(.-) %[") or rawName
						if set[FuseNormName(petName)] and not FuseIsFavorited(child) then
							table.insert(found, child)
						end
					end
				end
			end
		end
		return found
	end

	local function IsFusionBusy()
		local slots = LocalPlayer:FindFirstChild("FusionSlots")
		return slots ~= nil and slots:GetAttribute("FusionStatus") ~= nil
	end

	local function DetectFilledSlots()
		local filled = {}
		local slots = LocalPlayer:FindFirstChild("FusionSlots")
		if not slots then return filled end

		local function has(v)
			return v ~= nil and v ~= "" and v ~= false and v ~= 0
		end

		for name, v in pairs(slots:GetAttributes()) do
			local n = tonumber(string.match(name, "^Slot(%d)$") or string.match(name, "^Pet(%d)$") or string.match(name, "^(%d)$"))
			if n and n >= 1 and n <= 4 and has(v) then filled[n] = true end
		end

		for _, c in ipairs(slots:GetChildren()) do
			local n = tonumber(string.match(c.Name, "(%d)"))
			if n and n >= 1 and n <= 4 then
				local v = c:IsA("ValueBase") and c.Value or nil
				if has(v) or #c:GetChildren() > 0 or next(c:GetAttributes()) ~= nil then
					filled[n] = true
				end
			end
		end

		return filled
	end

	local FusePlaced = {}
	local FuseStartTries = 0
	local FuseRetryAt = 0

	-- may trabaho ba ang Auto Fuse? (ilagay ang pets / pindutin ang Start)
	function LH.FuseJobPending()
		if not AutoFuse or AutoSellPet or AutoSellAllPets then return false end
		if IsFusionBusy() then return false end
		-- ayaw mag-start (kulang cash?): huwag hawakan ang priority, subukan ulit kada 15s
		if FuseStartTries >= 3 and os.clock() < FuseRetryAt then return false end

		local det = DetectFilledSlots()
		local filled = 0
		for slot = 1, 4 do
			if FusePlaced[slot] or det[slot] then filled += 1 end
		end
		if filled >= 4 then return true end
		return #GetFuseCandidates() >= (4 - filled)
	end

	-- may trabaho ba ang Auto Claim Fused Pets? (claim / Fuse pagkatapos ng timer / reveal)
	function LH.ClaimJobPending()
		if not AutoClaimFusedPets then return false end
		if LocalPlayer:GetAttribute("FusionPresentationPending") == true then return true end
		local result = LocalPlayer:FindFirstChild("FusionResult")
		if result and result:FindFirstChild("Pet") then return true end
		local slots = LocalPlayer:FindFirstChild("FusionSlots")
		if slots and slots:GetAttribute("FusionStatus") == "Waiting" then
			return workspace:GetServerTimeNow() >= (slots:GetAttribute("EndsAt") or 0)
		end
		return false
	end

	LH.FuseHasWorkNow = function()
		return LH.FuseJobPending() or LH.ClaimJobPending()
	end

	local function RunAutoFuse()
		if LH.FarmPaused() then return end
		local remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
		local gameFolder = remotes and remotes:FindFirstChild("Game")
		local PlaceRemote = gameFolder and gameFolder:FindFirstChild("FusionPetPlace")
		local ActionRemote = gameFolder and gameFolder:FindFirstChild("FusionAction")
		if not PlaceRemote or not ActionRemote then return end

		local char = LocalPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		if not humanoid or humanoid.Health <= 0 or not backpack then return end

		-- tumatakbo na ang fusion: wala nang gagawin, mag-reset lang para sa susunod na ikot
		if IsFusionBusy() then
			FusePlaced = {}
			FuseStartTries = 0
			return
		end

		-- FIX: bumaba muna sa pet bago mag-TP sa fusion machine (naiipit kapag nakasakay)
		if LH.IsRiding and LH.IsRiding() then
			LH.DismountPet()
			char = LocalPlayer.Character
			humanoid = char and char:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end
		end

		-- mag-teleport sa fusion machine (kung malayo pa)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		if (hrp.Position - FuseMachineCFrame.Position).Magnitude > 8 then
			hrp.CFrame = FuseMachineCFrame
			task.wait(0.3)
		end

		-- alin ang may laman na (local record + nakita sa FusionSlots)
		local detected = DetectFilledSlots()
		local missing = {}
		for slot = 1, 4 do
			if not (FusePlaced[slot] or detected[slot]) then
				table.insert(missing, slot)
			end
		end

		-- lagyan LANG ang mga walang laman na slot; ang may laman na ay hindi ginagalaw
		if #missing > 0 then
			local candidates = GetFuseCandidates()
			if #candidates < #missing then return end

			for i, slot in ipairs(missing) do
				if not AutoFuse or not LH.Alive or LH.FarmPaused() then return end

				local petTool = candidates[i]
				if not petTool or not petTool.Parent then return end

				humanoid:EquipTool(petTool)
				local timeout = os.clock() + 2
				repeat task.wait() until petTool.Parent == char or os.clock() > timeout
				if petTool.Parent ~= char then return end

				PlaceRemote:FireServer(slot)
				task.wait(0.2)

				-- kung nandoon pa rin ang pet sa backpack/character, hindi pumasok sa machine
				if petTool.Parent == char or petTool.Parent == backpack then
					pcall(function() humanoid:UnequipTools() end)
					task.wait(0.5) -- huwag i-spam; subukan ulit mamaya
					return
				end

				FusePlaced[slot] = true
			end
		end

		-- kumpleto na ang 4 sa loob: Start na lang ang ipapadala
		if AutoFuse and LH.Alive and not LH.FarmPaused() then
			pcall(function() humanoid:UnequipTools() end)
			ActionRemote:FireServer("Start")
			FuseStartTries += 1
			task.wait(0.5)
			if FuseStartTries >= 3 then
				FuseRetryAt = os.clock() + 15
				task.wait(1) -- ayaw pa mag-start (kulang cash?), mas mabagal na retry pero hindi na ulit magpapalit ng pets
			end
		end
	end

	task.spawn(function()
		while LH.Alive do
			if IsFusionBusy() then
				FusePlaced = {}
				FuseStartTries = 0
				FuseRetryAt = 0
			end

			if AutoFuse and not AutoSellPet and not AutoSellAllPets and not LH.FarmPaused() and LH.FuseJobPending() then
				LH.FuseLockN += 1
				pcall(LH.FuseYield)
				LH.BgRun(RunAutoFuse)
				LH.FuseLockN = math.max(0, LH.FuseLockN - 1)
				task.wait(0.5)
			else
				task.wait(0.3)
			end
		end
	end)
end

-- AUTO CLAIM FUSED PETS
do
	-- Flow ng game: matapos ang timer ("Ready") -> "Fuse" -> lalabas ang FusionResult.Pet -> "Claim", Pet.PetKey
	local function RunAutoClaimFused()
		if LH.FarmPaused() then return end
		local remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
		local gameFolder = remotes and remotes:FindFirstChild("Game")
		local ActionRemote = gameFolder and gameFolder:FindFirstChild("FusionAction")
		if not ActionRemote then return end

		-- hintayin matapos ang reveal animation ng game
		if LocalPlayer:GetAttribute("FusionPresentationPending") == true then return end

		local result = LocalPlayer:FindFirstChild("FusionResult")
		local resultPet = result and result:FindFirstChild("Pet")

		-- mag-teleport sa fusion machine (kailangan nandoon para gumana ang reveal/claim)
		local function GoToMachine()
			if LH.FarmPaused() then return false end
			-- FIX: bumaba muna sa pet bago pumunta sa machine (Claim / Fuse)
			if LH.IsRiding and LH.IsRiding() then
				LH.DismountPet()
			end
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then return false end
			if (hrp.Position - FuseMachineCFrame.Position).Magnitude > 8 then
				hrp.CFrame = FuseMachineCFrame
				task.wait(0.2)
			end
			return true
		end

		-- 1) May resulta na: pumunta sa machine, tapos i-claim gamit ang PetKey (random na UID)
		if resultPet then
			if not GoToMachine() then return end
			local petKey = resultPet:GetAttribute("PetKey")
			if petKey then
				ActionRemote:FireServer("Claim", petKey)
			end
			return
		end

		-- 2) Walang resulta pa: kung tapos na ang timer ("Ready"), ipadala ang "Fuse"
		local slots = LocalPlayer:FindFirstChild("FusionSlots")
		if slots and slots:GetAttribute("FusionStatus") == "Waiting" then
			local endsAt = slots:GetAttribute("EndsAt") or 0
			if workspace:GetServerTimeNow() >= endsAt then
				if not GoToMachine() then return end
				ActionRemote:FireServer("Fuse")
				task.wait(6) -- hayaan munang tumakbo ang reveal (~5s)
			end
		end
	end

	task.spawn(function()
		while LH.Alive do
			if AutoClaimFusedPets and not LH.FarmPaused() and LH.ClaimJobPending() then
				LH.FuseLockN += 1
				pcall(LH.FuseYield)
				LH.BgRun(RunAutoClaimFused)
				LH.FuseLockN = math.max(0, LH.FuseLockN - 1)
				task.wait(0.5)
			else
				task.wait(0.3)
			end
		end
	end)
end

-- AUTO UPGRADE HATCH LUCK
task.spawn(function()
	while LH.Alive do
		if AutoUpgradeHatchLuck then
			pcall(function()
				local Remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local PlotFolder = GameRemotes and GameRemotes:FindFirstChild("Plot")
				local UpgradesRemote = PlotFolder and PlotFolder:FindFirstChild("Upgrades")

				if UpgradesRemote then
					UpgradesRemote:FireServer("Hatch Luck", 1)
				end
			end)
			task.wait(0.5)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO UPGRADE HATCH LUCK MAX
task.spawn(function()
	while LH.Alive do
		if AutoUpgradeHatchLuckMax then
			pcall(function()
				local Remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
				local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
				local PlotFolder = GameRemotes and GameRemotes:FindFirstChild("Plot")
				local UpgradesRemote = PlotFolder and PlotFolder:FindFirstChild("Upgrades")

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

-- AUTO REBIRTH LOOP
local function CanRebirth()
	local maxCap = tonumber(Mods.Rebirths_m.Cap)
	if maxCap and PD.Rebirths.Value >= maxCap then
		return false
	end

	local currentCost = Mods.Rebirths_m.GetCost(PD.Rebirths.Value)
	if PD.Cash.Value < currentCost then
		return false
	end

	local nextIndex = PD.Rebirths.Value + 1
	local reqList = Mods.General_m.RebirthRequirements

	if not reqList then
		return true
	end

	local requiredPet = reqList[math.clamp(nextIndex, 1, math.max(#reqList, 1))]

	if not requiredPet then
		return true
	end

	if Mods.PetRenderer_m and Mods.PetRenderer_m.GetAll then
		for _, val in pairs(Mods.PetRenderer_m.GetAll()) do
			if val.OwnerUserId == LocalPlayer.UserId and (val.Model and val.Model.Parent and val.Model.Name == requiredPet) then
				return true
			end
		end
	end

	local function ScanContainer(container)
		if not container then return false end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and string.find(child.Name, requiredPet) then
				return true
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
	local mountedPart = mountJoint and (mountJoint.Part1 and mountJoint.Parent)

	if mountedPart then
		local petAttr = mountedPart:GetAttribute("PetName") or mountedPart.Name
		if string.find(petAttr, requiredPet) then
			return true
		end
	end

	return false
end

task.spawn(function()
	while LH.Alive do
		if AutoRebirth then
			pcall(function()
				if CanRebirth() then
					local Remotes = Svc.ReplicatedStorage:FindFirstChild("Remotes")
					local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
					local RebirthRemote = GameRemotes and GameRemotes:FindFirstChild("Rebirth")

					if RebirthRemote then
						RebirthRemote:FireServer()
					end
				end
			end)

			task.wait(2)
		else
			task.wait(0.5)
		end
	end
end)

-- AUTO CLAIM INDEX REWARD
local function CanClaimIndexReward()
	local success, result = pcall(function()
		local discovered = Mods.IndexRewards.DiscoveredCount(PD.OwnedPetsIndex.Value)
		local stage = Mods.IndexRewards.StageAt(PD.IndexRewardStage.Value)
		if not stage then return false end
		return discovered >= stage.Goal
	end)
	return success and result == true
end

task.spawn(function()
	while LH.Alive do
		if AutoClaimIndex then
			if CanClaimIndexReward() then
				pcall(function() Rem.ClaimIndexReward:FireServer() end)
				task.wait(1)
			end
		end
		task.wait(0.5)
	end
end)

--==================================================
-- RIDE / DISMOUNT PET (AUTO FARM + AUTO CANDY)
--==================================================
LH.RodeByScript = false          -- true kapag ang script mismo ang sumakay sa pet
LH.CandyDismountAfterDrop = false -- false = nakasakay lang hanggang i-OFF ang toggle (default) | true = bababa pagkatapos ma-drop ang candy
LH.RideTimeout = 1.5             -- segundo na hihintayin ang sagot ng server sa ride / dismount

function LH.IsRiding()
	return LocalPlayer:GetAttribute("IsRiding") == true
end

-- Best pet sa INVENTORY (backpack / hawak) base sa income (parehong sorting ng Auto Equip Best Pet).
-- Hindi kasama ang mga pet na nakalagay na sa plot.
function LH.GetBestRidePet()
	for _, pet in ipairs(GetAllPetsSorted()) do
		if not pet.Placed and pet.Tool and pet.Tool.Parent then
			return pet.Tool
		end
	end
	return nil
end

-- Equip best pet -> Mounting remote -> hintayin na maging IsRiding
function LH.RidePet()
	local ok, result = pcall(function()
		if LH.IsRiding() then return true end

		local remote = GameRemotes:FindFirstChild("Mounting")
		if not remote then return false end

		for _ = 1, 3 do
			local char = GetCharacter()
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then return false end

			local tool = LH.GetBestRidePet()
			if not tool then return false end -- walang pet sa inventory na masasakyan

			if tool.Parent ~= char then
				hum:EquipTool(tool)
				local equipTimeout = os.clock() + 2
				repeat task.wait() until tool.Parent == char or os.clock() > equipTimeout
			end

			if tool.Parent == char then
				remote:FireServer()

				local rideTimeout = os.clock() + LH.RideTimeout
				repeat task.wait(0.05) until LH.IsRiding() or os.clock() > rideTimeout

				if LH.IsRiding() then
					LH.RodeByScript = true
					task.wait(0.2)
					return true
				end
			end
		end

		return false
	end)

	return ok and result == true
end

-- PetDismount remote -> hintayin na mawala ang IsRiding -> ibalik ang pet sa backpack
function LH.DismountPet()
	local ok = pcall(function()
		if not LH.IsRiding() then return end

		local remote = GameRemotes:FindFirstChild("PetDismount")
		if not remote then return end

		remote:FireServer()

		local timeout = os.clock() + LH.RideTimeout
		repeat task.wait(0.05) until not LH.IsRiding() or os.clock() > timeout

		local char = GetCharacter()
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum:UnequipTools() end
	end)

	LH.RodeByScript = false
	return ok
end

--==================================================
-- AUTO COLLECT CANDY (HALLOWEEN EVENT)
--==================================================
LH.CandyEvent = CFrame.new(
	-46040.7734, 40371.4453, -20327.2539,
	-0.780875802, 0, -0.62468636,
	0, 1, 0,
	0.62468636, 0, -0.780875802
)

LH.CandyHome = CFrame.new(
	-45842.9766, 40375.2734, -20118.6797,
	-0.99513644, -2.46834375e-08, -0.0985061005,
	-2.63667683e-08, 1, 1.57867746e-08,
	0.0985061005, 1.8307281e-08, -0.99513644
)

LH.FarmWantUntil = 0 -- itinatakda ng Auto Farm kapag may egg na kukunin (hindi na magsisimula ng bagong candy cycle)
LH.CandyEventRadius = 100000 -- FIX: malaking radius para hindi ma-reset ang position sa loob ng event
LH.CandyEventWait = 0.5
LH.CandyHomeWait = 0.5
LH.CandySkip = setmetatable({}, { __mode = "k" })

function LH.GetCandyPos(candy)
	if candy:IsA("BasePart") then
		return candy.Position
	elseif candy:IsA("Model") then
		local ok, pivot = pcall(function() return candy:GetPivot() end)
		if ok and pivot then return pivot.Position end
	end
	local part = candy:FindFirstChildWhichIsA("BasePart", true)
	if part then return part.Position end
	local attr = candy:GetAttribute("Position")
	if typeof(attr) == "Vector3" then return attr end
	return nil
end

function LH.GetCandyRemote()
	if LH.CandyRemote and LH.CandyRemote.Parent then
		return LH.CandyRemote
	end
	local r = GameRemotes:FindFirstChild("CollectCandy")
	if not r then
		for _, d in ipairs(Svc.ReplicatedStorage:GetDescendants()) do
			if d.Name == "CollectCandy" then r = d break end
		end
	end
	LH.CandyRemote = r
	return r
end

-- PRIORITY NG CANDY (mas mababang number = mas inuuna)
--  1) kahit anong may "Ritual" sa pangalan (RitualCandy:<random>, ritual Egg, etc.)
--  2) DoorCandy:<random>     (resulta ng Auto Knock Doors)
--  3) Candy_04  4) Candy_03  5) Candy_02  6) Candy_01  (candy na nakakalat sa map)
function LH.GetCandyRank(candy)
	local name = candy.Name
	-- FIX: dati "RitualCandy" lang; ngayon kahit anong named na "Ritual" (kasama ang Egg reward)
	if string.find(string.lower(name), "ritual", 1, true) then return 1 end
	if name:sub(1, 10) == "DoorCandy:" or name:sub(1, 9) == "DoorCandy" then return 2 end
	local n = tonumber(name:match("^Candy_?(%d+)"))
	if n then return 100 - n end -- Candy_04 = 96, Candy_03 = 97 ... (mas mataas na number = mas mataas na priority)
	return 1000
end

function LH.GetNextCandy()
	local folder = workspace:FindFirstChild("HalloweenCandy")
	if not folder then return nil end

	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local now = os.clock()
	local best, bestRank, bestDist

	for _, candy in ipairs(folder:GetChildren()) do
		local skipUntil = LH.CandySkip[candy]
		if not skipUntil or now >= skipUntil then
			local rank = LH.GetCandyRank(candy)
			local pos = LH.GetCandyPos(candy)
			local dist = (hrp and pos) and (hrp.Position - pos).Magnitude or math.huge
			-- unahin ang pinakamataas na priority; kung pareho, ang pinakamalapit
			if not best or rank < bestRank or (rank == bestRank and dist < bestDist) then
				best, bestRank, bestDist = candy, rank, dist
			end
		end
	end

	return best
end

function LH.GetCandyIds(candy)
	local ids, seen = {}, {}
	local function add(v)
		if type(v) == "string" and v ~= "" and not seen[v] then
			seen[v] = true
			table.insert(ids, v)
		end
	end

	for _, v in pairs(candy:GetAttributes()) do add(v) end
	for _, d in ipairs(candy:GetDescendants()) do
		if d:IsA("StringValue") then add(d.Value) end
		for _, v in pairs(d:GetAttributes()) do add(v) end
	end

	local rank = LH.GetCandyRank(candy)
	if rank <= 2 then
		-- RitualCandy / DoorCandy: pangalan muna ang ID, kasunod ang iba pang nakita
		local out = { candy.Name }
		for _, id in ipairs(ids) do
			if id ~= candy.Name then table.insert(out, id) end
		end
		return out
	end

	local matched = {}
	for _, id in ipairs(ids) do
		if id:match("^Candy%d+_%d+$") then table.insert(matched, id) end
	end
	if #matched > 0 then return matched end

	add(candy.Name)
	return ids
end

function LH.TriggerCandyPrompt(candy)
	local prompt = candy:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then return false end

	pcall(function() prompt.HoldDuration = 0 end)
	pcall(function() prompt.RequiresLineOfSight = false end)
	pcall(function()
		if prompt.MaxActivationDistance < 20 then prompt.MaxActivationDistance = 20 end
	end)

	if fireproximityprompt then
		local ok = pcall(fireproximityprompt, prompt)
		if ok then return true end
	end

	local okVim, vim = pcall(function() return game:GetService("VirtualInputManager") end)
	if okVim and vim then
		local key = prompt.KeyboardKeyCode
		if key == Enum.KeyCode.Unknown then key = Enum.KeyCode.E end
		pcall(function() vim:SendKeyEvent(true, key, false, game) end)
		task.wait(math.max(prompt.HoldDuration, 0) + 0.15)
		pcall(function() vim:SendKeyEvent(false, key, false, game) end)
		return true
	end

	return false
end

function LH.WaitCandyGone(candy, seconds)
	local started = os.clock()
	while candy.Parent and os.clock() - started < seconds and not LH.HallPaused() do
		task.wait(0.05)
	end
	return candy.Parent == nil
end

function LH.EnsureInEvent()
	if LH.HallPaused() then return true end 
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	if (hrp.Position - LH.CandyEvent.Position).Magnitude <= LH.CandyEventRadius then
		return false
	end

	hrp.CFrame = LH.CandyEvent
	LH.Stabilize()
	task.wait(LH.CandyEventWait)
	return true
end

function LH.CollectCandy(candy)
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if not candy.Parent then return true end

	local remote = LH.GetCandyRemote()
	local pos = LH.GetCandyPos(candy)

	for _ = 1, 3 do
		if LH.HallPaused() or not LH.AutoCandy then return true end
		if not candy.Parent then return true end

		-- nasa candy na: sumakay muna sa pet bago i-pick up
		if not LH.IsRiding() then
			LH.RidePet()
			if not candy.Parent then return true end
		end

		-- FIX: mag-TP SA CANDY pagkatapos sumakay (nagbabago ang position kapag sumasakay) at bago i-pick up
		pos = LH.GetCandyPos(candy) or pos
		if pos then
			hrp = (GetCharacter() or char):FindFirstChild("HumanoidRootPart") or hrp
			hrp.CFrame = LH.UprightCFrame(pos + Vector3.new(0, 2, 0))
			LH.Stabilize()
			task.wait(0.25)
		end

		LH.TriggerCandyPrompt(candy)
		if LH.WaitCandyGone(candy, 0.8) then
			return true
		end

		if remote then
			for _, id in ipairs(LH.GetCandyIds(candy)) do
				if LH.HallPaused() then return true end
				local args = { id }
				pcall(function()
					if remote:IsA("RemoteFunction") then
						remote:InvokeServer(unpack(args))
					else
						remote:FireServer(unpack(args))
					end
				end)
				if LH.WaitCandyGone(candy, 0.3) then
					return true
				end
			end
		end
	end

	return false
end

--// CANDY HOME TWEEN (rise -> fly straight -> descend)
-- Flow: TP sa candy -> kuha -> TAAS muna (lampas puno/bundok) -> straight na lipad sa taas ng Candy Home -> baba -> 0.5s wait -> next candy
LH.CandyTweenSpeed = math.clamp(tonumber(ConfigData.CandyTweenSpeed) or 100, 100, 1500) -- fixed speed (studs/sec), 100-1500 sa slider
LH.FarmTweenSpeed = math.clamp(tonumber(ConfigData.FarmTweenSpeed) or 100, 100, 1500)
LH.CandyTweenFallback = 100   -- gagamitin kung wala pang nasusukat na ride speed
LH.CandyClearance = 15        -- taas sa ibabaw ng pinakamataas na puno/bundok sa daan (studs)
LH.CandyScanStep = 8          -- layo ng bawat scan point sa daan (studs)
LH.CandyScanWidth = 6         -- scan sa kaliwa/kanan ng daan para hindi madaplisan ang puno
LH.CandyMaxRise = 400         -- max na taas na i-scan / aakyatin
LH.CandyHomeWait = 0.5        -- delay pagkabalik sa home bago kumuha ulit ng candy
LH.MeasuredRideSpeed = 0
LH.Tweening = false

-- FIX: "delivering" state = nakuha na ang candy pero hindi pa nakakauwi sa Candy Home.
-- Habang naka-ON ito, naghihintay ang Knock / Ritual / Buy Egg para hindi maputol ang tween pauwi.
LH.CandyCarry = false
LH.CandyCarryUntil = 0
LH.CandyCycle = false      -- true mula nang may napiling candy hanggang makauwi sa Candy Home
LH.CandyCycleUntil = 0
function LH.CandyDelivering()
	local now = os.clock()
	if LH.CandyCycle == true and now < (LH.CandyCycleUntil or 0) then return true end
	return LH.CandyCarry == true and now < (LH.CandyCarryUntil or 0) -- safety timeout para hindi ma-stuck
end

-- Sinusukat ang totoong bilis ng pet habang nakasakay ka (kapag ikaw mismo ang gumalaw)
Bind(Svc.RunService.Heartbeat, function()
	if LH.Tweening or not LH.IsRiding() then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local v = hrp.AssemblyLinearVelocity
	local s = Vector3.new(v.X, 0, v.Z).Magnitude
	if s > LH.MeasuredRideSpeed and s < 600 then
		LH.MeasuredRideSpeed = s
	end
end)

-- Priority: 1) slider  2) nasukat na bilis ng pet  3) WalkSpeed (kung mataas)  4) fallback
function LH.GetRideSpeed(hum, override)
	if override and override > 0 then return override end
	if LH.CandyTweenSpeed > 0 then return LH.CandyTweenSpeed end
	if LH.MeasuredRideSpeed >= 20 then return LH.MeasuredRideSpeed end
	local ws = hum and hum.WalkSpeed or 0
	if ws > 20 then return ws end
	return LH.CandyTweenFallback
end

function LH.SetMoveControls(enabled)
	pcall(function()
		local pm = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		local controls = pm:GetControls()
		if enabled then controls:Enable() else controls:Disable() end
	end)
end

-- Pinakamataas na bagay (puno, bundok, bato) sa daan mula a papuntang b
function LH.ScanTopY(a, b, char)
	local ignore = { char }
	local candyFolder = workspace:FindFirstChild("HalloweenCandy")
	if candyFolder then table.insert(ignore, candyFolder) end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore

	local flat = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
	local len = flat.Magnitude
	local dir = len > 1e-3 and flat.Unit or Vector3.new(0, 0, -1)
	local side = Vector3.new(-dir.Z, 0, dir.X)

	local originY = math.max(a.Y, b.Y) + LH.CandyMaxRise
	local rayLen = LH.CandyMaxRise + 600
	local steps = math.max(1, math.ceil(len / LH.CandyScanStep))
	local topY = -math.huge

	for i = 0, steps do
		local t = i / steps
		local bx, bz = a.X + (b.X - a.X) * t, a.Z + (b.Z - a.Z) * t
		for _, off in ipairs({ -LH.CandyScanWidth, 0, LH.CandyScanWidth }) do
			local origin = Vector3.new(bx + side.X * off, originY, bz + side.Z * off)
			for _ = 1, 4 do
				local hit = workspace:Raycast(origin, Vector3.new(0, -rayLen, 0), params)
				if not hit then break end
				local inst = hit.Instance
				local otherChar = inst:FindFirstAncestorOfClass("Model")
				local skip = not inst:IsA("Terrain")
					and (inst.Transparency >= 0.95
						or (otherChar and otherChar:FindFirstChildOfClass("Humanoid") ~= nil))
				if skip then
					table.insert(ignore, inst)
					params.FilterDescendantsInstances = ignore
				else
					if hit.Position.Y > topY then topY = hit.Position.Y end
					break
				end
			end
		end
	end
	return topY
end

function LH.TweenToCFrame(targetCF, shouldContinue, speedOverride)
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return false end

	local target = targetCF.Position
	local startPos = hrp.Position

	-- Cruise height: lampas sa pinakamataas na bagay sa daan
	local topY = LH.ScanTopY(startPos, target, char)
	local cruiseY = math.max(startPos.Y, target.Y, topY + LH.CandyClearance)
	cruiseY = math.min(cruiseY, math.max(startPos.Y, target.Y) + LH.CandyMaxRise)

	-- 3 segments: TAAS (vertical) -> STRAIGHT (flat) -> BABA (vertical)
	local points = {
		startPos,
		Vector3.new(startPos.X, cruiseY, startPos.Z),
		Vector3.new(target.X, cruiseY, target.Z),
		target,
	}
	local segLens, total = {}, 0
	for i = 1, 3 do
		segLens[i] = (points[i + 1] - points[i]).Magnitude
		total += segLens[i]
	end
	if total < 1 then
		hrp.CFrame = targetCF
		LH.Stabilize()
		return true
	end

	-- FIXED SPEED: isang beses lang kinukuha bago mag-tween
	local speed = LH.GetRideSpeed(hum, speedOverride)

	-- Fixed rotation habang nag-tween (walang ikot = walang alog ang camera)
	local flat = Vector3.new(target.X - startPos.X, 0, target.Z - startPos.Z)
	if flat.Magnitude < 1e-3 then
		local look = hrp.CFrame.LookVector
		flat = Vector3.new(look.X, 0, look.Z)
	end
	if flat.Magnitude < 1e-3 then flat = Vector3.new(0, 0, -1) end
	local rot = CFrame.lookAt(Vector3.zero, flat.Unit)

	local wasAnchored = hrp.Anchored
	local oldAutoRotate = hum.AutoRotate

	LH.Tweening = true
	LH.SetMoveControls(false) -- tween lang ang gagalaw
	hum.AutoRotate = false
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.Anchored = true

	local ok = pcall(function()
		local traveled = 0
		while traveled < total do
			if not shouldContinue() then
				return
			end
			if not hrp.Parent or hum.Health <= 0 then return end

			local dt = math.min(Svc.RunService.Heartbeat:Wait(), 0.1)
			traveled = math.min(total, traveled + speed * dt)

			-- hanapin kung nasaang segment tayo
			local remaining = traveled
			local pos = points[4]
			for i = 1, 3 do
				if remaining <= segLens[i] then
					local a = segLens[i] > 0 and (remaining / segLens[i]) or 1
					pos = points[i]:Lerp(points[i + 1], a)
					break
				end
				remaining -= segLens[i]
			end

			hrp.CFrame = CFrame.new(pos) * rot
		end

		hrp.CFrame = targetCF -- nasa Candy Home na
	end)

	-- ALWAYS ibalik ang movement
	hrp.Anchored = wasAnchored
	hum.AutoRotate = oldAutoRotate
	LH.SetMoveControls(true)
	LH.Tweening = false
	LH.Stabilize()

	return ok
end

function LH.TweenToCandyHome()
	return LH.TweenToCFrame(LH.CandyHome, function()
		-- FIX: huwag putulin ng Buy Egg / Ritual ang tween pauwi; patapusin muna ang delivery
		return LH.Alive and LH.AutoCandy and not LH.HallPaused()
	end)
end

-- Plot target (parehong lugar ng dating TeleportToMyPlot)
function LH.GetMyPlotCFrame()
	local MyPlot = LH.GetMyPlot()
	if not MyPlot then return nil end
	local part = MyPlot:FindFirstChild("Baseplate")
	if not (part and part:IsA("BasePart")) then
		part = MyPlot:FindFirstChildWhichIsA("BasePart", true)
	end
	if not part then return nil end
	return LH.UprightCFrame((part.CFrame * CFrame.new(0, 3, 0)).Position)
end

-- Auto Farm: TAAS (lampas puno) -> straight -> baba sa plot
function LH.TweenToMyPlot()
	local cf = LH.GetMyPlotCFrame()
	if not cf then return TeleportToMyPlot() end
	return LH.TweenToCFrame(cf, function()
		return LH.Alive and AutoPickup == true
	end, LH.FarmTweenSpeed)
end

-- Instant TP: diretsong teleport sa Candy Home (walang tween)
function LH.TPToCandyHome()
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	hrp.CFrame = LH.CandyHome
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	LH.Stabilize()
	return true
end

function LH.GoCandyHome()
	if LH.HallPaused() then return end
	if LH.CandyMoveMode == "Instant TP" then
		LH.TPToCandyHome()
	else
		LH.TweenToCandyHome()
	end
	-- 0.5s delay bago kumuha ulit ng candy
	local started = os.clock()
	while LH.Alive and LH.AutoCandy and not LH.HallPaused() and os.clock() - started < LH.CandyHomeWait do
		task.wait(0.05)
	end
end

function LH.CandyStep()
	local teleported = false
	LH.BgRun(function()
		teleported = LH.EnsureInEvent()
	end)
	if teleported then return end

	local candy = LH.GetNextCandy()
	if not candy then
		task.wait(0.5)
		return
	end

	-- FIX: i-lock ang buong cycle (kuha -> tween pauwi) para hindi mag-TP ang Ritual / Knock / Buy Egg sa gitna
	LH.CandyCycle = true
	LH.CandyCycleUntil = os.clock() + 75

	if not LH.IsRiding() then
		LH.BgRun(LH.RidePet)
	end

	local ok = LH.BgRun(function()
		if not LH.CollectCandy(candy) then
			LH.CandySkip[candy] = os.clock() + 2
		end
	end)
	if not ok then
		LH.CandySkip[candy] = os.clock() + 2
	end

	-- FIX: kapag hindi nakuha ang candy (nandoon pa rin), huwag mag-tween sa Candy Home; subukan ulit sa susunod
	if candy.Parent ~= nil then
		LH.CandySkip[candy] = os.clock() + 1
		return
	end

	-- FIX: nakuha na ang candy -> i-lock hanggang makauwi sa Candy Home (bago mag-Knock / Ritual / Buy Egg)
	LH.CandyCarry = true
	LH.CandyCarryUntil = os.clock() + 60
	if LH.Alive and LH.AutoCandy and not LH.HallPaused() then
		LH.BgRun(LH.GoCandyHome)
		if LH.CandyDismountAfterDrop then
			LH.BgRun(LH.DismountPet)
		end
	end
	LH.CandyCarry = false
end

task.spawn(function()
	while LH.Alive do
		if LH.AutoCandy and (LH.BuyActive() or LH.RitualActive() or LH.KnockActive()) then
			LH.CandyActing = false
			task.wait(0.1)
			continue
		end

		if not LH.AutoCandy or LH.HallPaused() then
			LH.CandyActing = false
			if not LH.AutoCandy and not AutoPickup and LH.RodeByScript then
				LH.BgRun(LH.DismountPet)
			end
			task.wait(0.3)
			continue
		end

		-- FIX: may egg na kukunin ang Auto Farm -> huwag nang magsimula ng bagong candy cycle,
		-- hayaan munang matapos ang kasalukuyang cycle (kuha + tween pauwi sa Candy Home)
		if os.clock() < (LH.FarmWantUntil or 0) then
			LH.CandyActing = false
			task.wait(0.05)
			continue
		end

		LH.CandyActing = true
		pcall(LH.CandyStep)
		LH.CandyCycle = false
		LH.CandyActing = false

		task.wait()
	end
end)

--==================================================
-- AUTO KNOCK DOORS (HALLOWEEN EVENT)
-- TP sa lit door -> knock -> hanap ulit ng door -> ulit
--==================================================
LH.CollectionService = game:GetService("CollectionService")
LH.KnockLit = {}            -- [doorId] = true kapag may ilaw (lit) ang door
LH.KnockCooldown = {}       -- [doorId] = oras kung kailan pwede ulit i-knock
LH.KnockCooldownTime = 4    -- segundo bago ulit i-knock ang parehong door
LH.KnockTPDelay = 0.2       -- delay pagkatapos mag-TP bago mag-knock
LH.KnockSearchDelay = 0.5   -- delay kapag walang nahanap na door bago maghanap ulit
LH.KnockLastResult = nil

function LH.HouseId(model)
	local id = model:GetAttribute("Id")
	if type(id) == "string" and id ~= "" then
		return id
	end
	local pos = model:GetPivot().Position
	return string.format("Door_%d_%d", math.round(pos.X), math.round(pos.Z))
end

task.spawn(function()
	LH.KnockRemote = GameRemotes:WaitForChild("KnockDoor", 15)
	LH.GetDoorStateRemote = GameRemotes:WaitForChild("GetDoorState", 15)
	local doorState = GameRemotes:WaitForChild("DoorState", 15)
	local doorKnocked = GameRemotes:WaitForChild("DoorKnocked", 15)

	-- live update kung aling door ang may ilaw
	if doorState then
		Bind(doorState.OnClientEvent, function(id, lit)
			if type(id) ~= "string" then return end
			LH.KnockLit[id] = (lit == true) or nil
		end)
	end

	-- sagot ng server sa knock (success = nil -> tinanggihan, may reason)
	if doorKnocked then
		Bind(doorKnocked.OnClientEvent, function(id, success, _, reason)
			LH.KnockLastResult = { Id = id, Ok = success ~= nil, Reason = reason }
			if success == nil and type(id) == "string" then
				LH.KnockCooldown[id] = os.clock() + 5
				if reason == "dark" or reason == "unknown-house" then
					LH.KnockLit[id] = nil
				end
			end
		end)
	end
end)

-- kunin ang listahan ng lit doors galing sa server
function LH.RefreshDoorState()
	local remote = LH.GetDoorStateRemote
	if not remote then return false end

	local ok, result = pcall(function()
		return remote:InvokeServer()
	end)

	if ok and type(result) == "table" and type(result.Lit) == "table" then
		local lit = {}
		for key, value in pairs(result.Lit) do
			if type(key) == "string" and value == true then
				lit[key] = true
			end
		end
		LH.KnockLit = lit
		return true
	end

	return false
end

-- pinakamalapit na lit door na hindi pa nako-knock
function LH.GetNextDoor()
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local now = os.clock()
	local best, bestDist

	for _, model in ipairs(LH.CollectionService:GetTagged("TrickOrTreatHouseModel")) do
		if model:IsA("Model") and model:IsDescendantOf(workspace) then
			local id = LH.HouseId(model)
			local cooldown = LH.KnockCooldown[id]

			if LH.KnockLit[id] and (not cooldown or now >= cooldown) then
				local doorPart = model:FindFirstChild("Door")
				local pos
				if doorPart and doorPart:IsA("BasePart") then
					pos = doorPart.Position
				else
					local okPivot, pivot = pcall(function() return model:GetPivot() end)
					pos = okPivot and pivot and pivot.Position or nil
				end

				if pos then
					local dist = hrp and (hrp.Position - pos).Magnitude or 0
					if not bestDist or dist < bestDist then
						best, bestDist = { Id = id, Model = model, Pos = pos }, dist
					end
				end
			end
		end
	end

	return best
end

function LH.KnockAtDoor(entry)
	local remote = LH.KnockRemote
	if not remote or not entry then return false end

	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if not LH.AutoKnock or LH.HallPaused() or LH.BuyActive() or LH.RitualActive() or LH.CandyDelivering() then return false end

	-- TP sa door
	hrp.CFrame = LH.UprightCFrame(entry.Pos + Vector3.new(0, 3, 0))
	LH.Stabilize()
	task.wait(LH.KnockTPDelay)

	if not LH.AutoKnock or LH.HallPaused() or LH.BuyActive() or LH.RitualActive() or LH.CandyDelivering() then return false end

	-- KNOCK
	LH.KnockLastResult = nil
	LH.KnockCooldown[entry.Id] = os.clock() + LH.KnockCooldownTime
	pcall(function()
		remote:FireServer(entry.Id)
	end)

	-- tapos na ang knock -> hindi na lit ang door na ito
	LH.KnockLit[entry.Id] = nil
	return true
end

task.spawn(function()
	while LH.Alive do
		if not LH.AutoKnock or LH.HallPaused() then
			LH.KnockHasDoor = false
			LH.KnockActing = false
			task.wait(0.3)
			continue
		end

		-- Halloween Egg at Auto Ritual ay mas mataas ang priority kaysa Knock
		if LH.BuyActive() or LH.RitualActive() then
			LH.KnockActing = false
			task.wait(0.2)
			continue
		end

		-- FIX: may candy na papunta pa sa Candy Home -> hintayin muna bago mag-TP sa door
		if LH.CandyDelivering() then
			LH.KnockActing = false
			task.wait(0.1)
			continue
		end

		LH.KnockActing = true
		LH.BgRun(function()
			if LH.EnsureInEvent() then return end

			local entry = LH.GetNextDoor()
			if not entry then
				LH.RefreshDoorState()
				entry = LH.GetNextDoor()
			end

			LH.KnockHasDoor = entry ~= nil

			if entry then
				LH.KnockAtDoor(entry)
			else
				task.wait(LH.KnockSearchDelay)
			end
		end)
		LH.KnockActing = false

		task.wait()
	end
end)


--==================================================
-- AUTO BUY HALLOWEEN EGG
-- Bibili lang kapag sapat ang Halloween Tokens
--==================================================
LH.HalloweenEggName = "Halloween Egg"
LH.HalloweenNPC = CFrame.new(
	-45763.6328, 40371.375, -20301.541,
	0.199452475, 1.03902856e-07, -0.979907513,
	-4.83451359e-08, 1, 9.61930624e-08,
	0.979907513, 2.81878183e-08, 0.199452475
)

-- kailangan malapit sa NPC para gumana ang bili
function LH.GoToHalloweenNPC()
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if (hrp.Position - LH.HalloweenNPC.Position).Magnitude > 6 then
		hrp.CFrame = LH.HalloweenNPC
		LH.Stabilize()
		task.wait(0.3)
	end
	return true
end

function LH.GetHalloweenTokens()
	local savedData = LocalPlayer:FindFirstChild("SavedData")
	local tokens = savedData and savedData:FindFirstChild("HalloweenCandy")
	return tokens and tonumber(tokens.Value) or 0
end

task.spawn(function()
	local buyRemote = GameRemotes:WaitForChild("BuyHalloweenEgg", 15)

	while LH.Alive do
		if not LH.AutoHaEgg or not buyRemote or LH.HallPaused() then
			LH.HaEggFails = 0
			task.wait(0.5)
			continue
		end

		-- FIX: hintayin munang makauwi sa Candy Home ang hawak na candy bago pumunta sa NPC
		if LH.CandyDelivering() then
			task.wait(0.1)
			continue
		end

		local tokensBefore = LH.GetHalloweenTokens()

		-- kulang pa ang token: HUWAG mag-fire, maghintay lang
		if tokensBefore < LH.HalloweenEggPrice then
			task.wait(1)
			continue
		end

		LH.BuyActing = true
		LH.BgRun(function()
			if not LH.GoToHalloweenNPC() then return end
			pcall(function()
				buyRemote:InvokeServer(LH.HalloweenEggName)
			end)
			task.wait(0.5)
		end)
		LH.BuyActing = false

		-- kung hindi bumaba ang token, pumalya ang bili: bagalan ang retry para hindi ma-spam
		if LH.GetHalloweenTokens() >= tokensBefore then
			LH.HaEggFails += 1
			task.wait(math.min(LH.HaEggFails * 2, 10))
		else
			LH.HaEggFails = 0
			task.wait(0.3)
		end
	end
end)


--==================================================
-- AUTO RITUAL (HALLOWEEN EVENT - YIN & YANG)  [REFACTORED]
-- Priority: Auto Farm > Auto Fuse/Claim > 1) Auto Buy Halloween Egg  2) Auto Ritual  3) Auto Knock  4) Auto Collect Candy
--
-- FLOW:
--  1) May Yin/Yang piece sa mapa -> TP -> pickup
--  2) Hawak na ang piece -> TP sa Yin Yang Cave -> ilagay
--  3) Kapag pareho nang nailagay (Yin + Yang) -> buksan ang cave
--
-- MGA BUG NA INAYOS:
--  A) "You Already Have The Yin/Yang Half"
--     -> hindi na pipilitin kunin. Itinuturing na HAWAK na natin ito: diretso TP sa cave at ilagay.
--  B) "You Already Collected Yin/Yang. Wait For The Next Egg Restock."
--     -> 2 fire lang kada pickup. Kapag pareho ang resulta: BACKOFF 20s -> 30s -> 40s -> 50s (50s na ang max).
--        Habang naka-backoff, HINDI hawak ng Ritual ang priority, kaya tuloy ang Candy / Knock / Farm.
--  C) Kapag hindi mailagay sa cave nang ilang beses -> parehong backoff din (walang infinite TP loop).
--==================================================
LH.YinYangCave = CFrame.new( -46378.4648, 40345.7656, -19666.6895, -0.781531572, 7.42021058e-08, 0.623865664, -1.59661617e-08, 1, -1.38940436e-07, -0.623865664, -1.18547078e-07, -0.781531572 
)

LH.RitualHalves = { "Yin", "Yang" }
LH.RitualPickupFires = 2      -- ilang beses lang i-fire ang pickup prompt kada attempt
LH.RitualFireGap = 0.6        -- hintay pagkatapos ng bawat fire (para makita ang sagot ng server)
LH.RitualBackoff = { 20, 30, 40, 50 } -- seconds: 1st fail = 20s, 2nd = 30s, 3rd = 40s, 4th+ = 50s (max)
LH.RitualDepositTime = 12     -- max segundo sa cave
LH.RitualCaveGrace = 1        -- hintay pagkatapos mag-TP para ma-update ng laro ang RitualSuppressed
LH.RitualIdleLimit = 4        -- tapos na kapag walang na-fire sa loob ng ganitong segundo
LH.RitualMaxTries = 6         -- max na pag-fire kada prompt sa cave
LH.RitualRetryDelay = 1       -- delay bago ulit i-fire ang parehong prompt sa cave
LH.RitualRestTime = 4         -- pahinga kapag bigo ang paglagay
LH.RitualYieldWait = 4        -- max segundo na hihintayin para magpahinga ang Candy/Knock
LH.RitualCompleteDelay = 1.5  -- hintay bago ituring na "complete"
LH.RitualFinishRest = 8       -- pahinga pagkatapos subukang buksan ang cave
LH.RitualMaxDepositFails = 3  -- ilang beses subukang ilagay ang piece bago i-backoff
LH.RitualDebug = false        -- i-set sa true para makita sa output kung ano ang nangyayari (kasama ang messages)

LH.RitualBusyCave = false
LH.RitualSkip = setmetatable({}, { __mode = "k" }) -- [piece] = oras hanggang kailan lalaktawan (piece na walang prompt)

-- STATE NG RITUAL (nare-reset kapag nag-iba ang RoundId)
LH.RitualCarrying = {}        -- [half] = true kapag NAKUHA na natin ang piece pero HINDI pa nailalagay
LH.RitualPlaced = {}          -- [half] = true kapag nailagay na natin (backup lang; mas pinagkakatiwalaan ang RitualView)
LH.RitualDepositFails = {}    -- [half] = ilang beses nang bigo ang paglagay
LH.RitualBlock = {}           -- [half] = { Strikes = n, Until = oras } (backoff)
LH.RitualMsg = {}             -- [half] = { Have = oras, Collected = oras } (galing sa message ng laro)
LH.RitualAttempt = nil        -- half na kasalukuyang kinukuha (para sa message na walang nakasulat na half)
LH.RitualRound = nil
LH.RitualCompleteSince = nil
LH.RitualFinishUntil = 0
LH.RitualIdleUntil = 0

function LH.RitualLog(...)
	if LH.RitualDebug then
		warn("[Ritual]", ...)
	end
end

function LH.RitualFolder(half)
	local root = workspace:FindFirstChild("HeadlessRitual")
	local runtime = root and root:FindFirstChild("Runtime")
	return runtime and runtime:FindFirstChild(half)
end

function LH.IsHoldingHalf(half)
	return LocalPlayer:GetAttribute("Ritual" .. half) == true
end

--==================================================
-- BACKOFF (20s -> 30s -> 40s -> 50s max)
--==================================================
function LH.RitualBlocked(half)
	local b = LH.RitualBlock[half]
	return b ~= nil and os.clock() < b.Until
end

function LH.RitualBlockHalf(half, why)
	local b = LH.RitualBlock[half]
	if not b then
		b = { Strikes = 0, Until = 0 }
		LH.RitualBlock[half] = b
	end
	b.Strikes += 1
	local list = LH.RitualBackoff
	local delay = list[math.min(b.Strikes, #list)]
	b.Until = os.clock() + delay
	LH.RitualLog("backoff", half, why or "?", "strike", b.Strikes, "wait", delay .. "s")
end

function LH.RitualUnblock(half)
	LH.RitualBlock[half] = nil
end

--==================================================
-- MESSAGE LISTENER
--  "You Already Have The Yin/Yang Half"                         -> Have
--  "You Already Collected Yin/Yang. Wait For The Next Egg Restock" -> Collected
-- Binabasa mula sa (1) kahit anong RemoteEvent na may string args, at (2) text ng kahit anong GUI label.
--==================================================
function LH.RitualMsgEntry(half)
	local e = LH.RitualMsg[half]
	if not e then
		e = { Have = 0, Collected = 0 }
		LH.RitualMsg[half] = e
	end
	return e
end

function LH.OnRitualText(raw)
	if not LH.Alive or type(raw) ~= "string" or #raw > 300 then return end
	local text = string.lower((raw:gsub("<[^>]+>", "")))

	local kind
	if string.find(text, "already have", 1, true) then
		kind = "Have"
	elseif string.find(text, "already collected", 1, true) or string.find(text, "egg restock", 1, true) then
		kind = "Collected"
	else
		return
	end

	local half
	if string.find(text, "yang", 1, true) then
		half = "Yang"
	elseif string.find(text, "yin", 1, true) then
		half = "Yin"
	else
		half = LH.RitualAttempt -- walang nakasulat na half: gamitin ang kasalukuyang kinukuha
	end
	if not half then return end

	LH.RitualMsgEntry(half)[kind] = os.clock()
	LH.RitualLog("message", kind, half, "|", raw)

	-- Already Have: hawak na natin ito -> ilagay na lang sa cave (huwag nang kunin ulit)
	if kind == "Have" and not LH.RitualIsPlaced(half) then
		LH.RitualCarrying[half] = true
		LH.RitualIdleUntil = 0
	end
end

task.spawn(function()
	-- (1) RemoteEvents
	local function ScanArgs(value, depth)
		if depth > 3 then return end
		if type(value) == "string" then
			LH.OnRitualText(value)
		elseif type(value) == "table" then
			for _, v in pairs(value) do ScanArgs(v, depth + 1) end
		end
	end

	local okR, remotes = pcall(function() return Svc.ReplicatedStorage:WaitForChild("Remotes", 10) end)
	if okR and remotes then
		for _, r in ipairs(remotes:GetDescendants()) do
			if r:IsA("RemoteEvent") then
				Bind(r.OnClientEvent, function(...)
					for _, a in ipairs({ ... }) do ScanArgs(a, 0) end
				end)
			end
		end
	end

	-- (2) GUI text (toast / notification label)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not playerGui then return end

	local function Watch(inst)
		if inst:IsA("TextLabel") or inst:IsA("TextButton") then
			inst:GetPropertyChangedSignal("Text"):Connect(function()
				if LH.Alive and inst.Text ~= "" then LH.OnRitualText(inst.Text) end
			end)
		end
	end

	for _, d in ipairs(playerGui:GetDescendants()) do Watch(d) end
	Bind(playerGui.DescendantAdded, function(d)
		Watch(d)
		if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" then
			LH.OnRitualText(d.Text)
		end
	end)
end)

--==================================================
-- RITUAL STATE
--==================================================
-- LocalPlayer.RitualView: Phase ("Pending" / "Open" / "Closing"), RoundId, YinStartedAt, YangStartedAt
function LH.RitualView()
	return LocalPlayer:FindFirstChild("RitualView")
end

function LH.RitualPhase()
	local rv = LH.RitualView()
	return rv and rv:GetAttribute("Phase") or nil
end

-- NAILAGAY NA ba ang piece sa cave? (server truth: YinStartedAt / YangStartedAt)
function LH.RitualIsPlaced(half)
	local rv = LH.RitualView()
	if rv and type(rv:GetAttribute(half .. "StartedAt")) == "number" then
		return true
	end
	return LH.RitualPlaced[half] == true
end

-- i-reset ang lahat ng state kapag bagong round + i-detect ang hawak na piece
function LH.RitualSync()
	local rv = LH.RitualView()
	local round = rv and rv:GetAttribute("RoundId") or nil
	if round ~= LH.RitualRound then
		LH.RitualRound = round
		LH.RitualCarrying = {}
		LH.RitualPlaced = {}
		LH.RitualDepositFails = {}
		LH.RitualBlock = {}
		LH.RitualMsg = {}
		LH.RitualCompleteSince = nil
		LH.RitualFinishUntil = 0
		LH.RitualIdleUntil = 0
		LH.RitualLog("new round", tostring(round))
	end

	-- FIX (Already Have): kung HAWAK na natin ang piece (attribute Ritual<half>) at hindi pa nailalagay,
	-- huwag nang hanapin sa mapa; ilagay na lang sa cave.
	for _, half in ipairs(LH.RitualHalves) do
		if LH.IsHoldingHalf(half) and not LH.RitualIsPlaced(half) and not LH.RitualBlocked(half) then
			LH.RitualCarrying[half] = true
		end
	end
	return rv
end

-- hawak natin ang piece at HINDI pa nailalagay at HINDI naka-backoff = kailangan nang mag-TP sa cave
function LH.RitualCarryingNow(half)
	if LH.RitualIsPlaced(half) then
		LH.RitualCarrying[half] = nil
		return false
	end
	return LH.RitualCarrying[half] == true and not LH.RitualBlocked(half)
end

function LH.RitualAnyCarrying()
	for _, half in ipairs(LH.RitualHalves) do
		if LH.RitualCarryingNow(half) then return true end
	end
	return false
end

-- KUMPLETO na ba? (pareho nang nailagay ang Yin at Yang)
function LH.RitualComplete()
	for _, half in ipairs(LH.RitualHalves) do
		if not LH.RitualIsPlaced(half) then return false end
	end
	return true
end

-- mag-TP lang para BUKSAN ang cave kapag kumpleto na AT hindi pa bukas
function LH.RitualNeedsFinish()
	if not LH.RitualComplete() then
		LH.RitualCompleteSince = nil
		return false
	end
	local phase = LH.RitualPhase()
	if phase ~= nil and phase ~= "Pending" then
		LH.RitualCompleteSince = nil -- bukas na / nagsasara na
		return false
	end
	local now = os.clock()
	LH.RitualCompleteSince = LH.RitualCompleteSince or now
	if now - LH.RitualCompleteSince < LH.RitualCompleteDelay then return false end
	return now >= (LH.RitualFinishUntil or 0)
end

-- pinakamalapit na piece ng half (hindi kasama kung naka-backoff ang half)
function LH.GetRitualPiece(half)
	if LH.RitualBlocked(half) then return nil end
	local folder = LH.RitualFolder(half)
	if not folder then return nil end
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local best, bestDist
	local now = os.clock()
	for _, piece in ipairs(folder:GetChildren()) do
		local pos = (now >= (LH.RitualSkip[piece] or 0)) and LH.GetCandyPos(piece) or nil
		if pos then
			local dist = hrp and (hrp.Position - pos).Magnitude or 0
			if not bestDist or dist < bestDist then
				best, bestDist = piece, dist
			end
		end
	end
	return best
end

-- may trabaho ba ang Auto Ritual?
--  1) may piece sa mapa na pwedeng kunin (hindi naka-backoff)
--  2) may hawak tayong piece na hindi pa nailalagay (at hindi naka-backoff)
--  3) kumpleto na ang Yin + Yang at hindi pa bukas ang cave
-- Kapag naka-backoff / wala pang spawn -> FALSE (tuloy ang Candy/Knock/Farm, walang TP)
function LH.RitualHasWorkNow()
	if LH.RitualBusyCave then return true end
	LH.RitualSync()
	local now = os.clock()
	for _, half in ipairs(LH.RitualHalves) do
		if LH.RitualCarryingNow(half) and now >= (LH.RitualIdleUntil or 0) then return true end
		if not LH.RitualIsPlaced(half) and not LH.RitualCarrying[half] and not LH.RitualBlocked(half) then
			if LH.RitualFolder(half) and LH.GetRitualPiece(half) then return true end
		end
	end
	return LH.RitualNeedsFinish()
end

function LH.RitualCanRun()
	return LH.Alive and LH.AutoRitual == true and not LH.BuyActive() and not LH.HallPaused()
end

-- hintayin munang tumigil ang Candy / Knock bago mag-TP (para walang mag-overwrite ng position)
function LH.RitualWaitYield()
	local started = os.clock()
	while (LH.CandyActing or LH.KnockActing or LH.Tweening) and os.clock() - started < LH.RitualYieldWait do
		task.wait(0.05)
	end
end

function LH.FireRitualPrompt(prompt)
	if not prompt or not prompt.Parent then return false end
	pcall(function() prompt.HoldDuration = 0 end)
	pcall(function() prompt.RequiresLineOfSight = false end)
	pcall(function()
		if prompt.MaxActivationDistance < 30 then prompt.MaxActivationDistance = 30 end
	end)

	if fireproximityprompt then
		local ok = pcall(fireproximityprompt, prompt)
		if ok then return true end
	end

	local okVim, vim = pcall(function() return game:GetService("VirtualInputManager") end)
	if okVim and vim then
		local key = prompt.KeyboardKeyCode
		if key == Enum.KeyCode.Unknown then key = Enum.KeyCode.E end
		pcall(function() vim:SendKeyEvent(true, key, false, game) end)
		task.wait(0.15)
		pcall(function() vim:SendKeyEvent(false, key, false, game) end)
		return true
	end

	return false
end

function LH.RitualTP(cf)
	local char = GetCharacter()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	hrp.CFrame = cf
	LH.Stabilize()
	task.wait(0.25)
	return true
end

--==================================================
-- PICKUP (2 fire lang; kapag pareho ang resulta -> backoff)
--==================================================
function LH.PickupRitualPiece(half)
	-- hawak na pala natin: huwag nang kunin, ilagay na lang
	if LH.IsHoldingHalf(half) then
		LH.RitualCarrying[half] = true
		return true
	end

	local piece = LH.GetRitualPiece(half)
	if not piece then return false end
	local pos = LH.GetCandyPos(piece)
	if not pos then return false end

	local prompt = piece:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		LH.RitualSkip[piece] = os.clock() + 5
		return false
	end

	local pieceCF = LH.UprightCFrame(pos + Vector3.new(0, 3, 0))
	if not LH.RitualTP(pieceCF) then return false end

	LH.RitualAttempt = half
	local t0 = os.clock()
	local result = "fail" -- "ok" | "have" | "collected" | "fail"

	for fire = 1, LH.RitualPickupFires do
		if not LH.RitualCanRun() then
			LH.RitualAttempt = nil
			return false
		end

		-- kung may nag-alis sa atin sa piece, bumalik
		local char = GetCharacter()
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and (hrp.Position - pieceCF.Position).Magnitude > 15 then
			LH.RitualTP(pieceCF)
		end

		LH.FireRitualPrompt(prompt)

		-- hintayin ang sagot ng server (poll para mabilis kung may sagot na)
		local waited = 0
		while waited < LH.RitualFireGap do
			task.wait(0.1)
			waited += 0.1

			local msg = LH.RitualMsg[half]
			if not piece.Parent or not piece:IsDescendantOf(workspace) or LH.IsHoldingHalf(half) then
				result = "ok"
				break
			end
			if msg and msg.Have >= t0 then
				result = "have"
				break
			end
			if msg and msg.Collected >= t0 then
				result = "collected"
				break
			end
		end

		if result ~= "fail" then break end
	end

	LH.RitualAttempt = nil

	if result == "ok" or result == "have" then
		-- nakuha na (o hawak na pala) -> ilagay sa cave
		LH.RitualLog("pickup", result, half)
		LH.RitualCarrying[half] = true
		LH.RitualUnblock(half)
		return true
	end

	-- "collected" o walang nangyari pagkatapos ng 2 fire -> parehong resulta: backoff 20/30/40/50s
	LH.RitualBlockHalf(half, result)
	return false
end

--==================================================
-- CAVE (place / finish)
--==================================================
-- lahat ng ritual prompt na nasa cave (pinapauna ang hindi suppressed)
function LH.GetCavePrompts(fallbackAll)
	local out = {}
	for _, p in ipairs(LH.CollectionService:GetTagged("HalloweenRitualPrompt")) do
		if p:IsA("ProximityPrompt") and p:IsDescendantOf(workspace) then
			if p:GetAttribute("RitualSuppressed") ~= true or fallbackAll then
				table.insert(out, p)
			end
		end
	end
	return out
end

-- workspace.HeadlessRitual.Altar.YinPlacement.RitualPrompt / YangPlacement.RitualPrompt
function LH.GetPlacementPrompt(half)
	local root = workspace:FindFirstChild("HeadlessRitual")
	local altar = root and root:FindFirstChild("Altar")
	local placement = altar and altar:FindFirstChild(half .. "Placement")
	return placement and placement:FindFirstChild("RitualPrompt")
end

-- mode "place"  = ilagay ang hawak na piece (Yin/Yang)
-- mode "finish" = kumpleto na, buksan ang cave
function LH.DepositAtCave(mode)
	mode = mode or "place"
	LH.RitualBusyCave = true

	if not LH.RitualTP(LH.YinYangCave) then
		LH.RitualBusyCave = false
		return false
	end

	-- bigyan ng oras ang laro para i-update ang RitualSuppressed pagkatapos ng TP
	task.wait(LH.RitualCaveGrace)

	local started = os.clock()
	local lastAction = os.clock()
	local nextFire = setmetatable({}, { __mode = "k" }) -- [prompt] = oras kung kailan pwede ulit i-fire
	local tries = setmetatable({}, { __mode = "k" })    -- [prompt] = ilang beses na na-fire
	local firedAny = false

	-- nakita nating nawala ang hawak = nailagay (backup kung walang StartedAt)
	local startedHolding = {}
	for _, half in ipairs(LH.RitualHalves) do
		startedHolding[half] = LH.RitualCarryingNow(half) and LH.IsHoldingHalf(half)
	end

	while os.clock() - started < LH.RitualDepositTime do
		if not LH.RitualCanRun() then break end

		local char = GetCharacter()
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then break end

		-- kung may nag-alis sa atin sa cave, bumalik
		if (hrp.Position - LH.YinYangCave.Position).Magnitude > 25 then
			LH.RitualLog("displaced from cave, re-TP")
			if not LH.RitualTP(LH.YinYangCave) then break end
			task.wait(LH.RitualCaveGrace)
			lastAction = os.clock()
		end

		local now = os.clock()
		local didFire = false

		for _, p in ipairs(LH.CollectionService:GetTagged("HalloweenRitualPrompt")) do
			if p:IsA("ProximityPrompt") and p:IsDescendantOf(workspace) then
				local suppressed = p:GetAttribute("RitualSuppressed")

				-- na-suppress = tapos na ang phase na ito; i-reset ang tries
				if suppressed == true then
					tries[p] = 0
				end

				if p.Enabled and suppressed == false
						and now >= (nextFire[p] or 0)
						and (tries[p] or 0) < LH.RitualMaxTries then
					LH.RitualLog("fire prompt", p:GetFullName(), "try", (tries[p] or 0) + 1)
					LH.FireRitualPrompt(p)
					nextFire[p] = now + LH.RitualRetryDelay
					tries[p] = (tries[p] or 0) + 1
					firedAny, didFire = true, true
					lastAction = now
					task.wait(0.15)
				end
			end
		end

		-- na-detect ba na nailagay na?
		for _, half in ipairs(LH.RitualHalves) do
			if startedHolding[half] and not LH.IsHoldingHalf(half) then
				startedHolding[half] = false
				LH.RitualPlaced[half] = true
				LH.RitualLog("placed (hold released)", half)
			end
		end

		if mode == "place" then
			-- tapos na kapag wala nang hawak na hindi pa nailalagay
			if firedAny and not LH.RitualAnyCarrying() then
				task.wait(0.5)
				break
			end
		else
			-- finish: tapos na kapag bukas na ang cave
			local phase = LH.RitualPhase()
			if phase ~= nil and phase ~= "Pending" then
				task.wait(0.5)
				break
			end
		end

		-- tapos na kapag wala nang na-fire sa loob ng RitualIdleLimit
		if not didFire and now - lastAction > LH.RitualIdleLimit then
			break
		end
		task.wait(0.2)
	end

	LH.RitualBusyCave = false
	return firedAny
end

--==================================================
-- CYCLE
--==================================================
function LH.RitualCycle()
	LH.RitualSync()

	-- 1) kunin ang Yin / Yang piece na naka-spawn sa mapa
	for _, half in ipairs(LH.RitualHalves) do
		while not LH.RitualIsPlaced(half) and not LH.RitualCarrying[half]
				and not LH.RitualBlocked(half) and LH.GetRitualPiece(half) do
			if not LH.RitualCanRun() then return end
			if not LH.PickupRitualPiece(half) then break end -- bigo = naka-backoff na ang half, lilipat sa susunod
		end
		if not LH.RitualCanRun() then return end
	end

	-- 2) may hawak na piece na hindi pa nailalagay -> TP sa cave at ilagay
	if LH.RitualAnyCarrying() and os.clock() >= (LH.RitualIdleUntil or 0) then
		local pending = {}
		for _, half in ipairs(LH.RitualHalves) do
			if LH.RitualCarryingNow(half) then table.insert(pending, half) end
		end

		LH.DepositAtCave("place")

		for _, half in ipairs(pending) do
			if LH.RitualCarryingNow(half) then
				-- hindi pa rin nailalagay (hintayin sandali ang server)
				local t0 = os.clock()
				while os.clock() - t0 < 1.5 and not LH.RitualIsPlaced(half) do task.wait(0.1) end
			end

			if LH.RitualIsPlaced(half) then
				LH.RitualDepositFails[half] = 0
				LH.RitualUnblock(half)
			elseif LH.RitualCarryingNow(half) then
				LH.RitualDepositFails[half] = (LH.RitualDepositFails[half] or 0) + 1
				LH.RitualLog("deposit failed", half, LH.RitualDepositFails[half])
				if LH.RitualDepositFails[half] >= LH.RitualMaxDepositFails then
					LH.RitualDepositFails[half] = 0
					if LH.IsHoldingHalf(half) then
						-- talagang hawak natin pero ayaw ilagay -> backoff 20/30/40/50s (walang infinite TP)
						LH.RitualBlockHalf(half, "deposit")
					else
						-- hindi pala natin hawak; hahanapin ulit sa mapa
						LH.RitualCarrying[half] = nil
					end
				end
				LH.RitualIdleUntil = os.clock() + LH.RitualRestTime
			end
		end
		if not LH.RitualCanRun() then return end
	end

	-- 3) KUMPLETO na (Yin + Yang nailagay) at hindi pa bukas -> TP at buksan ang cave
	if LH.RitualNeedsFinish() then
		LH.RitualLog("complete -> opening cave")
		LH.DepositAtCave("finish")
		LH.RitualFinishUntil = os.clock() + LH.RitualFinishRest
		if LH.RitualPhase() == nil then
			-- walang RitualView; i-reset ang local state para hindi umulit
			LH.RitualPlaced = {}
			LH.RitualCarrying = {}
		end
	end
end

task.spawn(function()
	while LH.Alive do
		if not LH.AutoRitual or LH.HallPaused() then
			LH.RitualLock = false
			LH.RitualBusyCave = false
			task.wait(0.3)
			continue
		end

		-- Auto Buy Halloween Egg ang mas mataas na priority
		if LH.BuyActive() then
			LH.RitualLock = false
			task.wait(0.2)
			continue
		end

		-- hintayin munang makauwi sa Candy Home ang hawak na candy bago mag-TP sa Yin/Yang
		if LH.CandyDelivering() then
			LH.RitualLock = false
			task.wait(0.1)
			continue
		end

		if LH.RitualHasWorkNow() then
			-- i-lock agad para huminto ang Candy at Knock, tapos hintayin silang tumigil
			LH.RitualLock = true
			LH.RitualWaitYield()
			LH.BgRun(LH.RitualCycle)
			LH.RitualLock = false
			LH.RitualBusyCave = false
		end

		task.wait(0.3)
	end
end)

--AUTO CLAIM OFFLINE
task.spawn(function()
	pcall(function()
		local OfflineEarnings = Svc.ReplicatedStorage:FindFirstChild("Remotes")
			and Svc.ReplicatedStorage.Remotes:FindFirstChild("Game")
			and Svc.ReplicatedStorage.Remotes.Game:FindFirstChild("OfflineEarnings")

		if OfflineEarnings then
			OfflineEarnings:FireServer()
			task.wait(0.3)

			local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
			if PlayerGui then
				for _, gui in ipairs(PlayerGui:GetChildren()) do
					if gui:IsA("ScreenGui") then
						local guiName = string.lower(gui.Name)
						if string.find(guiName, "offline") or string.find(guiName, "away") or string.find(guiName, "reward") then
							gui.Enabled = false
						end

						for _, desc in ipairs(gui:GetDescendants()) do
							if desc:IsA("TextLabel") or desc:IsA("TextButton") then
								local text = string.lower(desc.Text)
								if string.find(text, "while you're away") or string.find(text, "your pets made you") then
									local targetFrame = desc:FindFirstAncestorOfClass("Frame") or desc:FindFirstAncestorOfClass("ScreenGui")
									if targetFrame then
										if targetFrame:IsA("ScreenGui") then
											targetFrame.Enabled = false
										else
											targetFrame.Visible = false
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end)

--// CONSTANTS
local VOLCANO_1_CFRAME = CFrame.new(
	-4917.03369, 41286.2031, -3704.17529, -0.76919955, 5.31099609e-08, 0.639008641, 1.79985058e-08, 1, -6.14475582e-08, -0.639008641, -3.57642307e-08, -0.76919955
)

local VOLCANO_2_CFRAME = CFrame.new(
	-4974.02295, 41275.0195, -3647.97583,
	-0.736429989, 5.97274452e-09, 0.676513731,
	3.34177592e-08, 1, 2.75487313e-08,
	-0.676513731, 4.28952873e-08, -0.736429989
)

local LAVA_CFRAME = CFrame.new(
	-5078.99951, 41557.7578, -3470.83325,
	-0.957514703, -8.63799983e-08, 0.288384527,
	0.000290492084, 0.999999464, 0.000964811828,
	-0.288384378, 0.00100759498, -0.957514226
)

--// WAIT UNTIL EGG BASKET HAS CONTENT
local function WaitForEggBasket(timeout)
	local Basket = LocalPlayer:FindFirstChild("Basket")

	if not Basket then
		return nil
	end

	local start = os.clock()
	timeout = timeout or 3

	while os.clock() - start < timeout do
		local children = Basket:GetChildren()

		if #children > 0 then
			return children[1]
		end

		task.wait(0.1)
	end

	return nil
end

--// PICKUP EGG + WAIT FOR BASKET CONFIRMATION
local function PickupAndConfirm(Egg)
	for i = 1, 2 do
		PickupEgg(Egg)
		task.wait(0.15)--delay
	end

	return WaitForEggBasket(0.5)--delay
end

local function VolcanoDip(hrp)
	if not AutoVolcanoDip then
		return nil
	end

	hrp.CFrame = LAVA_CFRAME
	task.wait(0.4)     

	pcall(function()
		if Rem.VolcanoDipRemote then
        	task.wait(0.3)
			Rem.VolcanoDipRemote:FireServer()
		end
	end)

	task.wait(10)
end


--// FINISH EGG
local function FinishEgg(eggName, hrp, basketEgg, eggPos)
    if not LH.Alive or not AutoPickup then
        return
    end

    -- VOLCANO DIP: panatilihin ang existing behavior
    if AutoVolcanoDip then
        VolcanoDip(hrp)

        local Basket = LocalPlayer:FindFirstChild("Basket")
        local current = Basket and Basket:GetChildren()[1]

        if current then
            basketEgg = current
        end
    end

    -- walang break timer: pagkakuha ng egg, tween agad papuntang plot
    LH.TweenToMyPlot()

    -- nakasakay pa rin sa pet; bababa lang kapag na-OFF ang toggle

    SendWebhookNotification(eggName, basketEgg)

    task.wait(0.2)
end


--// AUTO FARM LOOP
task.spawn(function()
	while LH.Alive do
		if not AutoPickup then
			LH.FarmBusy = false
			LH.FarmFails = 0
			-- na-OFF ang Auto Farm (at Auto Candy): bumaba na sa pet
			if LH.RodeByScript and not LH.AutoCandy then
				LH.BgRun(LH.DismountPet)
			end
			task.wait(0.2)
			continue
		end

		local Egg = FindSelectedEgg()

		if not Egg then
			LH.FarmBusy = false
			LH.FarmFails = 0
			LH.FarmWantUntil = 0
			task.wait(0.2)
			continue
		end

		if not LH.FarmBusy then
			-- FIX: egg pa rin ang priority, pero patapusin muna ang candy loop (kuha + tween sa Candy Home)
			-- para hindi mag-agawan ang tween at TP papuntang Volcano / ibang dimension
			LH.FarmWantUntil = os.clock() + 3
			local waitStart = os.clock()
			while LH.Alive and AutoPickup and LH.CandyActing and os.clock() - waitStart < 15 do
				LH.FarmWantUntil = os.clock() + 3
				task.wait(0.05)
			end
			if not (LH.Alive and AutoPickup) then
				LH.FarmWantUntil = 0
				continue
			end
			-- tapos na ang candy cycle (o walang ginagawa): puwede nang mag-farm
			Egg = FindSelectedEgg()
			if not Egg then
				LH.FarmWantUntil = 0
				task.wait(0.2)
				continue
			end

			LH.FarmBusy = true

			pcall(function()
				if LocalPlayer:GetAttribute("IsRiding") ~= true then
					local c = GetCharacter()
					local h = c and c:FindFirstChildOfClass("Humanoid")
					if h then h:UnequipTools() end
				end
			end)

			Egg = FindSelectedEgg()
			if not Egg then
				LH.FarmBusy = false
				task.wait(0.2)
				continue
			end
		end

		local eggName = Egg.Name
		local char = GetCharacter()
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if not hrp then
			task.wait(0.1)
			continue
		end

		-- may egg na na-detect: i-check kung nakasakay na; kung hindi pa, sakyan ang best pet
		if not LH.IsRiding() then
			LH.RidePet()
			char = GetCharacter()
			hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				task.wait(0.1)
				continue
			end
		end

		-- i-save ang posisyon ng egg bago kunin (mawawala na ito sa RenderedEggs pagkakuha)
		local eggPart0 = GetEggPart(Egg)
		local eggPos = eggPart0 and eggPart0.Position

		--==================================================
		-- VOLCANIC EGG
		--==================================================
		if eggName == "Volcanic Egg" then
			hrp.CFrame = VOLCANO_1_CFRAME
			task.wait(0.1)

			TweenToCFrame(VOLCANO_2_CFRAME)
			task.wait(0.5)

			local eggPart = GetEggPart(Egg)

			if eggPart then
				hrp.CFrame = LH.UprightCFrame(eggPart.Position + Vector3.new(0, 3, 0))
				LH.Stabilize()
				task.wait(0.3)

				-- sakay sa pet bago kunin ang egg
				LH.RidePet()

				-- Pickup + GET ACTUAL BASKET EGG
				local basketEgg = PickupAndConfirm(Egg)

				if basketEgg then
					task.wait(0.2)

					hrp.CFrame = VOLCANO_2_CFRAME
					task.wait(0.2)

					TweenToCFrame(VOLCANO_1_CFRAME)
					task.wait(0.5)

					FinishEgg(eggName, hrp, basketEgg, eggPos)
				end
			else
				task.wait(0.1)
			end

			--==================================================
			-- NORMAL EGG
			--==================================================
		else
			if TeleportToEgg(Egg) then
				task.wait(1)

				-- sakay sa pet bago kunin ang egg
				LH.RidePet()

				-- Pickup + GET ACTUAL BASKET EGG
				local basketEgg = PickupAndConfirm(Egg)

				if basketEgg then
					task.wait(0.1)

					FinishEgg(eggName, hrp, basketEgg, eggPos)
				end
			else
				task.wait(0.2)
			end
		end

		task.wait(0.5)
	end
end)



LH.NoFallStates = {
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.PlatformStanding,
}

Bind(Svc.RunService.Heartbeat, function()
	if not AutoPickup then return end
	if LocalPlayer:GetAttribute("IsRiding") == true then return end

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp or hum.Health <= 0 then return end

	if LH.LastHum ~= hum then
		LH.LastHum = hum
		for _, st in ipairs(LH.NoFallStates) do
			pcall(function() hum:SetStateEnabled(st, false) end)
		end
	end

	local st = hum:GetState()
	if st == Enum.HumanoidStateType.FallingDown
				or st == Enum.HumanoidStateType.Ragdoll
				or st == Enum.HumanoidStateType.PlatformStanding then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if hrp.CFrame.UpVector.Y < 0.9 then
		hrp.AssemblyAngularVelocity = Vector3.zero
		hrp.CFrame = LH.UprightCFrame(hrp.Position)
	end
end)

local function OpenHomeTab()
	local ok = pcall(function() Tabs.Tab1:Select() end)
	if not ok then
		pcall(function() Window:SelectTab(1) end)
	end
end

OpenHomeTab()
task.spawn(function()
	task.wait(0.5)
	if LH.Alive then OpenHomeTab() end
end)


--==================================================
-- FULL CLEANUP + WINDOW CLOSE HOOKS
--==================================================
local function FullCleanup()
	if not LH.Alive then return end
	LH.Alive = false -- humihinto lahat ng while LH.Alive loops
	if LH.RodeByScript then task.spawn(LH.DismountPet) end
	LH.FarmBusy = false
	LH.FuseLockN, LH.BuyActing = 0, false

	AutoPickup, AutoVolcanoDip, AutoPlaceEgg, AutoHatchEgg = false, false, false, false
	AutoHatchSelectedEggs, AutoClaimIndex = false, false
	LH.AutoCandy = false
	LH.AutoKnock, LH.AutoHaEgg = false, false
	AutoUpgradeHatchLuck, AutoUpgradeHatchLuckMax, AutoRebirth = false, false, false
	Autobuygear, Autobuyfood, AutoEquipBestPet = false, false, false
	AutoSellPet, AutoSellAllPets, AutoFavoritePet = false, false, false
	AutoFuse, AutoClaimFusedPets, WebhookEnabled, ESPEnabled = false, false, false, false

	if FPSBoost then FPSBoost = false; pcall(ApplyFPSBoost, false) end
	if HideEggs then HideEggs = false; pcall(ToggleHideEggs, false) end
	pcall(ClearAllESP)
	pcall(LH.StopMovement) -- noclip + infinite jump

	for _, c in ipairs(LH.Conns) do pcall(function() c:Disconnect() end) end
	table.clear(LH.Conns)

	pcall(function() FloatingGui:Destroy() end)
	pcall(function() platform:Destroy() end)
	pcall(function() Window:Destroy() end)

	pcall(function() getgenv().LunaHubCleanup = nil end)
end

pcall(function() getgenv().LunaHubCleanup = FullCleanup end)

pcall(function() if Window.OnDestroy then Window:OnDestroy(FullCleanup) end end)

task.spawn(function()
	task.wait(2)
	while LH.Alive do
		local gone = false
		pcall(function()
			if Window.Destroyed == true then gone = true end
		end)
		if gone then FullCleanup() break end
		task.wait(0.5)
	end
end)
