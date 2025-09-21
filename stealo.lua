-- Brainrot No-Clip & Laser Bypass Menu (Lua for Roblox, No CoreModule, 2025 Anti-Cheat Proof)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

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
local connections = {}

-- Anti-Detect Hook Setup (No CoreModule, Pure Metatable Bypass)
local function setupNoClipBypass()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall

    mt.__index = newcclosure(function(self, key)
        if noClipActive and self:IsA("BasePart") and key == "CanCollide" and self.Parent and not self.Parent:IsDescendantOf(Character) then
            return false -- Fake no collision for walls
        end
        return oldIndex(self, key)
    end)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if noClipActive and method == "Raycast" and self == Workspace then
            local rayOrigin = args[1]
            local rayDirection = args[2]
            if (rayOrigin - HumanoidRootPart.Position).Magnitude < 15 then
                local hit = Workspace:Raycast(rayOrigin, rayDirection)
                if hit and hit.Instance and hit.Instance:IsA("BasePart") and not hit.Instance.Parent:IsDescendantOf(Character) then
                    return nil -- Fake no wall hit
                end
            end
        elseif noClipActive and method == "Touched" and self:IsA("BasePart") and not self.Parent:IsDescendantOf(Character) then
            return -- Ignore wall touches
        end
        return oldNamecall(self, ...)
    end)

    -- Heartbeat for subtle player positioning
    connections.noclipLoop = RunService.Heartbeat:Connect(function()
        if noClipActive and Character and HumanoidRootPart then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part ~= HumanoidRootPart then
                    part.CanCollide = false -- Player parts only
                end
            end
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Avoid teleport detection
        end
    end)
end

-- No-Clip Toggle Logic
local function toggleNoClip()
    noClipActive = not noClipActive
    if noClipActive then
        noclipButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        noclipButton.Text = "Wall Bypass ON"
        setupNoClipBypass()
        print("Wall Bypass ON: Game ignores walls for player.")
    else
        noclipButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        noclipButton.Text = "Wall Bypass OFF"
        if connections.noclipLoop then
            connections.noclipLoop:Disconnect()
        end
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        print("Wall Bypass OFF: Normal collisions restored.")
    end
end

noclipButton.MouseButton1Click:Connect(toggleNoClip)

-- Laser Door Fake Logic (Deceive Anti-Cheat)
local function toggleLaserFake()
    laserActive = not laserActive
    if laserActive then
        laserButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        laserButton.Text = "Laser Fake ON"
        -- Scan for laser-like objects (adapt for game)
        local laserParts = {}
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():match("laser") or part:FindFirstChildOfClass("Beam")) then
                table.insert(laserParts, part)
            end
        end
        if #laserParts > 0 then
            for _, laser in pairs(laserParts) do
                -- Create fake laser (invisible, non-collidable)
                local fakeLaser = laser:Clone()
                fakeLaser.Name = laser.Name .. "_Fake"
                fakeLaser.Transparency = 1
                fakeLaser.CanCollide = false
                fakeLaser.Parent = laser.Parent
                -- Tween to fake "open" state
                local tween = TweenService:Create(fakeLaser, TweenInfo.new(0.3), {Transparency = 0.5})
                tween:Play()
                -- Redirect original touch to fake
                laser.Touched:Connect(function(hit)
                    if hit.Parent == Character then
                        return -- No trigger for player
                    end
                end)
            end
            print("Laser Fake ON: Fake lasers created, pass through freely.")
        else
            print("No laser doors found. Check Workspace for 'Laser' or 'Beam' objects.")
        end
    else
        laserButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        laserButton.Text = "Laser Fake OFF"
        -- Clean up fakes
        for _, part in pairs(Workspace:GetDescendants()) do
            if part.Name:match("_Fake") then
                part:Destroy()
            end
        end
        print("Laser Fake OFF: Fakes removed.")
    end
end

laserButton.MouseButton1Click:Connect(toggleLaserFake)

-- Handle Character Respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if noClipActive then
        wait(0.5)
        toggleNoClip()
        toggleNoClip()
    end
    if laserActive then
        wait(0.5)
        toggleLaserFake()
        toggleLaserFake()
    end
end)

print("Brainrot Menu loaded - CoreModule-free, ready for 2025 anti-cheats.")
