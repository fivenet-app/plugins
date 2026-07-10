if Config.Tracking.Enable then
	CreateThread(function()
		while true do
			local locations = {}

			local players = GetPlayers()
			for playerId, _ in pairs(players) do
				local player = GetPlayerById(playerId)
				local job = GetPlayerJob(playerId)
				local identifier = GetPlayerUniqueIdentifier(playerId)
				if not player or not job or not identifier then goto continue end

				local userId = GetCachedTrackingUserId(identifier)

				if Config.Tracking.Jobs[job.name] and userId then
					local update = true

					local currentLocation = GetTrackingPosition(identifier)
					if currentLocation then
						if IsNearVector(playerId, currentLocation, 5.0) then
							update = false
						end
					end

					if update then
						local ped = GetPlayerPed(playerId)
						if ped ~= 0 then
							local coords = GetEntityCoords(ped)
							local hidden = false

							-- Either players is not on duty and/or doesn't have the tracking item
							if Functions.CheckIfPlayerHidden(player) then
								hidden = true
							end

							SetTrackingPosition(identifier, coords)

							locations[#locations + 1] = BuildUserLocationEntry(userId, job.name, coords, hidden, false)
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
end

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
