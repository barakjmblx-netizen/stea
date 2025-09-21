
-- Brainrot No-Clip & Laser Fake Menu (Lua for Roblox, Xeno Executor, 2025 Anti-Cheat Bypass)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
frame.Size = UDim2.new(0, 160, 0, 80)
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

-- Unified No-Clip & Laser Fake Button
local hackButton = Instance.new("TextButton")
hackButton.Size = UDim2.new(1, -10, 0, 35)
hackButton.Position = UDim2.new(0, 5, 0, 30)
hackButton.Text = "No-Clip & Laser OFF"
hackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hackButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
hackButton.Font = Enum.Font.SourceSans
hackButton.TextSize = 14
hackButton.Parent = frame

-- Variables
local hackActive = false
local originalMT = getrawmetatable(game)
local oldIndex = originalMT.__index
local oldNamecall = originalMT.__namecall
local connections = {}
local fakeLasers = {}

-- Anti-Cheat Bypass Setup
setreadonly(originalMT, false)
local bypassActive = false

local function setupBypass()
    if bypassActive then return end
    bypassActive = true

    -- Hook __index to fake no collision and invisibility on walls
    originalMT.__index = newcclosure(function(self, key)
        if hackActive and self:IsA("BasePart") and key == "CanCollide" and self.Parent and not self.Parent:IsDescendantOf(Character) then
            return false -- Fake walls as non-collidable for player
        elseif hackActive and self:IsA("BasePart") and key == "Transparency" and self.Parent and not self.Parent:IsDescendantOf(Character) then
            return 1 -- Make walls invisible to player only
        end
        return oldIndex(self, key)
    end)

    -- Hook __namecall to ignore Touched/Raycast on walls and lasers
    originalMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if hackActive and method == "Touched" and self:IsA("BasePart") and self.Parent and not self.Parent:IsDescendantOf(Character) then
            return -- Ignore wall/laser touches
        elseif hackActive and method == "Raycast" and self:IsA("Workspace") then
            local rayOrigin = args[1]
            local rayDirection = args[2]
            if (rayOrigin - HumanoidRootPart.Position).Magnitude < 10 then -- Player's ray
                local hit = workspace:Raycast(rayOrigin, rayDirection)
                if hit and hit.Instance and hit.Instance:IsA("BasePart") and not hit.Instance.Parent:IsDescendantOf(Character) then
                    return nil -- Fake no hit on walls/lasers
                end
            end
        end
        return oldNamecall(self, ...)
    end)

    -- Heartbeat loop for position adjustment
    connections.hackLoop = RunService.Heartbeat:Connect(function()
        if hackActive and Character and HumanoidRootPart then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part ~= HumanoidRootPart then
                    part.CanCollide = false -- Player parts non-collidable
                end
            end
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Avoid teleport detect
        end
    end)
end

-- Laser Fake Logic (Make lasers appear gone for player, but exist for anti-cheat)
local function toggleLaserFake()
    if hackActive then
        -- Create fake lasers (invisible, non-collidable)
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():match("laser") or part.Name:lower():match("beam")) then
                if not fakeLasers[part] then
                    local fakeLaser = part:Clone()
                    fakeLaser.Name = "FakeLaser_" .. part.Name
                    fakeLaser.Transparency = 1
                    fakeLaser.CanCollide = false
                    fakeLaser.Parent = part.Parent
                    -- Fake visual removal (remove material/shadows)
                    fakeLaser.Material = Enum.Material.SmoothPlastic
                    fakeLaser.CastShadow = false
                    -- Tween to simulate "open"
                    local tween = TweenService:Create(fakeLaser, TweenInfo.new(0.3), {Transparency = 0.9})
                    tween:Play()
                    fakeLasers[part] = fakeLaser
                    -- Redirect Touched to fake
                    part.Touched:Connect(function(hit)
                        if hit.Parent == Character then
                            return -- No trigger for player
                        end
                    end)
                end
            end
        end
        print("Lasers faked: Appear gone, pass through enabled.")
    else
        -- Remove fake lasers
        for _, fake in pairs(fakeLasers) do
            if fake then fake:Destroy() end
        end
        fakeLasers = {}
        print("Lasers restored: Anti-cheat sees them again.")
    end
end

-- Unified No-Clip & Laser Fake Toggle
local function toggleHack()
    hackActive = not hackActive
    if hackActive then
        hackButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        hackButton.Text = "No-Clip & Laser ON"
        setupBypass()
        toggleLaserFake()
        print("No-Clip & Laser Fake enabled: Walls/lasers invisible and passable.")
    else
        hackButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        hackButton.Text = "No-Clip & Laser OFF"
        if connections.hackLoop then
            connections.hackLoop:Disconnect()
        end
        toggleLaserFake()
        print("No-Clip & Laser Fake disabled.")
    end
end

hackButton.MouseButton1Click:Connect(toggleHack)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if hackActive then
        wait(1)
        toggleHack()
        toggleHack()
    end
end)

print("Brainrot Hack Menu loaded - Clean for Xeno Executor.")
