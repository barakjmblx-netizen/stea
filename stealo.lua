-- Brainrot Ultimate Bypass Menu (Steal a Brainrot, Xeno/Delta, 2025 Anti-Cheat Bypass)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotBypass"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Draggable Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 80)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(57, 255, 20) -- Neon green
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Brainrot Hack"
title.TextColor3 = Color3.fromRGB(57, 255, 20)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

-- Bypass Toggle Button (NoClip + Laser Fake)
local bypassButton = Instance.new("TextButton")
bypassButton.Size = UDim2.new(1, -10, 0, 35)
bypassButton.Position = UDim2.new(0, 5, 0, 30)
bypassButton.Text = "Bypass OFF"
bypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bypassButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
bypassButton.Font = Enum.Font.SourceSans
bypassButton.TextSize = 14
bypassButton.Parent = frame

-- Variables
local bypassActive = false
local originalMT = getrawmetatable(game)
local oldIndex = originalMT.__index
local oldNamecall = originalMT.__namecall
local connections = {}
local fakeLasers = {}
local bypassSetup = false

-- Anti-Detect Hooks (Bypass 2025 Anti-Cheat for Steal a Brainrot)
setreadonly(originalMT, false)

local function setupBypassHooks()
    if bypassSetup then return end
    bypassSetup = true
    
    -- Hook __index: Fake no walls/lasers for player (game sees no collision)
    originalMT.__index = newcclosure(function(self, key)
        if bypassActive and self:IsA("BasePart") and (key == "CanCollide" or key == "Transparency") and self.Parent and not self.Parent:IsDescendantOf(Character) and (self.Name:lower():find("wall") or self.Name:lower():find("laser") or self.Name:lower():find("barrier")) then
            return key == "CanCollide" and false or 1 -- Fake passable/invisible
        end
        return oldIndex(self, key)
    end)
    
    -- Hook __namecall: Ignore touches/raycasts on walls/lasers
    originalMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if bypassActive and method == "Touched" and self:IsA("BasePart") and (self.Name:lower():find("laser") or self.Name:lower():find("wall") or self.Name:lower():find("barrier")) and not self.Parent:IsDescendantOf(Character) then
            return -- Skip touches
        elseif bypassActive and method == "Raycast" and self:IsA("Workspace") then
            local rayOrigin = args[1]
            local rayDirection = args[2]
            if HumanoidRootPart and (rayOrigin - HumanoidRootPart.Position).Magnitude < 12 then
                local hit = workspace:Raycast(rayOrigin, rayDirection)
                if hit and hit.Instance and (hit.Instance.Name:lower():find("laser") or hit.Instance.Name:lower():find("wall") or hit.Instance.Name:lower():find("barrier")) then
                    return nil -- Fake no hit
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    
    -- Heartbeat: Subtle noclip + velocity spoof
    connections.bypassLoop = RunService.Heartbeat:Connect(function()
        if bypassActive and Character and HumanoidRootPart then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Player parts pass
                end
            end
            HumanoidRootPart.Velocity = Vector3.new(0, 30, 0) -- Spoof velocity for anti-teleport
        end
    end)
end

-- Laser Fake: Make lasers seem removed (visual + physical) for all, but stay in place
local function handleLaserFakes()
    if not bypassActive then
        for _, fake in pairs(fakeLasers) do
            if fake and fake.Parent then
                fake:Destroy()
            end
        end
        fakeLasers = {}
        return
    end
    
    -- Scan for lasers (Steal a Brainrot bases, adapt names if needed)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("laser") or obj.Name:lower():find("barrier") or obj.Name:lower():find("door")) and (obj:FindFirstChild("ParticleEmitter") or obj.Transparency < 1) then
            if not fakeLasers[obj] then
                -- Create fake laser: invisible, no collide
                local fake = obj:Clone()
                fake.Name = "Fake" .. obj.Name
                fake.Transparency = 1 -- Invisible to all
                fake.CanCollide = false -- Passable
                fake.Parent = obj.Parent
                fakeLasers[obj] = fake
                
                -- Tween for fake "remove" effect (visual deception)
                local tween = TweenService:Create(fake, TweenInfo.new(0.4), {Transparency = 1})
                tween:Play()
                
                -- Hook original touch: No trigger for player
                local oldTouchedConn
                oldTouchedConn = obj.Touched:Connect(function(hit)
                    if hit.Parent == Character then
                        return -- Player passes, no trigger
                    end
                end)
                
                -- Make original seem "removed" but present
                obj.Transparency = 1 -- Invisible to all
                obj.CanCollide = false -- Passable, but hooks hide from anticheat
                print("Laser fake for: " .. obj.Name .. " - Seems gone, pass free.")
            end
        end
    end
end

-- Single Toggle: NoClip + Laser Fake
local function toggleBypass()
    bypassActive = not bypassActive
    if bypassActive then
        bypassButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        bypassButton.Text = "Bypass ON"
        setupBypassHooks()
        handleLaserFakes()
        connections.laserScan = RunService.Heartbeat:Connect(handleLaserFakes) -- Continuous scan
        print("Bypass ON: Walls/Lasers seem gone for all, pass free.")
    else
        bypassButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        bypassButton.Text = "Bypass OFF"
        print("Bypass OFF: Normal mode restored.")
        if connections.bypassLoop then connections.bypassLoop:Disconnect() end
        if connections.laserScan then connections.laserScan:Disconnect() end
        handleLaserFakes() -- Cleanup
    end
end

bypassButton.MouseButton1Click:Connect(toggleBypass)

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    wait(1.5) -- Load wait
    if bypassActive then
        toggleBypass() -- Reapply
        toggleBypass()
    end
end)

-- Anti-Kick (Steal a Brainrot anticheat)
connections.antiKick = RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

print("Brainrot Bypass Menu loaded - Xeno/Delta ready, all-in-one bypass.")
