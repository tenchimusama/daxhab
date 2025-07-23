local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ScreenGuiを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景ラベル（daxhab, 作成者: dax）
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

-- ワープボタン作成 (中央に配置、サイズを画面の7分の1に)
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, screenGui.AbsoluteSize.X / 7, 0, screenGui.AbsoluteSize.Y / 7)
warpButton.Position = UDim2.new(0.5, -screenGui.AbsoluteSize.X / 14, 0.5, -screenGui.AbsoluteSize.Y / 14)
warpButton.BackgroundColor3 = Color3.new(0, 0, 0)
warpButton.BackgroundTransparency = 0.3
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.Code
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextSize = 30
warpButton.BorderSizePixel = 1
warpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Parent = screenGui

-- スクリプトをドラッグ可能にするためのコード
local dragging = false
local dragInput, dragStart, startPos

warpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = warpButton.Position
    end
end)

warpButton.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        warpButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

    -- 天井がある場合にワープ先を決定
    local raycastResult = workspace:Raycast(originPos, Vector3.new(0, 5000, 0), raycastParams)
    local targetY = raycastResult and raycastResult.Position.Y - 5 or originPos.Y + 5000

    -- ワープのピュン！とした動き
    hrp.CFrame = CFrame.new(originPos.X, targetY, originPos.Z)
end)

-- アンチKick（プラグインまたはバックドア対策）
local function AntiKick()
    -- 無効化するためのシグナルを送信
    game:GetService("Players").LocalPlayer.PlayerScripts:ClearAllChildren()
end

-- 無限ループで定期的に対策
while true do
    wait(5) -- 5秒ごとに実行
    AntiKick()
end
