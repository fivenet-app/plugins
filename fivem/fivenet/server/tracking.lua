local playerLocations = {}
local playerUserIds = {}

local function getCachedUserId(identifier --[[string]])
	if not identifier then return nil end

	if not playerUserIds[identifier] then
		local userId = getUserIDFromIdentifier(identifier)
		if not userId or userId == 0 then return nil end

		playerUserIds[identifier] = userId
	end

	return playerUserIds[identifier]
end

local function deletePosition(identifier --[[string]], job --[[string]])
	playerLocations[identifier] = nil
	local userId = getCachedUserId(identifier)
	if not userId then return end

	exports[GetCurrentResourceName()]:SendUserLocations({
		users = {
			{
				userId = userId,
				job = job,
				coords = {
					x = 0,
					y = 0,
				},
				hidden = false,
				remove = true,
			},
		},
	})
end

if Config.Tracking.Enable then
	CreateThread(function()
		while true do
			local locations = {}

			local players = getPlayers()
			for playerId, xPlayer in pairs(players) do
				if xPlayer == nil then goto continue end

				local job, identifier, userId
				if Config.Framework == 'qbcore' then
					playerId = xPlayer.PlayerData.source
					job = xPlayer.PlayerData.job.name
					identifier = xPlayer.PlayerData.cid .. ':' .. xPlayer.PlayerData.citizenid
				elseif Config.Framework == 'esx' then
					job = xPlayer.job.name
					identifier = xPlayer.identifier
				end
				userId = getCachedUserId(identifier)

				if Config.Tracking.Jobs[job] and userId then
					local update = true

					if playerLocations[identifier] then
						local curLocation = playerLocations[identifier]
						if IsNearVector(playerId, curLocation, 5.0) then
							update = false
						end
					end

					if update then
						local ped = GetPlayerPed(playerId)
						if ped ~= 0 then
							local coords = GetEntityCoords(ped)
							local hidden = false

							-- Either players is not on duty and/or doesn't have the tracking item
							if Functions.CheckIfPlayerHidden(xPlayer) then
								hidden = true
							end

							playerLocations[identifier] = coords

							locations[#locations + 1] = {
								["userId"] = userId,
								["job"] = job,
								["coords"] = {
									["x"] = coords.x,
									["y"] = coords.y,
								},
								["hidden"] = hidden,
								["remove"] = false,
							}
						end
					end
				end

				::continue::
			end

			if #locations > 0 then
				exports[GetCurrentResourceName()]:SendUserLocations({
					users = locations,
				})
			end

			Wait(Config.Tracking.Interval)
		end
	end)

	-- Player On Duty - If player comes on duty, add them to the locations table ASAP
	if Config.Framework == 'esx' then
		AddEventHandler('esx:onSetDuty', function(source, jobName, onDuty)
			local identifier = getPlayerUniqueIdentifier(source)
			if not identifier then return end

			local job = getPlayerJob(source)
			if not job then return end

			if not Config.Tracking.Jobs[job.name] then return end

			if onDuty then
				-- If player is hidden, we don't bother adding them to the locations table now
				local xPlayer = getPlayerById(source)
				if Functions.CheckIfPlayerHidden(xPlayer) then return end

				local coords = GetEntityCoords(GetPlayerPed(source))
				local userId = getCachedUserId(identifier)
				if not userId then return end

				exports[GetCurrentResourceName()]:SendUserLocations({
					users = {
						{
							userId = userId,
							job = job.name,
							coords = {
								x = coords.x,
								y = coords.y,
							},
							hidden = false,
							remove = true,
						},
					},
				})

				playerLocations[identifier] = coords
			else
				deletePosition(identifier, job.name)
			end
		end)
	elseif Config.Framework == 'qbcore' then
		AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
			local identifier = getPlayerUniqueIdentifier(source)

			if not Config.Tracking.Jobs[job.name] then return end

			if job.onduty then
				local xPlayer = getPlayerById(source)

				-- If player is hidden, we don't bother adding them to the locations table now
				if Functions.CheckIfPlayerHidden(xPlayer) then return end

				local coords = GetEntityCoords(GetPlayerPed(source))
				local userId = getCachedUserId(identifier)
				if not userId then return end

				exports[GetCurrentResourceName()]:SendUserLocations({
					users = {
						{
							userId = userId,
							job = job.name,
							coords = {
								x = coords.x,
								y = coords.y,
							},
							hidden = false,
							remove = true,
						},
					},
				})

				playerLocations[identifier] = coords
			else
				deletePosition(identifier, job.name)
			end
		end)
	end

	-- Player left/disconnected
	if Config.Framework == 'esx' then
		AddEventHandler('esx:playerDropped', function(source)
			local identifier = getPlayerUniqueIdentifier(source)
			if not identifier then
				print('no identifier returned for player', source)
				return
			end

			deletePosition(identifier)
		end)
	elseif Config.Framework == 'qbcore' then
		AddEventHandler('QBCore:Server:PlayerDropped', function(source)
			local identifier = getPlayerUniqueIdentifier(source)
			if not identifier then
				print('no identifier returned for player', source)
				return
			end

			deletePosition(identifier)
		end)
	end

	-- Resource Start
	AddEventHandler('onResourceStart', function(resourceName)
		if resourceName == GetCurrentResourceName() and GetConvar('fnet_clear_on_start', 'false') == 'true' then
			CreateThread(function()
				Wait(1000)
				-- Clear user locations table on resource (re-)start, which most likely will be server restarts
				exports[GetCurrentResourceName()]:SendUserLocations({
					users = {},
					clearAll = true,
				})
			end)
		end
	end)
end
