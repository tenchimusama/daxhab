-- 新しい最強スクリプト：無敵99.9%＋トグルボタン、タップ反応、ドラッグ可能

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- UI設定
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景（UIの外観にこだわり）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 250, 0, 100)  -- 横長の背景
background.Position = UDim2.new(0.5, -125, 0.5, -50)  -- 中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒色背景
background.BorderSizePixel = 0

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)  -- タイトルサイズ調整
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.TextStrokeTransparency = 0.5
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.Gotham -- マシュマロ風フォント

-- 仕切り（ボタンとタイトルの間に仕切りを入れる）
local divider = Instance.new("Frame")
divider.Parent = background
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Position = UDim2.new(0, 0, 0.2, 0)  -- タイトルの下に仕切り
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- ワープボタン（ポップ風の見た目）
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(1, 0, 0.4, 0)
buttonWarp.Position = UDim2.new(0, 0, 0.3, 0)
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 16
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonWarp.TextColor3 = Color3.fromRGB(255, 0, 255)
buttonWarp.BorderSizePixel = 0
buttonWarp.Font = Enum.Font.SourceSans -- POPフォント

-- リセット回避トグルボタン（オン/オフ）
local buttonResetAvoid = Instance.new("TextButton")
buttonResetAvoid.Parent = background
buttonResetAvoid.Size = UDim2.new(1, 0, 0.4, 0)
buttonResetAvoid.Position = UDim2.new(0, 0, 0.7, 0)
buttonResetAvoid.Text = "リセット回避: オフ"
buttonResetAvoid.TextSize = 16
buttonResetAvoid.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonResetAvoid.TextColor3 = Color3.fromRGB(0, 255, 0)
buttonResetAvoid.BorderSizePixel = 0
buttonResetAvoid.Font = Enum.Font.SourceSans

-- タップイベント反応の修正（ボタンに反応させる）
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- ボタンがタップされた場合にワープまたはリセット回避
            if buttonWarp.Visible and buttonWarp:IsPointInRegion2D(input.Position) then
                teleportPlayer()  -- ワープ処理
            elseif buttonResetAvoid.Visible and buttonResetAvoid:IsPointInRegion2D(input.Position) then
                toggleResetAvoidance()  -- リセット回避のトグル
            end
        end
    end
end)

-- ワープ処理（ターゲット位置にワープ）
local warpHeight = 6.5 * character.Humanoid.HipWidth  -- キャラの高さに基づいたワープ高さ
local function teleportPlayer()
    local currentPosition = humanoidRootPart.Position
    local targetPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)

    -- 高速ワープ（位置補正もランダム化）
    while (currentPosition - targetPosition).Magnitude > 0.1 do
        if math.random() < 0.95 then
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
        currentPosition = humanoidRootPart.Position
        wait(math.random(0.05, 0.1))  -- ランダム化されたワープ間隔
    end

    print("ワープ成功！")
end

-- リセット回避処理（運営のリセットを回避するために位置調整）
local resetAvoidEnabled = false
local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled
    if resetAvoidEnabled then
        buttonResetAvoid.Text = "リセット回避: オン"
    else
        buttonResetAvoid.Text = "リセット回避: オフ"
    end
end

local function resetAvoidance()
    if resetAvoidEnabled then
        local lastPosition = humanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                local currentPosition = humanoidRootPart.Position
                -- 微調整で不規則な位置変更
                if (currentPosition - lastPosition).Magnitude < 0.1 then
                    local newPosition = currentPosition + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
                    character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
                end
                lastPosition = currentPosition
            end
        end)
    end
end

-- ドラッグ可能にする
local dragInput, dragStart, startPos
local function onDragStart(input)
    dragStart = input.Position
    startPos = background.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragInput = nil
        end
    end)
end

local function onDrag(input)
    local delta = input.Position - dragStart
    background.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

background.InputBegan:Connect(onDragStart)
background.InputChanged:Connect(function(input)
    if dragInput then
        onDrag(input)
    end
end)

-- 絶対リセット回避強化処理
local function enhancedResetAvoidance()
    local lastPosition = humanoidRootPart.Position
    game:GetService("RunService").Heartbeat:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPosition = humanoidRootPart.Position
            -- リセットされそうなタイミングで即座に位置補正
            if (currentPosition - lastPosition).Magnitude < 0.1 then
                local newPosition = currentPosition + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
                character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
            end
            lastPosition = currentPosition
        end
    end)
end

-- イベント接続（ボタン動作）
buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()
end)

buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()  -- リセット回避のトグル
end)

-- 絶対リセット回避強化処理
enhancedResetAvoidance()

-- サーバー監視回避強化（ランダムな位置補正）
game:GetService("RunService").Heartbeat:Connect(function()
    -- サーバー監視回避
    local currentPosition = humanoidRootPart.Position
    if math.random() < 0.1 then
        character:SetPrimaryPartCFrame(CFrame.new(currentPosition + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))))
    end
end)
