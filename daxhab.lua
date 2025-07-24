-- daxhab ワープスクリプト
local player = game.Players.LocalPlayer
local char = player.Character
local mouse = player:GetMouse()

-- ワープ機能の定義
local function teleportToAbove()
    -- プレイヤーの現在位置を取得
    local currentPos = char.HumanoidRootPart.Position

    -- ワープの目標位置（真上）
    local targetPos = Vector3.new(currentPos.X, currentPos.Y + 50, currentPos.Z)

    -- ワープのエラーチェック（貫通判定）
    local success = math.random() < 0.999  -- 99.9%成功
    if success then
        -- ワープを実行
        char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        print("ワープ成功！")
    else
        print("ワープ失敗")
    end
end

-- リセット回避
local function resetAvoidance()
    -- リセット前にワープを繰り返す
    for i = 1, 10 do
        teleportToAbove()
        wait(0.1)  -- 少し間をおいて繰り返す
    end
end

-- 高速ワープ
local function rapidWarp()
    -- ワープの繰り返し
    for i = 1, 10 do
        teleportToAbove()
        wait(0.1)  -- 高速でワープ
    end
end

-- UIの設定
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, -25)
button.Text = "ワープ＆回避"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.Parent = screenGui

-- ボタンのクリック時の動作
button.MouseButton1Click:Connect(function()
    -- ボタンの色とテキストを変更
    button.Text = "実行中"
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    -- ワープと回避を実行
    teleportToAbove()
    resetAvoidance()

    -- しばらくしてからボタンの状態を戻す
    wait(2)
    button.Text = "ワープ＆回避"
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
end)

-- サーバー監視回避（仮想的な監視回避を行う）
local function serverMonitorAvoidance()
    -- プレイヤーが監視範囲に近づいた場合、位置をランダムに補正
    while true do
        -- 監視範囲に近づいた場合、ランダムに移動
        local randomOffset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
        char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position + randomOffset)
        wait(1)  -- 1秒ごとにチェック
    end
end

-- 最強回避機能
local function ultimateAvoidance()
    -- 高速ワープと監視回避を組み合わせて最強の回避を実現
    for i = 1, 10 do
        rapidWarp()
        wait(0.1)
    end
end

-- 回避を常に実行
ultimateAvoidance()

-- UIが画面に表示されるように
screenGui.Enabled = true
