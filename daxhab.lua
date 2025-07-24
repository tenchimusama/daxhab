local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景UI（サイズを1/5に縮小）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 120, 0, 60)  -- 横長の長方形
background.Position = UDim2.new(0.5, -60, 0.5, -30)  -- 背景を中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 背景色
background.BorderSizePixel = 0  -- 枠線なし

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 120, 0, 10)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 5
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.TextStrokeTransparency = 0.5
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold

-- 仕切り（ボタンとタイトルの間）
local divider = Instance.new("Frame")
divider.Parent = background
divider.Size = UDim2.new(0, 120, 0, 1)
divider.Position = UDim2.new(0, 0, 0, 15)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- ワープボタン作成
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(0, 100, 0, 20)  -- サイズを1/5に縮小
buttonWarp.Position = UDim2.new(0.5, -50, 0, 20)
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 8
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- 初期色：赤
buttonWarp.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonWarp.BorderSizePixel = 0
buttonWarp.Font = Enum.Font.SourceSansBold

-- リセット回避ボタン作成
local buttonResetAvoid = Instance.new("TextButton")
buttonResetAvoid.Parent = background
buttonResetAvoid.Size = UDim2.new(0, 100, 0, 20)
buttonResetAvoid.Position = UDim2.new(0.5, -50, 0, 50)
buttonResetAvoid.Text = "リセット回避: 🔴"
buttonResetAvoid.TextSize = 8
buttonResetAvoid.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
buttonResetAvoid.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonResetAvoid.BorderSizePixel = 0
buttonResetAvoid.Font = Enum.Font.SourceSansBold

-- ボタンの状態を更新する関数
local function updateButtonState(button, isActive)
    if isActive then
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
        button.Text = button.Text:sub(1, -2) .. "🟢"  -- 実行中
    else
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- 赤色
        button.Text = button.Text:sub(1, -2) .. "🔴"  -- 非実行
    end
end

-- ワープ機能
local function teleportPlayer()
    local successChance = math.random() < 0.999  -- 99.9%の確率で成功
    if successChance then
        local currentPosition = humanoidRootPart.Position
        local warpHeight = 6.5 * character.Humanoid.HipWidth  -- キャラの高さに合わせてワープ
        local targetPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- オブジェクト貫通してワープ
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        updateButtonState(buttonWarp, true)
    else
        updateButtonState(buttonWarp, false)
    end
end

buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープ実行
end)

-- リセット回避のオンオフ切り替え
local resetAvoidEnabled = false
local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled
    updateButtonState(buttonResetAvoid, resetAvoidEnabled)
end

buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()  -- リセット回避のオンオフ切り替え
end)

-- 強化されたリセット回避（プレイヤーがリセットされる前に位置補正）
local function enhancedResetAvoid()
    local resetPosition = humanoidRootPart.Position
    game:GetService("RunService").Heartbeat:Connect(function()
        if (humanoidRootPart.Position - resetPosition).Magnitude < 0.1 then
            local newPosition = humanoidRootPart.Position + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
            humanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end)
end

-- サーバー監視回避（監視範囲から外れた位置に補正）
local function serverDetectionAvoid()
    local currentPos = humanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)
    if (currentPos - detectedArea).Magnitude < 100 then
        local newPos = Vector3.new(math.random(-1000, 1000), currentPos.Y, math.random(-1000, 1000))
        humanoidRootPart.CFrame = CFrame.new(newPos)
    end
end

-- 強化されたリセット回避の実行
enhancedResetAvoid()

game:GetService("RunService").Heartbeat:Connect(function()
    serverDetectionAvoid()  -- サーバー監視回避
end)
