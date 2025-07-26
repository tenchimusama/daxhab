--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- アンチキック＆Idled無効化
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
StarterGui:SetCore("ResetButtonCallback", false)

-- UI構築
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインフレーム（ドラッグ対応）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35,0,0.45,0)
mainFrame.Position = UDim2.new(0.33,0,0.5,0)
mainFrame.BackgroundColor3 = Color3.new(0,0,0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ドラッグ処理
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,startPos.Y.Scale,startPos.Y.Offset + delta.Y)
    end
end)

-- ロゴ（虹色テキストでゆらゆら3D風）
local logoText = "daxhab"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1,0,0.15,0)
logoHolder.Position = UDim2.new(0,0,0,0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}

for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 18, 1, 0)
    lbl.Position = UDim2.new(0, 18*(i-1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = logoText:sub(i,i)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,1,0)
    lbl.TextColor3 = Color3.fromHSV((tick()*0.3 + i*0.07)%1, 1, 1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end

RunService.RenderStepped:Connect(function()
    for i, lbl in ipairs(logoLabels) do
        local offset = math.sin(tick()*8 + i)*6
        lbl.Position = UDim2.new(0, 18*(i-1), 0, offset)
        lbl.TextColor3 = Color3.fromHSV((tick()*0.4 + i*0.07)%1, 1, 1)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- ログ表示（作成者情報もここに）
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -10, 0.5, -10)
logBox.Position = UDim2.new(0, 5, 0.15, 5)
logBox.BackgroundColor3 = Color3.new(0, 0, 0)
logBox.TextColor3 = Color3.fromRGB(0, 255, 0)
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextSize = 14
logBox.TextWrapped = true
logBox.Text = "作成者: dax"
logBox.ClipsDescendants = true
logBox.Parent = mainFrame

local function addLog(text)
    logBox.Text = logBox.Text .. "\n> " .. text
end

-- スタッド入力欄（ワープ高さ）
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.3, 0, 0.12, 0)
heightInput.Position = UDim2.new(0.68, 0, 0.7, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
heightInput.TextColor3 = Color3.fromRGB(0, 255, 0)
heightInput.PlaceholderText = "↑スタッド"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local currentHeight = Instance.new("TextLabel")
currentHeight.Size = UDim2.new(0.3, 0, 0.12, 0)
currentHeight.Position = UDim2.new(0.68, 0, 0.83, 0)
currentHeight.BackgroundTransparency = 1
currentHeight.TextColor3 = Color3.fromRGB(0, 255, 0)
currentHeight.Font = Enum.Font.Code
currentHeight.TextScaled = true
currentHeight.Text = "↑: 40"
currentHeight.Parent = mainFrame

heightInput:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(heightInput.Text)
    if val then
        currentHeight.Text = "↑: "..tostring(val)
    else
        currentHeight.Text = "↑: ?"
    end
end)

-- キャラ選択用ドロップダウン
local characterNames = {
    "Las Vaquitas Saturnitas",
    "Garama and Madundung",
    "La Grande Combinasion",
}

local selectedCharacter = nil
local exploring = false

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0.6, 0, 0.1, 0)
dropdownFrame.Position = UDim2.new(0.05, 0, 0.55, 0)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Parent = mainFrame

local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Size = UDim2.new(1, 0, 1, 0)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
dropdownLabel.Font = Enum.Font.Code
dropdownLabel.TextScaled = true
dropdownLabel.Text = "キャラを選択"
dropdownLabel.Parent = dropdownFrame

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Size = UDim2.new(1, 0, 5, 0)
dropdownList.Position = UDim2.new(0, 0, 1, 0)
dropdownList.CanvasSize = UDim2.new(0, 0, 0, #characterNames * 25)
dropdownList.ScrollBarThickness = 5
dropdownList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.Parent = dropdownFrame

local function closeDropdown()
    dropdownList.Visible = false
end

local function openDropdown()
    dropdownList.Visible = true
end

dropdownLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dropdownList.Visible then
            closeDropdown()
        else
            openDropdown()
        end
    end
end)

