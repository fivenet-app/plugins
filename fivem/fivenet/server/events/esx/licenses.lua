-- These are non standard events, they need to be added by yourself to take advantage of
-- the job user activity tracking

---@param type string
---@return string
local function lookupLicenseLabel(type --[[string]])
	local label = MySQL.scalar.await('SELECT `label` FROM `licenses` WHERE `type` = ? LIMIT 1', { type })
	if not label then
		return type
	end
	return label
end

if Config.Framework == 'esx' then
	AddEventHandler('esx_license:addLicense', function(sourceXPlayer, targetXPlayer, type)
		local label = lookupLicenseLabel(type)
		local data = { oneofKind = 'licensesChange', licensesChange = { added = true, licenses = {{ type = type, label = label }} }}

		AddUserActivity(sourceXPlayer.identifier, targetXPlayer.identifier, 5, '', data)
	end)

	AddEventHandler('esx_license:removeLicense', function(sourceXPlayer, targetXPlayer, type)
		local label = lookupLicenseLabel(type)
		local data = { oneofKind = 'licensesChange', licensesChange = { added = false, licenses = {{ type = type, label = label }} }}

		AddUserActivity(sourceXPlayer.identifier, targetXPlayer.identifier, 5, '', data)
	end)
end
