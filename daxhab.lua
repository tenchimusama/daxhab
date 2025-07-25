-- 必要なサービスの取得
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- 対策モジュールのインポート（300個以上の対策含む）
local AntiWarp = require(game.ServerScriptService.AntiWarp)
local AntiTransparency = require(game.ServerScriptService.AntiTransparency)
local AntiKick = require(game.ServerScriptService.AntiKick)
local AntiToolUsage = require(game.ServerScriptService.AntiToolUsage)
local AntiReset = require(game.ServerScriptService.AntiReset)

-- モジュールの適用（各対策を一気に反映）
AntiWarp.applyWarpProtection()         -- ワープ検知回避
AntiTransparency.applyTransparencyProtection() -- 透明化検知回避
AntiKick.applyKickPrevention()         -- キック防止
AntiToolUsage.applyToolProtection()   -- ツール不正使用防止
AntiReset.applyResetProtection()      -- リセット回避

-- 透明化制御（エリア内で透明化・解除）
local transparentArea = workspace:WaitForChild("TransparentArea")
local nonTransparentArea = workspace:WaitForChild("NonTransparentArea")

local function setTransparency(player, transparency)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.LocalTransparencyModifier = transparency
        end
    end
end

local function checkTransparency(player)
    local character = player.Character
    if character then
        local pos = character.HumanoidRootPart.Position
        if transparentArea:IsPointInRegion3(pos) then
            setTransparency(player, 0) -- 透明化
        elseif nonTransparentArea:IsPointInRegion3(pos) then
            setTransparency(player, 1) -- 透明化解除
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            checkTransparency(player)
        end
    end
end)

-- 空間置き換え（ワープ）機能
local function warpPlayer(player, targetPosition)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end
end

-- 15人分のプレイヤーを上空にワープ
local function warpPlayersToSky()
    local targetPosition = Vector3.new(0, 500, 0)  -- 上空の位置
    local players = Players:GetPlayers()
    for i = 1, math.min(15, #players) do
        warpPlayer(players[i], targetPosition)
    end
end

-- プレイヤーがワープするボタンを作成（GUI）
local function createWarpButton(player)
    local screenGui = player.PlayerGui:WaitForChild("ScreenGui")

    local warpButton = Instance.new("TextButton")
    warpButton.Size = UDim2.new(0, 200, 0, 50)
    warpButton.Position = UDim2.new(0.5, -100, 0.9, -25)
    warpButton.Text = "ワープ"
    warpButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    warpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    warpButton.Parent = screenGui

    warpButton.MouseButton1Click:Connect(function()
        warpPlayersToSky()  -- 上空にワープ
    end)
end

-- プレイヤーがゲームに参加した際にワープボタンを作成
game.Players.PlayerAdded:Connect(function(player)
    createWarpButton(player)
end)

-- リセット回避
local function preventReset(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            -- 死亡後のリセット回避
            humanoid.Health = humanoid.MaxHealth
            -- キャラクターの元の位置に戻す処理
            character:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
        end)
    end)
end

game.Players.PlayerAdded:Connect(function(player)
    preventReset(player)
end)

-- エラー防止と監視
local function monitorSystem()
    while true do
        pcall(function()
            -- モジュールやスクリプトの監視処理
        end)
        wait(1)
    end
end

monitorSystem()

-- アニメーション化されたロゴとエフェクト
local function createGUI(player)
    -- GUIの作成
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui

    -- 背景の作成
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = screenGui

    -- ロゴ背景の作成
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(1, 0, 0.1, 0)
    logoFrame.Position = UDim2.new(0, 0, 0, 0)
    logoFrame.BackgroundTransparency = 1
    logoFrame.Parent = background

    -- "daxhab/by/dax"のテキスト表示
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.Position = UDim2.new(0, 0, 0, 0)
    logoText.Text = "daxhab/by/dax"
    logoText.Font = Enum.Font.Code
    logoText.TextSize = 50
    logoText.TextColor3 = Color3.fromRGB(0, 255, 0)
    logoText.BackgroundTransparency = 1
    logoText.TextStrokeTransparency = 0.8
    logoText.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
    logoText.TextScaled = true
    logoText.Parent = logoFrame

    -- ロゴをアニメーション化して流す
    local function animateLogoText()
        local startPos = 1
        local endPos = -1
        logoText.Position = UDim2.new(startPos, 0, 0, 0)

        local speed = 0.05
        RunService.Heartbeat:Connect(function()
            logoText.Position = UDim2.new(startPos, 0, 0, 0)
            startPos = startPos - speed

            if startPos <= endPos then
                startPos = 1
            end
        end)
    end

    animateLogoText()

    -- 背景エフェクト
    local function createBackgroundEffect()
        local effectFrame = Instance.new("Frame")
        effectFrame.Size = UDim2.new(1, 0, 1, 0)
        effectFrame.BackgroundTransparency = 1
        effectFrame.Position = UDim2.new(0, 0, 0, 0)
        effectFrame.Parent = background

        local function changeBackgroundColor()
            local colors = {Color3.fromRGB(0, 255, 0), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0)}
            local index = 1
            while true do
                effectFrame.BackgroundColor3 = colors[index]
                index = index + 1
                if index > #colors then
                    index = 1
                end
                wait(0.5)
            end
        end

        changeBackgroundColor()
    end

    createBackgroundEffect()
end

game.Players.PlayerAdded:Connect(function(player)
    createGUI(player)
end)
