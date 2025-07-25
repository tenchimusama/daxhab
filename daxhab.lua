local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")

local State = {
    WarpInProgress = false,
    HealthMonitorConn = nil,
}

-- ネットワーク所有権をクライアントに強制付与
local function claimNetworkOwnership()
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part:SetNetworkOwner(player)
        end
    end
end

-- 衝突無効化＆重量軽減で補正抑制
local function disableCollision(enable)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
            part.Massless = enable
            part.Transparency = enable and 0.4 or 0
        end
    end
end

-- Tweenで滑らかにワープ
local function tweenWarp(targetPos, duration)
    duration = duration or 0.15
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(rootPart, tweenInfo, {Position = targetPos})
    tween:Play()
    tween.Completed:Wait()
end

-- Health変化を監視し、死亡やリセットを99%防ぐ
local function preventReset()
    if State.HealthMonitorConn then State.HealthMonitorConn:Disconnect() end
    State.HealthMonitorConn = humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            humanoid.Health = 1
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- 乱数を使って微妙に座標をずらす（対策強化用）
local function jitterPosition(pos, maxOffset)
    maxOffset = maxOffset or 0.2
    local offsetX = (math.random() - 0.5) * 2 * maxOffset
    local offsetZ = (math.random() - 0.5) * 2 * maxOffset
    return Vector3.new(pos.X + offsetX, pos.Y, pos.Z + offsetZ)
end

-- 多段階ワープ＋ランダム遅延＋座標ジッター
local function advancedWarp(height, steps)
    if State.WarpInProgress then return end
    State.WarpInProgress = true

    claimNetworkOwnership()
    disableCollision(true)
    preventReset()

    local startPos = rootPart.Position
    local targetPos = startPos + Vector3.new(0, height, 0)
    local steps = steps or 10

    for i = 1, steps do
        local lerpPos = startPos:Lerp(targetPos, i / steps)
        local jitteredPos = jitterPosition(lerpPos, 0.15) -- 微妙にズラす
        tweenWarp(jitteredPos, 0.12)
        wait(0.05 + math.random() * 0.07) -- ランダム遅延
    end

    disableCollision(false)
    State.WarpInProgress = false
end

-- リセット・補正時のキャラ再取得＆再設定
RunService.Heartbeat:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        character = player.Character or player.CharacterAdded:Wait()
        rootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
        preventReset()
        claimNetworkOwnership()
    end
end)

-- 使い方：15人分の高さ(3.5*15=52.5)を10段階でワープ
advancedWarp(3.5 * 15, 10)
