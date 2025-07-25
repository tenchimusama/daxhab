local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- 背景フレーム（ドラッグ可能）
local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BackgroundTransparency = 0
bg.Size = UDim2.new(0.33,0,0.5,0) -- 横幅1/3、高さ1/2
bg.Position = UDim2.new(0.02,0,0.48,0)
bg.BorderSizePixel = 1
bg.BorderColor3 = Color3.fromRGB(0,255,0)
bg.Active = true
bg.Draggable = true
bg.Parent = screenGui

-- 浮遊ロゴテキスト
local floatingText = Instance.new("TextLabel")
floatingText.Text = "daxhab / by / dax"
floatingText.TextColor3 = Color3.fromRGB(0,255,0)
floatingText.BackgroundTransparency = 1
floatingText.Font = Enum.Font.Code
floatingText.TextScaled = true
floatingText.Size = UDim2.new(1,0,0.12,0)
floatingText.Position = UDim2.new(0,0,0.02,0)
floatingText.Parent = bg

-- ログ用スクロールフレーム
local logFrame = Instance.new("ScrollingFrame")
logFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
logFrame.BackgroundTransparency = 0
logFrame.Size = UDim2.new(0.95,0,0.6,0) -- 画面の約60%の高さ
logFrame.Position = UDim2.new(0.025,0,0.3,0)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 6
logFrame.CanvasSize = UDim2.new(0,0,5,0)
logFrame.Parent = bg

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0,2)
uiListLayout.Parent = logFrame

local function addLog(message)
    local newLabel = Instance.new("TextLabel")
    newLabel.BackgroundTransparency = 1
    newLabel.TextColor3 = Color3.fromRGB(0,255,0)
    newLabel.Font = Enum.Font.Code
    newLabel.TextSize = 16
    newLabel.TextWrapped = true
    newLabel.Size = UDim2.new(1,0,0,20)
    newLabel.Text = ""
    newLabel.Parent = logFrame

    coroutine.wrap(function()
        for i = 1, #message do
            newLabel.Text = string.sub(message, 1, i)
            wait(0.02)
        end
        logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
    end)()
end

-- ボタン作成関数
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6,0,0.12,0) -- 横幅狭め、高さ小さめ
    btn.Position = UDim2.new(0.2,0,posY,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    btn.TextColor3 = Color3.fromRGB(0,255,0)
    btn.Font = Enum.Font.Code
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = bg
    btn.AutoButtonColor = false
    return btn
end

local warpBtn = createButton("ワープ", 0.1)
local protectBtn = createButton("保護OFF", 0.25)
protectBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
protectBtn.TextColor3 = Color3.fromRGB(255,0,0)

-- 効果音
local beep = Instance.new("Sound")
beep.SoundId = "rbxassetid://911882487"
beep.Volume = 0.25
beep.Parent = bg
local function playBeep()
    beep:Play()
end

local protectEnabled = false

local function setNetworkOwner(part)
    pcall(function()
        part:SetNetworkOwner(player)
    end)
end

local function enableProtection(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 0.7
            if part.Name == "HumanoidRootPart" then
                part.Anchored = true
            end
        end
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.ResetOnDeath = false
        humanoid.Died:Connect(function()
            wait(0.1)
            if humanoid.Health <= 0 then
                humanoid.Health = humanoid.MaxHealth
                addLog("Diedイベント回避")
            end
        end)
    end
end

local function disableProtection(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.Transparency = 0
            if part.Name == "HumanoidRootPart" then
                part.Anchored = false
            end
        end
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.ResetOnDeath = true
    end
end

local warpCorrectionDuration = 2
local warpCorrectionActive = false
local lastTargetCFrame = nil

local function startWarpCorrection(rootPart, targetCFrame)
    warpCorrectionActive = true
    lastTargetCFrame = targetCFrame
    local startTime = tick()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if tick() - startTime > warpCorrectionDuration then
            warpCorrectionActive = false
            connection:Disconnect()
            return
        end
        if rootPart and rootPart.Parent then
            local dist = (rootPart.CFrame.p - lastTargetCFrame.p).Magnitude
            if dist > 1 then
                rootPart.CFrame = lastTargetCFrame
            end
        else
            warpCorrectionActive = false
            connection:Disconnect()
        end
    end)
end

local function safeWarp()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        addLog("RootPartなしでワープ中止")
        return
    end

    addLog("ワープ開始...")
    playBeep()

    setNetworkOwner(root)

    local wasAnchored = root.Anchored
    if wasAnchored then
        root.Anchored = false
    end

    local targetPos = root.Position + Vector3.new(0, 12, 0)
    local targetCFrame = CFrame.new(targetPos)

    local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    startWarpCorrection(root, targetCFrame)

    if protectEnabled and wasAnchored then
        root.Anchored = true
    end

    if protectEnabled then
        enableProtection(character)
    else
        disableProtection(character)
    end

    addLog("ワープ成功！")
end

warpBtn.MouseButton1Click:Connect(safeWarp)

protectBtn.MouseButton1Click:Connect(function()
    protectEnabled = not protectEnabled
    playBeep()
    if protectEnabled then
        protectBtn.Text = "保護ON"
        protectBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        protectBtn.TextColor3 = Color3.fromRGB(0,255,0)
        addLog("保護機能ON")
    else
        protectBtn.Text = "保護OFF"
        protectBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
        protectBtn.TextColor3 = Color3.fromRGB(255,0,0)
        addLog("保護機能OFF")
    end
end)

-- 浮遊ロゴアニメ
spawn(function()
    while true do
        floatingText.Position = UDim2.new(0, 0, 0.02 + 0.02 * math.sin(tick() * 3), 0)
        wait(0.03)
    end
end)

addLog("daxhab 起動完了")
