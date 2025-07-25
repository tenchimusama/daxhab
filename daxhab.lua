-- CoreModule.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local State = {
    WarpEnabled = false,
    ResetProtectionEnabled = true,
    TransparencyEnabled = false,
    WarpBlockBypassEnabled = true,
    NetworkOwnershipEnabled = true,
    ToolProtectionEnabled = true,
    KickProtectionEnabled = true,
    GuiVisible = true,
}

local CoreModule = {}

function CoreModule:GetState()
    return State
end

function CoreModule:SetState(key, value)
    State[key] = value
end

function CoreModule:GetCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

function CoreModule:GetHumanoid()
    local char = self:GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

function CoreModule:GetRootPart()
    local char = self:GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function CoreModule:DebugLog(msg)
    if State.GuiVisible then
        print("[daxhab LOG] " .. tostring(msg))
    end
end

return CoreModule
-- LoggerModule.lua
local CoreModule = require(script.Parent.CoreModule)
local CoreGui = game:GetService("CoreGui")

local LoggerModule = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "daxhabGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local BgFrame = Instance.new("Frame")
BgFrame.Size = UDim2.new(0, 280, 0, 180)
BgFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
BgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BgFrame.BackgroundTransparency = 0.7
BgFrame.BorderSizePixel = 0
BgFrame.Parent = ScreenGui

local RainbowColors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211),
}

-- 虹色スクロール背景
coroutine.wrap(function()
    local idx = 1
    while true do
        BgFrame.BackgroundColor3 = RainbowColors[idx]
        idx = idx + 1
        if idx > #RainbowColors then
            idx = 1
        end
        task.wait(0.3)
    end
end)()

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -10, 0, 90)
LogFrame.Position = UDim2.new(0, 5, 0, 85)
LogFrame.BackgroundTransparency = 0.8
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 5
LogFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
LogFrame.Parent = BgFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = LogFrame

function LoggerModule:AddLog(msg)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = tostring(msg)
    label.Parent = LogFrame
    task.wait(0.05)
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.CanvasSize.Y.Offset)
end

return LoggerModule
-- WarpModule.lua
local TweenService = game:GetService("TweenService")
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)

local WarpModule = {}
local State = CoreModule:GetState()

function WarpModule:SmoothWarp()
    if not State.WarpEnabled then return end
    local root = CoreModule:GetRootPart()
    if not root or not root:IsDescendantOf(game) then return end

    if not State.WarpBlockBypassEnabled then
        -- ワープ禁止ゾーン判定など（未実装・拡張可）
    end

    local currentPos = root.Position
    local targetPos = currentPos + Vector3.new(0, 90, 0)

    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(root, tweenInfo, {Position = targetPos})
    tween:Play()
    tween.Completed:Wait()
    LoggerModule:AddLog("ワープ実行完了")
end

function WarpModule:AutoWarpLoop()
    while true do
        if State.WarpEnabled then
            self:SmoothWarp()
        end
        task.wait(2)
    end
end

return WarpModule
-- ResetProtectionModule.lua
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)

local ResetProtectionModule = {}

local State = CoreModule:GetState()

function ResetProtectionModule:MonitorReset()
    while State.ResetProtectionEnabled do
        local humanoid = CoreModule:GetHumanoid()
        if humanoid then
            if humanoid.Health <= 0 then
                humanoid.Health = 100
                LoggerModule:AddLog("リセット検知：回復で復帰")
            end
        end
        task.wait(0.5)
    end
end

function ResetProtectionModule:MonitorCharacter()
    while State.ResetProtectionEnabled do
        local char = CoreModule:GetCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            LoggerModule:AddLog("キャラ紛失検出：復元処理")
            local lp = game:GetService("Players").LocalPlayer
            lp:LoadCharacter()
        end
        task.wait(1)
    end
end

function ResetProtectionModule:Start()
    coroutine.wrap(function()
        self:MonitorReset()
    end)()
    coroutine.wrap(function()
        self:MonitorCharacter()
    end)()
end

return ResetProtectionModule
-- TransparencyModule.lua
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)

local TransparencyModule = {}
local State = CoreModule:GetState()

function TransparencyModule:ApplyTransparency()
    local char = CoreModule:GetCharacter()
    if not char then return end

    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = State.TransparencyEnabled and 1 or 0
        end
    end

    LoggerModule:AddLog("透明化: " .. tostring(State.TransparencyEnabled))
end

return TransparencyModule
-- NetworkOwnershipModule.lua
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)

