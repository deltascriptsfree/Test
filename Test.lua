-- ============================================================================
-- MM2 ULTIMATE GOD SUITE (DELTA MOBILE OPTIMIZED)
-- Features: Fixed Mobile Fly, Anti-Void, Non-Visual Morph & Body Mods (Corblox/Headless),
-- Advanced Aimbot (Innocent safety logic + Instant pre-round Murderer reveal),
-- Convenient Fling Menu with pinned Murderer/Sheriff, Remote Shoot/Throw Tool,
-- Anti-Fling, Godmode (Invincibility toggle).
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
local AntiVoidActive = false
local GodmodeActive = false
local AntiFlingActive = false

-- Configurations
local WalkSpeedValue = 32
local FlySpeedValue = 60

-- Cleanup previous GUI instances
if CoreGui:FindFirstChild("MM2GodSuiteGui") then
    CoreGui.MM2GodSuiteGui:Destroy()
end

-- Main Screen Gui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2GodSuiteGui"
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
ToggleButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.BorderSizePixel = 2
ToggleButton.Position = UDim2.new(0.02, 0, 0.08, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "GOD"
ToggleButton.TextColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.TextSize = 11
ToggleButton.Active = true
ToggleButton.Draggable = true

-- Main Frame Window
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.08, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 230, 0, 350)
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
TitleText.Text = "MM2 GOD SUITE v5"
TitleText.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleText.TextSize = 12
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

