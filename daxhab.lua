-- daxhab 強化版：サーバー並みの安定性と保護力を備えた完全版スクリプト（改良済み）
-- 特徴：即実行防止 / GUI操作 / 自己復旧 / 透明化 / ワープ / 巻き戻し補正 / 所有権保持

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- 変数初期化
local char, hum, hrp
local isProtected = false
local isInvisible = false
local guiElements = {}

-- キャラ取得関数
local function InitCharacter()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end

-- 安定化：座標異常時の補正
local function PositionSafetyCheck()
    spawn(function()
        while isProtected do
            if hrp then
                local pos = hrp.Position
                if math.abs(pos.Y) > 1000 or math.abs(pos.X) > 1e5 or math.abs(pos.Z) > 1e5 then
                    hrp.CFrame = CFrame.new(0, 10, 0) -- 安全地帯に戻す
                end
            end
            task.wait(1)
        end
    end)
end

-- キャラプロパティ監視
local function MonitorCharacter()
    spawn(function()
        while isProtected do
            if hrp then
                hrp.Anchored = false
                hrp.CanCollide = true
                if hrp.Size.Magnitude < 1 then hrp.Size = Vector3.new(2, 2, 1) end
                if hrp.Transparency > 0.9 and not isInvisible then
                    hrp.Transparency = 0
                end
            end
            task.wait(0.05)
        end
    end)
end

-- 所有権維持
local function MaintainNetworkOwnership()
    spawn(function()
        while isProtected do
            pcall(function()
                if hrp then hrp:SetNetworkOwner(LocalPlayer) end
            end)
            task.wait(0.1)
        end
    end)
end

-- 死亡時復旧
local function MonitorDeath()
    hum.Died:Connect(function()
        if isProtected then
            task.wait(0.5)
            LocalPlayer:LoadCharacter()
            task.wait(1)
            InitCharacter()
            StartProtection()
        end
    end)
end

-- ワープ関数
local function WarpUp()
    if not hrp then return end
    local target = hrp.Position + Vector3.new(0, 50, 0)
    local tween = TweenService:Create(hrp, TweenInfo.new(0.25), {CFrame = CFrame.new(target)})
    tween:Play()
end

-- GUI生成
local function CreateGui()
    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "DaxhabShieldGUI"

    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(0, 250, 0, 180)
    frame.Position = UDim2.new(0.5, -125, 0.7, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    frame.BorderColor3 = Color3.fromRGB(0,255,0)
    frame.Active = true
    frame.Draggable = true

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, 0, 0.2, 0)
    status.Text = "状態: 待機中"
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Code
    status.TextScaled = true

    local startBtn = Instance.new("TextButton", frame)
    startBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
    startBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
    startBtn.Text = "保護開始"
    startBtn.Font = Enum.Font.Code
    startBtn.TextScaled = true
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    startBtn.TextColor3 = Color3.new(1, 1, 1)

    local warpBtn = Instance.new("TextButton", frame)
    warpBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
    warpBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
    warpBtn.Text = "ワープ"
    warpBtn.Font = Enum.Font.Code
    warpBtn.TextScaled = true
    warpBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 150)
    warpBtn.TextColor3 = Color3.new(1, 1, 1)

    local invisBtn = Instance.new("TextButton", frame)
    invisBtn.Position = UDim2.new(0.1, 0, 0.8, 0)
    invisBtn.Size = UDim2.new(0.8, 0, 0.15, 0)
    invisBtn.Text = "透明化: OFF"
    invisBtn.Font = Enum.Font.Code
    invisBtn.TextScaled = true
    invisBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    invisBtn.TextColor3 = Color3.new(1, 1, 1)

    guiElements = {
        status = status,
        startBtn = startBtn,
        warpBtn = warpBtn,
        invisBtn = invisBtn
    }

    startBtn.MouseButton1Click:Connect(StartProtection)
    warpBtn.MouseButton1Click:Connect(WarpUp)
    invisBtn.MouseButton1Click:Connect(function()
        isInvisible = not isInvisible
        if hrp then
            hrp.Transparency = isInvisible and 1 or 0
        end
        invisBtn.Text = "透明化: " .. (isInvisible and "ON" or "OFF")
    end)
end

-- 保護起動関数
function StartProtection()
    if isProtected then return end
    InitCharacter()
    isProtected = true
    guiElements.status.Text = "状態: 起動中"
    MonitorCharacter()
    MaintainNetworkOwnership()
    MonitorDeath()
    PositionSafetyCheck()
end

-- GUI起動
CreateGui()
print("✅ daxhab 強化版シールド 起動準備完了")
