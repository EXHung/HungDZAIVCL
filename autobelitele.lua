-- ═══════════════════════════════════════════
-- SCRIPT HOÀN CHỈNH: TELEPORT 2X + HOP SIÊU TỐC + ANTI-DANGEROUS + DEATH + VOID + PING
-- Tích hợp Hop Server không chờ 45s - Tối ưu 100%
-- ═══════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlaceId = game.PlaceId
local CurrentJobId = game.JobId

-- === DANH SÁCH CHEST ===
local chestPositions = {
    Vector3.new(-4826.30, 78.73, 5369.64),
    Vector3.new(-2876.46, 59.34, 1290.68),
    Vector3.new(-2553.73, 257.79, 1515.04),
    Vector3.new(-2596.95, 185.42, 6236.29),
    Vector3.new(-1102.74, 161.29, -5809.35),
    Vector3.new(-1093.39, 161.29, -5811.00),
    Vector3.new(-1130.81, 161.29, -5804.40),
    Vector3.new(-1121.45, 161.29, -5806.05),
    Vector3.new(-1112.10, 161.29, -5807.70),
    Vector3.new(-1084.03, 161.29, -5812.65),
    Vector3.new(-1074.67, 161.29, -5814.30),
    Vector3.new(-1053.42, 161.29, -5768.35),
    Vector3.new(-1060.02, 161.29, -5805.77),
    Vector3.new(-1058.37, 161.29, -5796.41),
    Vector3.new(-1056.72, 161.29, -5787.06),
    Vector3.new(-1055.07, 161.29, -5777.70),
    Vector3.new(-1074.29, 61.72, -1504.54),
    Vector3.new(25.34, 113.67, -724.23),
    Vector3.new(27.94, 113.67, -719.88),
    Vector3.new(22.93, 113.67, -720.10),
    Vector3.new(-188.71, 64.67, -436.63),
    Vector3.new(-192.85, 58.67, -196.11),
    Vector3.new(-267.41, 173.37, 568.58),
    Vector3.new(-910.46, 56.67, 1364.75),
    Vector3.new(175.93, 53.72, -437.32),
    Vector3.new(217.29, 103.52, 695.48),
    Vector3.new(924.44, 78.96, 1315.17),
    Vector3.new(1399.63, 93.24, -2553.47),
    Vector3.new(1386.63, 93.24, -2565.97),
    Vector3.new(4658.29, 55.47, 1613.29)
}

-- === TẠO GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmHopNew"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.34, 0, 0.35, 0)
mainFrame.Position = UDim2.new(0.33, 0, 0.33, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.Active = true
mainFrame.Draggable = true
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)
mainFrame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.16, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm Beli by EXHung"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = mainFrame
RunService.Heartbeat:Connect(function()
    title.TextColor3 = Color3.fromHSV(tick() * 2 % 1, 1, 1)
end)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.9, 0, 0.18, 0)
startBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
startBtn.Text = "START FARM & HOP"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)
startBtn.Parent = mainFrame
startBtn.Active = false

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0.14, 0)
statusLabel.Position = UDim2.new(0.05, 0, 0.38, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Đang vào server..."
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.Parent = mainFrame

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(0.9, 0, 0.14, 0)
progressLabel.Position = UDim2.new(0.05, 0, 0.54, 0)
progressLabel.BackgroundTransparency = 1
progressLabel.Text = "0 / " .. #chestPositions
progressLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
progressLabel.Font = Enum.Font.GothamBold
progressLabel.TextSize = 15
progressLabel.Parent = mainFrame

local hopLabel = Instance.new("TextLabel")
hopLabel.Size = UDim2.new(0.9, 0, 0.13, 0)
hopLabel.Position = UDim2.new(0.05, 0, 0.70, 0)
hopLabel.BackgroundTransparency = 1
hopLabel.Text = "Hop: Đang kiểm tra..."
hopLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
hopLabel.Font = Enum.Font.Gotham
hopLabel.TextSize = 12
hopLabel.Parent = mainFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.9, 0, 0.13, 0)
pingLabel.Position = UDim2.new(0.05, 0, 0.84, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: Đang đo..."
pingLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 12
pingLabel.Parent = mainFrame

-- === BIẾN TOÀN CỤC ===
local isRunning = false
local isHopping = false
local character = nil
local humanoidRootPart = nil
local humanoid = nil
local isInVoid = false
local lastPingCheck = 0
local PING_THRESHOLD = 600

-- === HOP SERVER SIÊU TỐC (TÍCH HỢP TỪ BẠN) ===
local RETRY_DELAY = 1
local MAX_SERVERS = 50
local FailedServers = {}

local HopErrors = {
    [268] = "Bị kick (spam hop)",
    [523] = "Server đang shutdown",
    [769] = "Teleport thất bại (timeout)",
    [774] = "Server đầy tạm thời",
    [1001] = "Mất kết nối",
    ["Disconnected"] = "Mất mạng",
    ["Timeout"] = "Quá thời gian chờ",
    ["Failed to teleport"] = "Lỗi chung",
}

local function GetRandomServers()
    local list = {}
    local cursor = ""
    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(PlaceId)
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        local ok, json = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if not ok or not json or not json.data then break end
        for _, sv in ipairs(json.data) do
            if sv.playing < sv.maxPlayers
            and sv.id ~= CurrentJobId
            and not FailedServers[sv.id] then
                table.insert(list, sv)
                if #list >= MAX_SERVERS then break end
            end
        end
        cursor = json.nextPageCursor or ""
        task.wait(0.2)
    until cursor == "" or #list >= MAX_SERVERS

    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end

local function HopServer(reason)
    if isHopping then return end
    isHopping = true
    isRunning = false
    if reason then
        hopLabel.Text = "Hop: " .. reason
        statusLabel.Text = "Đang hop server..."
    end

    print("Đang tìm server mới...")
    local servers = GetRandomServers()
    if #servers == 0 then
        warn("Không có server! Đợi 5s...")
        task.wait(5)
        FailedServers = {}
        return HopServer(reason)
    end

    for _, sv in ipairs(servers) do
        local id = sv.id
        print(("[HOP] Thử %d/%d người → %s"):format(sv.playing, sv.maxPlayers, id))
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, id, player)
        end)
        if success then
            print("Vào server thành công!")
            isHopping = false
            return true
        else
            local msg = tostring(err)
            local code = msg:match("%d+")
            local errReason = HopErrors[tonumber(code)] or HopErrors[msg:match("Timeout") and "Timeout"] or msg
            warn(("[HOP] Lỗi: %s → Bỏ qua server"):format(errReason))
            FailedServers[id] = true
            task.wait(RETRY_DELAY)
        end
    end

    warn("Hết server, lấy danh sách mới...")
    task.wait(2)
    FailedServers = {}
    return HopServer(reason or "Hết server")
