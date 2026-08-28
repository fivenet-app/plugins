Locales = Locales or {}

local fallbackLocale = 'en'

function GetLocale()
	local locale = Config and Config.Locale
	if type(locale) ~= 'string' or locale == '' then return fallbackLocale end
	return locale
end

local function getValue(values, key)
	for part in string.gmatch(key, '[^.]+') do
		if type(values) ~= 'table' then return nil end
		values = values[part]
	end
	return values
end

function Locale(key, variables)
	local value = getValue(Locales[GetLocale()], key) or getValue(Locales[fallbackLocale], key)
	if type(value) ~= 'string' then return key end

	if type(variables) == 'table' then
		value = string.gsub(value, '%%{([%w_]+)}', function(name)
			local replacement = variables[name]
			return replacement == nil and ('%%{' .. name .. '}') or tostring(replacement)
		end)
	end

	return value
end
