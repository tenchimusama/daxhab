-- daxhab v7 強化版 ワープ・透明化・ブロック無効化・リセット対策 完全版
-- 作者: dax + ChatGPT 改良版

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- === キャラクター＆HRP取得・復旧関数 ===
local function GetCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end

local char, hrp = GetCharacter()

-- === GUI作成 ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "daxhabProtectionGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 260)
Frame.Position = UDim2.new(0.5, -160, 0.7, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- 背景スクロールテキスト
local BgText = Instance.new("TextLabel")
BgText.Size = UDim2.new(2, 0, 1, 0)
BgText.Position = UDim2.new(0, 0, 0, 0)
BgText.BackgroundTransparency = 1
BgText.Text = "daxhab / 作 dax    daxhab / 作 dax    daxhab / 作 dax    daxhab / 作 dax"
BgText.TextColor3 = Color3.fromRGB(0,255,0)
BgText.Font = Enum.Font.Code
BgText.TextScaled = true
BgText.TextTransparency = 0.85
BgText.ZIndex = 0
BgText.Parent = Frame

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "daxhab / 作 dax"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.Code
Title.TextScaled = true
Title.Parent = Frame
Title.ZIndex = 1

-- 危険度表示ラベル
local DangerLabel = Instance.new("TextLabel")
DangerLabel.Size = UDim2.new(1, 0, 0, 20)
DangerLabel.Position = UDim2.new(0, 0, 0, 35)
DangerLabel.BackgroundTransparency = 1
DangerLabel.Text = "危険度: 安全"
DangerLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
DangerLabel.Font = Enum.Font.Code
DangerLabel.TextScaled = true
DangerLabel.Parent = Frame
DangerLabel.ZIndex = 1

-- 履歴ログ用フレーム
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -10, 0, 90)
LogFrame.Position = UDim2.new(0, 5, 0, 60)
LogFrame.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
LogFrame.BorderSizePixel = 0
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

-- ログを管理するテーブル
local logs = {}

local function AddLog(text)
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -10, 0, 18)
    logLabel.BackgroundTransparency = 1
    logLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    logLabel.Font = Enum.Font.Code
    logLabel.TextScaled = true
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.Text = text
    logLabel.Parent = LogFrame

    table.insert(logs, logLabel)
    if #logs > 10 then
        logs[1]:Destroy()
        table.remove(logs, 1)
    end
    -- 更新スクロールサイズ
    RunService.Heartbeat:Wait()
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- === ボタンの作成ヘルパー ===
local function CreateButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.Code
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = Frame
    return btn
end

-- === トグル状態 ===
local isProtected = false
local isTransparent = false
local isBypassBlock = false

-- === 危険度管理 ===
local dangerLevel = 0 -- 0=安全,1=中,2=高

local function UpdateDangerLabel()
    local texts = {"安全", "中", "高"}
    local colors = {
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 140, 0),
        Color3.fromRGB(255, 0, 0),
    }
    DangerLabel.Text = "危険度: " .. texts[dangerLevel+1]
    DangerLabel.TextColor3 = colors[dangerLevel+1]
end

-- === 保護処理 ===
local connections = {}

local function DisconnectAll()
    for _, conn in pairs(connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    connections = {}
end

local function ProtectCharacter()
    if not hrp or not char then
        char, hrp = GetCharacter()
    end

    isProtected = true
    dangerLevel = 0
    UpdateDangerLabel()
    AddLog("保護開始")

    -- キャラ状態監視ループ
    spawn(function()
        while isProtected do
            pcall(function()
                if hrp.Anchored then
                    hrp.Anchored = false
                    dangerLevel = math.max(dangerLevel, 2)
                    AddLog("検知: Anchored解除")
                    UpdateDangerLabel()
                end
                if hrp.Transparency > (isTransparent and 0.9 or 0) then
                    hrp.Transparency = isTransparent and 0.8 or 0
                    AddLog("透明度補正")
                end
                if not hrp.CanCollide and not isTransparent then
                    hrp.CanCollide = true
                    AddLog("CanCollide補正")
                end
                if hrp.Velocity.Magnitude > 150 then
                    hrp.Velocity = Vector3.new(0,0,0)
                    dangerLevel = math.max(dangerLevel,1)
                    UpdateDangerLabel()
                    AddLog("高速移動補正")
                end
                -- サイズ補正
                if hrp.Size.Magnitude < 0.5 then
                    hrp.Size = Vector3.new(2,2,1)
                    AddLog("サイズ補正")
                end
            end)
            wait(0.03)
        end
    end)

    -- Humanoid.Died自動復帰
    spawn(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local conn
            conn = hum.Died:Connect(function()
                if isProtected then
                    AddLog("死亡検知: キャラ再生成")
                    wait(0.2)
                    LocalPlayer:LoadCharacter()
                end
            end)
            table.insert(connections, conn)
        end
    end)

    -- HumanoidRootPartの削除検知 → 即復旧 & 危険度UP
    spawn(function()
        while isProtected do
            wait(0.5)
            if not hrp or not hrp.Parent then
                dangerLevel = 2
                UpdateDangerLabel()
                AddLog("HumanoidRootPart消失検知: 再取得中")
                char, hrp = GetCharacter()
                AddLog("HumanoidRootPart再取得完了")
            end
        end
    end)

    -- ネットワーク所有権強制奪取
    spawn(function()
        while isProtected do
            if hrp and hrp.Parent then
                pcall(function()
                    hrp:SetNetworkOwner(LocalPlayer)
                end)
            end
            wait(0.1)
        end
    end)

    -- 重力維持
    local baseGravity = Workspace.Gravity
    spawn(function()
        while isProtected do
            if Workspace.Gravity ~= baseGravity then
                Workspace.Gravity = baseGravity
                AddLog("重力補正")
                dangerLevel = math.max(dangerLevel,1)
                UpdateDangerLabel()
            end
            wait(0.3)
        end
    end)

    -- メタテーブル改変検知と通信遮断 (名前call防止)
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local selfStr = tostring(self):lower()
        if (method == "fireserver" or method == "invokeserver") then
            local blockKeywords = {"tp","warp","teleport","fly","walk","rootpart","humanoidrootpart"}
            for _, kw in pairs(blockKeywords) do
                if selfStr:find(kw) then
                    AddLog("通信遮断: " .. kw)
                    return nil
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)

    table.insert(connections, RunService.Heartbeat:Connect(function()
        -- メタテーブル復旧チェック
        local mt2 = getrawmetatable(game)
        setreadonly(mt2, false)
        if mt2.__namecall ~= mt.__namecall then
            mt2.__namecall = mt.__namecall
        end
        setreadonly(mt2, true)
    end))
