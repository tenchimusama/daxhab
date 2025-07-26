--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- VCサーバー専用メッセージ
local function addLog(text)
    logBox.Text = logBox.Text .. "\n> " .. text
end
addLog("VCサーバーでしか使えません")

-- アンチキック＆Idled無効化（スマホ対応）
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

StarterGui:SetCore("ResetButtonCallback", false)

-- UI構築（スマホ向けの調整）
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインフレーム（スマホ向けにサイズ調整）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.5, 0) -- スマホでも視認しやすい大きさ
mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0) -- 上部に余裕を持たせる
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ドラッグ処理（スマホ対応）
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 3Dロゴ作成（スマホ用にフォントやレイアウト調整）
local logoText = "！daxhab！"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1, 0, 0.2, 0)
logoHolder.Position = UDim2.new(0, 0, 0, 0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}

for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 15, 1, 0)
    lbl.Position = UDim2.new(0, 15 * (i - 1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = logoText:sub(i, i)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 1, 0)
    lbl.TextColor3 = Color3.fromHSV((tick() * 0.2 + i * 0.05) % 1, 1, 1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end

-- 3D風アニメーション（スマホ用）
RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(logoLabels) do
        local offset = math.sin(tick() * 10 + i) * 5
        lbl.Position = UDim2.new(0, 15 * (i - 1), 0, offset)
        lbl.TextColor3 = Color3.fromHSV((tick() * 0.3 + i * 0.07) % 1, 1, 1)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ログ表示枠（UIの見やすさを考慮）
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -10, 0.4, -10)  -- 高さを少し小さくして、ボタンが重ならないように
logBox.Position = UDim2.new(0, 5, 0.2, 5)
logBox.BackgroundColor3 = Color3.new(0, 0, 0)
logBox.TextColor3 = Color3.fromRGB(0, 255, 0)
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextSize = 14
logBox.TextWrapped = true
logBox.Text = "作成者: dax"
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

-- スタッド入力欄（スマホ用にサイズ調整）
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.7, 0, 0.1, 0)
heightInput.Position = UDim2.new(0.15, 0, 0.6, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
heightInput.TextColor3 = Color3.fromRGB(0, 255, 0)
heightInput.PlaceholderText = "↑スタッド"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local currentHeight = Instance.new("TextLabel")
currentHeight.Size = UDim2.new(0.7, 0, 0.1, 0)
currentHeight.Position = UDim2.new(0.15, 0, 0.75, 0)
currentHeight.BackgroundTransparency = 1
currentHeight.TextColor3 = Color3.fromRGB(0, 255, 0)
currentHeight.Font = Enum.Font.Code
currentHeight.TextScaled = true
currentHeight.Text = "↑: 40"
currentHeight.Parent = mainFrame

heightInput:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(heightInput.Text)
    if val then
        currentHeight.Text = "↑: " .. tostring(val)
    else
        currentHeight.Text = "↑: ?"
    end
end)

-- ボタン（透明化）スマホ向け
local transparencyButton = Instance.new("TextButton")
transparencyButton.Size = UDim2.new(0.7, 0, 0.12, 0)
transparencyButton.Position = UDim2.new(0.15, 0, 0.85, 0)
transparencyButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
transparencyButton.TextColor3 = Color3.fromRGB(0, 255, 0)
transparencyButton.Font = Enum.Font.Code
transparencyButton.TextScaled = true
transparencyButton.Text = "[ 透明化 ]"
transparencyButton.Parent = mainFrame

-- 座標変更ボタン（スマホ向け）
local changePositionButton = Instance.new("TextButton")
changePositionButton.Size = UDim2.new(0.7, 0, 0.12, 0)
changePositionButton.Position = UDim2.new(0.15, 0, 0.7, 0)
changePositionButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
changePositionButton.TextColor3 = Color3.fromRGB(0, 255, 0)
changePositionButton.Font = Enum.Font.Code
changePositionButton.TextScaled = true
changePositionButton.Text = "[ 座標変更 ]"
changePositionButton.Parent = mainFrame

-- ワープ時のビープ音（軽量サウンド）
local beepSound = Instance.new("Sound")
beepSound.SoundId = "rbxassetid://911882704" -- 短いビープ音
beepSound.Volume = 0.6
beepSound.Parent = mainFrame

local function animateButton(btn)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    }):Play()
    beepSound:Play()
    task.wait(0.2)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    }):Play()
end

-- ボタン動作（座標変更と透明化）
changePositionButton.MouseButton1Click:Connect(function()
    animateButton(changePositionButton)
    safeChangePosition()
end)

transparencyButton.MouseButton1Click:Connect(function()
    animateButton(transparencyButton)
    makeInvisible()
    addLog("透明化中...")
end)

-- リセット回避強化
preventReset()
