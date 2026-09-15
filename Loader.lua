local library = loadstring(game:HttpGet("https://slh-hub.lovable.app/raw/kyomba2-ui-lib", true))()

-- Make sure the Players service is available
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Dynamically generate the window title with a welcome message
local windowTitle = "PrimeKenzouu | Public Version | Sapakan Na! " .. LocalPlayer.DisplayName

local window = library:AddWindow(windowTitle, {
    main_color = Color3.fromRGB(41, 74, 122),
    min_size = Vector2.new(600, 500),
    can_resize = false
})

task.spawn(function()
    local imgui = game:GetService("CoreGui"):WaitForChild("imgui", 10)
    if not imgui then return end

    -- 🔥 FIXED THEME COLORS
    local WINDOW_COLOR = Color3.fromRGB(20, 20, 25)
    local FIRE_ORANGE = Color3.fromRGB(0, 0, 0)
    local DARK_EMBER = Color3.fromRGB(0, 0, 0)
    local BLACK = Color3.fromRGB(25, 25, 25)
    
    -- 🎨 DROPDOWN BOX COLOR (Baguhin mo dito kung gusto mo ibang kulay)
    local DROPDOWN_BOX_COLOR = Color3.fromRGB(20, 20, 25)

    local function forceFireTheme(element)
        if not element or not element:IsA("GuiObject") then return end
        if element:GetAttribute("UI_ForcedFire") then return end

        local nameLower = element.Name:lower()
        local parent = element.Parent
        local parentName = parent and parent.Name:lower() or ""

        if nameLower:match("indicator") or nameLower:match("checkmark") or nameLower:match("toggle") then
            return 
        end

        -- Detect kung ito yung mismong Box ng dropdown batay sa ibinigay mo
        local isDropdownBox = (nameLower == "box") and (parentName:match("dropdown") or parentName == "d" or parentName:match("adddropdown"))

        -- 1. IMAGE ASSETS (Dito papasok yung Box mo dahil ImageLabel/ImageButton ito)
        if element:IsA("ImageLabel") or element:IsA("ImageButton") then
            if isDropdownBox then
                element.ImageColor3 = DROPDOWN_BOX_COLOR
                element:SetAttribute("UI_ForcedFire", true)
                return
            elseif nameLower:match("window") or nameLower:match("main") then
                element.ImageColor3 = WINDOW_COLOR
            elseif nameLower:match("folder") then
                element.ImageColor3 = BLACK
            elseif nameLower:match("tab") then
                element.ImageColor3 = DARK_EMBER
            else
                element.ImageColor3 = FIRE_ORANGE
            end
        end

        -- 2. BACKGROUNDS & FRAMES
        if element:IsA("Frame") or element:IsA("TextButton") or element:IsA("TextBox") then
            if isDropdownBox then
                element.BackgroundColor3 = DROPDOWN_BOX_COLOR
                element:SetAttribute("UI_ForcedFire", true)
                return
            elseif nameLower:match("window") or nameLower:match("main") then
                element.BackgroundColor3 = WINDOW_COLOR
            elseif nameLower:match("folder") then
                element.BackgroundColor3 = BLACK
            elseif nameLower:match("tab") then
                element.BackgroundColor3 = DARK_EMBER
            elseif nameLower:match("addswitch") 
                or nameLower:match("addbutton") 
                or nameLower:match("addslider") 
                or nameLower:match("addtextbox")
                or nameLower:match("bar") then
                
                element.BackgroundColor3 = FIRE_ORANGE
            end
        end

        element:SetAttribute("UI_ForcedFire", true)
    end

    for _, element in ipairs(imgui:GetDescendants()) do
        task.defer(forceFireTheme, element)
    end

    imgui.DescendantAdded:Connect(function(element)
        task.defer(forceFireTheme, element)
    end)
end)

-- Create Tab within the Window
local FarmTab = window:AddTab("Farming")

local opfarms = FarmTab:AddFolder("Auto Equip Dumbbells V1")
local toos = FarmTab:AddFolder("Auto Equip Dumbbells V2")

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local AntiAFKConnection = nil
local AFKTimerThread = nil
local RainbowThread = nil

-- 1. Create Standalone ScreenGui Overlay
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Elerium_AFKOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protect GUI from detection if supported by executor
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    elseif gethui then
        ScreenGui.Parent = gethui()
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = CoreGui
end

-- 2. Build the Timer Frame Layout (Fixed Position & Fully Transparent)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 80)
MainFrame.Position = UDim2.new(0.5, -250, 0.00, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Active = false 
MainFrame.Draggable = false 
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

-- Rainbow Text Label (ANTI AFK Text)
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "ANTI AFK: 00:00:00"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextSize = 25 
TextLabel.TextXAlignment = Enum.TextXAlignment.Center
TextLabel.TextYAlignment = Enum.TextYAlignment.Center
TextLabel.Parent = MainFrame

-- 3. Add to your Elerium Tab
local AntiAFKSwitch = FarmTab:AddSwitch("Anti-AFK", function(bool)
    if bool then
        -- Make the ScreenGui container visible
        MainFrame.Visible = true
        
        -- Start Infinite Yield style Anti-AFK engine (uses LocalPlayer.Idled event + VirtualUser)
        if not AntiAFKConnection then
            AntiAFKConnection = player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
        
        -- Start clock thread
        if not AFKTimerThread then
            AFKTimerThread = task.spawn(function()
                local startTime = os.time()
                while true do
                    local elapsed = os.time() - startTime
                    local hours = math.floor(elapsed / 3600)
                    local minutes = math.floor((elapsed % 3600) / 60)
                    local seconds = elapsed % 60
                    
                    TextLabel.Text = string.format("ANTI AFK: %02d:%02d:%02d", hours, minutes, seconds)
                    task.wait(1)
                end
            end)
        end

        -- Start Rainbow Text dynamic loop thread
        if not RainbowThread then
            RainbowThread = task.spawn(function()
                local hue = 0
                while true do
                    TextLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                    hue = hue + 0.01
                    if hue >= 1 then
                        hue = 0
                    end
                    task.wait(0.03)
                end
            end)
        end
    else
        -- Hide the ScreenGui container completely
        MainFrame.Visible = false
        
        -- Stop everything safely
        if typeof(AntiAFKConnection) == "RBXScriptConnection" then
            AntiAFKConnection:Disconnect()
            AntiAFKConnection = nil
        elseif typeof(AntiAFKConnection) == "thread" then
            task.cancel(AntiAFKConnection)
            AntiAFKConnection = nil
        end
        
        if AFKTimerThread then
            task.cancel(AFKTimerThread)
            AFKTimerThread = nil
        end

        if RainbowThread then
            task.cancel(RainbowThread)
            RainbowThread = nil
        end
    end
end)

-- Visually toggle Elerium switch checkmark to ON immediately upon loading script
AntiAFKSwitch:Set(true)

-- Global state for Popups
local _G = getgenv and getgenv() or _G
_G.HideGainedPopups = false
local originalStates = {}

-- Checks if the UI element is any type of standard visual Frame container
local function isFrameUi(element)
    return element:IsA("Frame") or element:IsA("ScrollingFrame") or element:IsA("CanvasGroup")
end

local function hideElement(element)
    if not isFrameUi(element) then return end
    
    -- Save original properties before modifying them
    if not originalStates[element] then
        originalStates[element] = {
            Visible = element.Visible,
            Position = element.Position
        }
    end
    
    element.Visible = false
    element.Position = UDim2.new(5, 0, 5, 0) -- Teleport far off-screen to bypass forced visibility scripts
end

local function restoreElements()
    for element, state in pairs(originalStates) do
        if element and element.Parent then
            element.Visible = state.Visible
            element.Position = state.Position
        end
    end
    table.clear(originalStates)
end

local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Listen for any new frames being added dynamically while the switch is ON
playerGui.DescendantAdded:Connect(function(descendant)
    if _G.HideGainedPopups then
        task.wait(0.05) -- Tiny delay to let the game engine set up the new frame first
        if _G.HideGainedPopups then
            hideElement(descendant)
        end
    end
end)

-- Hooked directly into your Elerium v2 switch
FarmTab:AddSwitch("Hide All UI Frames", function(state)
    _G.HideGainedPopups = state
    if state then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            hideElement(desc)
        end
    else
        restoreElements()
    end
end)

local isLocked = false
local savedCFrame = nil -- Dito itatabi ang eksaktong lokasyon mo
local player = game:GetService("Players").LocalPlayer

-- Function na awtomatikong magbabalik at magla-lock sa iyo pagka-respawn
local function applyLock(character)
    if isLocked and savedCFrame then
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart then
            task.wait(0.2) -- Safe delay para hindi mag-glitch ang loading ng laro
            rootPart.CFrame = savedCFrame -- Ite-teleport ka pabalik sa tinagong pwesto
            task.wait(0.05)
            rootPart.Anchored = true -- Ika-lock ka ulit sa pwestong iyon
        end
    end
end

-- Taga-bantay tuwing namamatay at nabubuhay ka ulit
player.CharacterAdded:Connect(applyLock)

-- Ang tamang Elerium V2 Switch Element
FarmTab:AddSwitch("Lock Position", function(state)
    isLocked = state
    
    if player.Character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            if state then
                -- Pagka-on ng switch, ise-save ang kasalukuyang pwesto mo ngayon
                savedCFrame = rootPart.CFrame
                rootPart.Anchored = true
            else
                -- Pagka-off, pakakawalan ang character mo at buburahin ang saved spot
                rootPart.Anchored = false
                savedCFrame = nil
            end
        end
    end
end)

local loopActive = false

FarmTab:AddSwitch("FAKE Fast Rep", function(state)
    loopActive = state
    
    -- Runs a continuous loop while the switch is toggled ON
    task.spawn(function()
        while loopActive do
            local Event = game:GetService("ReplicatedStorage").EffectsGUi
            firesignal(Event.OnClientEvent, "Strength", 1000000000)
            task.wait(0.1) -- Adjustable delay to prevent game crashes
        end
    end)
end)

-- Global Environment Setup
getgenv().AutoFarmAll = false

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Function to safely locate nil instances if needed
local function getNil(name, class) 
    for _, v in pairs(getnilinstances()) do 
        if v.ClassName == class and v.Name == name then 
            return v
        end 
    end 
end

-- Check if a tool name matches any valid training keywords
local function isValidTrainingTool(toolName)
    if not toolName then return false end
    local name = toolName:lower()
    return name:find("weight") or name:find("bell") or name:find("lift") or name:find("squat") or name:find("push") or name:find("up")
end

-- Broad Locator Helper (Finds any valid lifting/training tool in backpack)
local function findAnyTrainingTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and isValidTrainingTool(item.Name) then
            return item
        end
    end
    
    return nil
end

-- Core execution loop logic (Combined)
local function universalFarmLoop()
    while getgenv().AutoFarmAll do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            local currentlyEquipped = character:FindFirstChildOfClass("Tool")
            
            if currentlyEquipped then
                -- Check if holding a valid training item
                if not isValidTrainingTool(currentlyEquipped.Name) then
                    humanoid:UnequipTools()
                    task.wait(0.1)
                else
                    -- Valid tool equipped; fire training remote safely
                    ReplicatedStorage.remotes.MuscleEvent:FireServer("tool")
                end
            else
                -- Not holding anything; scan backpack for ANY training tool available
                local tool = findAnyTrainingTool()
                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.1) 
    end
end

-- Elerium UI Elements
FarmTab:AddSwitch("Universal (Auto Lift)", function(bool)
    getgenv().AutoFarmAll = bool
    if bool then
        task.spawn(universalFarmLoop)
    end
end)

-- Global Environment Setup
getgenv().Weights = false

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Strict Weight Locator Helper (Locks onto lifting tools only)
local function findWeightTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    -- Checks backpack strictly for keywords matching weight items
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("weight") or name:find("bell") or name:find("lift") then
                return item
            end
        end
    end
    
    return nil
end

-- Core execution loop logic
local function autoEquipAndTrainLoop()
    while getgenv().Weights do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            local currentlyEquipped = character:FindFirstChildOfClass("Tool")
            
            if currentlyEquipped then
                local toolName = currentlyEquipped.Name:lower()
                -- If holding something that ISN'T a weight, force unequip it
                if not (toolName:find("weight") or toolName:find("bell") or toolName:find("lift")) then
                    humanoid:UnequipTools()
                    task.wait(0.1)
                else
                    -- Securely holding correct training tool; fire lifting remote
                    ReplicatedStorage.remotes.MuscleEvent:FireServer("tool")
                end
            else
                -- Not holding anything; look inside backpack specifically for weights
                local tool = findWeightTool()
                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.1) 
    end
end

-- Elerium UI Elements
FarmTab:AddSwitch("Auto Lift Weights", function(bool)
    getgenv().Weights = bool
    if bool then
        task.spawn(autoEquipAndTrainLoop)
    end
end)

-- Global Environment Setup
getgenv().Squat = false

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Function to safely locate nil instances if needed
function getNil(name, class) 
    for _, v in pairs(getnilinstances()) do 
        if v.ClassName == class and v.Name == name then 
            return v
        end 
    end 
end

-- Strict Squat Locator Helper (Locks onto Squat tool only)
local function findSquatTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    -- Checks backpack strictly for keywords matching squat item
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("squat") then
                return item
            end
        end
    end
    
    return nil
end

-- Core execution loop logic
local function autoEquipAndTrainLoop()
    while getgenv().Squat do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            local currentlyEquipped = character:FindFirstChildOfClass("Tool")
            
            if currentlyEquipped then
                local toolName = currentlyEquipped.Name:lower()
                -- If holding something that ISN'T squat, force unequip it
                if not (toolName:find("squat")) then
                    humanoid:UnequipTools()
                    task.wait(0.1)
                else
                    -- Securely holding squat tool; fire training remote
                    local args = {
                        [1] = "tool"
                    }
                    ReplicatedStorage.remotes.MuscleEvent:FireServer(unpack(args))
                end
            else
                -- Not holding anything; look inside backpack specifically for squat tool
                local tool = findSquatTool()
                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.1) 
    end
end

-- Elerium UI Elements
FarmTab:AddSwitch("Auto Squat", function(bool)
    getgenv().Squat = bool
    if bool then
        task.spawn(autoEquipAndTrainLoop)
    end
end)

-- Global Environment Setup
getgenv().PushUps = false

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Function to safely locate nil instances if needed
function getNil(name, class) 
    for _, v in pairs(getnilinstances()) do 
        if v.ClassName == class and v.Name == name then 
            return v
        end 
    end 
end

-- Strict Push Ups Locator Helper (Locks onto Push Ups tool only)
local function findPushUpsTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    -- Checks backpack strictly for keywords matching push ups item
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("push") or name:find("up") then
                return item
            end
        end
    end
    
    return nil
end

