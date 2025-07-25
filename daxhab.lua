--[[
  daxhab ブレインロットを盗む向け
  超強力サーバー級ワープ＆保護スクリプト 完全版 v8
  作者: dax
  機能:
    - 高さ約90スタッド(15人分)の段階的ワープ
    - リセット回避＆自動復帰完全対応
    - ワープ禁止エリア無効化トグル
    - 透明化トグル
    - ネットワーク所有権奪取で位置補正
    - 滑らかなTweenワープ＆ワープ成功判定表示
    - GUIは流れる「daxhab.by.dax」虹色背景
    - 3つのトグルボタン（ワープ・透明化・禁止エリア無効）
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local char, hum, hrp
local isProtected = false
local isTransparent = false
local isBlockBypass = false

-- 初期化関数
local function InitCharacter()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrpPart = character:WaitForChild("HumanoidRootPart")
    return character, humanoid, hrpPart
end

char, hum, hrp = InitCharacter()

-- リセット自動復帰用フラグ
local resetDetected = false

-- 虹色取得関数
local function RainbowColor(t)
    local freq = 0.4
    local r = math.floor(math.sin(freq * t + 0) * 127 + 128)
    local g = math.floor(math.sin(freq * t + 2) * 127 + 128)
    local b = math.floor(math.sin(freq * t + 4) * 127 + 128)
    return Color3.fromRGB(r, g, b)
end

-- GUI作成
local function CreateGui()
    if CoreGui:FindFirstChild("daxhabGui") then
        CoreGui.daxhabGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "daxhabGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 120)
    Frame.Position = UDim2.new(0.5, -110, 0.8, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    -- 流れる虹色背景ラベル
    local bgLabel = Instance.new("TextLabel")
    bgLabel.Size = UDim2.new(3, 0, 1, 0)
    bgLabel.Position = UDim2.new(0, 0, 0, 0)
    bgLabel.BackgroundTransparency = 1
    bgLabel.Text = "daxhab.by.dax   daxhab.by.dax   daxhab.by.dax   "
    bgLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    bgLabel.Font = Enum.Font.Code
    bgLabel.TextScaled = true
    bgLabel.TextTransparency = 0.8
    bgLabel.ZIndex = 0
    bgLabel.Parent = Frame

    -- 状態ラベル
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 25)
    statusLabel.Position = UDim2.new(0, 5, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "状態: 未起動"
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextScaled = true
    statusLabel.ZIndex = 1
    statusLabel.Parent = Frame

    -- ボタン作成共通関数
    local function CreateButton(text, posY)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, posY)
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        btn.Font = Enum.Font.Code
        btn.TextScaled = true
        btn.Text = text
        btn.ZIndex = 1
        btn.Parent = Frame
        return btn
    end

    local warpBtn = CreateButton("ワープ", 35)
    local transBtn = CreateButton("透明化", 65)
    local bypassBtn = CreateButton("禁止エリア無効", 95)

    return ScreenGui, statusLabel, warpBtn, transBtn, bypassBtn, bgLabel
end

local ScreenGui, statusLabel, warpBtn, transBtn, bypassBtn, bgLabel = CreateGui()

-- 背景流れるアニメーション
spawn(function()
    local offset = 0
    while true do
        offset = offset - 2
        bgLabel.Position = UDim2.new(0, offset, 0, 0)
        if offset <= -bgLabel.AbsoluteSize.X / 3 then
            offset = 0
        end
        wait(0.03)
    end
end)

-- 虹色アニメーション
spawn(function()
    local t = 0
    while true do
        local c = RainbowColor(t)
        statusLabel.TextColor3 = c
        warpBtn.TextColor3 = c
        transBtn.TextColor3 = c
        bypassBtn.TextColor3 = c
        t = t + 0.1
        wait(0.03)
    end
end)

-- ネットワーク所有権強制奪取（2重ループ）
local function ForceNetworkOwnership()
    spawn(function()
        while isProtected do
            if hrp and hrp:IsDescendantOf(Workspace) then
                pcall(function()
                    hrp:SetNetworkOwner(LocalPlayer)
                end)
            end
            wait(0.1)
        end
    end)
    spawn(function()
        while isProtected do
            if hrp and hrp:IsDescendantOf(Workspace) then
                pcall(function()
                    hrp:SetNetworkOwner(LocalPlayer)
                end)
            end
            wait(0.1)
        end
    end)
end

-- 透明化処理
local function SetTransparency(enable)
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = enable and 0.7 or 0
            part.CanCollide = not enable
        elseif part:IsA("Decal") then
            part.Transparency = enable and 0.7 or 0
        end
    end
end

-- ワープ禁止エリア判定（Y座標1未満は禁止）
local function IsInWarpBlockZone(pos)
    if pos.Y < 1 then return true end
    -- 追加禁止エリア判定ここに
    return false
end

-- Tweenを分割して自然に滑らかに上昇させるワープ
local function SmoothWarpUp(totalHeight, stepHeight, stepDuration)
    if not hrp or not char then return false end

    local currentPos = hrp.Position
    local targetPos = currentPos + Vector3.new(0, totalHeight, 0)

    if not isBlockBypass and IsInWarpBlockZone(targetPos) then
        return false, "禁止エリアです"
    end

    local steps = math.ceil(totalHeight / stepHeight)
    for i = 1, steps do
        local intermediatePos = currentPos + Vector3.new(0, stepHeight * i, 0)
        local tweenInfo = TweenInfo.new(stepDuration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(intermediatePos)})
        tween:Play()
        tween.Completed:Wait()
        wait(0.05)
    end

    return true, "ワープ成功"
end

-- 強力リセット監視＆自動復帰
local function SetupResetProtection()
    if hum then
        hum.Died:Connect(function()
            wait(0.3)
            if isProtected and (not LocalPlayer.Character or not LocalPlayer.Character.Parent) then
                resetDetected = true
                LocalPlayer:LoadCharacter()
            end
        end)
    end
    LocalPlayer.CharacterRemoving:Connect(function()
        resetDetected = true
    end)
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(0.1)
        char, hum, hrp = InitCharacter()
        if isProtected then
            ForceNetworkOwnership()
            SetTransparency(isTransparent)
        end
        resetDetected = false
    end)
    spawn(function()
        while true do
            wait(1)
            if resetDetected and isProtected then
                resetDetected = false
                pcall(function() LocalPlayer:LoadCharacter() end)
            end
        end
    end)
