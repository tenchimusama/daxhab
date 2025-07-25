local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local isProtected = false
local isTransparent = false

--============================
-- 🖥 GUIの作成
--============================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProtectionGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 160)
mainFrame.Position = UDim2.new(0.5, -130, 0.85, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Text = "🛡 daxhab 保護スクリプト"
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.Code
Title.TextScaled = true
Title.Parent = mainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "🔴 停止中"
StatusLabel.Size = UDim2.new(1, 0, 0.2, 0)
StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextScaled = true
StatusLabel.Parent = mainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Text = "保護開始"
StartBtn.Size = UDim2.new(1, 0, 0.2, 0)
StartBtn.Position = UDim2.new(0, 0, 0.4, 0)
StartBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.Font = Enum.Font.Code
StartBtn.TextScaled = true
StartBtn.Parent = mainFrame

local ToggleTransparency = Instance.new("TextButton")
ToggleTransparency.Text = "透明化：OFF"
ToggleTransparency.Size = UDim2.new(1, 0, 0.2, 0)
ToggleTransparency.Position = UDim2.new(0, 0, 0.6, 0)
ToggleTransparency.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleTransparency.TextColor3 = Color3.new(1, 1, 1)
ToggleTransparency.Font = Enum.Font.Code
ToggleTransparency.TextScaled = true
ToggleTransparency.Parent = mainFrame

local WarpBtn = Instance.new("TextButton")
WarpBtn.Text = "⬆ ワープ"
WarpBtn.Size = UDim2.new(1, 0, 0.2, 0)
WarpBtn.Position = UDim2.new(0, 0, 0.8, 0)
WarpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
WarpBtn.TextColor3 = Color3.new(1, 1, 1)
WarpBtn.Font = Enum.Font.Code
WarpBtn.TextScaled = true
WarpBtn.Parent = mainFrame

--============================
-- 🛠 保護ロジック
--============================

function MaintainHumanoidRootPart()
    spawn(function()
        while isProtected do
            character = LocalPlayer.Character
            hum = character:FindFirstChild("Humanoid")
            hrp = character:FindFirstChild("HumanoidRootPart")

            if hrp then
                if hrp.Anchored then hrp.Anchored = false end
                if hrp.Transparency and hrp.Transparency > 0.5 then hrp.Transparency = 0 end
                if hrp.CanCollide == false then hrp.CanCollide = true end
                if hrp.Size.Magnitude < 1 then hrp.Size = Vector3.new(2,2,1) end
            end
            wait(0.1)
        end
    end)
end

function WatchDeath()
    if hum then
        hum.Died:Connect(function()
            if isProtected then
                wait(0.2)
                LocalPlayer:LoadCharacter()
                wait(0.5)
                StartProtection()
            end
        end)
    end
end

function SafeWarp(height)
    if not hrp or not character then return end
    local origin = hrp.Position
    local target = origin + Vector3.new(0, height, 0)

    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
    local warpTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(target)})
    warpTween:Play()
end

--============================
-- 🔘 GUIボタン接続と状態切替
--============================

function StartProtection()
    if isProtected then return end
    isProtected = true
    StatusLabel.Text = "🟢 保護中"
    StartBtn.Text = "保護停止"

    MaintainHumanoidRootPart()
    WatchDeath()
end

function StopProtection()
    if not isProtected then return end
    isProtected = false
    StatusLabel.Text = "🔴 停止中"
    StartBtn.Text = "保護開始"
end

function ConnectButtons()
    StartBtn.MouseButton1Click:Connect(function()
        if isProtected then
            StopProtection()
        else
            StartProtection()
        end
    end)

    ToggleTransparency.MouseButton1Click:Connect(function()
        if isTransparent then
            isTransparent = false
            if hrp then hrp.Transparency = 0 end
            ToggleTransparency.Text = "透明化：OFF"
        else
            isTransparent = true
            if hrp then hrp.Transparency = 1 end
            ToggleTransparency.Text = "透明化：ON"
        end
    end)

    WarpBtn.MouseButton1Click:Connect(function()
        SafeWarp(40)
    end)
end

--============================
-- 🚀 自動起動＆自己復旧ループ
--============================

ConnectButtons()
StartProtection()

spawn(function()
    while true do
        wait(1)
        if not screenGui or not screenGui.Parent then
            screenGui.Parent = CoreGui
        end
        if not isProtected then
            StartProtection()
        end
    end
end)

print("✅ 最強保護スクリプト v3 起動完了")
