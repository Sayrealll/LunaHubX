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
	Title = "v1.0.1",
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
	Title = "FUSE",
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

do
	local InviteCode = "ftgs-development-hub-1300692552005189632"
	local DiscordAPI = "https://discord.gg/Ev8k5RAU3" .. InviteCode .. "?with_counts=true&with_expiration=true"

	local Response = WindUI.cloneref(game:GetService("HttpService"))
		:JSONDecode(WindUI.Creator.Request and WindUI.Creator.Request({
			Url = DiscordAPI,
			Method = "GET",
			Headers = {
				["User-Agent"] = "WindUI/Example",
				["Accept"] = "application/json",
			},
		}).Body or "{}")

	local Tabdc = OtherSection:Tab({
		Title = "Discord",
		Border = true,
	})

	if Response and Response.guild then
		Tabdc:Section({
			Title = "Join our Discord server!",
			TextSize = 20,
		})
		local DiscordServerParagraph = Tabdc:Paragraph({
			Title = tostring(Response.guild.name),
			Desc = tostring(Response.guild.description),
			Image = "https://cdn.discordapp.com/icons/"
				.. Response.guild.id
				.. "/"
				.. Response.guild.icon
				.. ".png?size=1024",
			Thumbnail = "https://cdn.discordapp.com/banners/1300692552005189632/35981388401406a4b7dffd6f447a64c4.png?size=512",
			ImageSize = 48,
			Buttons = {
				{
					Title = "Copy link",
					Icon = "link",
					Callback = function()
						setclipboard("https://discord.gg/" .. InviteCode)
					end,
				},
			},
		})
	elseif RunService:IsStudio() or not writefile then
		DiscordTab:Paragraph({
			Title = "Discord API is not available in Studio mode.",
			TextSize = 20,
			Justify = "Center",
			Image = "solar:info-circle-bold",
			Color = "Red",
			Buttons = {
				{
					Title = "Get/Copy Invite Link",
					Icon = "link",
					Callback = function()
						if setclipboard then
							setclipboard("https://discord.gg/" .. InviteCode)
						else
							WindUI:Notify({
								Title = "Discord Invite Link",
								Content = "https://discord.gg/" .. InviteCode,
							})
						end
					end,
				},
			},do
	local InviteCode = "ftgs-development-hub-1300692552005189632"
	local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

	local Response = WindUI.cloneref(game:GetService("HttpService"))
		:JSONDecode(WindUI.Creator.Request and WindUI.Creator.Request({
			Url = DiscordAPI,
			Method = "GET",
			Headers = {
				["User-Agent"] = "WindUI/Example",
				["Accept"] = "application/json",
			},
		}).Body or "{}")

	local Tabdc = OtherSection:Tab({
		Title = "Discord",
		Border = true,
	})

	if Response and Response.guild then
		Tabdc:Section({
			Title = "Join our Discord server!",
			TextSize = 20,
		})
		local DiscordServerParagraph = Tabdc:Paragraph({
			Title = tostring(Response.guild.name),
			Desc = tostring(Response.guild.description),
			Image = "https://cdn.discordapp.com/icons/"
				.. Response.guild.id
				.. "/"
				.. Response.guild.icon
				.. ".png?size=1024",
			Thumbnail = "https://cdn.discordapp.com/banners/1300692552005189632/35981388401406a4b7dffd6f447a64c4.png?size=512",
			ImageSize = 48,
			Buttons = {
				{
					Title = "Copy link",
					Icon = "link",
					Callback = function()
						setclipboard("https://discord.gg/" .. InviteCode)
					end,
				},
			},
		})
	elseif RunService:IsStudio() or not writefile then
		Tabdc:Paragraph({
			Title = "Discord API is not available in Studio mode.",
			TextSize = 20,
			Justify = "Center",
			Image = "solar:info-circle-bold",
			Color = "Red",
			Buttons = {
				{
					Title = "Get/Copy Invite Link",
					Icon = "link",
					Callback = function()
						if setclipboard then
							setclipboard("https://discord.gg/" .. InviteCode)
						else
							WindUI:Notify({
								Title = "Discord Invite Link",
								Content = "https://discord.gg/" .. InviteCode,
							})
						end
					end,
				},
			},
		})
	else
		Tabdc:Paragraph({
			Title = "Failed to fetch Discord server info.",
			TextSize = 20,
			Justify = "Center",
			Image = "solar:info-circle-bold",
			Color = "Red",
		})
	end
end

				


local Section = Tab1:Section({
	Title = "Auto Steal",
	Box = true,
	BoxBorder = true,
})

Section:Toggle({
	Title = "Auto Steal Egg",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})


local Section1 = Tab1:Section({
	Title = "Auto Steal Filter",
	Box = true,
	BoxBorder = true,
})

Section1:Dropdown({
	Title = "Rarities",
	Values = {
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
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})

local Section3 = Tab1:Section({
	Title = "Auto Sell Egg",
	Box = true,
	BoxBorder = true,
})

Section3:Toggle({
	Title = "Auto Sell Eggs",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
})
Section3:Dropdown({
	Title = "Rarities",
	Values = {
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

local Section4 = Tab2:Section({
	Title = "Upgrades",
	Box = true,
	BoxBorder = true,
})

Section4:Toggle({
	Title = "Auto Upgrade Pen",
	Desc = "",
	Value = false,
	Callback = function(state)
		print("Toggle state:", state)
	end,
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



--[[local EmptyTab = Window:Tab({
	Title = "Custom empty page tab",

	CustomEmptyPage = {
		Icon = "lucide:smile",
		Title = "This is a cool empty tab",
		Desc = "I like it. its so great tab with cool 'custom empty page'",
	},
})]]
