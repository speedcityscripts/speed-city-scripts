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
    ["Elf"] = true,
    ["Reindeer"] = true,
    ["Santa"] = true,
    ["Present"] = true,
    ["Stocking"] = true,
    ["Hot Chocolate"] = true,
    ["Present Stack"] = true,
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
    "Elf Crate",
    "Christmas Crate"
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
