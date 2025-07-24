-- 絶対リセット回避・監視回避・ワープ強化版

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- 背景UI（タイトルとdaxhab / 作者: dax）
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 120, 0, 40)  -- 横長の長方形にして高さを半分に設定
background.Position = UDim2.new(0.5, -60, 0.5, -20)  -- 背景を中央に配置
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- 黒色背景
background.BorderSizePixel = 0  -- 枠線なし

-- タイトルテキスト（daxhab / 作者: dax）
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(0, 120, 0, 10)  -- タイトルサイズを小さく
titleLabel.Position = UDim2.new(0.5, -60, 0, 0)  -- 上部に配置
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 8  -- テキストサイズを小さく
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- 緑色
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1  -- 背景透明
titleLabel.Font = Enum.Font.Gotham -- マシュマロ風のフォントに変更

-- ワープボタンUI（横長、文字色虹色）
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(1, 0, 0.3, 0)  -- 横長のボタン、背景に合わせて調整
buttonWarp.Position = UDim2.new(0, 0, 0.5, 0)  -- ボタンを背景内で配置
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 10  -- ボタンのテキストサイズを少し大きく
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 白背景
buttonWarp.TextColor3 = Color3.fromRGB(255, 0, 255)  -- 初期文字色（虹色に変更予定）
buttonWarp.BorderSizePixel = 0  -- ボタンの枠線を消す
buttonWarp.Font = Enum.Font.SourceSans -- POP風フォントに変更

-- リセット回避ボタンUI（横長）
local buttonResetAvoid = Instance.new("TextButton")
buttonResetAvoid.Parent = background
buttonResetAvoid.Size = UDim2.new(1, 0, 0.3, 0)  -- 横長ボタン
buttonResetAvoid.Position = UDim2.new(0, 0, 0.85, 0)  -- リセット回避ボタンを配置
buttonResetAvoid.Text = "リセット回避: オフ"
buttonResetAvoid.TextSize = 10  -- テキストサイズを少し大きく
buttonResetAvoid.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 白背景
buttonResetAvoid.TextColor3 = Color3.fromRGB(255, 0, 255)  -- 初期文字色（虹色に変更予定）
buttonResetAvoid.BorderSizePixel = 0  -- ボタンの枠線を消す
buttonResetAvoid.Font = Enum.Font.SourceSans -- POP風フォントに変更

-- 虹色エフェクト（ボタンに追加）
local function updateButtonTextColor()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    buttonWarp.TextColor3 = color
    buttonResetAvoid.TextColor3 = color
end

game:GetService("RunService").Heartbeat:Connect(updateButtonTextColor)

-- ワープ機能（真上にワープ）
local function teleportPlayer()
    local successChance = math.random() < 0.99  -- 99%の確率で成功
    if successChance then
        -- 高さをさらに半分に設定（キャラクターの2人分の高さ）
        local warpHeight = 2.5  -- 半分の高さ（前回の5.15625の半分）
        local currentPosition = player.Character.HumanoidRootPart.Position
        local newPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
        
        -- 一瞬でワープ
        player.Character:SetPrimaryPartCFrame(CFrame.new(newPosition))
    else
        warn("ワープ失敗")  -- 1%の確率で失敗
    end
end

-- **運営の監視回避と位置補正強化**
local function avoidServerDetection()
    local currentPosition = player.Character.HumanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)  -- 運営の監視範囲（例: XYZ座標の範囲）
    
    -- 監視範囲外へ補正する
    if (currentPosition - detectedArea).Magnitude < 100 then
        -- ランダムに位置を補正
        local newPos = Vector3.new(math.random(-1000, 1000), currentPosition.Y, math.random(-1000, 1000))
        player.Character:SetPrimaryPartCFrame(CFrame.new(newPos))
    end
end

-- リセット回避（運営による位置リセットを回避）
local resetAvoidEnabled = false

local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled  -- オン/オフを切り替え
    if resetAvoidEnabled then
        buttonResetAvoid.Text = "リセット回避: オン"
    else
        buttonResetAvoid.Text = "リセット回避: オフ"
    end
end

-- リセット回避処理（運営による位置リセットを回避）
local function resetAvoidance()
    if resetAvoidEnabled then
        local lastPosition = player.Character.HumanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local currentPosition = player.Character.HumanoidRootPart.Position
                -- リセットされそうなタイミングを予測し、位置補正
                if (currentPosition - lastPosition).Magnitude < 0.1 then
                    -- 位置が近くなったら即座に補正
                    local newPosition = currentPosition + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
                end
                lastPosition = currentPosition
            end
        end)
    end
end

-- 運営のブロック機能を回避するための補正
local function destroyBlocker()
    -- "Blocker"という名前のオブジェクトを探して削除
    local blocker = game.Workspace:FindFirstChild("Blocker")
    if blocker then
        blocker:Destroy()
        print("運営のブロック機能を破壊しました")
    end
end

-- ワープボタンのクリック処理
buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープを実行
end)

-- リセット回避ボタンのクリック処理
buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()  -- リセット回避のオン/オフを切り替え
end)

-- リセット回避の監視
resetAvoidance()

-- 運営の監視回避をチェック
game:GetService("RunService").Heartbeat:Connect(function()
    avoidServerDetection()  -- サーバーの監視回避
    destroyBlocker()         -- 運営のブロック機能を破壊
end)
