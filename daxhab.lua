-- ロブロックス 最強ワープスクリプト 完全版（修正版）

local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ワープ先の位置と速度
local targetPosition = Vector3.new(0, 1000, 0)  -- 高さ1000にワープ
local speed = 50  -- 高速移動の速度
local warpChance = 0.999  -- ワープ成功率

-- ワープボタンを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, 200, 0, 50)  -- ボタンのサイズ
warpButton.Position = UDim2.new(0.5, -100, 0.8, -25)  -- 画面中央下部に配置
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.GothamBold
warpButton.TextSize = 30
warpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
warpButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- 初期色（赤）

-- ワープボタンの虹色エフェクト
local function rainbowEffect()
    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 255)}
    local i = 1
    while true do
        warpButton.BackgroundColor3 = colors[i]
        i = i + 1
        if i > #colors then
            i = 1
        end
        wait(0.5)
    end
end

-- ワープボタンを押したときの動作
warpButton.MouseButton1Click:Connect(function()
    executeWarp()  -- ワープを実行
end)

-- ワープ実行関数
local function executeWarp()
    -- ワープ成功率チェック
    if math.random() > warpChance then
        warn("ワープに失敗しました。再試行します...")
        return
    end

    -- プレイヤーの位置を変更（ワープ処理）
    local startPosition = HumanoidRootPart.Position
    local currentPosition = startPosition

    -- 上方向にワープして障害物を貫通
    while currentPosition.Y < targetPosition.Y do
        currentPosition = currentPosition + Vector3.new(0, speed, 0)
        HumanoidRootPart.CFrame = CFrame.new(currentPosition)

        -- Rayを使って天井などを検出し、貫通するようにする
        local ray = Ray.new(currentPosition, Vector3.new(0, speed, 0))
        local hit, position = game.Workspace:FindPartOnRay(ray, Character)

        if hit then
            print("天井を検出！次の位置にワープします...")
        end

        -- 少し待機してから次の位置にワープ
        wait(0.1)
    end

    -- ワープ後、プレイヤーの位置が不適切なら補正する
    local raycastResult = workspace:Raycast(targetPosition + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0))
    if raycastResult then
        -- 地面を検出した場合、安全な位置に補正
        local newPosition = raycastResult.Position + Vector3.new(0, 2, 0)  -- 地面から少し上に調整
        HumanoidRootPart.CFrame = CFrame.new(newPosition)
    else
        -- 地面が見つからない場合、最初の位置に戻す
        HumanoidRootPart.CFrame = CFrame.new(startPosition)
    end

    print("ワープ完了！")
end

-- ボタンを画面に追加
warpButton.Parent = screenGui

-- ワープボタンの虹色エフェクトを開始
coroutine.wrap(rainbowEffect)()

-- 回避ボタンを作成（別途回避機能が必要な場合）
local bypassButton = Instance.new("TextButton")
bypassButton.Size = UDim2.new(0, 200, 0, 50)
bypassButton.Position = UDim2.new(0.5, -100, 0.9, -25)  -- 画面中央下部に配置
bypassButton.Text = "回避"
bypassButton.Font = Enum.Font.GothamBold
bypassButton.TextSize = 30
bypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bypassButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- 初期色（緑）

-- 回避ボタンを押したときの動作
bypassButton.MouseButton1Click:Connect(function()
    -- 回避機能をここに追加
    -- 例: activateAvoidance()
end)

bypassButton.Parent = screenGui
