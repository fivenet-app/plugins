-- Livemap Markers

--- Add or update a livemap marker.
---@param marker table
function AddMarker(marker --[[MarkerMarker]])
	exports[GetCurrentResourceName()]:AddMarker({
		marker = marker,
	})
end
exports('addMarker', AddMarker)

--- Delete a livemap marker by ID.
---@param id number
function DeleteMarker(id --[[number]])
	exports[GetCurrentResourceName()]:DeleteMarker({
		id = id,
	})
end
exports('deleteMarker', DeleteMarker)
