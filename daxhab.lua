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

-- メインフレーム（ドラッグ対応）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35, 0, 0.45, 0)
mainFrame.Position = UDim2.new(0.33, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ロゴ部分修正（虹色で動く）
local logoText = "daxhab"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1, 0, 0.2, 0)
logoHolder.Position = UDim2.new(0, 0, 0, 0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(0, 200, 1, 0)
logoLabel.Position = UDim2.new(0.5, -100, 0, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Font = Enum.Font.Code
logoLabel.TextScaled = true
logoLabel.Text = logoText
logoLabel.TextStrokeTransparency = 0
logoLabel.TextStrokeColor3 = Color3.new(0, 1, 0)
logoLabel.TextColor3 = Color3.fromHSV(tick() * 0.2, 1, 1)
logoLabel.Parent = logoHolder

-- 作成者メッセージ
local creatorMessage = Instance.new("TextLabel")
creatorMessage.Size = UDim2.new(1, -10, 0.1, 0)
creatorMessage.Position = UDim2.new(0, 5, 0.9, 5)
creatorMessage.BackgroundTransparency = 1
creatorMessage.TextColor3 = Color3.fromRGB(0, 255, 0)
creatorMessage.Font = Enum.Font.Code
creatorMessage.TextScaled = true
creatorMessage.Text = "作成者: dax"
creatorMessage.TextStrokeTransparency = 0
creatorMessage.TextStrokeColor3 = Color3.new(0, 1, 0)
creatorMessage.Parent = screenGui

-- 透明化機能
local function makeInvisible()
    local character = player.Character or player.CharacterAdded:Wait()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    -- 持っているオブジェクトも透明に
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in ipairs(tool:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
        end
    end
end

-- 透明化ボタン
local invisibleButton = Instance.new("TextButton")
invisibleButton.Size = UDim2.new(0.65, 0, 0.15, 0)
invisibleButton.Position = UDim2.new(0.025, 0, 0.7, 0)
invisibleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
invisibleButton.TextColor3 = Color3.fromRGB(0, 255, 0)
invisibleButton.Font = Enum.Font.Code
invisibleButton.TextScaled = true
invisibleButton.Text = "[ INVISIBLE ]"
invisibleButton.Parent = mainFrame

invisibleButton.MouseButton1Click:Connect(function()
    makeInvisible()
end)

-- 座標変更
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

local function changeCoordinates()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    
    local height = tonumber(heightInput.Text)
    if not height then
        addLog("無効なスタッド数")
        return
    end
    local targetPosition = root.Position + Vector3.new(0, height, 0)
    
    -- プレイヤーの位置変更
    root.CFrame = CFrame.new(targetPosition)
    
    addLog("座標変更完了: ↑" .. tostring(height) .. " stud")
end

-- 座標変更ボタン
local changeCoordButton = Instance.new("TextButton")
changeCoordButton.Size = UDim2.new(0.65, 0, 0.15, 0)
changeCoordButton.Position = UDim2.new(0.025, 0, 0.85, 0)
changeCoordButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
changeCoordButton.TextColor3 = Color3.fromRGB(0, 255, 0)
changeCoordButton.Font = Enum.Font.Code
changeCoordButton.TextScaled = true
changeCoordButton.Text = "[ CHANGE POSITION ]"
changeCoordButton.Parent = mainFrame

changeCoordButton.MouseButton1Click:Connect(function()
    changeCoordinates()
end)

-- リセット回避強化
local function enhancedResetProtection()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    humanoid.PlatformStand = true
    root.Anchored = true
    
    -- 数秒後にアンカー解除
    wait(1)
    root.Anchored = false
    humanoid.PlatformStand = false
end

-- リセット回避強化を座標変更後に実行
changeCoordButton.MouseButton1Click:Connect(function()
    changeCoordinates()
    enhancedResetProtection()
end)

-- ログ表示
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

addLog("起動完了！")
