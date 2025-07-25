--[[
  daxhab 完全v5スクリプト - 最強ワープ保護・透明化・死亡防止付き
  作者: dax
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local character, hum, hrp
local isProtected = false
local isTransparent = false
local isWarping = false

-- キャラ初期化
function InitCharacter()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    hum = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end

InitCharacter()

-- GUI初期化（簡略化）
local gui = Instance.new("ScreenGui", CoreGui)
local statusLabel = Instance.new("TextLabel", gui)
statusLabel.Size = UDim2.new(0, 300, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.Text = "daxhab v5 - 保護停止中"
statusLabel.TextColor3 = Color3.new(0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Code
statusLabel.TextScaled = true

-- 完全透明化
function TransparentIfNeeded()
    if not character then return end
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        elseif obj:IsA("Decal") or obj:IsA("Accessory") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj:Destroy()
        end
    end
end

-- 死亡検知と復帰
function MonitorHumanoid()
    if hum then
        hum.Died:Connect(function()
            task.wait(0.5)
            LocalPlayer:LoadCharacter()
            task.wait(1)
            InitCharacter()
            TransparentIfNeeded()
            StartProtection()
        end)
    end
end

-- ワープ事前準備・完了
function PrepareWarp()
    if hum then hum.PlatformStand = true end
end

function FinishWarp()
    task.wait(0.1)
    if hum then hum.PlatformStand = false end
end

-- 安全ワープ処理
function SafeWarp(offset)
    if not hrp or isWarping then return end
    isWarping = true
    PrepareWarp()
    local target = hrp.Position + offset
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3), {CFrame = CFrame.new(target)})
    tween:Play()
    tween.Completed:Wait()
    FinishWarp()
    isWarping = false
end

-- Gravity / Network 保護
function StartWatchers()
    spawn(function()
        while isProtected do
            if Workspace.Gravity ~= 196.2 then
                Workspace.Gravity = 196.2
            end
            task.wait(0.5)
        end
    end)
    spawn(function()
        while isProtected do
            if hrp then
                pcall(function()
                    hrp:SetNetworkOwner(LocalPlayer)
                end)
            end
            task.wait(0.3)
        end
    end)
end

-- メイン保護関数
function StartProtection()
    if isProtected then return end
    isProtected = true
    statusLabel.Text = "daxhab v5 - 保護中"
    TransparentIfNeeded()
    MonitorHumanoid()
    StartWatchers()
end

StartProtection()

-- 透明キー（T）
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        isTransparent = not isTransparent
        TransparentIfNeeded()
    elseif input.KeyCode == Enum.KeyCode.Y then
        SafeWarp(Vector3.new(0, 60, 0))
    end
end)

print("✅ daxhab v5 最強ワープ・保護・透明化スクリプトが起動しました")
