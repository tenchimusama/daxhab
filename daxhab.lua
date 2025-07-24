-- 基本設定
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- スクリーンUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "WarpUI"

-- 背景
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 300, 0, 150)  -- サイズ変更
background.Position = UDim2.new(0.5, -150, 0.5, -75)  -- 画面中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0
background.BackgroundTransparency = 0.5  -- 半透明

-- ボタン作成
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(0, 250, 0, 50)
buttonWarp.Position = UDim2.new(0.5, -125, 0.5, -25)
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 20
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonWarp.TextColor3 = Color3.fromRGB(0, 0, 0)
buttonWarp.BorderSizePixel = 2
buttonWarp.Font = Enum.Font.SourceSansBold
buttonWarp.TextStrokeTransparency = 0.8

-- ワープ機能（99.9%成功）
local function teleportPlayer()
    local successChance = math.random() < 0.999  -- 99.9%の確率で成功
    if successChance then
        local currentPosition = humanoidRootPart.Position
        local warpHeight = 6.5 * character.Humanoid.HipWidth  -- キャラの高さ
        local targetPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- 高速ワープ
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        print("ワープ成功！")
    else
        print("ワープ失敗")
    end
end

-- ワープボタンが押されたらワープ処理
buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()
end)

-- ドラッグ機能（背景フレームをドラッグ可能）
local dragging = false
local dragStart = nil
local startPos = nil

background.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = background.Position
    end
end)

background.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        background.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 強化版リセット回避
local function enhancedResetAvoid()
    local resetPosition = humanoidRootPart.Position
    game:GetService("RunService").Heartbeat:Connect(function()
        if (humanoidRootPart.Position - resetPosition).Magnitude < 0.1 then
            -- 即座に位置補正
            local newPosition = humanoidRootPart.Position + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
            humanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end)
end

-- 監視回避処理
local function serverDetectionAvoid()
    local currentPos = humanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)  -- 監視される範囲を指定（仮）

    if (currentPos - detectedArea).Magnitude < 100 then
        -- 監視範囲内に入った場合、位置をランダムに変更して監視回避
        local newPos = Vector3.new(math.random(-1000, 1000), currentPos.Y, math.random(-1000, 1000))
        humanoidRootPart.CFrame = CFrame.new(newPos)
        print("監視回避中")
    end
end

-- リセット回避を有効化
enhancedResetAvoid()

-- 監視回避をチェック
game:GetService("RunService").Heartbeat:Connect(function()
    serverDetectionAvoid()  -- サーバーの監視回避
end)
