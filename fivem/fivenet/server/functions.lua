function getLicenseFromIdentifier(identifier --[[string]])
	local start = string.find(identifier, ':', 1, true)
	if not start then return identifier end

	return string.sub(identifier, start + 1, -1)
end

local function getUserIDFromIdentifier(identifier --[[string]])
	local query
	local params = { identifier }

	if Config.Framework == 'esx' then
		query = 'SELECT `id` FROM `users` WHERE `identifier` = ? LIMIT 1'
	elseif Config.Framework == 'qbcore' then
		params[1] = getLicenseFromIdentifier(identifier)
		params[2] = string.sub(identifier, 1, (string.find(identifier, ':', 1, true) or 0) - 1)

		query = 'SELECT `id` FROM `players` WHERE `citizenid` = ? AND `cid` = ? LIMIT 1'
	else
		return 0
	end

	local row = MySQL.single.await(query, params)
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
			data = (data and { data = data } or nil),
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
function addJobColleagueActivity(job --[[string]], sIdentifier --[[string]], tIdentifier --[[string]], activityType --[[number]], reason --[[string]], data --[[JobColleagueActivityData]])
	local sourceUserId = getUserIDFromIdentifier(sIdentifier)
	local targetUserId = getUserIDFromIdentifier(tIdentifier)

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'colleagueActivity',
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
exports('addJobColleagueActivity', addJobColleagueActivity)

-- Jobs User Props
function addColleagueProps(identifier --[[string]], reason --[[string]], props --[[ColleagueProps]])
	local userId = getUserIDFromIdentifier(identifier)
	props.userId = userId


	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'colleagueProps',
		colleagueProps = {
			reason = reason,
			props = props,
		},
	})
end
exports('addColleagueProps', addColleagueProps)

-- Dispatches
RegisterNetEvent('fivenet:createDispatchFromClient')

function createDispatchFromIdentifier(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], identifier --[[string]])
	local userId = getUserIDFromIdentifier(identifier)

	createDispatch(job, message, description, x, y, anon, userId)
end
exports('createDispatchFromIdentifier', createDispatchFromIdentifier)

function createDispatch(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], userId --[[number]])
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

AddEventHandler('fivenet:createDispatchFromClient', function(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
	local source = source

	-- If x or y is nil, get the player's current entity coordinates
	if x == nil or y == nil then
		local ped = GetPlayerPed(source)
		if ped and ped ~= 0 then
			local coords = GetEntityCoords(ped)
			x = coords.x
			y = coords.y
		end
	end

	TriggerEvent('fivenet:createDispatch', source, job, message, description, x, y, anon)
end)

AddEventHandler('fivenet:createDispatch', function(source, job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
	local userId = nil
	if not anon then
		if Config.Framework == 'qbcore' then
			userId = getUserIDFromIdentifier(getPlayerUniqueIdentifier(source))
		else
			userId = getLicenseFromIdentifier(getPlayerUniqueIdentifier(source))
		end
	end

	createDispatch(job, message, description, x, y, anon, userId)
end)

-- Timeclock
function setTimeclockEntry(identifier --[[string]], data --[[TimeclockUpdate]])
	local userId = getUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'jobTimeclock',
		jobTimeclock = data,
	})
end

-- User Updates (use carefully! Only available when the ESX compatibility mode is disabled on the FiveNet server)
function sendUserUpdate(identifier --[[string]], data --[[UserUpdate]])
	local userId = getUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddActivity({
		oneofKind = 'userUpdate',
		userUpdate = data,
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
