--- Build a FiveNet timestamp payload.
---@return table
function GetCurrentTimestamp() --[[resources.timestamp.Timestamp]]
	return { timestamp = { seconds = GetCloudTimeAsInt(), nanos = 0 } }
end

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
function CheckIfBillingEnabledJob(targetJob --[[string]])
	local job = string.gsub(targetJob, 'society_', '')
	return Config.Events.BillingJobs[job]
end

--- Connect a Discord OAuth2 identity to a FiveNet account.
---@param license string
---@param externalId string
---@param username string
function AddOAuth2DiscordIdentifier(license --[[string]], externalId --[[string]], username --[[string]])
	exports[GetCurrentResourceName()]:AddUserOAuth2Conn({
		userOauth2 = {
			providerName = Config.Discord.OAuth2Provider,
			identifier = GetLicenseFromIdentifier(license),
			externalId = externalId,
			username = username,
		},
	})
end
