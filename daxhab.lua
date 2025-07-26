--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PlaceID = game.PlaceId

StarterGui:SetCore("ResetButtonCallback", false)
player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- UI初期化
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DaxhabUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.4,0,0.5,0)
mainFrame.Position = UDim2.new(0.3,0,0.45,0)
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
        -- 画面外に出さない処理
        local x,y = mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y
        local w,h = mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y
        local screenW, screenH = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
        if x < 0 then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, 0, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset) end
        if y < 0 then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, 0) end
        if x + w > screenW then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, screenW - w, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset) end
        if y + h > screenH then mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, screenH - h) end
    end
end)

-- ロゴ: daxhab 虹色点字風
local logoText = "daxhab"
local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1,0,0.15,0)
logoHolder.Position = UDim2.new(0,0,0,0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = mainFrame

local logoLabels = {}
local displayedCount = 0
local lastTick = tick()

for i = 1, #logoText do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 25, 1, 0)
    lbl.Position = UDim2.new(0, 25*(i-1), 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextScaled = true
    lbl.Text = ""
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,255,0)
    lbl.TextColor3 = Color3.fromHSV((i*0.15)%1,1,1)
    lbl.Parent = logoHolder
    table.insert(logoLabels, lbl)
end

-- 点字風に少しずつ文字を表示
RunService.RenderStepped:Connect(function()
    if tick() - lastTick > 0.15 and displayedCount < #logoText then
        displayedCount = displayedCount + 1
        for i=1,displayedCount do
            logoLabels[i].Text = logoText:sub(i,i)
            logoLabels[i].TextColor3 = Color3.fromHSV((tick()*0.4 + i*0.1)%1,1,1)
        end
        lastTick = tick()
    end
end)

-- ログ表示
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -10, 0.5, -10)
logBox.Position = UDim2.new(0, 5, 0.15, 5)
logBox.BackgroundColor3 = Color3.new(0,0,0)
logBox.TextColor3 = Color3.fromRGB(0,255,0)
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

-- スタッド入力欄
local heightInput = Instance.new("TextBox")
heightInput.Size = UDim2.new(0.25, 0, 0.1, 0)
heightInput.Position = UDim2.new(0.7, 0, 0.68, 0)
heightInput.BackgroundColor3 = Color3.fromRGB(20,20,20)
heightInput.TextColor3 = Color3.fromRGB(0,255,0)
heightInput.PlaceholderText = "Warp Height"
heightInput.Text = "40"
heightInput.TextScaled = true
heightInput.Font = Enum.Font.Code
heightInput.ClearTextOnFocus = false
heightInput.Parent = mainFrame

local currentHeight = Instance.new("TextLabel")
currentHeight.Size = UDim2.new(0.25,0,0.1,0)
currentHeight.Position = UDim2.new(0.7,0,0.78,0)
currentHeight.BackgroundTransparency = 1
currentHeight.TextColor3 = Color3.fromRGB(0,255,0)
currentHeight.Font = Enum.Font.Code
currentHeight.TextScaled = true
currentHeight.Text = "Height: 40"
currentHeight.Parent = mainFrame

heightInput:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(heightInput.Text)
    if val then
        currentHeight.Text = "Height: "..val
    else
        currentHeight.Text = "Height: ?"
    end
end)

-- キャラ選択用ドロップダウン
local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Size = UDim2.new(0.5, 0, 0.08, 0)
dropdownLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.TextColor3 = Color3.fromRGB(0,255,0)
dropdownLabel.Font = Enum.Font.Code
dropdownLabel.TextScaled = false
dropdownLabel.TextSize = 16
dropdownLabel.Text = "Select Character"
dropdownLabel.Parent = mainFrame

local dropdownBox = Instance.new("TextBox")
dropdownBox.Size = UDim2.new(0.5,0,0.1,0)
dropdownBox.Position = UDim2.new(0.05,0,0.63,0)
dropdownBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
dropdownBox.TextColor3 = Color3.fromRGB(0,255,0)
dropdownBox.Text = ""
dropdownBox.PlaceholderText = "Type character name..."
dropdownBox.Font = Enum.Font.Code
dropdownBox.TextScaled = true
dropdownBox.ClearTextOnFocus = false
dropdownBox.Parent = mainFrame

-- キャラリスト
local charList = {
    "Las Vaquitas Saturnitas",
    "Garama and Madundung",
    "LA GRANDE COMBINASION",
}

local currentSelected = ""

dropdownBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = dropdownBox.Text
        for _, name in pairs(charList) do
            if string.lower(name) == string.lower(text) then
                currentSelected = name
                addLog("Selected character: "..name)
                return
            end
        end
        addLog("Character not found")
    end
end)

