local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景UI（1/5に縮小）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 120, 0, 60)  -- 横長
background.Position = UDim2.new(0.5, -60, 0.5, -30)  -- 背景を中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 背景色
background.BorderSizePixel = 0  -- 枠線なし

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 120, 0, 10)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 5
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.TextStrokeTransparency = 0.5
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold

-- 仕切り（ボタンとタイトルの間）
local divider = Instance.new("Frame")
divider.Parent = background
divider.Size = UDim2.new(0, 120, 0, 1)
divider.Position = UDim2.new(0, 0, 0, 15)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- ワープ＆回避ボタン作成
local buttonWarpReset = Instance.new("TextButton")
buttonWarpReset.Parent = background
buttonWarpReset.Size = UDim2.new(0, 100, 0, 20)  -- サイズを1/5に縮小
buttonWarpReset.Position = UDim2.new(0.5, -50, 0, 20)
buttonWarpReset.Text = "ワープ＆回避"
buttonWarpReset.TextSize = 8
buttonWarpReset.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- 初期色：赤
buttonWarpReset.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonWarpReset.BorderSizePixel = 0
buttonWarpReset.Font = Enum.Font.SourceSansBold

-- ボタンの状態を更新する関数
local function updateButtonState(button, isActive)
    if isActive then
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
        button.Text = "実行中 🟢"
    else
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- 赤色
        button.Text = "ワープ＆回避 🔴"
    end
end

-- ワープ機能（真上にワープ）
local function teleportPlayer()
    local successChance = math.random() < 0.999  -- 99.9%の確率で成功
    if successChance then
        local currentPosition = humanoidRootPart.Position
        local warpHeight = 6.5 * character.Humanoid.HipWidth  -- キャラの高さに合わせてワープ
        local targetPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- オブジェクト貫通してワープ
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        updateButtonState(buttonWarpReset, true)  -- ボタンを実行中に更新
    else
        updateButtonState(buttonWarpReset, false)  -- 失敗した場合ボタン状態を更新
    end
end

-- リセット回避（ワープ後、リセットされないように位置補正）
local function resetAvoidance()
    local lastPosition = humanoidRootPart.Position
    game:GetService("RunService").Heartbeat:Connect(function()
        if (humanoidRootPart.Position - lastPosition).Magnitude < 0.1 then
            local newPosition = humanoidRootPart.Position + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
            humanoidRootPart.CFrame = CFrame.new(newPosition)
        end
        lastPosition = humanoidRootPart.Position
    end)
end

-- 高速ワープ（リセットされないように繰り返しワープ）
local function highSpeedWarp()
    local warpCount = 0
    while warpCount < 10 do
        teleportPlayer()  -- ワープ実行
        warpCount = warpCount + 1
        wait(0.1)  -- 高速でワープする
    end
end

-- 通常回避（常に回避を行う）
local function normalAvoidance()
    -- 高速ワープを利用して、リセットのタイミングを回避
    highSpeedWarp()
end

-- ボタンのクリック処理（ワープ＆回避同時実行）
buttonWarpReset.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープ実行
    resetAvoidance()  -- リセット回避を同時に実行
    normalAvoidance()  -- 常に回避を行う
end)

-- ゲーム内のサーバー監視回避（監視範囲から外れた位置に補正）
local function serverDetectionAvoid()
    local currentPos = humanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)
    if (currentPos - detectedArea).Magnitude < 100 then
        local newPos = Vector3.new(math.random(-1000, 1000), currentPos.Y, math.random(-1000, 1000))
        humanoidRootPart.CFrame = CFrame.new(newPos)
    end
end

-- サーバー監視回避を定期的にチェック
game:GetService("RunService").Heartbeat:Connect(function()
    serverDetectionAvoid()  -- サーバー監視回避
end)
