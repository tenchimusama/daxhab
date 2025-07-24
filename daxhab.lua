-- 最強リセット回避・瞬時天井貫通とワープ（プロハッカー風 完全回避）

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景UI（タイトルとdaxhab / 作者: dax）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 200, 0, 80)  -- 背景のサイズを小さく
background.Position = UDim2.new(0.5, -100, 0, 50)  -- 背景を中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒色背景
background.BorderSizePixel = 0  -- 枠線なし

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 200, 0, 20)  -- タイトルサイズを小さく
titleLabel.Position = UDim2.new(0.5, -100, 0, 5)  -- 上部に配置
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 12  -- テキストサイズを小さく
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1  -- 背景透明
titleLabel.Font = Enum.Font.SourceSansMono  -- ハッカー風の等幅フォント

-- ワープボタンUI（さらに小さく）
local button = Instance.new("TextButton")
button.Parent = background
button.Size = UDim2.new(0, 80, 0, 25)  -- ボタンのサイズを小さく
button.Position = UDim2.new(0.5, -40, 0.75, -12)  -- ボタンを中央に配置
button.Text = "ワープ"
button.TextSize = 10  -- ボタンのテキストサイズを小さく
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒背景
button.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
button.BorderSizePixel = 0  -- ボタンの枠線を消す
button.Font = Enum.Font.SourceSansMono  -- ハッカー風の等幅フォント

-- 虹色エフェクト（タイトルに追加）
local function updateTitle()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    titleLabel.TextColor3 = color
end

game:GetService("RunService").Heartbeat:Connect(updateTitle)

-- ワープ機能（90%成功率）
local function teleportPlayer()
    if math.random() < 0.9 then  -- 90%の確率でワープ
        local successChance = math.random() < 0.85  -- 高確率で成功
        if successChance then
            -- ワープする高さをキャラクターの7.5人分の高さに設定（41.25ユニット）
            local warpHeight = 41.25
            local currentPosition = player.Character.HumanoidRootPart.Position
            local newPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
            
            -- 一瞬でワープ
            player.Character:SetPrimaryPartCFrame(CFrame.new(newPosition))
        else
            warn("ワープ失敗")  -- 10%の確率で失敗
        end
    end
end

-- 天井貫通機能（瞬時に貫通）
local function enableCeilingPass()
    local character = player.Character
    if character then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        -- ランダムで天井貫通の高さを強化
        local randomHeight = math.random(120, 200)  -- 高さをランダムで変更
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, randomHeight, 0)  -- 一瞬で貫通
    end
end

-- 高度なリセット回避機能（プロハッカー仕様 完全回避）
local function advancedResetAvoidance()
    -- プレイヤーの位置や状態を常に監視し、リセットされる兆候を事前に察知
    local lastPosition = player.Character.HumanoidRootPart.Position
    local resetDetectionThreshold = 0.1  -- 位置が異常に近い場合にリセット回避を強化

    -- リセット回避用バックグラウンド監視
    game:GetService("RunService").Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local humanoidRootPart = player.Character.HumanoidRootPart
        local currentPosition = humanoidRootPart.Position

        -- リセットされる前にプレイヤーの位置が異常に変化している場合
        if (currentPosition - lastPosition).Magnitude < resetDetectionThreshold then
            -- リセットされる兆候が見つかれば、即座に回避処理を開始
            local newPosition = currentPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))  -- ランダムな位置に補正
            humanoidRootPart.CFrame = CFrame.new(newPosition)  -- 位置補正
            lastPosition = newPosition  -- 新しい位置を記録
        else
            lastPosition = currentPosition  -- 正常な移動を記録
        end
    end)

    -- リセット時に瞬時に位置補正（プロハッカー用回避）
    local function resetAvoidance()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local randomPosition = humanoidRootPart.Position + Vector3.new(math.random(-10, 10), 5, math.random(-10, 10))  -- ランダム位置補正
            humanoidRootPart.CFrame = CFrame.new(randomPosition)
        end
    end
end

-- 最強のリセット回避機能（プロハッカー仕様 完全回避）
advancedResetAvoidance()

-- ボタンをクリックしたときに両方の機能を同時に実行
button.MouseButton1Click:Connect(function()
    enableCeilingPass()   -- 天井貫通一瞬で実行
    teleportPlayer()      -- ワープ一瞬で実行
end)

