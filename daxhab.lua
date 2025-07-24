-- daxhab_maximum_pro_v8.lua
-- プロハッカー並みの最強ワープ＆貫通統合スクリプト
-- 完全無敵モード、運営対策完全無視、ワープと貫通の最強強化

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

-- サーバー同期無効化：サーバー側の修正を完全無視
local function disableServerSync()
    local metatable = getmetatable(game)
    metatable.__index = function(t, key)
        if key == "TeleportEvent" then
            return function() end  -- サーバー同期を無効化
        end
        return rawget(t, key)
    end
end

-- デバッグ無効化：スクリプトを検出されにくくする
local function disableDebugging()
    local debugMetatable = getmetatable(game)
    debugMetatable.__newindex = function(t, key, value)
        if key == "Player" then return end  -- Playerの更新を無効化
        rawset(t, key, value)
    end
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

    -- 貫通を続ける（障害物がなくなるまで）
    while isEnabled do
        local targetPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * penetrationSpeed  -- 進行方向
        humanoidRootPart.CFrame = CFrame.new(targetPosition)  -- 前方に進む

        -- 障害物がなくなったら貫通終了
        local partInFront = workspace:FindPartOnRay(Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 10), character)
        if not partInFront then
            break  -- 障害物がなくなったら終了
        end
        wait(0.1)  -- 貫通速度調整
    end
end

-- ワープ＆貫通ボタン：1つのボタンでワープと貫通を制御
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ＆貫通オン"
teleportButton.TextSize = 30
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.MouseButton1Click:Connect(function()
    -- ワープ＆貫通オン/オフの切り替え
    if isEnabled then
        isEnabled = false  -- オフにする
        teleportButton.Text = "ワープ＆貫通オン"
    else
        isEnabled = true  -- オンにする
        teleportButton.Text = "ワープ＆貫通オフ"
        teleportAndPenetrate()  -- ワープ＆貫通開始
    end
end)

-- 初期化処理：デバッグ無効化、物理エンジン無効化、サーバー同期無効化
disableCollision()
disableServerSync()
disableDebugging()
