--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

StarterGui:SetCore("ResetButtonCallback", false)
player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- UI初期化
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.4,0,0.5,0)
mainFrame.Position = UDim2.new(0.3,0,0.45,0)
mainFrame.BackgroundColor3 = Color3.new(0,0,0)
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
        mainFrame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,startPos.Y.Scale,startPos.Y.Offset + delta.Y)
        -- 画面外に出さない処理
        local x,y = mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y
        local w,h = mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y
        local screenW, screenH = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
        if x < 0 then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, 0, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset) end
        if y < 0 then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, 0) end
        if x + w > screenW then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, screenW - w, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset) end
        if y + h > screenH then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, screenH - h) end
    end
end)

-- ロゴ: daxhab 虹色点字風
local logoText = "daxhab"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1,0,0.15,0)
logoHolder.Position = UDim2.new(0,0,0,0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}
local displayedCount = 0
local lastTick = tick()

for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 25, 1, 0)
    lbl.Position = UDim2.new(0, 25*(i-1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = ""
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,255,0)
    lbl.TextColor3 = Color3.fromHSV((i*0.15)%1,1,1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end

-- 点字風に少しずつ文字を表示
RunService.RenderStepped:Connect(function()
    if tick() - lastTick > 0.15 and displayedCount < #logoText then
        displayedCount = displayedCount + 1
        for i=1,displayedCount do
            logoLabels[i].Text = logoText:sub(i,i)
            logoLabels[i].TextColor3 = Color3.fromHSV((tick()*0.4 + i*0.1)%1,1,1)
        end
        lastTick = tick()
    end
end)

-- ログ表示
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -10, 0.5, -10)
logBox.Position = UDim2.new(0, 5, 0.15, 5)
logBox.BackgroundColor3 = Color3.new(0,0,0)
logBox.TextColor3 = Color3.fromRGB(0,255,0)
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextSize = 14
logBox.TextWrapped = true
logBox.Text = "作成者: dax"
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

local function addLog(text)
    logBox.Text = logBox.Text .. "\n> " .. text
end

-- スタッド入力欄
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.4, 0, 0.1, 0)
heightInput.Position = UDim2.new(0.3, 0, 0.68, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(20,20,20)
heightInput.TextColor3 = Color3.fromRGB(0,255,0)
heightInput.PlaceholderText = "Warp Height"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local currentHeight = Instance.new("TextLabel")
currentHeight.Size = UDim2.new(0.4,0,0.1,0)
currentHeight.Position = UDim2.new(0.3,0,0.78,0)
currentHeight.BackgroundTransparency = 1
currentHeight.TextColor3 = Color3.fromRGB(0,255,0)
currentHeight.Font = Enum.Font.Code
currentHeight.TextScaled = true
currentHeight.Text = "Height: 40"
currentHeight.Parent = mainFrame

heightInput:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(heightInput.Text)
    if val then
        currentHeight.Text = "Height: "..val
    else
        currentHeight.Text = "Height: ?"
    end
end)

-- 透明化処理
local function setTransparency(character, transparency)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = transparency
            part.CanCollide = not (transparency > 0)
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                handle.Transparency = transparency
                handle.CanCollide = not (transparency > 0)
            end
        end
    end
end

local function setHeldObjectsTransparency(player, transparency)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in ipairs(tool:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = transparency
                    part.CanCollide = not (transparency > 0)
                end
            end
        end
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local equippedTool = humanoid:FindFirstChildOfClass("Tool")
        if equippedTool then
            for _, part in ipairs(equippedTool:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = transparency
                    part.CanCollide = not (transparency > 0)
                end
            end
        end
    end
end

local function enableInvisible()
    local char = player.Character
    if not char then return end
    setTransparency(char, 1)
    setHeldObjectsTransparency(player, 1)
    addLog("Invisible mode enabled")
end

local function disableInvisible()
    local char = player.Character
    if not char then return end
    setTransparency(char, 0)
    setHeldObjectsTransparency(player, 0)
    addLog("Invisible mode disabled")
end

local invisibleEnabled = false

local invisibleButton = Instance.new("TextButton")
invisibleButton.Size = UDim2.new(0.4, 0, 0.1, 0)
invisibleButton.Position = UDim2.new(0.3, 0, 0.55, 0)
invisibleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
invisibleButton.TextColor3 = Color3.fromRGB(255,255,255)
invisibleButton.Font = Enum.Font.Code
invisibleButton.TextScaled = true
invisibleButton.Text = "Invisible: OFF"
invisibleButton.Parent = mainFrame

invisibleButton.MouseButton1Click:Connect(function()
    if invisibleEnabled then
        disableInvisible()
        invisibleEnabled = false
        invisibleButton.Text = "Invisible: OFF"
        invisibleButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
    else
        enableInvisible()
        invisibleEnabled = true
        invisibleButton.Text = "Invisible: ON"
        invisibleButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

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

    root.CFrame = CFrame.new(targetPos)
    addLog("Warped ↑ "..tostring(h).." studs")

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

addLog("UI Ready. Created by dax")
