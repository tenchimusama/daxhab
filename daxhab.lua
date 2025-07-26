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

-- 足の速さとジャンプ力MAXに設定
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
humanoid.WalkSpeed = 100 -- 速さを最大に設定（デフォルト16）
humanoid.JumpHeight = 200 -- ジャンプ力を最大に設定（デフォルト50）

-- UI構築
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインフレーム（ドラッグ対応）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35,0,0.45,0)
mainFrame.Position = UDim2.new(0.33,0,0.5,0)
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
    end
end)

-- 3Dロゴ作成
local logoText = "< daxhab / by / dax >"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1,0,0.2,0)
logoHolder.Position = UDim2.new(0,0,0,0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}

for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 15, 1, 0)
    lbl.Position = UDim2.new(0, 15*(i-1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = logoText:sub(i,i)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,1,0)
    lbl.TextColor3 = Color3.fromHSV((tick()*0.2 + i*0.05)%1,1,1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end

-- 3D風アニメーション
RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(logoLabels) do
        local offset = math.sin(tick()*10 + i)*5
        lbl.Position = UDim2.new(0, 15*(i-1), 0, offset)
        lbl.TextColor3 = Color3.fromHSV((tick()*0.3 + i*0.07)%1, 1, 1)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ログ表示枠
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
logBox.Text = ""
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

local function addLog(text)
    logBox.Text = logBox.Text .. "\n> " .. text
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
        currentHeight.Text = "↑: "..tostring(val)
    else
        currentHeight.Text = "↑: ?"
    end
end)

-- ワープボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0.65, 0, 0.15, 0)
warpButton.Position = UDim2.new(0.025, 0, 0.85, 0)
warpButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "[ WARP ↑ ]"
warpButton.Parent = mainFrame

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

local function setNetworkOwner(part)
    pcall(function()
        part:SetNetworkOwner(player)
    end)
end

local function safeWarp()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        addLog("キャラクターの主要パーツが見つかりません")
        return
    end
    local height = tonumber(heightInput.Text)
    if not height then
        addLog("無効なスタッド数")
        return
    end
    currentHeight.Text = "↑: "..tostring(height)
    addLog("ワープ中... (↑"..tostring(height).." stud)")

    -- 透明化、オブジェクトを持っていても完全に透明化
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 1
        end
    end

    -- ワープ前に1.5スタッド浮上
    root.CFrame = root.CFrame + Vector3.new(0,1.5,0)

    local offset = Vector3.new(0, height, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local rayResult = workspace:Raycast(root.Position, offset, rayParams)

    local targetCFrame
    if rayResult then
        targetCFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
        addLog("障害物検知、貫通位置に調整")
    else
        targetCFrame = root.CFrame + offset
    end

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    humanoid.AutoRotate = true
    humanoid.PlatformStand = false
    humanoid.Sit = false

    root.Anchored = false
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
    setNetworkOwner(root)
    root.CFrame = targetCFrame

    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 6 then
            conn:Disconnect()
            -- ワープ後に物理判定・透明度を元に戻す
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.Transparency = 0
                end
            end
            return
        end
        if root and root.Parent then
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            root.CFrame = targetCFrame
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            setNetworkOwner(root)
        end
    end)
    addLog("ワープ成功（↑"..tostring(height).." stud）")
end

warpButton.MouseButton1Click:Connect(function()
    animateButton(warpButton)
    safeWarp()
end)
