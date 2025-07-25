-- ✅ daxhab/dax完全版ワープスクリプト（StarterPlayerScripts用 LocalScript）

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
repeat wait() until camera and camera.ViewportSize.X > 0

local function getCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

-- UI作成
local function createButton()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DaxhabUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	screenGui.ResetOnSpawn = false

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.125, 0, 0.125, 0)
	button.Position = UDim2.new(0.4375, 0, 0.4375, 0)
	button.Text = "ワープ"
	button.Font = Enum.Font.GothamBold
	button.TextSize = 20
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	button.ZIndex = 2
	button.Parent = screenGui

	-- 背景画像（daxhab/dax）
	local bgImage = Instance.new("ImageLabel")
	bgImage.Size = UDim2.new(1, 0, 1, 0)
	bgImage.Position = UDim2.new(0, 0, 0, 0)
	bgImage.BackgroundTransparency = 1
	bgImage.Image = "rbxassetid://INSERT_IMAGE_ID_HERE" -- 差し替え必要
	bgImage.ZIndex = 1
	bgImage.Parent = button

	-- 虹色グラデーション
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,165,0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,0)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
	}
	gradient.Parent = button

	-- ドラッグ可能処理
	local dragging = false
	local offset = Vector2.new()

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = input.Position - button.AbsolutePosition
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local newPos = input.Position - offset
			button.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return button
end

-- 天井がなくなるまで上昇ワープ
local function warpUp()
	local char, humanoid, rootPart = getCharacter()
	humanoid.PlatformStand = true
	rootPart.CanCollide = false
	rootPart.Anchored = false
	rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 5, 0)

	local maxSteps = 150
	for i = 1, maxSteps do
		local ray = workspace:Raycast(rootPart.Position, Vector3.new(0, 10, 0), RaycastParams.new())
		if ray then break end
		rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
		wait(0.01)
	end

	wait(0.2)
	humanoid.PlatformStand = false
end

-- リセット回避：座標が下がったら戻す
local function startAntiRes