end

-- GUI自己復旧監視
local function SelfRecoveryWatcher(ScreenGui)
    spawn(function()
        while true do
            wait(1.5)
            if not isProtected then
                StartProtection()
            end
            if not ScreenGui.Parent then
                ScreenGui.Parent = CoreGui
            end
        end
    end)
end

-- ワープ実行
local function WarpUp()
    local success, msg = SmoothWarpUp(90, 5, 0.1) -- 90スタッドを5スタッドずつ0.1秒で移動
    statusLabel.Text = msg
end

-- 保護開始・停止
function StartProtection()
    if isProtected then return end
    isProtected = true
    statusLabel.Text = "状態: 起動中"
    ForceNetworkOwnership()
    SetupResetProtection()
    SelfRecoveryWatcher(ScreenGui)
end

function StopProtection()
    if not isProtected then return end
    isProtected = false
    statusLabel.Text = "状態: 停止中"
    SetTransparency(false)
end

-- ボタン操作
warpBtn.MouseButton1Click:Connect(function()
    if not isProtected then return end
    WarpUp()
end)

transBtn.MouseButton1Click:Connect(function()
    if not isProtected then return end
    isTransparent = not isTransparent
    SetTransparency(isTransparent)
    statusLabel.Text = isTransparent and "透明化ON" or "透明化OFF"
end)

bypassBtn.MouseButton1Click:Connect(function()
    if not isProtected then return end
    isBlockBypass = not isBlockBypass
    statusLabel.Text = isBlockBypass and "禁止エリア無効ON" or "禁止エリア無効OFF"
end)

-- 自動起動
StartProtection()

print("✅ daxhab 超強力サーバー級ワープ＆保護 完全版 v8 起動完了 by dax")
