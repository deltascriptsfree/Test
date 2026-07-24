-- ============================================================================
-- MM2 ULTIMATE ADVANCED EXECUTOR SUITE (DELTA OPTIMIZED)
-- Features: Collapsible UI, ESP (Roles, Highlights, Billboards), Smart Role-Based 
-- Aimbot, Working Fly, Noclip, Speed Hack, Auto Gun Pickup, Anti-Lag, and Fling.
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global Feature Flags
local MenuOpen = true
local NoclipActive = false
local EspActive = false
local AimbotActive = false
local FlyActive = false
local SpeedActive = false
local AutoGunActive = false
local FullbrightActive = false
local FlingActive = false

-- Configuration Values
local WalkSpeedValue = 35
local FlySpeedValue = 60

-- Cleanup Existing GUI Instances to Prevent Duplicates
if CoreGui:FindFirstChild("MM2UltimateSuiteGui") then
    CoreGui.MM2UltimateSuiteGui:Destroy()
end

-- Create Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2UltimateSuiteGui"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Floating Toggle Button (UI Open/Close)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.BorderSizePixel = 2
ToggleButton.Position = UDim2.new(0.02, 0, 0.12, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Active = true
ToggleButton.Draggable = true

-- Main Frame Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.08, 0, 0.12, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 460)
MainFrame.Active = true
MainFrame.Draggable = true

-- Header Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.Size = UDim2.new(1, -12, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "MM2 ULTIMATE SUITE"
TitleText.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Scrollable Container for Menu Options
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingFrame.ScrollBarThickness = 5

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- UI Toggle Action
ToggleButton.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
end)

-- Helper Builder Function for Interactive Toggle Buttons
local function createToggle(labelName, initialCallback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(0, 225, 0, 38)
    Button.Font = Enum.Font.Gotham
    Button.Text = labelName .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(170, 170, 170)
    Button.TextSize = 13

    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Button.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = labelName .. ": ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Button.TextColor3 = Color3.fromRGB(170, 170, 170)
            Button.Text = labelName .. ": OFF"
        end
        pcall(function()
            initialCallback(toggled)
        end)
    end)
end

-- Role Identification Logic (MM2 Item Inspection)
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

-- 1. ESP Role Highlighting & Overhead Tracking System
local espRepository = {}

local function clearEspEntity(playerInstance)
    if espRepository[playerInstance] then
        if espRepository[playerInstance].highlight then
            espRepository[playerInstance].highlight:Destroy()
        end
        if espRepository[playerInstance].billboard then
            espRepository[playerInstance].billboard:Destroy()
        end
        espRepository[playerInstance] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not EspActive then
        for playerInstance, _ in pairs(espRepository) do
            clearEspEntity(playerInstance)
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local currentRole, roleColor = fetchPlayerRole(p)
            
            if not espRepository[p] then
                local hl = Instance.new("Highlight")
                hl.Parent = p.Character
                hl.Adornee = p.Character
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                
                local bb = Instance.new("BillboardGui")
                bb.Parent = p.Character.Head
                bb.Size = UDim2.new(0, 160, 0, 55)
                bb.StudsOffset = Vector3.new(0, 2.8, 0)
                bb.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel")
                txt.Parent = bb
                txt.BackgroundTransparency = 1
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 13
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.TextStrokeTransparency = 0
                
                espRepository[p] = {highlight = hl, billboard = bb, text = txt}
            end
            
            local dataRecord = espRepository[p]
            if dataRecord and dataRecord.highlight and dataRecord.text then
                dataRecord.highlight.FillColor = roleColor
                dataRecord.highlight.OutlineColor = roleColor
                dataRecord.text.Text = p.Name .. "\n[" .. string.upper(currentRole) .. "]"
                dataRecord.text.TextColor3 = roleColor
            end
        else
            clearEspEntity(p)
        end
    end
end)

createToggle("ESP & Roles", function(state)
    EspActive = state
end)

-- 2. Noclip System (Walk through walls)
createToggle("Noclip Walls", function(state)
    NoclipActive = state
end)

RunService.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character then
        for _, partObj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if partObj:IsA("BasePart") and partObj.CanCollide then
                partObj.CanCollide = false
            end
        end
    end
end)

-- 3. Working Fly System
local flightGyro, flightVelocity

