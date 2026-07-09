-- Setup API client on resource start
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		exports[GetCurrentResourceName()]:SetupClient(Config.API.Host, Config.API.Token, Config.API.Insecure, Config.Debug)
	end
end)

--- Build a FiveNet timestamp payload.
---@return table
function getCurrentTimestamp() --[[resources.timestamp.Timestamp]]
	return { timestamp = { seconds = GetCloudTimeAsInt(), nanos = 0 } }
end

-- Helper functions

--- Check if a player is near a vector.
---@param source number
---@param targetVector vector3
---@param range number|nil
---@return boolean
-- Written by mcNuggets of the ModernV server
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

--- Check whether billing activity should be tracked for a job.
---@param targetJob string
---@return boolean|nil
function checkIfBillingEnabledJob(targetJob --[[string]])
	local job = string.gsub(targetJob, 'society_', '')
	return Config.Events.BillingJobs[job]
end

--- Connect a Discord OAuth2 identity to a FiveNet account.
---@param license string
---@param externalId string
---@param username string
function addOAuth2DiscordIdentifier(license --[[string]], externalId --[[string]], username --[[string]])
	exports[GetCurrentResourceName()]:AddUserOAuth2Conn({
		userOauth2 = {
			providerName = Config.Discord.OAuth2Provider,
			identifier = getLicenseFromIdentifier(license),
			externalId = externalId,
			username = username,
		},
	})
end

-- User Activity and Props
--- Add a user activity entry.
---@param sIdentifier string|nil
---@param tIdentifier string
---@param type number
---@param reason string
---@param data table|nil
--- If `sIdentifier` is omitted, the target user's DB ID is reused as the source user.
function addUserActivity(sIdentifier --[[string/nil]], tIdentifier --[[string]], type --[[number]], reason --[[string]], data --[[UserActivityData]])
	local sourceUserId = nil
	if not sIdentifier then
		sourceUserId = getUserIDFromIdentifier(tIdentifier)
	end

	local targetUserId = getUserIDFromIdentifier(tIdentifier)

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
exports('addUserActivity', addUserActivity)

--- Set user properties for a target identifier.
---@param identifier string
---@param reason string|nil
---@param data table
--- The helper mutates `data` by adding `userId`.
function setUserProps(identifier --[[string]], reason --[[string]], data --[[UserProps]])
	local userId = getUserIDFromIdentifier(identifier)
	data.userId = userId

	exports[GetCurrentResourceName()]:AddUserProps({
		userProps = {
			reason = reason,
			props = data,
		},
	})
end
exports('setUserProps', setUserProps)

--- Add or subtract from the open fine total for a user.
---@param tIdentifier string
---@param fine number
function updateOpenFines(tIdentifier --[[string]], fine --[[number]])
	setUserProps(tIdentifier, nil, { openFines = fine })
end
exports('updateOpenFines', updateOpenFines)

--- Set the wanted state for a user.
---@param tIdentifier string
---@param wanted boolean
---@param reason string|nil
function setUserWantedState(tIdentifier --[[string]], wanted --[[bool]], reason --[[string/nil]])
	setUserProps(tIdentifier, reason, { wanted = wanted })
end
exports('setUserWantedState', setUserWantedState)

--- Set the blood type for a user.
---@param tIdentifier string
---@param bloodType string
function setUserBloodType(tIdentifier --[[string]], bloodType --[[string]])
	setUserProps(tIdentifier, nil, { bloodType = bloodType })
end
exports('setUserBloodType', setUserBloodType)

-- Jobs User Activity
-- activityType: 1 = HIRED, 2 = FIRED, 3 = PROMOTED, 4 = DEMOTED
--- Add a job colleague activity entry.
---@param job string
---@param sIdentifier string
---@param tIdentifier string
---@param activityType number
---@param reason string
---@param data table|nil
function addJobColleagueActivity(job --[[string]], sIdentifier --[[string]], tIdentifier --[[string]], activityType --[[number]], reason --[[string]], data --[[JobColleagueActivityData]])
	local sourceUserId = getUserIDFromIdentifier(sIdentifier)
	local targetUserId = getUserIDFromIdentifier(tIdentifier)

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
exports('addJobColleagueActivity', addJobColleagueActivity)

-- Jobs User Props
--- Set colleague properties for a target identifier.
---@param identifier string
---@param reason string|nil
---@param props table
--- The helper mutates `props` by adding `userId`.
function setColleagueProps(identifier --[[string]], reason --[[string]], props --[[ColleagueProps]])
	local userId = getUserIDFromIdentifier(identifier)
	props.userId = userId


	exports[GetCurrentResourceName()]:AddColleagueProps({
		colleagueProps = {
			reason = reason,
			props = props,
		},
	})
end
exports('setColleagueProps', setColleagueProps)

-- Dispatches
--- Normalize the dispatch job payload into the FiveNet API shape.
---@param job string|table
---@return table
local function normalizeDispatchJobs(job --[[string/table]])
	local jobs = {}

	if type(job) ~= "table" then
		job = { job }
	end

	for _, entry in ipairs(job) do
		if type(entry) == "table" then
			jobs[#jobs + 1] = {
				name = entry.name,
			}
		else
			jobs[#jobs + 1] = {
				name = entry,
			}
		end
	end

	return {
		jobs = jobs,
	}
end

--- Create a dispatch for a DB user ID.
---@param job string|table
---@param message string
---@param description string
---@param x number
---@param y number
---@param anon boolean
---@param userId number|nil
function createDispatch(job --[[string/table]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], userId --[[number]])
	exports[GetCurrentResourceName()]:AddDispatch({
		dispatch = {
			id = 0,
			jobs = normalizeDispatchJobs(job),
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

--- Create a dispatch for a player identifier.
---@param job string|table
---@param message string
---@param description string
---@param x number
---@param y number
---@param anon boolean
---@param identifier string
function createDispatchFromIdentifier(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], identifier --[[string]])
	local userId = getUserIDFromIdentifier(identifier)

	createDispatch(job, message, description, x, y, anon, userId)
end
exports('createDispatchFromIdentifier', createDispatchFromIdentifier)

if not Config.Dispatches.DisableClientDispatches then
		AddEventHandler('fivenet:createDispatch', function(source, job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
		local userId = nil
		if not anon then
			userId = getUserDBID(source)
		end

		createDispatch(job, message, description, x, y, anon, userId)
	end)

	RegisterNetEvent('fivenet:createDispatchFromClient')
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
end

-- Timeclock
--- Set a timeclock entry for a user identifier.
---@param identifier string
---@param data table
function setTimeclockEntry(identifier --[[string]], data --[[TimeclockUpdate]])
	local userId = getUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddJobTimeclock({
		jobTimeclock = data,
	})
end

-- User Updates (use carefully! Only available when the ESX compatibility mode is disabled on the FiveNet server)
--- Send a low-level user update.
---@param identifier string
---@param data table
function sendUserUpdate(identifier --[[string]], data --[[UserUpdate]])
	local userId = getUserIDFromIdentifier(identifier)

	data.userId = userId

	exports[GetCurrentResourceName()]:AddUserUpdate({
		userUpdate = data,
	})
end

--- Set the last character ID for a user identifier.
---@param identifier string
function setLastCharID(identifier --[[string]])
	local userId = getUserIDFromIdentifier(identifier)

	exports[GetCurrentResourceName()]:SetLastCharID({
		lastCharId = {
			identifier = identifier,
			lastCharId = userId,
		},
	})
end
