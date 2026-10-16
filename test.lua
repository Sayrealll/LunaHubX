--// LUNA HUB LIFECYCLE (fresh start / full cleanup)
local LH = { Alive = true, Conns = {} }
local Svc, Mods, Tabs, Secs = {}, {}, {}, {}


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
local ConfigFolder = "LUNA HUB/GAME NAME"
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

-- TOGGLES & INPUTS (state variables lang; wala nang function na gumagamit nito)
LH.MinKG = LH.ParseKG(ConfigData.MinWeightText)
LH.FarmTweenSpeed = tonumber(ConfigData.FarmTweenSpeed) or 100
LH.CandyTweenSpeed = tonumber(ConfigData.CandyTweenSpeed) or 100
local AutoVolcanoDip = ConfigData.AutoVolcanoDip or false
local AutoPickup = ConfigData.AutoPickup or false
local AutoPlaceEgg = ConfigData.AutoPlaceEgg or false
local AutoHatchSelectedEggs = ConfigData.AutoHatchSelectedEggs or false
local AutoHatchEgg = ConfigData.AutoHatchEgg or false
local AutoEquipBestPet = ConfigData.AutoEquipBestPet or false
local AutoUpgradeHatchLuck = ConfigData.AutoUpgradeHatchLuck or false
local AutoUpgradeHatchLuckMax = ConfigData.AutoUpgradeHatchLuckMax or false
local AutoRebirth = ConfigData.AutoRebirth or false
local AutoClaimIndex = ConfigData.AutoClaimIndex or false
LH.AutoCandy = ConfigData.AutoCandy == true
LH.AutoKnock = ConfigData.AutoKnock == true
LH.AutoHaEgg = ConfigData.AutoHaEgg == true
LH.AutoRitual = ConfigData.AutoRitual == true
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

	local eggData = Mods.Eggs_mData and Mods.Eggs_mData[eggName]
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
				local shown = (okK and type(kg) == "number") and kg or raw
				weight = LH.FormatKG and LH.FormatKG(shown) or tostring(shown)
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
	Desc = "No tracker function yet.",
})



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

	AutoPickup, AutoVolcanoDip, AutoPlaceEgg, AutoHatchEgg = false, false, false, false
	AutoHatchSelectedEggs, AutoClaimIndex = false, false
	LH.AutoCandy = false
	LH.AutoKnock, LH.AutoHaEgg, LH.AutoRitual = false, false, false
	AutoUpgradeHatchLuck, AutoUpgradeHatchLuckMax, AutoRebirth = false, false, false
	Autobuygear, Autobuyfood, AutoEquipBestPet = false, false, false
	AutoSellPet, AutoSellAllPets, AutoFavoritePet = false, false, false
	AutoFuse, AutoClaimFusedPets, WebhookEnabled, ESPEnabled = false, false, false, false

	if FPSBoost then FPSBoost = false; pcall(ApplyFPSBoost, false) end
	pcall(LH.StopMovement) -- noclip + infinite jump

	for _, c in ipairs(LH.Conns) do pcall(function() c:Disconnect() end) end
	table.clear(LH.Conns)

	pcall(function() FloatingGui:Destroy() end)
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
