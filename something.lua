-- LocalScript
local player = game.Players.LocalPlayer
local basesFolder = workspace:WaitForChild("Bases")

-- find the base owned by this player
local function getPlayerBase()
	for _, baseFolder in ipairs(basesFolder:GetChildren()) do
		if baseFolder:IsA("Folder") then
			local target = baseFolder:FindFirstChild("Target")
			if target and target:GetAttribute("Owner") == player.Name then
				return baseFolder
			end
		end
	end
	return nil
end

-- kill enemy function
local function killEnemy(model)
	task.wait(0.2)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0
	end
end

-- start watching the correct base
local function watchBase(baseFolder)
	local enemiesFolder = baseFolder:WaitForChild("Enemies")

	-- handle already existing enemies
	for _, model in ipairs(enemiesFolder:GetChildren()) do
		if model:IsA("Model") and model.Name == "" then
			task.spawn(killEnemy, model)
		end
	end

	-- detect new ones
	enemiesFolder.ChildAdded:Connect(function(child)
		if child:IsA("Model") and child.Name == "" then
			task.spawn(killEnemy, child)
		end
	end)
end

-- wait until the player’s base exists
local playerBase = nil
repeat
	playerBase = getPlayerBase()
	task.wait(1)
until playerBase

watchBase(playerBase)
