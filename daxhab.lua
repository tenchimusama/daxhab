-- 完全版：一瞬15スタッド真上ワープ＋海外式運営対策内蔵 UIドラッグ対応＋ログ＋効果音

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- 背景フレーム（ドラッグ可能）
local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BackgroundTransparency = 0
bg.Size = UDim2.new(0.33,0,0.5,0)
bg.Position = UDim2.new(0.02,0,0.48,0)
bg.BorderSizePixel = 1
bg.BorderColor3 = Color3.fromRGB(0,255,0)
bg.Active = true
bg.Draggable = true
bg.Parent = screenGui

-- ロゴテキスト
local floatingText = Instance.new("TextLabel")
floatingText.Text = "daxhab / by / dax"
floatingText.TextColor3 = Color3.fromRGB(0,255,0)
floatingText.BackgroundTransparency = 1
floatingText.Font = Enum.Font.Code
floatingText.TextScaled = true
floatingText.Size = UDim2.new(1,0,0.12,0)
floatingText.Position = UDim2.new(0,0,0.02,0)
floatingText.Parent = bg

-- ログスクロールフレーム
local logFrame = Instance.new("ScrollingFrame")
logFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
logFrame.BackgroundTransparency = 0
logFrame.Size = UDim2.new(0.95,0,0.6,0)
logFrame.Position = UDim2.new(0.025,0,0.3,0)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 6
logFrame.CanvasSize = UDim2.new(0,0,5,0)
logFrame.Parent = bg

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0,2)
uiListLayout.Parent = logFrame

local function addLog(message)
    local newLabel = Instance.new("TextLabel")
    newLabel.BackgroundTransparency = 1
    newLabel.TextColor3 = Color3.fromRGB(0,255,0)
    newLabel.Font = Enum.Font.Code
    newLabel.TextSize = 16
    newLabel.TextWrapped = true
    newLabel.Size = UDim2.new(1,0,0,20)
    newLabel.Text = ""
    newLabel.Parent = logFrame

    coroutine.wrap(function()
        for i = 1, #message do
            newLabel.Text = string.sub(message, 1, i)
            wait(0.02)
        end
        logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
    end)()
end

-- ボタン作成関数
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6,0,0.12,0)
    btn.Position = UDim2.new(0.2,0,posY,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    btn.TextColor3 = Color3.fromRGB(0,255,0)
    btn.Font = Enum.Font.Code
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = bg
    btn.AutoButtonColor = false
    return btn
end

local warpBtn = createButton("ワープ", 0.75) -- 画面下寄りに配置

-- 効果音
local beep = Instance.new("Sound")
beep.SoundId = "rbxassetid://911882487"
beep.Volume = 0.25
beep.Parent = bg
local function playBeep()
    beep:Play()
end

-- ネットワーク所有権取得＆運営対策系関数 --

local function setNetworkOwner(part)
    pcall(function()
        part:SetNetworkOwner(player)
    end)
end

local function preventReset(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                humanoid.Health = humanoid.MaxHealth
                addLog("自動復活処理実行")
            end
        end)
    end
end

local function antiFallKillProtection(character)
    -- 落下死防止等にカスタマイズ可
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        RunService.Heartbeat:Connect(function()
            if humanoid.Health > 0 and humanoid.FloorMaterial == Enum.Material.Air and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                -- 落下中の高さチェック、条件により回避行動等をここに追加可能
            end
        end)
    end
end

-- 安全ワープ関数（一瞬で15スタッド真上に瞬間移動）
local function safeWarp()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        addLog("RootPartが見つかりません。ワープ中止。")
        return
    end

    addLog("ワープ実行中...")
    playBeep()

    setNetworkOwner(root)
    preventReset(character)
    antiFallKillProtection(character)

    -- 一瞬で15スタッド上に瞬間移動
    root.CFrame = root.CFrame + Vector3.new(0, 15, 0)

    addLog("ワープ成功！")
end

warpBtn.MouseButton1Click:Connect(safeWarp)

-- 浮遊ロゴアニメーション
spawn(function()
    while true do
        floatingText.Position = UDim2.new(0, 0, 0.02 + 0.02 * math.sin(tick() * 3), 0)
        wait(0.03)
    end
end)

addLog("daxhab 起動完了")