end

-- Xử lý lỗi teleport
TeleportService.TeleportInitFailed:Connect(function(player, result, message)
    warn(("TeleportInitFailed: %s"):format(message))
    task.wait(RETRY_DELAY)
    HopServer("Lỗi khởi tạo teleport")
end)

-- === PING CHECK ===
local function getPing()
    if player and player.GetNetworkPing then
        return math.floor(player:GetNetworkPing() * 1000)
    end
    return nil
end

local function checkPingAndHop()
    local ping = getPing()
    if not ping then
        pingLabel.Text = "Ping: Không đo được"
        pingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    pingLabel.Text = "Ping: " .. ping .. "ms"
    if ping <= 200 then
        pingLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif ping <= 500 then
        pingLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        pingLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    if ping > PING_THRESHOLD and not isHopping then
        HopServer("Ping cao: " .. ping .. "ms")
        return true
    end
    return false
end

-- === ANTI DANGEROUS ===
local DANGEROUS_USERS = {"TheDevil8587", "P_w9r", "53ort", "xwtea", "PFvinylscratch666", "Quixotize"}
local function isDangerousPlayer(plr)
    if plr == player then return false end
    local name = plr.Name
    local display = plr.DisplayName
    for _, dangerous in ipairs(DANGEROUS_USERS) do
        if name == dangerous or display == dangerous then
            return true, dangerous
        end
    end
    return false
end

local function checkAndHopIfDangerous(reason)
    if isHopping then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        local isDanger, username = isDangerousPlayer(plr)
        if isDanger then
            statusLabel.Text = "PHÁT HIỆN: " .. username .. " → HỢP!"
            hopLabel.Text = "Hop: " .. reason
            task.wait(1)
            HopServer("Phát hiện nguy hiểm: " .. username)
            return true
        end
    end
    return false
end

-- === KIỂM TRA NHÂN VẬT ===
local function isCharacterAlive()
    if not character then return false end
    humanoid = character:FindFirstChild("Humanoid")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not humanoidRootPart then return false end
    if humanoidRootPart.Position.Y >= 9000 then
        isInVoid = true
        return false
    end
    isInVoid = false
    return humanoid.Health > 0
end

local function updateStatus()
    if isInVoid then
        statusLabel.Text = "Đang ở void (Y≥9000)..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        startBtn.Active = false
    elseif isCharacterAlive() then
        statusLabel.Text = "Sẵn sàng farm!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        startBtn.Active = true
    else
        statusLabel.Text = "Đang đợi hồi sinh..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        startBtn.Active = false
    end
end

-- === NOCLIP & OPEN CHEST & TELEPORT ===
local function toggleNoclip(enable)
    if not character or not humanoidRootPart then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= humanoidRootPart then
            part.CanCollide = not enable
        end
    end
