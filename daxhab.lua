--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

-- ロゴ
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0.2, 0)
logo.Position = UDim2.new(0, 0, 0, 0)
logo.BackgroundTransparency = 1
logo.TextColor3 = Color3.new(0, 1, 0)
logo.Font = Enum.Font.Code
logo.TextScaled = true
logo.Text = ""
logo.Parent = mainFrame

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
logBox.Text = ""  -- 初期ログ
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

-- ボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(1, -20, 0.15, 0)
warpButton.Position = UDim2.new(0, 10, 0.75, 0)
warpButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
warpButton.TextColor3 = Color3.new(0, 1, 0)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "[ WARP / 25↑ ]"
warpButton.Parent = mainFrame

-- ロゴアニメーション
local function animateLogo(text)
	logo.Text = ""
	coroutine.wrap(function()
		for i = 1, #text do
			logo.Text = string.sub(text, 1, i)
			wait(0.04)
		end
	end)()
end
animateLogo("daxhab / by / dax")

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

-- ワープ処理
local function safeWarp()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then
		addLog("キャラクターの主要パーツが見つかりません")
		return
	end

	addLog("ワープ中...")

	setNetworkOwner(root)
	
	local targetCFrame = root.CFrame + Vector3.new(0, 25, 0)
	
	-- 状態変更で落下状態を回避
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	root.Velocity = Vector3.zero
	root.RotVelocity = Vector3.zero
	
	-- 強制位置移動
	root.CFrame = targetCFrame

	-- サーバー同期回避：位置補正6秒間継続（より強化）
	local startTime = tick()
	local heartbeatConn
	heartbeatConn = RunService.Heartbeat:Connect(function()
		if tick() - startTime > 6 then
			heartbeatConn:Disconnect()
			return
		end
		if root and root.Parent then
			local dist = (root.Position - targetCFrame.Position).Magnitude
			if dist > 0.25 then
				root.CFrame = targetCFrame
				root.Velocity = Vector3.zero
				root.RotVelocity = Vector3.zero
				setNetworkOwner(root)
			end
		end
	end)

	addLog("ワープ成功（25スタッド上）")
end

-- ボタンイベント
warpButton.MouseButton1Click:Connect(safeWarp)
