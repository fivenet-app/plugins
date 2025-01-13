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

-- DO NOT change this, the token length is currently hard coded
local TokenLength = 6

local function generateToken()
	local token = ''
	for i = 1, TokenLength do
		token = token..math.random(1, 9)
	end

	return token
end

local function createToken(license --[[string]])
	local token = generateToken()

	MySQL.update('INSERT INTO fivenet_accounts (enabled, license, reg_token) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE reg_token = ?', { 1, license, token, token })
	return token
end

local function resetPassword(license)
	local token = generateToken()

	MySQL.update('UPDATE fivenet_accounts SET password = NULL, reg_token = ? WHERE license = ?', { token, license })
	return token
end

AddEventHandler('fivenet:resetPassword', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local license = getLicenseFromIdentifier(xPlayer.identifier)

	local registered = isRegistered(license)
	local token = resetPassword(license)

	TriggerClientEvent('fivenet:resetPassword', source, registered, token)
end)

function openTokenMgmt(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local license = getLicenseFromIdentifier(xPlayer.identifier)

	local registered, token = isRegistered(license)
	if not registered and not token then
		token = createToken(license)
	end

	TriggerClientEvent('fivenet:registration', source, registered, token)
end

AddEventHandler('fivenet:openTokenMgmt', function()
	local source = source
	openTokenMgmt(source)
end)

RegisterCommand('fivenet', function(source)
	openTokenMgmt(source)
end)
