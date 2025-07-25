-- Daxhab 完全版ブレインロット向けスマホ対応ワープ＆保護＋巻き戻し補正

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==== GUIセットアップ ====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- 背景
local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.Size = UDim2.new(1,0,1,0)
bg.Parent = screenGui

-- 浮遊ロゴ
local floatingText = Instance.new("TextLabel")
floatingText.Text = "daxhab / by / dax"
floatingText.TextColor3 = Color3.fromRGB(0,255,0)
floatingText.BackgroundTransparency = 1
floatingText.Font = Enum.Font.Code
floatingText.TextScaled = true
floatingText.Size = UDim2.new(0.6,0,0.1,0)
floatingText.Position = UDim2.new(0.2,0,0.02,0)
floatingText.Parent = bg

-- ログフレーム
local logFrame = Instance.new("Frame")
logFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
logFrame.BackgroundTransparency = 0.6
logFrame.Size = UDim2.new(0.9,0,0.15,0)
logFrame.Position = UDim2.new(0.05,0,0.75,0)
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

-- ボタン共通設定関数
local function createButton(text, posX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 70)
    btn.Position = UDim2.new(posX, 0, 0.85, 0)
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

local warpBtn = createButton("ワープ", 0.1)
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

-- ログ追加関数（タイプライター風）
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
        end
    end
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.ResetOnDeath = false
    end
end

local function disableProtection(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.Transparency = 0
        end
    end
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.ResetOnDeath = true
    end
end

-- 巻き戻し対策用ワープ補正ループ
local warpCorrectionDuration = 2 -- 秒数（2秒間補正）
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
            -- 位置が戻されてたら強制補正
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

-- 強化ワープ処理
local function safeWarp()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        addLog("キャラ未ロード")
        return
    end
    local root = character.HumanoidRootPart

    addLog("ワープ開始...")

    -- ネットワーク所有権奪取
    setNetworkOwnership(root)

    -- 保護ONならCollision無効・透明化
    if protectEnabled then
        enableProtection(character)
    end

    local targetPos = root.Position + Vector3.new(0, 100, 0)
    local targetCFrame = CFrame.new(targetPos)

    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    -- 巻き戻し補正開始
    startWarpCorrection(root, targetCFrame)

    -- 保護ONなら透明度解除・Collision復活（わずかに遅延させて検知逃れ）
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

-- ロゴ浮遊アニメーション
spawn(function()
    while true do
        floatingText.Position = UDim2.new(0.2, 0, 0.02 + 0.02 * math.sin(tick()*3), 0)
        wait(0.03)
    end
end)

-- 初期ログ
addLog("daxhab 起動完了")
