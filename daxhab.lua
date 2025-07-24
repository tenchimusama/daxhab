-- プレイヤーとキャラクターの参照
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- スクリプト制御変数
local isEnabled = false
local warpHeight = 100  -- 初期ワープ距離
local penetrationSpeed = 10  -- 高速貫通
local speedMultiplier = 3  -- 高速ワープの加速係数
local maxWarpDistance = 150  -- 最大ワープ距離制限
local resetProtection = true  -- リセット回避有効
local canMove = true  -- 操作可能状態

-- 物理エンジンの無効化（オブジェクト貫通）
local function disablePhysics()
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false  -- 衝突無効化
            part.Anchored = true      -- 完全固定
        end
    end
end

-- サーバーからの位置修正、テレポート要求完全無効化
local function disableServerSync()
    local metatable = getmetatable(game)
    metatable.__index = function(t, key)
        if key == "TeleportEvent" then
            return function() end  -- サーバーのテレポート要求無効化
        end
        return rawget(t, key)
    end

    -- サーバーからの位置修正イベントを無効化
    game:GetService("NetworkClient").OnClientPositionChanged:Connect(function() end)

    -- サーバーからの補正・リセットを完全に無視する
    game:GetService("NetworkClient").OnClientEvent:Connect(function(eventName)
        if eventName == "PositionUpdate" or eventName == "Teleport" then
            -- 無視
            return nil
        end
    end)
end

-- 完全位置ロック（リセット回避）→ 操作可能に修正
local function forcePositionLock()
    game:GetService("RunService").Heartbeat:Connect(function()
        if resetProtection then
            if canMove then
                -- 位置の強制維持
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)  
            end
        end
    end)
end

-- キック防止（サーバーから強制切断を無効化）
local function preventKick()
    game:GetService("Players").PlayerAdded:Connect(function(newPlayer)
        if newPlayer == player then
            -- キック処理を無効化
            pcall(function()
                game:GetService("Players").LocalPlayer:Kick("ゲームが強制終了されました")  -- エラーメッセージを無効化
            end)
        end
    end)
end

-- エンジン監視の無効化（プロハッカー仕様）
local function disableEngineMonitoring()
    -- プロハッカー仕様でシステムの監視を回避
    local gameMeta = getmetatable(game)
    gameMeta.__index = function(t, key)
        if key == "Analytics" then
            return function() end  -- エンジン監視を完全に無視
        end
        return rawget(t, key)
    end
end

-- 高速ワープ＆貫通処理
local function teleportAndPenetrate()
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, warpHeight, 0)

    -- 最大ワープ距離制限を超えないように調整
    if (targetPosition - humanoidRootPart.Position).magnitude > maxWarpDistance then
        targetPosition = humanoidRootPart.Position + (targetPosition - humanoidRootPart.Position).unit * maxWarpDistance
    end

    -- 上に障害物がないかチェック
    local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, 1000, 0))
    local hitPart, hitPosition = workspace:FindPartOnRay(ray, character)

    -- 障害物がなければワープ
    if not hitPart then
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    else
        -- 障害物がある場合は、最上部にワープ
        local targetPosition = hitPosition + Vector3.new(0, 5, 0)  -- 少し上に
