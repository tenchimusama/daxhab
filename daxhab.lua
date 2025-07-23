local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ScreenGuiを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景フレーム（ブラックアウト、少し透過）
local background = Instance.new("Frame")
background.Size = UDim2.new(0, 400, 0, 120)  -- サイズ調整
background.Position = UDim2.new(0.5, -200, 0.5, -60)  -- 中央に配置
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.8
background.BorderSizePixel = 1
background.BorderColor3 = Color3.fromRGB(0, 255, 0)
background.Parent = screenGui

-- タイトルのテキスト
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.3, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "daxhab\n作成者: dax"
title.Font = Enum.Font.Code
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 18
title.TextWrapped = true
title.TextYAlignment = Enum.TextYAlignment.Top
title.Parent = background

-- ワープボタン作成
local warpBut
