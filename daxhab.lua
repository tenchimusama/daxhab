-- 最強リセット回避・瞬時天井貫通とワープ（プロハッカー風 完全回避）

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景UI（タイトルとdaxhab / 作者: dax）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 200, 0, 180)  -- 背景のサイズを少し大きく
background.Position = UDim2.new(0.5, -100, 0.5, -90)  -- 背景を中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒色背景
background.BorderSizePixel = 0  -- 枠線なし

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 200, 0, 20)  -- タイトルサイズを小さく
titleLabel.Position = UDim2.new(0.5, -100, 0, 5)  -- 上部に配置
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 12  -- テキストサイズを小さく
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1  -- 背景透明
titleLabel.Font = Enum.Font.Gotham -- マシュマロ風のフォントに変更

-- 仕切り（ボタンとタイトルの間に仕切りを入れる）
local divider = Instance.new("Frame")
divider.Parent = background
divider.Size = UDim2.new(0, 200, 0, 2)  -- 仕切りのサイズ
divider.Position = UDim2.new(0.5, -100, 0, 30)  -- 仕切りの位置
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 白色の仕切り

-- ワープボタンUI（背景と一体化）
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(1, 0, 0.3, 0)  -- ボタンのサイズを背景に合わせて調整
buttonWarp.Position = UDim2.new(0, 0, 0.6, 0)  -- ボタンを背景内で配置
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 14  -- ボタンのテキストサイズ
buttonWarp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒背景
buttonWarp.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
buttonWarp.BorderSizePixel = 0  -- ボタンの枠線を消す
buttonWarp.Font = Enum.Font.SourceSans -- POP風フォントに変更

-- リセット回避ボタンUI（背景と一体化）
local buttonResetAvoid = Instance.new("TextButton")
buttonResetAvoid.Parent = background
buttonResetAvoid.Size = UDim2.new(1, 0, 0.3, 0)  -- ボタンのサイズを背景に合わせて調整
buttonResetAvoid.Position = UDim2.new(0, 0, 0.9, 0)  -- リセット回避ボタンを配置
buttonResetAvoid.Text = "リセット回避: オフ"
buttonResetAvoid.TextSize = 14
buttonResetAvoid.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒背景
buttonResetAvoid.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
buttonResetAvoid.BorderSizePixel = 0  -- ボタンの枠線を消す
buttonResetAvoid.Font = Enum.Font.SourceSans -- POP風フォントに変更

-- 虹色エフェクト（タイトルに追加）
local function updateTitle()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    titleLabel.TextColor3 = color
end

game:GetService("RunService").Heartbeat:Connect(updateTitle)

-- ワープ機能（真上にワープ）
local function teleportPlayer()
    local successChance = math.random() < 0.98  -- 98%の確率で成功
    if successChance then
        -- 真上にワープ
        local warpHeight = 41.25  -- キャラクターの7.5人分の高さ
        local currentPosition = player.Character.HumanoidRootPart.Position
        local newPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- 一瞬でワープ
        player.Character:SetPrimaryPartCFrame(CFrame.new(newPosition))
    else
        warn("ワープ失敗")  -- 2%の確率で失敗
    end
end

-- 天井貫通機能（瞬時に貫通）
local function enableCeilingPass()
    local character = player.Character
    if character then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        -- 高さを強化して天井貫通
        local randomHeight = math.random(120, 200)  -- 高さをランダムで変更
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, randomHeight, 0)  -- 一瞬で貫通
    end
end

-- リセット回避（オン/オフ切り替え）
local resetAvoidEnabled = false  -- リセット回避を初期状態でオフに設定

local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled  -- オン/オフを切り替える

    -- ボタンテキストを更新
    if resetAvoidEnabled then
        buttonResetAvoid.Text = "リセット回避: オン"
    else
        buttonResetAvoid.Text = "リセット回避: オフ"
    end
end

-- リセット回避機能
local function resetAvoidance()
    if resetAvoidEnabled then
        local lastPosition = player.Character.HumanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = player.Character.HumanoidRootPart
                local currentPosition = humanoidRootPart.Position
                -- リセットされる前に位置補正
                if (currentPosition - lastPosition).Magnitude < 0.1 then
                    -- 位置が近くなったら少しずらす
                    local newPosition = currentPosition + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))  -- ランダムな位置に補正
                    humanoidRootPart.CFrame = CFrame.new(newPosition)
                end
                lastPosition = currentPosition  -- 新しい位置を記録
            end
        end)
    end
end

-- ワープボタンのクリック処理
buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープを実行
    enableCeilingPass()  -- 天井貫通を実行
end)

-- リセット回避ボタンのクリック処理
buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()  -- リセット回避のオン/オフを切り替え
end)

-- リセット回避の定期的な監視
resetAvoidance()

-- ドラッグ機能を追加
local dragging = false
local dragInput, dragStart, dragPos

background.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragInput = input
    end
end)

background.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        dragPos = input.Position - dragStart
        background.Position = UDim2.new(0, dragPos.X, 0, dragPos.Y)
    end
end)

background.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
