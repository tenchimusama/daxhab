--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- ✅ アンチキック & Idled無効化
player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
StarterGui:SetCore("ResetButtonCallback", false)

-- ✅ UI構築（スマホ対応）
local gui = Instance.new("ScreenGui")
gui.Name = "DaxhabUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.45, 0, 0.45, 0)
frame.Position = UDim2.new(0.27, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Parent = gui

-- ✅ ドラッグ対応（タッチOK）
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragStart = dragStart or input.Position
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragStart then
        local delta = UserInputService:GetMouseLocation() - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ✅ ロゴ & アニメーション
local logoText = "！daxhab！"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1, 0, 0.15, 0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = frame

local labels = {}
for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 18, 1, 0)
    lbl.Position = UDim2.new(0, 18 * (i - 1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = logoText:sub(i, i)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,255,0)
    lbl.TextColor3 = Color3.fromHSV((tick() * 0.2 + i * 0.08) % 1, 1, 1)
    lbl.Parent = logoHolder
    table.insert(labels, lbl)
end
RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(labels) do
        lbl.TextColor3 = Color3.fromHSV((tick() * 0.3 + i * 0.05) % 1, 1, 1)
    end
end)

-- ✅ ログエリア
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -10, 0.4, -10)
logFrame.Position = UDim2.new(0, 5, 0.15, 5)
logFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
logFrame.ScrollBarThickness = 6
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.Parent = frame
Instance.new("UIListLayout", logFrame)

local function addLog(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0,255,0)
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "> " .. txt
    lbl.Parent = logFrame
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

-- ✅ 入力欄（高さ指定）
local input = Instance.new("TextBox")
input.Size = UDim2.new(0.3, 0, 0.1, 0)
input.Position = UDim2.new(0.65, 0, 0.6, 0)
input.BackgroundColor3 = Color3.fromRGB(20,20,20)
input.TextColor3 = Color3.fromRGB(0,255,0)
input.PlaceholderText = "高さ"
input.Text = "50"
input.TextScaled = true
input.Font = Enum.Font.Code
input.ClearTextOnFocus = false
input.Parent = frame

-- ✅ Warp関数（完全版）
local function safeWarp(h)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    -- 移動安全処理
    hum.PlatformStand = false
    hum:ChangeState(Enum.HumanoidStateType.Running)
    hum.Health = hum.MaxHealth
    hum.WalkSpeed = 16
    hum.JumpPower = 50

    -- Warp実行
    local target = root.Position + Vector3.new(0, h, 0)
    root.CFrame = CFrame.new(target)
    root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero

    addLog("Warp ↑ " .. tostring(h) .. " studs")

    -- Warp保護10秒
    local start = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - start > 10 then conn:Disconnect() return end
        if root and root.Parent then
            root.CFrame = CFrame.new(target)
            root.Velocity = Vector3.zero
            hum.PlatformStand = false
            hum.Health = hum.MaxHealth
        end
    end)
end

-- ✅ Warpボタン
local warpBtn = Instance.new("TextButton")
warpBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
warpBtn.Position = UDim2.new(0.3, 0, 0.75, 0)
warpBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
warpBtn.TextColor3 = Color3.new(1,1,1)
warpBtn.Font = Enum.Font.Code
warpBtn.TextScaled = true
warpBtn.Text = "Warp"
warpBtn.Parent = frame
warpBtn.MouseButton1Click:Connect(function()
    local val = tonumber(input.Text)
    if val then safeWarp(val) else addLog("数値を入力") end
end)

-- ✅ 完全透明化（ツール・アクセサリ含む）
local function makeInvisible()
    local char = player.Character or player.CharacterAdded:Wait()
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        elseif obj:IsA("Decal") then
            obj.Transparency = 1
        end
    end
end

local invisBtn = Instance.new("TextButton")
invisBtn.Size = UDim2.new(0.65, 0, 0.12, 0)
invisBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
invisBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
invisBtn.TextColor3 = Color3.fromRGB(0,255,0)
invisBtn.Text = "[透明化]"
invisBtn.Font = Enum.Font.Code
invisBtn.TextScaled = true
invisBtn.Parent = frame
invisBtn.MouseButton1Click:Connect(function()
    makeInvisible()
    addLog("キャラ完全透明化完了")
end)

-- ✅ 死亡回避・硬直防止
local function protect()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum.BreakJointsOnDeath = false
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Dead then
            hum.Health = hum.MaxHealth
            hum.PlatformStand = false
        end
    end)
    RunService.Heartbeat:Connect(function()
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.PlatformStand = false
        hum.Health = hum.MaxHealth
    end)
end
player.CharacterAdded:Connect(protect)
protect()

addLog("完全版起動完了 ✔ 作成: dax")
