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

-- ワープ機能: 高速かつ安全なワープ
local function teleportToHeight(height)
    -- 位置変更
    local newPosition = Vector3.new(humanoidRootPart.Position.X, height, humanoidRootPart.Position.Z)
    
    -- サーバーとの同期: ワープ後の位置を強制的に変更
    humanoidRootPart.CFrame = CFrame.new(newPosition)
    
    -- 貫通機能を再起動
    enableCeilingPenetration()  
end

-- ワープボタン
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ"
teleportButton.TextSize = 30
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.MouseButton1Click:Connect(function()
    teleportToHeight(500) -- 高さ500にワープ
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

-- 物理エンジン回避: 物理的なコリジョンを無効化
local function disableCollision()
    -- `CanCollide` を無効化して、物理的な障害物を通過できるようにする
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- 不正な検出を防ぐためにサーバーとの同期を強化
local function secureSyncWithServer()
    -- ワープ後、サーバーに通知し、再度位置が戻されないようにする
    game.ReplicatedStorage:WaitForChild("TeleportEvent"):FireServer(humanoidRootPart.Position)
end

-- ワープ後にサーバーの位置戻しを防ぐための強化された同期
game.ReplicatedStorage.TeleportEvent.OnClientEvent:Connect(function(newPosition)
    humanoidRootPart.CFrame = CFrame.new(newPosition)
end)

-- セキュリティ強化 - 監視機能
local function secureScriptExecution()
    -- プレイヤーが不正行動をしていないか監視
    local function checkForIllegalActions()
        while true do
            if humanoidRootPart.Position.Y > 1000 then
                -- 高すぎる位置にいる場合、即座に停止
                print("不正なワープが検出されました!")
                return
            end
            wait(0.1)
        end
    end

    -- セキュリティ監視開始
    checkForIllegalActions()
end

-- 初期設定の起動
teleportButton.MouseButton1Click:Connect(function()
    teleportToHeight(500)
    enableCeilingPenetration()
    disableCollision() -- 物理エンジン回避
    secureSyncWithServer() -- サーバーとの同期強化
end)

-- 天井がなくなったら停止する監視を開始
stopCeilingPenetrationIfNoCeiling()

-- セキュリティ監視を有効化
secureScriptExecution()
