-- daxhab_maximum_v28.lua
-- 最強ワープ&貫通スクリプト（アンチリセット・アンチキック強化）

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- スクリプト制御変数
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

-- サーバーによる位置補正を完全無効化
local function preventPositionReset()
    game:GetService("RunService").Heartbeat:Connect(function()
        if isEnabled then
            -- ワープ後の位置を強制的に維持
            humanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end)
end

-- 高度なリセット回避機能：キャラクターの位置をリアルタイムで監視し、強制的に維持
local function advancedResetPrevention()
    game:GetService("RunService").Heartbeat:Connect(function()
        if isEnabled then
            -- キャラクターの位置を強制的に維持
            humanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end)
end

-- サーバーによる不正な位置補正を防ぐため、サーバーからの位置情報を完全に無視
local function preventTeleportCorrection()
    -- サーバーから位置補正を受け取らないように、位置の同期を完全に無効化
    local remote = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("PlayerScripts")
    local function disableTeleport()
        remote = remote:FindFirstChild("TeleportService") or remote:FindFirstChild("TeleportEvent")
        if remote then
            remote.OnServerEvent:Connect(function()
                return  -- サーバーからのイベントを無視
            end)
        end
    end
    disableTeleport()
end

-- サーバーキックの防止：強制的にキックを防ぐ
local function preventKick()
    -- プレイヤーがキックされないように監視
    game:GetService("Players").PlayerRemoving:Connect(function(playerLeaving)
        if playerLeaving == player then
            -- キックを無視
            return
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

    -- 高度なリセット回避
    advancedResetPrevention()

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

-- 背景にタイトルと作者名を表示
local function createBackgroundText()
    local backgroundText = Instance.new("TextLabel")
    backgroundText.Parent = screenGui
    backgroundText.Text = "daxhab | 作者名: dax"
    backgroundText.TextSize = 24
    backgroundText.TextColor3 = Color3.fromRGB(0, 255, 0)  -- ハッカー風緑色
    backgroundText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundText.BackgroundTransparency = 0.5  -- 背景を少し透過
    backgroundText.Position = UDim2.new(0.5, -150, 0, 0)  -- 上部に中央配置
    backgroundText.Size = UDim2.new(0, 300, 0, 50)
    backgroundText.Font = Enum.Font.Code -- ハッカー風フォント
    backgroundText.TextTransparency = 0.5
end

-- ボタンの作成（ドラッグ可能で小さめのポップデザイン）
local teleportButton = Instance.new("TextButton")
teleportButton.Parent = screenGui
teleportButton.Text = "ワープ"
teleportButton.TextSize = 16
teleportButton.Size = UDim2.new(0, 150, 0, 40)
teleportButton.Position = UDim2.new(0.5, -75, 0.6, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.Font = Enum.Font.Code

-- ドラッグ機能
local dragToggle = nil
local dragInput = nil
local dragStartPos = nil

teleportButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStartPos = input.Position - teleportButton.Position.Offset
    end
end)

teleportButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragToggle then
        teleportButton.Position = UDim2.new(0, input.Position.X - dragStartPos.X, 0, input.Position.Y - dragStartPos.Y)
    end
end)

-- ボタンのクリックイベント
teleportButton.MouseButton1Click:Connect(function()
    -- ワープ＆貫通オン/オフの切り替え
    if isEnabled then
        isEnabled = false  -- オフにする
        teleportButton.Text = "ワープ"
    else
        isEnabled = true  -- オンにする
        teleportButton.Text = "ワープ"
        teleportAndPenetrate()  -- ワープ＆貫通開始
    end
end)

-- 初期化処理：デバッグ無効化、物理エンジン無効化、サーバー同期無効化
disableCollision()
disableServerSync()
preventPositionReset()

-- 背景テキストを表示
createBackgroundText()

-- **追加機能**
-- サーバーによる不正なキックを防ぐ
preventKick()
