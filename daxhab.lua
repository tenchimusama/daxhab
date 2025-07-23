-- プレイヤー情報取得
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- スクリーンGUIの作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景（ボタンと統一デザイン）
local background = Instance.new("TextLabel")
background.Size = UDim2.new(0, 180, 0, 50) -- 画面の7分の1に設定
background.Position = UDim2.new(0.5, -90, 0.5, -25) -- 中央配置
background.BackgroundColor3 = Color3.new(0, 0, 0) -- 黒背景
background.BackgroundTransparency = 0.7
background.Text = "" -- 背景テキスト無し
background.Font = Enum.Font.Code
background.TextColor3 = Color3.fromRGB(0, 255, 0) -- 緑色のテキスト
background.TextSize = 28
background.TextWrapped = true
background.TextYAlignment = Enum.TextYAlignment.Center
background.TextXAlignment = Enum.TextXAlignment.Center
background.Parent = screenGui

-- ワープボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, 180, 0, 50)
warpButton.Position = UDim2.new(0.5, -90, 0.5, -25)
warpButton.BackgroundColor3 = Color3.new(0, 0, 0)
warpButton.BackgroundTransparency = 0.3
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.Code
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextSize = 30
warpButton.BorderSizePixel = 1
warpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Parent = screenGui

-- ボタンドラッグ機能（背景とボタン）
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    screenGui.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
end

warpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = screenGui.Position
        input.Changed:Connect(function()
            if dragging then
                updateDrag(input)
            end
        end)
    end
end)

warpButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ワープ処理
warpButton.MouseButton1Click:Connect(function()
    -- オブジェクトを貫通してワープ
    local originPos = hrp.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    -- 天井を貫通するワープ
    local raycastResult = workspace:Raycast(originPos, Vector3.new(0, 5000, 0), raycastParams)
    local targetY = raycastResult and raycastResult.Position.Y - 5 or originPos.Y + 5000

    -- ワープ処理（物理的に戻されないように対応）
    hrp.CFrame = CFrame.new(originPos.X, targetY, originPos.Z)

    -- 瞬時にワープこれね
    wait(0.1)
    hrp.CFrame = CFrame.new(originPos.X, targetY, originPos.Z)
end)

-- 追加対策（例: 物理学的な干渉を避けるなど）
local function antiKick()
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(5000, 5000, 5000) -- 強力な力を加える
    bodyVelocity.Velocity = Vector3.new(0, 0, 0) -- 現在の速度
    bodyVelocity.Parent = hrp -- ヒューマノイドルートパートに追加
end

-- 毎フレーム呼び出し（アンチKick）
game:GetService("RunService").Heartbeat:Connect(function()
    antiKick()
end)
