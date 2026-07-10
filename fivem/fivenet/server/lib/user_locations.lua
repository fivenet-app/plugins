--- Build a user location entry compatible with the sync API.
---@param userId number
---@param job string
---@param coords vector3
---@param hidden boolean
---@param remove boolean
---@return table
function BuildUserLocationEntry(userId, job, coords, hidden, remove)
	return {
		userId = userId,
		job = job,
		coords = {
			x = coords.x,
			y = coords.y,
		},
		hidden = hidden,
		remove = remove,
	}
end
