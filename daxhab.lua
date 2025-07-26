--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- アンチキック＆Idled無効化
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
StarterGui:SetCore("ResetButtonCallback", false)

-- UI構築
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインフレーム（ドラッグ対応）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35, 0, 0.45, 0)
mainFrame.Position = UDim2.new(0.33, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ドラッグ処理
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
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ログ表示枠（スクロール対応）
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -10, 0.5, -10)
logBox.Position = UDim2.new(0, 5, 0.2, 5)
logBox.BackgroundColor3 = Color3.new(0, 0, 0)
logBox.TextColor3 = Color3.fromRGB(0, 255, 0)
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextSize = 14
logBox.TextWrapped = true
logBox.Text = "作成者: dax"
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

-- スクロール機能を持つログボックスに修正
logBox.TextTransparency = 1
local scroller = Instance.new("ScrollingFrame")
scroller.Size = UDim2.new(1, -10, 0.5, -10)
scroller.Position = UDim2.new(0, 5, 0.2, 5)
scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
scroller.BackgroundTransparency = 1
scroller.ScrollBarThickness = 5
scroller.Parent = mainFrame

-- ログボックスにスクロールを追加
local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, 0, 0, 100)
logText.Position = UDim2.new(0, 0, 0, 0)
logText.BackgroundTransparency = 1
logText.Font = Enum.Font.Code
logText.TextColor3 = Color3.fromRGB(0, 255, 0)
logText.TextScaled = true
logText.TextWrapped = true
logText.Text = "作成者: dax"
logText.Parent = scroller

local function addLog(text)
    logText.Text = logText.Text .. "\n> " .. text
    scroller.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y + 10)
end

-- ワープ関数（座標変更）
local function safeWarp(height)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        addLog("HumanoidRootPart not found")
        return
    end

    local h = tonumber(height) or 40
    local targetPos = root.Position + Vector3.new(0, h, 0)

    -- ワープを2回行い、強制的にリセットされないようにする
    root.CFrame = CFrame.new(targetPos)
    addLog("Warped ↑ "..tostring(h).." studs")

    -- ネットワークオーナーを設定
    pcall(function()
        root:SetNetworkOwner(player)
    end)

    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 10 then
            conn:Disconnect()
            return
        end
        if root and root.Parent then
            -- 速度や回転をリセット
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            root.CFrame = CFrame.new(targetPos)
            pcall(function()
                root:SetNetworkOwner(player)
            end)
        else
            conn:Disconnect()
        end
    end)
end

-- ワープボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0.4, 0, 0.1, 0)
warpButton.Position = UDim2.new(0.3, 0, 0.75, 0)
warpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
warpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "Warp"
warpButton.Parent = mainFrame

warpButton.MouseButton1Click:Connect(function()
    local val = tonumber(heightInput.Text)
    if not val then
        addLog("Invalid height input")
        return
    end
    safeWarp(val)
end)

-- 透明化ボタン
local transparencyButton = Instance.new("TextButton")
transparencyButton.Size = UDim2.new(0.65, 0, 0.15, 0)
transparencyButton.Position = UDim2.new(0.025, 0, 0.85, 0)
transparencyButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
transparencyButton.TextColor3 = Color3.fromRGB(0, 255, 0)
transparencyButton.Font = Enum.Font.Code
transparencyButton.TextScaled = true
transparencyButton.Text = "[ 透明化 ]"
transparencyButton.Parent = mainFrame

-- ワープ時のビープ音（軽量サウンド）
local beepSound = Instance.new("Sound")
beepSound.SoundId = "rbxassetid://911882704" -- 短いビープ音
beepSound.Volume = 0.6
beepSound.Parent = mainFrame

local function animateButton(btn)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    }):Play()
    beepSound:Play()
    task.wait(0.2)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    }):Play()
end

transparencyButton.MouseButton1Click:Connect(function()
    animateButton(transparencyButton)
    makeInvisible()
    addLog("透明化中...")
end)

-- 起動メッセージ
addLog("起動完了: ！daxhab！ / 作成者: dax")
