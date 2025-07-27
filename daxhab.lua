--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 既存UIを消す（重複防止）
local existing = playerGui:FindFirstChild("DaxhabUI")
if existing then
    existing:Destroy()
end

-- アンチキック＆Idled無効化
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
StarterGui:SetCore("ResetButtonCallback", false)

-- ScreenGui作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインFrame（スマホ対応固定サイズ）
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 400)
frame.Position = UDim2.new(0.5, -175, 0.5, -200)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true -- 公式ドラッグ対応でスマホOK

-- ロゴラベル群
local logoText = "！daxhab！"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1, 0, 0, 40)
logoHolder.Position = UDim2.new(0, 0, 0, 0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = frame

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
    lbl.TextStrokeColor3 = Color3.new(0, 1, 0)
    lbl.TextColor3 = Color3.fromHSV((tick() * 0.15 + i * 0.05) % 1, 1, 1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end

-- ロゴのゆらゆら虹色変化
RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(logoLabels) do
        local offset = math.sin(tick() * 8 + i) * 5
        lbl.Position = UDim2.new(0, 25 * (i - 1), 0, offset)
        lbl.TextColor3 = Color3.fromHSV((tick() * 0.25 + i * 0.07) % 1, 1, 1)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ログ用スクロールフレーム
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -20, 1, -100)
logFrame.Position = UDim2.new(0, 10, 0, 50)
logFrame.BackgroundColor3 = Color3.new(0, 0, 0)
logFrame.ScrollBarThickness = 10
logFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout", logFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 👿絵文字風の背景色数式でログを生成（パターン化）
local function createDevilBG(index)
    local x = index * 0.3
    local y = index * 0.7
    local r = 0.5 + 0.5 * math.sin(x * 10)
    local g = 0.1 + 0.9 * math.cos(y * 15)
    local b = 0.1 + 0.9 * math.sin(x * y * 20)
    return Color3.new(r, g, b)
end

-- ログ追加関数
local logCount = 0
local function addLog(text)
    logCount = logCount + 1
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundColor3 = createDevilBG(logCount)
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.Font = Enum.Font.Code
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "👿 " .. text
    label.Parent = logFrame
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

-- スタッド入力欄
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.5, 0, 0, 40)
heightInput.Position = UDim2.new(0, 10, 1, -45)
heightInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
heightInput.TextColor3 = Color3.fromRGB(0, 255, 0)
heightInput.PlaceholderText = "↑スタッド"
heightInput.Text = "40"
heightInput.Font = Enum.Font.Code
heightInput.TextScaled = true
heightInput.ClearTextOnFocus = false
heightInput.Parent = frame

-- 保護フラグ
local protectionEnabled = true

-- 保護トグルボタン
local protectButton = Instance.new("TextButton")
protectButton.Size = UDim2.new(0.65, 0, 0, 40)
protectButton.Position = UDim2.new(0, 10, 1, -90)
protectButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
protectButton.TextColor3 = Color3.fromRGB(0, 255, 0)
protectButton.Font = Enum.Font.Code
protectButton.TextScaled = true
protectButton.Text = "🟢 保護ON"
protectButton.Parent = frame

protectButton.MouseButton1Click:Connect(function()
    protectionEnabled = not protectionEnabled
    if protectionEnabled then
        protectButton.Text = "🟢 保護ON"
        addLog("保護を有効化しました")
    else
        protectButton.Text = "🔴 保護OFF"
        addLog("保護を無効化しました")
    end
end)

-- Warpボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0.3, 0, 0, 40)
warpButton.Position = UDim2.new(0.68, 0, 1, -90)
warpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
warpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "Warp"
warpButton.Parent = frame

-- UI最小化ボタン
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0.1, 0, 0, 40)
minimizeButton.Position = UDim2.new(0.9, 0, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.Code
minimizeButton.TextScaled = true
minimizeButton.Text = "ー"
minimizeButton.Parent = frame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in ipairs(frame:GetChildren()) do
        if child ~= logoHolder and child ~= minimizeButton then
            child.Visible = not minimized
        end
    end
    addLog(minimized and "UIを最小化しました" or "UIを展開しました")
end)

-- キャラ保護ループ
local function protectCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    humanoid.BreakJointsOnDeath = false

    humanoid.StateChanged:Connect(function(_, new)
        if protectionEnabled and new == Enum.HumanoidStateType.Dead then
            addLog("死亡検出 → 即回復！")
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

-- Warp機能（10秒間位置固定保護付き）
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

    addLog("Warp開始 ↑ " .. h .. " スタッド")
    protectionEnabled = true
    protectButton.Text = "🟢 保護ON"

    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        humanoid.Health = humanoid.MaxHealth
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

warpButton.MouseButton1Click:Connect(function()
    local val = tonumber(heightInput.Text)
    if not val then
        addLog("無効な高さです")
        return
    end
    safeWarp(val)
end)

-- 起動ログ
addLog("起動完了！ ！daxhab！ / 作者:dax")

