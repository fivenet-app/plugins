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
		return player.PlayerData.citizenid
	else
		-- Fallback
		local license
		for k, v in ipairs(GetPlayerIdentifiers(source)) do
			if string.match(v, 'license:') then
				license = v
				break
			end
		end

		return license
	end
end

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
	else
		-- Fallback
		return {
			name = 'unemployed',
			label = 'Unemployed',
			grade = 0,
			gradeLabel = 'Unemployed'
		}
	end

	return nil
end

function getPlayerById(source)
	if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        QBCore.Functions.GetPlayer(source)
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
