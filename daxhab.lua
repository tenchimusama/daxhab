-- 完全リセット回避・運営監視回避・指定の場所でリセット回避（最強プロハッカー仕様）

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- ワープの高さをキャラクター6.5人分に設定
local warpHeight = 6.5 * character.Humanoid.HipWidth  -- キャラクターの高さを元に計算

-- 目標の位置（ワープ先）
local targetPosition = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + warpHeight, humanoidRootPart.Position.Z)

-- ワープ完了の確認関数
local function teleportPlayer()
    local currentPosition = humanoidRootPart.Position
    local success = false
    
    -- ワープを繰り返し、指定位置に到達するまで行う
    while (currentPosition - targetPosition).Magnitude > 0.1 do
        -- ワープする
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        currentPosition = humanoidRootPart.Position
        wait(0.1)  -- 少し待ってから再確認
    end

    -- ワープ成功後、停止
    success = true
    print("ワープ成功！")
    
    -- ここでワープ後の位置にとどまる
    while success do
        -- キャラクターが指定位置にいることを確認
        if (humanoidRootPart.Position - targetPosition).Magnitude < 0.1 then
            break  -- 位置がほぼ一致したらループを抜ける
        end
        wait(0.1)  -- 少し待ってから再確認
    end

    print("指定位置に留まっています。ワープ停止。")
end

-- リセット回避（運営による位置リセットを回避）
local resetAvoidEnabled = true  -- リセット回避機能をオンにする

local function resetAvoidance()
    if resetAvoidEnabled then
        local lastPosition = humanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                local currentPosition = humanoidRootPart.Position
                -- リセットされそうなタイミングを予測し、即座にワープ
                if (currentPosition - lastPosition).Magnitude < 0.1 then
                    local newPosition = currentPosition + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
                    character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
                end
                lastPosition = currentPosition
            end
        end)
    end
end

-- 高速ワープの繰り返しとリセット回避
local function continuousTeleport()
    local isTeleported = false
    while not isTeleported do
        teleportPlayer()  -- 高速ワープを実行
        wait(0.5)  -- 0.5秒ごとにワープを繰り返し
    end
end

-- サーバーの監視回避
local function avoidServerDetection()
    local currentPosition = humanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)  -- 運営の監視範囲（例: XYZ座標の範囲）
    
    -- 監視範囲外へ補正
    if (currentPosition - detectedArea).Magnitude < 100 then
        -- ランダムに位置を補正
        local newPos = Vector3.new(math.random(-1000, 1000), currentPosition.Y, math.random(-1000, 1000))
        character:SetPrimaryPartCFrame(CFrame.new(newPos))
    end
end

-- リセット回避ボタン
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = player.PlayerGui
buttonWarp.Size = UDim2.new(0, 200, 0, 50)
buttonWarp.Position = UDim2.new(0.5, -100, 0.5, -25)
buttonWarp.Text = "高速ワープ"
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonWarp.TextColor3 = Color3.fromRGB(0, 255, 0)
buttonWarp.Font = Enum.Font.SourceSans
buttonWarp.TextSize = 20
buttonWarp.BorderSizePixel = 0

buttonWarp.MouseButton1Click:Connect(function()
    -- 高速ワープ開始
    continuousTeleport()
end)

-- リセット回避処理を実行
resetAvoidance()

-- サーバー監視回避を強化
game:GetService("RunService").Heartbeat:Connect(function()
    avoidServerDetection()  -- サーバーの監視回避
end)
