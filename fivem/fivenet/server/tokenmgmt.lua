RegisterNetEvent('fivenet:resetPassword')
RegisterNetEvent('fivenet:openTokenMgmt')

AddEventHandler('fivenet:resetPassword', function()
	local source = source

	local identifier = getPlayerUniqueIdentifier(source)
	if not identifier then
		print('no identifier returned for player', source)
		return
	end

	local license = getLicenseFromIdentifier(identifier)

	local data = exports[GetCurrentResourceName()]:RegisterAccount(license, true)

	TriggerClientEvent('fivenet:resetPassword', source, data.username, data.regToken)
end)

function openTokenMgmt(source)
	local identifier = getPlayerUniqueIdentifier(source)
	if not identifier then
		print('no identifier returned for player', source)
		return
	end

	local license = getLicenseFromIdentifier(identifier)

	local data = exports[GetCurrentResourceName()]:RegisterAccount(license, false)

	TriggerClientEvent('fivenet:registration', source, data.username, data.regToken)
end

AddEventHandler('fivenet:openTokenMgmt', function()
	local source = source
	openTokenMgmt(source)
end)

RegisterCommand('fivenet', function(source)
	if source == 0 then
		print('/fivenet command is only for players!')
		return
	end

	openTokenMgmt(source)
end)
