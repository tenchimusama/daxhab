-- daxhab 最強プロハッカースクリプト
-- 作者: dax
-- フォント: ハッカー風
-- 背景: 動的ハック風

-- 必要なライブラリ
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- グローバル変数
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local object = nil
local originalPos = nil
local velocity = Vector3.new(0, 0, 0)
local ceiling = nil

-- 初期化: プレイヤーの初期位置を中央に
local function setInitialPosition()
    character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(0, 50, 0)
end

-- ワープ機能
local function warpToPosition(position)
    character:SetPrimaryPartCFrame(position)
end

-- 天井貫通機能
local function enableCeilingPenetration()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if ceiling then
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + 5, humanoidRootPart.Position.Z)
    end
end

-- 天井がなくなったら停止
local function stopIfCeilingIsGone()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if ceiling == nil then
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

-- 初期設定
setInitialPosition()

-- 天井を消す
local function removeCeiling()
    ceiling = nil
end

-- ボタンを押すとワープ
local function onWarpButtonPress()
    local warpPos = CFrame.new(0, 100, 0)
    warpToPosition(warpPos)
end

-- 貫通するタイミングを確認
local function checkForPenetration()
    if ceiling then
        enableCeilingPenetration()
    else
        stopIfCeilingIsGone()
    end
end

-- イベントリスナー
RunService.Heartbeat:Connect(function()
    checkForPenetration()
end)

-- ボタンイベント
mouse.Button1Down:Connect(onWarpButtonPress)

-- 背景動作
local function createDynamicBackground()
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = "daxhab: Hacking..."
    textLabel.Font = Enum.Font.Code
    textLabel.TextSize = 18
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0.5, -100, 0.5, -10)
    textLabel.Parent = game.CoreGui
    while true do
        textLabel.Text = "daxhab: Hacking in progress..."
        wait(0.5)
        textLabel.Text = "daxhab: Accessing mainframe..."
        wait(0.5)
        textLabel.Text = "daxhab: Bypassing security..."
        wait(0.5)
    end
end

createDynamicBackground()

-- メインルーチン
while true do
    wait(1)
end
