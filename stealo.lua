-- Brainrot No-Clip & Laser Bypass Menu (Lua for Roblox, 2025 Bypass Edition)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Draggable Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 120)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(57, 255, 20) -- Neon green
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Brainrot Hacks"
title.TextColor3 = Color3.fromRGB(57, 255, 20)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

-- No-Clip Toggle Button
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1, -10, 0, 35)
noclipButton.Position = UDim2.new(0, 5, 0, 30)
noclipButton.Text = "Wall Bypass OFF"
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
noclipButton.Font = Enum.Font.SourceSans
noclipButton.TextSize = 14
noclipButton.Parent = frame

-- Laser Door Bypass Button
local laserButton = Instance.new("TextButton")
laserButton.Size = UDim2.new(1, -10, 0, 35)
laserButton.Position = UDim2.new(0, 5, 0, 70)
laserButton.Text = "Laser Fake OFF"
laserButton.TextColor3 = Color3.fromRGB(255, 255, 255)
laserButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
laserButton.Font = Enum.Font.SourceSans
laserButton.TextSize = 14
laserButton.Parent = frame

-- Variables
local noClipActive = false
local laserActive = false
local originalMT = getrawmetatable(game)
local oldIndex = originalMT.__index
local oldNamecall = originalMT.__namecall
local connections = {}

-- Anti-Detect Hook Setup (Bypass for 2025 Anti-Cheats)
setreadonly(originalMT, false)
local bypassActive = false

local function setupBypass()
    if bypassActive then return end
    bypassActive = true
    
    -- Hook __index to fake no collision on walls (game thinks walls don't exist for player)
    originalMT.__index = newcclosure(function(self, key)
        if noClipActive and self:IsA("BasePart") and key == "CanCollide" and self.Parent and self.Parent:FindFirstChildOfClass("Model") and not self.Parent:IsDescendantOf(Character) then
            return false -- Fake walls as non-collidable for detection
        end
        return oldIndex(self, key)
    end)
    
    -- Hook __namecall to ignore Touched/Raycast on walls for player
    originalMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if noClipActive and method == "Touched" and self:IsA("BasePart") and self.Parent and not self.Parent:IsDescendantOf(Character) then
            return -- Ignore wall touches
        elseif noClipActive and method == "Raycast" and self:IsA("Workspace") then
            local rayOrigin = args[1]
            local rayDirection = args[2]
            if (rayOrigin - HumanoidRootPart.Position).Magnitude < 10 then -- Player's ray
                local hit = workspace:Raycast(rayOrigin, rayDirection)
                if hit and hit.Instance and hit.Instance:IsA("BasePart") and hit.Instance.CanCollide and not hit.Instance.Parent:IsDescendantOf(Character) then
                    return nil -- Fake no hit on walls
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    
    -- RunService loop for subtle position adjustment (no CanCollide change)
    connections.noclipLoop = RunService.Heartbeat:Connect(function()
        if noClipActive and Character and HumanoidRootPart then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part ~= HumanoidRootPart then
                    part.CanCollide = false -- Only player parts, subtle
                end
            end
            -- Fake velocity to bypass teleport detects
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- No-Clip Toggle Logic
local function toggleNoClip()
    noClipActive = not noClipActive
    if noClipActive then
        noclipButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        noclipButton.Text = "Wall Bypass ON"
        setupBypass()
        print("Wall Bypass enabled: Game thinks no walls exist.")
    else
        noclipButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        noclipButton.Text = "Wall Bypass OFF"
        print("Wall Bypass disabled.")
        -- Cleanup loop if needed
        if connections.noclipLoop then
            connections.noclipLoop:Disconnect()
        end
    end
end

noclipButton.MouseButton1Click:Connect(toggleNoClip)

-- Laser Door Fake Open Logic (Deception: Fake open for anticheat, pass through fake)
local function toggleLaserFake()
    laserActive = not laserActive
    if laserActive then
        laserButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        laserButton.Text = "Laser Fake ON"
        -- Find laser door (assume named "LaserDoor" or scan for Beam/Part with Touch)
        local laserDoor = workspace:FindFirstChild("LaserDoor") or workspace:FindFirstChildOfClass("Part"):FindFirstChild("Beam") -- Adapt to game
        if laserDoor then
            -- Create fake clone: invisible, non-collide, but anticheat sees "open"
            local fakeLaser = laserDoor:Clone()
            fakeLaser.Name = "FakeLaser"
            fakeLaser.Transparency = 1
            fakeLaser.CanCollide = false
            fakeLaser.Parent = laserDoor.Parent
            -- Tween fake to simulate open (deceive checks)
            local tween = TweenService:Create(fakeLaser, TweenInfo.new(0.5), {Transparency = 0.5})
            tween:Play()
            -- Hook Touched on original to redirect to fake (pass through without trigger)
            local oldTouched = laserDoor.Touched
            laserDoor.Touched:Connect(function(hit)
                if hit.Parent == Character then
                    -- Fake no damage/trigger
                    return
                end
                if oldTouched then oldTouched(hit) end
            end)
            print("Laser Fake enabled: Door 'open' for anticheat, pass free.")
        else
            print("No laser door found - scan workspace for 'Laser' parts.")
        end
    else
        laserButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        laserButton.Text = "Laser Fake OFF"
        -- Remove fakes
        local fake = workspace:FindFirstChild("FakeLaser")
        if fake then fake:Destroy() end
        print("Laser Fake disabled.")
    end
end

laserButton.MouseButton1Click:Connect(toggleLaserFake)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if noClipActive then
        wait(1) -- Wait for full load
        toggleNoClip() -- Re-enable
        toggleNoClip()
    end
    if laserActive then
        toggleLaserFake() -- Re-fake
        toggleLaserFake()
    end
end)

print("Brainrot Menu loaded - Bypass ready for 2025 anti-cheats.")