local function selectCharacter(name)
    selectedCharacter = name
    dropdownLabel.Text = name
    closeDropdown()
    addLog("キャラ選択: "..name)
end

-- キャラ選択ボタン群作成
for i, name in ipairs(characterNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, 25 * (i-1))
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.Code
    btn.TextScaled = true
    btn.Text = name
    btn.Parent = dropdownList
    btn.MouseButton1Click:Connect(function()
        selectCharacter(name)
    end)
end

-- 停止ボタン
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.3, 0, 0.12, 0)
stopButton.Position = UDim2.new(0.68, 0, 0.93, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
stopButton.TextColor3 = Color3.fromRGB(255, 0, 0)
stopButton.Font = Enum.Font.Code
stopButton.TextScaled = true
stopButton.Text = "停止"
stopButton.Parent = mainFrame

stopButton.MouseButton1Click:Connect(function()
    if exploring then
        exploring = false
        addLog("探索停止")
    end
end)

-- 座標変更＆リセット回避用関数
local function setNetworkOwner(part)
    pcall(function()
        part:SetNetworkOwner(player)
    end)
end

local function setCharacterInvisible(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        elseif part:IsA("Accessory") and part.Handle then
            part.Handle.Transparency = 1
            part.Handle.CanCollide = false
        end
    end
end

local function setCharacterVisible(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        elseif part:IsA("Accessory") and part.Handle then
            part.Handle.Transparency = 0
            part.Handle.CanCollide = true
        end
    end
end

local function teleportToPosition(character, position)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = false
        root.Velocity = Vector3.new()
        root.RotVelocity = Vector3.new()
        root.CFrame = CFrame.new(position)
        setNetworkOwner(root)
    end
end

-- サーバー巡回＆探索ロジック
local HttpService = game:GetService("HttpService")

local PlaceID = game.PlaceId
local MAX_SERVER_PAGES = 100

local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url.."&cursor="..cursor
    end
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result then
        return HttpService:JSONDecode(result)
    else
        return nil
    end
end

local function findAndTeleportServer(targetName)
    addLog("サーバー巡回開始: "..targetName)
    local cursor = nil
    local page = 1
    while exploring do
        local serverData = getServers(cursor)
        if not serverData then
            addLog("サーバーデータ取得失敗")
            break
        end
        for _, server in ipairs(serverData.data) do
            if server.playing ~= nil and server.playing > 0 then
                local success, joinResult = pcall(function()
                    local serverPlayersUrl = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/"..server.id.."/players"
                    local response = game:HttpGet(serverPlayersUrl)
                    local playersData = HttpService:JSONDecode(response)
                    for _, pInfo in ipairs(playersData.data) do
                        if string.find(string.lower(pInfo.user.username), string.lower(targetName)) then
                            addLog("見つけた: "..pInfo.user.username.." in サーバーID "..server.id)
                            -- 移動実行
                            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, player)
                            return true
                        end
                    end
                    return false
                end)
                if success and joinResult then
                    return true
                end
            end
        end
        cursor = serverData.nextPageCursor
        if not cursor or page > MAX_SERVER_PAGES then
            addLog("指定キャラのいるサーバーが見つかりません")
            break
        end
        page += 1
        wait(2)
    end
    return false
end

-- ワープ（座標変更）関数
local function safeWarp(height)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        addLog("キャラクターの主要パーツが見つかりません")
        return
    end
    if not height or type(height) ~= "number" then
        addLog("無効なスタッド数")
        return
    end

    addLog("座標変更中... (↑"..tostring(height).." stud)")

    -- 透明化＆リセット回避用物理無効化
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 1
        elseif part:IsA("Accessory") and part.Handle then
            part.Handle.CanCollide = false
            part.Handle.Transparency = 1
        end
    end

    -- 高さ指定分だけY座標を上げる
    local targetPosition = root.Position + Vector3.new(0, height, 0)
    teleportToPosition(character, targetPosition)

    -- 連続でネットワーク所有権を設定しつつリセット回避
    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 10 then
            conn:Disconnect()
            -- 透過解除などはしないので完全透明維持
            return
        end
        if root and root.Parent then
            root.Velocity = Vector3.new()
            root.RotVelocity = Vector3.new()
            root.CFrame = CFrame.new(targetPosition)
            setNetworkOwner(root)
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end

-- 自動探索処理
local function startExploring(targetName)
    if exploring then
        addLog("既に探索中です")
        return
    end
    exploring = true
    addLog("探索開始: "..targetName)

    coroutine.wrap(function()
        -- まず今のサーバーでキャラを探す
        while exploring do
            local found = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local plName = pl.Name
                    if string.find(string.lower(plName), string.lower(targetName)) then
                        addLog("ターゲット発見: "..plName)
                        -- ターゲットの近くにワープ
                        local char = player.Character or player.CharacterAdded:Wait()
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local targetRoot = pl.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                teleportToPosition(char, targetRoot.Position + Vector3.new(0, tonumber(heightInput.Text) or 40, 0))
                            end
                        end
                        found = true
                        break
                    end
                end
            end

            if not found then
                -- サーバー巡回して探す
                local success = findAndTeleportServer(targetName)
                if not success then
                    addLog("探索失敗、再試行します")
                    wait(5)
                else
                    break -- 別サーバーへテレポートしているためここはもう動かない
                end
            end

            wait(3)
        end
    end)()
end

-- 選択時に探索開始
local function onCharacterSelected()
    if selectedCharacter then
        startExploring(selectedCharacter)
    else
        addLog("キャラクターを選択してください")
    end
end

-- キャラ選択から探索開始ボタン（クリックで探索開始）
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.3, 0, 0.12, 0)
startButton.Position = UDim2.new(0.05, 0, 0.7, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
startButton.TextColor3 = Color3.fromRGB(0, 255, 0)
startButton.Font = Enum.Font.Code
startButton.TextScaled = true
startButton.Text = "探索開始"
startButton.Parent = mainFrame

startButton.MouseButton1Click:Connect(function()
    onCharacterSelected()
end)

-- 透明化ボタン（自分と持ち物）
local transparentToggle = Instance.new("TextButton")
transparentToggle.Size = UDim2.new(0.3, 0, 0.12, 0)
transparentToggle.Position = UDim2.new(0.35, 0, 0.7, 0)
transparentToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
transparentToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
transparentToggle.Font = Enum.Font.Code
transparentToggle.TextScaled = true
transparentToggle.Text = "透明化 OFF"
transparentToggle.Parent = mainFrame

local isTransparent = false

local function setTransparencyAll(state)
    local character = player.Character or player.CharacterAdded:Wait()
    if state then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            elseif part:IsA("Accessory") and part.Handle then
                part.Handle.Transparency = 1
                part.Handle.CanCollide = false
            elseif part:IsA("Tool") then
                for _, subpart in ipairs(part:GetChildren()) do
                    if subpart:IsA("BasePart") then
                        subpart.Transparency = 1
                        subpart.CanCollide = false
                    end
                end
            end
        end
        transparentToggle.Text = "透明化 ON"
        addLog("透明化 ON")
    else
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Accessory") and part.Handle then
                part.Handle.Transparency = 0
                part.Handle.CanCollide = true
            elseif part:IsA("Tool") then
                for _, subpart in ipairs(part:GetChildren()) do
                    if subpart:IsA("BasePart") then
                        subpart.Transparency = 0
                        subpart.CanCollide = true
                    end
                end
            end
        end
        transparentToggle.Text = "透明化 OFF"
        addLog("透明化 OFF")
    end
end

transparentToggle.MouseButton1Click:Connect(function()
    isTransparent = not isTransparent
    setTransparencyAll(isTransparent)
end)

-- 起動完了ログ表示
addLog("起動完了: daxhab by dax")