-- 捜索＆停止ボタン
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.25, 0, 0.1, 0)
startButton.Position = UDim2.new(0.05, 0, 0.85, 0)
startButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
startButton.TextColor3 = Color3.fromRGB(0,255,0)
startButton.Font = Enum.Font.Code
startButton.TextScaled = false
startButton.TextSize = 16
startButton.Text = "Search"
startButton.Parent = mainFrame

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.25, 0, 0.1, 0)
stopButton.Position = UDim2.new(0.32, 0, 0.85, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
stopButton.TextColor3 = Color3.fromRGB(255, 0, 0)
stopButton.Font = Enum.Font.Code
stopButton.TextScaled = false
stopButton.TextSize = 16
stopButton.Text = "Stop"
stopButton.Parent = mainFrame

local warpButton = Instance.new("TextButton")
warpButton.Size = UDim2.new(0.38, 0, 0.1, 0)
warpButton.Position = UDim2.new(0.6, 0, 0.85, 0)
warpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
warpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
warpButton.Font = Enum.Font.Code
warpButton.TextScaled = true
warpButton.Text = "Warp"
warpButton.Parent = mainFrame

-- リセット防止強化用
local resetBypassEnabled = true
local exploring = false

-- 透明化処理
local function setTransparency(character, transparency)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = transparency
            part.CanCollide = not (transparency > 0)
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                handle.Transparency = transparency
                handle.CanCollide = not (transparency > 0)
            end
        end
    end
end

-- 持ち物透明化
local function setHeldObjectsTransparency(player, transparency)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in ipairs(tool:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = transparency
                    part.CanCollide = not (transparency > 0)
                end
            end
        end
    end
    -- 装備中のツールも透明化
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local equippedTool = humanoid:FindFirstChildOfClass("Tool")
        if equippedTool then
            for _, part in ipairs(equippedTool:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = transparency
                    part.CanCollide = not (transparency > 0)
                end
            end
        end
    end
end

local function enableInvisible()
    local char = player.Character
    if not char then return end
    setTransparency(char, 1)
    setHeldObjectsTransparency(player, 1)
    addLog("Invisible mode enabled")
end

local function disableInvisible()
    local char = player.Character
    if not char then return end
    setTransparency(char, 0)
    setHeldObjectsTransparency(player, 0)
    addLog("Invisible mode disabled")
end

local invisibleEnabled = false

local invisibleButton = Instance.new("TextButton")
invisibleButton.Size = UDim2.new(0.38, 0, 0.1, 0)
invisibleButton.Position = UDim2.new(0.6, 0, 0.72, 0)
invisibleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
invisibleButton.TextColor3 = Color3.fromRGB(255,255,255)
invisibleButton.Font = Enum.Font.Code
invisibleButton.TextScaled = true
invisibleButton.Text = "Invisible: OFF"
invisibleButton.Parent = mainFrame

invisibleButton.MouseButton1Click:Connect(function()
    if invisibleEnabled then
        disableInvisible()
        invisibleEnabled = false
        invisibleButton.Text = "Invisible: OFF"
        invisibleButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
    else
        enableInvisible()
        invisibleEnabled = true
        invisibleButton.Text = "Invisible: ON"
        invisibleButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

-- ワープ関数（座標変更）
local function safeWarp(height)
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        addLog("HumanoidRootPart not found")
        return
    end

    -- 高さ取得
    local h = tonumber(height) or 40

    -- ワープ先は真上にhスタッド
    local targetPos = root.Position + Vector3.new(0, h, 0)

    -- 移動
    root.CFrame = CFrame.new(targetPos)

    addLog("Warped ↑ "..tostring(h).." studs")

    -- ネットワーク所有権取得
    pcall(function()
        root:SetNetworkOwner(player)
    end)

    -- リセット防止用に反復的に位置を補正
    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 10 then
            conn:Disconnect()
            return
        end
        if root and root.Parent then
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            root.CFrame = CFrame.new(targetPos)
            pcall(function()
                root:SetNetworkOwner(player)
            end)
        else
            conn:Disconnect()
        end
    end)
end

-- サーバー巡回処理
local exploring = false
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url.."&cursor="..cursor
    end
    local success, res = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success and res then
        local data = HttpService:JSONDecode(res)
        return data
    end
    return nil
end

local searchThread = nil

local function findAndTeleportServer(targetName)
    if exploring then return end
    exploring = true
    addLog("Search started for: "..targetName)
    local cursor = nil
    local maxPages = 15
    local page = 0

    while exploring and page < maxPages do
        local servers = getServers(cursor)
        if not servers then
            addLog("Failed to get server data")
            break
        end
        for _, server in ipairs(servers.data) do
            if not exploring then break end
            if server.playing and server.playing > 0 then
                -- サーバー内のプレイヤーを取得
                local serverPlayersUrl = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/"..server.id.."/players"
                local ok, response = pcall(function()
                    return HttpService:GetAsync(serverPlayersUrl)
                end)
                if ok and response then
                    local playersData = HttpService:JSONDecode(response)
                    for _, pInfo in ipairs(playersData.data) do
                        if string.find(string.lower(pInfo.user.username), string.lower(targetName)) then
                            addLog("Found target "..pInfo.user.username.." in server "..server.id)
                            exploring = false
                            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, player)
                            return
                        end
                    end
                end
            end
        end
        if not exploring then break end
        cursor = servers.nextPageCursor
        if not cursor then
            addLog("No more servers")
            break
        end
        page += 1
        wait(2)
    end
    addLog("Target not found in servers")
    exploring = false
end

startButton.MouseButton1Click:Connect(function()
    if currentSelected == "" then
        addLog("Select a character first")
        return
    end
    if exploring then
        addLog("Already searching")
        return
    end
    searchThread = coroutine.create(function()
        findAndTeleportServer(currentSelected)
    end)
    coroutine.resume(searchThread)
end)

stopButton.MouseButton1Click:Connect(function()
    if exploring then
        exploring = false
        addLog("Search stopped")
    else
        addLog("Not searching")
    end
end)

warpButton.MouseButton1Click:Connect(function()
    local val = tonumber(heightInput.Text)
    if not val then
        addLog("Invalid height input")
        return
    end
    safeWarp(val)
end)

-- 初期化
addLog("UI Ready. Created by dax")

-- デフォルト透明化OFF
invisibleEnabled = false

