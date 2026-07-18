-- false = closed, true = open
local usingTablet = false
-- false = unblocked, true = blocked
local blockInputs = false

-- Prop object
local tablet

function IsInTablet()
	return usingTablet and true or false
end

AddEventHandler('fivenet:viewTablet', function(state)
	if Logger.isDebugEnabled() then Logger.debug(('fivenet:viewTablet called with state: %s'):format(tostring(state))) end

	if not state then
		blockInputs = false
		CloseTablet()
	elseif state then
		blockInputs = false
		OpenTablet()
	end
end)

local objectHash = `prop_cs_tablet`

local dict, anim = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', 'idle_a'

local defaultDisabledControls = {
	{ group = 0, control = 0 },   -- Next Camera
	{ group = 0, control = 1 },   -- Look Left/Right
	{ group = 0, control = 2 },   -- Look Up/Down
	{ group = 0, control = 14 },  -- Scrollwheel up
	{ group = 0, control = 15 },  -- Scrollwheel down
	{ group = 0, control = 16 },  -- Select next weapon (scrollwheel down)
	{ group = 0, control = 17 },  -- Select previous weapon (scrollwheel up)
	{ group = 0, control = 24 },  -- Attack
	{ group = 0, control = 25 },  -- Aim
	{ group = 27, control = 75 }, -- Exit vehicle when driving
	{ group = 0, control = 36 },  -- Input Duck/Sneak
	{ group = 0, control = 44 },  -- Cover
	{ group = 0, control = 45 },  -- Reload
	{ group = 0, control = 75 },  -- Exit Vehicle
	{ group = 0, control = 81 },  -- Next Radio (Vehicle)
	{ group = 0, control = 82 },  -- Previous Radio (Vehicle)
	{ group = 0, control = 96 },  -- Cinematic camera scroll up (scrollwheel up)
	{ group = 0, control = 97 },  -- Cinematic camera scroll down (scrollwheel down)
	{ group = 0, control = 99 },  -- Vehicle select next weapon (scrollwheel up)
	{ group = 0, control = 100 }, -- Vehicle select previous weapon (scrollwheel down)
	{ group = 0, control = 115 }, -- Vehicle flying select next weapon (scrollwheel up)
	{ group = 0, control = 116 }, -- Vehicle flying select previous weapon (scrollwheel down)
	{ group = 0, control = 180 }, -- Cellphone scroll forward (scrollwheel down)
	{ group = 0, control = 181 }, -- Cellphone scroll backward (scrollwheel up)
	{ group = 0, control = 198 }, -- Frontend right axis y (scrollwheel down)
	{ group = 0, control = 241 }, -- Increase replay FOV (scrollwheel up)
	{ group = 0, control = 242 }, -- Decrease replay FOV (scrollwheel down)
	{ group = 0, control = 257 }, -- Attack 2
	{ group = 0, control = 261 }, -- Scroll up previous weapon (scrollwheel up)
	{ group = 0, control = 262 }, -- Scroll down next weapon (scrollwheel down)
	{ group = 0, control = 263 }, -- Melee Attack 1
}

local disabledControls = {}

