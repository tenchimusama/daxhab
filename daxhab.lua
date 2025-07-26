--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

-- ===== UI構築 =====
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35, 0, 0.45, 0)
mainFrame.Position = UDim2.new(0.33, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ドラッグ機能
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

-- ログ表示
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

-- スタッド入力欄＆表示
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

-- ボタンアニメーション関数
local function animateButton(btn)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    }):Play()
    task.wait(0.15)
    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    }):Play()
end

-- ワープ時の紫発光エフェクト
local function emitPurpleGlow(char, duration)
    if not char then return end
    local glowParts = {}

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local glow = Instance.new("PointLight")
            glow.Color = Color3.fromRGB(170, 0, 255)
            glow.Range = 10
            glow.Brightness = 3
            glow.Shadows = true
            glow.Parent = part
            table.insert(glowParts, glow)
        end
    end

    delay(duration, function()
        for _, glow in ipairs(glowParts) do
            if glow and glow.Parent then
                glow:Destroy()
            end
        end
    end)
end

-- ワープ関数（完全保護付き）
local function safeWarp(height)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root then
        addLog("HumanoidRootPart not found")
        return
    end

    local h = tonumber(height) or 40
    local targetPos = root.Position + Vector3.new(0, h, 0)

    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        humanoid.Health = humanoid.MaxHealth
    end

    emitPurpleGlow(char, 3)
    addLog("Warped ↑ " .. tostring(h) .. " studs")

    root.CFrame = CFrame.new(targetPos)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    pcall(function()
        root:SetNetworkOwner(player)
    end)

    -- 10秒間巻き戻し防止＆復活監視
    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 10 then
            conn:Disconnect()
            if humanoid then
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            addLog("Warp protection ended")
            return
        end
        if root and root.Parent then
            root.CFrame = CFrame.new(targetPos)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            pcall(function()
                root:SetNetworkOwner(player)
            end)
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
            if humanoid and humanoid.PlatformStand then
                humanoid.PlatformStand = false
            end
        else
            conn:Disconnect()
            addLog("Warp protection aborted: RootPart missing")
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

-- 保護機能トグル
local protectionEnabled = true

local protectionButton = Instance.new("TextButton")
protectionButton.Size = UDim2.new(0.25, 0, 0.1, 0)
protectionButton.Position = UDim2.new(0.1, 0, 0.85, 0)
protectionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
protectionButton.TextColor3 = Color3.fromRGB(0, 255, 0)
protectionButton.Font = Enum.Font.Code
protectionButton.TextScaled = true
protectionButton.Text = "[ 保護: ON ]"
protectionButton.Parent = mainFrame

local function animateProtectionBtn()
    TweenService:Create(protectionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 100, 0)}):Play()
    task.wait(0.2)
    TweenService:Create(protectionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
end

protectionButton.MouseButton1Click:Connect(function()
    protectionEnabled = not protectionEnabled
    protectionButton.Text = protectionEnabled and "[ 保護: ON ]" or "[ 保護: OFF ]"
    protectionButton.TextColor3 = protectionEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    animateProtectionBtn()
    addLog("Protection toggled: " .. (protectionEnabled and "ON" or "OFF"))
end)

-- リセット完全防御モジュール
local function protectCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    humanoid.BreakJointsOnDeath = false

    humanoid.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Dead and protectionEnabled then
            addLog("死亡検出 - 即回復処理開始")
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

addLog("起動完了: ！daxhab！ / 作成者: dax")