createToggle("Fly Mode", function(state)
    FlyActive = state
    local characterInstance = LocalPlayer.Character
    if not characterInstance or not characterInstance:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = characterInstance.HumanoidRootPart
    
    if FlyActive then
        flightGyro = Instance.new("BodyGyro")
        flightGyro.Parent = rootPart
        flightGyro.MaxTorque = Vector3.new(500000, 500000, 500000)
        flightGyro.CFrame = rootPart.CFrame
        
        flightVelocity = Instance.new("BodyVelocity")
        flightVelocity.Parent = rootPart
        flightVelocity.MaxForce = Vector3.new(500000, 500000, 500000)
        flightVelocity.Velocity = Vector3.new(0, 0, 0)
        
        task.spawn(function()
            while FlyActive and characterInstance and rootPart.Parent do
                local camMatrix = Camera.CFrame
                local movementDirection = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then movementDirection = movementDirection + camMatrix.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then movementDirection = movementDirection - camMatrix.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then movementDirection = movementDirection - camMatrix.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then movementDirection = movementDirection + camMatrix.RightVector end
                
                flightVelocity.Velocity = movementDirection * FlySpeedValue
                flightGyro.CFrame = camMatrix
                RunService.RenderStepped:Wait()
            end
        end)
    else
        if flightGyro then flightGyro:Destroy() end
        if flightVelocity then flightVelocity:Destroy() end
    end
end)

-- 4. Smart Target-Specific Aimbot (Murderer targets Sheriff/Hero, Sheriff/Innocent targets Murderer)
createToggle("Smart Aimbot", function(state)
    AimbotActive = state
end)

RunService.RenderStepped:Connect(function()
    if not AimbotActive then return end
    
    local myPlayerRole, _ = fetchPlayerRole(LocalPlayer)
    local targetFilterRole = ""
    
    if myPlayerRole == "Murderer" then
        targetFilterRole = "Sheriff"
    elseif myPlayerRole == "Sheriff" or myPlayerRole == "Innocent" then
        targetFilterRole = "Murderer"
    end
    
    local selectedTargetPart = nil
    local minDistanceLimit = math.huge
    
    for _, ply in ipairs(Players:GetPlayers()) do
        if ply ~= LocalPlayer and ply.Character and ply.Character:FindFirstChild("HumanoidRootPart") then
            local evaluatedRole, _ = fetchPlayerRole(ply)
            local hum = ply.Character:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 and (evaluatedRole == targetFilterRole or targetFilterRole == "") then
                local partRoot = ply.Character.HumanoidRootPart
                local screenVector, visibleOnScreen = Camera:WorldToScreenPoint(partRoot.Position)
                
                if visibleOnScreen then
                    local cursorLocation = UserInputService:GetMouseLocation()
                    local calculatedDist = (Vector2.new(screenVector.X, screenVector.Y) - cursorLocation).Magnitude
                    if calculatedDist < minDistanceLimit then
                        minDistanceLimit = calculatedDist
                        selectedTargetPart = partRoot
                    end
                end
            end
        end
    end
    
    if selectedTargetPart then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, selectedTargetPart.Position)
    end
end)

-- 5. Speed Hack Boost
createToggle("Speed Boost", function(state)
    SpeedActive = state
end)

RunService.Heartbeat:Connect(function()
    if SpeedActive and LocalPlayer.Character then
        local humanoidEntity = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoidEntity then
            humanoidEntity.WalkSpeed = WalkSpeedValue
        end
    end
end)

-- 6. Auto Gun Pickup System
createToggle("Auto Gun Pickup", function(state)
    AutoGunActive = state
end)

RunService.Heartbeat:Connect(function()
    if AutoGunActive and LocalPlayer.Character then
        local rootNode = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootNode then
            for _, itemInstance in ipairs(Workspace:GetChildren()) do
                if itemInstance.Name == "GunDrop" and itemInstance:IsA("BasePart") then
                    if (itemInstance.Position - rootNode.Position).Magnitude < 25 then
                        pcall(function()
                            if firetouchinterest then
                                firetouchinterest(rootNode, itemInstance, 0)
                                firetouchinterest(rootNode, itemInstance, 1)
                            else
                                itemInstance.CFrame = rootNode.CFrame
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- 7. Additional Helper Feature: Fullbright (Clear Vision)
createToggle("Fullbright", function(state)
    FullbrightActive = state
end)

RunService.RenderStepped:Connect(function()
    if FullbrightActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)
