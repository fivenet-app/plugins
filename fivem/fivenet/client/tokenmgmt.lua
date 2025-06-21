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

	SendNUIMessage({
		type = 'token',
		data = {
			username = registered,
			token = token,
		},
		webUrl = Config.WebURL,
	})

	TriggerEvent('notifications', 'Nutze den Token ~g~'..token..'~s~, um dein FiveNet-Passwort zurückzusetzen.', 'FIVENET', 'success')
end)

RegisterNetEvent('fivenet:registration', function(registered, token)
	if not registered and not token then return end

	usingTokenMgmt = true
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

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/fivenet', 'FiveNet Konto-Verwaltung öffnen')
end)
