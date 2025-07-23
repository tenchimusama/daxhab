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
textLabel.Size = UDim2.new(1, 0, 0.2, 0)  -- 少し小さめにして、画面上部に配置
textLabel.BackgroundTransparency = 1
textLabel.Text = "daxhab\n作成者: dax"
textLabel.Font = Enum.Font.Code
textLabel.TextColor3 = Color3.
