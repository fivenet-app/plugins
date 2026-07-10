local playerLocations = {}
local playerUserIds = {}

function GetCachedTrackingUserId(identifier --[[string]])
	if not identifier then return nil end

	if not playerUserIds[identifier] then
		local userId = GetUserIDFromIdentifier(identifier)
		if not userId or userId == 0 then return nil end

		playerUserIds[identifier] = userId
	end

	return playerUserIds[identifier]
end

function DeleteTrackingPosition(identifier --[[string]], job --[[string]])
	playerLocations[identifier] = nil
	local userId = GetCachedTrackingUserId(identifier)
	if not userId then return end

	exports[GetCurrentResourceName()]:SendUserLocations({
		users = {
			BuildUserLocationEntry(userId, job, { x = 0, y = 0 }, false, true),
		},
	})
end

function SetTrackingPosition(identifier --[[string]], coords --[[vector3]])
	playerLocations[identifier] = coords
end

function GetTrackingPosition(identifier --[[string]])
	return playerLocations[identifier]
end
