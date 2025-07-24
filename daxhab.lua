-- daxhab.lua (最新プロハッカーレベル)
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

-- 物理エンジン完全無効化: 物理的な障害物を完全に無視
local function disableCollision()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 物理的な障害物を通過
            part.Anchored = false  -- 物理エンジンによる動きを無効化
        end
    end
end

-- 高度なワープ機能（ターゲット指定ワープ）
local function teleportToTarget(targetPosition)
    -- エフェクト: ワープ前に光の閃光エフェクト
    local warpEffect = Instance.new("Part")
    warpEffect.Shape = Enum.PartType.Ball
    warpEffect.Size = Vector3.new(10, 10, 10)
    warpEffect.Position = humanoidRootPart.Position
    warpEffect.Anchored = true
    warpEffect.CanCollide = false
    warpEffect.Material = Enum.Material.Neon
    warpEffect.Color = Color3.fromRGB(0, 255, 255) -- ワープエフェクト
    warpEffect.Parent = game.Workspace

    -- ワープのアニメーション（瞬間的に位置を変更）
    humanoidRootPart.CFrame = CFrame.new(targetPosition)

    -- エフェクトが完了したら削除
    game.Debris:AddItem(warpEffect, 0.5)

    -- 完全に物理無効化
    disableCollision()

    -- サーバー同期処理（戻されないようにサーバー側に強制的に同期）
    game.ReplicatedStorage:WaitForChild("TeleportEvent"):FireServer(targetPosition)
end

-- ワープボタン：ターゲットワープ（マウス位置など指定した位置にワープ）
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ"
teleportButton.TextSize = 30
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.MouseButton1Click:Connect(function()
    local targetPosition = Vector3.new(mouse.Hit.p.X, mouse.Hit.p.Y, mouse.Hit.p.Z)  -- マウス位置でワープ
    teleportToTarget(targetPosition)
end)

-- 貫通機能（障害物を通過し続ける）
local function enablePenetration()
    -- 貫通対象の障害物を無視し続ける
    disableCollision()

    -- 無限貫通：障害物を貫通し続ける
    while true do
        -- 貫通中にキャラクターを前進させる
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 10) -- 前進貫通
        wait(0.1)  -- 速い貫通速度
    end
end

-- 貫通ボタン：貫通を開始する
local penetrationButton = Instance.new("TextButton")
penetrationButton.Parent = screenGui
penetrationButton.Text = "貫通"
penetrationButton.TextSize = 30
penetrationButton.Size = UDim2.new(0, 200, 0, 50)
penetrationButton.Position = UDim2.new(0.5, -100, 0.7, 0)
penetrationButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
penetrationButton.TextColor3 = Color3.fromRGB(255, 255, 255)
penetrationButton.MouseButton1Click:Connect(function()
    enablePenetration()  -- 貫通開始
end)

-- 無限貫通を開始
local infinitePenetrationButton = Instance.new("TextButton")
infinitePenetrationButton.Parent = screenGui
infinitePenetrationButton.Text = "無限貫通"
infinitePenetrationButton.TextSize = 30
infinitePenetrationButton.Size = UDim2.new(0, 200, 0, 50)
infinitePenetrationButton.Position = UDim2.new(0.5, -100, 0.8, 0)
infinitePenetrationButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
infinitePenetrationButton.TextColor3 = Color3.fromRGB(255, 255, 255)
infinitePenetrationButton.MouseButton1Click:Connect(function()
    enablePenetration()  -- 貫通を続ける
end)

-- サーバー同期強化: ワープ後、サーバー側の位置を強制的に反映
local function secureSyncWithServer()
    game.ReplicatedStorage.TeleportEvent.OnClientEvent:Connect(function(newPosition)
        humanoidRootPart.CFrame = CFrame.new(newPosition)  -- サーバーからの位置情報を強制的に反映
    end)
end

-- 初期化: キャラクターのコリジョン無効化とサーバー同期強化
disableCollision()
secureSyncWithServer()