end

local function openNearbyChest()
    if not isCharacterAlive() then return end
    local nearest, minDist = nil, 25
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") and obj.Parent and (obj.Parent.Name:lower():find("chest") or obj.Parent.Name:lower():find("swap")) then
            local root = obj.Parent.PrimaryPart or obj.Parent:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (root.Position - humanoidRootPart.Position).Magnitude
                if dist < minDist then
                    nearest, minDist = obj, dist
                end
            end
        end
    end
    if nearest then
        fireclickdetector(nearest)
        task.wait(0.8)
    end
end

local function teleportTo(pos)
    if not isCharacterAlive() then return end
    humanoidRootPart.CFrame = CFrame.new(pos)
    task.wait(0.25)
    humanoidRootPart.CFrame = CFrame.new(pos)
    task.wait(0.25)
end

-- === NÚT START ===
startBtn.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        toggleNoclip(false)
        statusLabel.Text = "Đã dừng"
        startBtn.Text = "START FARM & HOP"
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
        return
    end
    if not isCharacterAlive() then
        statusLabel.Text = "CHƯA HỒI SINH HOẶC Ở VOID → HOP NGAY!"
        hopLabel.Text = "Hop: Chưa sẵn sàng"
        task.wait(1)
        HopServer("Chưa hồi sinh / Ở void")
        return
    end
    isRunning = true
    startBtn.Text = "STOP"
    startBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    statusLabel.Text = "Đang farm..."
    toggleNoclip(true)
    task.spawn(function()
        for i, pos in ipairs(chestPositions) do
            if not isRunning or not isCharacterAlive() then break end
            progressLabel.Text = i .. " / " .. #chestPositions
            teleportTo(pos)
            openNearbyChest()
            checkAndHopIfDangerous("Farm check")
        end
        if isRunning and isCharacterAlive() then
            statusLabel.Text = "Farm xong! Hop server..."
            toggleNoclip(false)
            task.wait(1)
            HopServer("Farm hoàn thành")
        end
    end)
end)

-- === CHARACTER SPAWN ===
player.CharacterAdded:Connect(function(char)
    character = char
    isInVoid = false
    statusLabel.Text = "Đang đợi hồi sinh..."
    startBtn.Active = false
    hopLabel.Text = "Hop: Đang load nhân vật..."
    task.wait(3)
    humanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
    task.spawn(function()
        task.wait(1)
        if humanoidRootPart and humanoidRootPart.Position.Y >= 9000 then
            statusLabel.Text = "Ở void (Y≥9000)! Đợi rơi..."
            repeat task.wait(0.5) until not humanoidRootPart or humanoidRootPart.Position.Y < 9000 or not character.Parent
        end
        if isCharacterAlive() then
            updateStatus()
            hopLabel.Text = "Hop: Đã sẵn sàng!"
        else
            HopServer("Lỗi load nhân vật")
        end
    end)
end)

-- === REALTIME CHECK (DEATH, VOID, PING, DANGEROUS) ===
RunService.Heartbeat:Connect(function()
    -- Void check
    if character and humanoidRootPart and humanoidRootPart.Position.Y >= 9000 and not isInVoid then
        isInVoid = true
        updateStatus()
    elseif isInVoid and humanoidRootPart and humanoidRootPart.Position.Y < 9000 then
        isInVoid = false
        updateStatus()
    end

    -- Death check
    if isRunning and not isCharacterAlive() then
        isRunning = false
        toggleNoclip(false)
        statusLabel.Text = "CHẾT/VOID → HOP NGAY!"
        startBtn.Text = "START FARM & HOP"
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
        task.wait(0.5)
        HopServer("Death or Void")
    end

    -- Ping check every 2s
    if tick() - lastPingCheck >= 2 then
        lastPingCheck = tick()
        if not isHopping then
            checkPingAndHop()
        end
    end
end)

-- === ANTI DANGEROUS REALTIME ===
task.spawn(function()
    task.wait(1)
    if not checkAndHopIfDangerous("Vào server") then
        hopLabel.Text = "Hop: Server an toàn"
    end
end)

Players.PlayerAdded:Connect(function(newPlayer)
    task.wait(1.5)
    checkAndHopIfDangerous("Player mới: " .. newPlayer.Name)
end)

RunService.Heartbeat:Connect(function()
    if tick() % 15 < 0.1 and not isHopping then
        checkAndHopIfDangerous("Check 15s")
    end
end)

-- === KHỞI ĐỘNG ===
task.spawn(function()
    task.wait(1)
    character = player.Character
    if character then
        task.wait(0.5)
        updateStatus()
    else
        statusLabel.Text = "Đang đợi nhân vật..."
    end
    task.wait(1)
    if not isHopping then
        checkPingAndHop()
    end
end)