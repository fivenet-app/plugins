-- Dispatches

--- Create a dispatch for a DB user ID.
---@param job string|table
---@param message string
---@param description string
---@param x number
---@param y number
---@param anon boolean
---@param userId number|nil
function CreateDispatch(job --[[string/table]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], userId --[[number]])
	exports[GetCurrentResourceName()]:AddDispatch({
		dispatch = {
			id = 0,
			jobs = NormalizeJobsToJobList(job),
			message = message,
			description = description,
			x = x,
			y = y,
			anon = anon,
			creatorId = userId,
			units = {},
		},
	})
end
exports('createDispatch', CreateDispatch)

--- Create a dispatch for a player identifier.
---@param job string|table
---@param message string
---@param description string
---@param x number
---@param y number
---@param anon boolean
---@param identifier string
function CreateDispatchFromIdentifier(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]], identifier --[[string]])
	local userId = GetUserIDFromIdentifier(identifier)

	CreateDispatch(job, message, description, x, y, anon, userId)
end
exports('createDispatchFromIdentifier', CreateDispatchFromIdentifier)

if not Config.Dispatches.DisableClientDispatches then
	AddEventHandler('fivenet:createDispatch', function(source, job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
		local userId = nil
		if not anon then
			userId = GetUserDBID(source)
		end

		CreateDispatch(job, message, description, x, y, anon, userId)
	end)

	RegisterNetEvent('fivenet:createDispatchFromClient')
	AddEventHandler('fivenet:createDispatchFromClient', function(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
		local source = source

		-- If x or y is nil, get the player's current entity coordinates
		if x == nil or y == nil then
			local ped = GetPlayerPed(source)
			if ped and ped ~= 0 then
				local coords = GetEntityCoords(ped)
				x = coords.x
				y = coords.y
			end
		end

		TriggerEvent('fivenet:createDispatch', source, job, message, description, x, y, anon)
	end)
end
