local base = 'https://raw.githubusercontent.com/17kShotsss/UI-LIBRARY/main/'
local Library = loadstring(game:HttpGet(base .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(base .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(base .. 'addons/SaveManager.lua'))()

--// UI Setup
local Window = Library:CreateWindow({ Title = '╭━─≪ ✠ skidmenu.xyz ✠ ≫─━╮', Center = true, AutoShow = true })
local Tabs = { Main = Window:AddTab('Main'), ['UI Settings'] = Window:AddTab('UI Settings') }
local Box = Tabs.Main:AddLeftGroupbox('Automatics')

local Settings = { AutoMoney = false, AutoMats = false, AutoFullKill = false, AutoDMG = false, DamageValue = 10, DamageTimer = 1 }

local function addToggle(id, text)
    Box:AddToggle(id, { Text = text, Default = false }):OnChanged(function() Settings[id] = Toggles[id].Value end)
    Toggles[id]:SetValue(false)
end

addToggle('AutoMoney', 'Auto Collect Money')
addToggle('AutoMats', 'Auto Collect Material')
addToggle('AutoFullKill', 'Auto Full Kill Enemies')
addToggle('AutoDMG', 'Auto Damage Enemies')

Box:AddSlider('DamageTimer', { Text = 'Timer Per Hit', Default = 1, Min = 0, Max = 1, Rounding = 1, Compact = true })
Options.DamageTimer:OnChanged(function() Settings.DamageTimer = Options.DamageTimer.Value end)
Box:AddSlider('DamageValue', { Text = 'Damage', Default = 10, Min = 0, Max = 500, Rounding = 0, Compact = true })
Options.DamageValue:OnChanged(function() Settings.DamageValue = Options.DamageValue.Value end)

local MyButton = Box:AddButton('Remove Shit (Maybe removes lag)', function()
    workspace.InvisWalls:Remove()
	workspace.Leaderboards:Remove()
	workspace.Spin:Remove()
	workspace.TheEnchanter:Remove()
	workspace.DefaultMap:Remove()
end)

Library:SetWatermarkVisibility(false)

Library:SetWatermark('Meow meow my ninja')

Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings']) 
ThemeManager:ApplyToTab(Tabs['UI Settings'])

--// Game logic
local player = game.Players.LocalPlayer
local hrp = (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
local basesFolder = workspace:WaitForChild("Bases")

local function getPlayerBase()
	for _, b in ipairs(basesFolder:GetChildren()) do
		local t = b:FindFirstChild("Target")
		if t and t:GetAttribute("Owner") == player.Name then return b end
	end
end

local playerBase
repeat task.wait(0.5) playerBase = getPlayerBase() until playerBase
local enemies = playerBase:WaitForChild("Enemies")

--// Enemy handlers
local function killEnemy(m)
	local h = m:FindFirstChildOfClass("Humanoid")
	if h then h.Health = 0 end
end

local function damageEnemy(m)
	local h = m:FindFirstChildOfClass("Humanoid")
	if h then h.Health -= Settings.DamageValue end
end

enemies.ChildAdded:Connect(function(c)
	if not c:IsA("Model") or c.Name ~= "" then return end
	if Settings.AutoFullKill then task.spawn(killEnemy, c)
	elseif Settings.AutoDMG then task.spawn(damageEnemy, c) end
end)

task.spawn(function()
	while task.wait(0.5) do
		for _, m in ipairs(enemies:GetChildren()) do
			if m:IsA("Model") and m.Name == "" then
				if Settings.AutoFullKill then killEnemy(m)
				elseif Settings.AutoDMG then task.spawn(damageEnemy, m) end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		if not (Settings.AutoMoney or Settings.AutoMats) then continue end

		for _, obj in ipairs(workspace:GetDescendants()) do
			if not obj:IsA("BasePart") then continue end

			if Settings.AutoMoney and obj.Name == "CashTemp" then
				obj.CFrame = hrp.CFrame
			elseif Settings.AutoMats and obj.Name == "MaterialTemp" then
				obj.CFrame = hrp.CFrame
			end
		end
	end
end)
