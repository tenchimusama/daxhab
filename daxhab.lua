-- daxhab 完全強化ワープスクリプト
local player = game.Players.LocalPlayer
local char = player.Character
local mouse = player:GetMouse()
local buttonPressed = false

-- ワープ機能
local function teleportToAbove()
    -- プレイヤーの現在位置を取得
    local currentPos = char.HumanoidRootPart.Position

    -- 真上にワープ先を設定
    local targetPos = Vector3.new(currentPos.X, currentPos.Y + 50, currentPos.Z)

    -- ワープの成功率（99.9%）
    local success = math.random() < 0.999
    if success then
        -- オブジェクト貫通の確認（オブジェクトがないか確認）
        local ray = Ray.new(currentPos, Vector3.new(0, 100, 0))
        local hit, position = game.Workspace:FindPartOnRay(ray, char)
        
        if not hit then
            -- オブジェクトがない場合のみワープ
            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            print("ワープ成功！")
        else
            -- オブジェクトがある場合、上にさらにワープ
            while hit do
                targetPos = targetPos + Vector3.new(0, 10, 0)
                ray = Ray.new(targetPos, Vector3.new(0, 100, 0))
                hit, position = game.Workspace:FindPartOnRay(ray, char)
            end
            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            print("オブジェクト貫通してワープ成功！")
        end
    else
        print("ワープ失敗")
    end
end

-- リセット回避（回避機能最強化）
local function resetAvoidance()
    -- リセット回避のために繰り返し高速ワープ
    while buttonPressed do
        teleportToAbove()
        wait(0.1)
    end
end

-- サーバー監視回避（最強回避）
local function serverMonitorAvoidance()
    -- 監視回避のためにランダムに位置補正
    while buttonPressed do
        local randomOffset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
        char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position + randomOffset)
        wait(0.5)
    end
end

-- ボタン状態変更とワープ回避開始
local function toggleButtonState()
    if buttonPressed then
        -- オフにする場合、ワープと回避を停止
        buttonPressed = false
        print("停止！")
    else
        -- オンにする場合、ワープと回避を開始
        buttonPressed = true
        print("実行中！")
        -- ワープと回避を同時に実行
        teleportToAbove()
        resetAvoidance()
        serverMonitorAvoidance()
    end
end

-- UIの設定（ボタン）
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, -25)
button.Text = "ワープ＆回避"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.Parent = screenGui

-- ボタンのクリック時の動作
button.MouseButton1Click:Connect(function()
    -- ボタン状態を切り替える
    if buttonPressed then
        button.Text = "ワープ＆回避"
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        button.Text = "実行中"
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
    toggleButtonState() -- 状態を変更して実行
end)

-- UIが画面に表示されるように
screenGui.Enabled = true
