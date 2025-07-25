-- 最強スクリプト設定

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- ボタンUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, game:GetService("Workspace").CurrentCamera.ViewportSize.X / 8, 0, game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 8)  -- 画面の8分の1
button.Position = UDim2.new(0.5, -game:GetService("Workspace").CurrentCamera.ViewportSize.X / 16, 0.5, -game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 16)  -- 中央に配置
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 背景を透明にして虹色に変更
button.Text = "daxhab/作者dax"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSans
button.TextSize = 20
button.TextStrokeTransparency = 0.7  -- テキストの輪郭を少し透明にしてスタイリッシュに

-- 虹色の背景をアニメーションで変更
local function createRainbowBackground()
    local gradient = Instance.new("UIGradient")
    gradient.Parent = button
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(75, 0, 130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 130, 238))
    }
    gradient.Rotation = 90  -- 横に虹色が流れるように
end

createRainbowBackground()

-- ボタンドラッグ機能
local dragging = false
local dragStartPos = nil
local buttonStartPos = nil

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        buttonStartPos = button.Position
    end
end)

button.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        button.Position = buttonStartPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 真上にワープし続け、天井がなくなるまで貫通する
function moveUpUntilNoCeiling()
    local attemptCount = 0
    local maxAttempts = 50
    while attemptCount < maxAttempts do
        local ray = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, 10, 0))
        if not ray then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)
            attemptCount = attemptCount + 1
        else
            break
        end
        wait(0.1)
    end
    if attemptCount == maxAttempts then
        warn("天井貫通失敗: 最大試行回数を超えました")
    end
end

-- 最上階に到達した後、動かなくなる
function stayAtTop()
    while true do
        local ray = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, 10, 0))
        if not ray then
            -- 最上階に到達したらここで止まる
            break
        end
        wait(0.1)
    end
end

-- リセット回避機能
function fixReset()
    while true do
        -- リセットの発生を高精度で検知
        local position = humanoidRootPart.Position
        if position.Y < -100 then  -- 通常のリセット判定
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2))
        end
        wait(0.2)  -- より頻繁にチェック
    end
end

-- 物理エンジン無効化強化
function disablePhysics()
    humanoid.PlatformStand = true
    humanoidRootPart.CanCollide = false
end

-- ワープボタンの処理
button.MouseButton1Click:Connect(function()
    -- 真上にワープ
    moveUpUntilNoCeiling()

    -- 最上階で止まる
    stayAtTop()

    -- 物理無効化
    disablePhysics()

    -- リセット回避
    fixReset()
end)
