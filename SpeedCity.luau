local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer.PlayerGui


local function safeFind(root, pathParts)
    local cur = root
    for i = 1, #pathParts do
        if not cur then return nil end
        cur = cur:FindFirstChild(pathParts[i])
    end
    return cur
end

local function createInstance(class, properties)
    local obj = Instance.new(class)
    if properties then
        for k, v in pairs(properties) do
            if k == "Parent" then
                obj.Parent = v
            else
                local ok, _ = pcall(function() obj[k] = v end)
            end
        end
    end
    return obj
end

local function getHRP(timeout)
    timeout = timeout or 2
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    return char:WaitForChild("HumanoidRootPart", timeout)
end


local FarmFlags = {}      -- name -> boolean
local FarmRunners = {}    -- name -> thread (task)

local function startFarm(name, getPositionFunc)
    FarmFlags[name] = true
    if FarmRunners[name] then return end
    FarmRunners[name] = task.spawn(function()
        while FarmFlags[name] do
            local ok, pos = pcall(getPositionFunc)
            if ok and pos then
                local hrp = getHRP()
                if hrp then
                    pcall(function()
                        hrp.CFrame = CFrame.new(pos)
                    end)
                end
            end
            task.wait(0.45)
        end
        FarmRunners[name] = nil
    end)
end

local function stopFarm(name)
    FarmFlags[name] = false
    FarmRunners[name] = nil
end

local function stopAllFarms()
    for k in pairs(FarmFlags) do FarmFlags[k] = false end
    FarmRunners = {}
end


