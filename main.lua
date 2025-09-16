local Config = {
    Webhook = _G.Webhook or nil,
    Delay = _G.Delay or 300,
    UseUI = (_G.UseUI ~= nil and _G.UseUI) or true,
    ButtonSize = _G.ButtonSize or UDim2.new(0, 60, 0, 60),
    ButtonPos = _G.ButtonPos or UDim2.new(0.9, 0, 0.2, 0)
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local isRunning = true

local function getVNTime()
    local timestamp = os.time() + (7 * 3600)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

local function formatNumber(n)
    local str = tostring(n)
    return str:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.","")
end

local function formatCompact(n)
    if n >= 1e9 then
        return string.format("%.1fB", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fK", n/1e3)
    else
        return tostring(n)
    end
end

local function sendEmbed(playerName, fragments, beli)
    local data = {
        ["embeds"] = {{
            ["title"] = "Thông Tin : " .. playerName,
            ["color"] = 3447003, 
            ["thumbnail"] = {["url"] = "https://i.postimg.cc/MGWnmXkK/e763ee1268743e92ec3a23c7f0d1eb0e.jpg"},
            ["fields"] = {
                {
                    ["name"] = "Fragments",
                    ["value"] = formatNumber(fragments) .. " (" .. formatCompact(fragments) .. ")",
                    ["inline"] = true
                },
                {
                    ["name"] = "Beli",
                    ["value"] = formatNumber(beli) .. " (" .. formatCompact(beli) .. ")",
                    ["inline"] = true
                }
            },
            ["footer"] = {["text"] = "Thời Gian Gửi : " .. getVNTime()}
        }}
    }

    local jsonData = HttpService:JSONEncode(data)
    pcall(function()
        http.request({
            Url = Config.Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end)
end

local function getPlayerData()
    local player = Players.LocalPlayer
    local fragments, beli = 0, 0
    local ok, result = pcall(function()
        local data = {}
        if player:FindFirstChild("Data") then
            if player.Data:FindFirstChild("Fragments") then
                data.fragments = player.Data.Fragments.Value
            end
            if player.Data:FindFirstChild("Beli") then
                data.beli = player.Data.Beli.Value
            end
        elseif player:FindFirstChild("leaderstats") then
            if player.leaderstats:FindFirstChild("Fragments") then
                data.fragments = player.leaderstats.Fragments.Value
            end
            if player.leaderstats:FindFirstChild("Beli") then
                data.beli = player.leaderstats.Beli.Value
            end
        end
        return data
    end)
    if ok and result then
        fragments = result.fragments or 0
        beli = result.beli or 0
    end
    return fragments, beli
end

if Config.UseUI then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WebhookCircleUI"
    ScreenGui.Parent = CoreGui

    local Button = Instance.new("TextButton")
    Button.Size = Config.ButtonSize
    Button.Position = Config.ButtonPos
    Button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    Button.Text = ""
    Button.TextTransparency = 1
    Button.AutoButtonColor = false
    Button.Parent = ScreenGui
    Button.Active = true
    Button.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Button

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "ON"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.TextSize = 18
    StatusLabel.Parent = Button

    Button.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        if isRunning then
            Button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            StatusLabel.Text = "ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            StatusLabel.Text = "OFF"
        end
    end)
end

task.spawn(function()
    while true do
        if isRunning then
            local fragments, beli = getPlayerData()
            sendEmbed(Players.LocalPlayer.Name, fragments, beli)
        end
        task.wait(Config.Delay)
    end
end)
