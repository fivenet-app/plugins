function getLicenseFromIdentifier(identifier --[[string]])
	local start = string.find(identifier, ':', 1, true)
	if not start then return identifier end

	return string.sub(identifier, start + 1, -1)
end

local function getUserIDFromIdentifier(identifier --[[string]])
	local query
	if Config.Framework == 'esx' then
		query = 'SELECT `id` FROM `users` WHERE `identifier` = ? LIMIT 1'
	elseif Config.Framework == 'qbcore' then
		query = 'SELECT `id` FROM `players` WHERE `citizenid` = ? LIMIT 1'
	else
		return 0
	end

	local row = MySQL.single.await(query, { identifier })
	if not row then
		return 0
	end

	return row.id
end

function checkIfBillingEnabledJob(targetJob --[[string]])
	local job = string.gsub(targetJob, 'society_', '')
	return Config.Events.BillingJobs[job]
end

-- FiveNet Account - Social Login connection
function addOAuth2DiscordIdentifier(license --[[string]], externalId --[[string]], username --[[string]])
	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'userOauth2',
		userOauth2 = {
			providerName = Config.Discord.OAuth2Provider,
			identifier = getLicenseFromIdentifier(license),
			externalId = externalId,
			username = username,
		},
	})
end

-- User Activity and Props
function addUserActivity(sIdentifier --[[string/nil]], tIdentifier --[[string]], type --[[number]], reason --[[string]], data --[[UserActivityData]])
	local sourceUserId = nil
	if not sIdentifier then
		sourceUserId = getUserIDFromIdentifier(tIdentifier)
	end

	local targetUserId = getUserIDFromIdentifier(tIdentifier)

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'userActivity',
		userActivity = {
			sourceUserId = sourceUserId,
			targetUserId = targetUserId,
			type = type,
			reason = reason,
			data = data,
		},
	})
end
exports('addUserActivity', addUserActivity)

function setUserProps(identifier --[[string]], reason --[[string]], data --[[UserProps]])
	local userId = getUserIDFromIdentifier(identifier)
	data.userId = userId

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'userProps',
		userProps = {
			reason = reason,
			props = data,
		},
	})
end
exports('setUserProps', setUserProps)

-- If the `fine` is positive will be added and if negative substracted to/from the user's total
function updateOpenFines(tIdentifier --[[string]], fine --[[number]])
	setUserProps(tIdentifier, nil, { openFines = fine })
end
exports('updateOpenFines', updateOpenFines)

function setUserWantedState(tIdentifier --[[string]], wanted --[[bool]], reason --[[string/nil]])
	setUserProps(tIdentifier, reason, { wanted = wanted })
end
exports('setUserWantedState', setUserWantedState)

function setUserBloodType(tIdentifier --[[string]], bloodType --[[string]])
	setUserProps(tIdentifier, nil, { bloodType = bloodType })
end
exports('setUserBloodType', setUserBloodType)

-- Jobs User Activity
-- activityType: 1 = HIRED, 2 = FIRED, 3 = PROMOTED, 4 = DEMOTED
function addJobsUserActivity(job --[[string]], sIdentifier --[[string]], tIdentifier --[[string]], type --[[number]], reason --[[string]], data --[[JobsUserActivityData]])
	local sourceUserId = getUserIDFromIdentifier(sIdentifier)
	local targetUserId = getUserIDFromIdentifier(tIdentifier)

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'jobsUserActivity',
		jobsUserActivity = {
			sourceUserId = sourceUserId,
			targetUserId = targetUserId,
			job = job,
			type = type,
			reason = reason,
			data = data,
		},
	})
end
exports('addJobsUserActivity', addJobsUserActivity)

-- Dispatches
function createDispatch(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], identifier --[[string]])
	local userId = getUserIDFromIdentifier(identifier)

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'dispatch',
		dispatch = {
			id = 0,
			job = job,
			message = message,
			description = description,
			x = x,
			y = y,
			anon = anon,
			creatorId = userId,
			units = {},
		},
	})
end
exports('createDispatch', createDispatch)

function createCivilProtectionJobDispatch(message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], identifier --[[string]])
	for job, _ in pairs(Config.Dispatches.CivilProtectionJobs) do
		createDispatch(job, message, description, x, y, anon, identifier)
	end
end
exports('createCivilProtectionJobDispatch', createCivilProtectionJobDispatch)

-- Timeclock
function setTimeclockEntry(identifier --[[string]], data --[[TimeclockEntry]])
	local userId = getUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'jobsTimeclock',
		jobsTimeclock = data,
	})
end

-- Written by mcnuggets
function IsNearVector(source, targetVector, range)
	range = range or 3.0

	local sourcePed = GetPlayerPed(source)
	if sourcePed == 0 then return false end
	local sourceCoords = GetEntityCoords(sourcePed)

	if #(sourceCoords - targetVector) > range then
		return false
	end

	return true
end
