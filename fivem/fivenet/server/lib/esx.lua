--- Resolve an ESX player object from common custom event payload shapes.
---@param player string|number|table|nil
---@return table|nil
function GetESXPlayer(player)
	if not player then return nil end

	if type(player) == 'number' then
		return ESX.GetPlayerFromId(player)
	end

	if type(player) == 'table' then
		return player
	end

	return nil
end

--- Resolve an ESX character identifier from common custom event payload shapes.
---@param player string|number|table|nil
---@return string|nil
function GetESXPlayerIdentifier(player)
	if not player then return nil end
	if type(player) == 'string' then return player end

	local xPlayer = GetESXPlayer(player)
	if not xPlayer then return nil end

	return xPlayer.identifier
end

--- Resolve ESX job data from common custom event payload shapes.
---@param player number|table|nil
---@return table|nil
function GetESXPlayerJob(player)
	local xPlayer = GetESXPlayer(player)
	if not xPlayer then return nil end

	return xPlayer.job
end