-- Core execution loop logic
local function autoEquipAndTrainLoop()
    while getgenv().PushUps do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            local currentlyEquipped = character:FindFirstChildOfClass("Tool")
            
            if currentlyEquipped then
                local toolName = currentlyEquipped.Name:lower()
                -- If holding something that ISN'T push ups, force unequip it
                if not (toolName:find("push") or toolName:find("up")) then
                    humanoid:UnequipTools()
                    task.wait(0.1)
                else
                    -- Securely holding push ups tool; fire training remote
                    local args = {
                        [1] = "tool"
                    }
                    ReplicatedStorage.remotes.MuscleEvent:FireServer(unpack(args))
                end
            else
                -- Not holding anything; look inside backpack specifically for push ups tool
                local tool = findPushUpsTool()
                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.1) 
    end
end

-- Elerium UI Elements
FarmTab:AddSwitch("Auto Push Ups", function(bool)
    getgenv().PushUps = bool
    if bool then
        task.spawn(autoEquipAndTrainLoop)
    end
end)

-- Switch: Auto Rebirth Loop
FarmTab:AddSwitch("Auto Rebirth", function(bool)
    autoRebirth = bool
    
    -- Run execution loop safely on a background thread
    task.spawn(function()
        while autoRebirth do
            game:GetService("ReplicatedStorage").remotes.rebirthRequest:FireServer()
            
            -- Essential delay to prevent game rate-limiting or crashing
            task.wait(0.1) 
        end
    end)
end)

-- Global Environment Setup
getgenv().AutoSpin = false

-- Core execution loop logic
local function autoSpinLoop()
    while getgenv().AutoSpin do
        game:GetService("ReplicatedStorage").spinRequest:FireServer()
        
        -- Essential delay to prevent game rate-limiting, lagging, or crashing
        task.wait(0.5) 
    end
end

-- Elerium UI Elements
FarmTab:AddSwitch("Auto Spin Wheel", function(bool)
    getgenv().AutoSpin = bool
    if bool then
        task.spawn(autoSpinLoop)
    end
end)

-- Separate functions to ensure each remote fires on its own schedule
local function claimReward(rewardName)
    local args = {
        [1] = rewardName
    }
    game:GetService("ReplicatedStorage").claimReward:FireServer(unpack(args))
end

-- All rewards combined into one single switch
FarmTab:AddSwitch("Auto Claim All Rewards", function(bool)
    task.spawn(function()
        while bool do
            claimReward("reward1")
            task.wait(1)
            
            -- Only proceed if the user hasn't turned off the switch mid-loop
            if not bool then break end
            claimReward("reward2")
            task.wait(1)
            
            if not bool then break end
            claimReward("reward3")
            task.wait(1)
            
            if not bool then break end
            claimReward("reward4")
            task.wait(1)
            
            if not bool then break end
            claimReward("reward5")
            task.wait(1)
            
            if not bool then break end
            claimReward("reward6")
            task.wait(1)
        end
    end)
end)

local remotes = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer

-- Create the Toggle Switch in your UI section
local autoCollectQuest = false
FarmTab:AddSwitch("Auto Collect Daily Quest", function(state)
    autoCollectQuest = state
    
    -- Loop runs continuously while the switch is toggled ON
    while autoCollectQuest do
        -- Target the specific quest object inside the player's quest folder
        local questTarget = player.QuestsFolder:FindFirstChild("Quest")
        
        if questTarget then
            -- Safely fire the remote event without needing unpack()
            remotes.collecteRequest:FireServer(questTarget)
        end
        
        -- Prevents game crashes and controls the speed of the loop
        task.wait(1) 
    end
end)

-- Global Environment Setup
getgenv().Chocolates = false

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Master Checker kung may Chocolate talaga sa Backpack
local function hasChocolateInBackpack()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("choco") or name:find("bar") or name:find("sweet") then
                return item -- Ibalik yung tool object kapag nahanap
            end
        end
    end
    return nil -- Kapag walang nahanap na chocolate sa backpack
end

-- Core execution loop logic
local function autoEquipAndTrainLoop()
    while getgenv().Chocolates do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            local currentlyEquipped = character:FindFirstChildOfClass("Tool")
            
            -- MASTER CHECK: Kung may hawak siyang tama, hayaan lang. Pero kung walang hawak, dapat siguradong may chocolate sa backpack bago gumana.
            local isHoldingChocolate = currentlyEquipped and (currentlyEquipped.Name:lower():find("choco") or currentlyEquipped.Name:lower():find("bar") or currentlyEquipped.Name:lower():find("sweet"))
            local chocolateTool = hasChocolateInBackpack()
            
            if isHoldingChocolate or chocolateTool then
                -- DITO LANG GAGANA ANG SCRIPT KAPAG TRUE ANG CONDITION
                if currentlyEquipped then
                    if not isHoldingChocolate then
                        -- Kung may hawak na maling tool, tanggaling agad para makapag-equip ng chocolate
                        humanoid:UnequipTools()
                        task.wait(0.01)
                    else
                        -- Pag tama ang hawak, kain agad!
                        ReplicatedStorage.remotes.proteineRequest:FireServer()
                    end
                else
                    -- Kung walang hawak pero may chocolate sa backpack, i-equip na natin
                    if chocolateTool then
                        humanoid:EquipTool(chocolateTool)
                        task.wait(0.01)
                    end
                end
            else
                -- KAPAG WALANG CHOCOLATE SA BACKPACK AT WALANG HAWAK: 
                -- HINDI GAGANA, HINDI MAG-AAUTO EQUIP, WALANG GAGAWIN.
            end
        end
        task.wait(0.01) 
    end
end

-- Elerium UI Elements
FarmTab:AddSwitch("Auto Chocolates", function(bool)
    getgenv().Chocolates = bool
    if bool then
        task.spawn(autoEquipAndTrainLoop)
    end
end)

local BossBoostToggle = false

FarmTab:AddSwitch("Auto TP Boss Boost", function(state)
    BossBoostToggle = state
    
    if state then
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            
            while BossBoostToggle do
                -- Safely check if the character and RootPart exist before moving
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(
                        299.65741, 9.64752197, 334.599731, 
                        -0.017452199, 6.03341235e-08, -0.99984771, 
                        9.62693747e-08, 1, 5.86629412e-08, 
                        0.99984771, -9.52309165e-08, -0.017452199
                    )
                end
                task.wait(1) -- Lowered delay for a faster, tighter loop teleport
            end
        end)
    end
end)

_G.ArenaBoostActive = false

FarmTab:AddSwitch("Auto TP Arena Boost", function(bool)
    _G.ArenaBoostActive = bool
    
    if _G.ArenaBoostActive then
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            
            while _G.ArenaBoostActive do
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    rootPart.CFrame = CFrame.new(
                        -25.8208008, 10.4261885, 348.60202, 
                        0.0174522307, -5.16945846e-08, 0.99984771, 
                        -2.01935868e-09, 1, 5.17377039e-08, 
                        -0.99984771, -2.92198954e-09, 0.0174522307
                    )
                end
                task.wait(1)
            end
        end)
    end
end)

opfarms:AddLabel("Push ups")

