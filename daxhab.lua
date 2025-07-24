-- プレイヤーとキャラクターの参照
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui  -- 正しくPlayerGuiに親設定

-- スクリプト制御変数
local isEnabled = false
local warpHeight = 100  -- 初期ワープ距離
local penetrationSpeed = 10  -- 高速貫通
local speedMultiplier = 3  -- 高速ワープの加速係数
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
teleportButton.Visible = true -- ボタンが表示されるように設定

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

-- サーバーからの位置修正無効化
disableServerSync()    

-- キック防止
preventKick()
