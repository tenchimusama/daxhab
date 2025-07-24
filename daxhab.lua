local isExecuting = false
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "ワープ＆回避"
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 14
button.Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui

-- ボタン状態変更
function changeButtonState(state)
    if state == "executing" then
        button.Text = "実行中"
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        button.Text = "ワープ＆回避"
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- ワープ機能
function warpPlayer()
    local success = math.random(1, 1000) <= 999  -- 99.9%成功
    if success then
        -- 真上にワープ
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Map.SpawnLocation.CFrame + Vector3.new(0, 50, 0)
        print("ワープ成功")
    else
        print("ワープ失敗")
    end
end

-- リセット回避
function avoidReset()
    -- 高速ワープと監視回避
    for i = 1, 10 do
        warpPlayer()
        wait(0.1)  -- 0.1秒待機してワープ
    end
end

-- ボタンのクリックイベント
button.MouseButton1Click:Connect(function()
    if not isExecuting then
        isExecuting = true
        changeButtonState("executing")
        warpPlayer()
        avoidReset()
        wait(1)  -- 動作が完了したら、少し待機
        isExecuting = false
        changeButtonState("idle")
    end
end)

-- サーバー監視回避
function serverMonitorAvoidance()
    -- プレイヤーが監視範囲に近づいた場合、ランダムに位置補正
    local randomPosition = Vector3.new(math.random(-500, 500), 50, math.random(-500, 500))
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPosition)
end
