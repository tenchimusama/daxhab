-- プレイヤーとキャラクターの参照
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- スクリプト制御変数
local isEnabled = false
local warpHeight = 50  -- 高速ワープ距離
local penetrationSpeed = 10  -- 高速貫通
local speedMultiplier = 3  -- 高速ワープの加速係数
local maxWarpDistance = 150  -- 最大ワープ距離制限
local resetProtection = true  -- リセット回避有効

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

-- 完全位置ロック（リセット回避）
local function forcePositionLock()
    game:GetService("RunService").Heartbeat:Connect(function()
        if isEnabled then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  -- プレイヤーの位置維持
        end
    end)
end

-- 高速ワープ＆貫通処理
local function teleportAndPenetrate()
    -- 高速ワープ位置設定（ワープ距離制限を超えないように調整）
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, warpHeight, 0)
    if (targetPosition - humanoidRootPart.Position).magnitude > maxWarpDistance then
        targetPosition = humanoidRootPart.Position + (targetPosition - humanoidRootPart.Position).unit * maxWarpDistance
    end
    humanoidRootPart.CFrame = CFrame.new(targetPosition)

    -- 物理エンジン無効化
    disablePhysics()

    -- サーバー同期無効化
    disableServerSync()

    -- 位置ロック強化
    forcePositionLock()

    -- 高速貫通処理
    while isEnabled do
        local targetPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * penetrationSpeed * speedMultiplier
        humanoidRootPart.CFrame = CFrame.new(targetPosition)

        -- 障害物がなくなったら貫通終了
        local partInFront = workspace:FindPartOnRay(Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 10), character)
        if not partInFront then
            break
        end
        wait(0.05)  -- 高速貫通速度調整
    end
end

-- 永続的なリセット回避用強化
local function preventReset()
    -- 毎フレーム、位置を固定してサーバーのリセット要求を無視
    game:GetService("RunService").Heartbeat:Connect(function()
        if resetProtection then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  -- 自分の位置を強制維持
        end
    end)
end

-- 背景に虹色で「daxhab/作者dax」を流す
local function createBackgroundText()
    local backgroundText = Instance.new("TextLabel")
    backgroundText.Parent = screenGui
    backgroundText.Text = "daxhab | 作者名: dax"
    backgroundText.TextSize = 24
    backgroundText.TextColor3 = Color3.fromRGB(255, 0, 255)  -- 初期色（虹色にするために流れる）
    backgroundText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundText.BackgroundTransparency = 0.5
    backgroundText.Position = UDim2.new(0.5, -150, 0, 0)
    backgroundText.Size = UDim2.new(0, 300, 0, 50)
    backgroundText.Font = Enum.Font.Code
    backgroundText.TextTransparency = 0.5

    -- 虹色で流れるエフェクト
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local goal = {TextColor3 = Color3.fromRGB(255, 255, 255)}
    local tween = tweenService:Create(backgroundText, tweenInfo, goal)
    tween:Play()
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
        teleportAndPenetrate()  -- 高速ワープ＆貫通開始
    end
end)

-- 初期化処理
disablePhysics()
disableServerSync()
forcePositionLock()

-- 永続的リセット回避強化
preventReset()

-- 背景テキストを表示
createBackgroundText()
