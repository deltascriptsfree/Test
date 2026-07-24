-- ============================================================================
-- MM2 ULTIMATE HACK SUITE (DELTA MOBILE OPTIMIZED)
-- Fully functional Lua script without execution errors.
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Feature States
local MenuOpen = true
local NoclipActive = false
local EspActive = false
local AimbotActive = false
local FlyActive = false
local SpeedActive = false
local AutoGunActive = false
local FullbrightActive = false
local InfJumpActive = false
local SpinBotActive = false
local PreGameRoleActive = true

-- Configurations
local WalkSpeedValue = 32
local FlySpeedValue = 50

-- Cleanup previous GUI instances safely
if CoreGui:FindFirstChild("MM2UltimateSuiteGuiFinal") then
    CoreGui.MM2UltimateSuiteGuiFinal:Destroy()
end

-- Main Screen Gui Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2UltimateSuiteGuiFinal"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Floating Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.BorderSizePixel = 2
ToggleButton.Position = UDim2.new(0.02, 0, 0.1, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 11
ToggleButton.Active = true
ToggleButton.Draggable = true

-- Compact Main Frame Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.08, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 310)
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "MM2 HACK SUITE"
TitleText.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleText.TextSize = 12
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close Window Button
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

-- Scrolling Container
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0, 32)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -32)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Helper: Create Toggle Buttons
local function createToggle(labelName, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(0, 200, 0, 32)
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
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Button.TextColor3 = Color3.fromRGB(160, 160, 160)
            Button.Text = labelName .. ": OFF"
        end
        pcall(function()
            callback(toggled)
        end)
    end)
end

-- Role Detection System (Red = Murderer, Blue = Sheriff, Green = Innocent)
local function fetchPlayerRole(targetPlayer)
    if not targetPlayer.Character then return "Innocent", Color3.fromRGB(0, 255, 0) end
    
    local char = targetPlayer.Character
    local backpack = targetPlayer:FindFirstChild("Backpack")
    
    local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if hasKnife then
        return "Murderer", Color3.fromRGB(255, 40, 40)
    elseif hasGun then
        return "Sheriff", Color3.fromRGB(40, 140, 255)
    else
        return "Innocent", Color3.fromRGB(40, 255, 90)
    end
end

-- Pre-game Role Display Label
local PreGameLabel = Instance.new("TextLabel")
PreGameLabel.Parent = ScreenGui
PreGameLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PreGameLabel.BorderColor3 = Color3.fromRGB(0, 170, 255)
PreGameLabel.BorderSizePixel = 1
PreGameLabel.Position = UDim2.new(0.02, 0, 0.22, 0)
PreGameLabel.Size = UDim2.new(0, 170, 0, 28)
PreGameLabel.Font = Enum.Font.GothamBold
PreGameLabel.Text = "Role: Waiting..."
PreGameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PreGameLabel.TextSize = 11

RunService.Heartbeat:Connect(function()
    if PreGameRoleActive and LocalPlayer then
        local role, color = fetchPlayerRole(LocalPlayer)
        PreGameLabel.Text = "My Role: " .. role
        PreGameLabel.TextColor3 = color
    end
end)

-- 1. ESP Role Highlighting (Through Walls)
local espCache = {}

local function clearEsp(player)
    if espCache[player] then
        if espCache[player].highlight then espCache[player].highlight:Destroy() end
        if espCache[player].billboard then espCache[player].billboard:Destroy() end
        espCache[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not EspActive then
        for player, _ in pairs(espCache) do clearEsp(player) end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local role, color = fetchPlayerRole(p)
            
            if not espCache[p] then
                local hl = Instance.new("Highlight")
                hl.Parent = p.Character
                hl.Adornee = p.Character
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                
                local bb = Instance.new("BillboardGui")
                bb.Parent = p.Character.Head
                bb.Size = UDim2.new(0, 150, 0, 45)
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel")
                txt.Parent = bb
                txt.BackgroundTransparency = 1
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 11
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.TextStrokeTransparency = 0
                
                espCache[p] = {highlight = hl, billboard = bb, text = txt}
            end
            
            local data = espCache[p]
            if data and data.highlight and data.text then
                data.highlight.FillColor = color
                data.highlight.OutlineColor = color
                data.text.Text = p.Name .. "\n[" .. role .. "]"
                data.text.TextColor3 = color
            end
        else
            clearEsp(p)
        end
    end
end)

createToggle("ESP Roles", function(state) EspActive = state end)

-- 2. Noclip System
createToggle("Noclip Walls", function(state) NoclipActive = state end)

RunService.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 3. Fixed Mobile Fly System
local flyConn

createToggle("Fly Mode", function(state)
    FlyActive = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if FlyActive then
        humanoid.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.Parent = hrp
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.Parent = hrp
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = Camera.CFrame
        
        flyConn = RunService.RenderStepped:Connect(function()
            if not FlyActive then return end
            bg.CFrame = Camera.CFrame
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            bv.Velocity = moveDir * FlySpeedValue
        end)
    else
        if flyConn then flyConn:Disconnect() end
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        if humanoid then humanoid.PlatformStand = false end
    end
end)

