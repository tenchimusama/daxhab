-- 強化版スクリプト設定

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- ボタンUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
button.Text = "daxhab/作者dax"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSans
button.TextSize = 18
button.Parent = screenGui

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

-- 天井貫通強化版
function moveUpUntilNoCeiling()
    local attemptCount = 0
    while attemptCount < 50 do  -- 最大50回試行してそれでも天井に当たったら諦める
        local ray = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, 10, 0))
        if not ray then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)
            attemptCount = attemptCount + 1
        else
            break
        end
        wait(0.1)
    end
end

-- リセット回避強化
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

-- ランダム動き強化
function randomMovement()
    while true do
        -- 微妙な動きで予測を難しく
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(math.random(-0.2, 0.2), 0, math.random(-0.2, 0.2))
        wait(0.1)  -- より早く移動して軌跡を予測不可能にする
    end
end

-- 高度な対策（検知回避強化）
function evasiveManeuver()
    while true do
        -- プレイヤーの動きに予測不可能な遅延やランダム化を加える
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(math.random(-0.5, 0.5), 0, math.random(-0.5, 0.5))
        wait(math.random(0.1, 0.3))  -- 動きにランダムな遅延を加える
    end
end

-- ワープボタンの処理
button.MouseButton1Click:Connect(function()
    -- 真上にワープ
    moveUpUntilNoCeiling()

    -- 物理無効化
    disablePhysics()

    -- リセット回避
    fixReset()

    -- ランダム動きで回避
    randomMovement()

    -- 検知回避強化
    evasiveManeuver()
end)
