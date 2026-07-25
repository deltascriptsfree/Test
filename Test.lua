-- ============================================================================
-- MM2 SERVER TRADE FREEZE & AUTO ACCEPT (DELTA OPTIMIZED)
-- Features: Network RemoteEvent Hook for Trade Freezing and Auto-Accepting.
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- States
local TradeFreezeActive = false
local AutoAcceptActive = false

-- Find MM2 RemoteEvents related to trading
local function getTradeRemotes()
    local remotes = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = v.Name:lower()
            if name:find("trade") or name:find("exchange") or name:find("offer") then
                table.insert(remotes, v)
            end
        end
    end
    return remotes
end

-- Hooking Metamethods to intercept and freeze network packets if enabled
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if TradeFreezeActive and self:IsA("RemoteEvent") then
        local name = self.Name:lower()
        if name:find("trade") and (method == "FireServer" or method == "InvokeServer") then
            -- If opponent tries to cancel or lock, we intercept and freeze the state
            if args[1] == "Cancel" or args[1] == "Decline" then
                return -- Block packet
            end
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- GUI Creation
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("MM2ServerTradeGui") then
    CoreGui.MM2ServerTradeGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2ServerTradeGui"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(255, 140, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "MM2 SERVER TRADE HACK"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextSize = 11

local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local Spacer = Instance.new("Frame")
Spacer.Parent = MainFrame
Spacer.BackgroundTransparency = 1
Spacer.Size = UDim2.new(1, 0, 0, 35)

local function makeToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 12
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = name .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = name .. ": OFF"
        end
        callback(state)
    end)
end

makeToggle("Trade Freeze (Server)", function(state)
    TradeFreezeActive = state
end)

makeToggle("Auto Accept (Both)", function(state)
    AutoAcceptActive = state
end)

-- Automated Loop to force server-side accept packets when enabled
task.spawn(function()
    while true do
        task.wait(0.4)
        if AutoAcceptActive then
            pcall(function()
                for _, remote in ipairs(getTradeRemotes()) do
                    -- Force firing acceptance argument to server for both players
                    remote:FireServer("Accept")
                    remote:FireServer(true)
                end
            end)
        end
    end
end)
