-- Brainrot Bypass Menu (Steal a Brainrot - NoClip + Laser Fake, 2025 Xeno Compatible)
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
screenGui.Name = "BrainrotBypass"
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
title.Text = "Brainrot Bypass"
title.TextColor3 = Color3.fromRGB(57, 255, 20)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

-- Single Bypass Toggle Button (NoClip + Laser Fake Combined)
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
local fakeLasers = {} -- Track fakes for cleanup

-- Anti-Detect Hook Setup (From 2025 Brainrot/Doors bypasses)
setreadonly(originalMT, false)
local bypassSetup = false

local function setupBypassHooks()
    if bypassSetup then return end
    bypassSetup = true
    
    -- Hook __index: Fake no walls for player rays/touches (game thinks no collision)
    originalMT.__index = newcclosure(function(self, key)
        if bypassActive and self:IsA("BasePart") and (key == "CanCollide" or key == "Transparency") and self.Parent and not self.Parent:IsDescendantOf(Character) and self.Name:find("Wall") or self.Name:find("Barrier") then
            return false -- Fake walls/doors as passable/non-existent
        end
        return oldIndex(self, key)
    end)
    
    -- Hook __namecall: Ignore touches/raycasts on walls/lasers for player (bypass anticheat detection)
    originalMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if bypassActive and method == "Touched" and self:IsA("BasePart") and (self.Name:find("Laser") or self.Name:find("Wall")) and not self.Parent:IsDescendantOf(Character) then
            return -- Ignore touches on lasers/walls
        elseif bypassActive and method == "Raycast" and self:IsA("Workspace") then
            local rayOrigin = args[1]
            local rayDirection = args[2]
            if HumanoidRootPart and (rayOrigin - HumanoidRootPart.Position).Magnitude < 15 then -- Player near
                local hit = workspace:Raycast(rayOrigin, rayDirection)
                if hit and hit.Instance and (hit.Instance.Name:find("Laser") or hit.Instance.Name:find("Wall")) then
                    return nil -- Fake no hit on lasers/walls
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    
    -- Heartbeat loop: Subtle noclip for player + velocity fake (no direct CanCollide on walls)
    connections.bypassLoop = RunService.Heartbeat:Connect(function()
        if bypassActive and Character and HumanoidRootPart then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Player parts no collide
                end
            end
            HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) -- Fake subtle up velocity to bypass teleport checks
        end
    end)
end

-- Laser Fake Function: Make lasers seem removed (visually + physically) for all, but pass through
local function handleLaserFakes()
    if not bypassActive then
        -- Cleanup fakes
        for _, fake in pairs(fakeLasers) do
            if fake and fake.Parent then
                fake:Destroy()
            end
        end
        fakeLasers = {}
        return
    end
    
    -- Scan for lasers (adapt names: Laser, LaserDoor, Barrier in Steal a Brainrot bases)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("laser") or obj.Name:lower():find("barrier") or obj.Name:lower():find("door")) and obj:FindFirstChild("ParticleEmitter") then -- Laser-like with emitter
            if not fakeLasers[obj] then
                -- Create fake: Invisible, no collide, but positioned same for pass-through
                local fake = obj:Clone()
                fake.Name = "Fake" .. obj.Name
                fake.Transparency = 1 -- Invisible to all (visual fake removed)
                fake.CanCollide = false -- Physical pass for player
                fake.Parent = obj.Parent
                fakeLasers[obj] = fake
                
                -- Tween to "remove" effect (fade out illusion)
                local tween = TweenService:Create(fake, TweenInfo.new(0.3), {Transparency = 0}) -- But stays 1
                tween:Play()
                
                -- Hook original Touched: Fake "open/removed" for server/anticheat (no trigger)
                local oldTouchedConn
                oldTouchedConn = obj.Touched:Connect(function(hit)
                    if hit.Parent == Character then
                        return -- Player passes free, no damage/trigger
                    end
                    -- For others, normal behavior
                end)
                
                -- Disable original visual/physical subtly
                obj.Transparency = 1 -- Visual fake removed for all
                obj.CanCollide = false -- Physical fake removed, but hooks prevent detection
                
                print("Laser fake applied to: " .. obj.Name .. " - Seems removed, pass free.")
            end
        end
    end
end

-- Single Toggle Logic (All in One: NoClip + Lasers)
local function toggleBypass()
    bypassActive = not bypassActive
    if bypassActive then
        bypassButton.BackgroundColor3 = Color3.fromRGB(57, 255, 20) -- Green on
        bypassButton.Text = "Bypass ON"
        setupBypassHooks()
        handleLaserFakes() -- Initial scan
        connections.laserScan = RunService.Heartbeat:Connect(handleLaserFakes) -- Continuous for new lasers
        print("Bypass enabled: NoClip + Laser Fakes active. Walls/lasers seem gone.")
    else
        bypassButton.BackgroundColor3 = Color3.fromRGB(255, 7, 58) -- Red off
        bypassButton.Text = "Bypass OFF"
        print("Bypass disabled.")
        -- Cleanup
        if connections.bypassLoop then connections.bypassLoop:Disconnect() end
        if connections.laserScan then connections.laserScan:Disconnect() end
        handleLaserFakes() -- Remove fakes
    end
end

bypassButton.MouseButton1Click:Connect(toggleBypass)

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    wait(2) -- Load time
    if bypassActive then
        toggleBypass() -- Off/on to reapply
        toggleBypass()
    end
end)

-- Anti-Kick from Brainrot Scripts (Extra layer)
connections.antiKick = RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth -- Fake health to bypass kicks
    end
end)

print("Brainrot Bypass Menu loaded - Xeno ready, all in one button.")
