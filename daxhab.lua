--[[
  daxhab ブレインロットを盗む向け
  超強力サーバー級ワープ対策スクリプト 完全版 強化版
  作者: dax
  GUI付き・自動再実行・高度自己防衛・強化ワープ機能・完全保護
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- キャラ初期化
local function InitCharacter()
  local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
  local hum = character:WaitForChild("Humanoid")
  local hrp = character:WaitForChild("HumanoidRootPart")
  return character, hum, hrp
end

local char, hum, hrp = InitCharacter()

local guiEnabled = true
local isProtected = false

-- 虹色関数
local function RainbowColor(t)
  local frequency = 0.4
  local red = math.floor(math.sin(frequency * t + 0) * 127 + 128)
  local green = math.floor(math.sin(frequency * t + 2) * 127 + 128)
  local blue = math.floor(math.sin(frequency * t + 4) * 127 + 128)
  return Color3.fromRGB(red, green, blue)
end

-- GUI作成
local function CreateGui()
  if CoreGui:FindFirstChild("daxhabProtectionGui") then
    CoreGui.daxhabProtectionGui:Destroy()
  end

  local ScreenGui = Instance.new("ScreenGui")
  ScreenGui.Name = "daxhabProtectionGui"
  ScreenGui.ResetOnSpawn = false
  ScreenGui.Parent = CoreGui

  local Frame = Instance.new("Frame")
  Frame.Size = UDim2.new(0, 240, 0, 130)
  Frame.Position = UDim2.new(0.5, -120, 0.85, 0)
  Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
  Frame.BorderSizePixel = 2
  Frame.BorderColor3 = Color3.new(0, 1, 0)
  Frame.Parent = ScreenGui
  Frame.Active = true
  Frame.Draggable = true

  local Title = Instance.new("TextLabel")
  Title.Text = "daxhab / 作者: dax"
  Title.Size = UDim2.new(1, 0, 0.2, 0)
  Title.BackgroundTransparency = 1
  Title.TextColor3 = Color3.new(0, 1, 0)
  Title.Font = Enum.Font.Code
  Title.TextScaled = true
  Title.Parent = Frame

  local StatusLabel = Instance.new("TextLabel")
  StatusLabel.Text = "保護状態: 未起動"
  StatusLabel.Size = UDim2.new(1, 0, 0.4, 0)
  StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
  StatusLabel.BackgroundTransparency = 1
  StatusLabel.TextColor3 = Color3.new(1, 1, 1)
  StatusLabel.Font = Enum.Font.Code
  StatusLabel.TextScaled = true
  StatusLabel.Parent = Frame

  local ToggleBtn = Instance.new("TextButton")
  ToggleBtn.Text = "保護開始"
  ToggleBtn.Size = UDim2.new(1, 0, 0.4, 0)
  ToggleBtn.Position = UDim2.new(0, 0, 0.6, 0)
  ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
  ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
  ToggleBtn.Font = Enum.Font.Code
  ToggleBtn.TextScaled = true
  ToggleBtn.Parent = Frame

  return ScreenGui, Title, StatusLabel, ToggleBtn
end

local ScreenGui, Title, StatusLabel, ToggleBtn = CreateGui()

-- GUI虹色アニメーション
spawn(function()
  local t = 0
  while true do
    if guiEnabled then
      local c = RainbowColor(t)
      Title.TextColor3 = c
      ToggleBtn.TextColor3 = c
      StatusLabel.TextColor3 = c
      t = t + 0.1
    end
    wait(0.03)
  end
end)

-- メタテーブルと関数の管理
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex

-- 通信偽装・遮断用キーワード
local blockKeywords = {"move", "walk", "position", "tp", "warp", "teleport", "fly", "jump", "rootpart", "humanoidrootpart", "hrp"}

-- __namecall強力フック（偽装・遮断）
mt.__namecall = newcclosure(function(self, ...)
  local method = getnamecallmethod()
  local selfStr = tostring(self):lower()

  if (method == "fireserver" or method == "invokeserver") then
    for _, keyword in ipairs(blockKeywords) do
      if selfStr:find(keyword) then
        -- 通信キャンセル
        return nil
      end
    end
  end
  return oldNamecall(self, ...)
end)

-- メタテーブル改変検知＆自動復旧
spawn(function()
  while true do
    wait(1)
    local mt2 = getrawmetatable(game)
    setreadonly(mt2, false)
    if mt2.__namecall ~= mt.__namecall then
      mt2.__namecall = mt.__namecall
    end
    setreadonly(mt2, true)
  end
end)

-- 保護状態監視
local protectionLoopConnections = {}

local function DisconnectProtectionLoops()
  for _, conn in pairs(protectionLoopConnections) do
    if conn and conn.Connected then
      conn:Disconnect()
    end
  end
  protectionLoopConnections = {}
end

-- Anchored/透明度/サイズ/CanCollide強制維持
local function AnchoredTransparencySizeWatcher()
  spawn(function()
    while isProtected do
      if hrp then
        if hrp.Anchored then hrp.Anchored = false end
        if hrp.Transparency and hrp.Transparency > 0.8 then hrp.Transparency = 0 end
        if hrp.Size and hrp.Size.Magnitude < 0.5 then hrp.Size = Vector3.new(2,2,1) end
        if hrp.CanCollide == false then hrp.CanCollide = true end
      end
      wait(0.03)
    end
  end)
end

-- Velocity制御（高速移動制限）
local function VelocityWatcher()
  spawn(function()
    while isProtected do
      if hrp then
        if hrp.Velocity.Magnitude > 150 then
          hrp.Velocity = Vector3.new(0,0,0)
        end
      end
      wait(0.03)
    end
  end)
end

-- 重力維持
local function GravityWatcher()
  local baseGravity = Workspace.Gravity
  spawn(function()
    while isProtected do
      if Workspace.Gravity ~= baseGravity then
        Workspace.Gravity = baseGravity
      end
      wait(0.1)
    end
  end)
end

-- ネットワーク所有権強制奪取（0.1秒間隔×2並列）
local function NetworkOwnershipEnforcer()
  spawn(function()
    while isProtected do
      if hrp and hrp:IsDescendantOf(Workspace) then
        pcall(function()
          hrp:SetNetworkOwner(LocalPlayer)
        end)
      end
      wait(0.1)
    end
  end)
  spawn(function()
    while isProtected do
      if hrp and hrp:IsDescendantOf(Workspace) then
        pcall(function()
          hrp:SetNetworkOwner(LocalPlayer)
        end)
      end
      wait(0.1)
    end
  end)
end

-- Humanoid.Died自動再接続＆即復帰
local function SecureHumanoidDied()
  if hum then
    local connected = false
    for _, conn in pairs(getconnections(hum.Died)) do
      if conn.Function == nil then
        conn:Disconnect()
      else
        connected = true
      end
    end
    if not connected then
      hum.Died:Connect(function()
        if isProtected then
          wait(0.3)
          if LocalPlayer.Character == nil then
            LocalPlayer:LoadCharacter()
          end
        end
      end)
    end
  end
end
spawn(function()
  while isProtected do
    SecureHumanoidDied()
    wait(5)
  end
end)

-- 巻き戻し滑らか補正（Tween使用・閾値15）
spawn(function()
  local lastPos = hrp.Position
  while isProtected do
    wait(0.1)
    if hrp and hrp.Parent then
      local dist = (hrp.Position - lastPos).Magnitude
      if dist > 15 then
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(lastPos)})
        tween:Play()
        tween.Completed:Wait()
      else
        lastPos = hrp.Position
      end
    end
  end
end)