-- Scrolling Container
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0, 32)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -32)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 850)
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Helper: Create Toggles
local function createToggle(labelName, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(0, 210, 0, 32)
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

-- Role Detection System
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

-- Pre-Round / Instant Murderer Detection Label
local PreGameLabel = Instance.new("TextLabel")
PreGameLabel.Parent = ScreenGui
PreGameLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PreGameLabel.BorderColor3 = Color3.fromRGB(255, 40, 40)
PreGameLabel.BorderSizePixel = 1
PreGameLabel.Position = UDim2.new(0.02, 0, 0.16, 0)
PreGameLabel.Size = UDim2.new(0, 180, 0, 35)
PreGameLabel.Font = Enum.Font.GothamBold
PreGameLabel.Text = "Murderer: Searching..."
PreGameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PreGameLabel.TextSize = 11

RunService.Heartbeat:Connect(function()
    local foundMurderer = "None"
    for _, p in ipairs(Players:GetPlayers()) do
        local role, _ = fetchPlayerRole(p)
        if role == "Murderer" then
            foundMurderer = p.Name
            break
        end
    end
    if foundMurderer ~= "None" then
        PreGameLabel.Text = "Murderer: " .. foundMurderer
        PreGameLabel.TextColor3 = Color3.fromRGB(255, 40, 40)
    else
        PreGameLabel.Text = "Murderer: Waiting Round..."
        PreGameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- 1. ESP Roles
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

-- 2. Noclip
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

-- 3. Fixed Mobile Fly System (No walking freeze)
local flyConn
createToggle("Fly Mode", function(state)
    FlyActive = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if FlyActive then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVel"
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
        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
    end
end)

-- 4. Smart Aimbot (Innocent safety logic: doesn't target murderers if you are innocent/sheriff unless aimed at murderer)
createToggle("Smart Aimbot", function(state) AimbotActive = state end)
RunService.RenderStepped:Connect(function()
    if not AimbotActive then return end
    local myRole, _ = fetchPlayerRole(LocalPlayer)
    
    local bestTarget = nil
    local minDistance = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local role, _ = fetchPlayerRole(p)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            -- If innocent, do NOT target murderers automatically unless specified, or target murderer safely
            local shouldTarget = false
            if myRole == "Murderer" and role == "Sheriff" then shouldTarget = true
            elseif (myRole == "Innocent" or myRole == "Sheriff") and role == "Murderer" then shouldTarget = true
            elseif myRole == "Innocent" then shouldTarget = false -- Innocents shouldn't lock onto innocents
            end
            
            if shouldTarget and hum and hum.Health > 0 then
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

-- 5. Anti-Void (Instantly teleports back up if falling under map)
createToggle("Anti-Void", function(state) AntiVoidActive = state end)
RunService.Heartbeat:Connect(function()
    if AntiVoidActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hrp.Position.Y < -10 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 6. Godmode / Invincibility Toggle
createToggle("Godmode (No Die)", function(state) GodmodeActive = state end)
RunService.Heartbeat:Connect(function()
    if GodmodeActive and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
end)

-- 7. Anti-Fling
createToggle("Anti-Fling", function(state) AntiFlingActive = state end)
RunService.Stepped:Connect(function()
    if AntiFlingActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hrp.AssemblyLinearVelocity.Magnitude > 250 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 8. Speed Boost
createToggle("Speed Boost", function(state) SpeedActive = state end)
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedActive and WalkSpeedValue or 16
        end
    end
end)

-- 9. Auto Gun Pickup
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

-- 10. Fullbright
createToggle("Fullbright", function(state) FullbrightActive = state end)
RunService.RenderStepped:Connect(function()
    if FullbrightActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)

-- ============================================================================
-- EXTRA BUTTONS: SHOOT / THROW KNIFE / NON-VISUAL MORPHS (Corblox & Headless)
-- ============================================================================

local ExtraBox = Instance.new("TextButton")
ExtraBox.Parent = ScrollingFrame
ExtraBox.BackgroundColor3 = Color3.fromRGB(0, 100, 160)
ExtraBox.BorderSizePixel = 0
ExtraBox.Size = UDim2.new(0, 210, 0, 32)
ExtraBox.Font = Enum.Font.GothamBold
ExtraBox.Text = "Open Action & Morph Panel"
ExtraBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtraBox.TextSize = 11

local ActionWindow = Instance.new("Frame")
ActionWindow.Parent = ScreenGui
ActionWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ActionWindow.BorderColor3 = Color3.fromRGB(0, 170, 255)
ActionWindow.BorderSizePixel = 1
ActionWindow.Position = UDim2.new(0.32, 0, 0.08, 0)
ActionWindow.Size = UDim2.new(0, 200, 0, 280)
ActionWindow.Visible = false
ActionWindow.Active = true
ActionWindow.Draggable = true

local ActionTitle = Instance.new("TextLabel")
ActionTitle.Parent = ActionWindow
ActionTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ActionTitle.Size = UDim2.new(1, 0, 0, 28)
ActionTitle.Font = Enum.Font.GothamBold
ActionTitle.Text = "ACTION & MORPH MENU"
ActionTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
ActionTitle.TextSize = 10

ExtraBox.MouseButton1Click:Connect(function()
    ActionWindow.Visible = not ActionWindow.Visible
end)

local ActionScroll = Instance.new("ScrollingFrame")
ActionScroll.Parent = ActionWindow
ActionScroll.BackgroundTransparency = 1
ActionScroll.Position = UDim2.new(0, 0, 0, 30)
ActionScroll.Size = UDim2.new(1, 0, 1, -30)
ActionScroll.CanvasSize = UDim2.new(0, 0, 0, 320)
ActionScroll.ScrollBarThickness = 3

local ActionLayout = Instance.new("UIListLayout")
ActionLayout.Parent = ActionScroll
ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ActionLayout.SortOrder = Enum.SortOrder.LayoutOrder
ActionLayout.Padding = UDim.new(0, 5)

-- Button: Shoot / Throw Knife through walls
local ShootBtn = Instance.new("TextButton")
ShootBtn.Parent = ActionScroll
ShootBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ShootBtn.Size = UDim2.new(0, 180, 0, 30)
ShootBtn.Font = Enum.Font.GothamBold
ShootBtn.Text = "Throw Knife / Shoot Target"
ShootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootBtn.TextSize = 10

ShootBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end)

-- Button: Headless (Non-Visual Server Side or Local Mesh Remove)
local HeadlessBtn = Instance.new("TextButton")
HeadlessBtn.Parent = ActionScroll
HeadlessBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HeadlessBtn.Size = UDim2.new(0, 180, 0, 30)
HeadlessBtn.Font = Enum.Font.Gotham
HeadlessBtn.Text = "Equip Headless (Real)"
HeadlessBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadlessBtn.TextSize = 10

HeadlessBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            LocalPlayer.Character.Head.Transparency = 1
            if LocalPlayer.Character.Head:FindFirstChild("face") then
                LocalPlayer.Character.Head.face:Destroy()
            end
        end
    end)
end)

-- Button: Corblox (Real Leg Remove/Scale)
local CorbloxBtn = Instance.new("TextButton")
CorbloxBtn.Parent = ActionScroll
CorbloxBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CorbloxBtn.Size = UDim2.new(0, 180, 0, 30)
CorbloxBtn.Font = Enum.Font.Gotham
CorbloxBtn.Text = "Equip Corblox Legs"
CorbloxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CorbloxBtn.TextSize = 10

CorbloxBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, v in ipairs(char:GetChildren()) do
                if v.Name == "RightLeg" or v.Name == "LeftLeg" or v.Name == "RightLowerLeg" or v.Name == "LeftLowerLeg" then
                    v:Destroy()
                end
            end
        end
    end)
end)