local NetworkOwnershipModule = {}
local State = CoreModule:GetState()

function NetworkOwnershipModule:ForceOwnership()
    while State.NetworkOwnershipEnabled do
        local root = CoreModule:GetRootPart()
        if root then
            pcall(function()
                root:SetNetworkOwner(game.Players.LocalPlayer)
            end)
        end
        task.wait(1)
    end
end

return NetworkOwnershipModule
-- ToolProtectionModule.lua
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)

local ToolProtectionModule = {}
local State = CoreModule:GetState()

function ToolProtectionModule:MonitorTools()
    while State.ToolProtectionEnabled do
        local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and not tool:FindFirstChild("Handle") then
                    LoggerModule:AddLog("ツール破壊検出：" .. tool.Name)
                    local newTool = tool:Clone()
                    newTool.Parent = backpack
                    tool:Destroy()
                    LoggerModule:AddLog("ツール復元：" .. newTool.Name)
                end
            end
        end
        task.wait(1)
    end
end

return ToolProtectionModule

-- MultiLayerMonitorModule.lua
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)

local MultiLayerMonitorModule = {}

function MultiLayerMonitorModule:WatchRoot()
    while true do
        local root = CoreModule:GetRootPart()
        if not root then
            LoggerModule:AddLog("RootPartが存在しません。復旧を試みます。")
            game.Players.LocalPlayer:LoadCharacter()
        end
        task.wait(2)
    end
end

function MultiLayerMonitorModule:Start()
    coroutine.wrap(function()
        self:WatchRoot()
    end)()
end

return MultiLayerMonitorModule
-- MainScript.lua
local Core = require(script.CoreModule)
local Logger = require(script.LoggerModule)
local Warp = require(script.WarpModule)
local Reset = require(script.ResetProtectionModule)
local Transparency = require(script.TransparencyModule)
local NetOwner = require(script.NetworkOwnershipModule)
local ToolProtect = require(script.ToolProtectionModule)
local KickProtect = require(script.KickProtectionModule)
local Monitor = require(script.MultiLayerMonitorModule)

-- 起動処理
Logger:AddLog("システム起動中...")
Reset:Start()
Monitor:Start()
KickProtect:InterceptKick()

coroutine.wrap(function()
    Warp:AutoWarpLoop()
end)()

coroutine.wrap(function()
    NetOwner:ForceOwnership()
end)()

coroutine.wrap(function()
    ToolProtect:MonitorTools()
end)()

-- 透明トグル監視
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        local s = Core:GetState()
        Core:SetState("TransparencyEnabled", not s.TransparencyEnabled)
        Transparency:ApplyTransparency()
    end
end)

Logger:AddLog("システム起動完了")
-- GuiControlModule.lua
local CoreModule = require(script.Parent.CoreModule)
local LoggerModule = require(script.Parent.LoggerModule)
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local GuiControlModule = {}

function GuiControlModule:CreateControlPanel()
    local screenGui = CoreGui:FindFirstChild("daxhabGui")
    if not screenGui then return end

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 120, 0, 28)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleButton.BackgroundTransparency = 0.3
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 16
    toggleButton.Text = "GUI切り替え"
    toggleButton.Parent = screenGui

    toggleButton.MouseButton1Click:Connect(function()
        local state = CoreModule:GetState()
        state.GuiVisible = not state.GuiVisible
        for _, child in ipairs(screenGui:GetChildren()) do
            if child:IsA("Frame") and child ~= toggleButton then
                child.Visible = state.GuiVisible
            end
        end
        LoggerModule:AddLog("GUI表示: " .. tostring(state.GuiVisible))
    end)

    local warpToggle = Instance.new("TextButton")
    warpToggle.Size = UDim2.new(0, 120, 0, 26)
    warpToggle.Position = UDim2.new(0, 10, 0, 45)
    warpToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    warpToggle.BackgroundTransparency = 0.2
    warpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    warpToggle.Font = Enum.Font.SourceSans
    warpToggle.TextSize = 14
    warpToggle.Text = "ワープON/OFF"
    warpToggle.Parent = screenGui

    warpToggle.MouseButton1Click:Connect(function()
        local state = CoreModule:GetState()
        state.WarpEnabled = not state.WarpEnabled
        LoggerModule:AddLog("Warp: " .. tostring(state.WarpEnabled))
    end)
end

return GuiControlModule
local GuiControl = require(script.GuiControlModule)
GuiControl:CreateControlPanel()
