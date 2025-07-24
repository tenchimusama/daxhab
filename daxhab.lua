-- プレイヤーとキャラクターの参照
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- スクリプト制御変数
local isEnabled = false
local skinHeight = humanoidRootPart.Size.Y  -- スキンの高さを取得
local warpHeight = skinHeight * 7.5  -- 高さをスキン7.5体分に設定
local maxWarpDistance = 150  -- 最大ワープ距離制限
local resetProtection = true  -- リセット回避有効
local canMove = true  -- 操作可能状態

-- 物理エンジンの無効化（オブジェクト貫通）
local function disablePhysics()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 衝突無効化
            part.Anchored = true      -- 完全固定
        end
    end
end

-- サーバーからの位置修正、テレポート要求完全無効化
local function disableServerSync()
    -- サーバーからの補正を完全に無視
    local metatable = getmetatable(game)
    metatable.__index = function(t, key)
        if key == "TeleportEvent" then
            return function() end  -- サーバーのテレポート要求無効化
        end
        return rawget(t, key)
    end

    -- サーバーからの位置修正イベントを無効化
    game:GetService("NetworkClient").OnClientPositionChanged:Connect(function() end)

    -- サーバーからの補正・リセットを完全に無視する
    game:GetService("NetworkClient").OnClientEvent:Connect(function(eventName)
        if eventName == "PositionUpdate" or eventName == "Teleport" then
            -- サーバーからのリセット要求を完全無視
            return nil
        end
    end)
end

-- 特定のエリア（例えば家の中）でリセットを無効化
local function checkAndPreventResetAtHome()
    -- プレイヤーの位置を取得
    local playerPosition = humanoidRootPart.Position

    -- 家の中の範囲（仮定：家の中心が (0,0,0) で、半径50スタッドの範囲内）
    local homeCenter = Vector3.new(0, 0, 0)  -- 家の中心位置
    local homeRadius = 50  -- 半径50スタッド以内を家の中とする

    -- プレイヤーが家の中にいるか確認
    if (playerPosition - homeCenter).magnitude < homeRadius then
        -- 家の中にいる場合、リセットを無効化
        resetProtection = true  -- 家の中でリセット回避
    else
        -- 家の外にいる場合はリセットを許可
        resetProtection = false
    end
end

-- 高速ワープ＆真上へのワープ処理
local function teleportToTop()
    -- ワープ先の位置を計算
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, warpHeight, 0)

    -- 最大ワープ距離制限を超えないように調整
    if (targetPosition - humanoidRootPart.Position).magnitude > maxWarpDistance then
        targetPosition = humanoidRootPart.Position + (targetPosition - humanoidRootPart.Position).unit * maxWarpDistance
    end

    -- 上に障害物がないかチェック（真上にレイを飛ばして）
    local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, 1000, 0))
    local hitPart, hitPosition = workspace:FindPartOnRay(ray, character)

    -- 障害物がなければワープ
    if not hitPart then
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    else
        -- 障害物がある場合、オブジェクトを持っていても貫通させる
        local currentPosition = humanoidRootPart.Position
        while hitPart do
            -- 障害物がまだある場合はさらに進める
            local direction = humanoidRootPart.CFrame.LookVector
            local nextPosition = currentPosition + direction * 10  -- 10スタッド先へ進む
            humanoidRootPart.CFrame = CFrame.new(nextPosition)

            -- 次の障害物を検出
            ray = Ray.new(nextPosition, Vector3.new(0, 1000, 0))  -- 次の位置から再度上方向にレイを飛ばす
            hitPart, hitPosition = workspace:FindPartOnRay(ray, character)

            -- 新しい障害物を越えるために位置を更新
            currentPosition = nextPosition
        end
    end

    -- ワープ後、操作可能に
    canMove = true  -- ワープ完了後に操作を可能にする
end

-- 強制的に位置を維持（リセット回避強化）
local function forcePositionLock()
    game:GetService("RunService").Heartbeat:Connect(function()
        if resetProtection and canMove then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  -- 常に現在の位置を維持
        end
    end)
end

-- 死亡を無効化
local function preventDeath()
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            -- 体力が0になっても死亡しないようにする
            humanoid.Health = 100  -- 体力を再設定
        end
    end)
end

-- サーバーからのリセット要求無効化
disableServerSync()

-- 物理エンジン無効化
disablePhysics()

-- 強制位置ロック
forcePositionLock()

-- 死亡回避
preventDeath()

-- リセット回避
local function preventReset()
    -- 特定の場所（家の中）でリセットされないようにする
    checkAndPreventResetAtHome()
end

preventReset()

-- ワープボタンと背景を一つにする
local warpButtonWithBackground = Instance.new("Frame")
warpButtonWithBackground.Parent = screenGui
warpButtonWithBackground.Size = UDim2.new(0, 300, 0, 60)  -- ボタンサイズと背景を調整
warpButtonWithBackground.Position = UDim2.new(0.5, -150, 0.6, 0)  -- 中央配置
warpButtonWithBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 背景色（黒）
warpButtonWithBackground.BackgroundTransparency = 0.5

-- ボタンの作成
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = warpButtonWithBackground
teleportButton.Text = "ワープ | daxhab | 作者名: dax"
teleportButton.TextSize = 16
teleportButton.Size = UDim2.new(1, 0, 1, 0)  -- 背景とボタンが一体になるように調整
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.Font = Enum.Font.Code

-- ボタンのクリックイベント
teleportButton.MouseButton1Click:Connect(function()
    if isEnabled then
        isEnabled = false
        teleportButton.Text = "ワープ | daxhab | 作者名: dax"
    else
        isEnabled = true
        teleportButton.Text = "ワープ中... | daxhab | 作者名: dax"
        teleportToTop()  -- 真上ワープ開始
    end
end)