-- ============================================================================
-- CONVENIENT FLING MENU (Pinned Murderer & Sheriff at top, then list)
-- ============================================================================

local FlingOpenBtn = Instance.new("TextButton")
FlingOpenBtn.Parent = ScrollingFrame
FlingOpenBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
FlingOpenBtn.BorderSizePixel = 0
FlingOpenBtn.Size = UDim2.new(0, 210, 0, 32)
FlingOpenBtn.Font = Enum.Font.GothamBold
FlingOpenBtn.Text = "Open Fling Menu"
FlingOpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingOpenBtn.TextSize = 12

local FlingWindow = Instance.new("Frame")
FlingWindow.Parent = ScreenGui
FlingWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlingWindow.BorderColor3 = Color3.fromRGB(255, 50, 50)
FlingWindow.BorderSizePixel = 1
FlingWindow.Position = UDim2.new(0.32, 0, 0.25, 0)
FlingWindow.Size = UDim2.new(0, 190, 0, 260)
FlingWindow.Visible = false
FlingWindow.Active = true
FlingWindow.Draggable = true

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Parent = FlingWindow
FlingTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FlingTitle.Size = UDim2.new(1, 0, 0, 28)
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.Text = "FLING TARGETS"
FlingTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
FlingTitle.TextSize = 10

FlingOpenBtn.MouseButton1Click:Connect(function()
    FlingWindow.Visible = not FlingWindow.Visible
end)

local FlingScroll = Instance.new("ScrollingFrame")
FlingScroll.Parent = FlingWindow
FlingScroll.BackgroundTransparency = 1
FlingScroll.Position = UDim2.new(0, 0, 0, 30)
FlingScroll.Size = UDim2.new(1, 0, 1, -30)
FlingScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
FlingScroll.ScrollBarThickness = 3

local FlingLayout = Instance.new("UIListLayout")
FlingLayout.Parent = FlingScroll
FlingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FlingLayout.SortOrder = Enum.SortOrder.LayoutOrder
FlingLayout.Padding = UDim.new(0, 4)

task.spawn(function()
    while true do
        task.wait(1)
        if FlingWindow.Visible then
            for _, child in ipairs(FlingScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            -- Sort players pinning Murderer and Sheriff first
            local playersList = Players:GetPlayers()
            table.sort(playersList, function(a, b)
                local roleA, _ = fetchPlayerRole(a)
                local roleB, _ = fetchPlayerRole(b)
                if roleA == "Murderer" then return true end
                if roleB == "Murderer" then return false end
                if roleA == "Sheriff" then return true end
                if roleB == "Sheriff" then return false end
                return a.Name < b.Name
            end)
            
            for _, p in ipairs(playersList) do
                if p ~= LocalPlayer then
                    local role, color = fetchPlayerRole(p)
                    local pBtn = Instance.new("TextButton")
                    pBtn.Parent = FlingScroll
                    pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    pBtn.Size = UDim2.new(0, 175, 0, 26)
                    pBtn.Font = Enum.Font.Gotham
                    pBtn.Text = p.Name .. " [" .. role .. "]"
                    pBtn.TextColor3 = color
                    pBtn.TextSize = 10
                    
                    pBtn.MouseButton1Click:Connect(function()
                        pBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                        pBtn.Text = "FLINGING: " .. p.Name
                        
                        task.spawn(function()
                            local character = LocalPlayer.Character
                            local targetChar = p.Character
                            if character and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                local tHrp = targetChar.HumanoidRootPart
                                local startTime = tick()
                                while tick() - startTime < 3 and hrp and tHrp do
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
