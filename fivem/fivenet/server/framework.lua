-- Multi framework handling
--
-- Heavily inspired by <https://github.com/nwvh/wx_bridge> and <https://github.com/meesvrh/fmLib> projects
--

ESX = nil
QBCore = nil

local identifierToUserIdCache = {}
local identifierToUserIdCacheTtl = 60

local function clearIdentifierToUserIdCache(identifier --[[string]])
	if not identifier then return end

	identifierToUserIdCache[identifier] = nil
end

local function clearIdentifierToUserIdCacheForSource(playerId --[[number]])
	clearIdentifierToUserIdCache(GetPlayerUniqueIdentifier(playerId))
end

if Config.Framework == 'esx' then
	ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbcore' then
	QBCore = exports['qb-core']:GetCoreObject()
else
	print('ERROR: No framework selected for FiveNet, this will cause FiveNet to not work correctly!')
end

-- Framework independent functions

--- Resolve the framework identifier for a player source.
--- ESX returns the character identifier.
--- QB-Core returns `cid:license`.
---@param source number
---@return string|nil
function GetPlayerUniqueIdentifier(source)
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

		return player.PlayerData.cid .. ':' .. GetLicenseFromIdentifier(player.PlayerData.license)
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
exports('getPlayerUniqueIdentifier', GetPlayerUniqueIdentifier)

if Config.Framework == 'esx' then
	AddEventHandler('esx:playerDropped', function(playerId)
		clearIdentifierToUserIdCacheForSource(playerId)
	end)

	AddEventHandler('esx:playerLogout', function(playerId)
		clearIdentifierToUserIdCacheForSource(playerId)
	end)
elseif Config.Framework == 'qbcore' then
	AddEventHandler('QBCore:Server:OnPlayerUnload', function(playerId)
		clearIdentifierToUserIdCacheForSource(playerId)
	end)
end

--- Resolve the FiveNet user DB ID for a framework identifier.
--- ESX expects the character identifier.
--- QB-Core expects `cid:license`.
---@param identifier string
---@return number
function GetUserIDFromIdentifier(identifier --[[string]])
	local cachedEntry = identifierToUserIdCache[identifier]
	if cachedEntry ~= nil then
		if cachedEntry.expiresAt > os.time() then
			return cachedEntry.id
		end

		clearIdentifierToUserIdCache(identifier)
	end

	local query
	local params = { identifier }

	if Config.Framework == 'esx' then
		query = 'SELECT `id` FROM `users` WHERE `identifier` = ? LIMIT 1'
	elseif Config.Framework == 'qbcore' then
		params[1] = GetLicenseFromIdentifier(identifier)
		params[2] = string.sub(identifier, 1, (string.find(identifier, ':', 1, true) or 0) - 1)

		query = 'SELECT `id` FROM `players` WHERE `citizenid` = ? AND `cid` = ? LIMIT 1'
	else
		return 0
	end

	local id = MySQL.scalar.await(query, params)
	if not id then
		return 0
	end

	identifierToUserIdCache[identifier] = {
		id = id,
		expiresAt = os.time() + identifierToUserIdCacheTtl,
	}
	return id
end
exports('getUserIDFromIdentifier', GetUserIDFromIdentifier)

--- Resolve the FiveNet user DB ID for a player source.
---@param source number
---@return number|nil
function GetUserDBID(source)
	if Config.Framework == 'esx' then
		-- ESX
		-- ESX doesn't select the `id` at all when loading the player, so we need to query it ourselves
		return GetUserIDFromIdentifier(GetPlayerUniqueIdentifier(source))
	elseif Config.Framework == 'qbcore' then
		-- QBCore
		local player = QBCore.Functions.GetPlayer(source)
		if not player then
			return nil
		end

		if player.PlayerData.id ~= nil then
			return player.PlayerData.id
		end

		return GetUserIDFromIdentifier(GetPlayerUniqueIdentifier(source))
	end

	-- Fallback
	return 0
end
exports('getUserDBID', GetUserDBID)

--- Return the player's job information for the active framework.
---@param source number
---@return table
function GetPlayerJob(source)
	if Config.Framework == 'esx' then
		-- ESX
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return nil
		end

		return NormalizePlayerJob(xPlayer.job, xPlayer.job.onDuty)
	elseif Config.Framework == 'qbcore' then
		-- QBCore
		local player = QBCore.Functions.GetPlayer(source)
		if not player then
			return nil
		end

		return NormalizePlayerJob(player.PlayerData.job, player.PlayerData.job.onduty)
	end

	-- Fallback
	return {
		name = 'unemployed',
		label = 'Unemployed',
		grade = 0,
		gradeLabel = 'Unemployed',
		onDuty = false,
	}
end

--- Return the framework player object for a source.
---@param source number
---@return table|nil
function GetPlayerById(source)
	if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(source)
    end

    return nil
end

--- Return the framework-specific player list.
---@return table
function GetPlayers()
	if Config.Framework == 'esx' then
        return ESX.GetExtendedPlayers()
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetQBPlayers()
    end

    return {}
end
