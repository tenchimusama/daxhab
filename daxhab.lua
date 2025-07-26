-- 必要なサービスの取得
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- プレイヤーの取得
local player = Players.LocalPlayer

-- アンチキック＆Idled無効化
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
StarterGui:SetCore("ResetButtonCallback", false)

-- UI構築
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 起動時の説明メッセージ
local descriptionText = Instance.new("TextLabel")
descriptionText.Size = UDim2.new(0.8, 0, 0.2, 0)
descriptionText.Position = UDim2.new(0.1, 0, 0.4, 0)
descriptionText.BackgroundColor3 = Color3.new(0, 0, 0)
descriptionText.TextColor3 = Color3.fromRGB(0, 255, 0)
descriptionText.Font = Enum.Font.Code
descriptionText.TextScaled = true
descriptionText.Text = "このスクリプトはあなたを相手から完全に見えなくし、移動速度とジャンプ力を強化します。"
descriptionText.TextWrapped = true
descriptionText.Parent = screenGui

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

-- プレイヤーの見えないオブジェクトも透明化
local function makeInvisible(character)
    -- プレイヤーのキャラクターのすべてのパーツを透明化
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    -- プレイヤーが持っているツールも透明化
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Handle.Transparency = 1
            tool.Handle.CanCollide = false
        end
    end
end

-- 起動時にプレイヤーを見えない状態にする
local character = player.Character or player.CharacterAdded:Wait()
makeInvisible(character)

-- ジャンプ力と移動速度を最大化
local humanoid = character:WaitForChild("Humanoid")
humanoid.WalkSpeed = 1000  -- 最大移動速度
humanoid.JumpPower = 150   -- 最大ジャンプ力

-- 透明化状態を維持する
RunService.RenderStepped:Connect(function()
    if character and character.Parent then
        makeInvisible(character)
    end
end)

-- 座標変更（位置を上に変更する機能）
local function teleportUp()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, 50, 0)  -- 上に50スタッド移動
    humanoidRootPart.CFrame = CFrame.new(targetPosition)
end

-- 最初に起動時に座標変更
teleportUp()

-- ジャンプ力と移動速度を最大化してリセット
humanoid.WalkSpeed = 1000  -- 最大移動速度
humanoid.JumpPower = 150   -- 最大ジャンプ力
humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

-- 座標変更が常に維持されるようにする
RunService.Heartbeat:Connect(function()
    if character and character.Parent then
        -- 定期的に透明化を維持し、座標変更も維持
        makeInvisible(character)
        teleportUp()  -- 位置を上に保つ
    end
end)

-- リセット防止機能（位置変更を強制的に続ける）
local function preventReset()
    -- キャラクターの位置と状態を強制的に維持
    if character and character.Parent then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        if humanoidRootPart and humanoid then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 50, 0))
        end
    end
end

RunService.Heartbeat:Connect(preventReset)  -- 毎フレーム位置と状態を確認してリセットを防止
