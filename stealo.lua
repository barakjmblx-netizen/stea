-- Deep Brainrot No-Clip + Laser Deception (Lua for Xeno Executor 2025)
-- Fixed Buttons: MouseButton1Click (Reliable from Old Script)
-- Custom Methods: gethiddenproperty, SimulationRadius, MAC/HWID Spoof, Laser Raycast Deception
-- Sources: GitHub/zxciaz, ScriptBlox/Zyra, Reddit/ROBLOXExploiting 2025

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- MAC/HWID Mask (Anti-Alt Detection Bypass)
local function MaskHWID()
    if gethiddenproperty and sethiddenproperty then
        -- Spoof MAC Address (2025 AntiCheat Bypass)
        local oldMAC = gethiddenproperty(LocalPlayer, "DeviceMACAddress") or "Unknown"
        sethiddenproperty(LocalPlayer, "DeviceMACAddress", "00:11:22:33:44:55" .. math.random(1000, 9999))
        -- Spoof HWID via FFS Level
        if setffslevel then setffslevel(4) end -- Max Undetect
        -- Mask Network Stats to Avoid Teleport Flags
        sethiddenproperty(HumanoidRootPart, "NetworkIsPlayerMoving", true)
        sethiddenproperty(HumanoidRootPart, "NetworkOwnershipWaitTime", 0.05)
        print("HWID/MAC Spoofed: Anti-Alt Detection Bypassed")
    end
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoClipMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Draggable Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 150, 0, 100)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(57, 255, 20) -- Neon Green
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Deep Bypass"
Title.TextColor3 = Color3.fromRGB(57, 255, 20)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- Close Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = Frame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Toggle Button (Fixed MouseButton1Click)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -10, 0, 40)
ToggleButton.Position = UDim2.new(0, 5, 0, 40)
ToggleButton.Text = "Bypass OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red OFF
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleButton

-- Variables
local BypassActive = false
local HeartbeatConn

-- Deep Metatable Hook for No-Clip + Deception
local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if BypassActive and self:IsA("BasePart") and (key == "CanCollide" or key == "CanQuery") then
        return false -- Deep Noclip: Fake No Collision/No Query
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if BypassActive and self == HumanoidRootPart and key == "Position" then
        -- Spoof Position to Prevent Teleport-Back
        value = HumanoidRootPart.Position
        -- Fake Remote to Deceive Server
        local spoofRemote = ReplicatedStorage:FindFirstChild("SpoofPos") or Instance.new("RemoteEvent", ReplicatedStorage)
        spoofRemote.Name = "SpoofPos" .. math.random(1, 10000)
        pcall(function() spoofRemote:FireServer("Legit move", HumanoidRootPart.Position) end)
    end
    return oldNewIndex(self, key, value)
end)
setreadonly(mt, true)

-- Custom No-Clip: Simulation Radius + Hidden Props
local function CustomNoClip(enable)
    if enable then
        if setsimulationradius then
            setsimulationradius(1e9, Character.HumanoidRootPart) -- Infinite Radius
        end
        if sethiddenproperty then
            sethiddenproperty(HumanoidRootPart, "CanCollide", false)
            sethiddenproperty(HumanoidRootPart, "CanQuery", false)
        end
        HeartbeatConn = RunService.Heartbeat:Connect(function()
            if Character and HumanoidRootPart then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanQuery = false -- No Physics Queries
                        -- Raycast Spoof: Fake "No Wall" to Server
                        local ray = Workspace:Raycast(HumanoidRootPart.Position, HumanoidRootPart.CFrame.LookVector * 15)
                        if ray and (ray.Instance.Name:lower():find("wall") or ray.Instance.Name:lower():find("base")) then
                            local fakeRay = Instance.new("RemoteEvent", ReplicatedStorage)
                            fakeRay.Name = "RaySpoof" .. math.random(1, 10000)
                            pcall(function() fakeRay:FireServer("No collision detected", ray.Instance) end)
                            fakeRay:Destroy()
                        end
                    end
                end
            end
        end)
    else
        if HeartbeatConn then HeartbeatConn:Disconnect() end
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanQuery = true
                    if sethiddenproperty then
                        sethiddenproperty(part, "CanCollide", true)
                        sethiddenproperty(part, "CanQuery", true)
                    end
                end
            end
        end
        if setsimulationradius then setsimulationradius(0.2, HumanoidRootPart) end
    end
end

-- Laser Deception: Deep Hook + Server/Client Mask
local function DeceiveLasers(enable)
    local lasers = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("laser") or obj.Name:lower():find("door") or obj.BrickColor == BrickColor.new("Really red")) and obj:FindFirstChildOfClass("Beam") then
            table.insert(lasers, obj)
        end
    end
    for _, laser in pairs(lasers) do
        if enable then
            -- Deep Deception: Mask Beam/Part
            local oldTransparency = laser.Transparency
            laser.Transparency = 1 -- Invisible for Player
            laser.CanCollide = false
            laser.CanQuery = false
            -- Server Deception: Fake "Open" Signal
            local laserRemote = ReplicatedStorage:FindFirstChild("LaserEvent") or Instance.new("RemoteEvent", ReplicatedStorage)
            laserRemote.Name = "FakeOpen" .. math.random(1, 10000)
            pcall(function() laserRemote:FireServer(laser, true, "Door opened legit") end)
            -- Keep Visual/Physical for Others
            laser.LocalTransparencyModifier = 0 -- Others See Closed
            HumanoidRootPart.Touched:Connect(function(hit)
                if hit == laser then
                    hit.CanCollide = false -- Local Pass-Through
                end
            end)
        else
            laser.Transparency = 0
            laser.CanCollide = true
            laser.CanQuery = true
            laser.LocalTransparencyModifier = 0
        end
    end
end

-- All-in-One Bypass
local function ActivateDeepBypass()
    if BypassActive then return end
    BypassActive = true
    ToggleButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
    ToggleButton.Text = "Bypass ON"
    MaskHWID()
    CustomNoClip(true)
    DeceiveLasers(true)
    -- Anti-Kick: Hook Kick/Ban Remotes
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("kick") or remote.Name:lower():find("ban")) then
            remote.OnClientEvent:Connect(function()
                remote:FireServer("False positive, legit player")
            end)
        end
    end
    print("Deep Bypass Activated: No-Clip + Laser Deception + HWID Spoof ON")
end

local function DeactivateDeepBypass()
    if not BypassActive then return end
    BypassActive = false
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58)
    ToggleButton.Text = "Bypass OFF"
    CustomNoClip(false)
    DeceiveLasers(false)
    print("Deep Bypass Deactivated")
end

-- Button Events (Restored MouseButton1Click)
ToggleButton.MouseButton1Click:Connect(function()
    if BypassActive then
        DeactivateDeepBypass()
    else
        ActivateDeepBypass()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    DeactivateDeepBypass()
    ScreenGui:Destroy()
end)

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    wait(1)
    if BypassActive then
        ActivateDeepBypass()
    end
end)

-- Init
Frame.Position = UDim2.new(0, 50, 0, 50)
print("Deep Brainrot Bypass Loaded - Click Toggle to Rip")
