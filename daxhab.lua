-- プレイヤーの設定
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- プレイヤー高さの設定（7.5人分）
local playerHeight = 7.5 * 5  -- 1人あたり5 studsとして7.5人分
local moveSpeed = 0.1  -- 移動速度（遅くして自然に見せる）
local movementDelay = 0.1  -- 移動後のディレイ
local randomMoveDelay = 0.5  -- ランダム化の間隔

-- キャラクターの物理を無効化（貫通対策）
local function disableCharacterPhysics()
    humanoidRootPart.CanCollide = false  -- キャラクターが他の物体と衝突しないように
    humanoid.PlatformStand = true  -- プレイヤーを物理エンジンから切り離し、自由に動けるように
end

-- キャラクターがリセットされた場合、位置を補正する
local function fixReset()
    if humanoidRootPart.Position.Y < 1 then  -- Y座標が低い＝リセット状態
        print("リセット状態が検出されました。位置を補正します。")
        -- 位置を補正（少し上に移動してリセット回避）
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, 0))
    end
end

-- 定期的に位置補正を行い、リセットを防ぐ
local function preventReset()
    while true do
        fixReset()  -- リセット回避処理
        wait(0.5)  -- 0.5秒間隔で確認
    end
end

-- 真上にワープする関数（天井がない限りワープし続ける）
local function moveUpUntilNoCeiling()
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, playerHeight, 0)  -- 現在位置の真上

    while true do
        -- ワープ移動
        smoothMove(targetPosition)
        
        -- 目の前に天井があるかチェック（キャラクターの真上の一定範囲を確認）
        if not isCeilingAbove() then
            break  -- 天井がなくなったら停止
        end
        
        -- 次の位置にワープ
        targetPosition = humanoidRootPart.Position + Vector3.new(0, playerHeight, 0)
        wait(movementDelay)  -- 少し待機してから次の移動
    end
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

-- 天井があるかどうかを確認する関数（真上に障害物があるかをチェック）
local function isCeilingAbove()
    local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, playerHeight, 0))  -- 真上に向かってレイを飛ばす
    local hitPart, hitPosition = workspace:FindPartOnRay(ray, character)  -- レイが障害物に当たるかチェック

    if hitPart then
        return true  -- 障害物（天井）があればtrue
    else
        return false  -- 障害物がなければfalse
    end
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
    -- 真上に移動して天井がなくなるまでワープ
    moveUpUntilNoCeiling()
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

-- リセット回避のため、定期的に位置を補正
preventReset()
