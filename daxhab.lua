--[[
✅ daxhab 最強98%突破対策版（Delta Executor対応 完全版）
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Player references
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Constants
local gravityBase = 196.2
local isProtected = false
local isWarping = false
local lastSafePos = hrp.Position
local warpFailCount = 0
local maxWarpFails = 7
local resetCooldown = false
local RESPAWN_COOLDOWN = 10
local WARP_INVULNERABLE_TIME = 6
local lastWarpTime = 0
local eventLastSent = {}
local MIN_SEND_INTERVAL = 0.08

-- GUI Init
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("daxhabProtectionGui") then
    playerGui.daxhabProtectionGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "daxhabProtectionGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 130)
frame.Position = UDim2.new(0.5, -120, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 1, 0)
frame.Parent = screenGui

-- Dragging
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- GUI Text
local title = Instance.new("TextLabel")
title.Text = "daxhab / 作者: dax"
title.Size = UDim2.new(1, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(0, 1, 0)
title.Font = Enum.Font.Code
title.TextScaled = true
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "保護状態: 未起動"
statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
statusLabel.Position = UDim2.new(0, 0, 0.2, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Code
statusLabel.TextScaled = true
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Text = "保護開始"
toggleBtn.Size = UDim2.new(1, 0, 0.4, 0)
toggleBtn.Position = UDim2.new(0, 0, 0.6, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.Code
toggleBtn.TextScaled = true
toggleBtn.Parent = frame

-- Warp offset patterns
local offsetPatterns = {
    Vector3.new(0,0,0), Vector3.new(0.5,0,0), Vector3.new(-0.5,0,0),
    Vector3.new(0,0,0.5), Vector3.new(0,0,-0.5),
    Vector3.new(1,0,1), Vector3.new(-1,0,-1),
    Vector3.new(0.3,0,0.3), Vector3.new(-0.3,0,-0.3),
    Vector3.new(0.7,0,-0.7), Vector3.new(-0.7,0,0.7),
}

local function CanWarpTo(pos)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local direction = (pos - hrp.Position)
    local result = Workspace:Raycast(hrp.Position, direction, rayParams)
    return not result
end

local function TryWarpStep(targetPos)
    for _,off in ipairs(offsetPatterns) do
        local altPos = targetPos + off
        if CanWarpTo(altPos) then
            local tween = TweenService:Create(hrp, TweenInfo.new(0.12), {CFrame = CFrame.new(altPos)})
            tween:Play()
            tween.Completed:Wait()
            hrp.Velocity = Vector3.zero
            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
            wait(0.1)
            return true
        end
    end
    return false
end

local function StrongWarp()
    if isWarping then return end
    isWarping = true
    local basePos = hrp.Position
    local totalMax = 120
    local step = 18
    local minStep = 5
    local height = 0
    warpFailCount = 0

    while height < totalMax do
        local nextPos = basePos + Vector3.new(0, height + step, 0)
        if TryWarpStep(nextPos) then
            height += step
            lastSafePos = hrp.Position
            warpFailCount = 0
            step = math.min(step + 2, 20)
            lastWarpTime = tick()
        else
            step = math.max(step - 6, minStep)
            warpFailCount += 1
            if warpFailCount >= maxWarpFails then
                hrp.CFrame = CFrame.new(lastSafePos)
                wait(0.7)
                break
            end
        end
    end

    local startTime = tick()
    while tick() - startTime < WARP_INVULNERABLE_TIME do
        RunService.Heartbeat:Wait()
    end

    isWarping = false
end

-- Protection logic
local protectionConn
local function StartProtection()
    if isProtected then return end
    isProtected = true
    statusLabel.Text = "保護状態: 起動中"
    toggleBtn.Text = "停止"

    protectionConn = RunService.Heartbeat:Connect(function()
        if hrp and hrp.Anchored then hrp.Anchored = false end
        if Workspace.Gravity ~= gravityBase then Workspace.Gravity = gravityBase end
        if hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
        if hum.JumpPower < 50 then hum.JumpPower = 50 end
        if hrp:IsDescendantOf(Workspace) then
            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        end

        if not isWarping and not resetCooldown then
            local now = tick()
            if (now - lastWarpTime) > WARP_INVULNERABLE_TIME then
                local dist = (hrp.Position - lastSafePos).Magnitude
                if dist > 90 then
                    hrp.CFrame = CFrame.new(lastSafePos)
                else
                    lastSafePos = hrp.Position
                end
            end
        end
    end)
end

local function StopProtection()
    if protectionConn then protectionConn:Disconnect() end
    isProtected = false
    statusLabel.Text = "保護状態: 停止中"
    toggleBtn.Text = "保護開始"
end

-- Button binds
toggleBtn.MouseButton1Click:Connect(function()
    if isProtected then StopProtection() else StartProtection() end
end)

hum.Died:Connect(function()
    if isProtected and not resetCooldown then
        resetCooldown = true
        wait(1)
        pcall(function() LocalPlayer:LoadCharacter() end)
        wait(RESPAWN_COOLDOWN)
        resetCooldown = false
    end
end)

print("✅ daxhab 最強版（Delta対応）起動完了")
