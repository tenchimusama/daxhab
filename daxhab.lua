-- daxhab Protection Script 完全版 統合版

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Core State --
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
    local char = CoreModule:GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

function CoreModule:GetRootPart()
    local char = CoreModule:GetCharacter()
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

-- Logger Module --
local LoggerModule = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "daxhabGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local BgFrame = Instance.new("Frame")
BgFrame.Size = UDim2.new(0, 280, 0, 180)
BgFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
BgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BgFrame.BackgroundTransparency = 0.7
BgFrame.BorderSizePixel = 0
BgFrame.ClipsDescendants = true
BgFrame.Parent = ScreenGui

local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 45
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 0, 211)),
}
Gradient.Parent = BgFrame

coroutine.wrap(function()
    while true do
        for i = 0, 1, 0.01 do
            Gradient.Offset = Vector2.new(i, 0)
            task.wait(0.03)
        end
        for i = 1, 0, -0.01 do
            Gradient.Offset = Vector2.new(i, 0)
            task.wait(0.03)
        end
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
    label.TextTransparency = 1
    label.TextStrokeTransparency = 1
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenText = TweenService:Create(label, tweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0})
    tweenText:Play()
    tweenText.Completed:Wait()
    task.wait(0.05)
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.CanvasSize.Y.Offset)
end

-- Warp Module --
local WarpModule = {}
local State = CoreModule:GetState()

function WarpModule:SmoothWarp()
    if not State.WarpEnabled then return end
    local root = CoreModule:GetRootPart()
    if not root or not root:IsDescendantOf(game) then return end

    if not State.WarpBlockBypassEnabled then
        -- 未実装のワープ禁止判定エリア対応など
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

-- Reset Protection Module --
local ResetProtectionModule = {}

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
            LocalPlayer:LoadCharacter()
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

-- Transparency Module --
local TransparencyModule = {}

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

-- Network Ownership Module --
local NetworkOwnershipModule = {}

function NetworkOwnershipModule:ForceOwnership()
    while State.NetworkOwnershipEnabled do
        local root = CoreModule:GetRootPart()
        if root then
            pcall(function()
                root:SetNetworkOwner(LocalPlayer)
            end)
        end
        task.wait(1)
    end
end

-- Tool Protection Module --
local ToolProtectionModule = {}

function ToolProtectionModule:MonitorTools()
    while State.ToolProtectionEnabled do
        local backpack = LocalPlayer:FindFirstChild("Backpack")
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

-- MultiLayer Monitor Module --
local MultiLayerMonitorModule = {}

function MultiLayerMonitorModule:WatchRoot()
    while true do
        local root = CoreModule:GetRootPart()
        if not root then
            LoggerModule:AddLog("RootPartが存在しません。復旧を試みます。")
            LocalPlayer:LoadCharacter()
        end
        task.wait(2)
    end
end

function MultiLayerMonitorModule:Start()
    coroutine.wrap(function()
        self:WatchRoot()
    end)()
end

-- Kick Protection Module --
local KickProtectionModule = {}

function KickProtectionModule:InterceptKick()
    if State.KickProtectionEnabled then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then
                LoggerModule:AddLog("キック検知をブロックしました。")
                return
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end

-- GUI Control Module --
local GuiControlModule = {}

function GuiControlModule:CreateControlPanel()
    local screenGui = ScreenGui
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
        State.GuiVisible = not State.GuiVisible
        for _, child in ipairs(screenGui:GetChildren()) do
            if child:IsA("Frame") and child ~= toggleButton then
                child.Visible = State.GuiVisible
            end
        end
        LoggerModule:AddLog("GUI表示: " .. tostring(State.GuiVisible))
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
        State.WarpEnabled = not State.WarpEnabled
        LoggerModule:AddLog("Warp: " .. tostring(State.WarpEnabled))
    end)
end

-- Main execution --
LoggerModule:AddLog("システム起動中...")
ResetProtectionModule:Start()
MultiLayerMonitorModule:Start()
KickProtectionModule:InterceptKick()
GuiControlModule:CreateControlPanel()

coroutine.wrap(function()
    WarpModule:AutoWarpLoop()
end)()

coroutine.wrap(function()
    NetworkOwnershipModule:ForceOwnership()
end)()

coroutine.wrap(function()
    ToolProtectionModule:MonitorTools()
end)()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        State.TransparencyEnabled = not State.TransparencyEnabled
        TransparencyModule:ApplyTransparency()
    end
end)

LoggerModule:AddLog("システム起動完了")
