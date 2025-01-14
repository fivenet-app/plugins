RegisterNetEvent('fivenet:resetPassword')
RegisterNetEvent('fivenet:openTokenMgmt')

function getLicenseFromIdentifier(identifier --[[string]])
	local start = string.find(identifier, ':', 1, true)
	if not start then return identifier end

	return string.sub(identifier, start + 1, -1)
end

local function isRegistered(license --[[string]])
	local query = MySQL.single.await('SELECT username, reg_token FROM fivenet_accounts WHERE license = ?', { license })
	if query then
		return query.username, query.reg_token
	end

	return false, nil
end

AddEventHandler('fivenet:resetPassword', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local license = getLicenseFromIdentifier(xPlayer.identifier)

	local data = exports[GetCurrentResourceName()]:RegisterAccount(license, true)

	TriggerClientEvent('fivenet:resetPassword', source, data.username, data.regToken)
end)

function openTokenMgmt(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local license = getLicenseFromIdentifier(xPlayer.identifier)

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
