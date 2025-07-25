--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- メインパネル
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.33, 0, 0.4, 0)
mainFrame.Position = UDim2.new(0.33, 0, 0.55, 0)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- UI折りたたみボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.1, 0, 0.08, 0)
toggleButton.Position = UDim2.new(0.9, -10, 0, 10)
toggleButton.Text = "✕"
toggleButton.TextColor3 = Color3.new(0, 1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.Font = Enum.Font.Code
toggleButton.TextScaled = true
toggleButton.Parent = mainFrame

local isVisible = true
toggleButton.MouseButton1Click:Connect(function()
	isVisible = not isVisible
	for _, child in pairs(mainFrame:GetChildren()) do
		if child ~= toggleButton then
			child.Visible = isVisible
		end
	toggleButton.Text = isVisible and "✕" or "≡"
end)

-- ロゴ
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0.2, 0)
logo.Position = UDim2.new(0, 0, 0, 0)
logo.BackgroundTransparency = 1
logo.TextColor3 = Color3.fromRGB(0, 255, 0)
logo.Font = Enum.Font.Code
logo.TextScaled = true
logo.Text = ""
logo.TextStrokeTransparency = 0.4
logo.TextStrokeColor3 = Color3.new(0, 0.5, 0)
logo.Parent = mainFrame

-- ロゴアニメーション（3D風に）
local function animateLogoFancy(text)
	logo.Text = ""
	coroutine.wrap(function()
		for i = 1, #text do
			local char = string.sub(text, i, i)
			logo.Text = logo.Text .. char
			logo.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
			logo.TextStrokeTransparency = 0
			logo.TextStrokeColor3 = Color3.fromRGB(20, 255, 20)
			logo.TextSize = 36 + math.sin(i + tick() * 10) * 2
			wait(0.04)
		end
	end)()
end
animateLogoFancy("< daxhab / by / dax >")

-- ログウィンドウ
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -10, 0.5, -10)
logBox.Position = UDim2.new(0, 5, 0.2, 5)
logBox.BackgroundColor3 = Color3.new(0, 0, 0)
logBox.TextColor3 = Color3.new(0, 1, 0)
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextSize = 14
logBox.TextWrapped = true
logBox.Text = ""
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

-- スタッド入力
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.3, 0, 0.12, 0)
heightInput.Position = UDim2.new(0.68, 0, 0.63, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
heightInput.TextColor3 = Color3.new(0, 1, 0)
heightInput.PlaceholderText = "↑スタッド"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

-- 現在のスタッド表示
local currentHeight = Instance.new("TextLabel")
currentHeight.Size = UDim2.new(0.3, 0, 0.12, 0)
currentHeight.Position = UDim2.new(0.68, 0, 0.77, 0)
currentHeight.BackgroundTransparency = 1
currentHeight.TextColor3 = Color3.new(0, 1, 0)
currentHeight.Font = Enum.Font.Code
currentHeight.TextScaled = true
currentHeight.Text = "↑: 40"
currentHeight.Parent = mainFrame

-- ボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0.65, 0, 0.15, 0)
warpButton.Position = UDim2.new(0.025, 0, 0.75, 0)
warpButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
warpButton.TextColor3 = Color3.new(0, 1, 0)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "[ WARP ↑ ]"
warpButton.Parent = mainFrame

-- アニメーション追加
local function animateButton(btn)
	TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		BackgroundColor3 = Color3.fromRGB(0, 100, 0)
	}):Play()
	wait(0.2)
	TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	}):Play()
end

-- ログ追加
local function addLog(text)
	logBox.Text = logBox.Text .. "\n> " .. text
end

-- ネットワーク所有権取得
local function setNetworkOwner(part)
	pcall(function()
		part:SetNetworkOwner(player)
	end)
end

-- リセット妨害（海外式）
StarterGui:SetCore("ResetButtonCallback", false)

-- ワープ処理
local function safeWarp()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then
		addLog("キャラクターの主要パーツが見つかりません")
		return
	end
	local height = tonumber(heightInput.Text)
	if not height then
		addLog("無効なスタッド数")
		return
	end
	currentHeight.Text = "↑: " .. tostring(height)
	addLog("ワープ中... (↑" .. tostring(height) .. " stud)")
	setNetworkOwner(root)
	local offset = Vector3.new(0, height, 0)
	local origin = root.Position
	local direction = offset
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local rayResult = workspace:Raycast(origin, direction, rayParams)
	local targetCFrame
	if rayResult then
		targetCFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
		addLog("障害物を検知、貫通位置に設定")
	else
		targetCFrame = root.CFrame + offset
	end
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	humanoid.AutoRotate = true
	root.Anchored = false
	root.Velocity = Vector3.zero
	root.RotVelocity = Vector3.zero
	setNetworkOwner(root)
	root.CFrame = targetCFrame
	local startTime = tick()
	local heartbeatConn
	heartbeatConn = RunService.Heartbeat:Connect(function()
		if tick() - startTime > 6 then
			heartbeatConn:Disconnect()
			return
		end
		if root and root.Parent then
			root.Velocity = Vector3.zero
			root.RotVelocity = Vector3.zero
			root.CFrame = targetCFrame
			humanoid.PlatformStand = false
			humanoid.Sit = false
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			setNetworkOwner(root)
		end
	end)
	addLog("ワープ成功（↑" .. tostring(height) .. " stud）")
end

-- ボタンイベント
warpButton.MouseButton1Click:Connect(function()
	animateButton(warpButton)
	safeWarp()
end)
