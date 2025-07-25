-- ✅ 最強版 Roblox 保護・透明化・ワープスクリプト by dax（強化修正版）
-- 第1部：初期化・GUI・保護状態管理・透明化ロジック

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local character = nil
local humanoid = nil
local hrp = nil
local protectionEnabled = false
local transparent = false

-- キャラクター取得関数
local function GetCharacter()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end

-- GUI構築関数
local function CreateGui()
    if CoreGui:FindFirstChild("daxSecureGui") then
        CoreGui.daxSecureGui:Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "daxSecureGui"
    gui.ResetOnSpawn = false

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

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(1, 0, 0.25, 0)
    toggleBtn.Position = UDim2.new(0, 0, 0.25, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.Code
    toggleBtn.TextScaled = true
    toggleBtn.Text = "保護開始"

    local warpBtn = Instance.new("TextButton", frame)
    warpBtn.Size = UDim2.new(1, 0, 0.25, 0)
    warpBtn.Position = UDim2.new(0, 0, 0.5, 0)
    warpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    warpBtn.TextColor3 = Color3.new(1, 1, 1)
    warpBtn.Font = Enum.Font.Code
    warpBtn.TextScaled = true
    warpBtn.Text = "ワープ"

    local invisBtn = Instance.new("TextButton", frame)
    invisBtn.Size = UDim2.new(1, 0, 0.25, 0)
    invisBtn.Position = UDim2.new(0, 0, 0.75, 0)
    invisBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    invisBtn.TextColor3 = Color3.new(1, 1, 1)
    invisBtn.Font = Enum.Font.Code
    invisBtn.TextScaled = true
    invisBtn.Text = "透明化: OFF"

    return gui, statusLabel, toggleBtn, warpBtn, invisBtn
end

-- 透明化トグル
local function ToggleTransparency()
    if not character then return end
    transparent = not transparent
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = transparent and 1 or 0
            part.CanCollide = not transparent
        elseif part:IsA("Decal") or part:IsA("BillboardGui") then
            part.Enabled = not transparent
        end
    end
end

-- 保護機能（後続で定義）に続く...
--============================
-- 🔒 保護機能（物理プロパティの修復）
--============================

local function MaintainHumanoidRootPart()
    spawn(function()
        while true do
            if not isProtected or not hrp then wait(0.1) continue end
            pcall(function()
                if hrp.Anchored then hrp.Anchored = false end
                if hrp.Transparency > 0.5 then hrp.Transparency = 0 end
                if hrp.Size.Magnitude < 1 then hrp.Size = Vector3.new(2, 2, 1) end
                if hrp.CanCollide == false then hrp.CanCollide = true end
            end)
            wait(0.1)
        end
    end)
end

--============================
-- 💥 死亡復旧・キャラリセット対策
--============================

local function WatchDeath()
    spawn(function()
        while true do
            if not isProtected then wait(1) continue end
            if hum and hum.Health <= 0 then
                warn("死亡検知 → 再生成します")
                repeat
                    LocalPlayer:LoadCharacter()
                    wait(1)
                until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                char = LocalPlayer.Character
                hum = char:FindFirstChildOfClass("Humanoid")
                hrp = char:FindFirstChild("HumanoidRootPart")
                TransparentIfEnabled()
            end
            wait(1)
        end
    end)
end

--============================
-- 🌀 ワープ機能（安全補間ワープ）
--============================

local function SafeWarp(offset)
    if not hrp then return end
    local targetPos = hrp.Position + Vector3.new(0, offset, 0)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
end

--============================
-- ♻️ 自己復元・GUI再配置・状態監視
--============================

spawn(function()
    while true do
        wait(2)
        if not gui or not gui.Parent then
            gui = CreateGui()
            ConnectButtons()
        end
        if isProtected and not char or not hum or not hrp then
            char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            hum = char:FindFirstChildWhichIsA("Humanoid")
            hrp = char:FindFirstChild("HumanoidRootPart")
        end
    end
end)
--============================
-- 🔘 GUIボタン接続と状態切替
--============================

function StartProtection()
    if isProtected then return end
    isProtected = true
    StatusLabel.Text = "🟢 保護中"
    StartBtn.Text = "保護停止"

    MaintainHumanoidRootPart()
    WatchDeath()
end

function StopProtection()
    if not isProtected then return end
    isProtected = false
    StatusLabel.Text = "🔴 停止中"
    StartBtn.Text = "保護開始"
end

function ConnectButtons()
    StartBtn.MouseButton1Click:Connect(function()
        if isProtected then
            StopProtection()
        else
            StartProtection()
        end
    end)

    ToggleTransparency.MouseButton1Click:Connect(function()
        if isTransparent then
            isTransparent = false
            if hrp then hrp.Transparency = 0 end
            ToggleTransparency.Text = "透明化：OFF"
        else
            isTransparent = true
            if hrp then hrp.Transparency = 1 end
            ToggleTransparency.Text = "透明化：ON"
        end
    end)

    WarpBtn.MouseButton1Click:Connect(function()
        SafeWarp(40)
    end)
end

--============================
-- 🚀 起動時自動開始
--============================

ConnectButtons()
StartProtection()

print("✅ daxhab強化版プロテクトスクリプト（完全修正版）起動完了")
