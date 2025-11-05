-- LocalScript
local player = game.Players.LocalPlayer
local basesFolder = workspace:WaitForChild("Bases")
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local queue = {}
local moving = false

-- add new valid part to queue
local function onNewPart(obj)
	if obj:IsA("BasePart") and (obj.Name == "CashTemp" or obj.Name == "MaterialTemp") then
		table.insert(queue, obj)
	end
end

-- move queued parts one by one
local function moveParts()
	if moving then return end
	moving = true
	while #queue > 0 do
		local part = table.remove(queue, 1)
		if part and part.Parent and hrp then
			part.CFrame = hrp.CFrame
		end
		task.wait(0.05) -- delay to prevent lag spikes
	end
	moving = false
end

-- initial scan for existing parts
for _, obj in pairs(workspace:GetDescendants()) do
	onNewPart(obj)
end
task.spawn(moveParts)

-- detect and collect new ones as they appear
workspace.DescendantAdded:Connect(function(obj)
	onNewPart(obj)
	task.spawn(moveParts)
end)


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
