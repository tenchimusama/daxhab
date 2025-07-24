-- プレイヤーの設定
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local playerHeight = 7.5 * 5  -- キャラの高さを7.5人分 (1人あたり5 studs)
local moveSpeed = 0.1  -- 移動速度を設定（遅くして自然に見せる）
local movementDelay = 0.1  -- 移動後のディレイ

-- 真上にワープする関数
local function moveUp()
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, playerHeight, 0)  -- 現在位置の真上
    smoothMove(targetPosition)
end

-- スムーズな移動を行う関数（補間）
local function smoothMove(targetPosition)
    local currentPosition = humanoidRootPart.Position
    local steps = 50  -- 移動を小刻みに行うためのステップ数
    for i = 1, steps do
        -- ランダムオフセットを追加して動きをより自然にする
        currentPosition = currentPosition:Lerp(targetPosition + Vector3.new(math.random(-0.1, 0.1), math.random(-0.1, 0.1), math.random(-0.1, 0.1)), moveSpeed)
        humanoidRootPart.CFrame = CFrame.new(currentPosition)
        wait(movementDelay)
    end
end

-- リセット後に停止または補正する処理
local function stopIfReset()
    if humanoidRootPart.Position.Y < 3 then  -- Y座標が低い＝リセット状態（条件を緩和）
        print("リセット状態が検出されました。位置を補正します。")
        -- リセットされた場合、少しだけ位置を補正
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, 0))  -- Y座標を少し上に補正
        return true
    end
    return false
end

-- UIにボタンを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- ボタンの背景とボタン作成
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, player.PlayerGui.AbsoluteSize.X / 8, 0, player.PlayerGui.AbsoluteSize.Y / 8)
button.Position = UDim2.new(0.5, -player.PlayerGui.AbsoluteSize.X / 16, 0.5, -player.PlayerGui.AbsoluteSize.Y / 16)
button.Text = "daxhab/作者dax"  -- ボタンにテキストを表示
button.TextColor3 = Color3.fromRGB(255, 255, 255)  -- テキスト色（白）
button.TextSize = 24  -- テキストのサイズ
button.TextStrokeTransparency = 0.5  -- テキストにストロークを追加
button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  -- ストローク色を黒に設定
button.Font = Enum.Font.Code -- ハッカーフォントに設定

-- ボタンの背景にグラデーションを追加
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),  -- 緑
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 255)),  -- 青
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))   -- 赤
})
gradient.Parent = button

button.Parent = screenGui

-- ボタンがクリックされたときの処理
button.MouseButton1Click:Connect(function()
    -- リセットされていたら移動停止
    if stopIfReset() then
        return
    end
    -- 真上に移動
    moveUp()
end)

-- ドラッグ可能にするための処理
local dragging = false
local dragStart = nil
local startPos = nil

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

button.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 定期的にリセットを補正
while true do
    if stopIfReset() then
        -- 再度位置を補正
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, 0))
    end
    wait(1)  -- 1秒ごとにチェック
end
