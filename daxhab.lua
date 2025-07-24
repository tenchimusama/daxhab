-- プレイヤーの物理エンジン無効化（衝突無効化と完全固定）
local function disablePhysics()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 衝突無効化
            part.Anchored = true      -- 完全固定
        end
    end
end

-- サーバーからの位置修正要求、テレポート要求完全無効化
local function disableServerSync()
    -- metatableを変更して、サーバーからの補正を完全無効化
    local metatable = getmetatable(game)
    metatable.__index = function(t, key)
        if key == "TeleportEvent" then
            return function() end  -- サーバーのテレポート要求無効化
        end
        return rawget(t, key)
    end

    -- サーバーからの位置修正イベントを完全に無効化
    game:GetService("NetworkClient").OnClientPositionChanged:Connect(function() end)

    -- サーバーからの位置修正要求を完全に無効化するためのイベントリスナーを追加
    game:GetService("NetworkClient").OnClientEvent:Connect(function(eventName)
        if eventName == "Teleport" then
            return nil  -- サーバーからのテレポート要求を無視
        end
    end)
end

-- 強化した位置ロック
local function forcePositionLock()
    game:GetService("RunService").Heartbeat:Connect(function()
        if isEnabled then
            -- プレイヤーの位置を強制的に維持（運営側からの補正を完全無視）
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  -- 自分の位置を維持
        end
    end)
end

-- 完全リセット回避のための強力なロック
local function preventTeleportReset()
    game:GetService("RunService").Heartbeat:Connect(function()
        if isEnabled then
            -- 毎フレームで位置を確認し、サーバーの補正を完全に回避
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  -- 自分の位置を強制維持
        end
    end)
end

-- ワープ＆貫通統合：強化バージョン
local function teleportAndPenetrate()
    -- ワープ位置設定（50 studs上にワープ）
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, warpHeight, 0)
    humanoidRootPart.CFrame = CFrame.new(targetPosition)

    -- 物理エンジン無効化
    disablePhysics()

    -- サーバー同期無効化
    disableServerSync()

    -- 位置ロック強化
    forcePositionLock()

    -- リセット回避強化
    preventTeleportReset()

    -- 貫通処理（障害物を通過）
    while isEnabled do
        local targetPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * penetrationSpeed
        humanoidRootPart.CFrame = CFrame.new(targetPosition)

        -- 障害物がなくなったら貫通終了
        local partInFront = workspace:FindPartOnRay(Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 10), character)
        if not partInFront then
            break
        end
        wait(0.1) -- 貫通速度調整
    end
end

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
        teleportButton.Text = "ワープ"
        teleportAndPenetrate()  -- ワープ＆貫通開始
    end
end)

-- 初期化処理
disablePhysics()
disableServerSync()
forcePositionLock()

-- 背景テキストを表示
createBackgroundText()
