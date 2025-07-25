-- ✅ 完全版スクリプト（UI表示 + 真上ワープ + 天井貫通 + リセット回避 + 虹色UI + ドラッグ可能）
-- 🔧 LocalScriptで実行（StarterPlayerScripts推奨）

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
repeat wait() until camera.ViewportSize.X > 0

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- GUI作成
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "DaxhabUI"
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Parent = screenGui
button.Name = "WarpButton"
button.Text = "daxhab/作者dax"
button.Size = UDim2.new(0.125, 0, 0.125, 0)
button.Position = UDim2.new(0.4375, 0, 0.4375, 0)
button.BackgroundTransparency = 0
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 20
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0

-- 虹色背景
local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255,165,0)),
	ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0,255,0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,0,255)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(75,0,130)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(238,130,238))
}
gradient.Parent = button

-- ドラッグ処理
local dragging, offset
button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		offset = input.Position - button.AbsolutePosition
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local newPos = input.Position - offset
		button.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- 天井貫通ワープ
local function warpUpThroughCeiling()
	local maxSteps = 100
	local step = 0
	while step < maxSteps do
		local ray = workspace:Raycast(rootPart.Position, Vector3.new(0, 10, 0))
		if ray then break end
		rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
		step += 1
		wait(0.05)
	end
end

-- リセット回避用位置補正
spawn(function()
	while true do
		if rootPart.Position.Y < -50 then
			rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 100, 0)
		end
		wait(0.2)
	end
end)

-- 物理無効化
local function disablePhysics()
	humanoid.PlatformStand = true
	rootPart.CanCollide = false
end

-- ボタンクリック時の処理
button.MouseButton1Click:Connect(function()
	disablePhysics()
	warpUpThroughCeiling()
end)

print("✅ 完全版スクリプト初期化完了")
