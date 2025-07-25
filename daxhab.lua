-- ✅ 最強版 Roblox 保護・透明化・ワープスクリプト by dax（強化修正版）

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local char = nil
local hum = nil
local hrp = nil

local isProtected = false
local isTransparent = false

local gui, StatusLabel, StartBtn, WarpBtn, TransparencyBtn

-- キャラクター初期化関数
local function InitializeCharacter()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end

-- 透明化処理
local function ApplyTransparency(enabled)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = enabled and 1 or 0
            part.CanCollide = not enabled
        elseif part:IsA("Decal") or part:IsA("BillboardGui") then
            part.Enabled = not enabled
        end
    end
end

-- GUI生成関数
local function CreateGui()
    if CoreGui:FindFirstChild("daxSecureGui") then
        CoreGui.daxSecureGui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "daxSecureGui"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 240, 0, 160)
    frame.Position = UDim2.new(0.5, -120, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Active = true
    frame.Draggable = true

    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.Size = UDim2.new(1, 0, 0.25, 0)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextScaled = true
    statusLabel.Text = "保護: 無効"

    local startBtn = Instance.new("TextButton", frame)
    startBtn.Size = UDim2.new(1, 0, 0.25, 0)
    startBtn.Position = UDim2.new(0, 0, 0.25, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.Font = Enum.Font.Code
    startBtn.TextScaled = true
    startBtn.Text = "保護開始"

    local warpBtn = Instance.new("TextButton", frame)
    warpBtn.Size = UDim2.new(1, 0, 0.25, 0)
    warpBtn.Position = UDim2.new(0, 0, 0.5, 0)
    warpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    warpBtn.TextColor3 = Color3.new(1, 1, 1)
    warpBtn.Font = Enum.Font.Code
    warpBtn.TextScaled = true
    warpBtn.Text = "ワープ"

    local transparencyBtn = Instance.new("TextButton", frame)
    transparencyBtn.Size = UDim2.new(1, 0, 0.25, 0)
    transparencyBtn.Position = UDim2.new(0, 0, 0.75, 0)
    transparencyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    transparencyBtn.TextColor3 = Color3.new(1, 1, 1)
    transparencyBtn.Font = Enum.Font.Code
    transparencyBtn.TextScaled = true
    transparencyBtn.Text = "透明化: OFF"

    return gui, statusLabel, startBtn, warpBtn, transparencyBtn
end

-- 保護状態維持（HumanoidRootPartのプロパティ修復）
local function MaintainHumanoidRootPart()
    spawn(function()
        while isProtected do
            if hrp then
                pcall(function()
                    if hrp.Anchored then hrp.Anchored = false end
                    if hrp.Transparency > 0.5 then hrp.Transparency = 0 end
                    if hrp.Size.Magnitude < 1 then hrp.Size = Vector3.new(2, 2, 1) end
                    if hrp.CanCollide == false then hrp.CanCollide = true end
                end)
            end
            wait(0.1)
        end
    end)
end

-- 死亡検知と復活処理
local function WatchDeath()
    spawn(function()
        while isProtected do
            if hum and hum.Health <= 0 then
                warn("死亡検知 → 再生成します")
                repeat
                    LocalPlayer:LoadCharacter()
                    wait(1)
                until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                InitializeCharacter()
                ApplyTransparency(isTransparent)
            end
            wait(1)
        end
    end)
end

-- 安全なワープ（上方向にoffset分）
local function SafeWarp(offset)
    if not hrp then return end
    local targetPos = hrp.Position + Vector3.new(0, offset, 0)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
end

-- GUIボタン接続
local function ConnectButtons()
    StartBtn.MouseButton1Click:Connect(function()
        if isProtected then
            isProtected = false
            StatusLabel.Text = "🔴 停止中"
            StartBtn.Text = "保護開始"
        else
            isProtected = true
            StatusLabel.Text = "🟢 保護中"
            StartBtn.Text = "保護停止"
            MaintainHumanoidRootPart()
            WatchDeath()
        end
    end)

    TransparencyBtn.MouseButton1Click:Connect(function()
        isTransparent = not isTransparent
        ApplyTransparency(isTransparent)
        TransparencyBtn.Text = isTransparent and "透明化: ON" or "透明化: OFF"
    end)

    WarpBtn.MouseButton1Click:Connect(function()
        SafeWarp(40)
    end)
end

-- メイン処理

InitializeCharacter()

gui, StatusLabel, StartBtn, WarpBtn, TransparencyBtn = CreateGui()

ConnectButtons()

-- 起動時は保護ON
isProtected = true
StatusLabel.Text = "🟢 保護中"
StartBtn.Text = "保護停止"

MaintainHumanoidRootPart()
WatchDeath()

print("✅ daxhab強化版プロテクトスクリプト（完全修正版）起動完了")