-- Button 4: Use Push Ups
opfarms:AddButton("Equiped Push Ups 5kg", function()
    local args = {
        [1] = "Push Ups"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 4: Use Push Ups
opfarms:AddButton("Equiped Push Ups 10kg", function()
    local args = {
        [1] = "Push Ups2"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 4: Use Push Ups
opfarms:AddButton("Equiped Push Ups 25kg", function()
    local args = {
        [1] = "Push Ups3"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 4: Use Push Ups
opfarms:AddButton("Equiped Push Ups 40kg", function()
    local args = {
        [1] = "Push Ups Magma"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 4: Use Push Ups
opfarms:AddButton("Equiped Push Ups 75kg", function()
    local args = {
        [1] = "Push Ups Legend"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

opfarms:AddLabel("Dumbbell")

-- Create the Button using Elerium V2 syntax (:AddButton)
opfarms:AddButton("Equiped Rookie Dumbbell 1kg", function()
    local args = {
        [1] = "Rookie Dumbbell"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 2: Use Dumbbell Curl
opfarms:AddButton("Equiped Dumbbell Curl 5kg", function()
    local args = {
        [1] = "Dumbbell Curl"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 2: Use Dumbbell Curl
opfarms:AddButton("Equiped Dumbbell Curl 10kg", function()
    local args = {
        [1] = "Dumbbell Curl2"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 2: Use Dumbbell Curl
opfarms:AddButton("Equiped Dumbbell Curl 15kg", function()
    local args = {
        [1] = "Dumbbell Curl3"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 2: Use Dumbbell Curl
opfarms:AddButton("Equiped Dumbbell Curl 25kg", function()
    local args = {
        [1] = "Dumbbell Curl4"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 2: Use Dumbbell Curl
opfarms:AddButton("Equiped Dumbbell Curl 40kg", function()
    local args = {
        [1] = "Dumbbell Curl Magma"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 2: Use Dumbbell Curl
opfarms:AddButton("Equiped Dumbbell Curl 75kg", function()
    local args = {
        [1] = "Dumbbell Curl Legend"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

opfarms:AddLabel("Dead lift")

-- Button 3: Use Dead Lift
opfarms:AddButton("Equiped Dead Lift 5kg", function()
    local args = {
        [1] = "Dead Lift"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 3: Use Dead Lift
opfarms:AddButton("Equiped Dead Lift 10kg", function()
    local args = {
        [1] = "Dead Lift2"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 3: Use Dead Lift
opfarms:AddButton("Equiped Dead Lift 15kg", function()
    local args = {
        [1] = "Dead Lift3"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 3: Use Dead Lift
opfarms:AddButton("Equiped Dead Lift 25kg", function()
    local args = {
        [1] = "Dead Lift4"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 3: Use Dead Lift
opfarms:AddButton("Equiped Dead Lift 40kg", function()
    local args = {
        [1] = "Dead Lift Magma"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 3: Use Dead Lift
opfarms:AddButton("Equiped Dead Lift 75kg", function()
    local args = {
        [1] = "Dead Lift Legend"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

opfarms:AddLabel("Squat")

-- Button 1: Use Squat
opfarms:AddButton("Equiped Squat 5kg", function()
    local args = {
        [1] = "Squat"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 1: Use Squat
opfarms:AddButton("Equiped Squat 10kg", function()
    local args = {
        [1] = "Squat2"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 1: Use Squat
opfarms:AddButton("Equiped Squat 15kg", function()
    local args = {
        [1] = "Squat3"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 1: Use Squat
opfarms:AddButton("Equiped Squat 25kg", function()
    local args = {
        [1] = "Squat4"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 1: Use Squat
opfarms:AddButton("Equiped Squat 40kg", function()
    local args = {
        [1] = "Squat Magma"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

-- Button 1: Use Squat
opfarms:AddButton("Equiped Squat 75kg", function()
    local args = {
        [1] = "Squat Legend"
    }
    game:GetService("ReplicatedStorage").remotes.dumbbellTake:FireServer(unpack(args))
end)

local remotes = game:GetService("ReplicatedStorage").remotes

-- Push ups Toggles
toos:AddLabel("Push ups")

local farmingPushUps5 = false
toos:AddSwitch("Auto Equiped Push Ups 5kg", function(state)
    farmingPushUps5 = state
    while farmingPushUps5 do
        remotes.dumbbellTake:FireServer("Push Ups")
        task.wait(6)
    end
end)

local farmingPushUps10 = false
toos:AddSwitch("Auto Equiped Push Ups 10kg", function(state)
    farmingPushUps10 = state
    while farmingPushUps10 do
        remotes.dumbbellTake:FireServer("Push Ups2")
        task.wait(6)
    end
end)

local farmingPushUps25 = false
toos:AddSwitch("Auto Equiped Push Ups 25kg", function(state)
    farmingPushUps25 = state
    while farmingPushUps25 do
        remotes.dumbbellTake:FireServer("Push Ups3")
        task.wait(6)
    end
end)

local farmingPushUps40 = false
toos:AddSwitch("Auto Equiped Push Ups 40kg", function(state)
    farmingPushUps40 = state
    while farmingPushUps40 do
        remotes.dumbbellTake:FireServer("Push Ups Magma")
        task.wait(6)
    end
end)

local farmingPushUps40 = false
toos:AddSwitch("Auto Equiped Push Ups 75kg", function(state)
    farmingPushUps40 = state
    while farmingPushUps40 do
        remotes.dumbbellTake:FireServer("Push Ups Legend")
        task.wait(6)
    end
end)

-- Dumbbell Toggles
toos:AddLabel("Dumbbell")

local farmingDumbbell1 = false
toos:AddSwitch("Auto Equiped Rookie Dumbbell 1kg", function(state)
    farmingDumbbell1 = state
    while farmingDumbbell1 do
        remotes.dumbbellTake:FireServer("Rookie Dumbbell")
        task.wait(6)
    end
end)

local farmingCurl5 = false
toos:AddSwitch("Auto Equiped Dumbbell Curl 5kg", function(state)
    farmingCurl5 = state
    while farmingCurl5 do
        remotes.dumbbellTake:FireServer("Dumbbell Curl")
        task.wait(6)
    end
end)

local farmingCurl10 = false
toos:AddSwitch("Auto Equiped Dumbbell Curl 10kg", function(state)
    farmingCurl10 = state
    while farmingCurl10 do
        remotes.dumbbellTake:FireServer("Dumbbell Curl2")
        task.wait(6)
    end
end)

local farmingCurl15 = false
toos:AddSwitch("Auto Equiped Dumbbell Curl 15kg", function(state)
    farmingCurl15 = state
    while farmingCurl15 do
        remotes.dumbbellTake:FireServer("Dumbbell Curl3")
        task.wait(6)
    end
end)

local farmingCurl25 = false
toos:AddSwitch("Auto Equiped Dumbbell Curl 25kg", function(state)
    farmingCurl25 = state
    while farmingCurl25 do
        remotes.dumbbellTake:FireServer("Dumbbell Curl4")
        task.wait(6)
    end
end)

local farmingCurl40 = false
toos:AddSwitch("Auto Equiped Dumbbell Curl 40kg", function(state)
    farmingCurl40 = state
    while farmingCurl40 do
        remotes.dumbbellTake:FireServer("Dumbbell Curl Magma")
        task.wait(6)
    end
end)

local farmingCurl40 = false
toos:AddSwitch("Auto Equiped Dumbbell Curl 75kg", function(state)
    farmingCurl40 = state
    while farmingCurl40 do
        remotes.dumbbellTake:FireServer("Dumbbell Curl Legend")
        task.wait(6)
    end
end)

-- Dead lift Toggles
toos:AddLabel("Dead lift")

local farmingDeadLift5 = false
toos:AddSwitch("Auto Equiped Dead Lift 5kg", function(state)
    farmingDeadLift5 = state
    while farmingDeadLift5 do
        remotes.dumbbellTake:FireServer("Dead Lift")
        task.wait(6)
    end
end)

local farmingDeadLift10 = false
toos:AddSwitch("Auto Equiped Dead Lift 10kg", function(state)
    farmingDeadLift10 = state
    while farmingDeadLift10 do
        remotes.dumbbellTake:FireServer("Dead Lift2")
        task.wait(6)
    end
end)

local farmingDeadLift15 = false
toos:AddSwitch("Auto Equiped Dead Lift 15kg", function(state)
    farmingDeadLift15 = state
    while farmingDeadLift15 do
        remotes.dumbbellTake:FireServer("Dead Lift3")
        task.wait(6)
    end
end)

local farmingDeadLift25 = false
toos:AddSwitch("Auto Equiped Dead Lift 25kg", function(state)
    farmingDeadLift25 = state
    while farmingDeadLift25 do
        remotes.dumbbellTake:FireServer("Dead Lift4")
        task.wait(6)
    end
end)

local farmingDeadLift40 = false
toos:AddSwitch("Auto Equiped Dead Lift 40kg", function(state)
    farmingDeadLift40 = state
    while farmingDeadLift40 do
        remotes.dumbbellTake:FireServer("Dead Lift Magma")
        task.wait(6)
    end
end)

local farmingDeadLift40 = false
toos:AddSwitch("Auto Equiped Dead Lift 75kg", function(state)
    farmingDeadLift40 = state
    while farmingDeadLift40 do
        remotes.dumbbellTake:FireServer("Dead Lift Legend")
        task.wait(6)
    end
end)

-- Squat Toggles
toos:AddLabel("Squat")

local farmingSquat5 = false
toos:AddSwitch("Auto Equiped Squat 5kg", function(state)
    farmingSquat5 = state
    while farmingSquat5 do
        remotes.dumbbellTake:FireServer("Squat")
        task.wait(6)
    end
end)

local farmingSquat10 = false
toos:AddSwitch("Auto Equiped Squat 10kg", function(state)
    farmingSquat10 = state
    while farmingSquat10 do
        remotes.dumbbellTake:FireServer("Squat2")
        task.wait(6)
    end
end)

local farmingSquat15 = false
toos:AddSwitch("Auto Equiped Squat 15kg", function(state)
    farmingSquat15 = state
    while farmingSquat15 do
        remotes.dumbbellTake:FireServer("Squat3")
        task.wait(6)
    end
end)

local farmingSquat25 = false
toos:AddSwitch("Auto Equiped Squat 25kg", function(state)
    farmingSquat25 = state
    while farmingSquat25 do
        remotes.dumbbellTake:FireServer("Squat4")
        task.wait(6)
    end
end)

local farmingSquat40 = false
toos:AddSwitch("Auto Equiped Squat 40kg", function(state)
    farmingSquat40 = state
    while farmingSquat40 do
        remotes.dumbbellTake:FireServer("Squat Magma")
        task.wait(6)
    end
end)

local farmingSquat40 = false
toos:AddSwitch("Auto Equiped Squat 75kg", function(state)
    farmingSquat40 = state
    while farmingSquat40 do
        remotes.dumbbellTake:FireServer("Squat Legend")
        task.wait(6)
    end
end)

-- Create Tab within the Window
local eggtab = window:AddTab("Auto Hatch Egg")

-- Global Environment Setup
getgenv().AutoBuyPet = false
getgenv().SelectedPetRarity = "common" -- Default selected rarity

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BuyPetRemote = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("BuyPetRequest")
local SellRequestRemote = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("sellRequest")

-- Core loop for auto buying
local function autoBuyPetLoop()
    while getgenv().AutoBuyPet do
        -- Fires the remote using the rarity currently chosen in the dropdown
        BuyPetRemote:FireServer(getgenv().SelectedPetRarity)
        task.wait(0.1) -- Cooldown to prevent client crashes
    end
end

-- Elerium V2 UI Elements

-- 1. Create the base dropdown container first
local petDropdown = eggtab:AddDropdown("Select Egg", function(selected)
    getgenv().SelectedPetRarity = selected
end)

-- 2. Add each option manually using the official Elerium syntax
petDropdown:Add("common")
petDropdown:Add("uncommon")
petDropdown:Add("rare")
petDropdown:Add("epic")
petDropdown:Add("mythic")
petDropdown:Add("master")
petDropdown:Add("titan")

-- Switch to toggle the actual auto-buyer loop
eggtab:AddSwitch("Auto Buy Selected Egg", function(bool)
    getgenv().AutoBuyPet = bool
    if bool then
        task.spawn(autoBuyPetLoop)
    end
end)

local autosell = eggtab:AddFolder("Auto Sell Pets")

-- Single reusable function to handle selling any pet safely
local function createAutoSell(petName)
    autosell:AddSwitch("Auto Sell " .. petName, function(bool)
        task.spawn(function()
            while bool do
                local player = Players.LocalPlayer
                local petsFolder = player:FindFirstChild("PetsFolder")
                
                if petsFolder and petsFolder:FindFirstChild(petName) then
                    SellRequestRemote:FireServer(petsFolder[petName])
                end
                
                task.wait(1) -- 1-second delay to protect against network rate-limits
            end
        end)
    end)
end

-- Common Egg Section
autosell:AddLabel("Common Egg")
createAutoSell("Cat")
createAutoSell("Dog")
createAutoSell("Rabbit")
createAutoSell("Hamster")
createAutoSell("Shark")

-- Uncommon Egg Section
autosell:AddLabel("Uncommon Egg")
createAutoSell("Wolf")
createAutoSell("Fox")
createAutoSell("MuscleMan")
createAutoSell("Spike")
createAutoSell("Bear")

-- Rare Egg Section
autosell:AddLabel("Rare Egg")
createAutoSell("Snow Wolf")
createAutoSell("Forest Deer")
createAutoSell("Fire Pup")
createAutoSell("Shadow Wolf")
createAutoSell("Thunder Bear")

-- Epic Egg Section
autosell:AddLabel("Epic Egg")
createAutoSell("Spirit Wolf")
createAutoSell("Storm Tiger")
createAutoSell("Lunar Dragon")
createAutoSell("Crystal Dragon")

-- Mythic Egg Section
autosell:AddLabel("Mythic Egg")
createAutoSell("Pelican")
createAutoSell("Divine Dragon")
createAutoSell("Neon Divine Dragon")
createAutoSell("Space Dragon")

-- Master Egg Section
autosell:AddLabel("Master Egg")
createAutoSell("Red Alien")
createAutoSell("Fire Alien")
createAutoSell("Vortex")
createAutoSell("Astrax")

-- Titan Egg Section
autosell:AddLabel("Titan Egg")
createAutoSell("Roge Shark")
createAutoSell("Titan Crocodile")
createAutoSell("Battle Gorilla")
createAutoSell("Champion Dragon")

-- Creating the Tab and showing it
local MainTab = window:AddTab("Upgrade Evolutions")

-- Remote service caching to save memory and execution speed
local upgradeRemote = game:GetService("ReplicatedStorage").remotes.upgradeEvolution

-- Isang listahan ng lahat ng remote arguments na kailangang i-upgrade
local upgrades = {
    "fastliftUpgrade",
    "healthUpgrade",
    "damageUpgrade",
    "gainUpgrade",
    "petsgainUpgrade",
    "fastPunch",
    "stealChocolate",
    "chestReward"
}

-- Isang table para hawakan ang toggle states (Saves local registers!)
local states = {
    autoAll = false,
    fastliftUpgrade = false,
    healthUpgrade = false,
    damageUpgrade = false,
    gainUpgrade = false,
    petsgainUpgrade = false,
    fastPunch = false,
    stealChocolate = false,
    chestReward = false
}

-- Isang switch para sa lahat ng upgrades
MainTab:AddSwitch("Auto Upgrade All", function(bool)
    states.autoAll = bool
    if bool then
        task.spawn(function()
            while states.autoAll do
                -- Iikutan lahat ng nasa listahan nang sunod-sunod
                for _, upgradeName in ipairs(upgrades) do
                    if not states.autoAll then break end -- Huminto agad kapag pinatay ang switch
                    upgradeRemote:FireServer(upgradeName)
                    task.wait(0.1) -- Maikling patlang para hindi ma-rate limit ng server
                end
                task.wait(0.2) -- Break bago magsimula ulit ang susunod na round ng upgrades
            end
        end)
    end
end)

-- Switch for Fastlift Upgrade
MainTab:AddSwitch("Auto Upgrade Fastlift", function(bool)
    states.fastliftUpgrade = bool
    if bool then
        task.spawn(function()
            while states.fastliftUpgrade do
                upgradeRemote:FireServer("fastliftUpgrade")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Health Upgrade
MainTab:AddSwitch("Auto Upgrade Health", function(bool)
    states.healthUpgrade = bool
    if bool then
        task.spawn(function()
            while states.healthUpgrade do
                upgradeRemote:FireServer("healthUpgrade")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Damage Upgrade
MainTab:AddSwitch("Auto Upgrade Damage", function(bool)
    states.damageUpgrade = bool
    if bool then
        task.spawn(function()
            while states.damageUpgrade do
                upgradeRemote:FireServer("damageUpgrade")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Gain Upgrade
MainTab:AddSwitch("Auto Upgrade Strength Gain", function(bool)
    states.gainUpgrade = bool
    if bool then
        task.spawn(function()
            while states.gainUpgrade do
                upgradeRemote:FireServer("gainUpgrade")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Pets Gain Upgrade
MainTab:AddSwitch("Auto Upgrade Pets Gain", function(bool)
    states.petsgainUpgrade = bool
    if bool then
        task.spawn(function()
            while states.petsgainUpgrade do
                upgradeRemote:FireServer("petsgainUpgrade")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Fast Punch Upgrade
MainTab:AddSwitch("Auto Upgrade Fast Punch", function(bool)
    states.fastPunch = bool
    if bool then
        task.spawn(function()
            while states.fastPunch do
                upgradeRemote:FireServer("fastPunch")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Steal Chocolate Action
MainTab:AddSwitch("Auto Upgrade Steal Chocolate", function(bool)
    states.stealChocolate = bool
    if bool then
        task.spawn(function()
            while states.stealChocolate do
                upgradeRemote:FireServer("stealChocolate")
                task.wait(1)
            end
        end)
    end
end)

-- Switch for Chest Reward Claiming
MainTab:AddSwitch("Auto Upgrade Chest", function(bool)
    states.chestReward = bool
    if bool then
        task.spawn(function()
            while states.chestReward do
                upgradeRemote:FireServer("chestReward")
                task.wait(1)
            end
        end)
    end
end)

-- Create Only the Teleports Tab within the Window
local TeleportTab = window:AddTab("Teleport")

-- Teleport Helper Function
local function teleportTo(cframe)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = cframe
    end
end

-- ==========================================
-- TELEPORT BUTTONS (NO DROPDOWNS)
-- ==========================================

TeleportTab:AddButton("Spawn", function()
    teleportTo(CFrame.new(
        -15.0386581, 9.44794369, 99.5055084, 1, 0, 0, 0, 1, 0, 0, 0, 1
    ))
end)

TeleportTab:AddButton("Safe Zone 0-1M", function()
    teleportTo(CFrame.new(
        -259.966248, 9.57174969, 16.8054733, -0.0436196253, -2.76712946e-08, -0.999048233, 9.58031023e-08, 1, -3.1880532e-08, 0.999048233, -9.71025358e-08, -0.0436196253
    ))
end)

TeleportTab:AddButton("Frost Island", function()
    teleportTo(CFrame.new(
        1761.46106, 9.35956097, -93.4663086, 
        -0.0348993875, 5.71457583e-08, -0.999390841, 
        -5.23453991e-08, 1, 5.90085243e-08, 
        0.999390841, 5.43728724e-08, -0.0348993875
    ))
end)

TeleportTab:AddButton("Sunny Island", function()
    teleportTo(CFrame.new(
        3575.64819, 10.2205515, 294.568237, 
        -0.0610489473, 2.72128222e-08, -0.998134792, 
        6.09054851e-08, 1, 2.35385116e-08, 
        0.998134792, -5.93548819e-08, -0.0610489473
    ))
end)

TeleportTab:AddButton("Forest World", function()
    teleportTo(CFrame.new(
        -158.646683, 10.2202816, 2577.07324, 
        -0.999657333, 2.67622262e-08, -0.0261768159, 
        2.36446793e-08, 1, 1.62958873e-08, 
        0.0261768159, 1.56006834e-08, -0.999657333
    ))
end)

TeleportTab:AddButton("Volcano World", function()
    teleportTo(CFrame.new(
        -68.0123062, 11.4684992, 4312.91504, 
        -0.999657333, -4.12707273e-08, 0.0261769108, 
        -4.18838546e-08, 1, -2.28741524e-08, 
        -0.0261769108, -2.39627038e-08, -0.999657333
    ))
end)

TeleportTab:AddButton("Dumbbells World", function()
    teleportTo(CFrame.new(
        -1740.26685, 11.3567324, 368.174683, -1.19210611e-07, -4.05949896e-09, 1, 1.13882492e-09, 1, 4.05949896e-09, -1, 1.13882537e-09, -1.19210611e-07
    ))
end)

TeleportTab:AddButton("Titan Gym Island", function()
    teleportTo(CFrame.new(
        4994.79932, 10.5763903, 440.314362, -3.57627897e-07, -2.96512859e-08, -1, 6.53894432e-08, 1, -2.9651309e-08, 1, -6.53894574e-08, -3.57627897e-07
    ))
end)

TeleportTab:AddButton("Boss Boost", function()
    teleportTo(CFrame.new(
        299.65741, 9.64752197, 334.599731, 
        -0.017452199, 6.03341235e-08, -0.99984771, 
        9.62693747e-08, 1, 5.86629412e-08, 
        0.99984771, -9.52309165e-08, -0.017452199
    ))
end)

TeleportTab:AddButton("Arena Boost 18%", function()
    teleportTo(CFrame.new(
        -25.8208008, 10.4261885, 348.60202, 0.0174522307, -5.16945846e-08, 0.99984771, -2.01935868e-09, 1, 5.17377039e-08, -0.99984771, -2.92198954e-09, 0.0174522307
    ))
end)

TeleportTab:AddButton("Arena Boost 25%", function()
    teleportTo(CFrame.new(
        1878.20776, 10.6999903, 80.2840347, -0.186482161, 5.7147318e-08, 0.982458353, 6.40675495e-08, 1, -4.60068996e-08, -0.982458353, 5.43642358e-08, -0.186482161
    ))
end)

TeleportTab:AddButton("Arena Boost 35%", function()
    teleportTo(CFrame.new(
        3826.70874, 5.26375294, 396.468079, 0.16196236, -1.41390615e-08, -0.986796916, -5.28429958e-08, 1, -2.30013253e-08, 0.986796916, 5.58706539e-08, 0.16196236
    ))
end)

TeleportTab:AddButton("Arena Boost 50%", function()
    teleportTo(CFrame.new(
        -286.8013, 8.11831379, 2653.2207, -0.0839834884, -7.69802426e-08, 0.996467173, 9.08480402e-09, 1, 7.801885e-08, -0.996467173, 1.56050035e-08, -0.0839834884
    ))
end)

TeleportTab:AddButton("Arena Boost 100%", function()
    teleportTo(CFrame.new(
        -133.176849, 12.1300173, 4389.7373, -0.991407275, 3.56622243e-09, -0.130811229, 3.00160763e-09, 1, 4.51342563e-09, 0.130811229, 4.08199918e-09, -0.991407275
    ))
end)

TeleportTab:AddButton("Arena Boost 150%", function()
    teleportTo(CFrame.new(
        -1813.86853, 10.9312506, 330.79776, -0.122324601, -3.13583794e-12, 0.992490172, 1.07769482e-08, 1, 1.33142053e-09, -0.992490172, 1.08588809e-08, -0.122324601
    ))
end)

TeleportTab:AddButton("VIP Boost 185% REQUIRES VIP", function()
    teleportTo(CFrame.new(
        -271.105164, 8.02610493, 348.933441, -0.00368146622, 0, 0.999993205, 0, 1, 0, -0.999993205, 0, -0.00368146622
    ))
end)

TeleportTab:AddButton("Arena Boost 170%", function()
    teleportTo(CFrame.new(
        -199.092438, 10.9310827, 579.725098, -0.125456229, -1.90094318e-09, 0.992099166, -2.68448606e-08, 1, -1.47859391e-09, -0.992099166, -2.68182632e-08, -0.125456229
    ))
end)

TeleportTab:AddButton("Arena Boost 180%", function()
    teleportTo(CFrame.new(
        -333.675476, 10.9310884, 579.473816, -0.100714162, 0, 0.994915426, 0, 1, 0, -0.994915426, 0, -0.100714162
    ))
end)

TeleportTab:AddButton("Arena Boost 200%", function()
    teleportTo(CFrame.new(
        5265.54004, 10.9312038, 398.775513, 0.129527479, 1.35402258e-08, -0.991575837, 1.37851472e-08, 1, 1.54559849e-08, 0.991575837, -1.56709934e-08, 0.129527479
    ))
end)

TeleportTab:AddButton("Arena Boost 250%", function()
    teleportTo(CFrame.new(
        -466.660797, 10.9310513, 579.656128, -0.0815361142, 0, 0.996670365, 0, 1, 0, -0.996670365, 0, -0.0815361142
    ))
end)

TeleportTab:AddButton("Arena Boost 500%", function()
    teleportTo(CFrame.new(
        -657.036804, 10.9310274, 580.776672, -0.0987548307, 2.27731167e-09, 0.995111823, -1.31174605e-09, 1, -2.4186757e-09, -0.995111823, -1.54418989e-09, -0.0987548307
    ))
end)

TeleportTab:AddButton("Arena Boost 1000 %", function()
    teleportTo(CFrame.new(
        -910.248352, 10.8888636, 581.611511, -0.101835206, 0, 0.994801283, 0, 1, 0, -0.994801283, 0, -0.101835206
    ))
end)

---------------------------------------------------------
-- [SECTION 1: LOCAL PLAYER STATS TAB]
---------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    pcall(function() Players:GetPropertyChangedSignal("LocalPlayer"):Wait() end)
    LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
end

if _G.LocalTracker then _G.LocalTracker = nil end
_G.LocalTracker = {
    Config = {
        Stats = {"Strength", "Endurance", "Rebirths", "Gold", "Kills", "KillStreak", "Lifts", "BossTime", "Spins"},
        Suffixes = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "ODc", "NDc", "Vg"}
    },
    Labels = {},
    StartStats = {},
    CachedObjects = {},
    Connections = {},
    TotalGained = {},
    LastValues = {},
    Rates = {},
    LastUpdates = {},
    StartTime = os.time(),
    Utils = {}
}

_G.LocalTracker.Utils.updateLabelText = function(name, content)
    local label = _G.LocalTracker.Labels[name]
    if not label then return end
    local ok = pcall(function() label.Text = content end)
    if not ok then ok = pcall(function() label:SetText(content) end) end
    if not ok then pcall(function() label:UpdateLabel(content) end) end
end

_G.LocalTracker.Utils.formatNumber = function(value)
    if not value or typeof(value) ~= "number" then return "0" end
    local absVal = math.abs(value)
    if absVal < 1000 then 
        return tostring(value < 0 and -math.floor(absVal) or math.floor(absVal)) 
    end
    local index = math.floor(math.log10(absVal) / 3)
    if index > #_G.LocalTracker.Config.Suffixes then index = #_G.LocalTracker.Config.Suffixes end
    return string.format("%.1f", value / (10 ^ (index * 3))):gsub("%.0$", "") .. (_G.LocalTracker.Config.Suffixes[index] or "")
end

_G.LocalTracker.Utils.scanForStatFast = function(statName)
    if not LocalPlayer then return nil end
    local lowerTarget = string.lower(statName)
    local cleanTarget = lowerTarget:gsub("%s+", ""):gsub("_+", "")
    
    local function matches(name)
        local lName = string.lower(name)
        local cName = lName:gsub("%s+", ""):gsub("_+", "")
        return string.find(lName, lowerTarget) or cName == cleanTarget or string.find(cName, cleanTarget)
    end
    
    local classicHubs = {"leaderstats", "leaderstats2", "Stats", "PlayerData", "Data", "Currency"}
    for i = 1, #classicHubs do
        local folder = LocalPlayer:FindFirstChild(classicHubs[i])
        if folder then
            local children = folder:GetChildren()
            for j = 1, #children do
                local child = children[j]
                if matches(child.Name) and string.find(child.ClassName, "Value") then
                    return child
                end
            end
        end
    end

    local rootChildren = LocalPlayer:GetChildren()
    for i = 1, #rootChildren do
        local child = rootChildren[i]
        if matches(child.Name) and string.find(child.ClassName, "Value") then
            return child
        elseif child:IsA("Folder") or child:IsA("Configuration") then
            local subChildren = child:GetChildren()
            for j = 1, #subChildren do
                local subChild = subChildren[j]
                if matches(subChild.Name) and string.find(subChild.ClassName, "Value") then
                    return subChild
                end
            end
        end
    end
    
    return nil
end

_G.LocalTracker.Utils.computeAndRenderStat = function(name, currentVal)
    local currentTime = os.time()
    local startVal = _G.LocalTracker.StartStats[name]
    
    if not startVal then
        _G.LocalTracker.StartStats[name] = currentVal
        startVal = currentVal
        _G.LocalTracker.TotalGained[name] = 0
        _G.LocalTracker.LastValues[name] = currentVal
        _G.LocalTracker.LastUpdates[name] = currentTime
        _G.LocalTracker.Rates[name] = 0
    end
    
    _G.LocalTracker.TotalGained[name] = _G.LocalTracker.TotalGained[name] or 0
    _G.LocalTracker.LastValues[name] = _G.LocalTracker.LastValues[name] or currentVal
    _G.LocalTracker.LastUpdates[name] = _G.LocalTracker.LastUpdates[name] or currentTime
    _G.LocalTracker.Rates[name] = _G.LocalTracker.Rates[name] or 0

    if currentVal < _G.LocalTracker.LastValues[name] then
        local progressBeforeReset = math.max(_G.LocalTracker.LastValues[name] - startVal, 0)
        _G.LocalTracker.TotalGained[name] = _G.LocalTracker.TotalGained[name] + progressBeforeReset
        _G.LocalTracker.StartStats[name] = currentVal
        startVal = currentVal
    end

    local diff = currentVal - _G.LocalTracker.LastValues[name]
    if diff > 0 then
        local timePassed = math.max(currentTime - _G.LocalTracker.LastUpdates[name], 1)
        _G.LocalTracker.Rates[name] = diff / timePassed
        _G.LocalTracker.LastUpdates[name] = currentTime
    end
    
    _G.LocalTracker.LastValues[name] = currentVal

    local currentGain = math.max(currentVal - startVal, 0)
    local gained = _G.LocalTracker.TotalGained[name] + currentGain
    local formattedCurrent = _G.LocalTracker.Utils.formatNumber(currentVal)
    local activeRate = _G.LocalTracker.Rates[name] or 0
    
    if gained > 0 and activeRate > 0 then
        _G.LocalTracker.Utils.updateLabelText(name, string.format(
            "%s: %s (+%s) | M: %s | H: %s | D: %s | W: %s | MO: %s",
            name, formattedCurrent, _G.LocalTracker.Utils.formatNumber(gained),
            _G.LocalTracker.Utils.formatNumber(activeRate * 60), 
            _G.LocalTracker.Utils.formatNumber(activeRate * 3600), 
            _G.LocalTracker.Utils.formatNumber(activeRate * 86400), 
            _G.LocalTracker.Utils.formatNumber(activeRate * 604800),
            _G.LocalTracker.Utils.formatNumber(activeRate * 2592000)
        ))
    else
        _G.LocalTracker.Utils.updateLabelText(name, string.format("%s: %s (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0", name, formattedCurrent))
    end
end

_G.LocalTracker.Utils.bindObjectSignals = function(name, obj)
    _G.LocalTracker.CachedObjects[name] = obj
    _G.LocalTracker.StartStats[name] = tonumber(obj.Value) or 0
    _G.LocalTracker.LastValues[name] = tonumber(obj.Value) or 0
    _G.LocalTracker.TotalGained[name] = _G.LocalTracker.TotalGained[name] or 0
    _G.LocalTracker.LastUpdates[name] = os.time()
    _G.LocalTracker.Rates[name] = 0
    
    if _G.LocalTracker.Connections[name] then
        pcall(function() _G.LocalTracker.Connections[name]:Disconnect() end)
    end
    
    _G.LocalTracker.Connections[name] = obj.Changed:Connect(function(newVal)
        _G.LocalTracker.Utils.computeAndRenderStat(name, tonumber(newVal) or 0)
    end)
    
    _G.LocalTracker.Utils.computeAndRenderStat(name, _G.LocalTracker.StartStats[name])
end

_G.LocalTracker.TrackerTab = nil
pcall(function() _G.LocalTracker.TrackerTab = window:AddTab("Stats") end)

_G.LocalTracker.ClockLabel = _G.LocalTracker.TrackerTab and _G.LocalTracker.TrackerTab:AddLabel("Session Time: 00:00:00") or nil

for i = 1, #_G.LocalTracker.Config.Stats do
    local name = _G.LocalTracker.Config.Stats[i]
    _G.LocalTracker.StartStats[name] = 0
    
    local foundObj = _G.LocalTracker.Utils.scanForStatFast(name)
    local currentText = name .. ": 0 (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0"
    
    if foundObj then
        local initialVal = tonumber(foundObj.Value) or 0
        _G.LocalTracker.StartStats[name] = initialVal
        _G.LocalTracker.LastValues[name] = initialVal
        currentText = string.format("%s: %s (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0", name, _G.LocalTracker.Utils.formatNumber(initialVal))
    end
    
    if _G.LocalTracker.TrackerTab then
        pcall(function() _G.LocalTracker.Labels[name] = _G.LocalTracker.TrackerTab:AddLabel(currentText) end)
    end
    
    if foundObj then
        _G.LocalTracker.Utils.bindObjectSignals(name, foundObj)
    end
end

task.spawn(function()
    while task.wait(1) do
        local elapsedSeconds = math.max(os.time() - _G.LocalTracker.StartTime, 1)
        local currentTime = os.time()
        
        local hours = math.floor(elapsedSeconds / 3600)
        local minutes = math.floor((elapsedSeconds % 3600) / 60)
        local seconds = elapsedSeconds % 60
        if _G.LocalTracker.ClockLabel then
            pcall(function() _G.LocalTracker.ClockLabel.Text = string.format("Session Time: %02d:%02d:%02d", hours, minutes, seconds) end)
        end
        
        for i = 1, #_G.LocalTracker.Config.Stats do
            local name = _G.LocalTracker.Config.Stats[i]
            local obj = _G.LocalTracker.CachedObjects[name]
            if obj then
                local lastActive = _G.LocalTracker.LastUpdates[name] or currentTime
                if currentTime - lastActive > 60 then
                    _G.LocalTracker.Rates[name] = math.max((_G.LocalTracker.Rates[name] or 0) * 0.99, 0)
                    if _G.LocalTracker.Rates[name] < 0.001 then _G.LocalTracker.Rates[name] = 0 end
                    _G.LocalTracker.Utils.computeAndRenderStat(name, tonumber(obj.Value) or 0)
                end
            end
        end
    end
end)

---------------------------------------------------------
-- [SECTION 2: SHARED UTILITIES & CENTRAL CORES]
---------------------------------------------------------
do
    local PlayersRef = game:GetService("Players")
    local LocalPlayerRef = PlayersRef.LocalPlayer

    if not LocalPlayerRef then
        pcall(function() PlayersRef:GetPropertyChangedSignal("LocalPlayer"):Wait() end)
        LocalPlayerRef = PlayersRef.LocalPlayer or PlayersRef.PlayerAdded:Wait()
    end

    if _G.TrackerCore then _G.TrackerCore = nil end
    _G.TrackerCore = {
        Config = {
            Stats = {"Strength", "Endurance", "Rebirths", "Gold", "Kills", "KillStreak", "Lifts", "BossTime", "Spins"},
            Suffixes = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "ODc", "NDc", "Vg"}
        },
        SpyState = { target = nil, startTime = os.time(), labels = {}, start = {}, total = {}, last = {}, rate = {}, ticks = {} },
        Utils = {}
    }

    _G.TrackerCore.Utils.updateLabelText = function(label, content)
        if not label then return end
        local ok = pcall(function() label.Text = content end)
        if not ok then ok = pcall(function() label:SetText(content) end) end
        if not ok then pcall(function() label:UpdateLabel(content) end) end
    end

    _G.TrackerCore.Utils.formatNumber = function(value)
        if not value or typeof(value) ~= "number" then return "0" end
        local absVal = math.abs(value)
        if absVal < 1000 then 
            return tostring(value < 0 and -math.floor(absVal) or math.floor(absVal)) 
        end
        local index = math.floor(math.log10(absVal) / 3)
        if index > #_G.TrackerCore.Config.Suffixes then index = #_G.TrackerCore.Config.Suffixes end
        return string.format("%.1f", value / (10 ^ (index * 3))):gsub("%.0$", "") .. (_G.TrackerCore.Config.Suffixes[index] or "")
    end

    _G.TrackerCore.Utils.locatePlayerStatObject = function(playerInstance, statName)
        if not playerInstance then return nil end
        local lowerTarget = string.lower(statName)
        local cleanTarget = lowerTarget:gsub("%s+", ""):gsub("_+", "")
        
        local function matches(name)
            local lName = string.lower(name)
            local cName = lName:gsub("%s+", ""):gsub("_+", "")
            return string.find(lName, lowerTarget) or cName == cleanTarget or string.find(cName, cleanTarget)
        end
        
        local classicHubs = {"leaderstats", "leaderstats2", "Stats", "PlayerData", "Data", "Currency"}
        
        for i = 1, #classicHubs do
            local folder = playerInstance:FindFirstChild(classicHubs[i])
            if folder then
                local children = folder:GetChildren()
                for j = 1, #children do
                    local child = children[j]
                    if matches(child.Name) and string.find(child.ClassName, "Value") then
                        return child
                    end
                end
            end
        end

        local rootChildren = playerInstance:GetChildren()
        for i = 1, #rootChildren do
            local child = rootChildren[i]
            if matches(child.Name) and string.find(child.ClassName, "Value") then
                return child
            elseif child:IsA("Folder") or child:IsA("Configuration") then
                local subChildren = child:GetChildren()
                for j = 1, #subChildren do
                    local subChild = subChildren[j]
                    if matches(subChild.Name) and string.find(subChild.ClassName, "Value") then
                        return subChild
                    end
                end
            end
        end
        return nil
    end

    ---------------------------------------------------------
    -- [SECTION 3: SPY PLAYER INTERFACE FIELDS]
    ---------------------------------------------------------
    _G.TrackerCore.SpyTab = nil
    pcall(function() _G.TrackerCore.SpyTab = window:AddTab("Spy Stats") end)

    -- [[ SINGLE TARGET DROPDOWN ]]
    local singleTargetDropdown = _G.TrackerCore.SpyTab and _G.TrackerCore.SpyTab:AddDropdown("Select Player...", function(text)
        local S = _G.TrackerCore.SpyState
        if text == "None" or text == "" then
            S.target, S.start, S.total, S.last, S.rate, S.ticks = nil, {}, {}, {}, {}, {}
            return
        end
        
        local found = nil
        for _, p in ipairs(PlayersRef:GetPlayers()) do
            if p.DisplayName == text or p.Name == text then
                found = p
                break
            end
        end

        if found then
            S.target, S.startTime, S.start, S.total, S.last, S.rate, S.ticks = found, os.time(), {}, {}, {}, {}, {}
            local curT = os.time()
            for _, name in ipairs(_G.TrackerCore.Config.Stats) do
                local obj = _G.TrackerCore.Utils.locatePlayerStatObject(found, name)
                local val = obj and tonumber(obj.Value) or 0
                S.start[name], S.last[name], S.total[name], S.ticks[name], S.rate[name] = val, val, 0, curT, 0
            end
        else
            S.target = nil
        end
    end) or nil

    -- Function to refresh options for dropdowns dynamically (Display Name only)
    local function RefreshDropdowns()
        if not singleTargetDropdown then return end
        pcall(function()
            singleTargetDropdown:Add("None")
            for _, p in ipairs(PlayersRef:GetPlayers()) do
                if p ~= LocalPlayerRef then
                    singleTargetDropdown:Add(p.DisplayName)
                end
            end
        end)
    end

    RefreshDropdowns()

    PlayersRef.PlayerAdded:Connect(function(p)
        task.wait(1)
        if p ~= LocalPlayerRef and singleTargetDropdown then
            pcall(function()
                singleTargetDropdown:Add(p.DisplayName)
            end)
        end
    end)

    PlayersRef.PlayerRemoving:Connect(function(p)
        if _G.TrackerCore.SpyState.target == p then
            _G.TrackerCore.SpyState.target, _G.TrackerCore.SpyState.start, _G.TrackerCore.SpyState.total, _G.TrackerCore.SpyState.last, _G.TrackerCore.SpyState.rate, _G.TrackerCore.SpyState.ticks = nil, {}, {}, {}, {}, {}
        end
    end)

    if _G.TrackerCore.SpyTab then
        for _, name in ipairs(_G.TrackerCore.Config.Stats) do
            pcall(function() _G.TrackerCore.SpyState.labels[name] = _G.TrackerCore.SpyTab:AddLabel(name .. ": N/A (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0") end)
        end
    end

    ---------------------------------------------------------
    -- [SECTION 4: UNIFIED POLLED CALCULATION LOOP ENGINE]
    ---------------------------------------------------------
    task.spawn(function()
        while task.wait(0.5) do
            local currentTime = os.time()
            local S = _G.TrackerCore.SpyState
            
            if S.target and S.target.Parent == PlayersRef then
                for _, name in ipairs(_G.TrackerCore.Config.Stats) do
                    local statObj = _G.TrackerCore.Utils.locatePlayerStatObject(S.target, name)
                    if statObj and S.labels[name] then
                        local currentVal = tonumber(statObj.Value) or 0
                        if not S.start[name] then
                            S.start[name], S.last[name], S.total[name], S.ticks[name], S.rate[name] = currentVal, currentVal, 0, currentTime, 0
                        end

                        if currentVal < S.last[name] then
                            S.total[name] = S.total[name] + math.max(S.last[name] - S.start[name], 0)
                            S.start[name] = currentVal
                        end

                        local diff = currentVal - S.last[name]
                        if diff > 0 then
                            S.rate[name] = diff / math.max(currentTime - S.ticks[name], 1)
                            S.ticks[name] = currentTime
                        else
                            if currentTime - (S.ticks[name] or currentTime) > 60 then
                                S.rate[name] = math.max((S.rate[name] or 0) * 0.99, 0)
                                if S.rate[name] < 0.001 then S.rate[name] = 0 end
                            end
                        end
                        S.last[name] = currentVal

                        local gained = S.total[name] + math.max(currentVal - S.start[name], 0)
                        local r = S.rate[name] or 0
                        
                        if gained > 0 then
                            if r <= 0 then r = gained / math.max(currentTime - S.startTime, 1) end
                            _G.TrackerCore.Utils.updateLabelText(S.labels[name], string.format(
                                "%s: %s (+%s) | M: %s | H: %s | D: %s | W: %s | MO: %s",
                                name, _G.TrackerCore.Utils.formatNumber(currentVal), _G.TrackerCore.Utils.formatNumber(gained),
                                _G.TrackerCore.Utils.formatNumber(r * 60), 
                                _G.TrackerCore.Utils.formatNumber(r * 3600), 
                                _G.TrackerCore.Utils.formatNumber(r * 86400), 
                                _G.TrackerCore.Utils.formatNumber(r * 604800), 
                                _G.TrackerCore.Utils.formatNumber(r * 2592000)
                            ))
                        else
                            _G.TrackerCore.Utils.updateLabelText(S.labels[name], string.format("%s: %s (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0", name, _G.TrackerCore.Utils.formatNumber(currentVal)))
                        end
                    end
                end
            else
                for _, name in ipairs(_G.TrackerCore.Config.Stats) do
                    if S.labels[name] then
                        _G.TrackerCore.Utils.updateLabelText(S.labels[name], name .. ": N/A (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0")
                    end
                end
            end
        end
    end)
end

-- [[ MOVE TO TOP: Core Logic Variables ]]
local player = game.Players.LocalPlayer
local whitelistFriendsActive = false 
local TargetInput = ""         
local WhitelistedPlayers = {}        -- Dictionary mapping UserId -> true
local MultiInputText = ""          -- Stores the raw comma-separated text string

-- Added Label Variable Support for Elerium V2 Whitelist Display
local WhitelistDisplayLabel = nil

-- Target Kill List Variables
local TargetKillListActive = false  -- Toggle state for Loop TP Kill Target List
local TargetKillPlayers = {}        -- Dictionary mapping UserId -> true for target kill list
local SpyTargetKillListActive = false -- Toggle state for spying on the target kill list

-- Added Label Variable Support for Elerium V2 Kill List Display
local KillListDisplayLabel = nil

local LoopKillAllActive = false
local FastLoopKillAllV2Active = false
local LoopKilling = false
local Spectating = false

-- [[ MOVE TO TOP: Helper Function: Find Player by Partial Username OR Nickname/Display Name ]]
local function GetPlayerByInput(input)
    if not input or input == "" then return nil end
    local cleanInput = input:lower():match("^%s*(.-)%s*$") -- Clean leading/trailing spaces
    if cleanInput == "" then return nil end
    
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Name:lower():sub(1, #cleanInput) == cleanInput or p.DisplayName:lower():sub(1, #cleanInput) == cleanInput then
            return p
        end
    end
    return nil
end

-- [[ MOVE TO TOP: Helper Function: Update Whitelist List Label Text for Elerium V2 ]]
local function UpdateWhitelistLabel()
    if not WhitelistDisplayLabel then return end
    
    local displayNames = {}
    for userId, _ in pairs(WhitelistedPlayers) do
        local p = game.Players:GetPlayerByUserId(userId)
        if p then
            table.insert(displayNames, p.DisplayName)
        else
            table.insert(displayNames, tostring(userId))
        end
    end
    
    local finalString = "Whitelist: (Empty)"
    if #displayNames > 0 then
        finalString = "Whitelist: " .. table.concat(displayNames, ", ")
    end
    
    pcall(function()
        if type(WhitelistDisplayLabel) == "table" then
            if WhitelistDisplayLabel.Update then
                WhitelistDisplayLabel:Update(finalString)
            elseif WhitelistDisplayLabel.SetText then
                WhitelistDisplayLabel:SetText(finalString)
            elseif WhitelistDisplayLabel.Text then
                WhitelistDisplayLabel.Text = finalString
            end
        elseif typeof(WhitelistDisplayLabel) == "Instance" and WhitelistDisplayLabel:IsA("TextLabel") then
            WhitelistDisplayLabel.Text = finalString
        end
    end)
end

-- [[ MOVE TO TOP: Helper Function: Update Kill List Label Text for Elerium V2 ]]
local function UpdateKillListLabel()
    if not KillListDisplayLabel then return end
    
    local displayNames = {}
    for userId, _ in pairs(TargetKillPlayers) do
        local p = game.Players:GetPlayerByUserId(userId)
        if p then
            table.insert(displayNames, p.DisplayName)
        else
            table.insert(displayNames, tostring(userId))
        end
    end
    
    local finalString = "Kill List: (Empty)"
    if #displayNames > 0 then
        finalString = "Kill List: " .. table.concat(displayNames, ", ")
    end
    
    pcall(function()
        if type(KillListDisplayLabel) == "table" then
            if KillListDisplayLabel.Update then
                KillListDisplayLabel:Update(finalString)
            elseif KillListDisplayLabel.SetText then
                KillListDisplayLabel:SetText(finalString)
            elseif KillListDisplayLabel.Text then
                KillListDisplayLabel.Text = finalString
            end
        elseif typeof(KillListDisplayLabel) == "Instance" and KillListDisplayLabel:IsA("TextLabel") then
            KillListDisplayLabel.Text = finalString
        end
    end)
end

-- [[ MOVE TO TOP: Helper Function: Check Whitelist / Friend Status ]]
local function isWhitelisted(otherPlayer)
    if not otherPlayer then return false end
    
    if WhitelistedPlayers[otherPlayer.UserId] then
        return true
    end
    
    if whitelistFriendsActive then
        local success, result = pcall(function()
            return player:IsFriendsWith(otherPlayer.UserId)
        end)
        if success and result then return true end
    end
    
    return false
end

-- Create tab after vars are ready
local Tab = window:AddTab("Auto Kill") -- Name of tab

Tab:AddButton("Server Hop + Auto Kill", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/IVRzHxZ/Farming-Auto-KIll-in-xKyo/refs/heads/main/farmkillsxkyo"))()
end)

Tab:AddButton("Kill Counter", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/MBzGQAVW"))()
end)

-- [[ UI Elements Setup ]]

Tab:AddSwitch("Loop TP Auto Kill All", function(Value)
    LoopKillAllActive = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            
            while LoopKillAllActive do
                local myChar = player.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myChar and myRoot and myHumanoid then
                    local targetList = game.Players:GetPlayers()
                    
                    for _, targetPlayer in ipairs(targetList) do
                        if not LoopKillAllActive then break end
                        
                        if targetPlayer ~= player and targetPlayer.Character and not isWhitelisted(targetPlayer) then
                            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local timeSpent = 0
                            
                            while LoopKillAllActive and tRoot and targetPlayer.Parent == game.Players and timeSpent < 0.5 do
                                myChar = player.Character
                                myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                                
                                if not (myChar and myRoot and myHumanoid) then break end
                                
                                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                                
                                local tool = myChar:FindFirstChild("Punch")
                                if not tool then
                                    local backpack = player:FindFirstChild("Backpack")
                                    local bpTool = backpack and backpack:FindFirstChild("Punch")
                                    if bpTool then
                                        myHumanoid:EquipTool(bpTool)
                                        tool = bpTool
                                    end
                                end
                                
                                if tool then
                                    tool:Activate()
                                end
                                
                                local remotes = ReplicatedStorage:FindFirstChild("RemotesEvent")
                                if remotes and remotes:FindFirstChild("SizeChanged") then
                                    remotes.SizeChanged:FireServer(1)
                                end
                                
                                task.wait(0.05)
                                timeSpent = timeSpent + 0.05 
                            end
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

Tab:AddSwitch("Loop TP Auto Kill All V2", function(Value)
    FastLoopKillAllV2Active = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            
            while FastLoopKillAllV2Active do
                local myChar = player.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myChar and myRoot and myHumanoid then
                    local targetList = game.Players:GetPlayers()
                    
                    for _, targetPlayer in ipairs(targetList) do
                        if not FastLoopKillAllV2Active then break end
                        
                        if targetPlayer ~= player and targetPlayer.Character and not isWhitelisted(targetPlayer) then
                            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local tHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                            
                            if tRoot and tHumanoid and tHumanoid.Health > 0 then
                                for _ = 1, 3 do
                                    if not FastLoopKillAllV2Active or tHumanoid.Health <= 0 then break end
                                    
                                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                                    
                                    local tool = myChar:FindFirstChild("Punch")
                                    if not tool then
                                        local backpack = player:FindFirstChild("Backpack")
                                        local bpTool = backpack and backpack:FindFirstChild("Punch")
                                        if bpTool then
                                            myHumanoid:EquipTool(bpTool)
                                            tool = bpTool
                                        end
                                    end
                                    
                                    if tool then
                                        tool:Activate()
                                    end
                                    
                                    local remotes = ReplicatedStorage:FindFirstChild("RemotesEvent")
                                    if remotes and remotes:FindFirstChild("SizeChanged") then
                                        pcall(function()
                                            remotes.SizeChanged:FireServer(1)
                                        end)
                                    end
                                    
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)

-- [[ SINGLE TARGET DROPDOWN ]]
local singleTargetDropdown = Tab:AddDropdown("Target Player", function(text)
    TargetInput = text
end)

-- Function to refresh options for dropdowns dynamically (Display Name only)
local function RefreshDropdowns()
    pcall(function()
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= player then
                singleTargetDropdown:Add(p.DisplayName)
            end
        end
    end)
end

RefreshDropdowns()

game.Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    if p ~= player then
        singleTargetDropdown:Add(p.DisplayName)
    end
end)

Tab:AddSwitch("TP Kill Target", function(state)
    LoopKilling = state
    if LoopKilling then
        task.spawn(function()
            while LoopKilling do
                local target = GetPlayerByInput(TargetInput)
                
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and 
                    player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    
                    player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    
                    local tool = player.Character:FindFirstChild("Punch")
                    if not tool then
                        local backpackTool = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Punch")
                        if backpackTool then
                            player.Character.Humanoid:EquipTool(backpackTool)
                            tool = backpackTool
                        end
                    end
                    
                    if tool then
                        tool:Activate() 
                    end
                end
                task.wait(0.01) 
            end
        end)
    end
end)

Tab:AddSwitch("Spy Target", function(state)
    Spectating = state
    local camera = workspace.CurrentCamera
    
    if state then
        task.spawn(function()
            while Spectating do
                local target = GetPlayerByInput(TargetInput)
                if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = target.Character.Humanoid
                else
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = player.Character.Humanoid
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    end
end)

Tab:AddLabel("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

-- [[ UPDATED: Target Kill List Features ]]

-- Kill List UI Label Display (Elerium V2)
KillListDisplayLabel = Tab:AddLabel("Kill List: (Empty)")

-- [[ ADD TO TARGET KILL LIST DROPDOWN ]]
local targetKillDropdown = Tab:AddDropdown("Add To Target Kill List", function(text)
    local target = GetPlayerByInput(text)
    if target then
        TargetKillPlayers[target.UserId] = true
        print("[TARGET KILL LIST] Added: " .. target.Name .. " (" .. target.DisplayName .. ")")
        UpdateKillListLabel()
    end
end)

-- Function to refresh target kill dropdown options dynamically (Display Name only)
local function RefreshTargetKillDropdown()
    pcall(function()
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= player then
                targetKillDropdown:Add(p.DisplayName)
            end
        end
    end)
end

RefreshTargetKillDropdown()

game.Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    if p ~= player then
        targetKillDropdown:Add(p.DisplayName)
    end
end)

Tab:AddButton("Clear All Target Kill List", function()
    TargetKillPlayers = {}
    print("[TARGET KILL LIST] Target Kill List cleared completely.")
    UpdateKillListLabel()
end)

Tab:AddSwitch("TP Kill Target List", function(Value)
    TargetKillListActive = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            
            while TargetKillListActive do
                local myChar = player.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myChar and myRoot and myHumanoid then
                    for userId, _ in pairs(TargetKillPlayers) do
                        if not TargetKillListActive then break end
                        
                        local targetPlayer = game.Players:GetPlayerByUserId(userId)
                        
                        if targetPlayer and targetPlayer ~= player and targetPlayer.Character and not isWhitelisted(targetPlayer) then
                            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local tHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                            local timeSpent = 0
                            
                            while TargetKillListActive and tRoot and tHumanoid and tHumanoid.Health > 0 and targetPlayer.Parent == game.Players and timeSpent < 0.5 do
                                myChar = player.Character
                                myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                                
                                if not (myChar and myRoot and myHumanoid) then break end
                                
                                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                                
                                local tool = myChar:FindFirstChild("Punch")
                                if not tool then
                                    local backpack = player:FindFirstChild("Backpack")
                                    local bpTool = backpack and backpack:FindFirstChild("Punch")
                                    if bpTool then
                                        myHumanoid:EquipTool(bpTool)
                                        tool = bpTool
                                    end
                                end
                                
                                if tool then
                                    tool:Activate()
                                end
                                
                                local remotes = ReplicatedStorage:FindFirstChild("RemotesEvent")
                                if remotes and remotes:FindFirstChild("SizeChanged") then
                                    pcall(function()
                                        remotes.SizeChanged:FireServer(1)
                                    end)
                                end
                                
                                task.wait(0.05)
                                timeSpent = timeSpent + 0.05
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

Tab:AddSwitch("Spy Target Kill List", function(state)
    SpyTargetKillListActive = state
    local camera = workspace.CurrentCamera
    
    if state then
        task.spawn(function()
            while SpyTargetKillListActive do
                local foundTarget = false
                for userId, _ in pairs(TargetKillPlayers) do
                    if not SpyTargetKillListActive then break end
                    local targetPlayer = game.Players:GetPlayerByUserId(userId)
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
                        camera.CameraSubject = targetPlayer.Character.Humanoid
                        foundTarget = true
                        task.wait(3) 
                    end
                end
                
                if not foundTarget then
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = player.Character.Humanoid
                    end
                    task.wait(1)
                end
            end
        end)
    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    end
end)

local function getNil(name, class) 
    for _, v in pairs(getnilinstances()) do 
        if v.ClassName == class and v.Name == name then 
            return v
        end 
    end 
end

local function firePunch()
    local args = {
        "RightHand"
    }
    game:GetService("ReplicatedStorage").remotes.punchRequest:FireServer(unpack(args))
end

local autoPunchEnabled = false
Tab:AddSwitch("Auto Punch (No Anim)", function(state)
    autoPunchEnabled = state
    
    task.spawn(function()
        while autoPunchEnabled do
            firePunch()
            task.wait(0.1)
        end
    end)
end)

local AutoPunchActive = false

Tab:AddSwitch("Auto Punch", function(Value)
    AutoPunchActive =Value
    local player = game.Players.LocalPlayer
    
    if Value then
        task.spawn(function()
            while AutoPunchActive do
                local char = player.Character
                local backpack = player:FindFirstChild("Backpack")
                local tool = char and char:FindFirstChild("Punch")
                
                if not tool and backpack then
                    local bpTool = backpack:FindFirstChild("Punch")
                    if bpTool then
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:EquipTool(bpTool)
                        end
                    end
                end
                
                if char and char:FindFirstChild("Punch") then
                    char.Punch:Activate()
                end
                
                task.wait(0.1) 
            end
        end)
    end
end)

_G.HeadSize = 25
_G.HitboxEnabled = false 

Tab:AddSwitch("Kill Aura Range", function(Value)
    _G.HitboxEnabled = Value
    
    if not Value then
        for _, v in pairs(game:GetService('Players'):GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1) 
                v.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)

game:GetService('RunService').RenderStepped:Connect(function()
    if _G.HitboxEnabled then
        for _, v in pairs(game:GetService('Players'):GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = v.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                    hrp.Transparency = 0.7 
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end)
            end
        end
    end
end)

local whitelistSwitch = Tab:AddSwitch("Whitelist Friends", function(bool)
    whitelistFriendsActive = bool
end)
if whitelistSwitch and whitelistSwitch.Set then whitelistSwitch:Set(false) end

Tab:AddLabel("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

-- [[ UPDATED: Whitelist List Features ]]

-- Whitelist UI Label Display (Elerium V2)
WhitelistDisplayLabel = Tab:AddLabel("Whitelist: (Empty)")

Tab:AddTextBox("Type Name Player To Whitelist", function(text)
    MultiInputText = text
end, {
    ["placeholder"] = "e.g. builderman, roblox, player3",
    ["clear"] = false
})

Tab:AddButton("Add Whitelist Players", function()
    if MultiInputText == "" then 
        print("[WHITELIST] Text box is empty!")
        return 
    end
    
    for nameSegment in string.gmatch(MultiInputText, "([^,]+)") do
        local target = GetPlayerByInput(nameSegment)
        if target then
            WhitelistedPlayers[target.UserId] = true
            print("[WHITELIST] Added: " + target.Name + " (" + target.DisplayName + ")")
        else
            local cleanName = nameSegment:match("^%s*(.-)%s*$")
            print("[WHITELIST] Could not find player: '" + cleanName + "'")
        end
    end
    UpdateWhitelistLabel()
end)

Tab:AddButton("Clear All Whitelist", function()
    WhitelistedPlayers = {}
    print("[WHITELIST] Whitelist cleared completely.")
    UpdateWhitelistLabel()
end)

Tab:AddLabel("~~~Auto Kill V2~~~")

-- ============================================================================
-- GLOBAL STATE & SERVICES
-- ============================================================================
_G.autokillall, _G.autokillall2, _G.autokilltarget, _G.autokilltargetlist = false, false, false, false
_G.SingleTargetName, _G.FriendsWhitelistActive, _G.SpectateTargetActive, _G.SpectateTargetListActive = "", false, false, false
_G.whitelistTable, _G.targetKillListTable, _G.friendsCache, _G.activeThreads = {}, {}, {}, {} 
_G.whitelistInputTextCache = "" 

_G.PlayersService = game:GetService("Players")
_G.RunService = game:GetService("RunService")
_G.MyLocalPlayer = _G.PlayersService.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global reference variables for Elerium V2 display labels and dropdowns
local KillListDisplayLabel = nil
local WhitelistDisplayLabel = nil
local targetKillDropdown = nil
local singleTargetDropdown = nil

-- ============================================================================
-- BACKGROUND ASYNC FRIENDS CACHING FRAMEWORK
-- ============================================================================
function updateFriendsCache()
    if not _G.FriendsWhitelistActive then table.clear(_G.friendsCache); return end
    for _, player in ipairs(_G.PlayersService:GetPlayers()) do
        if player ~= _G.MyLocalPlayer and not _G.friendsCache[player.UserId] then
            task.spawn(function()
                local success, isFriend = pcall(function() return _G.MyLocalPlayer:IsFriendsWithAsync(player.UserId) end)
                if success and isFriend then _G.friendsCache[player.UserId] = true end
            end)
        end
    end
end

_G.PlayersService.PlayerAdded:Connect(function(player)
    if _G.FriendsWhitelistActive then
        local success, isFriend = pcall(function() return _G.MyLocalPlayer:IsFriendsWithAsync(player.UserId) end)
        if success and isFriend then _G.friendsCache[player.UserId] = true end
    end
    task.wait(1)
    pcall(function()
        if player ~= _G.MyLocalPlayer then
            if singleTargetDropdown and singleTargetDropdown.Add then
                singleTargetDropdown:Add(player.DisplayName)
            end
            if targetKillDropdown and targetKillDropdown.Add then
                targetKillDropdown:Add(player.DisplayName)
            end
        end
    end)
end)

_G.PlayersService.PlayerRemoving:Connect(function(player)
    _G.friendsCache[player.UserId] = nil; _G.activeThreads[player.UserId] = nil
end)

task.spawn(function()
    while true do
        if _G.FriendsWhitelistActive then updateFriendsCache() end
        task.wait(3)
    end
end)

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
function isAliveAndValid(player)
    if not player or not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    return (hum and hum.Health > 0 and root) and true or false
end

function teleportToMe(targetPlayer, targetLocalPlayer)
    if not isAliveAndValid(targetPlayer) then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
    local myRoot = targetLocalPlayer.Character and (targetLocalPlayer.Character:FindFirstChild("HumanoidRootPart") or targetLocalPlayer.Character:FindFirstChild("Torso"))
    if not targetRoot or not myRoot then return end
    
    pcall(function() targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3) end)
end

function isPlayerWhitelisted(targetPlayer, targetLocalPlayer)
    if not targetPlayer or targetPlayer == targetLocalPlayer then return true end
    local targetNameLower = targetPlayer.Name:lower()
    local targetDisplayLower = targetPlayer.DisplayName:lower()
    if table.find(_G.whitelistTable, targetNameLower) or table.find(_G.whitelistTable, targetDisplayLower) then return true end
    return (_G.FriendsWhitelistActive and _G.friendsCache[targetPlayer.UserId]) and true or false
end

function isPlayerOnTargetList(targetPlayer)
    if not targetPlayer then return false end
    local targetNameLower = targetPlayer.Name:lower()
    local targetDisplayLower = targetPlayer.DisplayName:lower()
    for _, entry in ipairs(_G.targetKillListTable) do
        if targetNameLower:find(entry) or targetDisplayLower:find(entry) then
            return true
        end
    end
    return false
end

local function resetCamera()
    if _G.MyLocalPlayer.Character then
        local hum = _G.MyLocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
    end
end

-- ============================================================================
-- HELPER: UPDATE KILL LIST LABEL TEXT FOR ELERIUM V2 (NO DUPLICATES)
-- ============================================================================
local function UpdateKillListLabelText()
    if not KillListDisplayLabel then return end
    
    local addedNames = {}
    local displayNames = {}
    
    for _, entry in ipairs(_G.targetKillListTable) do
        local foundName = entry
        for _, player in ipairs(_G.PlayersService:GetPlayers()) do
            if player.Name:lower() == entry or player.DisplayName:lower() == entry then
                foundName = player.DisplayName
                break
            end
        end
        
        if not addedNames[foundName] then
            addedNames[foundName] = true
            table.insert(displayNames, foundName)
        end
    end
    
    local finalString = "Kill List: (Empty)"
    if #displayNames > 0 then
        finalString = "Kill List: " .. table.concat(displayNames, ", ")
    end
    
    pcall(function()
        if type(KillListDisplayLabel) == "table" then
            if KillListDisplayLabel.Update then
                KillListDisplayLabel:Update(finalString)
            elseif KillListDisplayLabel.SetText then
                KillListDisplayLabel:SetText(finalString)
            elseif KillListDisplayLabel.Text then
                KillListDisplayLabel.Text = finalString
            end
        elseif typeof(KillListDisplayLabel) == "Instance" and KillListDisplayLabel:IsA("TextLabel") then
            KillListDisplayLabel.Text = finalString
        end
    end)
end

-- ============================================================================
-- HELPER: UPDATE WHITELIST LABEL TEXT FOR ELERIUM V2 (NO DUPLICATES)
-- ============================================================================
local function UpdateWhitelistLabelText()
    if not WhitelistDisplayLabel then return end
    
    local addedNames = {}
    local displayNames = {}
    
    for _, entry in ipairs(_G.whitelistTable) do
        local foundName = entry
        for _, player in ipairs(_G.PlayersService:GetPlayers()) do
            if player.Name:lower() == entry or player.DisplayName:lower() == entry then
                foundName = player.DisplayName
                break
            end
        end
        
        if not addedNames[foundName] then
            addedNames[foundName] = true
            table.insert(displayNames, foundName)
        end
    end
    
    local finalString = "Whitelist: (Empty)"
    if #displayNames > 0 then
        finalString = "Whitelist: " .. table.concat(displayNames, ", ")
    end
    
    pcall(function()
        if type(WhitelistDisplayLabel) == "table" then
            if WhitelistDisplayLabel.Update then
                WhitelistDisplayLabel:Update(finalString)
            elseif WhitelistDisplayLabel.SetText then
                WhitelistDisplayLabel:SetText(finalString)
            elseif WhitelistDisplayLabel.Text then
                WhitelistDisplayLabel.Text = finalString
            end
        elseif typeof(WhitelistDisplayLabel) == "Instance" and WhitelistDisplayLabel:IsA("TextLabel") then
            WhitelistDisplayLabel.Text = finalString
        end
    end)
end

-- ============================================================================
-- SPECTATE TRACKING ENGINE
-- ============================================================================
task.spawn(function()
    while true do
        if _G.SpectateTargetActive and _G.SingleTargetName ~= "" then
            local searchString = _G.SingleTargetName:lower()
            local targetFound = false
            
            for _, player in ipairs(_G.PlayersService:GetPlayers()) do
                if player ~= _G.MyLocalPlayer then
                    local userMatch = player.Name:lower():find(searchString)
                    local nickMatch = player.DisplayName:lower():find(searchString)
                    
                    if (userMatch or nickMatch) then
                        targetFound = true
                        if player.Character then
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            if hum then
                                Camera.CameraSubject = hum
                            else
                                Camera.CameraSubject = player.Character
                            end
                        end
                        break
                    end
                end
            end
            
            if not targetFound then
                resetCamera()
            end
            
        elseif _G.SpectateTargetListActive and #_G.targetKillListTable > 0 then
            local targetFound = false
            for _, player in ipairs(_G.PlayersService:GetPlayers()) do
                if player ~= _G.MyLocalPlayer and isPlayerOnTargetList(player) then
                    targetFound = true
                    if player.Character then
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            Camera.CameraSubject = hum
                        else
                            Camera.CameraSubject = player.Character
                        end
                    else
                        Camera.CameraSubject = player
                    end
                    break
                end
            end
            if not targetFound then
                resetCamera()
            end
        end
        _G.RunService.Heartbeat:Wait()
    end
end)

-- ============================================================================
-- AUTOMATED WEAPON ENGINE & MAIN ATTACK LOOP
-- ============================================================================
task.spawn(function()
    while true do
        if (_G.autokillall or _G.autokillall2 or _G.autokilltarget or _G.autokilltargetlist) and _G.MyLocalPlayer and _G.MyLocalPlayer.Character then
            local char = _G.MyLocalPlayer.Character
            local tool = char:FindFirstChild("Punch") or (_G.MyLocalPlayer:FindFirstChild("Backpack") and _G.MyLocalPlayer.Backpack:FindFirstChild("Punch"))
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if tool and hum and hum.Health > 0 then
                if not char:FindFirstChild("Punch") then hum:EquipTool(tool) end
                if char:FindFirstChild("Punch") then char.Punch:Activate() end
            end
            
            if _G.autokilltargetlist then
                for _, player in ipairs(_G.PlayersService:GetPlayers()) do
                    if player ~= _G.MyLocalPlayer and not isPlayerWhitelisted(player, _G.MyLocalPlayer) then
                        if isPlayerOnTargetList(player) and isAliveAndValid(player) then
                            teleportToMe(player, _G.MyLocalPlayer)
                        end
                    end
                end
            elseif _G.autokilltarget and _G.SingleTargetName ~= "" then
                local searchString = _G.SingleTargetName:lower()
                for _, player in ipairs(_G.PlayersService:GetPlayers()) do
                    if player ~= _G.MyLocalPlayer and not isPlayerWhitelisted(player, _G.MyLocalPlayer) then
                        if player.Name:lower():find(searchString) or player.DisplayName:lower():find(searchString) then
                            if isAliveAndValid(player) then
                                teleportToMe(player, _G.MyLocalPlayer)
                            end
                        end
                    end
                end
            elseif _G.autokillall or _G.autokillall2 then
                for _, player in ipairs(_G.PlayersService:GetPlayers()) do
                    if not isPlayerWhitelisted(player, _G.MyLocalPlayer) and isAliveAndValid(player) then
                        if _G.autokillall2 then
                            if not _G.activeThreads[player.UserId] then
                                _G.activeThreads[player.UserId] = true
                                
                                local startTime = tick()
                                while tick() - startTime < 1 do
                                    if not _G.autokillall2 or not isAliveAndValid(player) then break end
                                    teleportToMe(player, _G.MyLocalPlayer)
                                    
                                    local activeChar = _G.MyLocalPlayer.Character
                                    if activeChar then
                                        local activeTool = activeChar:FindFirstChild("Punch")
                                        if activeTool then
                                            activeTool:Activate()
                                        end
                                    end
                                    
                                    task.wait(0.05)
                                end
                                
                                _G.activeThreads[player.UserId] = nil
                            end
                        else
                            teleportToMe(player, _G.MyLocalPlayer)
                        end
                    end
                end
            end
        end
        _G.RunService.Heartbeat:Wait() 
    end
end)

-- ============================================================================
-- UI COMPONENTS
-- ============================================================================
Tab:AddSwitch("Auto Kill All", function(state) _G.autokillall = state end)
Tab:AddSwitch("Auto Kill All V2", function(state) _G.autokillall2 = state; if not state then table.clear(_G.activeThreads) end end)

singleTargetDropdown = Tab:AddDropdown("Target Player Auto Kill Target", function(text)
    _G.SingleTargetName = text
end)

Tab:AddSwitch("Auto Kill Target", function(state) _G.autokilltarget = state end)

Tab:AddSwitch("Spy Target", function(state) 
    _G.SpectateTargetActive = state 
    if not state then 
        resetCamera() 
    end 
end)

Tab:AddLabel("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

-- Kill List Display Label setup for Elerium V2
KillListDisplayLabel = Tab:AddLabel("Kill List: (Empty)")

targetKillDropdown = Tab:AddDropdown("Add To Target Kill List", function(text)
    if text and text ~= "" then
        local searchInput = text:lower():gsub("%s+", "")
        local playerFound = false
        
        for _, player in ipairs(_G.PlayersService:GetPlayers()) do
            local actualUsername = player.Name:lower()
            local actualDisplayName = player.DisplayName:lower()
            
            if actualUsername:find(searchInput) or actualDisplayName:find(searchInput) then
                playerFound = true
                if not table.find(_G.targetKillListTable, actualUsername) then
                    table.insert(_G.targetKillListTable, actualUsername)
                end
                if not table.find(_G.targetKillListTable, actualDisplayName) then
                    table.insert(_G.targetKillListTable, actualDisplayName)
                end
                print("Added to Target Kill List: " .. player.Name .. " (@" .. player.DisplayName .. ")")
            end
        end
        
        if not playerFound then
            if not table.find(_G.targetKillListTable, searchInput) then
                table.insert(_G.targetKillListTable, searchInput)
                print("Added Offline Tag/Name to Target Kill List: " .. searchInput)
            else
                print("Name is already inside the Target Kill List.")
            end
        end
        UpdateKillListLabelText()
    else
        print("Error: Target Kill Dropdown selection is empty!")
    end
end)

Tab:AddButton("Clear All Target Kill List", function()
    table.clear(_G.targetKillListTable)
    print("Target Kill List cleared completely.")
    UpdateKillListLabelText()
end)

Tab:AddSwitch("Auto Kill Target List", function(state) _G.autokilltargetlist = state end)

Tab:AddSwitch("Spy Target List", function(state) 
    _G.SpectateTargetListActive = state 
    if not state then 
        resetCamera() 
    end 
end)

Tab:AddSwitch("Whitelist Friends", function(state) _G.FriendsWhitelistActive = state; if state then updateFriendsCache() else table.clear(_G.friendsCache) end end)

Tab:AddLabel("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

-- Whitelist Display Label setup for Elerium V2
WhitelistDisplayLabel = Tab:AddLabel("Whitelist: (Empty)")

Tab:AddTextBox("Type Player Name To Whitelist", function(text)
    _G.whitelistInputTextCache = text
end, {["clear"] = false})

Tab:AddButton("Add Whitelist Player", function()
    if _G.whitelistInputTextCache and _G.whitelistInputTextCache ~= "" then
        local searchInput = _G.whitelistInputTextCache:lower():gsub("%s+", "")
        local playerFound = false
        
        for _, player in ipairs(_G.PlayersService:GetPlayers()) do
            local actualUsername = player.Name:lower()
            local actualDisplayName = player.DisplayName:lower()
            
            if actualUsername:find(searchInput) or actualDisplayName:find(searchInput) then
                playerFound = true
                if not table.find(_G.whitelistTable, actualUsername) then
                    table.insert(_G.whitelistTable, actualUsername)
                end
                if not table.find(_G.whitelistTable, actualDisplayName) then
                    table.insert(_G.whitelistTable, actualDisplayName)
                end
                print("Successfully Whitelisted: " .. player.Name .. " (@" .. player.DisplayName .. ")")
            end
        end
        
        if not playerFound then
            if not table.find(_G.whitelistTable, searchInput) then
                table.insert(_G.whitelistTable, searchInput)
                print("Whitelisted Offline Tag/Name: " .. searchInput)
            else
                print("Name is already inside the whitelist framework.")
            end
        end
        UpdateWhitelistLabelText()
    else
        print("Error: Whitelist TextBox is empty! Type a name first.")
    end
end)

Tab:AddButton("Clear All Whitelist", function()
    table.clear(_G.whitelistTable)
    print("Whitelist cleared completely.")
    UpdateWhitelistLabelText()
end)

-- Populate options into dropdowns for current online players (Display Name only)
task.spawn(function()
    task.wait(1)
    pcall(function()
        for _, player in ipairs(_G.PlayersService:GetPlayers()) do
            if player ~= _G.MyLocalPlayer then
                if singleTargetDropdown and singleTargetDropdown.Add then
                    singleTargetDropdown:Add(player.DisplayName)
                end
                if targetKillDropdown and targetKillDropdown.Add then
                    targetKillDropdown:Add(player.DisplayName)
                end
            end
        end
    end)
end)

local Tab = window:AddTab("Misc") -- Name of tab

local misc = Tab:AddFolder("Misc 1")

misc:AddButton("Stats Changer", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Lrjy9D3B"))()
end)

-- 4. Server Hop Function Definition
local function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local placeId = game.PlaceId
    local serversUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversUrl))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            -- Ensure the server has room and isn't the one you are currently in
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                end)
                return -- Stop executing once teleport is initiated
            end
        end
        print("❌ No alternative public servers found.")
    else
        warn("⚠️ Failed to fetch server list. Retrying native teleport...")
        -- Fallback: basic teleport if API lookup is blocked or rate-limited
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end
end

-- 5. Add the Server Hop Button to Elerium
misc:AddButton("Server Hop", function()
    print("🔄 Initializing Server Hop...")
    serverHop()
end)

-- 4. Rejoin Function Definition
local function rejoinServer()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local placeId = game.PlaceId
    local jobId = game.JobId

    -- If there's only 1 player in the server, a standard Teleport works best as a fallback
    if #Players:GetPlayers() <= 1 then
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    else
        -- Force a teleport directly back into the current active server instance
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
        end)
    end
end

-- 5. Add the Rejoin Button to Elerium
misc:AddButton("Rejoin Server", function()
    print("🔄 Reconnecting to current server...")
    rejoinServer()
end)

misc:AddButton("Emotes", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
end)

misc:AddButton("Jerk Tool (R15)", function()
    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
end)

misc:AddButton("Fly GUI V3", function()
    -- This executes the external Fly GUI script when the button is clicked
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)

local ClickTPEnabled = false
local Mouse = game.Players.LocalPlayer:GetMouse()
-- Changed AddToggle to AddSwitch
misc:AddSwitch("Click Teleport", function(Value)
    ClickTPEnabled = Value
end)

Mouse.Button1Down:Connect(function()
    if ClickTPEnabled then
        local character = game.Players.LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)

misc:AddLabel("~~~~~~~~~~~~~")

-- Configuration variables
local JumpModEnabled = false
local TargetPower = 50
local TargetHeight = 7.2
local Player = game.Players.LocalPlayer

-- AddSwitch using proper structural framework
local SwitchInstance = misc:AddSwitch("Jump~Power", function(State)
    JumpModEnabled = State
    if not State then
        -- Restore base physics options instantly when disabled
        pcall(function()
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = 50
                    Humanoid.JumpHeight = 7.2
                end
            end
        end)
    end
end)

-- AddSlider utilizing proper Elerium data options
local SliderInstance = misc:AddSlider("Jump Power Value", function(Value)
    TargetPower = Value
    TargetHeight = (Value * 0.144) -- Convert ratio scaling safely
end, {
    min = 50,
    max = 1000
})

-- Continuous loop ensuring state remains applied
game:GetService("RunService").RenderStepped:Connect(function()
    if JumpModEnabled then
        pcall(function()
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    -- Forces both values to prevent anti-cheat reset overwrites
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = TargetPower
                    Humanoid.JumpHeight = TargetHeight
                end
            end
        end)
    end
end)

-- Global Logic Variables
local noclipEnabled = false
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- ==========================================
-- 🛠️ MOVEMENT SECTION (Noclip Logic)
-- ==========================================
local noclipConnection
noclipConnection = runService.Stepped:Connect(function()
    if noclipEnabled and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

misc:AddSwitch("Noclip", function(state)
    noclipEnabled = state
    
    if not noclipEnabled and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- 1. Switch to Enable/Disable
misc:AddSwitch("Infinite Jump", function(Value)
    InfiniteJumpEnabled = Value
end)

-- 2. The Logic (Listen for Jump Request)
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            -- Set state to Jumping to allow another jump in mid-air
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Variables for control
getgenv().LoopSpeedEnabled = false
getgenv().WalkSpeedValue = 16

-- 1. The Switch (Toggle)
misc:AddSwitch("Loop WalkSpeed", function(bool)
    getgenv().LoopSpeedEnabled = bool
    print("Loop Speed is now: ", bool)
end)

-- 2. The Textbox (Speed Value)
misc:AddTextBox("Speed Amount", function(text)
    local num = tonumber(text)
    if num then
        getgenv().WalkSpeedValue = num
    end
end)

-- 3. The Background Loop
task.spawn(function()
    while task.wait() do
        if getgenv().LoopSpeedEnabled then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
                end
            end)
        end
    end
end)

local mainTab = Tab:AddFolder("Misc 2")

local function mk(n, c)
    local g = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
    g.Name, g.ResetOnSpawn, g.DisplayOrder, g.IgnoreGuiInset = n, false, 9999999, true
    local f = Instance.new("Frame", g)
    f.Size, f.BackgroundColor3, f.BorderSizePixel, f.Visible = UDim2.new(1,0,1,0), c, 0, false
    return f
end

local bF, wF = mk("B", Color3.new(0,0,0)), mk("W", Color3.new(1,1,1))
mainTab:AddSwitch("Black Screen", function(s) bF.Visible = s end)
mainTab:AddSwitch("White Screen", function(s) wF.Visible = s end)

local fb, orig = false, {game:GetService("Lighting").Ambient, game:GetService("Lighting").OutdoorAmbient, game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime, game:GetService("Lighting").GlobalShadows}
task.spawn(function()
    while task.wait(0.5) do
        if fb then game:GetService("Lighting").Ambient, game:GetService("Lighting").OutdoorAmbient, game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime, game:GetService("Lighting").GlobalShadows = Color3.new(1,1,1), Color3.new(1,1,1), 2, 14, false end
    end
end)
mainTab:AddSwitch("Fullbright", function(s)
    fb = s
    if not s then game:GetService("Lighting").Ambient, game:GetService("Lighting").OutdoorAmbient, game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime, game:GetService("Lighting").GlobalShadows = unpack(orig) end
end)

local be, ne, he, c = false, false, false, {}

local function esp(p)
    if c[p] or p == game:GetService("Players").LocalPlayer then return end
    local hl = Instance.new("Highlight")
    hl.FillColor, hl.FillTransparency, hl.OutlineColor = Color3.new(1,0,0), 0.5, Color3.new(1,1,1)
    
    local nt = Instance.new("BillboardGui")
    nt.Size, nt.AlwaysOnTop, nt.ExtentsOffset = UDim2.new(0,200,0,50), true, Vector3.new(0,3,0)
    local tx = Instance.new("TextLabel", nt)
    tx.Size, tx.BackgroundTransparency, tx.Text, tx.TextColor3, tx.TextSize, tx.Font, tx.TextStrokeTransparency = UDim2.new(1,0,1,0), 1, p.Name, Color3.new(1,1,1), 14, Enum.Font.SourceSansBold, 0

    local hb = Instance.new("BillboardGui")
    hb.Size, hb.AlwaysOnTop, hb.ExtentsOffset = UDim2.new(0,5,0,45), true, Vector3.new(-2.2,0.5,0)
    local bg = Instance.new("Frame", hb)
    bg.Size, bg.BackgroundColor3, bg.BorderSizePixel = UDim2.new(1,0,1,0), Color3.fromRGB(40,40,40), 0
    local hm = Instance.new("Frame", bg)
    hm.Size, hm.Position, hm.AnchorPoint, hm.BackgroundColor3, hm.BorderSizePixel = UDim2.new(1,0,1,0), UDim2.new(0,0,1,0), Vector2.new(0,1), Color3.fromRGB(0,255,0), 0

    c[p] = {H = hl, N = nt, B = hb, M = hm}

    local function up()
        local ch = p.Character
        local hd, hu = ch and ch:WaitForChild("Head", 5), ch and ch:WaitForChild("Humanoid", 5)
        if ch and hd and hu then
            hl.Parent, hl.Enabled = ch, be
            nt.Adornee, nt.Parent, nt.Enabled = hd, hd, ne
            hb.Adornee, hb.Parent, hb.Enabled = hd, hd, he
            if c[p].Cn then c[p].Cn:Disconnect() end
            c[p].Cn = hu:GetPropertyChangedSignal("Health"):Connect(function()
                local pct = math.clamp(hu.Health / hu.MaxHealth, 0, 1)
                hm.Size = UDim2.new(1, 0, pct, 0)
                hm.BackgroundColor3 = Color3.fromHSV(pct * 0.35, 1, 1)
            end)
        end
    end
    p.CharacterAdded:Connect(function() task.wait(0.5) up() end)
    up()
end

for _, p in ipairs(game:GetService("Players"):GetPlayers()) do esp(p) end
game:GetService("Players").PlayerAdded:Connect(esp)
game:GetService("Players").PlayerRemoving:Connect(function(p)
    if c[p] then
        for _, v in pairs(c[p]) do if typeof(v) == "Instance" then v:Destroy() elseif typeof(v) == "RBXScriptConnection" then v:Disconnect() end end
        c[p] = nil
    end
end)

mainTab:AddSwitch("Box ESP", function(s) be = s for _, d in pairs(c) do if d.H then d.H.Enabled = s end end end)
mainTab:AddSwitch("Player Name ESP", function(s) ne = s for _, d in pairs(c) do if d.N then d.N.Enabled = s end end end)
mainTab:AddSwitch("Health Bar ESP", function(s) he = s for _, d in pairs(c) do if d.B then d.B.Enabled = s end end end)
	
local fps1 = Tab:AddFolder("Misc 3")

	fps1:AddButton('Remove Textures', function()
		local v1194, v1195, v1196 = pairs(game:GetDescendants())
		while true do
			local v1197
			v1196, v1197 = v1194(v1195, v1196)
			if v1196 == nil then
				break
			end
			if v1197:IsA('Decal') or v1197:IsA('Texture') then
				v1197.Transparency = 1
			end
		end
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Performance',
			Text = 'Textures removed!',
			Duration = 5,
		})
	end)
	fps1:AddButton('Reduce Graphics', function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Performance',
			Text = 'Graphics reduced!',
			Duration = 5,
		})
	end)
	fps1:AddButton('Disable Shadows', function()
		game:GetService('Lighting').GlobalShadows = false
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Performance',
			Text = 'Shadows disabled!',
			Duration = 5,
		})
	end)
	fps1:AddButton('Disable Effects', function()
		local v1198, v1199, v1200 = pairs(game:GetDescendants())
		while true do
			local v1201
			v1200, v1201 = v1198(v1199, v1200)
			if v1200 == nil then
				break
			end
			if v1201:IsA('ParticleEmitter') or (v1201:IsA('Smoke') or (v1201:IsA('Fire') or v1201:IsA('Sparkles'))) then
				v1201.Enabled = false
			end
		end
		local _Lighting2 = game:GetService('Lighting')
		local v1203, v1204, v1205 = pairs(_Lighting2:GetChildren())
		while true do
			local v1206
			v1205, v1206 = v1203(v1204, v1205)
			if v1205 == nil then
				break
			end
			if v1206:IsA('BlurEffect') or (v1206:IsA('SunRaysEffect') or (v1206:IsA('ColorCorrectionEffect') or (v1206:IsA('BloomEffect') or v1206:IsA('DepthOfFieldEffect')))) then
				v1206.Enabled = false
			end
		end
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Performance',
			Text = 'Effects disabled!',
			Duration = 5,
		})
	end)
	fps1:AddButton('Simplify Materials', function()
		local v1207, v1208, v1209 = pairs(game:GetDescendants())
		while true do
			local v1210
			v1209, v1210 = v1207(v1208, v1209)
			if v1209 == nil then
				break
			end
			if v1210:IsA('BasePart') and not v1210:IsA('MeshPart') then
				v1210.Material = Enum.Material.SmoothPlastic
				if not (v1210.Parent and (v1210.Parent:FindFirstChild('Humanoid') or v1210.Parent.Parent:FindFirstChild('Humanoid'))) then
					v1210.Reflectance = 0
				end
			end
		end
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Performance',
			Text = 'Materials simplified!',
			Duration = 5,
		})
	end)
fps1:AddButton('Remove Fog', function()
		game:GetService('Lighting').FogEnd = 10000000000
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Performance',
			Text = 'Fog removed!',
			Duration = 5,
		})
	end)
	fps1:AddButton('Anti Lag (Advanced)', function()
		local v1211, v1212, v1213 = pairs(game:GetDescendants())
		while true do
			local v1214
			v1213, v1214 = v1211(v1212, v1213)
			if v1213 == nil then
				break
			end
			if v1214:IsA('Decal') or v1214:IsA('Texture') then
				v1214:Destroy()
			end
		end
		local _Terrain = workspace:FindFirstChildOfClass('Terrain')
		if _Terrain then
			_Terrain.WaterWaveSize = 0
			_Terrain.WaterWaveSpeed = 0
			_Terrain.WaterReflectance = 0
			_Terrain.WaterTransparency = 1
			_Terrain.Decorations = false
		end
		local v1216, v1217, v1218 = pairs(workspace:GetDescendants())
		while true do
			local v1219
			v1218, v1219 = v1216(v1217, v1218)
			if v1218 == nil then
				break
			end
			if v1219:IsA('Explosion') or v1219:IsA('Debris') then
				v1219:Destroy()
			elseif v1219:IsA('BasePart') and v1219.Name:lower():find('debris') then
				v1219:Destroy()
			end
		end
		local v1220, v1221, v1222 = pairs(game:GetDescendants())
		while true do
			local v1223
			v1222, v1223 = v1220(v1221, v1222)
			if v1222 == nil then
				break
			end
			if v1223:IsA('PointLight') or (v1223:IsA('SurfaceLight') or v1223:IsA('SpotLight')) then
				v1223.Enabled = false
			end
		end
		local v1224, v1225, v1226 = pairs(workspace:GetDescendants())
		while true do
			local v1227
			v1226, v1227 = v1224(v1225, v1226)
			if v1226 == nil then
				break
			end
			if v1227:IsA('Sound') then
				v1227:Stop()
			end
		end
		print('Anti-Lag Activated: Textures, lighting, sounds, and effects removed.')
	end)
	fps1:AddButton('Ultra FPS Booster', function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
		settings().Rendering.EagerBulkExecution = true
		settings().Rendering.ReloadAssets = false
		local _Lighting3 = game:GetService('Lighting')
		_Lighting3.GlobalShadows = false
		_Lighting3.FogEnd = 10000000000
		_Lighting3.Brightness = 0
		_Lighting3.EnvironmentDiffuseScale = 0
		_Lighting3.EnvironmentSpecularScale = 0
		local v1229, v1230, v1231 = ipairs(game:GetDescendants())
		while true do
			local v1232
			v1231, v1232 = v1229(v1230, v1231)
			if v1231 == nil then
				break
			end
			if v1232:IsA('ParticleEmitter') or (v1232:IsA('Trail') or (v1232:IsA('Smoke') or (v1232:IsA('Fire') or v1232:IsA('Sparkles')))) then
				v1232:Destroy()
			elseif v1232:IsA('PointLight') or (v1232:IsA('SpotLight') or v1232:IsA('SurfaceLight')) then
				v1232.Enabled = false
			end
		end
		local v1233, v1234, v1235 = pairs(game:GetDescendants())
		while true do
			local v1236
			v1235, v1236 = v1233(v1234, v1235)
			if v1235 == nil then
				break
			end
			if v1236:IsA('Sound') then
				v1236:Stop()
				v1236.Volume = 0
			end
		end
		local v1237, v1238, v1239 = ipairs(game:GetDescendants())
		while true do
			local v1240
			v1239, v1240 = v1237(v1238, v1239)
			if v1239 == nil then
				break
			end
			if v1240:IsA('Decal') or v1240:IsA('Texture') then
				v1240:Destroy()
			end
		end
		local _Terrain2 = workspace:FindFirstChildOfClass('Terrain')
		if _Terrain2 then
			_Terrain2.WaterWaveSize = 0
			_Terrain2.WaterWaveSpeed = 0
			_Terrain2.WaterReflectance = 0
			_Terrain2.WaterTransparency = 1
			_Terrain2.Decorations = false
		end
		local _LocalPlayer60 = game.Players.LocalPlayer
		local _PlayerGui3 = _LocalPlayer60:FindFirstChild('PlayerGui')
		if _PlayerGui3 then
			local v1244, v1245, v1246 = ipairs(_PlayerGui3:GetDescendants())
			while true do
				local v1247
				v1246, v1247 = v1244(v1245, v1246)
				if v1246 == nil then
					break
				end
				if v1247:IsA('TextLabel') or (v1247:IsA('ImageLabel') or v1247:IsA('ImageButton')) then
					v1247.Visible = false
				end
			end
		end
		local v1248, v1249, v1250 = ipairs(_LocalPlayer60.Character:GetChildren())
		while true do
			local v1251
			v1250, v1251 = v1248(v1249, v1250)
			if v1250 == nil then
				break
			end
			if v1251:IsA('Accessory') or v1251:IsA('Clothing') then
				v1251:Destroy()
			end
		end
		local _Humanoid8 = _LocalPlayer60.Character:FindFirstChildWhichIsA('Humanoid')
		if _Humanoid8 then
			local v1253, v1254, v1255 = pairs(_Humanoid8:GetPlayingAnimationTracks())
			while true do
				local v1256
				v1255, v1256 = v1253(v1254, v1255)
				if v1255 == nil then
					break
				end
				v1256:Stop()
			end
		end
		print('Ultra FPS Boost applied. Maximum rendering and resource optimization complete.')
	end)
	fps1:AddButton('Full Optimization', function()
		local v1257, v1258, v1259 = pairs(game:GetDescendants())
		while true do
			local v1260
			v1259, v1260 = v1257(v1258, v1259)
			if v1259 == nil then
				break
			end
			if v1260:IsA('ParticleEmitter') or (v1260:IsA('Smoke') or (v1260:IsA('Fire') or v1260:IsA('Sparkles'))) then
				v1260.Enabled = false
			end
		end
		local _Lighting4 = game:GetService('Lighting')
		_Lighting4.GlobalShadows = false
		_Lighting4.FogEnd = 9000000000
		_Lighting4.Brightness = 0
		settings().Rendering.QualityLevel = 1
		local v1262, v1263, v1264 = pairs(game:GetDescendants())
		while true do
			local v1265
			v1264, v1265 = v1262(v1263, v1264)
			if v1264 == nil then
				break
			end
			if v1265:IsA('Decal') or v1265:IsA('Texture') then
				v1265.Transparency = 1
			elseif v1265:IsA('BasePart') and not v1265:IsA('MeshPart') then
				v1265.Material = Enum.Material.SmoothPlastic
				if not (v1265.Parent and (v1265.Parent:FindFirstChild('Humanoid') or v1265.Parent.Parent:FindFirstChild('Humanoid'))) then
					v1265.Reflectance = 0
				end
			end
		end
		local v1266, v1267, v1268 = pairs(_Lighting4:GetChildren())
		while true do
			local v1269
			v1268, v1269 = v1266(v1267, v1268)
			if v1268 == nil then
				break
			end
			if v1269:IsA('BlurEffect') or (v1269:IsA('SunRaysEffect') or (v1269:IsA('ColorCorrectionEffect') or (v1269:IsA('BloomEffect') or v1269:IsA('DepthOfFieldEffect')))) then
				v1269.Enabled = false
			end
		end
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = 'Optimization',
			Text = 'Full optimization applied!',
			Duration = 5,
		})
	end)

local features = window:AddTab("Info") -- Name of tab
features:Show() -- shows the tab

features:AddLabel("Made By PrimeKenzou")
features:AddLabel("Thank You For Using My Public Script")
features:AddLabel("BLACKLISTED PLAYERS 👇")
features:AddLabel("Maitre_eyuns, Maitre 22222, Mhar, QUERUB3N, NSP_Jekk, Yuki, TAKEME356")

features:AddLabel("")
local wLabel = features:AddLabel("KENZOU PUBLIC VERSION")
wLabel.TextSize = 40
wLabel.Font = Enum.Font.Arcade

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Public Script Executed!",
    Text = "Sucessfully Executed Public Script",
    Duration = 5,
})
