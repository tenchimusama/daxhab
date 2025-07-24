-- daxhab_maximum_v16.lua
-- 最強ワープ&貫通スクリプト（完全リセット防止、虹色テキスト流れ強化）

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local isEnabled = false  -- ワープと貫通のオン/オフフラグ
local warpHeight = 50  -- ワープの高さ（真上）
local penetrationSpeed = 5  -- 貫通速度

-- 物理エンジン無効化：障害物を無視して貫通する
local function disableCollision()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 障害物を通過
            part.Anchored = false  -- 物理エンジンを無効化
        end
    end
end

-- サーバー同期完全無効化：サーバー側の位置修正を無効化
local function disableServerSync()
    local metatable = getmetatable(game)
    metatable.__index = function(t, key)
        if key == "TeleportEvent" then
            return function() end  -- サーバー同期を無効化
        end
        return rawget(t, key)
    end
end

-- 物理エンジンやサーバーによる位置補正を完全に防ぐ
local function preventPositionReset()
    game:GetService("RunService").Heartbeat:Connect(function()
        if isEnabled then
            -- ワープ後の位置を強制的に維持
            humanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end)
end

-- ワープと貫通統合：ワープ後に貫通を続ける
local function teleportAndPenetrate()
    -- ワープの高さを設定（真上）
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, warpHeight, 0)  -- 50 studs上にワープ

    -- ワープ実行
    humanoidRootPart.CFrame = CFrame.new(targetPosition)

    -- 物理無効化
    disableCollision()

    -- サーバー同期無効化
    disableServerSync()

    -- 位置戻し防止
    preventPositionReset()

    -- 貫通を続ける（障害物がなくなるまで）
    while isEnabled do
        local targetPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * penetrationSpeed  -- 進行方向
        humanoidRootPart.CFrame = CFrame.new(targetPosition)  -- 前方に進む

        -- 障害物がなくなったら貫通終了
        local partInFront = workspace:FindPartOnRay(Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 10), character)
        if not partInFront then
            -- 障害物がなくなったら貫通終了
            break
        end
        wait(0.1)  -- 貫通速度調整
    end
end

-- 流れる虹色背景テキストの作成
local function createScrollingRainbowText()
    local rainbowText = Instance.new("TextLabel")
    rainbowText.Parent = screenGui
    rainbowText.Text = "daxhab  |  作者名: dax"
    rainbowText.TextSize = 40
    rainbowText.TextColor3 = Color3.fromRGB(255, 255, 255)
    rainbowText.BackgroundTransparency = 1
    rainbowText.Position = UDim2.new(0, 0, 0, 100)
    rainbowText.Size = UDim2.new(1, 0, 0, 50)

    -- 虹色エフェクト：テキストの色を周期的に変化させる
    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130), Color3.fromRGB(238, 130, 238)}
    local colorIndex = 1
    while true do
        rainbowText.TextColor3 = colors[colorIndex]
        colorIndex = (colorIndex % #colors) + 1
        wait(0.2)  -- 色変更の速度調整
    end

    -- テキストを横に流す
    local function scrollText()
        while true do
            rainbowText.Position = UDim2.new(0, rainbowText.Position.X.Offset - 2, 0, 100)
            if rainbowText.Position.X.Offset < -rainbowText.TextBounds.X then
                rainbowText.Position = UDim2.new(1, 0, 0, 100)  -- テキストが完全に流れたら反対側から再スタート
            end
            wait(0.02)
        end
    end

    -- 流れるテキストを開始
    spawn(scrollText)
end

-- ボタンの作成
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ＆貫通開始"
teleportButton.TextSize = 20  -- フォントサイズを調整
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 0, 0)

teleportButton.MouseButton1Click:Connect(function()
    -- ワープ＆貫通オン/オフの切り替え
    if isEnabled then
        isEnabled = false  -- オフにする
        teleportButton.Text = "ワープ＆貫通開始"
    else
        isEnabled = true  -- オンにする
        teleportButton.Text = "ワープ＆貫通停止"
        teleportAndPenetrate()  -- ワープ＆貫通開始
    end
end)

-- 初期化処理：デバッグ無効化、物理エンジン無効化、サーバー同期無効化
disableCollision()
disableServerSync()
disableDebugging()

-- 背景テキストを流す
createScrollingRainbowText()
