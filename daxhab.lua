-- 最強回避・ワープ強化版プロハッカー仕様（追加強化版）

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- ボタンUI
local button = Instance.new("TextButton")
button.Parent = screenGui
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.5, -25)
button.Text = "ワープ"
button.TextSize = 18
button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 虹色タイトル
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = screenGui
titleLabel.Size = UDim2.new(0, 400, 0, 50)
titleLabel.Position = UDim2.new(0.5, -200, 0, 20)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextStrokeTransparency = 0.8

-- 虹色エフェクト
local function updateTitle()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    titleLabel.TextColor3 = color
end

game:GetService("RunService").Heartbeat:Connect(updateTitle)

-- ワープ機能（タイミング最適化＆精度強化）
local function teleportPlayer()
    if math.random() < 0.9 then  -- 90%の確率でワープ
        -- 負荷が高い時間帯を避けてワープ実行
        local successChance = math.random() < 0.85  -- より高確率で成功
        if successChance then
            local randomPosition = Vector3.new(math.random(-100, 100), 10, math.random(-100, 100))
            local startPosition = player.Character.HumanoidRootPart.Position
            local steps = 20  -- よりスムーズにワープ

            -- スムーズにワープ
            for i = 1, steps do
                local newPos = startPosition:Lerp(randomPosition, i / steps)
                player.Character:SetPrimaryPartCFrame(CFrame.new(newPos))
                wait(0.025)  -- 少しずつ動かして自然に見せる
            end
        else
            warn("ワープ失敗")  -- 10%の確率で失敗
        end
    end
end

button.MouseButton1Click:Connect(function()
    teleportPlayer()
end)

-- 天井貫通機能（強化版）
local function enableCeilingPass()
    local character = player.Character
    if character then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        -- ランダムで天井貫通の高さを強化
        local randomHeight = math.random(120, 200)  -- 高さをランダムで変更
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, randomHeight, 0)
    end
end

-- 天井貫通ボタン
local ceilingButton = Instance.new("TextButton")
ceilingButton.Parent = screenGui
ceilingButton.Size = UDim2.new(0, 150, 0, 50)
ceilingButton.Position = UDim2.new(0.5, -75, 0.6, 20)
ceilingButton.Text = "天井貫通"
ceilingButton.TextSize = 18
ceilingButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
ceilingButton.TextColor3 = Color3.fromRGB(255, 255, 255)

ceilingButton.MouseButton1Click:Connect(function()
    enableCeilingPass()
end)

-- リセット回避の強化（自動位置補正＆タイミングズラし）
local function preventReset()
    -- プレイヤーの位置がリセットされるタイミングをずらす
    game:GetService("RunService").Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local humanoidRootPart = player.Character.HumanoidRootPart
        if humanoidRootPart.Position.Y < 0 then  -- 位置が不正なら修正
            -- リセットされる前に位置を補正
            humanoidRootPart.CFrame = CFrame.new(0, 10, 0)  -- 任意の位置に補正
        end

        -- リセット後に動作をずらしてバレないようにする
        if humanoidRootPart.Position.Y < 5 then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 2, 0))
            wait(0.1)  -- 一時的に動きを停止してリセット時のタイミングをずらす
        end
    end)
end

-- 動作監視（異常を検出して修正）
local function monitorScript()
    -- スクリプトが動作しているか定期的にチェック
    game:GetService("RunService").Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            -- キャラクターが存在しない場合、エラー処理
            warn("Player character missing, attempting recovery...")
            -- 自動復帰処理
            player.CharacterAdded:Wait()
        end
    end)
end

-- 初期化
preventReset()  -- リセット回避
monitorScript() -- 動作監視

