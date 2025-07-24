local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 500, 0, 300)
background.Position = UDim2.new(0.5, -250, 0.5, -150)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0
background.BackgroundTransparency = 0.5

-- タイトル
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 500, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 30
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.TextStrokeTransparency = 0.5
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold

-- 仕切り
local divider = Instance.new("Frame")
divider.Parent = background
divider.Size = UDim2.new(0, 500, 0, 2)
divider.Position = UDim2.new(0, 0, 0, 55)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- ボタン作成関数
local function createButton(name, position, defaultColor)
    local button = Instance.new("TextButton")
    button.Parent = background
    button.Size = UDim2.new(0, 450, 0, 60)
    button.Position = position
    button.Text = name
    button.TextSize = 24
    button.BackgroundColor3 = defaultColor
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSansBold
    return button
end

-- ボタン作成
local buttonWarp = createButton("ワープ", UDim2.new(0.5, -225, 0, 70), Color3.fromRGB(255, 0, 0))  
local buttonResetAvoid = createButton("リセット回避: 🔴", UDim2.new(0.5, -225, 0, 150), Color3.fromRGB(255, 0, 0))  

-- ボタンの状態を更新
local function updateButtonState(button, isActive)
    if isActive then
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        button.Text = button.Text:sub(1, -2) .. "🟢"
    else
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        button.Text = button.Text:sub(1, -2) .. "🔴"
    end
end

-- ワープ機能：真上にワープ（オブジェクト貫通）
local function teleportPlayer()
    local successChance = math.random() < 0.999  -- 成功確率99.9%
    if successChance then
        local currentPosition = humanoidRootPart.Position
        local warpHeight = 6.5 * character.Humanoid.HipWidth  -- 高さをキャラ6.5分に設定
        local targetPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- オブジェクトを貫通してワープ
        -- ワープ後の位置にオブジェクトがあっても貫通して移動するようにする
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        updateButtonState(buttonWarp, true)
    else
        updateButtonState(buttonWarp, false)
    end
end

buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープを実行
end)

-- リセット回避
local resetAvoidEnabled = false
local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled
    updateButtonState(buttonResetAvoid, resetAvoidEnabled)
end

-- リセット回避処理
local function enhancedResetAvoid()
    local resetPosition = humanoidRootPart.Position
    game:GetService("RunService").Heartbeat:Connect(function()
        if (humanoidRootPart.Position - resetPosition).Magnitude < 0.1 then
            local newPosition = humanoidRootPart.Position + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
            humanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end)
end

local function serverDetectionAvoid()
    local currentPos = humanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)
    if (currentPos - detectedArea).Magnitude < 100 then
        local newPos = Vector3.new(math.random(-1000, 1000), currentPos.Y, math.random(-1000, 1000))
        humanoidRootPart.CFrame = CFrame.new(newPos)
    end
end

buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()
end)

-- 強化されたリセット回避
enhancedResetAvoid()

game:GetService("RunService").Heartbeat:Connect(function()
    serverDetectionAvoid()
end)
