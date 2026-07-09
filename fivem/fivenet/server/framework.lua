-- Multi framework handling
--
-- Heavily inspired by <https://github.com/nwvh/wx_bridge> and <https://github.com/meesvrh/fmLib> projects
--

ESX = nil
QBCore = nil

if Config.Framework == 'esx' then
	ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbcore' then
	QBCore = exports['qb-core']:GetCoreObject()
else
	print('ERROR: No framework selected for FiveNet, this will cause FiveNet to not work correctly!')
end

--- Extract the bare license portion from an identifier string.
---@param identifier string
---@return string
function getLicenseFromIdentifier(identifier --[[string]])
	local start = string.find(identifier, ':', 1, true)
	if not start then return identifier end

	return string.sub(identifier, start + 1, -1)
end

-- Framework independent functions

--- Resolve the framework identifier for a player source.
--- ESX returns the character identifier.
--- QB-Core returns `cid:license`.
---@param source number
---@return string|nil
function getPlayerUniqueIdentifier(source)
	if Config.Framework == 'esx' then
		-- ESX
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return nil
		end

		return xPlayer.identifier
	elseif Config.Framework == 'qbcore' then
		-- QBCore
		local player = QBCore.Functions.GetPlayer(source)
		if not player then
			return nil
		end

		return player.PlayerData.cid .. ':' .. getLicenseFromIdentifier(player.PlayerData.license)
	end

	-- Fallback
	local license
	for _, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, 'license:') then
			license = v
			break
		end
	end

	return license
end
exports('getPlayerUniqueIdentifier', getPlayerUniqueIdentifier)

--- Resolve the FiveNet user DB ID for a framework identifier.
--- ESX expects the character identifier.
--- QB-Core expects `cid:license`.
---@param identifier string
---@return number
function getUserIDFromIdentifier(identifier --[[string]])
	local query
	local params = { identifier }

	if Config.Framework == 'esx' then
		query = 'SELECT `id` FROM `users` WHERE `identifier` = ? LIMIT 1'
	elseif Config.Framework == 'qbcore' then
		params[1] = getLicenseFromIdentifier(identifier)
		params[2] = string.sub(identifier, 1, (string.find(identifier, ':', 1, true) or 0) - 1)

		query = 'SELECT `id` FROM `players` WHERE `citizenid` = ? AND `cid` = ? LIMIT 1'
	else
		return 0
	end

	local row = MySQL.single.await(query, params)
	if not row then
		return 0
	end

	return row.id
end
exports('getUserIDFromIdentifier', getUserIDFromIdentifier)

--- Resolve the FiveNet user DB ID for a player source.
---@param source number
---@return number|nil
function getUserDBID(source)
	if Config.Framework == 'esx' then
		-- ESX
		-- ESX doesn't select the `id` at all when loading the player, so we need to query it ourselves
		return getUserIDFromIdentifier(getPlayerUniqueIdentifier(source))
	elseif Config.Framework == 'qbcore' then
		-- QBCore
		local player = QBCore.Functions.GetPlayer(source)
		if not player then
			return nil
		end

		if player.PlayerData.id ~= nil then
			return player.PlayerData.id
		end

		return getUserIDFromIdentifier(getPlayerUniqueIdentifier(source))
	end

	-- Fallback
	return 0
end
exports('getUserDBID', getUserDBID)

--- Return the player's job information for the active framework.
---@param source number
---@return table
function getPlayerJob(source)
	if Config.Framework == 'esx' then
		-- ESX
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return nil
		end

		return {
			name = xPlayer.job.name,
			label = xPlayer.job.label,
			grade = xPlayer.job.grade,
			gradeLabel = xPlayer.job.grade_label
		}
	elseif Config.Framework == 'qbcore' then
		-- QBCore
		local player = QBCore.Functions.GetPlayer(source)
		return {
			name = player.PlayerData.job.name,
			label = player.PlayerData.job.label,
			grade = player.PlayerData.job.grade.level,
			gradeLabel = player.PlayerData.job.grade.name
		}
	end

	-- Fallback
	return {
		name = 'unemployed',
		label = 'Unemployed',
		grade = 0,
		gradeLabel = 'Unemployed'
	}
end

--- Return the framework player object for a source.
---@param source number
---@return table|nil
function getPlayerById(source)
	if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(source)
    end

    return nil
end

--- Return the framework-specific player list.
---@return table
function getPlayers()
	if Config.Framework == 'esx' then
        return ESX.GetExtendedPlayers()
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetQBPlayers()
    end

    return {}
end
