--[[
  daxhab ブレインロット対応版（ステルス超強化）
  超強力サーバー級ワープ対策スクリプト 完全ステルス強化版
  作者: dax
  特徴:
  - GUIステルス化（PlayerGui使用、右Shiftで表示切替）
  - 自動敵回避（近接プレイヤー検出→上昇ワープ）
  - 管理者検出と自動一時停止
  - 保護ログ・状態HUD表示
  - 高速物理移動（Tween非使用）
  - メタテーブル改変完全非使用（検知率最小）
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local protectionEnabled = true
local guiVisible = true

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- ステータスHUD
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealthProtectGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 240, 0, 30)
statusLabel.Position = UDim2.new(0.5, -120, 0.02, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
statusLabel.BorderColor3 = Color3.new(0, 1, 0)
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.Code
statusLabel.TextScaled = true
statusLabel.Text = "保護状態: 起動中"
statusLabel.Parent = screenGui

-- GUI表示切替
UserInputService.InputBegan:Connect(function(input, gpe)
  if gpe then return end
  if input.KeyCode == Enum.KeyCode.RightShift then
    guiVisible = not guiVisible
    screenGui.Enabled = guiVisible
  end
end)

-- 敵検出 → ワープ回避
spawn(function()
  while protectionEnabled do
    for _, p in pairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
        if dist < 18 then
          hrp.Velocity = Vector3.new(0, 100, 0)
          wait(0.3)
          break
        end
      end
    end
    wait(0.5)
  end
end)

-- 管理者検出（名前ベース）
local adminKeywords = {"admin", "moderator", "staff", "owner"}

spawn(function()
  while protectionEnabled do
    for _, p in pairs(Players:GetPlayers()) do
      local name = p.Name:lower()
      for _, kw in pairs(adminKeywords) do
        if name:find(kw) then
          protectionEnabled = false
          statusLabel.Text = "⚠️ 管理者検出、保護停止"
          return
        end
      end
    end
    wait(3)
  end
end)

-- フォールバック復活（死亡時）
LocalPlayer.CharacterAdded:Connect(function()
  wait(0.2)
  char = LocalPlayer.Character
  hum = char:WaitForChild("Humanoid")
  hrp = char:WaitForChild("HumanoidRootPart")
  protectionEnabled = true
  statusLabel.Text = "保護状態: 再起動"
end)

print("✅ daxhab ステルス完全版起動完了")
