-- 完全リセット回避・天井貫通とワープ（プロハッカー仕様）

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景UI（タイトルとdaxhab / 作者: dax）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 120, 0, 40)  -- 横長の長方形にして高さを半分に設定
background.Position = UDim2.new(0.5, -60, 0.5, -20)  -- 背景を中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒色背景
background.BorderSizePixel = 0  -- 枠線なし

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 120, 0, 10)  -- タイトルサイズを小さく
titleLabel.Position = UDim2.new(0.5, -60, 0, 0)  -- 上部に配置
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 8  -- テキストサイズを小さく
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1  -- 背景透明
titleLabel.Font = Enum.Font.Gotham -- マシュマロ風のフォントに変更

-- 仕切り（ボタンとタイトルの間に仕切りを入れる）
local divider = Instance.new("Frame")
divider.Parent = background
divider.Size = UDim2.new(0, 120, 0, 1)  -- 仕切りのサイズを小さく
divider.Position = UDim2.new(0.5, -60, 0, 15)  -- 仕切りの位置
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 白色の仕切り

-- ワープボタンUI（横長、文字色虹色）
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(1, 0, 0.3, 0)  -- 横長のボタン、背景に合わせて調整
buttonWarp.Position = UDim2.new(0, 0, 0.5, 0)  -- ボタンを背景内で配置
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 10  -- ボタンのテキストサイズを少し大きく
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 白背景
buttonWarp.TextColor3 = Color3.fromRGB(255, 0, 255)  -- 初期文字色（虹色に変更予定）
buttonWarp.BorderSizePixel = 0  -- ボタンの枠線を消す
buttonWarp.Font = Enum.Font.SourceSans -- POP風フォントに変更

-- リセット回避ボタンUI（横長）
local buttonResetAvoid = Instance.new("TextButton")
buttonResetAvoid.Parent = background
buttonResetAvoid.Size = UDim2.new(1, 0, 0.3, 0)  -- 横長ボタン
buttonResetAvoid.Position = UDim2.new(0, 0, 0.85, 0)  -- リセット回避ボタンを配置
buttonResetAvoid.Text = "リセット回避: オフ"
buttonResetAvoid.TextSize = 10  -- テキストサイズを少し大きく
buttonResetAvoid.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 白背景
buttonResetAvoid.TextColor3 = Color3.fromRGB(255, 0, 255)  -- 初期文字色（虹色に変更予定）
buttonResetAvoid.BorderSizePixel = 0  -- ボタンの枠線を消す
buttonResetAvoid.Font = Enum.Font.SourceSans -- POP風フォントに変更

-- 虹色エフェクト（ボタンに追加）
local function updateButtonTextColor()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    buttonWarp.TextColor3 = color
    buttonResetAvoid.TextColor3 = color
end

game:GetService("RunService").Heartbeat:Connect(updateButtonTextColor)

-- ワープ機能（真上にワープ、ワープの高さを半分に設定）
local function teleportPlayer()
    local successChance = math.random() < 0.99  -- 99%の確率で成功
    if successChance then
        -- 高さを半分に設定（キャラクターの3.75人分の高さ）
        local warpHeight = 10.3125  -- 半分の高さ
        local currentPosition = player.Character.HumanoidRootPart.Position
        local newPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- 一瞬でワープ
        player.Character:SetPrimaryPartCFrame(CFrame.new(newPosition))
    else
        warn("ワープ失敗")  -- 1%の確率で失敗
    end
end

-- 天井貫通機能（瞬時に貫通）
local function enableCeilingPass()
    local character = player.Character
    if character then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        -- 高さを強化して天井貫通
        local randomHeight = math.random(120, 200)  -- 高さをランダムで変更
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, randomHeight, 0)  -- 一瞬で貫通
    end
end

-- リセット回避（プロハッカー仕様）
local resetAvoidEnabled = false  -- リセット回避を初期状態でオフに設定

local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled  -- オン/オフを切り替える

    -- ボタンテキストを更新
    if resetAvoidEnabled then
        buttonResetAvoid.Text = "リセット回避: オン"
    else
        buttonResetAvoid.Text = "リセット回避: オフ"
    end
end

-- **最強リセット回避機能（プロハッカー仕様）**
local function resetAvoidance()
    if resetAvoidEnabled then
        local lastPosition = player.Character.HumanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = player.Character.HumanoidRootPart
                local currentPosition = humanoidRootPart.Position
                
                -- **リセットされそうなタイミング**を予測し、即座に位置を補正
                if (currentPosition - lastPosition).Magnitude < 0.1 then
                    -- 位置が近くなったら即座に補正
                    local newPosition = currentPosition + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))  -- より広範囲で補正
                    humanoidRootPart.CFrame = CFrame.new(newPosition)
                end
                lastPosition = currentPosition  -- 新しい位置を記録
            end
        end)
    end
end

-- ワープボタンのクリック処理
buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープを実行
    enableCeilingPass()  -- 天井貫通を実行
end)

-- リセット回避ボタンのクリック処理
buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()  -- リセット回避のオン/オフを切り替え
end)

-- リセット回避の監視
resetAvoidance()

-- ドラッグ機能を追加
local dragging = false
local dragInput, dragStart, dragPos

background.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragInput = input
    end
end)

background.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        dragPos = input.Position - dragStart
        background.Position = UDim2.new(0, dragPos.X, 0, dragPos.Y)
    end
end)

background.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)


