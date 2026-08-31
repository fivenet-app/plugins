-- User Activity and Props

--- Add a user activity entry.
---@param sIdentifier string|nil
---@param tIdentifier string
---@param type number
---@param reason string
---@param data table|nil
--- If `sIdentifier` is omitted, the target user's DB ID is reused as the source user.
function AddUserActivity(sIdentifier, tIdentifier, type, reason, data)
	local sourceUserId = nil
	local targetUserId = GetUserIDFromIdentifier(tIdentifier)

	if sIdentifier then
		sourceUserId = GetUserIDFromIdentifier(sIdentifier)
	else
		sourceUserId = targetUserId
	end

	exports[GetCurrentResourceName()]:AddUserActivity({
		userActivity = {
			sourceUserId = sourceUserId,
			targetUserId = targetUserId,
			type = type,
			reason = reason,
			data = (data and { data = data } or nil),
		},
	})
end
exports('addUserActivity', AddUserActivity)

--- Get user props for a target identifier.
---@param identifier string
---@return GetUserPropsResponse
function GetUserProps(identifier)
	local userId = GetUserIDFromIdentifier(identifier)

	return exports[GetCurrentResourceName()]:GetUserProps({
		userId = userId,
	})
end
exports('getUserProps', GetUserProps)

--- Set user props for a target identifier.
---@param identifier string
---@param reason string|nil
---@param data table
---@param sourceUserId number|nil User DB ID to attribute the change to.
---@param sourceUserJob string|nil Job to attribute the change to.
--- The helper mutates `data` by adding `userId`.
function SetUserProps(identifier, reason, data, sourceUserId, sourceUserJob)
	local userId = GetUserIDFromIdentifier(identifier)
	data.userId = userId

	exports[GetCurrentResourceName()]:AddUserProps({
		userProps = {
			reason = reason,
			props = data,
		},
		sourceUser = (sourceUserId or sourceUserJob) and {
			userId = sourceUserId,
			job = sourceUserJob,
		} or nil,
	})
end
exports('setUserProps', SetUserProps)

--- Add or subtract from the open fine total for a user.
---@param tIdentifier string
---@param fine number
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
function UpdateOpenFines(tIdentifier, fine, sourceUserId, sourceUserJob)
	SetUserProps(tIdentifier, nil, { openFines = fine }, sourceUserId, sourceUserJob)
end
exports('updateOpenFines', UpdateOpenFines)

--- Set the wanted state for a user.
---@param tIdentifier string
---@param wanted boolean
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
function SetUserWantedState(tIdentifier, wanted, reason, sourceUserId, sourceUserJob)
	SetUserProps(tIdentifier, reason, { wanted = wanted }, sourceUserId, sourceUserJob)
end
exports('setUserWantedState', SetUserWantedState)

-- Jobs User Activity
-- activityType: 1 = HIRED, 2 = FIRED, 3 = PROMOTED, 4 = DEMOTED
--- Add a job colleague activity entry.
---@param job string
---@param sIdentifier string
---@param tIdentifier string
---@param activityType number
---@param reason string
---@param data table|nil
function AddJobColleagueActivity(job, sIdentifier, tIdentifier, activityType, reason, data)
	local sourceUserId = GetUserIDFromIdentifier(sIdentifier)
	local targetUserId = GetUserIDFromIdentifier(tIdentifier)

	exports[GetCurrentResourceName()]:AddColleagueActivity({
		colleagueActivity = {
			sourceUserId = sourceUserId,
			targetUserId = targetUserId,
			job = job,
			activityType = activityType,
			reason = reason,
			data = (data and { data = data } or nil),
		},
	})
end
exports('addJobColleagueActivity', AddJobColleagueActivity)

-- Jobs User Props
--- Set colleague props for a target identifier.
---@param identifier string
---@param reason string|nil
---@param props table
---@param sourceUserId number|nil User DB ID to attribute the change to.
---@param sourceUserJob string|nil Job to attribute the change to.
--- The helper mutates `props` by adding `userId`.
function SetColleagueProps(identifier, reason, props, sourceUserId, sourceUserJob)
	local userId = GetUserIDFromIdentifier(identifier)
	props.userId = userId

	exports[GetCurrentResourceName()]:AddColleagueProps({
		colleagueProps = {
			reason = reason,
			props = props,
		},
		sourceUser = (sourceUserId or sourceUserJob) and {
			userId = sourceUserId,
			job = sourceUserJob,
		} or nil,
	})
end
exports('setColleagueProps', SetColleagueProps)

--- Get vehicle props for a plate.
---@param plate string
---@return GetVehiclePropsResponse
function GetVehicleProps(plate)
	return exports[GetCurrentResourceName()]:GetVehicleProps({
		plate = plate,
	})
end
exports('getVehicleProps', GetVehicleProps)

--- Set vehicle props for a plate.
---@param plate string
---@param reason string|nil
---@param data table
---@param sourceUserId number|nil User DB ID to attribute the change to.
---@param sourceUserJob string|nil Job to attribute the change to.
--- The helper mutates `data` by adding `plate`.
function SetVehicleProps(plate, reason, data, sourceUserId, sourceUserJob)
	data.plate = plate

	return exports[GetCurrentResourceName()]:SetVehicleProps({
		vehicleProps = data,
		reason = reason,
		sourceUser = (sourceUserId or sourceUserJob) and {
			userId = sourceUserId,
			job = sourceUserJob,
		} or nil,
	})
end
exports('setVehicleProps', SetVehicleProps)
