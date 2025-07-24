local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local playerHeight = 7.5 * 5  -- キャラの高さを7.5人分 (1人あたり5 studs)
local moveSpeed = 0.05  -- 移動速度を遅くする（自然な動き）
local movementDelay = 0.1  -- 移動後のディレイ
local antiKickDelay = 1  -- アンチキックのための確認間隔

-- 屋上と1階の座標を設定（例）
local roofPosition = Vector3.new(0, 100, 0)  -- 屋上の位置
local floorPosition = Vector3.new(0, 0, 0)   -- 1階の位置

-- ランダムなオフセットを生成して、動きに自然さを加える
local function getRandomOffset()
    return Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * 0.5
end

-- スムーズな移動を行う関数（補間）
local function smoothMove(targetPosition)
    local currentPosition = humanoidRootPart.Position
    local steps = 50  -- 移動を小刻みに行うためのステップ数
    for i = 1, steps do
        currentPosition = currentPosition:Lerp(targetPosition + getRandomOffset(), moveSpeed)
        humanoidRootPart.CFrame = CFrame.new(currentPosition)
        wait(movementDelay)
    end
end

-- 移動後に座標補正やバグを防止するための処理を追加
local function antiKickFix()
    wait(antiKickDelay)
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, playerHeight, 0)
    if (humanoidRootPart.Position - targetPosition).magnitude < 0.1 then
        humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 0.1, 0))  -- 小さなズレを加えてリセット回避
    end
end

-- UIにボタンを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- カラフルで可愛いボタンの作成
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "屋上/1階 入れ替え"  -- ボタンにテキストを表示
button.TextColor3 = Color3.fromRGB(255, 255, 255)  -- テキスト色を白に設定
button.TextSize = 18  -- テキストのサイズ
button.TextStrokeTransparency = 0.8  -- テキストにストロークを追加
button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  -- ストローク色を黒に設定

-- ボタンの背景にグラデーションを追加
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 200)),  -- ピンク
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 100)),  -- 黄色
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 255))   -- 水色
})
gradient.Parent = button

button.Parent = screenGui

-- 屋上と1階の入れ替え処理
local function swapFloors()
    -- プレイヤーが持っているオブジェクトをリスト化
    local objectsToMove = {}
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("BasePart") and obj.Parent == character then
            table.insert(objectsToMove, obj)
        end
    end

    -- 1階→屋上のワープ
    if humanoidRootPart.Position.Y < 10 then  -- プレイヤーが1階にいる場合
        smoothMove(roofPosition)  -- 屋上に移動
    else
        -- 屋上→1階のワープ
        smoothMove(floorPosition)  -- 1階に移動
    end

    -- オブジェクトも一緒に移動させる
    for _, obj in pairs(objectsToMove) do
        obj.CFrame = humanoidRootPart.CFrame
    end

    -- パッチ回避: 不正アクセスを防ぐために動作をランダム化
    antiKickFix()

    -- 上にオブジェクトを生成（例: 部屋の中にブロックを生成）
    local object = Instance.new("Part")
    object.Size = Vector3.new(5, 5, 5)
    object.Position = humanoidRootPart.Position + Vector3.new(0, 5, 0)
    object.Anchored = true
    object.Parent = workspace
end

button.MouseButton1Click:Connect(swapFloors)

-- 高度な対策強化のため、ランダムな位置変動と時間差での動作を繰り返す
while true do
    -- 監視を回避するために、少しずつ動かす
    local randomOffset = getRandomOffset()
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + randomOffset)
    wait(math.random(2, 5))  -- ランダムな待機時間
end