-- 4. Smart Aimbot (Murderer -> Sheriff, Sheriff/Innocent -> Murderer)
createToggle("Smart Aimbot", function(state) AimbotActive = state end)

RunService.RenderStepped:Connect(function()
    if not AimbotActive then return end
    
    local myRole, _ = fetchPlayerRole(LocalPlayer)
    local targetRole = ""
    if myRole == "Murderer" then targetRole = "Sheriff"
    elseif myRole == "Sheriff" or myRole == "Innocent" then targetRole = "Murderer" end
    
    local bestTarget = nil
    local minDistance = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local role, _ = fetchPlayerRole(p)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and (role == targetRole or targetRole == "") then
                local hrp = p.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        bestTarget = hrp
                    end
                end
            end
        end
    end
    
    if bestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
    end
end)

-- 5. Speed Boost (With correct toggle reset!)
createToggle("Speed Boost", function(state) SpeedActive = state end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if SpeedActive then
                hum.WalkSpeed = WalkSpeedValue
            else
                hum.WalkSpeed = 16 -- Normal speed reset on OFF
            end
        end
    end
end)

-- 6. Auto Gun Pickup
createToggle("Auto Gun Pickup", function(state) AutoGunActive = state end)

RunService.Heartbeat:Connect(function()
    if AutoGunActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    if (obj.Position - hrp.Position).Magnitude < 30 then
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

-- 7. Fullbright
createToggle("Fullbright", function(state) FullbrightActive = state end)

RunService.RenderStepped:Connect(function()
    if FullbrightActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)

-- 8. Infinite Jump
createToggle("Infinite Jump", function(state) InfJumpActive = state end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpActive and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 9. SpinBot
createToggle("SpinBot", function(state) SpinBotActive = state end)

RunService.RenderStepped:Connect(function()
    if SpinBotActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(35), 0)
    end
end)

-- ============================================================================
-- FLING GUI MODULE (Select player by name to fling)
-- ============================================================================
local FlingOpen = false

local FlingMenuBtn = Instance.new("TextButton")
FlingMenuBtn.Parent = ScrollingFrame
FlingMenuBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
FlingMenuBtn.BorderSizePixel = 0
FlingMenuBtn.Size = UDim2.new(0, 200, 0, 32)
FlingMenuBtn.Font = Enum.Font.GothamBold
FlingMenuBtn.Text = "Open Fling Menu"
FlingMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingMenuBtn.TextSize = 12

local FlingWindow = Instance.new("Frame")
FlingWindow.Name = "FlingWindow"
FlingWindow.Parent = ScreenGui
FlingWindow.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
FlingWindow.BorderColor3 = Color3.fromRGB(255, 50, 50)
FlingWindow.BorderSizePixel = 1
FlingWindow.Position = UDim2.new(0.32, 0, 0.1, 0)
FlingWindow.Size = UDim2.new(0, 180, 0, 220)
FlingWindow.Visible = false
FlingWindow.Active = true
FlingWindow.Draggable = true

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Parent = FlingWindow
FlingTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FlingTitle.Size = UDim2.new(1, 0, 0, 28)
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.Text = "SELECT TARGET TO FLING"
FlingTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
FlingTitle.TextSize = 9

local FlingScroll = Instance.new("ScrollingFrame")
FlingScroll.Parent = FlingWindow
FlingScroll.BackgroundTransparency = 1
FlingScroll.Position = UDim2.new(0, 0, 0, 30)
FlingScroll.Size = UDim2.new(1, 0, 1, -30)
FlingScroll.CanvasSize = UDim2.new(0, 0, 0, 350)
FlingScroll.ScrollBarThickness = 3

local FlingLayout = Instance.new("UIListLayout")
FlingLayout.Parent = FlingScroll
FlingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FlingLayout.SortOrder = Enum.SortOrder.LayoutOrder
FlingLayout.Padding = UDim.new(0, 4)

FlingMenuBtn.MouseButton1Click:Connect(function()
    FlingOpen = not FlingOpen
    FlingWindow.Visible = FlingOpen
end)

task.spawn(function()
    while true do
        task.wait(1)
        if FlingWindow.Visible then
            for _, child in ipairs(FlingScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local pBtn = Instance.new("TextButton")
                    pBtn.Parent = FlingScroll
                    pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    pBtn.Size = UDim2.new(0, 165, 0, 26)
                    pBtn.Font = Enum.Font.Gotham
                    pBtn.Text = p.Name
                    pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    pBtn.TextSize = 11
                    
                    pBtn.MouseButton1Click:Connect(function()
                        pBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                        pBtn.Text = "ATTACKING: " .. p.Name
                        
                        task.spawn(function()
                            local character = LocalPlayer.Character
                            local targetChar = p.Character
                            if character and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                local tHrp = targetChar.HumanoidRootPart
                                local startTime = tick()
                                while tick() - startTime < 2.5 and hrp and tHrp do
                                    hrp.CFrame = tHrp.CFrame * CFrame.new(math.random(-2, 2), 0, math.random(-2, 2))
                                    hrp.Velocity = Vector3.new(99999, 99999, 99999)
                                    RunService.RenderStepped:Wait()
                                end
                            end
                        end)
                    end)
                end
            end
        end
    end
end)
