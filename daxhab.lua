--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- アンチキック＆Idled無効化
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
StarterGui:SetCore("ResetButtonCallback", false)

-- UI作成
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインフレーム（画面サイズに応じて自動調整）
local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end
local screenSize = workspace.CurrentCamera.ViewportSize
local frameWidth = clamp(screenSize.X * 0.8, 300, 700)
local frameHeight = clamp(screenSize.Y * 0.6, 200, 500)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ドラッグ処理（タッチ＆マウス対応）
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        local newX = clamp(startPos.X.Offset + delta.X, 0, screenSize.X - frameWidth)
        local newY = clamp(startPos.Y.Offset + delta.Y, 0, screenSize.Y - frameHeight)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ロゴ（虹色＆上下揺れ）
local logoText = "！daxhab！"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1, 0, 0.15, 0)
logoHolder.Position = UDim2.new(0, 0, 0, 0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}
for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 25, 1, 0)
    lbl.Position = UDim2.new(0, 25 * (i - 1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = logoText:sub(i, i)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    lbl.TextColor3 = Color3.fromHSV((tick() * 0.15 + i * 0.05) % 1, 1, 1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end
RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(logoLabels) do
        local offset = math.sin(tick() * 8 + i) * 6
        lbl.Position = UDim2.new(0, 25 * (i - 1), 0, offset)
        lbl.TextColor3 = Color3.fromHSV((tick() * 0.3 + i * 0.1) % 1, 1, 1)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ログ（背景に👿の模様を文字列で再現）
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -20, 0.6, -40)
logFrame.Position = UDim2.new(0, 10, 0.15, 50)
logFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
logFrame.ScrollBarThickness = 10
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout", logFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 👿パターン文字列作成（横幅に合わせて変動）
local function makeDevilPattern(width)
    local pattern = ""
    local devilChar = "👿"
    local lineLength = math.floor(width / 18) -- 文字幅18px想定

    for y = 1, 15 do
        local line = ""
        for x = 1, lineLength do
            -- 変な数式で模様を決定
            local val = (math.sin(x * 1.5 + y * 2.3) + math.cos(y * 1.8 - x * 1.1)) * 10
            if math.floor(val) % 2 == 0 then
                line = line .. devilChar
            else
                line = line .. " "
            end
        end
        pattern = pattern .. line .. "\n"
    end
    return pattern
end

-- 背景テキスト（👿模様）
local bgPatternLabel = Instance.new("TextLabel")
bgPatternLabel.Size = UDim2.new(1, 0, 1, 0)
bgPatternLabel.Position = UDim2.new(0, 0, 0, 0)
bgPatternLabel.BackgroundTransparency = 1
bgPatternLabel.TextColor3 = Color3.fromRGB(0, 150, 0)
bgPatternLabel.TextStrokeTransparency = 0.8
bgPatternLabel.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
bgPatternLabel.Font = Enum.Font.Code
bgPatternLabel.TextScaled = false
bgPatternLabel.TextXAlignment = Enum.TextXAlignment.Left
bgPatternLabel.TextYAlignment = Enum.TextYAlignment.Top
bgPatternLabel.Text = makeDevilPattern(logFrame.AbsoluteSize.X)
bgPatternLabel.ZIndex = 1
bgPatternLabel.Parent = logFrame

-- ログ用ラベル群（前面に配置）
local function addLog(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "> " .. text
    lbl.ZIndex = 2
    lbl.Parent = logFrame
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

-- 高さ入力欄
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.3, 0, 0.12, 0)
heightInput.Position = UDim2.new(0.65, 0, 0.78, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
heightInput.TextColor3 = Color3.fromRGB(0, 255, 0)
heightInput.PlaceholderText = "↑スタッド"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local currentHeight = Instance.new("TextLabel")
currentHeight.Size = UDim2.new(0.3, 0, 0.12, 0)
currentHeight.Position = UDim2.new(0.65, 0, 0.9, 0)
currentHeight.BackgroundTransparency = 1
currentHeight.TextColor3 = Color3.fromRGB(0, 255, 0)
currentHeight.Font = Enum.Font.Code
currentHeight.TextScaled = true
currentHeight.Text = "↑: 40"
currentHeight.Parent = mainFrame

heightInput:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(heightInput.Text)
    if val then
        currentHeight.Text = "↑: " .. tostring(val)
    else
        currentHeight.Text = "↑: ?"
    end
end)

-- 保護トグルボタン
local protectionEnabled = true
local protectButton = Instance.new("TextButton")
protectButton.Size = UDim2.new(0.6, 0, 0.12, 0)
protectButton.Position = UDim2.new(0.05, 0, 0.9, 0)
protectButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
protectButton.TextColor3 = Color3.fromRGB(0, 255, 0)
protectButton.Font = Enum.Font.Code
protectButton.TextScaled = true
protectButton.Text = "🟢 保護ON"
protectButton.Parent = mainFrame

protectButton.MouseButton1Click:Connect(function()
    protectionEnabled = not protectionEnabled
    if protectionEnabled then
        protectButton.Text = "🟢 保護ON"
        addLog("保護を有効化")
    else
        protectButton.Text = "🔴 保護OFF"
        addLog("保護を無効化")
    end
end)

-- キャラ保護ループ
local function protectCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    humanoid.BreakJointsOnDeath = false

    humanoid.StateChanged:Connect(function(_, new)
        if protectionEnabled and new == Enum.HumanoidStateType.Dead then
            addLog("死亡検出 - 即回復")
            humanoid.Health = humanoid.MaxHealth
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if protectionEnabled then
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
                humanoid.PlatformStand = false
            end
            if root and root.Parent then
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
                pcall(function()
                    root:SetNetworkOwner(player)
                end)
            end
        end
    end)
end

player.CharacterAdded:Connect(protectCharacter)
protectCharacter()

-- ワープ関数（安全ワープ + 10秒間の座標保護）
local function safeWarp(height)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root then
        addLog("HumanoidRootPartが見つかりません")
        return
    end

    local h = tonumber(height) or 40
    local targetPos = root.Position + Vector3.new(0, h, 0)

    addLog("Warp開始 ↑ "..h.." スタッド")
    protectionEnabled = true
    protectButton.Text = "🟢 保護ON"

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.Health = humanoid.MaxHealth
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end

    root.CFrame = CFrame.new(targetPos)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 10 then
            conn:Disconnect()
            addLog("Warp保護終了")
            return
        end
        if root and root.Parent then
            root.CFrame = CFrame.new(targetPos)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end)
end

-- ワープボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0.3, 0, 0.12, 0)
warpButton.Position = UDim2.new(0.65, 0, 0.9, 0)
warpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
warpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "Warp"
warpButton.Parent = mainFrame

warpButton.MouseButton1Click:Connect(function()
    local val = tonumber(heightInput.Text)
    if not val then
        addLog("高さが無効です")
        return
    end
    safeWarp(val)
end)

addLog("起動完了: ！daxhab！ / 作成者: dax")
