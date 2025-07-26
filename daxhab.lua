--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--===== RemoteEvent for global messages =====
local remoteName = "DaxGlobalMessage"
local remoteEvent = ReplicatedStorage:FindFirstChild(remoteName)
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = remoteName
    remoteEvent.Parent = ReplicatedStorage
end

-- Anti-Idle (Move Mouse)
player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

StarterGui:SetCore("ResetButtonCallback", false)

-- ===== UI Setup =====
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame (initial size: 1/3 screen)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.33, 0, 0.45, 0)
mainFrame.Position = UDim2.new(0.33, 0, 0.33, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Drag logic
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

-- Logo Label (OnePiece風 "dax出現！"のフォント代替)
local logoText = "dax出現！"
local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(1,0,0.15,0)
logoLabel.Position = UDim2.new(0,0,0,0)
logoLabel.BackgroundTransparency = 1
logoLabel.Font = Enum.Font.Antique  -- 太字風フォント代替
logoLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
logoLabel.TextScaled = true
logoLabel.TextStrokeColor3 = Color3.new(0,0,0)
logoLabel.TextStrokeTransparency = 0.3
logoLabel.Text = logoText
logoLabel.Parent = mainFrame

-- Scroll log frame
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -10, 0.6, -40)
logFrame.Position = UDim2.new(0, 5, 0.15, 35)
logFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
logFrame.ScrollBarThickness = 6
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.CanvasSize = UDim2.new(0,0,0,0)
logFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout", logFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 4)

local function addLog(text: string)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0,255,0)
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "> " .. text
    lbl.Parent = logFrame
    task.wait()
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

-- Input box for height
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.35, 0, 0.1, 0)
heightInput.Position = UDim2.new(0.02, 0, 0.78, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(25,25,25)
heightInput.TextColor3 = Color3.fromRGB(0,255,0)
heightInput.PlaceholderText = "Warp Height (studs)"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local currentHeightLabel = Instance.new("TextLabel")
currentHeightLabel.Size = UDim2.new(0.3, 0, 0.1, 0)
currentHeightLabel.Position = UDim2.new(0.39, 0, 0.78, 0)
currentHeightLabel.BackgroundTransparency = 1
currentHeightLabel.TextColor3 = Color3.fromRGB(0,255,0)
currentHeightLabel.Font = Enum.Font.Code
currentHeightLabel.TextScaled = true
currentHeightLabel.Text = "↑: 40"
currentHeightLabel.Parent = mainFrame

heightInput:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(heightInput.Text)
    if val then
        currentHeightLabel.Text = "↑: " .. tostring(val)
    else
        currentHeightLabel.Text = "↑: ?"
    end
end)

-- =====================
-- Emit purple glow on character for X seconds
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

-- Broadcast "dax出現！" to all players
remoteEvent.OnServerEvent:Connect(function(plr)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            local msgGui = Instance.new("ScreenGui")
            msgGui.Name = "DaxMessage"
            msgGui.ResetOnSpawn = false
            msgGui.Parent = p:WaitForChild("PlayerGui")

            local msgLabel = Instance.new("TextLabel")
            msgLabel.Size = UDim2.new(1,0,1,0)
            msgLabel.BackgroundTransparency = 1
            msgLabel.Font = Enum.Font.Antique -- 太字風
            msgLabel.TextColor3 = Color3.fromRGB(255,0,0)
            msgLabel.TextScaled = true
            msgLabel.TextStrokeColor3 = Color3.new(0,0,0)
            msgLabel.TextStrokeTransparency = 0
            msgLabel.Text = "dax出現！"
            msgLabel.TextWrapped = true
            msgLabel.TextYAlignment = Enum.TextYAlignment.Center
            msgLabel.Parent = msgGui

            delay(3, function()
                if msgGui and msgGui.Parent then
                    msgGui:Destroy()
                end
            end)
        end
    end
end)

