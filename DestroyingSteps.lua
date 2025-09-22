local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local screenCrate = playerGui:WaitForChild("ScreenCrate")

screenCrate.Enabled = false

local crateScript = screenCrate:FindFirstChildOfClass("LocalScript")
if crateScript then
    crateScript.Disabled = true
end

local ptrails = {
    ["Plain Red"] = true,
    ["Plain Blue"] = true,
    ["Plain Green"] = true,
    ["Radioactive Beast Mode"] = true,
    ["Beast Mode"] = true,
    ["Blizzard Beast Mode"] = true,
    ["The Classic ROBLOX Fedora"] = true,
    ["Green Circle"] = true,
    ["Red Circle"] = true,
    ["Blue Circle"] = true,
    ["Valkyrie Helm"] = true,
    ["Green Sparkle Time Fedora"] = true,
    ["Red Sparkle Time Fedora"] = true,
    ["Teal Sparkle Time Fedora"] = true,
    ["Dominus Praefectus"] = true,
    ["Dominus Frigidus"] = true,
    ["Dominus Infernus"] = true,
    ["Super Super Happy Face"] = true,
    ["Chill"] = true,
    ["Crybaby"] = true,
    ["Dominus Empyreus"] = true,
    ["Blackvalk"] = true,
    ["Beach Ball"] = true,
    ["Sun"] = true,
    ["Emerald Valkyrie"] = true,
    ["Red Tango"] = true,
    ["Yum!"] = true,
    ["Logo"] = true,
    ["City"] = true,
    ["Double Rainbow"] = true,
    ["Meltedway"] = true,
    ["Stars"] = true,
    ["Dream"] = true,
    ["Timeless"] = true,
    ["Elf"] = true,
    ["Reindeer"] = true,
    ["Santa"] = true,
    ["Christmas Tree"] = true,
    ["Present"] = true,
    ["Stocking"] = true,
    ["Hot Chocolate"] = true,
    ["Present Stack"] = true,
    ["Marshmallow"] = true,
    ["Dominus Astra"] = true,
    ["Err..."] = true,
    ["Best Trail"] = true,
    ["Rainbow Timeless"] = true,
    ["not free orb"] = true,
    ["Sparkle Time Valkyrie"] = true,

}

local screenCrateEvent = ReplicatedStorage:WaitForChild("ScreenCrate").OnClientEvent
local destroyTrail = ReplicatedStorage:WaitForChild("DestroyTrail")
local buyCrate = ReplicatedStorage:WaitForChild("BuyCrate")

screenCrateEvent:Connect(function(trailName)
    if ptrails[trailName] then
        destroyTrail:FireServer(trailName)
        print("Auto-deleted: " .. trailName)
    else
        warn("Kept: " .. trailName)
    end
end)

local crateTypes = {
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
    "not free crate"
}

local currentCrateIndex = 1

while task.wait() do
   
    local crateType = crateTypes[currentCrateIndex]
    
    local success, error = pcall(function()
        buyCrate:FireServer(crateType)
    end)
    
    if success then
        print("Purchased: " .. crateType)
    else
        warn("Failed to purchase " .. crateType .. ": " .. tostring(error))
    end
    
    currentCrateIndex = currentCrateIndex + 1
    if currentCrateIndex > #crateTypes then
        currentCrateIndex = 1
    end
end
