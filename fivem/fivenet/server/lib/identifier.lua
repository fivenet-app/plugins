--- Extract the bare license portion from an identifier string.
---@param identifier string
---@return string
function GetLicenseFromIdentifier(identifier --[[string]])
	local start = string.find(identifier, ':', 1, true)
	if not start then return identifier end

	return string.sub(identifier, start + 1, -1)
end