-- ワープ関数
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

    -- 即着地用 - 着地位置計算して地面を検出
    local ray = Ray.new(targetPos, Vector3.new(0, -1000, 0))
    local hit, pos = workspace:FindPartOnRayWithWhitelist(ray, {workspace.Terrain, workspace})
    if hit then
        targetPos = Vector3.new(targetPos.X, pos.Y + 3, targetPos.Z) -- 少し浮かせて着地位置調整
    end

    -- ワープ開始ログ
    addLog(("Warping ↑ %d studs..."):format(h))

    -- 発光エフェクトON
    emitPurpleGlow(char, 4)

    -- ワープ実行
    root.CFrame = CFrame.new(targetPos)
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    -- ネットワーク所有権強制
    pcall(function() root:SetNetworkOwner(player) end)

    -- 全員にdax出現メッセージ送信（自分にも）
    remoteEvent:FireServer(player)

    -- 10秒間巻き戻し防止
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
            pcall(function() root:SetNetworkOwner(player) end)
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
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
warpButton.Position = UDim2.new(0.05, 0, 0.9, 0)
warpButton.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
warpButton.TextColor3 = Color3.new(1,1,1)
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

-- 透明化トグル
local transparencyButton = Instance.new("TextButton")
transparencyButton.Size = UDim2.new(0.35, 0, 0.1, 0)
transparencyButton.Position = UDim2.new(0.47, 0, 0.9, 0)
transparencyButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
transparencyButton.TextColor3 = Color3.fromRGB(0,255,0)
transparencyButton.Font = Enum.Font.Code
transparencyButton.TextScaled = true
transparencyButton.Text = "透明化: OFF"
transparencyButton.Parent = mainFrame

local isInvisible = false

local function setInvisible(state)
    local char = player.Character or player.CharacterAdded:Wait()
    if char then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Transparency = state and 1 or 0
                obj.CanCollide = not state
            elseif obj:IsA("Decal") then
                obj.Transparency = state and 1 or 0
            elseif obj:IsA("Accessory") then
                local handle = obj:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    handle.Transparency = state and 1 or 0
                    handle.CanCollide = not state
                end
            elseif obj:IsA("Tool") then
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = state and 1 or 0
                        part.CanCollide = not state
                    elseif part:IsA("Decal") then
                        part.Transparency = state and 1 or 0
                    end
                end
            end
        end
        addLog("透明化: " .. (state and "ON" or "OFF"))
    end
end

transparencyButton.MouseButton1Click:Connect(function()
    isInvisible = not isInvisible
    transparencyButton.Text = "透明化: " .. (isInvisible and "ON" or "OFF")
    setInvisible(isInvisible)
end)

-- 縮小ボタン
local shrinkButton = Instance.new("TextButton")
shrinkButton.Size = UDim2.new(0.15, 0, 0.07, 0)
shrinkButton.Position = UDim2.new(0.85, 0, 0, 0)
shrinkButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
shrinkButton.TextColor3 = Color3.fromRGB(0,255,0)
shrinkButton.Font = Enum.Font.Code
shrinkButton.TextScaled = true
shrinkButton.Text = "[ - ]"
shrinkButton.Parent = mainFrame

local normalSize = mainFrame.Size
local normalPos = mainFrame.Position
local isShrunk = false

shrinkButton.MouseButton1Click:Connect(function()
    if isShrunk then
        mainFrame.Size = normalSize
        mainFrame.Position = normalPos
        shrinkButton.Text = "[ - ]"
    else
        mainFrame.Size = UDim2.new(0.15,0,0.2,0)
        mainFrame.Position = UDim2.new(0.8,0,0.8,0)
        shrinkButton.Text = "[ + ]"
    end
    isShrunk = not isShrunk
end)

-- リセット防御
local function protectCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    humanoid.BreakJointsOnDeath = false

    -- 死亡即復活処理
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Dead then
            addLog("死亡検出 - 即復活開始")
            humanoid.Health = humanoid.MaxHealth
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)

    RunService.Heartbeat:Connect(function()
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
    end)
end

player.CharacterAdded:Connect(protectCharacter)
protectCharacter()

addLog("起動完了：daxhab / 作成者：dax")
