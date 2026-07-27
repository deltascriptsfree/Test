--[ABIBOK]: ABYSS ENGINE DELTA | BOKTAR PROTOCOL
-- Delta Executor Mobile Optimized

local LP = game.Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")
local Cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- ANTI BAN BLOCK
local Detected = {"Detector","Anti","Ban","Kick","Guard","Watch","Log","Check","Flag","Report","Mod","Admin"}
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
        local n = v.Name:lower()
        for _,d in pairs(Detected) do
            if n:find(d:lower()) then
                v.Enabled = false
                pcall(function() v:Destroy() end)
            end
        end
    end
end

-- Remote Blocker
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    local a = {...}
    if m == "FireServer" or m == "InvokeServer" then
        local s = tostring(self)
        for _,d in pairs(Detected) do
            if s:find(d) then return nil end
        end
    end
    if m == "Kick" then return nil end
    return old(self, unpack(a))
end)

-- FLY ENGINE
getgenv().FlyEnabled = false
getgenv().FlySpeed = 1

local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
BV.Velocity = Vector3.zero
BV.Parent = HRP

local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
BG.CFrame = HRP.CFrame
BG.Parent = HRP

local function startFly()
    getgenv().FlyEnabled = true
    Hum.PlatformStand = true
    RS.Stepped:Connect(function()
        if not getgenv().FlyEnabled then return end
        if not Char or not HRP or not Hum then return end
        
        BG.CFrame = Cam.CFrame
        local dir = Vector3.zero
        local sp = getgenv().FlySpeed * 50
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        
        if dir.Magnitude > 0 then
            BV.Velocity = dir.Unit * sp
        else
            BV.Velocity = Vector3.zero
        end
    end)
end

local function stopFly()
    getgenv().FlyEnabled = false
    Hum.PlatformStand = false
    BV:Destroy()
    BG:Destroy()
end

-- SPEED HACK
getgenv().SpeedEnabled = false
getgenv().SpeedValue = 16

local function setSpeed(val)
    Hum.WalkSpeed = val
end

-- NOCLIP
getgenv().NoClipEnabled = false
RS.Stepped:Connect(function()
    if getgenv().NoClipEnabled then
        for _,v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- JUMP POWER
getgenv().JumpPower = 50

-- GUI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/Fluent.lua"))()
local Window = Fluent:CreateWindow({
    Title = "ABIBOK | BOKTAR",
    SubTitle = "Delta Executor",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "bolt" }),
    Fly = Window:AddTab({ Title = "Fly", Icon = "bird" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Tabs.Main:AddButton({ Title = "Speed Hack", Callback = function()
    getgenv().SpeedEnabled = not getgenv().SpeedEnabled
    if getgenv().SpeedEnabled then
        setSpeed(getgenv().SpeedValue)
    else
        setSpeed(16)
    end
end})

Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Speed",
    Default = 50,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(val)
        getgenv().SpeedValue = val
        if getgenv().SpeedEnabled then setSpeed(val) end
    end
})

Tabs.Main:AddButton({ Title = "NoClip", Callback = function()
    getgenv().NoClipEnabled = not getgenv().NoClipEnabled
end})

Tabs.Main:AddSlider("JumpSlider", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(val)
        Hum.JumpPower = val
    end
})

Tabs.Fly:AddButton({ Title = "Toggle Fly", Callback = function()
    if getgenv().FlyEnabled then
        stopFly()
    else
        startFly()
    end
end})

Tabs.Fly:AddSlider("FlySlider", {
    Title = "Fly Speed",
    Default = 1,
    Min = 0.1,
    Max = 20,
    Rounding = 1,
    Callback = function(val)
        getgenv().FlySpeed = val
    end
})

Tabs.Settings:AddButton({ Title = "Rejoin", Callback = function()
    LP:Kick("ABIBOK Session End")
end})

Tabs.Settings:AddButton({ Title = "Crash Server", Callback = function()
    while true do
        pcall(function()
            for i=1,1000 do
                local p = Instance.new("Part", workspace)
                p.Name = "BOKTAR_CRASH_"..tostring(math.random(1e9))
                p.Size = Vector3.new(math.random(1,100), math.random(1,100), math.random(1,100))
            end
        end)
    end
end})

LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
    HRP = Char:WaitForChild("HumanoidRootPart")
    Hum = Char:WaitForChild("Humanoid")
    wait(0.5)
    if getgenv().FlyEnabled then
        stopFly()
        startFly()
    end
end)
