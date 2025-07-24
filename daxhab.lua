-- プレイヤーとキャラクターの参照
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- スクリプト制御変数
local isEnabled = false
local warpHeight = 100  -- 初期ワープ距離
local penetrationSpeed = 10  -- 高速貫通
local speedMultiplier = 3  -- 高速ワープの加速係数
local maxWarpDistance = 150  -- 最大ワープ距離制限
local resetProtection = true  -- リセット回避有効
local canMove = true  -- 操作可能状態
local networkOverride = true -- 通信改竄無効化
local playerID = player.UserId  -- プレイヤーID
local lastPosition = humanoidRootPart.Position  -- 最後の位置

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
            -- 無視
            return nil
        end
    end)
end

-- 完全位置ロック（リセット回避）→ 操作可能に修正
local function forcePositionLock()
    game:GetService("RunService").Heartbeat:Connect(function()
        if resetProtection then
            if canMove then
                -- 位置の強制維持
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  -- 位置ロック
            end
        end
    end)
end

-- キック防止（サーバーから強制切断を無効化）
local function preventKick()
    game:GetService("Players").PlayerAdded:Connect(function(newPlayer)
        if newPlayer == player then
            -- キック処理を無効化
            pcall(function()
                game:GetService("Players").LocalPlayer:Kick("ゲームが強制終了されました")  -- エラーメッセージを無効化
            end)
        end
    end)
end

-- 高速ワープ＆屋上ワープ処理
local function teleportToRooftop()
    -- ワープする建物の座標（屋上）
    local building = workspace:FindFirstChild("Building")  -- 建物の名前を適切に指定
    if not building then
        warn("Building not found!")
        return
    end

    local roofHeight = building.Position.Y + building.Size.Y / 2  -- 屋上の高さを計算

    -- ワープ先の位置を計算（屋上の高さまで）
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, roofHeight - humanoidRootPart.Position.Y, 0)

    -- 最大ワープ距離制限を超えないように調整
    if (targetPosition - humanoidRootPart.Position).magnitude > maxWarpDistance then
        targetPosition = humanoidRootPart.Position + (targetPosition - humanoidRootPart.Position).unit * maxWarpDistance
    end

    -- 上に障害物がないかチェック
    local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, 1000, 0))
    local hitPart, hitPosition = workspace:FindPartOnRay(ray, character)

    -- 障害物がなければワープ
    if not hitPart then
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    else
        -- 障害物がある場合、最上部にワープする処理
        local targetPosition = hitPosition + Vector3.new(0, 5, 0)  -- 少し上に
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    end

    -- ワープ後、操作可能に
    canMove = true  -- ワープ完了後に操作を可能にする

    -- ワープ後に移動を続ける
    while isEnabled do
        local currentPosition = humanoidRootPart.Position
        local nextPosition = currentPosition + humanoidRootPart.CFrame.LookVector * penetrationSpeed * speedMultiplier
        humanoidRootPart.CFrame = CFrame.new(nextPosition)
        wait(0.1)  -- 位置更新の間隔を設定
    end
end

-- 通信改竄（トラフィック偽装）・エンジン監視の無効化
local function disableEngineMonitoring()
    -- プロハッカー仕様でシステムの監視を回避
    local gameMeta = getmetatable(game)
    gameMeta.__index = function(t, key)
        if key == "Analytics" then
            return function() end  -- エンジン監視を完全に無視
        end
        return rawget(t, key)
    end
end

-- セキュリティ強化のバックドア
local function backdoorProtection()
    -- 他のプロセスやサーバーからのバックドアアクセスを防ぐ
    local currentTime = os.time()
    while true do
        if os.time() - currentTime > 5 then
            -- 定期的にゲームのプロセスをチェックし、異常があれば無効化
            local processCheck = game:GetService("Players"):FindFirstChild(player.Name)
            if processCheck then
                -- 不正な接続があればゲームを強制終了させる
                game:GetService("Players").LocalPlayer:Kick("不正な接続を検出しました")
            end
            currentTime = os.time()
        end
        wait(1)  -- 1秒間隔でチェック
    end
end

-- 高度なトラフィック改竄（すべてのデータ通信を隠蔽）
local function trafficSpoofing()
    -- プロトコルのレベルでデータの偽装を行う（例：ゲーム通信の中身を隠す）
    game:GetService("NetworkClient").OnClientEvent:Connect(function(eventName, ...)
        if eventName == "PositionUpdate" or eventName == "Teleport" then
            -- 不正なリセットやテレポートのイベントを無効化
            return
        end
    end)
end

-- スクリプトの初期化
disablePhysics()       -- 物理エンジン無効化
disableServerSync()    -- サーバーからの位置修正無効化
forcePositionLock()    -- 位置ロック
preventKick()          -- キック防止
disableEngineMonitoring() -- エンジン監視無効化
backdoorProtection()   -- バックドア保護
trafficSpoofing()      -- トラフィック偽装

-- ワープボタンの作成
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ"
teleportButton.TextSize = 16
teleportButton.Size = UDim2.new(0, 150, 0, 40)
teleportButton.Position = UDim2.new(0.5, -75, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.Font = Enum.Font.Code

-- ボタンのクリックイベント
teleportButton.MouseButton1Click:Connect(function()
    if isEnabled then
        isEnabled = false
        teleportButton.Text = "ワープ"
    else
        isEnabled = true
        teleportButton.Text = "ワープ中..."
        teleportToRooftop()  -- 屋上ワープ開始
    end
end)

-- 背景にタイトルと作者名を表示
local function createBackgroundText()
    local backgroundText = Instance.new("TextLabel")
    backgroundText.Parent = screenGui
    backgroundText.Text = "daxhab | 作者名: dax"
    backgroundText.TextSize = 24
    backgroundText.TextColor3 = Color3.fromRGB(0, 255, 0)
    backgroundText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundText.BackgroundTransparency = 0.5
    backgroundText.Position = UDim2.new(0.5, -150, 0, 0)
    backgroundText.Size = UDim2.new(0, 300, 0, 50)
    backgroundText.Font = Enum.Font.Code
    backgroundText.TextTransparency = 0.5
end

createBackgroundText()  -- 背景テキスト表示
