-- 最強の屋上との空間入れ替えスクリプト（着地強化版）

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- 屋上の位置（屋上の座標を指定）
local roofPosition = Vector3.new(0, 500, 0)  -- 例: 屋上の位置（適切な座標に変更してください）

-- セキュリティ強化設定
local speed = 50  -- 高速移動の速度
local warpChance = 0.999  -- ワープ成功率
local securityCheckInterval = 0.1  -- セキュリティチェックの間隔
local maxRetryAttempts = 10  -- 最大リトライ回数
local maxPositionY = 5000  -- 最大許容Y軸位置
local maxWarpDistance = 100  -- 最大ワープ距離（誤ったワープを防ぐため）
local isSwapping = false  -- ワープ中かどうかを管理するフラグ

-- セキュリティ対策：不正な位置検出
local function performSecurityChecks(targetPosition)
    if targetPosition.Y < 0 or targetPosition.Y > maxPositionY then
        warn("不正なターゲット位置です。処理を停止します。")
        return false
    end
    return true
end

-- ワープ位置ランダム化（周囲の位置で安全な位置をランダムに選ぶ）
local function getRandomizedPosition(basePosition)
    local randomX = basePosition.X + math.random(-5, 5)
    local randomY = basePosition.Y + math.random(-2, 2)
    local randomZ = basePosition.Z + math.random(-5, 5)
    return Vector3.new(randomX, randomY, randomZ)
end

-- ワープ遅延ランダム化
local function randomDelay()
    wait(math.random(0.1, 0.5))  -- ワープの前に0.1~0.5秒のランダム遅延
end

-- ワープ試行
local function attemptWarp(targetPosition)
    local retries = 0
    local success = false
    while retries < maxRetryAttempts and not success do
        -- ワープ成功率チェック
        if math.random() > warpChance then
            warn("ワープに失敗しました。再試行します...")
            retries = retries + 1
        else
            -- ワープ前に遅延をランダム化
            randomDelay()

            -- 空間の入れ替え処理（屋上にワープ）
            local randomizedPosition = getRandomizedPosition(targetPosition)
            humanoidRootPart.CFrame = CFrame.new(randomizedPosition)  -- プレイヤーを屋上に移動
            success = true
        end
        wait(0.2)  -- 少し待って再試行
    end
    return success
end

-- 空間入れ替え実行（屋上に移動後、その位置にとどまる）
local function swapSpaces()
    -- ワープ中でないかをチェック
    if isSwapping then
        warn("現在、他のワープ処理が実行中です。")
        return
    end

    isSwapping = true  -- ワープ処理開始

    -- プレイヤーの位置と屋上の位置を交換
    local playerPosition = humanoidRootPart.Position

    -- 屋上の位置が有効かどうかチェック
    if not performSecurityChecks(roofPosition) then
        isSwapping = false  -- 処理終了
        return
    end

    -- ワープ試行
    if not attemptWarp(roofPosition) then
        warn("ワープに失敗しました。")
        isSwapping = false  -- 処理終了
        return
    end

    print("プレイヤーは屋上にとどまりました。")

    -- ここでプレイヤーは屋上にとどまります
    ensureValidPosition()

    isSwapping = false  -- 処理終了
end

-- セキュリティ強化：位置が不正なら修正
local function ensureValidPosition()
    -- プレイヤーが屋上にとどまるため、位置がずれていないかを確認
    local currentPosition = humanoidRootPart.Position
    if currentPosition.Y < 0 or currentPosition.Y > maxPositionY or (currentPosition - roofPosition).Magnitude > maxWarpDistance then
        humanoidRootPart.CFrame = CFrame.new(roofPosition)  -- プレイヤーが不正位置にいる場合、屋上に強制的に戻す
        print("不正な位置検出、屋上に戻しました。")
    end
end

-- UIボタン作成（空間入れ替えボタン）
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui  -- PlayerGuiに親を設定

local swapButton = Instance.new("TextButton")
swapButton.Size = UDim2.new(0, 200, 0, 50)
swapButton.Position = UDim2.new(0.5, -100, 0.8, -25)
swapButton.Text = "屋上と入れ替え"
swapButton.Font = Enum.Font.Code
swapButton.TextSize = 30
swapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
swapButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
swapButton.BackgroundTransparency = 0.2
swapButton.Parent = screenGui

-- daxhab/作者dax表示
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 50)
titleLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
titleLabel.Text = "daxhab / 作者dax"
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 25
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = screenGui

-- 空間入れ替えボタンをクリックしたときに実行
swapButton.MouseButton1Click:Connect(function()
    -- プレイヤーと屋上の位置を入れ替え
    swapSpaces()
end)

-- 回避機能強化：不正な位置を検出して修正
local function enableAvoidance()
    while true do
        wait(securityCheckInterval)
        -- プレイヤーが不正な位置に移動した場合、強制的に屋上に戻す
        local currentPosition = humanoidRootPart.Position
        if currentPosition.Y < 0 or currentPosition.Y > maxPositionY or (currentPosition - roofPosition).Magnitude > maxWarpDistance then
            humanoidRootPart.CFrame = CFrame.new(roofPosition)  -- 屋上に戻す
            print("不正な位置検出、屋上に戻しました。")
        end
    end
end

-- 回避機能を有効化
enableAvoidance()
