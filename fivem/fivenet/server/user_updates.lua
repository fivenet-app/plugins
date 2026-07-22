-- Timeclock and user update helpers

--- Set a timeclock entry for a user identifier.
---@param identifier string
---@param data table
function SetTimeclockEntry(identifier --[[string]], data --[[TimeclockUpdate]])
	local userId = GetUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddJobTimeclock({
		jobTimeclock = data,
	})
end

--- Send a low-level user update.
---@param identifier string
---@param data table
function SendUserUpdate(identifier --[[string]], data --[[UserUpdate]])
	local userId = GetUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddUserUpdate({
		userUpdate = data,
	})
end

--- Set the last character ID for a user identifier.
---@param identifier string
function SetLastCharID(identifier --[[string]])
	local userId = GetUserIDFromIdentifier(identifier)

	exports[GetCurrentResourceName()]:SetLastCharID({
		lastCharId = {
			license = GetLicenseFromIdentifier(identifier),
			lastCharId = userId,
		},
	})
end
