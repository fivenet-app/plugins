if Config.Framework == 'qbcore' and Config.Tracking.Enable then
	AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
		local identifier = GetPlayerUniqueIdentifier(source)
		local normalizedJob = GetPlayerJob(source)
		if not identifier or not normalizedJob then return end

		if not Config.Tracking.Jobs[normalizedJob.name] then return end

		if normalizedJob.onDuty then
			local xPlayer = GetPlayerById(source)

			-- If player is hidden, we don't bother adding them to the locations table now
			if Functions.CheckIfPlayerHidden(xPlayer) then return end

			local coords = GetEntityCoords(GetPlayerPed(source))
			local userId = GetCachedTrackingUserId(identifier)
			if not userId then return end

			exports[GetCurrentResourceName()]:SendUserLocations({
				users = {
					BuildUserLocationEntry(userId, normalizedJob.name, coords, false, true),
				},
			})

			SetTrackingPosition(identifier, coords)
		else
			DeleteTrackingPosition(identifier, normalizedJob.name)
		end
	end)

	AddEventHandler('QBCore:Server:PlayerDropped', function(source)
		local identifier = GetPlayerUniqueIdentifier(source)
		if not identifier then
			print('no identifier returned for player', source)
			return
		end

		DeleteTrackingPosition(identifier)
	end)
end
