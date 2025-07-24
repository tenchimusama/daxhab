-- プレイヤーの設定
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local playerHeight = 7.5 * 5  -- キャラの高さを7.5人分 (1人あたり5 studs)
local moveSpeed = 0.05  -- 移動速度を遅くする（自然な動き）
local movementDelay = 0.1  -- 移動後のディレイ
local antiKickDelay = 1  -- アンチキックのための確認間隔
local randomMoveDelay = 0.5  -- ランダム化の間隔

-- 屋上の座標を設定（例）
local roofPosition = Vector3.new(0, 100, 0)  -- 屋上の位置

-- 真上にワープする関数
local function moveUp()
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, playerHeight, 0)  -- 現在位置の真上
    smoothMove(targetPosition)
end

-- スムーズな移動を行う関数（補間）
local function smoothMove(targetPosition)
    local currentPosition = humanoidRootPart.Position
    local steps = 50  -- 移動を小刻みに行うためのステップ数
    for i = 1, steps do
        -- ランダムオフセットを追加して動きをより自然にする
        currentPosition = currentPosition:Lerp(targetPosition + Vector3.new(math.random(-0.1, 0.1), math.random(-0.1, 0.1), math.random(-0.1, 0.1)), moveSpeed)
        humanoidRootPart.CFrame = CFrame.new(currentPosition)
        wait(movementDelay)
    end
end

-- 移動後に座標補正やバグを防止するための処理を追加
local function antiKickFix()
    wait(antiKickDelay)
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, playerHeight, 0)
    if (humanoidRootPart.Position - targetPosition).magnitude < 0.1 then
        humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 0.1, 0))  -- 小さなズレを加えてリセット回避
    end
end

-- リセット後に停止または補正する処理
local function stopIfReset()
    if humanoidRootPart.Position.Y < 1 then  -- Y座標が低い＝リセット状態
        print("リセット状態が検出されました。位置を補正します。")
        -- リセットされた場合、少しだけ位置を補正
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, 0))  -- Y座標を少し上に補正
        return true
    end
    return false
end

-- UIにボタンを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- カラフルで可愛いボタンの作成
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, player.PlayerGui.AbsoluteSize.X / 8, 0, player.PlayerGui.AbsoluteSize.Y / 8)
button.Position = UDim2.new(0.5, -player.PlayerGui.AbsoluteSize.X / 16, 0.5, -player.PlayerGui.AbsoluteSize.Y / 16)
button.Text = "daxhab/作者dax"  -- ボタンにテキストを表示
button.
