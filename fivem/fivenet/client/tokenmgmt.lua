local usingTokenMgmt = false -- false = closed, true = open

function IsInTokenMgmt()
	return usingTokenMgmt and true or false
end

RegisterNUICallback('exit', function(data, cb)
	usingTokenMgmt = false

	if not IsInTablet() then
		SetNuiFocus(false, false)
	end

	cb(true)
end)

RegisterNUICallback('resetPassword', function(data, cb)
	TriggerServerEvent('fivenet:resetPassword')

	cb(true)
end)

RegisterNetEvent('fivenet:resetPassword', function(registered, token)
	usingTokenMgmt = true
	SendLocaleToNUI()

	SendNUIMessage({
		type = 'token',
		data = {
			username = registered,
			token = token,
		},
		webUrl = Config.WebURL,
	})

	TriggerEvent('notifications', Locale('token.reset', { token = token }), 'FIVENET', 'success')
end)

RegisterNetEvent('fivenet:registration', function(registered, token)
	if not registered and not token then return end

	usingTokenMgmt = true
	SendLocaleToNUI()
	SetNuiFocus(true, true)
	SendNUIMessage({
		type = 'token',
		data = {
			username = registered,
			token = token,
		},
		webUrl = Config.WebURL,
	})
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/fivenet', Locale('token.open'))
end)
