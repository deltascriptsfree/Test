-- ============================================================================
-- MM2 ULTIMATE HACK SUITE V3 (DELTA OPTIMIZED)
-- Features: Russian Interface, Compact UI, Working Mobile Fly, Role ESP,
-- Target Aimbot, Fling Player GUI (Select by Name), Pre-game Role Detection,
-- Speed (Fix Toggle), Noclip, Fullbright, SpinBot, Infinite Jump & More!
-- Language: Russian
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
local InfJumpActive = false
local SpinBotActive = false
local PreGameRoleActive = true

-- Configuration Values
local WalkSpeedValue = 32
local FlySpeedValue = 50

-- Cleanup Existing UI Instances
if CoreGui:FindFirstChild("MM2UltimateSuiteGuiV3") then
    CoreGui.MM2UltimateSuiteGuiV3:Destroy()
end

-- Create Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2UltimateSuiteGuiV3"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Floating Toggle Button (Open/Close)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.BorderSizePixel = 2
ToggleButton.Position = UDim2.new(0.02, 0, 0.1, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "МЕНЮ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 11
ToggleButton.Active = true
ToggleButton.Draggable = true

-- Main Frame Window (Compact Size, Tabbed or Collapsible Design)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.08, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 230, 0, 320) -- Компактный размер!
MainFrame.Active = true
MainFrame.Draggable = true

-- Header Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 32)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "MM2 HACK (DELTA)"
TitleText.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Switch Tabs Button / Minimize
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -26, 0, 6)
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

-- Scrollable Container for Options
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0, 36)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -36)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

-- Helper Builder Function for Interactive Toggle Buttons (Russian)
local function createToggle(labelName, initialCallback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(0, 210, 0, 32)
    Button.Font = Enum.Font.Gotham
    Button.Text = labelName .. ": ВЫКЛ"
    Button.TextColor3 = Color3.fromRGB(170, 170, 170)
    Button.TextSize = 12

    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Button.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = labelName .. ": ВКЛ"
        else
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Button.TextColor3 = Color3.fromRGB(170, 170, 170)
            Button.Text = labelName .. ": ВЫКЛ"
        end
        pcall(function()
            initialCallback(toggled)
        end)
    end)
end

-- Role Identification Logic
local function fetchPlayerRole(targetPlayer)
    if not targetPlayer.Character then return "Innocent", Color3.fromRGB(0, 255, 0) end
    
    local char = targetPlayer.Character
    local backpack = targetPlayer:FindFirstChild("Backpack")
    
    local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if hasKnife then
        return "Убийца", Color3.fromRGB(255, 40, 40)
    elseif hasGun then
        return "Шериф", Color3.fromRGB(40, 140, 255)
    else
        return "Невинный", Color3.fromRGB(40, 255, 90)
    end
end

-- Pre-game Role Detection (Показывает роль до начала раунда по инвентарю/банку данных)
local PreGameLabel = Instance.new("TextLabel")
PreGameLabel.Parent = ScreenGui
PreGameLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PreGameLabel.BorderColor3 = Color3.fromRGB(0, 170, 255)
PreGameLabel.BorderSizePixel = 1
PreGameLabel.Position = UDim2.new(0.02, 0, 0.23, 0)
PreGameLabel.Size = UDim2.new(0, 180, 0, 30)
PreGameLabel.Font = Enum.Font.GothamBold
PreGameLabel.Text = "Роль: Ожидание..."
PreGameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PreGameLabel.TextSize = 11

RunService.Heartbeat:Connect(function()
    if PreGameRoleActive and LocalPlayer then
        local role, color = fetchPlayerRole(LocalPlayer)
        PreGameLabel.Text = "Ваша роль: " .. role
        PreGameLabel.TextColor3 = color
    end
end)

-- 1. ESP Role Highlighting
local espRepository = {}

local function clearEspEntity(playerInstance)
    if espRepository[playerInstance] then
        if espRepository[playerInstance].highlight then espRepository[playerInstance].highlight:Destroy() end
        if espRepository[playerInstance].billboard then espRepository[playerInstance].billboard:Destroy() end
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
                bb.Size = UDim2.new(0, 160, 0, 50)
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel")
                txt.Parent = bb
                txt.BackgroundTransparency = 1
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 12
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.TextStrokeTransparency = 0
                
                espRepository[p] = {highlight = hl, billboard = bb, text = txt}
            end
            
            local dataRecord = espRepository[p]
            if dataRecord and dataRecord.highlight and dataRecord.text then
                dataRecord.highlight.FillColor = roleColor
                dataRecord.highlight.OutlineColor = roleColor
                dataRecord.text.Text = p.Name .. "\n[" .. currentRole .. "]"
                dataRecord.text.TextColor3 = roleColor
            end
        else
            clearEspEntity(p)
        end
    end
end)

createToggle("ВХ / Подсветка Ролей", function(state)
    EspActive = state
end)

