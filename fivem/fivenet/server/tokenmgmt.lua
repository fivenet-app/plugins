RegisterNetEvent('fivenet:resetPassword')
RegisterNetEvent('fivenet:openTokenMgmt')

AddEventHandler('fivenet:resetPassword', function()
	local source = source

	local identifier = GetPlayerUniqueIdentifier(source)
	if not identifier then
		Logger.error(('No identifier returned for player %s.'):format(source))
		return
	end

	local license = GetLicenseFromIdentifier(identifier)

	local data = exports[GetCurrentResourceName()]:RegisterAccount(license, true)

	TriggerClientEvent('fivenet:resetPassword', source, data.username, data.regToken)
end)

function OpenTokenMgmt(source)
	local identifier = GetPlayerUniqueIdentifier(source)
	if not identifier then
		Logger.error(('No identifier returned for player %s.'):format(source))
		return
	end

	local license = GetLicenseFromIdentifier(identifier)

	local data = exports[GetCurrentResourceName()]:RegisterAccount(license, false)

	TriggerClientEvent('fivenet:registration', source, data.username, data.regToken)
end

AddEventHandler('fivenet:openTokenMgmt', function()
	local source = source
	OpenTokenMgmt(source)
end)

RegisterCommand('fivenet', function(source)
	if source == 0 then
		Logger.warn('/fivenet command is only for players.')
		return
	end

	OpenTokenMgmt(source)
end)
