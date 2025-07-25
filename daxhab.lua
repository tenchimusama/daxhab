-- Daxhab Compact 強化版ワープ＆リセット回避スクリプト
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==== GUIセットアップ（画面の約9分の1サイズ、縦横0.33ずつ） ====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabCompactUI"
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.BackgroundTransparency = 0.8
bg.Size = UDim2.new(0.33, 0, 0.33, 0)
bg.Position = UDim2.new(0.02, 0, 0.65, 0)
bg.BorderSizePixel = 1
bg.BorderColor3 = Color3.fromRGB(0,255,0)
bg.Parent = screenGui

-- 浮遊ロゴ（小さく）
local floatingText = Instance.new("TextLabel")
floatingText.Text = "daxhab / by / dax"
floatingText.TextColor3 = Color3.fromRGB(0,255,0)
floatingText.BackgroundTransparency = 1
floatingText.Font = Enum.Font.Code
floatingText.TextScaled = true
floatingText.Size = UDim2.new(1,0,0.12,0)
floatingText.Position = UDim2.new(0,0,0.02,0)
floatingText.Parent = bg

-- ログフレーム
local logFrame = Instance.new("Frame")
logFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
logFrame.BackgroundTransparency = 0.7
logFrame.Size = UDim2.new(0.95,0,0.3,0)
logFrame.Position = UDim2.new(0.025,0,0.65,0)
logFrame.BorderSizePixel = 0
logFrame.Parent = bg

local logText = Instance.new("TextLabel")
logText.BackgroundTransparency = 1
logText.TextColor3 = Color3.fromRGB(0,255,0)
logText.Font = Enum.Font.Code
logText.TextWrapped = true
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.Size = UDim2.new(1,0,1,0)
logText.Position = UDim2.new(0,5,0,0)
logText.Text = ""
logText.Parent = logFrame

-- ボタン作成関数（小さめで押しやすく）
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.15, 0)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.Code
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = bg
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    return btn
end

local warpBtn = createButton("ワープ", 0.4)
local protectBtn = createButton("保護OFF", 0.6)
protectBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
protectBtn.TextColor3 = Color3.fromRGB(255, 0, 0)

-- ビープ音
local beep = Instance.new("Sound")
beep.SoundId = "rbxassetid://911882487"
beep.Volume = 0.25
beep.Parent = bg

local function playBeep()
    beep:Play()
end

-- ログ追加（タイプライター風アニメ）
local logQueue = {}
local isLogging = false
local function addLog(message)
    table.insert(logQueue, message)
    if not isLogging then
        isLogging = true
        while #logQueue > 0 do
            local msg = table.remove(logQueue, 1)
            logText.Text = ""
            for i = 1, #msg do
                logText.Text = string.sub(msg,1,i)
                wait(0.02)
            end
            wait(1.2)
        end
        isLogging = false
    end
end

-- 保護状態管理
local protectEnabled = false

local function setNetworkOwnership(part)
    pcall(function()
        part:SetNetworkOwner(player)
    end)
end

local function enableProtection(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 0.7
            -- RootPartはアンカーして物理無効化強化
            if part.Name == "HumanoidRootPart" then
                part.Anchored = true
            end
        end
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.ResetOnDeath = false
        -- Diedイベントを無効化（海外スクリプト技術）
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

-- 巻き戻し補正（2秒間）
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

-- 超強化ワープ処理
local function safeWarp()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        addLog("キャラ未ロード")
        return
    end
    local root = character.HumanoidRootPart

    addLog("ワープ開始...")

    setNetworkOwnership(root)

    if protectEnabled then
        enableProtection(character)
    end

    local targetPos = root.Position + Vector3.new(0, 100, 0)
    local targetCFrame = CFrame.new(targetPos)

    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    startWarpCorrection(root, targetCFrame)

    if protectEnabled then
        wait(0.15)
        disableProtection(character)
    end

    addLog("ワープ成功！")
end

-- ボタン処理
warpBtn.MouseButton1Click:Connect(function()
    playBeep()
    safeWarp()
end)

protectBtn.MouseButton1Click:Connect(function()
    playBeep()
    protectEnabled = not protectEnabled
    if protectEnabled then
        protectBtn.Text = "保護ON"
        protectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        protectBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        addLog("保護機能ON")
    else
        protectBtn.Text = "保護OFF"
        protectBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        protectBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        addLog("保護機能OFF")
    end
end)

-- 浮遊ロゴアニメーション
spawn(function()
    while true do
        floatingText.Position = UDim2.new(0, 0, 0.02 + 0.02 * math.sin(tick() * 3), 0)
        wait(0.03)
    end
end)

-- 起動ログ
addLog("daxhab 起動完了")
