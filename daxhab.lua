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

-- ワープ機能: 真上にワープ
local function teleportUp(distance)
    -- 位置変更
    local newPosition = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + distance, humanoidRootPart.Position.Z)
    
    -- 物理エンジン無効化（移動後、再度無効化）
    disableCollision()

    -- サーバーとの同期：ワープ後、サーバーにその位置情報を送信（戻されないように）
    game.ReplicatedStorage:WaitForChild("TeleportEvent"):FireServer(newPosition)
    
    -- 位置を強制的に変更
    humanoidRootPart.CFrame = CFrame.new(newPosition)
    
    -- 貫通機能を再起動
    enableCeilingPenetration()
end

-- ワープボタン（真上にワープ）
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
end)

-- 天井貫通機能: 高速貫通（天井がなくなったら停止）
local ceilingHeight = 500 -- 天井の高さ
local penetrationActive = false -- 貫通がアクティブかどうか

local function enableCeilingPenetration()
    penetrationActive = true
    local function onCharacterMove()
        if penetrationActive then
            -- キャラクターが天井の高さに達した場合、貫通を続ける
            if humanoidRootPart.Position.Y >= ceilingHeight then
                -- 高速貫通を加速
                local newPosition = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + 100, humanoidRootPart.Position.Z)
                humanoidRootPart.CFrame = CFrame.new(newPosition)
            end
        end
    end

    -- キャラクターが動くたびに貫通確認
    character:WaitForChild("Humanoid").Running:Connect(onCharacterMove)
end

-- 天井がなくなったら貫通を停止
local function stopCeilingPenetrationIfNoCeiling()
    while true do
        if humanoidRootPart.Position.Y < ceilingHeight then
            penetrationActive = false -- 貫通を停止
            print("天井がなくなったため、貫通を停止しました。")
            break
        end
        wait(0.1)
    end
end

-- 監視機能: ワープ後に戻されるのを防ぐ
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