local UI = {}
do
    local screenGui = createInstance("ScreenGui", {Parent = PlayerGui, Name = "SpeedCity", ResetOnSpawn = false})
    UI.screenGui = screenGui

    local mainFrame = createInstance("Frame", {Parent = screenGui, Size = UDim2.new(0, 560, 0, 440), Position = UDim2.new(1, -580, 1, -460), BackgroundColor3 = Color3.fromRGB(24,24,24), BorderSizePixel = 0, Active = true, Draggable = true})
    createInstance("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0,8)})
    UI.mainFrame = mainFrame

    createInstance("TextLabel", {Parent = mainFrame, Size = UDim2.new(1,0,0,36), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(30,30,30), Text = "Speed City", TextColor3 = Color3.fromRGB(230,230,230), Font = Enum.Font.GothamBold, TextSize = 20})

    local tabsFrame = createInstance("Frame", {Parent = mainFrame, Size = UDim2.new(0,160,1,-36), Position = UDim2.new(0,0,0,36), BackgroundColor3 = Color3.fromRGB(28,28,28)})
    createInstance("UICorner", {Parent = tabsFrame, CornerRadius = UDim.new(0,6)})
    local contentFrame = createInstance("Frame", {Parent = mainFrame, Size = UDim2.new(1,-170,1,-46), Position = UDim2.new(0,170,0,40), BackgroundColor3 = Color3.fromRGB(20,20,20)})
    createInstance("UICorner", {Parent = contentFrame, CornerRadius = UDim.new(0,6)})

    UI.tabs = {}
    UI.pages = {}


    local tabNames = {"Farms", "TradeTools", "TradeSpy", "InventoryViewer", "Crates", "Maps"}
    for i = 1, #tabNames do
        local name = tabNames[i]
        local btn = createInstance("TextButton", {Parent = tabsFrame, Size = UDim2.new(1, -12, 0, 40), Position = UDim2.new(0,6,0,8 + (i-1)*46), BackgroundColor3 = Color3.fromRGB(35,35,35), Text = name, TextColor3 = Color3.fromRGB(230,230,230), Font = Enum.Font.Gotham, TextSize = 14})
        createInstance("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
        UI.tabs[name] = btn

        local page = createInstance("ScrollingFrame", {Parent = contentFrame, Size = UDim2.new(1,-10,1,-10), Position = UDim2.new(0,5,0,5), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y})
        createInstance("UIListLayout", {Parent = page}).Padding = UDim.new(0,8)
        page.Visible = false
        UI.pages[name] = page

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(UI.pages) do
                p.Visible = false
            end
            for _, b in pairs(UI.tabs) do
                b.BackgroundColor3 = Color3.fromRGB(35,35,35)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        end)
    end

    UI.tabs["Farms"].BackgroundColor3 = Color3.fromRGB(60,60,60)
    UI.pages["Farms"].Visible = true
end


local function addLabel(parent, text)
    return createInstance("TextLabel", {Parent = parent, Size = UDim2.new(1,-10,0,20), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
end

local function addButton(parent, text, callback)
    local btn = createInstance("TextButton", {Parent = parent, Size = UDim2.new(1,-10,0,34), BackgroundColor3 = Color3.fromRGB(70,70,70), Text = text, TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.Gotham, TextSize = 14})
    createInstance("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function addToggle(parent, text, callback)
    local frame = createInstance("Frame", {Parent = parent, Size = UDim2.new(1,-10,0,34), BackgroundColor3 = Color3.fromRGB(40,40,40)})
    createInstance("UICorner", {Parent = frame, CornerRadius = UDim.new(0,6)})
    createInstance("TextLabel", {Parent = frame, Text = text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,6,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(230,230,230), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    local btn = createInstance("TextButton", {Parent = frame, Size = UDim2.new(0,48,0,22), Position = UDim2.new(1,-56,0,6), Text = "OFF", BackgroundColor3 = Color3.fromRGB(90,90,90), TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.Gotham, TextSize = 12})
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(80,170,80) or Color3.fromRGB(90,90,90)
        pcall(callback, state)
    end)
    return frame, function(s)
        state = s and true or false
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(80,170,80) or Color3.fromRGB(90,90,90)
        pcall(callback, state)
    end
end


do
    local page = UI.pages["Farms"]
    addLabel(page, " ")

    local function makeGhostToggle(name, pathParts, accessorName)
        addToggle(page, name, function(enabled)
            if enabled then
                startFarm(name, function()
                    local obj = safeFind(Workspace, pathParts)
                    if obj then
                        local node = obj:FindFirstChild(accessorName) or obj:FindFirstChild("Outside") or obj
                        if node and node.Position then return node.Position end
                    end
                    return nil
                end)
            else
                stopFarm(name)
            end
        end)
    end

    makeGhostToggle("White Orbs", {"GhostCity","GhostOrbsMega","GhostMega"}, "Outside")
    makeGhostToggle("Black Orbs", {"GhostCity","GhostOrbsMega","GhostMega2"}, "Outside")
    makeGhostToggle("Happy Ghost", {"GhostCity","GhostOrbsMega","Happy"}, "Crate")
    makeGhostToggle("King Ghost", {"GhostCity","GhostOrbsMega","King Ghost"}, "Crate")
    makeGhostToggle("Sad Ghost", {"GhostCity","GhostOrbsMega","Sad"}, "Crate")
    makeGhostToggle("Angry Ghost", {"GhostCity","GhostOrbsMega","Angry"}, "Crate")
    makeGhostToggle("Scared Ghost", {"GhostCity","GhostOrbsMega","Scared"}, "Crate")
    makeGhostToggle("Surprised Ghost", {"GhostCity","GhostOrbsMega","Surprised"}, "Crate")
    makeGhostToggle("Zombie Ghost", {"GhostCity","GhostOrbsMega","Zombie Ghost"}, "Crate")

   
    local function findTrillionPos()
        local t = safeFind(Workspace, {"TrillionaireCity","TrillionaireOrbs","Trillionaire"})
        if not t then t = safeFind(Workspace, {"TrillionaireCity","TrillionaireOrbs"}) end
        if t then
            local out = t:FindFirstChild("Outside") or t
            if out and out.Position then return out.Position end
        end
        return nil
    end

    addToggle(page, "Trillionaire orbs", function(enabled)
        if enabled then
            startFarm("Trillionaire orbs", findTrillionPos)
        else
            stopFarm("Trillionaire orbs")
        end
    end)
end


do
    local page = UI.pages["TradeTools"]
    addLabel(page, " ")

    local inputFrame = createInstance("Frame", {Parent = page, Size = UDim2.new(1,-10,0,36), BackgroundColor3 = Color3.fromRGB(40,40,40)})
    createInstance("UICorner", {Parent = inputFrame, CornerRadius = UDim.new(0,6)})
    local textBox = createInstance("TextBox", {Parent = inputFrame, Size = UDim2.new(1,-12,1,-8), Position = UDim2.new(0,6,0,4), BackgroundColor3 = Color3.fromRGB(30,30,30), TextColor3 = Color3.fromRGB(230,230,230), PlaceholderText = "Enter trail name...", Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false})

    local btnGrid = createInstance("Frame", {Parent = page, Size = UDim2.new(1,-10,0,160), BackgroundTransparency = 1})
    createInstance("UIGridLayout", {Parent = btnGrid, CellSize = UDim2.new(0.48,0,0,40), CellPadding = UDim2.new(0,8,0,8)})

    local function safeFire(eventName, param)
        local ev = ReplicatedStorage:FindFirstChild(eventName)
        if ev and ev.FireServer then
            pcall(function()
                if param ~= nil then
                    ev:FireServer(param)
                else
                    ev:FireServer()
                end
            end)
        end
    end

    addButton(btnGrid, "Offer", function()
        if textBox.Text and textBox.Text ~= "" then safeFire("TradeTrailAdd", textBox.Text) end
    end)
    addButton(btnGrid, "Remove", function()
        if textBox.Text and textBox.Text ~= "" then safeFire("TradeTrailPutBack", textBox.Text) end
    end)
    addButton(btnGrid, "Accept", function() safeFire("TradeMenuAccept") end)
    addButton(btnGrid, "Cancel", function() safeFire("TradeMenuCancel") end)


    addButton(page, "Trade Lock", function()
        local rs = game.ReplicatedStorage
        for i = 1, 100 do
            rs.TradeAccept:FireServer()
            rs.TradeMenuCancel()
            rs.TradeAccept:FireServer()
        end
        textBox.Text = ""
    end)
end


do
    local page = UI.pages["TradeSpy"]
    addLabel(page, " ")

    local container = createInstance("Frame", {Parent = page, Size = UDim2.new(1,-10,0,320), BackgroundTransparency = 1})
    local scroll = createInstance("ScrollingFrame", {Parent = container, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y})
    createInstance("UIListLayout", {Parent = scroll}).Padding = UDim.new(0,6)

    local function createSessionUI(session)
        if not session or not session:IsA("Folder") then return end
        local p1 = session:FindFirstChild("Player1"); local p2 = session:FindFirstChild("Player2")
        local p1Accept = session:FindFirstChild("Player1Accept"); local p2Accept = session:FindFirstChild("Player2Accept")
        local p1Trading = session:FindFirstChild("Player1Trading"); local p2Trading = session:FindFirstChild("Player2Trading")
        if not (p1 and p2 and p1Accept and p2Accept and p1Trading and p2Trading) then return end

        local itemFrame = createInstance("Frame", {Parent = scroll, Size = UDim2.new(1,-10,0,110), BackgroundColor3 = Color3.fromRGB(45,45,45)})
        createInstance("UICorner", {Parent = itemFrame, CornerRadius = UDim.new(0,6)})
        createInstance("TextLabel", {Parent = itemFrame, Size = UDim2.new(1,-10,0,28), Position = UDim2.new(0,5,0,5), BackgroundTransparency = 1, Text = p1.Value .. " ⇄ " .. p2.Value, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(235,235,235)})
        local statusLabel = createInstance("TextLabel", {Parent = itemFrame, Size = UDim2.new(0,90,0,20), Position = UDim2.new(1,-100,0,6), BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = Color3.fromRGB(255,255,255), TextXAlignment = Enum.TextXAlignment.Right})
        local leftLabel = createInstance("TextLabel", {Parent = itemFrame, Size = UDim2.new(0.5,-8,0,64), Position = UDim2.new(0,6,0,36), BackgroundColor3 = Color3.fromRGB(35,35,35), Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(220,220,220), TextXAlignment = Enum.TextXAlignment.Left})
        local rightLabel = createInstance("TextLabel", {Parent = itemFrame, Size = UDim2.new(0.5,-8,0,64), Position = UDim2.new(0.5,2,0,36), BackgroundColor3 = Color3.fromRGB(35,35,35), Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(220,220,220), TextXAlignment = Enum.TextXAlignment.Left})

        local function updateState()
            local acceptedCount = (p1Accept.Value and 1 or 0) + (p2Accept.Value and 1 or 0)
            if acceptedCount == 2 then
                statusLabel.Text = "ACCEPTED"
                statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
                task.delay(2.5, function()
                    if itemFrame and itemFrame.Parent then itemFrame:Destroy() end
                end)
            else
                statusLabel.Text = tostring(acceptedCount) .. "/2"
                statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end

        local function updateTrading()
            local items1 = {}
            for _, it in ipairs(p1Trading:GetChildren()) do table.insert(items1, it.Name) end
            leftLabel.Text = table.concat(items1, "\n")
            local items2 = {}
            for _, it in ipairs(p2Trading:GetChildren()) do table.insert(items2, it.Name) end
            rightLabel.Text = table.concat(items2, "\n")
        end

        local c1 = p1Accept:GetPropertyChangedSignal("Value"):Connect(updateState)
        local c2 = p2Accept:GetPropertyChangedSignal("Value"):Connect(updateState)
        local a1 = p1Trading.ChildAdded:Connect(updateTrading); local r1 = p1Trading.ChildRemoved:Connect(updateTrading)
        local a2 = p2Trading.ChildAdded:Connect(updateTrading); local r2 = p2Trading.ChildRemoved:Connect(updateTrading)

        updateState(); updateTrading()

        local anc = session.AncestryChanged:Connect(function(_, parent)
            if not parent then
                local acceptedCount = (p1Accept.Value and 1 or 0) + (p2Accept.Value and 1 or 0)
                if acceptedCount == 2 then
                    statusLabel.Text = "ACCEPTED"
                    statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
                else
                    statusLabel.Text = "CANCELLED"
                    statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
                end
                task.delay(2.5, function()
                    if itemFrame and itemFrame.Parent then itemFrame:Destroy() end
                end)
                anc:Disconnect()
                c1:Disconnect(); c2:Disconnect(); a1:Disconnect(); r1:Disconnect(); a2:Disconnect(); r2:Disconnect()
            end
        end)
    end

    local function attachTradeSessions()
        local folder = Workspace:FindFirstChild("TradeSessions")
        if folder then
            for _, s in ipairs(folder:GetChildren()) do
                pcall(function() createSessionUI(s) end)
            end
            folder.ChildAdded:Connect(function(s) task.wait(0.08); pcall(function() createSessionUI(s) end) end)
        else
            addLabel(page, "TradeSessions не найден — ожидаю появления в Workspace...")
            Workspace.ChildAdded:Connect(function(child)
                if child and child.Name == "TradeSessions" then
                    attachTradeSessions()
                end
            end)
        end
    end

    attachTradeSessions()
end


do
    local page = UI.pages["InventoryViewer"]
    addLabel(page, " ")

    local viewer = createInstance("Frame", {Parent = page, Size = UDim2.new(1,-10,0,260), BackgroundColor3 = Color3.fromRGB(35,35,35)})
    createInstance("UICorner", {Parent = viewer, CornerRadius = UDim.new(0,6)})

    local playersList = createInstance("ScrollingFrame", {Parent = viewer, Size = UDim2.new(0,180,1,-20), Position = UDim2.new(0,10,0,10), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y})
    createInstance("UIListLayout", {Parent = playersList}).Padding = UDim.new(0,4)
    local trailsList = createInstance("ScrollingFrame", {Parent = viewer, Size = UDim2.new(1,-220,1,-20), Position = UDim2.new(0,200,0,10), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y})
    createInstance("UIListLayout", {Parent = trailsList}).Padding = UDim.new(0,4)

    local function renderPlayers()
        for _, c in ipairs(playersList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            local btn = createInstance("TextButton", {Parent = playersList, Size = UDim2.new(1,-8,0,26), Text = pl.Name, BackgroundColor3 = Color3.fromRGB(50,50,50), TextColor3 = Color3.fromRGB(230,230,230), Font = Enum.Font.Gotham, TextSize = 14})
            btn.MouseButton1Click:Connect(function()
                for _, c in ipairs(trailsList:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
                local trails = pl:FindFirstChild("trails")
                if trails then
                    for _, it in ipairs(trails:GetChildren()) do
                        createInstance("TextLabel", {Parent = trailsList, Size = UDim2.new(1,-8,0,20), Text = it.Name, BackgroundColor3 = Color3.fromRGB(45,45,45), TextColor3 = Color3.fromRGB(230,230,230), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                    end
                else
                    createInstance("TextLabel", {Parent = trailsList, Size = UDim2.new(1,-8,0,20), Text = "No trails folder", BackgroundColor3 = Color3.fromRGB(45,45,45), TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.Gotham, TextSize = 13})
                end
            end)
        end
    end

    renderPlayers()
    Players.PlayerAdded:Connect(renderPlayers)
    Players.PlayerRemoving:Connect(renderPlayers)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Z then
            UI.screenGui.Enabled = not UI.screenGui.Enabled
        end
    end)
end


do
    local page = UI.pages["Crates"]
    addLabel(page, " ")

    local crates = {
        "Blue Crate",
        "Purple Crate",
        "Green Crate",
        "Red Crite",
        "Elf Crate",
        "Christmas Crate",
        "Legendary Crate",
        "Dark Crate",
        "Beach Crate",
        "Cloud Crate",
        "Ocean Crate",
        "Best Crate",
        "very op crate",
	    "not free crate",
	    "H4110w33n",
	    "Christmas Present"
    }

    for i, crateName in ipairs(crates) do
        addButton(page, "Buy " .. crateName, function()
            ReplicatedStorage.BuyCrate:FireServer(crateName)
        end)
    end
end


do
    local page = UI.pages["Maps"]
    addLabel(page, " ")

    local teleports = {
        {"Lobby", CFrame.new(0, 75, 0)},
        {"Winter", CFrame.new(-4680, 1799, -2812)},
        {"Original Map", CFrame.new(-2388, 2742, 390)},
        {"Volcano", CFrame.new(-1270, 258, 2022)},
        {"Beach", CFrame.new(-3624, 67, 1018)},
        {"Ghost City", CFrame.new(-3825, -33, 7304)},
        {"Infinite Road", CFrame.new(-22, 1549, -1926)},
        {"Elite City", CFrame.new(1730, 12, 1745)},
        {"Trillioniare City", CFrame.new(1532, 100, 5937)}
    }

    for i, teleport in ipairs(teleports) do
        addButton(page, teleport[1], function()
            local hrp = getHRP()
            if hrp then
                pcall(function()
                    hrp.CFrame = teleport[2]
                end)
            end
        end)
    end
end

do
    local status = createInstance("TextLabel", {Parent = UI.mainFrame, Size = UDim2.new(0,200,0,20), Position = UDim2.new(0,8,1,-28), BackgroundTransparency = 1, Text = "Farms: 0 running", TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.Gotham, TextSize = 12})
    task.spawn(function()
        while true do
            task.wait(0.8)
            local cnt = 0
            for _, v in pairs(FarmFlags) do
                if v then cnt = cnt + 1 end
            end
            pcall(function() status.Text = "Farms: " .. cnt .. " running" end)
        end
    end)
end
