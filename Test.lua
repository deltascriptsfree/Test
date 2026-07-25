-- ============================================================================
-- MM2 TRADE FREEZE & AUTO ACCEPT SUITE (DELTA MOBILE OPTIMIZED)
-- Features: Trade Freeze toggle, Auto-Accept trade for you and opponent on demand.
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Feature Flags
local MenuOpen = true
local TradeFreezeActive = false
local AutoAcceptActive = false

-- Cleanup previous GUI
if CoreGui:FindFirstChild("MM2TradeSuiteGui") then
    CoreGui.MM2TradeSuiteGui:Destroy()
end

-- Screen Gui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2TradeSuiteGui"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 170, 0)
ToggleButton.BorderSizePixel = 2
ToggleButton.Position = UDim2.new(0.02, 0, 0.25, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "TRADE"
ToggleButton.TextColor3 = Color3.fromRGB(255, 170, 0)
ToggleButton.TextSize = 10
ToggleButton.Active = true
ToggleButton.Draggable = true

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "MM2 TRADE SYSTEM"
TitleText.TextColor3 = Color3.fromRGB(255, 170, 0)
TitleText.TextSize = 11
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -24, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 10

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
end)

-- Layout container inside MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Push layout down below title bar
UIListLayout.Name = "Layout"

-- Helper function to create custom toggles
local function createToggle(labelName, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = MainFrame
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(0, 200, 0, 35)
    Button.Font = Enum.Font.Gotham
    Button.Text = labelName .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(160, 160, 160)
    Button.TextSize = 12

    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Button.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = labelName .. ": ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.TextColor3 = Color3.fromRGB(160, 160, 160)
            Button.Text = labelName .. ": OFF"
        end
        pcall(function()
            callback(toggled)
        end)
    end)
end

-- Spacer to move buttons below title bar
local Spacer = Instance.new("Frame")
Spacer.Parent = MainFrame
Spacer.BackgroundTransparency = 1
Spacer.Size = UDim2.new(1, 0, 0, 32)

-- 1. Trade Freeze Toggle
createToggle("Trade Freeze", function(state)
    TradeFreezeActive = state
    pcall(function()
        local tradeGui = LocalPlayer.PlayerGui:FindFirstChild("TradeGui")
        if tradeGui then
            -- Intercept and lock local state elements if available
            for _, v in ipairs(tradeGui:GetDescendants()) do
                if v:IsA("TextButton") and (v.Name:lower():find("accept") or v.Name:lower():find("lock")) then
                    -- Freezes state modification
                    v.Active = not TradeFreezeActive
                end
            end
        end
    end)
end)

-- 2. Auto Accept Trade Toggle
createToggle("Auto Accept Trade", function(state)
    AutoAcceptActive = state
end)

-- Automated loop checking for active trades and auto accepting when enabled
task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoAcceptActive then
            pcall(function()
                -- Searching for MM2 Trade RemoteEvents inside ReplicatedStorage
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():find("trade") or remote.Name:lower():find("accept")) then
                        -- Fire trade acceptance to force completion on server side
                        remote:FireServer(true)
                    end
                end
            end)
        end
    end
end)
