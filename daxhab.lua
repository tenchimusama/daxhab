-- warp_script.lua
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ScreenGuiを作成
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
