-- ユーザーインターフェース
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ScreenGuiを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景ラベル（daxhab, 作成者:dax）
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.85
background.BorderSizePixel = 0
background.Parent = screenGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "daxhab\n作成者: dax"
textLabel.Font = Enum.Font.Code
textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
textLabel.TextSize = 28
textLabel.TextWrapped = true
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.Parent = background

-- ボタンの作成
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, 140, 0, 40)
warpButton.Position = UDim2.new(0.5, -70, 0.85, 0)
warpButton.BackgroundColor3 = Color3.new(0, 0, 0)
warpButton.BackgroundTransparency = 0.3
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.Code
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextSize = 24
warpButton.BorderSizePixel = 1
warpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Parent = screenGui

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

-- ドラッグ機能
local dragging = false
local dragStartPos = Vector2.new()
local dragOffset = Vector2.new()

warpButton.MouseButton1Down:Connect(function(input)
    dragging = true
    dragStartPos = input.Position
    dragOffset = warpButton.Position - UDim2.new(0, dragStartPos.X, 0, dragStartPos.Y)
end)

warpButton.MouseMoved:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStartPos
        warpButton.Position = UDim2.new(0, delta.X + dragOffset.X, 0, delta.Y + dragOffset.Y)
    end
end)

warpButton.MouseButton1Up:Connect(function()
    dragging = false
end)
