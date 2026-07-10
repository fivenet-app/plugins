--- Helper functions for comparing version numbers.
function SanitizeVersion(v)
	if not v or v == '' then return '0.0.0' end

	v = v:gsub('^v', ''):gsub('[^0-9%.]', '')
	return v
end

local function splitVersion(v)
	local parts = {}
	for num in SanitizeVersion(v):gmatch('(%d+)') do
		parts[#parts + 1] = tonumber(num)
	end

	while #parts < 3 do
		parts[#parts + 1] = 0
	end

	return parts
end

function CompareSemVer(a, b)
	local A, B = splitVersion(a), splitVersion(b)
	for i = 1, math.max(#A, #B) do
		local ai, bi = A[i] or 0, B[i] or 0
		if ai > bi then return 1 end
		if ai < bi then return -1 end
	end

	return 0
end

function GetCurrentResourceVersion()
	local res = GetCurrentResourceName()
	local v = GetResourceMetadata(res, 'version', 0)
	return SanitizeVersion(v or '0.0.0')
end
