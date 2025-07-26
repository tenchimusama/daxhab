--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- アンチキック＆Idled無効化（常時）
player.Idled:Connect(function()
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

-- 3Dロゴ作成
local logoText = "！daxhab！"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1, 0, 0.2, 0)
logoHolder.Position = UDim2.new(0, 0, 0, 0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}

for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 15, 1, 0)
    lbl.Position = UDim2.new(0, 15 * (i - 1), 0, 0)
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

-- 3D風アニメーション
RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(logoLabels) do
        local offset = math.sin(tick() * 8 + i) * 5
        lbl.Position = UDim2.new(0, 15 * (i - 1), 0, offset)
        lbl.TextColor3 = Color3.fromHSV((tick() * 0.25 + i * 0.07) % 1, 1, 1)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ✅ スクロール可能ログ
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -10, 0.5, -10)
logFrame.Position = UDim2.new(0, 5, 0.2, 5)
logFrame.BackgroundColor3 = Color3.new(0, 0, 0)
logFrame.ScrollBarThickness = 6
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout", logFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function addLog(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "> " .. text
    lbl.Parent = logFrame
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

-- スタッド入力欄
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.3, 0, 0.12, 0)
heightInput.Position = UDim2.new(0.68, 0, 0.63, 0)
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
currentHeight.Position = UDim2.new(0.68, 0, 0.77, 0)
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

-- ワープ関数（改良版）
local function safeWarp(height)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        addLog("HumanoidRootPart or Humanoid not found")
        return
    end

    local h = tonumber(height) or 40
    local targetPos = root.Position + Vector3.new(0, h, 0)

    -- ワープ直後に死なない・硬直しないように繰り返し処理
    humanoid.PlatformStand = false
    humanoid.Health = humanoid.MaxHealth
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
    root.CFrame = CFrame.new(targetPos)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
    pcall(function() root:SetNetworkOwner(player) end)

    -- 15秒間位置＆物理を強制維持しつつ保護
    local start = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - start > 15 then
            conn:Disconnect()
            addLog("Warp protection ended")
            return
        end

        if root.Parent then
            root.CFrame = CFrame.new(targetPos)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            humanoid.PlatformStand = false
            humanoid.Health = humanoid.MaxHealth
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            pcall(function() root:SetNetworkOwner(player) end)
        else
            conn:Disconnect()
            addLog("Warp protection aborted: RootPart missing")
        end
    end)
end

-- ワープボタン（中央配置）
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

local function makeInvisible()
    local char = player.Character or player.CharacterAdded:Wait()
    if char then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Transparency = 1
                obj.CanCollide = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("Accessory") then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = 1
                    handle.CanCollide = false
                end
            elseif obj:IsA("Tool") then
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                end
            end
        end
        addLog("Character fully invisible (including accessories/tools)")
    end
end

-- 透明化ボタンのアニメーション
local beepSound = Instance.new("Sound")
beepSound.SoundId = "rbxassetid://911882704"
beepSound.Volume = 0.6
beepSound.Parent = mainFrame

local function animateButton(btn)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    }):Play()
    beepSound:Play()
    task.wait(0.15)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    }):Play()
end

transparencyButton.MouseButton1Click:Connect(function()
    animateButton(transparencyButton)
    makeInvisible()
    addLog("透明化中...")
end)

-- リセット完全防御モジュール（最強強化版）
local function protectCharacter(char)
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.BreakJointsOnDeath = false

    humanoid.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Dead then
            task.spawn(function()
                while humanoid.Health <= 0 do
                    humanoid.Health = humanoid.MaxHealth
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    task.wait(0.1)
                end
            end)
        end
    end)

    local heartbeatConn
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not char.Parent then
            heartbeatConn:Disconnect()
            addLog("Character removed, protection stopped")
            return
        end

        -- 体力を最大に保つ
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end

        -- 歩行速度・ジャンプ力の正常化
        if humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
        if humanoid.JumpPower ~= 50 then
            humanoid.JumpPower = 50
        end

        -- 硬直解除
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end

        -- 物理干渉解除＆ネットワーク所有権強制取得
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        pcall(function()
            root:SetNetworkOwner(player)
        end)
    end)
end

player.CharacterAdded:Connect(protectCharacter)
if player.Character then
    protectCharacter(player.Character)
end

addLog("起動完了: ！daxhab！ / 作成者: dax")
print("超強力保護スクリプト起動完了。リセット・硬直・死亡から絶対守る最強保護モード。")