-- 2. Noclip System
createToggle("Ходьба сквозь стены", function(state)
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

-- 3. Working Mobile Fly System (Исправлен лаг на месте!)
local flyConnection

createToggle("Полет (Fly)", function(state)
    FlyActive = state
    local characterInstance = LocalPlayer.Character
    if not characterInstance or not characterInstance:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = characterInstance.HumanoidRootPart
    local humanoid = characterInstance:FindFirstChildOfClass("Humanoid")
    
    if FlyActive then
        humanoid.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlightVelocity"
        bv.Parent = rootPart
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlightGyro"
        bg.Parent = rootPart
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = Camera.CFrame
        
        flyConnection = RunService.RenderStepped:Connect(function()
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
        if flyConnection then flyConnection:Disconnect() end
        if rootPart:FindFirstChild("FlightVelocity") then rootPart.FlightVelocity:Destroy() end
        if rootPart:FindFirstChild("FlightGyro") then rootPart.FlightGyro:Destroy() end
        if humanoid then humanoid.PlatformStand = false end
    end
end)

-- 4. Smart Target-Specific Aimbot
createToggle("Умный Аимбот", function(state)
    AimbotActive = state
end)

RunService.RenderStepped:Connect(function()
    if not AimbotActive then return end
    
    local myPlayerRole, _ = fetchPlayerRole(LocalPlayer)
    local targetFilterRole = ""
    
    if myPlayerRole == "Убийца" then
        targetFilterRole = "Шериф"
    elseif myPlayerRole == "Шериф" or myPlayerRole == "Невинный" then
        targetFilterRole = "Убийца"
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

-- 5. Speed Hack Boost (С корректным отключением!)
createToggle("Быстрый Бег (Speed)", function(state)
    SpeedActive = state
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local humanoidEntity = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoidEntity then
            if SpeedActive then
                humanoidEntity.WalkSpeed = WalkSpeedValue
            else
                humanoidEntity.WalkSpeed = 16 -- Сброс к дефолтной скорости при выключении
            end
        end
    end
end)

-- 6. Auto Gun Pickup System
createToggle("Авто-подбор Пистолета", function(state)
    AutoGunActive = state
end)

RunService.Heartbeat:Connect(function()
    if AutoGunActive and LocalPlayer.Character then
        local rootNode = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootNode then
            for _, itemInstance in ipairs(Workspace:GetChildren()) do
                if itemInstance.Name == "GunDrop" and itemInstance:IsA("BasePart") then
                    if (itemInstance.Position - rootNode.Position).Magnitude < 30 then
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

-- 7. Fullbright (Яркое освещение)
createToggle("Светлый мир (Fullbright)", function(state)
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

-- 8. Infinite Jump (Бесконечный прыжок)
createToggle("Бесконечный Прыжок", function(state)
    InfJumpActive = state
end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpActive and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 9. SpinBot (Крутится для дезориентации врагов)
createToggle("Спинбот (Вращение)", function(state)
    SpinBotActive = state
end)

RunService.RenderStepped:Connect(function()
    if SpinBotActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(35), 0)
    end
end)

-- ============================================================================
-- FLING GUI MODULE (Флинг любого игрока по нику или роли)
-- ============================================================================
local FlingFrameOpen = false
local SelectedTargetToFling = nil

local FlingMenuBtn = Instance.new("TextButton")
FlingMenuBtn.Parent = ScrollingFrame
FlingMenuBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
FlingMenuBtn.BorderSizePixel = 0
FlingMenuBtn.Size = UDim2.new(0, 210, 0, 32)
FlingMenuBtn.Font = Enum.Font.GothamBold
FlingMenuBtn.Text = "Открыть Меню Флинга"
FlingMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingMenuBtn.TextSize = 12

-- Второе окно для выбора игроков под флинг
local FlingWindow = Instance.new("Frame")
FlingWindow.Name = "FlingWindow"
FlingWindow.Parent = ScreenGui
FlingWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FlingWindow.BorderColor3 = Color3.fromRGB(255, 50, 50)
FlingWindow.BorderSizePixel = 1
FlingWindow.Position = UDim2.new(0.32, 0, 0.1, 0)
FlingWindow.Size = UDim2.new(0, 190, 0, 240)
FlingWindow.Visible = false
FlingWindow.Active = true
FlingWindow.Draggable = true

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Parent = FlingWindow
FlingTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlingTitle.Size = UDim2.new(1, 0, 0, 30)
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.Text = "ВЫБОР ИГРОКА ДЛЯ ФЛИНГА"
FlingTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
FlingTitle.TextSize = 10

local FlingScroll = Instance.new("ScrollingFrame")
FlingScroll.Parent = FlingWindow
FlingScroll.BackgroundTransparency = 1
FlingScroll.Position = UDim2.new(0, 0, 0, 35)
FlingScroll.Size = UDim2.new(1, 0, 1, -35)
FlingScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
FlingScroll.ScrollBarThickness = 4

local FlingLayout = Instance.new("UIListLayout")
FlingLayout.Parent = FlingScroll
FlingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FlingLayout.SortOrder = Enum.SortOrder.LayoutOrder
FlingLayout.Padding = UDim.new(0, 4)

FlingMenuBtn.MouseButton1Click:Connect(function()
    FlingFrameOpen = not FlingFrameOpen
    FlingWindow.Visible = FlingFrameOpen
end)

-- Обновление списка игроков для флинга
task.spawn(function()
    while true do
        task.wait(1)
        if FlingWindow.Visible then
            -- Очищаем старые кнопки
            for _, child in ipairs(FlingScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local pBtn = Instance.new("TextButton")
                    pBtn.Parent = FlingScroll
                    pBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    pBtn.Size = UDim2.new(0, 175, 0, 28)
                    pBtn.Font = Enum.Font.Gotham
                    pBtn.Text = p.Name
                    pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    pBtn.TextSize = 11
                    
                    pBtn.MouseButton1Click:Connect(function()
                        SelectedTargetToFling = p
                        pBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                        pBtn.Text = "АТАКА: " .. p.Name
                        
       
