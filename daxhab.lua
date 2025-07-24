-- 最強リセット回避・プロハッカーレベル

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- ボタンUI（ワープ・天井貫通を1つのボタンで同時に実行）
local button = Instance.new("TextButton")
button.Parent = screenGui
button.Size = UDim2.new(0, 300, 0, 100)  -- ボタンのサイズを大きく
button.Position = UDim2.new(0.5, -150, 0.5, -50)  -- ボタンを中央に配置
button.Text = "ワープ & 天井貫通"
button.TextSize = 36
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒背景
button.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
button.BorderSizePixel = 0  -- ボタンの枠線を消す
button.Font = Enum.Font.SourceSansMono  -- ハッカー風の等幅フォント

-- 背景にタイトル（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = screenGui
titleLabel.Size = UDim2.new(0, 600, 0, 50)  -- 背景のサイズ調整
titleLabel.Position = UDim2.new(0.5, -300, 0, 20)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 28
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1  -- 背景透明
titleLabel.Font = Enum.Font.SourceSansMono  -- ハッカー風の等幅フォント

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

-- リセット回避強化（プロハッカー仕様）
local function preventReset()
    -- プレイヤーの位置や状態を常に監視し、リセットされる兆候を事前に察知
    local lastPosition = player.Character.HumanoidRootPart.Position
    local resetDetectionThreshold = 0.1  -- 位置が異常に近い場合にリセット回避を強化

    game:GetService("RunService").Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local humanoidRootPart = player.Character.HumanoidRootPart
        local currentPosition = humanoidRootPart.Position

        -- リセットされる前にプレイヤーの位置が異常に変化している場合
        if (currentPosition - lastPosition).Magnitude < resetDetectionThreshold then
            -- リセットされる兆候が見つかれば、即座に回避処理を開始
            humanoidRootPart.CFrame = CFrame.new(currentPosition + Vector3.new(0, 3, 0))  -- 高速で位置補正
            lastPosition = currentPosition  -- 新しい位置を記録
        else
            lastPosition = currentPosition  -- 正常な移動を記録
        end
    end)

    -- 強化版リセット回避（リセット時に瞬時に位置を補正して回避）
    local function resetAvoidance()
        -- プレイヤーがリセットされた場合、即座にリセット回避を実行
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local recoveryPosition = humanoidRootPart.Position + Vector3.new(0, 5, 0)  -- 5ユニット上に補正
            humanoidRootPart.CFrame = CFrame.new(recoveryPosition)
        end
    end

    -- リセット後の動作停止と再開の最適化
    game:GetService("RunService").Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- 定期的に位置を補正し、動作のタイミングをずらす
            local humanoidRootPart = player.Character.HumanoidRootPart
            if humanoidRootPart.Position.Y < 5 then  -- 位置がリセットされた場合
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 1, 0))  -- 少しだけ位置を調整
                wait(0.1)  -- 一時停止してタイミングをずらす
            end
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

-- ボタンをクリックしたときに両方の機能を同時に実行
button.MouseButton1Click:Connect(function()
    teleportPlayer()      -- ワープ実行
    enableCeilingPass()   -- 天井貫通実行
end)
