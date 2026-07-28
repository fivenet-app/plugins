local function isBlank(value)
	return value == nil or value == '' or (type(value) == 'string' and value:match('^%s*$') ~= nil)
end

local function isBoolean(value)
	return type(value) == 'boolean'
end

local function isLogLevel(value)
	return value == 'debug' or value == 'info' or value == 'warn' or value == 'error' or value == 'off'
end

local function getConvarIfSet(name)
	local value = GetConvar(name, '')
	if isBlank(value) then return nil end

	return value
end

local function applyConfigConvars()
	local apiHost = getConvarIfSet('fivenet_sync_api_host')
	if apiHost ~= nil then
		Config.API.Host = apiHost
	end

	local apiToken = getConvarIfSet('fivenet_sync_api_token')
	if apiToken ~= nil then
		Config.API.Token = apiToken
	end

	local apiInsecure = getConvarIfSet('fivenet_sync_api_insecure')
	if apiInsecure ~= nil then
		local value = apiInsecure:lower()
		Config.API.Insecure = value == 'true' or value == '1'
	end
end

local function validateConfig()
	local valid = true

	if Config == nil then
		Logger.error('Config is missing. Make sure config/server.lua is loaded before server/bootstrap.lua.')
		return false
	end

	if Config.Framework ~= 'esx' and Config.Framework ~= 'qbcore' then
		Logger.error(("Invalid Config.Framework: %s. Expected 'esx' or 'qbcore'."):format(tostring(Config.Framework)))
		valid = false
	end

	if Config.API == nil then
		Logger.warn('Missing Config.API section in config/server.lua, assuming convars are used for API.')
		Config.API = {}
	end

	applyConfigConvars()

	if type(Config.API.Host) ~= 'string' then
		Logger.error('Invalid Config.API.Host. Expected a host:port string, e.g. demo.fivenet.app:443.')
		valid = false
	elseif isBlank(Config.API.Host) then
		Logger.error('Missing Config.API.Host. Set it to your FiveNet DBSync API host, e.g. demo.fivenet.app:443.')
		valid = false
	elseif Config.API.Host:find('^https?://') then
		Logger.error('Invalid Config.API.Host. Do not include http:// or https://, use host:port only.')
		valid = false
	elseif Config.API.Host:sub(-1) == '/' then
		Logger.error('Invalid Config.API.Host. Do not include a trailing slash.')
		valid = false
	end

	if type(Config.API.Token) ~= 'string' then
		Logger.error('Invalid Config.API.Token. Expected your FiveNet DBSync API token as a string.')
		valid = false
	elseif isBlank(Config.API.Token) or Config.API.Token == 'YOUR_SYNC_API_TOKEN' then
		Logger.error('Missing Config.API.Token. Set it to your FiveNet DBSync API token.')
		valid = false
	end

	if not isBoolean(Config.API.Insecure) then
		Logger.error('Invalid Config.API.Insecure. Expected true or false.')
		valid = false
	end

	if Config.LogLevel ~= nil and not isLogLevel(Config.LogLevel) then
		Logger.error("Invalid Config.LogLevel. Expected 'debug', 'info', 'warn', 'error', or 'off'.")
		valid = false
	end

	if Config.Tracking and Config.Tracking.Enable and type(Config.Tracking.Interval) == 'number' and Config.Tracking.Interval < 3000 then
		Logger.warn(('Config.Tracking.Interval is %sms. Values below 3000ms may cause excessive load.'):format(Config.Tracking.Interval))
	end

	return valid
end

-- Setup the API client on resource start.
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end

	if not validateConfig() then
		Logger.error('FiveNet startup stopped because required config values are missing or invalid.')
		return
	end

	Logger.setLevel(Config and Config.LogLevel)
	exports[GetCurrentResourceName()]:setLogLevel(Config and Config.LogLevel)

	Logger.info('Config check passed. Starting FiveNet API.')

	exports[GetCurrentResourceName()]:SetupClient(
		Config.API.Host,
		Config.API.Token,
		Config.API.Insecure,
		Config.LogLevel
	)

	local initialStartConvar = 'fivenet_initial_start_done'
	local isInitialStart = GetConvar(initialStartConvar, 'false') ~= 'true'
	SetConvar(initialStartConvar, 'true')

	-- Only run cleanups on initial server start and not on every resource restart
	if not isInitialStart then return end

	if GetConvar('fivenet_locations_clear_on_start', 'false') == 'true' then
		CreateThread(function()
			Wait(1000)
			-- Clear user locations data
			exports[GetCurrentResourceName()]:SendUserLocations({
				users = {},
				clearAll = true,
			})
		end)
	end

	if GetConvar('fivenet_end_timeclock_on_start', 'false') == 'true' then
		CreateThread(function()
			Wait(1000)
			-- End timecloock entries
			exports[GetCurrentResourceName()]:EndActiveJobTimeclocks({
				users = {},
				clearAll = true,
			})
		end)
	end
end)
