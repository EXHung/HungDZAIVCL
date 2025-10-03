-- Auto Farm + HUD Chest (script hoàn chỉnh)
-- Tính năng: START DELAY random(15-25s), ANTI-BAN (random delay, ping check, shuffle), 
-- cập nhật chest tức thì, RESPAN WAIT random chẵn(6,8,10) chia 2 thông báo, 
-- hop server thường random(3-7s), autoFarmActive reset khi respawn/lỗi
-- =====================================

local checkInterval = 15 -- kiểm tra định kỳ HUD/farm
local startDelay = math.random(15,25) -- random khởi động
local respawnWaitOptions = {6,8,10}   -- số giây chẵn khi respawn
local respawnWait = respawnWaitOptions[math.random(1,#respawnWaitOptions)]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

-- trạng thái
local farmingThread = nil
local autoFarmActive = true
local statusText = "Deos cos gif"
local hudLabel

-- ========== HUD ==========
local function createHUD()
    if player:FindFirstChild("PlayerGui") == nil then return end
    local pg = player:WaitForChild("PlayerGui")
    if pg:FindFirstChild("AutoChestHUD") then
        pg.AutoChestHUD:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AutoChestHUD"
    gui.ResetOnSpawn = false
    gui.Parent = pg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 110)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 0.35
    frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    hudLabel = Instance.new("TextLabel")
    hudLabel.Size = UDim2.new(1, -8, 1, -8)
    hudLabel.Position = UDim2.new(0, 4, 0, 4)
    hudLabel.BackgroundTransparency = 1
    hudLabel.TextColor3 = Color3.fromRGB(255,255,255)
    hudLabel.TextWrapped = true
    hudLabel.Font = Enum.Font.SourceSansSemibold
    hudLabel.TextSize = 16
    hudLabel.TextXAlignment = Enum.TextXAlignment.Left
    hudLabel.TextYAlignment = Enum.TextYAlignment.Top
    hudLabel.Parent = frame

    -- Rainbow text
    task.spawn(function()
        local hue = 0
        while hudLabel and hudLabel.Parent do
            hue = (hue + 0.01) % 1
            hudLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end)

    return gui
end

local function updateHUD(chestN)
    if not hudLabel then return end
    local chStr = chestN or (workspace:FindFirstChild("Chests") and #workspace.Chests:GetChildren()) or 0
    hudLabel.Text = "Số lượng chests: "..tostring(chStr)
        .."\nTrạng thái : "..tostring(statusText)
		.."\nHung dzai vl"
        .."\nSCRIPT BY TEAM TPL"
		.."\nv1.0"
end

-- ========== Watch chests ==========
local function watchChests()
    local folder = workspace:FindFirstChild("Chests")
    if folder then
        updateHUD(#folder:GetChildren())
        folder.ChildAdded:Connect(function() updateHUD(#folder:GetChildren()) end)
        folder.ChildRemoved:Connect(function() updateHUD(#folder:GetChildren()) end)
    else
        updateHUD(0)
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Chests" then
                task.wait(0.1)
                watchChests()
            end
        end)
    end
end

-- ========== Anti-ban ==========
math.randomseed(tick() + os.time())

local function randomDelay(minSec, maxSec)
    return math.random(math.floor(minSec*100), math.floor(maxSec*100)) / 100
end

local function safePingWait()
    local ok, ping = pcall(function()
        local stats = game:GetService("Stats")
        local item = stats and stats.Network and stats.Network.ServerStatsItem and stats.Network.ServerStatsItem["Data Ping"]
        if item then return item:GetValue() end
        return nil
    end)
    if ok and ping and ping > 300 then
        local t = randomDelay(2,4)
        statusText = "Ping cao, nghỉ [ANTI-BAN]"
        updateHUD()
        task.wait(t)
    end
end

local function antiBanPauseOccasional()
    if math.random(1,6) == 1 then
        local extra = randomDelay(1, 3)
        statusText = "Nghỉ ngắn "..tostring(extra).."s [ANTI-BAN]"
        updateHUD()
        task.wait(extra)
    end
end

local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
end

-- ========== Hop server ==========
local function hopServerLoop()
    local failCount = 0
    while true do
        statusText = "Đang phi thăng"
        updateHUD()
        warn("[Auto] Hop server...")
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
        end)
        if success and result then
            local ok, data = pcall(function() return HttpService:JSONDecode(result) end)
            if ok and data and data.data then
                local servers = {}
                for _, v in ipairs(data.data) do
                    if type(v) == "table" and v.playing and v.maxPlayers and v.id and v.id ~= game.JobId and v.playing < v.maxPlayers then
                        table.insert(servers, v.id)
                    end
                end
                if #servers > 0 then
                    local randomServer = servers[math.random(1,#servers)]
                    local waitT = math.random(3,7) -- random delay 3-7s
                    statusText = "Chuẩn bị hop ("..waitT.."s)"
                    updateHUD()
                    task.wait(waitT)
                    local okTp, err = pcall(function()
                        TeleportService:TeleportToPlaceInstance(placeId, randomServer, player)
                    end)
                    if okTp then return end
                    warn("[Auto] Teleport fail: "..tostring(err))
                end
            end
        end
        failCount += 1
        local waitT = math.random(8, 15)
        statusText = "Hop thất bại, thử lại sau "..waitT.."s"
        updateHUD()
        task.wait(waitT)
    end
end

-- ========== Farm ==========
local function getChestsFolder()
    return workspace:FindFirstChild("Chests")
end

local function safeTweenTo(part, targetCFrame)
    if not part or not targetCFrame then return false end
    local tweenTime = randomDelay(0.28, 0.6)
    local ok, tw = pcall(function()
        return TweenService:Create(part, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCFrame})
    end)
    if ok and tw then
        tw:Play()
        pcall(function() tw.Completed:Wait() end)
        return true
    else
        pcall(function() part.CFrame = targetCFrame end)
        return true
    end
end

local function farmOnce()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local chestsFolder = getChestsFolder()
    if not chestsFolder then return "no_chests" end
    local chests = chestsFolder:GetChildren()
    if #chests == 0 then return "no_chests" end

    shuffleTable(chests)
    for _, chest in ipairs(chests) do
        local targetCFrame
        if chest:IsA("Model") and chest.PrimaryPart then
            targetCFrame = chest.PrimaryPart.CFrame + Vector3.new(0,2,0)
        elseif chest:IsA("BasePart") then
            targetCFrame = chest.CFrame + Vector3.new(0,2,0)
        else
            if chest:IsA("Model") then
                for _, d in ipairs(chest:GetDescendants()) do
                    if d:IsA("BasePart") then
                        targetCFrame = d.CFrame + Vector3.new(0,2,0)
                        break
                    end
                end
            end
        end

        if targetCFrame then
            safePingWait()
            safeTweenTo(hrp, targetCFrame)
            updateHUD((getChestsFolder() and #getChestsFolder():GetChildren()) or 0)
            task.wait(randomDelay(0.12, 0.45))
            antiBanPauseOccasional()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                return false
            end
        end
    end
    return true
end

local function startFarmLoop()
    if farmingThread then return end
    autoFarmActive = true
    farmingThread = task.spawn(function()
        statusText = "Tu luyện"
        updateHUD()
        while autoFarmActive do
            local r = farmOnce()
            if r == "no_chests" then
                statusText = "Không còn chest, chuẩn bị hop"
                updateHUD()
                task.wait(randomDelay(1,3))
                hopServerLoop()
                break
            elseif r == false then
                statusText = "Lỗi/Respawn, dừng farm"
                updateHUD()
                break
            end
            task.wait(randomDelay(0.7, 1.5))
        end
        farmingThread = nil
    end)
end

-- ========== Respawn handler ==========
player.CharacterRemoving:Connect(function()
    statusText = "Đang xuống âm phủ"
    autoFarmActive = false
    farmingThread = nil
    updateHUD()

    task.spawn(function()
        local half = respawnWait / 2
        for i = half, 1, -1 do
            statusText = "Đang đánh giá nhân phẩm ("..i.."s)..."
            updateHUD()
            task.wait(1)
        end
        for i = half, 1, -1 do
            statusText = "Mày sẽ phải xuống địa ngục vì hack game ("..i.."s)..."
            updateHUD()
            task.wait(1)
        end
        hopServerLoop()
    end)
end)

player.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    if char:FindFirstChild("HumanoidRootPart") then
        startFarmLoop()
    end
end)

-- ========== START ==========
createHUD()
task.spawn(function()
    for i = startDelay, 1, -1 do
        statusText = "Bắt đầu sau "..i.."s..."
        updateHUD()
        task.wait(1)
    end
    statusText = "Khởi động farming..."
    updateHUD()
    watchChests()
    task.wait(0.3)
    startFarmLoop()

    task.spawn(function()
        while true do
            task.wait(checkInterval)
            if not farmingThread then
                startFarmLoop()
            end
            updateHUD((getChestsFolder() and #getChestsFolder():GetChildren()) or 0)
        end
    end)
end)

updateHUD((workspace:FindFirstChild("Chests") and #workspace.Chests:GetChildren()) or 0)

warn("[Auto] SCRIPT BY TEAM TPL (Delay "..startDelay.."s, RespawnWait "..respawnWait.."s)")
