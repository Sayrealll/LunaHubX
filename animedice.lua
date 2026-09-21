
--[[
    LUNA HUB | ANIME DICE v1.0.02

    Features:
    - Draggable GUI
    - Minimize / Restore
    - Auto Claim Daily Reward
    - Auto Roll Dice
    - Auto Collect Money
    - Auto Equip Best
    - Auto Rebirth (Cash check)
    - Auto Claim Offline Reward
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- REMOTES
--==================================================

local Network = ReplicatedStorage:WaitForChild("Network")

local DailyClaim =
    Network.DailyRewardService.RE.Claim

local RollDice =
    Network.RollService.RF.RollDice

local CollectBalance =
    Network.PlotService.RE.CollectBalance

local EquipBest =
    Network.PlotService.RE.EquipBest

local Rebirth =
    Network.RebirthService.RE.Rebirth

local OfflineClaim =
    Network.OfflineEarningsService.RE.Claim


--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunaHubAnimeDice"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")


local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 430, 0, 390)
Main.Position = UDim2.new(0.5, -215, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main


--==================================================
-- TITLE BAR
--==================================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar


local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LUNA HUB | ANIME DICE v1.0.02"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar


--==================================================
-- MINIMIZE BUTTON
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 40, 0, 32)
Minimize.Position = UDim2.new(1, -45, 0, 6)
Minimize.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 22
Minimize.Font = Enum.Font.GothamBold
Minimize.BorderSizePixel = 0
Minimize.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = Minimize


--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 5
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main


local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content


--==================================================
-- TOGGLE SYSTEM
--==================================================

local Toggles = {}

local function CreateToggle(Name, Callback)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, -5, 0, 48)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 43)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Content


    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button


    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = Color3.fromRGB(235, 235, 240)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button


    local State = Instance.new("TextLabel")
    State.Size = UDim2.new(0, 55, 0, 28)
    State.Position = UDim2.new(1, -65, 0.5, -14)
    State.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    State.Text = "OFF"
    State.TextColor3 = Color3.fromRGB(220, 220, 220)
    State.TextSize = 12
    State.Font = Enum.Font.GothamBold
    State.Parent = Button


    local StateCorner = Instance.new("UICorner")
    StateCorner.CornerRadius = UDim.new(0, 7)
    StateCorner.Parent = State


    local Enabled = false

    Toggles[Name] = false


    local function SetState(Value)

        Enabled = Value
        Toggles[Name] = Value

        if Enabled then

            State.Text = "ON"
            State.BackgroundColor3 = Color3.fromRGB(80, 180, 100)

        else

            State.Text = "OFF"
            State.BackgroundColor3 = Color3.fromRGB(65, 65, 75)

        end

        Callback(Enabled)

    end


    Button.MouseButton1Click:Connect(function()

        SetState(not Enabled)

    end)

end


--==================================================
-- AUTO CLAIM DAILY
--==================================================

CreateToggle("AUTO CLAIM DAILY REWARD", function(Enabled)

    if Enabled then

        task.spawn(function()

            pcall(function()
                DailyClaim:FireServer()
            end)

        end)

    end

end)


--==================================================
-- AUTO ROLL DICE
--==================================================

CreateToggle("AUTO ROLL DICE", function(Enabled)

    if Enabled then

        task.spawn(function()

            while Toggles["AUTO ROLL DICE"] do

                pcall(function()
                    RollDice:InvokeServer()
                end)

                task.wait(0.5)

            end

        end)

    end

end)


--==================================================
-- AUTO COLLECT MONEY
--==================================================

CreateToggle("AUTO COLLECT MONEY", function(Enabled)

    if Enabled then

        task.spawn(function()

            while Toggles["AUTO COLLECT MONEY"] do

                for Slot = 1, 10 do

                    if not Toggles["AUTO COLLECT MONEY"] then
                        break
                    end

                    pcall(function()
                        CollectBalance:FireServer(Slot)
                    end)

                    task.wait(0.1)

                end

                task.wait(0.5)

            end

        end)

    end

end)


