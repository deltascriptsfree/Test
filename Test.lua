-- Murder Mystery 2 GUI (Optimized and Fixed for Delta)
-- Fully compatible with mobile executors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables for features
local noclipEnabled = false
local aimbotEnabled = false
local autoEquipGun = false

-- Create GUI safely
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "MM2ModMenu"
ScreenGui.ResetOnSpawn = false

-- Safe parent selection for mobile executors
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "MM2 MOD MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Helper function to create clean toggles
local function createToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = MainFrame
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(0, 200, 0, 36)
    Button.Font = Enum.Font.Gotham
    Button.Text = name .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Button.TextSize = 13

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(0, 150, 75)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = name .. ": ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            Button.Text = name .. ": OFF"
        end
        pcall(function()
            callback(state)
        end)
    end)
end

-- 1. Noclip Implementation
createToggle("Noclip", function(state)
    noclipEnabled = state
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 2. Aimbot Implementation (Tracking role tools)
createToggle("Aimbot", function(state)
    aimbotEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = nil
        local shortestDistance = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool and (tool.Name == "Knife" or tool.Name == "Gun") then
                        local screenPoint, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                        if onScreen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                target = hrp
                            end
                        end
                    end
                end
            end
        end

        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- 3. Auto Gun Pickup Implementation
createToggle("Auto Gun Pickup", function(state)
    autoEquipGun = state
end)

RunService.Heartbeat:Connect(function()
    if autoEquipGun and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    if (obj.Position - hrp.Position).Magnitude < 25 then
                        pcall(function()
                            if firetouchinterest then
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            else
                                obj.CFrame = hrp.CFrame
                            end
                        end)
                    end
                end
            end
        end
    end
end)
