-- daxhab.lua
-- タイトル: daxhab
-- 作者名: dax
-- フォント: ハッカー風タイピング演出（世界にないレベル）

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = game.Workspace.CurrentCamera

-- 初期配置: 真ん中に配置（必ず真ん中に配置される）
character:SetPrimaryPartCFrame(CFrame.new(0, 50, 0)) -- 初期位置を真ん中に設定

-- タイピング演出: ハッカー風フォント
local text = Instance.new("TextLabel")
text.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
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
    -- ワープ後に再度貫通を確認
    local newPosition = Vector3.new(humanoidRootPart.Position.X, height, humanoidRootPart.Position.Z)
    humanoidRootPart.CFrame = CFrame.new(newPosition)
    enableCeilingPenetration()  -- ワープ後に貫通機能を再起動
end

-- ワープボタン
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
teleportButton.Text = "ワープ"
teleportButton.TextSize = 30
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.MouseButton1Click:Connect(function()
    teleportToHeight(500)  -- 高さ500にワープ
end)

-- 天井貫通機能: 高速貫通
local function enableCeilingPenetration()
    -- 高速で貫通する処理
    local function onCharacterMove()
        -- もし天井に達した場合、さらに貫通して進む
        if humanoidRootPart.Position.Y >= 500 then
            -- 高速貫通を加速
            local newPosition = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + 100, humanoidRootPart.Position.Z)
            humanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end

    -- キャラクターが動くたびに貫通確認
    character:WaitForChild("Humanoid").Running:Connect(onCharacterMove)
end

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
end)

-- セキュリティ監視を有効化
secureScriptExecution()
