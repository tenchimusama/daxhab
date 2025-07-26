local Players = game:GetService("Players")

-- RemoteEventをServerStorageなどに作っておくことも可能だが今回はReplicatedStorageに作る例
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local eventName = "DaxShowEvent"
local remoteEvent = ReplicatedStorage:FindFirstChild(eventName)
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = eventName
    remoteEvent.Parent = ReplicatedStorage
end

-- BillboardGUIをキャラの頭に付ける関数
local function attachDaxGuiToCharacter(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- すでに付いてるなら再利用（重複防止）
    if head:FindFirstChild("DaxBillboardGui") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DaxBillboardGui"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 600, 0, 400) -- かなりでかいサイズ
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 1

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "D A X\n出現！"
    textLabel.TextColor3 = Color3.fromRGB(170, 0, 255) -- 紫色
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.Arcade -- ドンッ！ぽいフォントに近いもの
    textLabel.TextScaled = true
    textLabel.RichText = false
    textLabel.TextWrapped = true
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- 発光のエフェクト的に影を作る（単純にストローク強調）
    billboard.Parent = head

    -- 簡単な点滅アニメーション（紫の発光っぽく）
    spawn(function()
        while billboard.Parent do
            for i = 0, 1, 0.05 do
                textLabel.TextColor3 = Color3.fromHSV(0.75, 1, 0.5 + 0.5 * i) -- 紫系で明るさ変化
                wait(0.05)
            end
            for i = 1, 0, -0.05 do
                textLabel.TextColor3 = Color3.fromHSV(0.75, 1, 0.5 + 0.5 * i)
                wait(0.05)
            end
        end
    end)
end

-- イベント受け取り時、全プレイヤーのキャラにGUIを付ける
remoteEvent.OnServerEvent:Connect(function(sender)
    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            attachDaxGuiToCharacter(char)
        end
    end
end)

-- プレイヤーがキャラ生成したとき、DaxBillboardGuiがあれば付けなおし（切断などに備えて）
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        wait(1)
        local head = char:FindFirstChild("Head")
        if head and head:FindFirstChild("DaxBillboardGui") then
            -- 既に付いているGUIはスルー
            return
        end
        -- もし何かトリガーがあればここで付けることもできる
    end)
end)