--==================================================
-- AUTO EQUIP BEST
--==================================================

CreateToggle("AUTO EQUIP BEST", function(Enabled)

    if Enabled then

        task.spawn(function()

            while Toggles["AUTO EQUIP BEST"] do

                pcall(function()
                    EquipBest:FireServer()
                end)

                task.wait(1)

            end

        end)

    end

end)


--==================================================
-- FIND CASH
--==================================================

local function GetCash()

    local Leaderstats = Player:FindFirstChild("leaderstats")

    if Leaderstats then

        local Cash = Leaderstats:FindFirstChild("Cash", true)

        if Cash and (
            Cash:IsA("IntValue")
            or Cash:IsA("NumberValue")
        ) then

            return Cash.Value

        end

    end


    local Cash = Player:FindFirstChild("Cash", true)

    if Cash and (
        Cash:IsA("IntValue")
        or Cash:IsA("NumberValue")
    ) then

        return Cash.Value

    end


    return nil

end


--==================================================
-- FIND REBIRTH COST
--==================================================

local RebirthCostNames = {
    "RebirthCost",
    "RebirthPrice",
    "RebirthRequirement",
    "RequiredMoney",
    "RequiredCash",
    "RequiredCoins",
    "Cost",
    "Price"
}


local function GetRebirthCost()

    local Containers = {
        Player,
        Player:FindFirstChild("leaderstats"),
        Player:FindFirstChild("Data"),
        Player:FindFirstChild("Stats")
    }


    for _, Container in ipairs(Containers) do

        if Container then

            for _, Name in ipairs(RebirthCostNames) do

                local Value = Container:FindFirstChild(Name, true)

                if Value and (
                    Value:IsA("IntValue")
                    or Value:IsA("NumberValue")
                ) then

                    return Value.Value

                end

            end

        end

    end


    return nil

end


--==================================================
-- AUTO REBIRTH
--==================================================

CreateToggle("AUTO REBIRTH", function(Enabled)

    if Enabled then

        task.spawn(function()

            while Toggles["AUTO REBIRTH"] do

                local Cash = GetCash()
                local RebirthCost = GetRebirthCost()

                -- DO NOT FIRE if the values cannot be detected.
                if Cash ~= nil and RebirthCost ~= nil then

                    -- Only rebirth when Cash is enough.
                    if Cash >= RebirthCost then

                        pcall(function()
                            Rebirth:FireServer()
                        end)

                    end

                end

                -- Keep checking until enough Cash.
                task.wait(1)

            end

        end)

    end

end)


--==================================================
-- AUTO CLAIM OFFLINE REWARD
--==================================================

CreateToggle("AUTO CLAIM OFFLINE REWARD", function(Enabled)

    if Enabled then

        task.spawn(function()

            while Toggles["AUTO CLAIM OFFLINE REWARD"] do

                pcall(function()
                    OfflineClaim:FireServer()
                end)

                task.wait(2)

            end

        end)

    end

end)


--==================================================
-- DRAGGING
--==================================================

local Dragging = false
local DragStart
local StartPosition


TitleBar.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true

        DragStart = Input.Position
        StartPosition = Main.Position


        Input.Changed:Connect(function()

            if Input.UserInputState == Enum.UserInputState.End then

                Dragging = false

            end

        end)

    end

end)


UserInputService.InputChanged:Connect(function(Input)

    if Dragging and (
        Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch
    ) then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

    end

end)


--==================================================
-- MINIMIZE / RESTORE
--==================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

    Minimized = not Minimized

    if Minimized then

        Content.Visible = false

        Main.Size = UDim2.new(
            0,
            430,
            0,
            45
        )

        Minimize.Text = "+"

    else

        Content.Visible = true

        Main.Size = UDim2.new(
            0,
            430,
            0,
            390
        )

        Minimize.Text = "-"

    end

end)
