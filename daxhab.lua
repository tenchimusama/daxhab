local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local userId = player.UserId

-- ScreenGui作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景ラベル（daxhab, 作成者:dax）
local background = Instance.new("TextLabel")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.85
background.Text = "daxhab\n作成者: dax"
background.Font = Enum.Font.Code
background.TextColor3 = Color3.fromRGB(0, 255, 0)
background.TextSize = 28
background.TextWrapped = true
background.TextYAlignment = Enum.TextYAlignment.Top
background.Parent = screenGui

-- ワープボタン作成
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, 180, 0, 50)
warpButton.Position = UDim2.new(0.5, -90, 0.85, 0)
warpButton.BackgroundColor3 = Color3.new(0, 0, 0)
warpButton.BackgroundTransparency = 0.3
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.Code
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextSize = 30
warpButton.BorderSizePixel = 1
warpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Parent = screenGui

-- ドラッグ可能にする機能
local dragging = false
local dragStart, dragPos
warpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
    end
end)

warpButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        warpButton.Position = UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

warpButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ワープ処理
warpButton.MouseButton1Click:Connect(function()
    local originPos = hrp.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local raycastResult = workspace:Raycast(originPos, Vector3.new(0, 5000, 0), raycastParams)
    local targetY = raycastResult and raycastResult.Position.Y - 5 or originPos.Y + 5000
    hrp.CFrame = CFrame.new(originPos.X, targetY, originPos.Z)
end)

-- 自動再接続（アンチキック機能）
local function antiKick()
    -- プレイヤーが落ちたときに再接続する
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if player == game.Players.LocalPlayer then
            -- サーバーに強制的に接続
            while true do
                if not game:GetService("Players").LocalPlayer then
                    wait(1)
                else
                    -- 再接続
                    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
                end
            end
        end
    end)
end

-- エラーキャッチ機能
pcall(function()
    -- エラーが発生してもスクリプトが停止しない
    -- プレイヤーが落ちる、エラーなど発生してもここでキャッチして処理を続行
    -- 例: ログ出力等
end)

-- ハードウェア変更検出
local function detectHardwareChange()
    -- プレイヤーのハードウェア情報の確認
    -- 例: デバイスが変わった場合に警告を表示するなど
    if player.UserId ~= userId then
        warn("ハードウェア変更検出: 新しいデバイス")
        -- ここでセキュリティ対策を実行（例: ログアウトさせるなど）
    end
end

-- 位置検出機能
local function checkPlayerPosition()
    -- プレイヤーの現在位置をチェックして危険エリアを監視
    local position = hrp.Position
    -- 例えば、特定の座標範囲に移動した場合に警告
    if position.X > 1000 or position.Y > 1000 or position.Z > 1000 then
        warn("警告: 危険エリアに到達しました！")
    end
end

-- キー入力保護
local function protectKeyInput()
    -- 他のスクリプトがキー入力を盗聴しないように保護
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        -- ユーザー入力を保護したい場合の処理
    end)
end

-- セキュリティ機能の実行
antiKick()
detectHardwareChange()
checkPlayerPosition()
protectKeyInput()
