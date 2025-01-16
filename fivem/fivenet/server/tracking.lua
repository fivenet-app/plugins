local playerLocations = {}

local locationUpdateQuery = [[
	INSERT INTO `fivenet_user_locations` (`identifier`, `job`, `x`, `y`, `hidden`) VALUES (@identifier, @job, @x, @y, @hidden)
	ON DUPLICATE KEY UPDATE `job` = VALUES(`job`), `x` = VALUES(`x`), `y` = VALUES(`y`), `hidden` = VALUES(`hidden`);
]]

local function deletePosition(identifier --[[string]], job --[[string]])
	playerLocations[identifier] = nil

	exports[GetCurrentResourceName()]:SendData({
		oneofKind = 'userLocations',
		userLocations = {
			users = {
				{
					identifier = identifier,
					job = job,
					coords = {
						x = 0,
						y = 0,
					},
					hidden = false,
					remove = true,
				},
			},
		},
	})
end

local function checkIfPlayerHidden(xPlayer)
	return not xPlayer.job.onDuty or (Config.Tracking.Item and not xPlayer.getInventoryItem(Config.Tracking.Item))
end

if Config.Tracking.Enable then
	CreateThread(function()
		while true do
			local locations = {}

			for playerId, xPlayer in pairs(ESX.GetExtendedPlayers()) do
				if Config.Tracking.Jobs[xPlayer.job.name] then
					local update = true

					if playerLocations[xPlayer.identifier] then
						local curLocation = playerLocations[xPlayer.identifier]
						if IsNearVector(playerId, curLocation, 5.0) then
							update = false
						end
					end

					if update then
						local ped = GetPlayerPed(playerId)
						if ped ~= 0 then
							local coords = GetEntityCoords(ped)
							local hidden = 0

							-- Either players is not on duty and/or doesn't have the tracking item
							if checkIfPlayerHidden(xPlayer) then
								hidden = 1
							end

							playerLocations[xPlayer.identifier] = coords

							table.insert(locations, {
								["identifier"] = xPlayer.identifier,
								["job"] = xPlayer.job.name,
								["x"] = coords.x,
								["y"] = coords.y,
								["hidden"] = hidden,
								["remove"] = false,
							})
						end
					end
				end
			end

			exports[GetCurrentResourceName()]:SendData({
				oneofKind = 'userLocations',
				userLocations = {
					users = locations,
				},
			})

			Wait(Config.Tracking.Interval)
		end
	end)

	-- If player comes on duty, add them to the locations table ASAP
	AddEventHandler('esx:onSetDuty', function(source, jobName, onDuty)
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then return end

		if onDuty then
			-- If player is hidden, we don't bother adding them to the locations table now
			if checkIfPlayerHidden(xPlayer) then return end

			local coords = GetEntityCoords(GetPlayerPed(source))

			exports[GetCurrentResourceName()]:SendData({
				oneofKind = 'userLocations',
				userLocations = {
					users = {
						{
							identifier = xPlayer.identifier,
							job = xPlayer.job.name,
							coords = {
								x = coords.x,
								y = coords.y,
							},
							hidden = false,
							remove = true,
						},
					},
				},
			})

			playerLocations[identifier] = coords
		else
			deletePosition(identifier, xPlayer.job.name)
		end
	end)

	AddEventHandler('esx:playerDropped', function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then return end

		deletePosition(xPlayer.identifier)
	end)

	-- Resource Start
	AddEventHandler('onResourceStart', function(resourceName)
		if resourceName == GetCurrentResourceName() and GetConvar('fnet_clear_on_start', 'false') == 'true' then
			CreateThread(function()
				Wait(1000)
				-- Clear user locations table on resource (re-)start, which most likely will be server restarts
				exports[GetCurrentResourceName()]:SendData({
					oneofKind = 'userLocations',
					userLocations = {
						users = {},
						clearAll = true,
					},
				})
			end)
		end
	end)
end
