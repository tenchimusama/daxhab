local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- ScreenGuiを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景ラベル（daxhab, 作成者:dax）
local background = Instance.new("TextLabel")
background.Size = UDim2.new(0, 150, 0, 40) -- 画面の7分の1の大きさ
background.Position = UDim2.new(0.5, -75, 0.05, 0) -- 上部中央に配置
background.BackgroundColor3 = Color3.new(0, 0, 0) -- 背景を黒に
background.BackgroundTransparency = 0.85
background.Text = "daxhab\n作成者: dax"
background.Font = Enum.Font.Code
background.TextColor3 = Color3.fromRGB(0, 255, 0)
background.TextSize = 14
background.TextWrapped = true
background.TextYAlignment = Enum.TextYAlignment.Top
background.Parent = screenGui

-- ワープボタン作成
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, 150, 0, 40) -- 画面の7分の1の大きさ
warpButton.Position = UDim2.new(0.5, -75, 0.8, 0) -- 真ん中に配置
warpButton.BackgroundColor3 = Color3.new(0, 0, 0)
warpButton.BackgroundTransparency = 0.3
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.Code
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextSize = 18
warpButton.BorderSizePixel = 1
warpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Parent = screenGui

-- ドラッグ機能
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    background.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    warpButton.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y + 60) -- ボタンも追従
end

background.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = background.Position
        input.Changed:Connect(function()
            if not input.UserInputState == Enum.UserInputState.End then return end
            dragging = false
        end)
    end
end)

background.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- ワープ処理（オブジェクト貫通）
warpButton.MouseButton1Click:Connect(function()
    local originPos = hrp.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    -- ワープ先を天井貫通させる
    local raycastResult = workspace:Raycast(originPos, Vector3.new(0, 5000, 0), raycastParams)
    local targetY = raycastResult and raycastResult.Position.Y - 5 or originPos.Y + 5000
    local targetPos = CFrame.new(originPos.X, targetY, originPos.Z)
    
    -- ワープ後、戻されないようにCFrameを直接設定
    hrp.CFrame = targetPos

    -- 一瞬でワープしても問題がないように
    wait(0.1)  -- 少し待機してから強制的に位置をセット

    -- 武器やオブジェクトを保持したままにする
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- 武器があれば確認（Toolを確認）
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                -- Toolが保持されている場合、親を設定し直す
                tool.Parent = character
            end
        end
    end

    -- オブジェクト貫通させるために、ワープ中に一時的に「CanCollide」プロパティを変更して貫通を可能にする
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- 少しの間だけ貫通状態にしてから、元に戻す
    wait(0.2)

    -- 再度、コリジョンを戻す
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end)