end

local function StopProtection()
    isProtected = false
    AddLog("保護停止")
    DisconnectAll()
    dangerLevel = 0
    UpdateDangerLabel()
end

-- === 透明化処理 ===
local function SetTransparency(on)
    if not hrp or not char then return end
    isTransparent = on
    if on then
        -- 透明化対象
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.LocalTransparencyModifier = 0.8
            end
            if part:IsA("Accessory") then
                for _, ap in pairs(part:GetChildren()) do
                    if ap:IsA("BasePart") then
                        ap.LocalTransparencyModifier = 0.8
                    end
                end
            end
        end
        hrp.LocalTransparencyModifier = 0.8
    else
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.LocalTransparencyModifier = 0
            end
            if part:IsA("Accessory") then
                for _, ap in pairs(part:GetChildren()) do
                    if ap:IsA("BasePart") then
                        ap.LocalTransparencyModifier = 0
                    end
                end
            end
        end
        hrp.LocalTransparencyModifier = 0
    end
end

-- === ワープ機能 ===
local function DetectObstacleUp(fromPos, height)
    -- 上方向に障害物があるかRaycastで検出
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Workspace:Raycast(fromPos, Vector3.new(0, height, 0), rayParams)
    return ray and ray.Instance
end

local function WarpUp()
    if not hrp or not char then return end

    local baseHeight = 45 -- 約15人分の高さ
    local targetHeight = baseHeight

    -- ブロック無効がオンなら高さを自動増加＆障害物は通過
    if isBypassBlock then
        local obstacle = DetectObstacleUp(hrp.Position, targetHeight)
        local tries = 0
        while obstacle and tries < 5 do
            targetHeight = targetHeight + 10
            obstacle = DetectObstacleUp(hrp.Position, targetHeight)
            tries = tries + 1
        end
        AddLog("ブロック検出回避 高さ調整: " .. targetHeight)
    end

    -- ワープの滑らかTween移動＆再試行3回
    local succeeded = false
    for attempt = 1, 3 do
        local targetPos = hrp.Position + Vector3.new(0, targetHeight, 0)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
        tween:Play()
        tween.Completed:Wait()

        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 3 then
            succeeded = true
            AddLog("ワープ成功（試行" .. attempt .. "）")
            break
        else
            AddLog("ワープ試行" .. attempt .. "失敗 距離：" .. string.format("%.2f", dist))
            wait(0.05)
        end
    end

    if not succeeded then
        -- 強制CFrame移動
        hrp.CFrame = hrp.CFrame + Vector3.new(0, targetHeight, 0)
        AddLog("ワープ強制実行")
    end
end

-- === ブロック無効トグル ===
local function ToggleBypassBlock()
    isBypassBlock = not isBypassBlock
    AddLog("ブロック無効: " .. (isBypassBlock and "ON" or "OFF"))
end

-- === ボタン作成 ===
local warpBtn = CreateButton("↑ ワープ", 160)
local transBtn = CreateButton("👻 透明化", 210)
local bypassBtn = CreateButton("🚫 ブロック無効", 260)

warpBtn.MouseButton1Click:Connect(function()
    WarpUp()
end)

transBtn.MouseButton1Click:Connect(function()
    SetTransparency(not isTransparent)
    AddLog("透明化トグル: " .. (isTransparent and "ON" or "OFF"))
end)

bypassBtn.MouseButton1Click:Connect(function()
    ToggleBypassBlock()
end)

-- === GUI 背景スクロールアニメーション ===
spawn(function()
    local offset = 0
    while true do
        offset = offset - 2
        if offset <= -BgText.AbsoluteSize.X / 2 then
            offset = 0
        end
        BgText.Position = UDim2.new(0, offset, 0, 0)
        wait(0.03)
    end
end)

-- === キャラ再取得 & 自動保護再起動 ===
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.1)
    char, hrp = GetCharacter()
    if isProtected then
        ProtectCharacter()
        AddLog("キャラ変更検知: 保護再起動")
    end
end)

-- === 自動保護開始 ===
ProtectCharacter()

print("✅ daxhab v7 完全版 起動完了 by dax + ChatGPT")
