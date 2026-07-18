Logger = Logger or {}

local prefixes = {
	debug = '^5[DEBUG]^7',
	info = '^2[INFO]^7',
	warn = '^3[WARN]^7',
	error = '^1[ERROR]^7',
}

local values = {
	debug = 10,
	info = 20,
	warn = 30,
	error = 40,
	off = 50,
}

Logger.level = Logger.level or values.info

function Logger.setLevel(level)
	if values[level] then
		Logger.level = values[level]
	else
		Logger.level = values.info
	end
end

function Logger.isDebugEnabled()
	return Logger.level <= values.debug
end

local function shouldLog(level)
	return values[level] >= Logger.level
end

local function log(level, message)
	if not shouldLog(level) then return end

	print(('%s %s'):format(prefixes[level], tostring(message)))
end

function Logger.debug(message)
	log('debug', message)
end

function Logger.info(message)
	log('info', message)
end

function Logger.warn(message)
	log('warn', message)
end

function Logger.error(message)
	log('error', message)
end