local function addDisabledControl(control)
	if type(control) == 'number' then
		disabledControls[#disabledControls + 1] = { group = 0, control = control }
		return
	end

	if type(control) == 'table' and control.control ~= nil then
		disabledControls[#disabledControls + 1] = {
			group = control.group or 0,
			control = control.control,
		}
	end
end

for _, control in ipairs(defaultDisabledControls) do
	addDisabledControl(control)
end

if Config.Tablet and type(Config.Tablet.DisabledControls) == 'table' then
	for _, control in ipairs(Config.Tablet.DisabledControls) do
		addDisabledControl(control)
	end
end

-- Delete tablet prop
local function deleteTablet()
	if DoesEntityExist(tablet) then
		DeleteEntity(tablet)
	end

	tablet = 0
end

-- Create tablet prop
local function createTablet()
	deleteTablet()

	tablet = CreateObject(objectHash, 0, 0, 0, true, true, false)
end

-- Open tablet
function OpenTablet()
	if IsInTablet() then return end

	local ped = PlayerPedId()

	-- Don't use tablet animation when in vehicle
	if not IsPedInAnyVehicle(ped) then
		createTablet()

		LoadAnimDict(dict)
		TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 51, 0, false, false, false)

		AttachEntityToEntity(tablet, ped, GetPedBoneIndex(ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	end

	usingTablet = true

	CreateThread(function()
		while usingTablet do
			BlockWeaponWheelThisFrame()

			for _, control in ipairs(disabledControls) do
				DisableControlAction(control.group, control.control, true)
			end

			if blockInputs then
				DisableAllControlActions(0)
			end

			Wait(0)
		end

		HudWeaponWheelIgnoreControlInput(false)
	end)

	-- Handles pause menu state for tablet
	CreateThread(function()
		while usingTablet do
			Wait(500)
			local isPauseOpen = IsPauseMenuActive() ~= false
			-- Handle if the tablet is already visible and escape menu is opened
			if isPauseOpen and IsInTablet() then
				CloseTablet()
				break
			end
		end
	end)

	SendNUIMessage({type = 'openTablet', state = usingTablet, webUrl = Config.WebURL})

	SetNuiFocus(true, true)
	SetNuiFocusKeepInput(true)
end

-- Close tablet
function CloseTablet()
	if not IsInTablet() then return end

	if not IsInTokenMgmt() then
		SetNuiFocus(false, false)
	end

	SetNuiFocusKeepInput(false)

	SendNUIMessage({type = 'closeTablet', state = not usingTablet})

	-- Stop animation
	local playerPed = PlayerPedId()
	if IsEntityPlayingAnim(playerPed, dict, anim, 3) then
		StopAnimTask(playerPed, dict, anim, 2.0)
	else
		ClearPedTasks(playerPed)
	end
	RemoveAnimDict(dict)

	usingTablet = false

	deleteTablet()
end

RegisterNUICallback('openTablet', function(data, cb)
	TriggerEvent('fivenet:viewTablet', true)

	cb(true)
end)

RegisterNUICallback('closeTablet', function(data, cb)
	TriggerEvent('fivenet:viewTablet', false)

	cb(true)
end)

RegisterNUICallback('focusTablet', function(data, cb)
	blockInputs = data and data.state == true

	cb(true)
end)

RegisterCommand('tablet', function()
	TriggerEvent('fivenet:viewTablet', not usingTablet)
end)

RegisterCommand('tabletfix', function()
	TriggerEvent('fivenet:viewTablet', false)
	blockInputs = false

	SendNUIMessage({type = 'tabletfix', webUrl = Config.WebURL})
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/tablet', 'FiveNet Tablet öffnen')
	TriggerEvent('chat:addSuggestion', '/tabletfix', 'Probleme mit FiveNet Tablet lösen')
end)

if Config.Hotkey.Enable then
	RegisterKeyMapping('tablet', 'Tablet öffnen', 'keyboard', Config.Hotkey.Key)
end

-- Hide tablet on resource stop and player relog
AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		if usingTablet then
			TriggerEvent('fivenet:viewTablet', false)
		end
	end
end)

if Config.Framework == 'esx' then
	RegisterNetEvent('esx:onPlayerLogout', function()
		if IsInTablet() then
			CloseTablet()
		end
	end)
elseif Config.Framework == 'qbcore' then
	RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
		if IsInTablet() then
			CloseTablet()
		end
	end)
end

-- NUI Callback Handlers for FiveNet actions
RegisterNUICallback('setWaypoint', function(data, cb)
	SetNewWaypoint(data.x, data.y)

	cb(true)
end)

RegisterNUICallback('phoneCallNumber', function(data, cb)
	if IsInTablet() then
		CloseTablet()
	end

	Functions.CallNumber(data.phoneNumber)

	cb(true)
end)

RegisterNUICallback('copyToClipboard', function(data, cb)
	SendNUIMessage({type = 'copyToClipboard', text = data.text})

	cb(true)
end)

RegisterNUICallback('setRadioFrequency', function(data, cb)
	local frequency = tonumber(data.frequency)
	if frequency then
		Functions.SetRadioFrequency(frequency)
	end

	cb(true)
end)

RegisterNUICallback('setWaypointPLZ', function(data, cb)
	if data and data.plz ~= nil then
		ExecuteCommand(Config.PostalCommand .. ' ' .. tostring(data.plz))
	end

	cb(true)
end)

RegisterNUICallback('openTokenMgmt', function(data, cb)
	if IsInTablet() then
		CloseTablet()
	end

	TriggerServerEvent('fivenet:openTokenMgmt')

	cb(true)
end)

RegisterNUICallback('openURLInWindow', function(data, cb)
	SendNUIMessage({type = 'openURLInWindow', url = data.url})

	cb(true)
end)

RegisterNUICallback('setTabletColors', function(data, cb)
	SendNUIMessage({type = 'setTabletColors', data = data})

	cb(true)
end)
