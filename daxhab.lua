-- プレイヤー情報取得
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- スクリーンGUIの作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WarpGui_daxhab"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景（ボタンと統一デザイン）
local background = Instance.new("TextLabel")
background.Size = UDim2.new(0, 180, 0, 50) -- 画面の7分の1に設定
background.Position = UDim2.new(0.5, -90, 0.85, 0) -- 中央配置
background.BackgroundColor3 = Color3.new(0, 0, 0) -- 黒背景
background.BackgroundTransparency = 0.7
background.Text = "daxhab\n作成者: dax"
background.Font = Enum.Font.Code
background.TextColor3 = Color3.fromRGB(0, 255, 0) -- 緑色のテキスト
background.TextSize = 28
background.TextWrapped = true
background.TextYAlignment = Enum.TextYAlignment.Center
background.TextXAlignment = Enum.TextXAlignment.Center
background.Parent = screenGui

-- ワープボタン
local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0, 180, 0, 50)
warpButton.Position = UDim2.new(0.5, -90, 0.85, 0) -- 中央に配置
warpButton.BackgroundColor3 = Color3.new(0, 0, 0)
warpButton.BackgroundTransparency = 0.3
warpButton.Text = "ワープ"
warpButton.Font = Enum.Font.Code
warpButton.TextColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextSize = 30
warpButton.BorderSizePixel = 1
warpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
warpButton.Parent = screenGui

-- ワープの処理
warpButton.MouseButton1Click:Connect(function()
    local originPos = hrp.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character} -- 自キャラを除外
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    -- 天井を貫通するためにRaycastを上方向に飛ばす
    local raycastResult = workspace:Raycast(originPos, Vector3.new(0, 5000, 0), raycastParams)
    local targetY = raycastResult and raycastResult.Position.Y - 5 or originPos.Y + 5000

    -- ワープ処理：障害物を完全に無視して貫通
    hrp.CFrame = CFrame.new(originPos.X, targetY, originPos.Z)

    -- 瞬時にワープ処理（障害物や天井を貫通）
    wait(0.1)
    hrp.CFrame = CFrame.new(originPos.X, targetY, originPos.Z)
end)

-- オブジェクトを長押しで持つ
local holding = false
local heldObject = nil
local holdDistance = 5 -- オブジェクトとの距離

mouse.Button1Down:Connect(function()
    if mouse.Target and mouse.Target:IsA("BasePart") then
        heldObject = mouse.Target
        holding = true
    end
end)

-- オブジェクトを離す
mouse.Button1Up:Connect(function()
    holding = false
    heldObject = nil
end)

-- オブジェクトを移動する処理
game:GetService("RunService").RenderStepped:Connect(function()
    if holding and heldObject then
        local mousePos = mouse.Hit.p
        -- 持ち上げているオブジェクトをマウスの位置に合わせて移動
        local newPos = mousePos + (mousePos - heldObject.Position).unit * holdDistance
        heldObject.CFrame = CFrame.new(newPos)
    end
end)

-- ドラッグ機能
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    screenGui.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
end

warpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = screenGui.Position
        input.Changed:Connect(function()
            if dragging then
                updateDrag(input)
            end
        end)
    end
end)

warpButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
