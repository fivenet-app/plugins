-- Written by mcnuggets
function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Wait(10)
		end
	end
end

-- Sends the configured client locale to the NUI. The UI can use this when i18n is added.
function SendLocaleToNUI()
	SendNUIMessage({ type = 'setLocale', locale = GetLocale() })
end

-- Allows another client resource to change the locale used by FiveNet and its NUI.
AddEventHandler('fivenet:setLocale', function(locale)
	if type(locale) ~= 'string' or locale == '' then return end

	Config.Locale = locale
	SendLocaleToNUI()
end)

exports('getLocale', GetLocale)
