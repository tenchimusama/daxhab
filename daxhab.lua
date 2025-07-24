-- 無敵95%強化版：リセット回避・監視回避・ワープ強化スクリプト

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "GameUI"

-- UI背景
local background = Instance.new("Frame")
background.Parent = screenGui
background.Size = UDim2.new(0, 200, 0, 50)
background.Position = UDim2.new(0.5, -100, 0.5, -25)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0

-- タイトルテキスト
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = background
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "daxhab / 作者: dax"
titleLabel.TextSize = 12
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.Gotham

-- ワープボタン
local buttonWarp = Instance.new("TextButton")
buttonWarp.Parent = background
buttonWarp.Size = UDim2.new(1, 0, 0.7, 0)
buttonWarp.Position = UDim2.new(0, 0, 0.3, 0)
buttonWarp.Text = "ワープ"
buttonWarp.TextSize = 14
buttonWarp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonWarp.TextColor3 = Color3.fromRGB(0, 255, 255)
buttonWarp.BorderSizePixel = 0
buttonWarp.Font = Enum.Font.SourceSans

-- リセット回避ボタン
local buttonResetAvoid = Instance.new("TextButton")
buttonResetAvoid.Parent = background
buttonResetAvoid.Size = UDim2.new(1, 0, 0.7, 0)
buttonResetAvoid.Position = UDim2.new(0, 0, 1, 0)
buttonResetAvoid.Text = "リセット回避: オフ"
buttonResetAvoid.TextSize = 14
buttonResetAvoid.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
buttonResetAvoid.TextColor3 = Color3.fromRGB(255, 0, 255)
buttonResetAvoid.BorderSizePixel = 0
buttonResetAvoid.Font = Enum.Font.SourceSans

-- リセット回避機能
local resetAvoidEnabled = false
local function toggleResetAvoidance()
    resetAvoidEnabled = not resetAvoidEnabled
    if resetAvoidEnabled then
        buttonResetAvoid.Text = "リセット回避: オン"
    else
        buttonResetAvoid.Text = "リセット回避: オフ"
    end
end

local function resetAvoidance()
    if resetAvoidEnabled then
        local lastPosition = humanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                local currentPosition = humanoidRootPart.Position
                -- 微調整で不規則な位置変更
                if (currentPosition - lastPosition).Magnitude < 0.1 then
                    local newPosition = currentPosition + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
                    character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
                end
                lastPosition = currentPosition
            end
        end)
    end
end

-- 高速ワープ機能（ランダム間隔追加）
local warpHeight = 6.5 * character.Humanoid.HipWidth
local function teleportPlayer()
    local currentPosition = humanoidRootPart.Position
    local targetPosition = Vector3.new(currentPosition.X, currentPosition.Y + warpHeight, currentPosition.Z)
    
    -- 高速ワープ
    while (currentPosition - targetPosition).Magnitude > 0.1 do
        -- ランダムタイミングでワープ
        if math.random() < 0.95 then
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
        currentPosition = humanoidRootPart.Position
        wait(math.random(0.05, 0.1))  -- ワープタイミングのランダム化
    end

    print("ワープ成功！")
end

-- ワープボタンのクリック処理
buttonWarp.MouseButton1Click:Connect(function()
    teleportPlayer()  -- ワープ実行
end)

buttonResetAvoid.MouseButton1Click:Connect(function()
    toggleResetAvoidance()  -- リセット回避のオン/オフ切り替え
end)

-- リセット回避を実行
resetAvoidance()

-- サーバー監視回避強化
game:GetService("RunService").Heartbeat:Connect(function()
    -- サーバー監視回避処理
    local currentPosition = humanoidRootPart.Position
    local detectedArea = Vector3.new(500, 500, 500)
    if (currentPosition - detectedArea).Magnitude < 100 then
        local newPos = Vector3.new(math.random(-1000, 1000), currentPosition.Y, math.random(-1000, 1000))
        character:SetPrimaryPartCFrame(CFrame.new(newPos))
    end
end)

-- 絶対にリセットされないための動作強化
local function enhancedResetAvoidance()
    local lastPosition = humanoidRootPart.Position
    game:GetService("RunService").Heartbeat:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPosition = humanoidRootPart.Position
            -- リセットされそうなタイミングで微調整
            if (currentPosition - lastPosition).Magnitude < 0.1 then
                local newPosition = currentPosition + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
                character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
            end
            lastPosition = currentPosition
        end
    end)
end

-- 絶対リセット回避
enhancedResetAvoidance()

-- タップイベントが反応しない場合の改善
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- ワープボタンを強制的にタップイベントに反応させる
            if buttonWarp.Visible and buttonWarp:IsPointInRegion2D(input.Position) then
                teleportPlayer()
            elseif buttonResetAvoid.Visible and buttonResetAvoid:IsPointInRegion2D(input.Position) then
                toggleResetAvoidance()
            end
        end
    end
end)
