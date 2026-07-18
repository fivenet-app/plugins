if Config.Framework == 'esx' and Config.Tracking.Enable then
	AddEventHandler('esx:onSetDuty', function(source, jobName, onDuty)
		local identifier = GetPlayerUniqueIdentifier(source)
		if not identifier then return end

		local job = GetPlayerJob(source)
		if not job then return end

		if not Config.Tracking.Jobs[job.name] then return end

		if job.onDuty then
			-- If player is hidden, we don't bother adding them to the locations table now
			local xPlayer = GetPlayerById(source)
			if Functions.CheckIfPlayerHidden(xPlayer) then return end

			local coords = GetEntityCoords(GetPlayerPed(source))
			local userId = GetCachedTrackingUserId(identifier)
			if not userId then return end

			exports[GetCurrentResourceName()]:SendUserLocations({
				users = {
					BuildUserLocationEntry(userId, job.name, coords, false, true),
				},
			})

			SetTrackingPosition(identifier, coords)
		else
			DeleteTrackingPosition(identifier, job.name)
		end
	end)

	AddEventHandler('esx:playerDropped', function(source)
		local identifier = GetPlayerUniqueIdentifier(source)
		if not identifier then
			Logger.error(('No identifier returned for player %s.'):format(source))
			return
		end

		DeleteTrackingPosition(identifier)
	end)
end
