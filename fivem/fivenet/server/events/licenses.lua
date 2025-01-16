-- These are non standard events, they need to be added by yourself to take advantage of
-- the job user activity tracking

local function lookupLicenseLabel(type)
	local response = MySQL.query.await('SELECT `label` FROM `licenses` WHERE `type` = ? LIMIT 1', { type })
	if response then
		return response[1].label or ''
	end

	return ''
end

AddEventHandler('esx_license:addLicense', function(sourceXPlayer, targetXPlayer, type)
	local label = lookupLicenseLabel(type)
	local data = { licensesChange = { added = true, licenses = [{ type = type, label = label }] }}

	addUserActivity(sourceXPlayer.identifier, targetXPlayer.identifier, 5, '', json.encode(data))
end)

AddEventHandler('esx_license:removeLicense', function(sourceXPlayer, targetXPlayer, type)
	local label = lookupLicenseLabel(type)
	local data = { licensesChange = { added = false, licenses = [{ type = type, label = label }] }}

	addUserActivity(sourceXPlayer.identifier, targetXPlayer.identifier, 5, '', json.encode(data))
end)
