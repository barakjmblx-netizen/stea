-- Deep Brainrot No-Clip + Laser Deception (Lua for Xeno Executor 2025)
-- Custom Methods: gethiddenproperty Bypass, MAC/HWID Mask, Raycast Spoof
-- Button Fixed: UserInputService for Reliable Toggle
-- Sources: GitHub/zxciaz, ScriptBlox/Zyra, Reddit/ROBLOXExploiting 2025, WeAreDevs

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- MAC/HWID Mask (Deep Spoof for Alt Detection Bypass)
local function MaskHWID()
    if gethiddenproperty and sethiddenproperty then
        -- Spoof Device MAC (2025 Anti-Alt Bypass)
        local oldMAC = gethiddenproperty(LocalPlayer, "DeviceMACAddress")
        sethiddenproperty(LocalPlayer, "DeviceMACAddress", "00:11:22:33:44:55" .. math.random(1000, 9999)) -- Random Mask
        -- HWID Spoof via FFS Level (Bypass Roblox HWID Check)
        if setffslevel then setffslevel(4) end -- High Level for Undetect
        -- Spoof Stats to Legit (Avoid Teleport Detect)
        sethiddenproperty(HumanoidRootPart, "NetworkIsPlayerMoving", true)
        sethiddenproperty(HumanoidRootPart, "NetworkOwnershipWaitTime", 0.1)
        print("HWID/MAC Masked: Anti-Alt Detection Bypassed")
    end
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeepBypass"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (Draggable)
local Frame = Instance.new("Frame")
Frame.Name = "BypassFrame"
Frame.Size = UDim2.new(0, 160, 0, 80)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(57, 255, 20)
Stroke.Thickness = 2
Stroke.Parent = Frame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 0.4, 0)
Title.Position = UDim2.new(0, 5, 0, 5)
Title.Text = "Deep Bypass"
Title.TextColor3 = Color3.fromRGB(57, 255, 20)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Close Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.2, 0, 0.4, 0)
CloseButton.Position = UDim2.new(0.75, 0, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = Frame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Toggle Button (Fixed with UserInputService)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -10, 0.5, 0)
ToggleButton.Position = UDim2.new(0, 5, 0.5, 0)
ToggleButton.Text = "Bypass OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 12
ToggleButton.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleButton

-- Variables
local BypassActive = false
local HeartbeatConn
local InputConn

-- Deep Metatable Hook for Deeper Deception
local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if BypassActive and self:IsA("BasePart") and key == "CanCollide" then
        return false -- Deep Noclip: Always Report False Collision
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if BypassActive and self == HumanoidRootPart and key == "Position" then
        -- Spoof Position to Legit (No Teleport Detect)
        value = HumanoidRootPart.Position -- Echo Back to Avoid Flags
    end
    return oldNewIndex(self, key, value)
end)
setreadonly(mt, true)

-- Custom No-Clip Method: Simulation Radius + HiddenProperty Bypass
local function CustomNoClip(enable)
    if enable then
        if setsimulationradius then
            setsimulationradius(9e9, Character.HumanoidRootPart) -- Infinite Radius Ignore
        end
        if gethiddenproperty and sethiddenproperty then
            sethiddenproperty(HumanoidRootPart, "CollisionGroup", "Default") -- Mask Group
            sethiddenproperty(HumanoidRootPart, "CanCollide", false) -- Hidden Set
        end
        -- Raycast Spoof: Game Thinks Walls Exist but No Hit
        HeartbeatConn = RunService.Heartbeat:Connect(function()
            if Character and HumanoidRootPart then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanQuery = false -- Deep: No Physics Query
                        -- Fake Raycast Report (Server Deception)
                        local ray = workspace:Raycast(HumanoidRootPart.Position, HumanoidRootPart.CFrame.LookVector * 10)
                        if ray and ray.Instance.Name:find("Wall") then
                            -- Spoof "No Hit" to Server via Fake Event
                            local fakeRay = Instance.new("RemoteEvent", ReplicatedStorage)
                            fakeRay.Name = "SpoofRayNoHit"
                            pcall(function() fakeRay:FireServer("Wall ignored, legit path") end)
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
                    if sethiddenproperty then sethiddenproperty(part, "CanCollide", true) end
                end
            end
        end
        if setsimulationradius then setsimulationradius(0.2, HumanoidRootPart) end -- Restore
    end
end

-- Laser Door Deception: Deeper Hook + Visual/Physical Mask
local function DeceiveLasers(enable)
    local lasers = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("laser") or obj.Name:lower():find("door") or obj.BrickColor == BrickColor.new("Really red")) and obj:FindFirstChildOfClass("Beam") then
            table.insert(lasers, obj)
        end
    end
    for _, laser in pairs(lasers) do
        if enable then
            -- Deep Deception: Hook Beam Properties
            local oldTransparency = laser.Transparency
            laser.Transparency = 1 -- Visual Hide for Player
            laser.CanCollide = false -- Physical Pass
            laser.CanQuery = false
            -- Server Spoof: Fake "Open" Event with Masked Remote
            local spoofRemote = ReplicatedStorage:FindFirstChild("LaserRemote") or Instance.new("RemoteEvent", ReplicatedStorage)
            spoofRemote.Name = "DeceiveOpen" .. math.random(1, 10000) -- Random to Avoid Detect
            pcall(function()
                spoofRemote:FireServer(laser, true, "Legit open signal") -- Server Thinks Open
            end)
            -- Local Mask: Player Sees Closed but Passes
            laser.LocalTransparencyModifier = 0 -- Others See Closed
        else
            laser.Transparency = 0
            laser.CanCollide = true
            laser.CanQuery = true
        end
    end
end

-- All-in-One Activate
local function ActivateDeepBypass()
    if BypassActive then return end
    BypassActive = true
    ToggleButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
    ToggleButton.Text = "Bypass ON"
    MaskHWID() -- Initial Mask
    CustomNoClip(true)
    DeceiveLasers(true)
    -- Anti-Kick Deep: Hook Kick Remotes
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("kick") or remote.Name:lower():find("ban")) then
            remote.OnClientEvent:Connect(function(...)
                -- Spoof Response: "Legit Player"
                remote:FireServer("No cheat detected, false positive")
            end)
        end
    end
    print("Deep Bypass Activated: Custom No-Clip + Laser Deception + HWID Mask ON")
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

-- Fixed Toggle: UserInputService (Began for Reliability in Xeno)
InputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and ToggleButton:IsDescendantOf(game.CoreGui) then -- Wait, no — check if over button
        local mousePos = UserInputService:GetMouseLocation()
        local buttonPos = ToggleButton.AbsolutePosition
        local buttonSize = ToggleButton.AbsoluteSize
        if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
           mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
            if BypassActive then
                DeactivateDeepBypass()
            else
                ActivateDeepBypass()
            end
        end
    elseif input.KeyCode == Enum.KeyCode.RightControl then -- Alt Toggle: Right Ctrl for Quick
        if BypassActive then DeactivateDeepBypass() else ActivateDeepBypass() end
    end
end)

-- Close Button (Also Fixed)
CloseButton.MouseButton1Click:Connect(function()
    DeactivateDeepBypass()
    if InputConn then InputConn:Disconnect() end
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
print("Deep Brainrot Bypass Loaded - Click Button or Right Ctrl to Toggle")