-- キャラ再生成時の保護再設定
LocalPlayer.CharacterAdded:Connect(function(character)
  wait(0.05)
  char, hum, hrp = InitCharacter()
  if isProtected then
    StartProtection()
  end
end)

-- 自己防衛ループ（保護OFF検知やGUI破壊検知・即復活）
spawn(function()
  while true do
    wait(1.5)
    if not isProtected then StartProtection() end
    if not ScreenGui.Parent then ScreenGui.Parent = CoreGui end
  end
end)

-- 保護開始停止関数群
function StartProtection()
  if isProtected then return end
  isProtected = true
  StatusLabel.Text = "保護状態: 起動中"

  DisconnectProtectionLoops()

  AnchoredTransparencySizeWatcher()
  VelocityWatcher()
  GravityWatcher()
  NetworkOwnershipEnforcer()
  SecureHumanoidDied()

  ToggleBtn.Text = "保護停止"
end

function StopProtection()
  if not isProtected then return end
  isProtected = false
  StatusLabel.Text = "保護状態: 停止中"
  DisconnectProtectionLoops()
  ToggleBtn.Text = "保護開始"
end

ToggleBtn.MouseButton1Click:Connect(function()
  if isProtected then
    StopProtection()
  else
    StartProtection()
  end
end)

-- 自動開始
StartProtection()

-- === ワープ用GUI ===
local warpFrame = Instance.new("Frame")
warpFrame.Size = UDim2.new(0, 240, 0, 120)
warpFrame.Position = UDim2.new(0.5, -120, 0.72, 0)
warpFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
warpFrame.BorderSizePixel = 2
warpFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpFrame.Parent = ScreenGui
warpFrame.Active = true
warpFrame.Draggable = true

local bgText = Instance.new("TextLabel")
bgText.Size = UDim2.new(2, 0, 1, 0)
bgText.Position = UDim2.new(0, 0, 0, 0)
bgText.BackgroundTransparency = 1
bgText.Text = "daxhab / dax   daxhab / dax   daxhab / dax   daxhab / dax   daxhab / dax"
bgText.TextColor3 = Color3.fromRGB(0, 255, 0)
bgText.Font = Enum.Font.Code
bgText.TextScaled = true
bgText.TextTransparency = 0.85
bgText.ZIndex = 0
bgText.Parent = warpFrame

local warpBtn = Instance.new("TextButton")
warpBtn.Size = UDim2.new(0.8, 0, 0, 50)
warpBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
warpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
warpBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
warpBtn.Font = Enum.Font.Code
warpBtn.TextScaled = true
warpBtn.Text = "ワープ"
warpBtn.ZIndex = 1
warpBtn.Parent = warpFrame

spawn(function()
  local offset = 0
  while true do
    offset = offset - 2
    bgText.Position = UDim2.new(0, offset, 0, 0)
    if offset <= -bgText.AbsoluteSize.X / 2 then
      offset = 0
    end
    wait(0.03)
  end
end)

-- ワープ成功率99%模擬＆滑らかワープ
local function WarpUp()
  if not hrp or not char then return end

  if math.random(1,100) == 1 then
    return -- 1%失敗
  end

  local currentPos = hrp.Position
  local warpHeight = 60 -- 10人分高さ
  local targetPos = currentPos + Vector3.new(0, warpHeight, 0)

  for attempt = 1, 3 do
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    local dist = (hrp.Position - targetPos).Magnitude
    if dist < 3 then break end
    wait(0.05)
  end
end

warpBtn.MouseButton1Click:Connect(WarpUp)

print("✅ daxhab 超強力サーバー級ワープ対策スクリプト 完全版 強化版 起動完了 by dax")
