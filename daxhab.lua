-- daxhab_maximum_pro.lua
-- 最強プロハッカースクリプト
-- ワープと貫通機能を完全に無効化した最強のスクリプト

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- 物理エンジン無効化：障害物を無視する
local function disableCollision()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 障害物を通過
            part.Anchored = false  -- 物理エンジンを無効化
        end
    end
end

-- サーバー同期完全無効化：ワープや貫通後のサーバー側の修正を防ぐ
local function disableServerSync()
    local metatable = getmetatable(game)
    metatable.__index = function(t, key)
        if key == "TeleportEvent" then
            return function() end  -- サーバーとの同期を完全に無効化
        end
        return rawget(t, key)
    end
end

-- デバッグ無効化：ゲームのデバッグ機能を無効化し、スクリプトを検出されにくくする
local function disableDebugging()
    local debugMetatable = getmetatable(game)
    debugMetatable.__newindex = function(t, key, value)
        if key == "Player" then return end  -- Playerの更新を無効化
        rawset(t, key, value)
    end
end

-- ワープ機能：指定した位置に瞬時にワープ
local function teleportToTarget(targetPosition)
    -- ワープ実行
    humanoidRootPart.CFrame = CFrame.new(targetPosition)
    
    -- ワープ後に物理無効化
    disableCollision()
    
    -- サーバー同期無効化
    disableServerSync()
    
    -- ワープ完了後、エフェクト表示
    local warpEffect = Instance.new("Part")
    warpEffect.Shape = Enum.PartType.Ball
    warpEffect.Size = Vector3.new(10, 10, 10)
    warpEffect.Position = humanoidRootPart.Position
    warpEffect.Anchored = true
    warpEffect.CanCollide = false
    warpEffect.Material = Enum.Material.Neon
    warpEffect.Color = Color3.fromRGB(0, 255, 255)
    warpEffect.Parent = game.Workspace
    game.Debris:AddItem(warpEffect, 0.5)  -- 0.5秒後にエフェクト削除
end

-- 貫通機能：障害物を無視して進み続ける
local function enablePenetration()
    -- 貫通前に物理エンジン完全無効化
    disableCollision()
    
    -- 貫通を無限に続ける
    while true do
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 10)  -- 前方に貫通
        wait(0.1)  -- 貫通速度
    end
end

-- ワープボタン：クリックした位置にワープ
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ"
teleportButton.TextSize = 30
teleportButton.Size = UDim2.new(0, 200, 0, 50)
teleportButton.Position = UDim2.new(0.5, -100, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.MouseButton1Click:Connect(function()
    -- クリック位置にワープ
    local targetPosition = player:GetMouse().Hit.p
    teleportToTarget(targetPosition)
end)

-- 貫通ボタン：貫通を開始
local penetrationButton = Instance.new("TextButton")
penetrationButton.Parent = screenGui
penetrationButton.Text = "貫通"
penetrationButton.TextSize = 30
penetrationButton.Size = UDim2.new(0, 200, 0, 50)
penetrationButton.Position = UDim2.new(0.5, -100, 0.7, 0)
penetrationButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
penetrationButton.TextColor3 = Color3.fromRGB(255, 255, 255)
penetrationButton.MouseButton1Click:Connect(function()
    enablePenetration()  -- 貫通開始
end)

-- 初期化処理：デバッグ無効化、物理エンジン無効化、サーバー同期無効化
disableCollision()
disableServerSync()
disableDebugging()
