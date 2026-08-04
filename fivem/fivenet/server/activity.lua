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
--- The helper mutates `data` by adding `userId`.
function SetUserProps(identifier, reason, data)
	local userId = GetUserIDFromIdentifier(identifier)
	data.userId = userId

	exports[GetCurrentResourceName()]:AddUserProps({
		userProps = {
			reason = reason,
			props = data,
		},
	})
end
exports('setUserProps', SetUserProps)

--- Add or subtract from the open fine total for a user.
---@param tIdentifier string
---@param fine number
function UpdateOpenFines(tIdentifier, fine)
	SetUserProps(tIdentifier, nil, { openFines = fine })
end
exports('updateOpenFines', UpdateOpenFines)

--- Set the wanted state for a user.
---@param tIdentifier string
---@param wanted boolean
---@param reason string|nil
function SetUserWantedState(tIdentifier, wanted, reason)
	SetUserProps(tIdentifier, reason, { wanted = wanted })
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
--- The helper mutates `props` by adding `userId`.
function SetColleagueProps(identifier, reason, props)
	local userId = GetUserIDFromIdentifier(identifier)
	props.userId = userId

	exports[GetCurrentResourceName()]:AddColleagueProps({
		colleagueProps = {
			reason = reason,
			props = props,
		},
	})
end
exports('setColleagueProps', SetColleagueProps)
