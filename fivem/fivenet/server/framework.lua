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

-- Extract license from identifier (e.g., 'license:abcd1234' -> 'abcd1234')
function getLicenseFromIdentifier(identifier --[[string]])
	local start = string.find(identifier, ':', 1, true)
	if not start then return identifier end

	return string.sub(identifier, start + 1, -1)
end

-- Framework independent functions

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

		return player.PlayerData.cid .. ':' .. player.PlayerData.citizenid
	else
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
end
exports('getPlayerUniqueIdentifier', getPlayerUniqueIdentifier)

-- Get user ID from identifier (retrieves the user DB ID by identifier, depending on the framework using a database query)
-- ESX: Requires the char/user identifier to be passed (e.g., 'char1:abcd1234')
-- QBCore: Requires the citizenid to be passed
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

-- Get user database ID from source arg
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
	else
		-- Fallback
		return 0
	end
end
exports('getUserDBID', getUserDBID)

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

function getPlayerById(source)
	if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(source)
    end

    return nil
end

function getPlayers()
	if Config.Framework == 'esx' then
        return ESX.GetExtendedPlayers()
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetQBPlayers()
    end

    return {}
end
