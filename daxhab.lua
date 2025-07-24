-- プレイヤーの設定
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- プレイヤー高さの設定（7.5人分）
local playerHeight = 7.5 * 5  -- 1人あたり5 studsとして7.5人分
local moveSpeed = 0.1  -- 移動速度（遅くして自然に見せる）
local movementDelay = 0.1  -- 移動後のディレイ

-- キャラを7.5人分の高さだけ真上にワープする関数
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
    -- Y座標が低い＝リセット状態（条件を緩和）
    if humanoidRootPart.Position.Y < 3 then  
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
screenGui.IgnoreGuiInset = true  -- ゲーム画面の端を無視して全体に表示

-- 背景とボタンを一体化したデザイン
local background = Instance.new("Frame")
background.Size = UDim2.new(0, player.PlayerGui.AbsoluteSize.X / 2, 0, player.PlayerGui.AbsoluteSize.Y / 8)
background.Position = UDim2.new(0.5, -player.PlayerGui.AbsoluteSize.X / 4, 0.5, -player.PlayerGui.AbsoluteSize.Y / 16)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 背景を黒に設定
background.BackgroundTransparency = 0.5
background.Parent = screenGui

-- ボタンの作成
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 250, 0, 100)
button.Position = UDim2.new(0.5, -125, 0.5, -50)
button.Text = "daxhab/作者dax"  -- ボタンにテキストを表示
button.TextColor3 = Color3.fromRGB(255, 255, 255)  -- テキスト色（白）
button.TextSize = 24  -- テキストのサイズ
button.TextStrokeTransparency = 0.5  -- テキストにストロークを追加
button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  -- ストローク色を黒に設定
button.Font = Enum.Font.Code -- ハッカーフォントに設定
button.BackgroundTransparency = 0.5
button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- 背景色（緑）

button.Parent = background  -- ボタンを背景の中に配置

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

background.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = background.Position
    end
end)

background.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        background.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

background.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 高度なランダム化と微調整で、監視ツール対策を強化
while true do
    -- 微調整で不自然な移動を防ぐ
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(math.random(-0.1, 0.1), 0, math.random(-0.1, 0.1)))
    wait(0.5)  -- ランダム待機時間で不規則な動き
end

-- ワープ後の物理設定変更（貫通）
local function enableCharacterCollision()
    -- ワープ後、物理挙動を無効化して貫通できるようにする
    humanoidRootPart.CanCollide = false
    character:WaitForChild("Humanoid").PlatformStand = true  -- プレイヤーが物理的に制御されないようにする
end

-- 位置が元に戻るのを防ぐため、ワープ後に物理設定を変更
local function moveAndDisableCollisions()
    moveUp()
    enableCharacterCollision()
end

-- ボタンがクリックされた際、ワープ機能と貫通設定を呼び出す
button.MouseButton1Click:Connect(function()
    -- リセットされていたら移動停止
    if stopIfReset() then
        return
    end
    -- 真上に移動して貫通設定を適用
    moveAndDisableCollisions()
end)
