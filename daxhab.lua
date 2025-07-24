-- daxhab.lua
-- タイトル: daxhab
-- 作者名: dax
-- フォント: ハッカー風タイピング演出（世界にないレベル）

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- 初期配置: 真ん中に配置（必ず真ん中に配置される）
character:SetPrimaryPartCFrame(CFrame.new(0, 50, 0)) -- 初期位置を真ん中に設定

-- ハッカー風タイピング演出
local text = Instance.new("TextLabel")
text.Parent = screenGui
text.Text = "daxhab..."
text.TextSize = 50
text.Font = Enum.Font.Code -- ハッカー風フォント
text.TextColor3 = Color3.fromRGB(0, 255, 0) -- 緑色
text.BackgroundTransparency = 1
text.Position = UDim2.new(0.5, -150, 0.5, -25)
text.Size = UDim2.new(0, 300, 0, 50)
text.TextStrokeTransparency = 0.5

-- 物理エンジン回避: 物理的なコリジョンを無効化
local function disableCollision()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 物理的な障害物を通過
            part.Anchored = false  -- 物理エンジンによる動きを無効化
        end
    end
end

-- ワープ機能: 範囲ワープ（ターゲット指定）
local function teleportUp(distance)
    -- エフェクト: ワープ前の発光エフェクト
    local warpEffect = Instance.new("Part")
    warpEffect.Shape = Enum.PartType.Ball
    warpEffect.Size = Vector3.new(10, 10, 10)
    warpEffect.Position = humanoidRootPart.Position
    warpEffect.Anchored = true
    warpEffect.CanCollide = false
    warpEffect.Material = Enum.Material.Neon
    warpEffect.Color = Color3.fromRGB(0, 255, 255) -- ワープエフェクト
    warpEffect.Parent = game.Workspace

    -- エフェクトの短い時間表示
    game.Debris:AddItem(warpEffect, 0.5)

    -- 物理エンジン無効化（移動後、再度無効化）
    disableCollision()

    -- ワープ後のターゲット位置
    local newPosition = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + distance, humanoidRootPart.Position.Z)
    
    -- サーバーとの同期：ワープ後、サーバーにその位置情報を送信（戻されないように）
    game.ReplicatedStorage:WaitForChild("TeleportEvent"):FireServer(newPosition)
    
    -- 位置を強制的に変更
    humanoidRootPart.CFrame = CFrame.new(newPosition)
    
    -- 貫通機能を再起動
    enableCeilingPenetration()  
end

-- 貫通機能の強化: 高速貫通
local function enableCeilingPenetration()
    local penetrationSpeed = 50 -- 貫通速度
    local penetrationActive = true
    while penetrationActive do
        -- 高速貫通: 壁を貫通する
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, penetrationSpeed, 0)
        wait(0.1) -- 貫通の加速
    end
end

-- 複数オブジェクト貫通（連続貫通）
local function continuousPenetration()
    -- 貫通対象の障害物をリスト化（例: 壁や障害物）
    local obstacles = {}
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            table.insert(obstacles, part)
        end
    end

    -- 障害物を次々に貫通
    for _, obstacle in ipairs(obstacles) do
        if humanoidRootPart.Position:DistanceFrom(obstacle.Position) < 10 then
            -- 貫通する
            humanoidRootPart.CFrame = CFrame.new(obstacle.Position + Vector3.new(0, 0, -10)) -- 障害物を越える
            wait(0.2) -- 次の貫通までのインターバル
        end
    end
end

-- 時間スローモーションエフェクト
local function slowTimeEffect()
    -- 周囲のオブジェクトをスローモーション化
    local originalTime = game:GetService("RunService").Heartbeat
    game:GetService("RunService").Heartbeat = function(_, dt)
        dt = dt * 0.3 -- スローモーション速度
        originalTime(_, dt)
    end
end

-- ワープボタン（範囲ワープ）
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ"
teleportButton.TextSize = 30
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.MouseButton1Click:Connect(function()
    teleportUp(500) -- 真上に500スタッドワープ
    slowTimeEffect() -- ワープ後のスローモーションエフェクト
end)

-- 天井貫通機能
local function stopCeilingPenetrationIfNoCeiling()
    while true do
        if humanoidRootPart.Position.Y < 500 then
            penetrationActive = false -- 貫通を停止
            break
        end
        wait(0.1)
    end
end

-- セキュリティ監視: ワープ後に戻されるのを防ぐ
local function secureSyncWithServer()
    -- サーバー側に位置を通知し、戻されないように設定
    game.ReplicatedStorage.TeleportEvent.OnClientEvent:Connect(function(newPosition)
        humanoidRootPart.CFrame = CFrame.new(newPosition)
    end)
end

-- キャラクターのコリジョンを無効化し、サーバーと同期
disableCollision()
secureSyncWithServer()

-- セキュリティ監視を有効化
stopCeilingPenetrationIfNoCeiling()

