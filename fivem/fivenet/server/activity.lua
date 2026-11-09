-- User Activity and Props

--- Add a user activity entry.
---@param sIdentifier string|nil
---@param tIdentifier string
---@param type number
---@param reason string
---@param data table|nil
--- If `sIdentifier` is omitted, the target user's DB ID is reused as the source user.
function AddUserActivity(sIdentifier, tIdentifier, type, reason, data)
	local sourceUserId = nil
	local targetUserId = GetUserIDFromIdentifier(tIdentifier)

	if sIdentifier then
		sourceUserId = GetUserIDFromIdentifier(sIdentifier)
	else
		sourceUserId = targetUserId
	end

	exports[GetCurrentResourceName()]:AddUserActivity({
		userActivity = {
			sourceUserId = sourceUserId,
			targetUserId = targetUserId,
			type = type,
			reason = reason,
			data = (data and { data = data } or nil),
		},
	})
end
exports('addUserActivity', AddUserActivity)

--- Get user props for a target identifier.
---@param identifier string
---@return GetUserPropsResponse
function GetUserProps(identifier)
	local userId = GetUserIDFromIdentifier(identifier)

	return exports[GetCurrentResourceName()]:GetUserProps({
		userId = userId,
	})
end
exports('getUserProps', GetUserProps)

--- Find a dynamic property in a FiveNet property list.
---@param properties table|nil A `resources.properties.Properties` value.
---@param key string
---@return table|nil The matching `resources.properties.Property` value.
function GetPropertyFromList(properties, key)
	if type(properties) ~= 'table' or type(properties.properties) ~= 'table' or type(key) ~= 'string' then
		return nil
	end

	for _, property in ipairs(properties.properties) do
		if property.key == key then
			return property
		end
	end

	return nil
end
exports('getPropertyFromList', GetPropertyFromList)

--- Unwrap the scalar value from a dynamic property.
--- Returns nil for an unset property. Timestamps and dates remain tables.
---@param property table|nil A `resources.properties.Property` value.
---@return string|number|boolean|table|nil
function GetPropertyValue(property)
	local value = property and property.value and property.value.value
	if type(value) ~= 'table' or type(value.oneofKind) ~= 'string' then
		return nil
	end

	return value[value.oneofKind]
end
exports('getPropertyValue', GetPropertyValue)

--- Get all dynamic user properties for a target identifier.
---@param identifier string
---@return table|nil A `resources.properties.Properties` value.
function GetUserProperties(identifier)
	local response = GetUserProps(identifier)
	return response and response.userProps and response.userProps.properties or nil
end
exports('getUserProperties', GetUserProperties)

--- Get one dynamic user property by its namespaced key.
---@param identifier string
---@param key string
---@return table|nil A `resources.properties.Property` value.
function GetUserProperty(identifier, key)
	return GetPropertyFromList(GetUserProperties(identifier), key)
end
exports('getUserProperty', GetUserProperty)

--- Get the unwrapped value of one dynamic user property.
---@param identifier string
---@param key string
---@return string|number|boolean|table|nil
function GetUserPropertyValue(identifier, key)
	return GetPropertyValue(GetUserProperty(identifier, key))
end
exports('getUserPropertyValue', GetUserPropertyValue)

local userLegacyPropertyKeys = {
	wanted = 'user.wanted',
	trafficInfractionPoints = 'user.traffic_infraction_points',
	openFines = 'user.open_fines',
	bloodType = 'user.blood_type',
	email = 'user.email',
}

local vehicleLegacyPropertyKeys = {
	wanted = 'vehicle.wanted',
}

local integerMathActionAdd = 1
local integerMathActionSubtract = 2

local function WarnUnsupportedLegacyProperties(kind, data, supportedFields)
	for field in pairs(data) do
		if not supportedFields[field] then
			Logger.warn(('Ignoring unsupported legacy %s field "%s". Use set%sProperty/Properties instead.'):format(
				kind,
				field,
				kind == 'user props' and 'User' or 'Vehicle'
			))
		end
	end
end

--- Build a typed FiveNet property value from a Lua scalar, or accept an
--- explicit `resources.properties.PropertyValue` table for dates/timestamps.
---@param value string|number|boolean|table
---@return table|nil
local function CreatePropertyValue(value)
	if type(value) == 'string' then
		return { value = { oneofKind = 'stringValue', stringValue = value } }
	elseif type(value) == 'boolean' then
		return { value = { oneofKind = 'boolValue', boolValue = value } }
	elseif type(value) == 'number' then
		if math.type(value) == 'integer' then
			return { value = { oneofKind = 'integerValue', integerValue = value } }
		end

		return { value = { oneofKind = 'numberValue', numberValue = value } }
	elseif type(value) == 'table' and type(value.oneofKind) == 'string' then
		return { value = value }
	elseif type(value) == 'table' and type(value.value) == 'table' then
		return value
	end

	return nil
end

--- Build a property mutation. Pass nil as `value` to clear the property.
---@param key string
---@param value string|number|boolean|table|nil
---@param reason string|nil
---@return table|nil
local function CreatePropertyMutation(key, value, reason)
	if type(key) ~= 'string' or key == '' then
		return nil
	end

	local mutation = { key = key }
	if type(reason) == 'string' and reason ~= '' then
		mutation.reason = reason
	end
	if value == nil then
		mutation.valueChange = { oneofKind = 'clearValue', clearValue = {} }
		return mutation
	end

	local propertyValue = CreatePropertyValue(value)
	if not propertyValue then
		return nil
	end

	mutation.valueChange = { oneofKind = 'setValue', setValue = propertyValue }
	return mutation
end

--- Build an atomic integer math mutation.
---@param key string
---@param delta integer A non-zero signed integer.
---@param reason string|nil
---@return table|nil
local function CreateIntegerMathMutation(key, delta, reason)
	delta = type(delta) == 'number' and math.tointeger(delta) or nil
	if type(key) ~= 'string' or key == '' or not delta or delta == 0 then
		return nil
	end

	local mutation = { key = key }
	if type(reason) == 'string' and reason ~= '' then
		mutation.reason = reason
	end
	mutation.valueChange = {
		oneofKind = 'integerMath',
		integerMath = {
			action = delta > 0 and integerMathActionAdd or integerMathActionSubtract,
			operand = math.abs(delta),
		},
	}
	return mutation
end

--- Apply generic or managed user-property mutations.
---@param identifier string
---@param propertyMutations table[]
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@return SetUserPropertiesResponse|nil
function SetUserProperties(identifier, propertyMutations, reason, sourceUserId, sourceUserJob)
	local userId = GetUserIDFromIdentifier(identifier)
	if userId == 0 or type(propertyMutations) ~= 'table' or #propertyMutations == 0 then
		return nil
	end
	if type(reason) ~= 'string' or reason == '' then reason = nil end

	return exports[GetCurrentResourceName()]:SetUserProperties({
		userId = userId,
		propertyMutations = propertyMutations,
		reason = reason,
		sourceUser = (sourceUserId or sourceUserJob) and {
			userId = sourceUserId,
			job = sourceUserJob,
		} or nil,
	})
end
exports('setUserProperties', SetUserProperties)

--- Set or clear one user property. Pass a scalar value, or an explicit
--- `resources.properties.PropertyValue` table for date/timestamp values.
---@param identifier string
---@param key string
---@param value string|number|boolean|table|nil
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@return SetUserPropertiesResponse|nil
function SetUserProperty(identifier, key, value, reason, sourceUserId, sourceUserJob)
	local mutation = CreatePropertyMutation(key, value, reason)
	if not mutation then return nil end

	return SetUserProperties(identifier, { mutation }, reason, sourceUserId, sourceUserJob)
end
exports('setUserProperty', SetUserProperty)

--- Get the managed wanted state for a user.
---@param identifier string
---@return boolean|nil
function GetUserWantedState(identifier)
	return GetUserPropertyValue(identifier, 'user.wanted')
end
exports('getUserWantedState', GetUserWantedState)

--- Get a user's traffic infraction points.
---@param identifier string
---@return number|nil
function GetUserTrafficInfractionPoints(identifier)
	return GetUserPropertyValue(identifier, 'user.traffic_infraction_points')
end
exports('getUserTrafficInfractionPoints', GetUserTrafficInfractionPoints)

--- Set a user's traffic infraction points.
---@param identifier string
---@param points integer
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@return SetUserPropertiesResponse|nil
function SetUserTrafficInfractionPoints(identifier, points, reason, sourceUserId, sourceUserJob)
	points = type(points) == 'number' and math.tointeger(points) or nil
	if not points then return nil end

	return SetUserProperty(identifier, 'user.traffic_infraction_points', points, reason, sourceUserId, sourceUserJob)
end
exports('setUserTrafficInfractionPoints', SetUserTrafficInfractionPoints)

--- Get a user's open fines total in minor currency units.
---@param identifier string
---@return number|nil
function GetUserOpenFines(identifier)
	return GetUserPropertyValue(identifier, 'user.open_fines')
end
exports('getUserOpenFines', GetUserOpenFines)

--- Set a user's open fines total in minor currency units.
---@param identifier string
---@param total integer
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@return SetUserPropertiesResponse|nil
function SetUserOpenFines(identifier, total, reason, sourceUserId, sourceUserJob)
	total = type(total) == 'number' and math.tointeger(total) or nil
	if not total then return nil end

	return SetUserProperty(identifier, 'user.open_fines', total, reason, sourceUserId, sourceUserJob)
end
exports('setUserOpenFines', SetUserOpenFines)

--- Set user props for a target identifier.
---@param identifier string
---@param reason string|nil
---@param data table
---@param sourceUserId number|nil User DB ID to attribute the change to.
---@param sourceUserJob string|nil Job to attribute the change to.
--- Compatibility helper for the legacy scalar user-props shape.
function SetUserProps(identifier, reason, data, sourceUserId, sourceUserJob)
	if type(data) ~= 'table' then return nil end
	WarnUnsupportedLegacyProperties('user props', data, {
		wanted = true,
		wantedTill = true,
		trafficInfractionPoints = true,
		openFines = true,
		bloodType = true,
		email = true,
	})

	local mutations = {}
	for field, key in pairs(userLegacyPropertyKeys) do
		if data[field] ~= nil then
			local value = data[field]
			if (field == 'trafficInfractionPoints' or field == 'openFines') and type(value) == 'number' then
				value = math.tointeger(value) or value
			end

			local mutation = CreatePropertyMutation(key, value, reason)
			if field == 'wanted' and data.wantedTill ~= nil and mutation then
				mutation.state = {
					expiryChange = { oneofKind = 'expiresAt', expiresAt = data.wantedTill },
				}
			end
			if mutation then table.insert(mutations, mutation) end
		end
	end

	return SetUserProperties(identifier, mutations, reason, sourceUserId, sourceUserJob)
end
exports('setUserProps', SetUserProps)

--- Atomically add or subtract from the open fine total for a user.
---@param tIdentifier string
---@param fine number
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
function UpdateOpenFines(tIdentifier, fine, sourceUserId, sourceUserJob)
	if type(tIdentifier) ~= 'string' then return nil end

	local mutation = CreateIntegerMathMutation('user.open_fines', fine, nil)
	if not mutation then return nil end

	return SetUserProperties(tIdentifier, { mutation }, nil, sourceUserId, sourceUserJob)
end
exports('updateOpenFines', UpdateOpenFines)

--- Set the wanted state for a user.
---@param tIdentifier string
---@param wanted boolean
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@param wantedTill table|nil A `resources.timestamp.Timestamp` expiration.
function SetUserWantedState(tIdentifier, wanted, reason, sourceUserId, sourceUserJob, wantedTill)
	local mutation = CreatePropertyMutation('user.wanted', wanted, reason)
	if not mutation then return nil end
	if wantedTill ~= nil then
		mutation.state = {
			expiryChange = { oneofKind = 'expiresAt', expiresAt = wantedTill },
		}
	end

	return SetUserProperties(tIdentifier, { mutation }, reason, sourceUserId, sourceUserJob)
end
exports('setUserWantedState', SetUserWantedState)

-- Jobs User Activity
-- activityType: 1 = HIRED, 2 = FIRED, 3 = PROMOTED, 4 = DEMOTED
--- Add a job colleague activity entry.
---@param job string
---@param sIdentifier string
---@param tIdentifier string
---@param activityType number
---@param reason string
---@param data table|nil
function AddJobColleagueActivity(job, sIdentifier, tIdentifier, activityType, reason, data)
	local sourceUserId = GetUserIDFromIdentifier(sIdentifier)
	local targetUserId = GetUserIDFromIdentifier(tIdentifier)

	exports[GetCurrentResourceName()]:AddColleagueActivity({
		colleagueActivity = {
			sourceUserId = sourceUserId,
			targetUserId = targetUserId,
			job = job,
			activityType = activityType,
			reason = reason,
			data = (data and { data = data } or nil),
		},
	})
end
exports('addJobColleagueActivity', AddJobColleagueActivity)

-- Jobs User Props
--- Set colleague props for a target identifier.
---@param identifier string
---@param reason string|nil
---@param props table
---@param sourceUserId number|nil User DB ID to attribute the change to.
---@param sourceUserJob string|nil Job to attribute the change to.
--- The helper mutates `props` by adding `userId`.
function SetColleagueProps(identifier, reason, props, sourceUserId, sourceUserJob)
	local userId = GetUserIDFromIdentifier(identifier)
	props.userId = userId

	exports[GetCurrentResourceName()]:AddColleagueProps({
		colleagueProps = {
			reason = reason,
			props = props,
		},
		sourceUser = (sourceUserId or sourceUserJob) and {
			userId = sourceUserId,
			job = sourceUserJob,
		} or nil,
	})
end
exports('setColleagueProps', SetColleagueProps)

--- Get vehicle props for a plate.
---@param plate string
---@return GetVehiclePropsResponse
function GetVehicleProps(plate)
	return exports[GetCurrentResourceName()]:GetVehicleProps({
		plate = plate,
	})
end
exports('getVehicleProps', GetVehicleProps)

--- Get all dynamic vehicle properties for a license plate.
---@param plate string
---@return table|nil A `resources.properties.Properties` value.
function GetVehicleProperties(plate)
	local response = GetVehicleProps(plate)
	return response and response.vehicleProps and response.vehicleProps.properties or nil
end
exports('getVehicleProperties', GetVehicleProperties)

--- Get one dynamic vehicle property by its namespaced key.
---@param plate string
---@param key string
---@return table|nil A `resources.properties.Property` value.
function GetVehicleProperty(plate, key)
	return GetPropertyFromList(GetVehicleProperties(plate), key)
end
exports('getVehicleProperty', GetVehicleProperty)

--- Get the unwrapped value of one dynamic vehicle property.
---@param plate string
---@param key string
---@return string|number|boolean|table|nil
function GetVehiclePropertyValue(plate, key)
	return GetPropertyValue(GetVehicleProperty(plate, key))
end
exports('getVehiclePropertyValue', GetVehiclePropertyValue)

--- Apply generic or managed vehicle-property mutations.
---@param plate string
---@param propertyMutations table[]
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@return SetVehiclePropertiesResponse|nil
function SetVehicleProperties(plate, propertyMutations, reason, sourceUserId, sourceUserJob)
	if type(plate) ~= 'string' or plate == '' or type(propertyMutations) ~= 'table' or #propertyMutations == 0 then
		return nil
	end
	if type(reason) ~= 'string' or reason == '' then reason = nil end

	return exports[GetCurrentResourceName()]:SetVehicleProperties({
		plate = plate,
		propertyMutations = propertyMutations,
		reason = reason,
		sourceUser = (sourceUserId or sourceUserJob) and {
			userId = sourceUserId,
			job = sourceUserJob,
		} or nil,
	})
end
exports('setVehicleProperties', SetVehicleProperties)

--- Set or clear one vehicle property. Pass a scalar value, or an explicit
--- `resources.properties.PropertyValue` table for date/timestamp values.
---@param plate string
---@param key string
---@param value string|number|boolean|table|nil
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@return SetVehiclePropertiesResponse|nil
function SetVehicleProperty(plate, key, value, reason, sourceUserId, sourceUserJob)
	local mutation = CreatePropertyMutation(key, value, reason)
	if not mutation then return nil end

	return SetVehicleProperties(plate, { mutation }, reason, sourceUserId, sourceUserJob)
end
exports('setVehicleProperty', SetVehicleProperty)

--- Get the managed wanted state for a vehicle.
---@param plate string
---@return boolean|nil
function GetVehicleWantedState(plate)
	return GetVehiclePropertyValue(plate, 'vehicle.wanted')
end
exports('getVehicleWantedState', GetVehicleWantedState)

--- Set the managed wanted state for a vehicle.
---@param plate string
---@param wanted boolean
---@param reason string|nil
---@param sourceUserId number|nil
---@param sourceUserJob string|nil
---@param wantedTill table|nil A `resources.timestamp.Timestamp` expiration.
---@return SetVehiclePropertiesResponse|nil
function SetVehicleWantedState(plate, wanted, reason, sourceUserId, sourceUserJob, wantedTill)
	local mutation = CreatePropertyMutation('vehicle.wanted', wanted, reason)
	if not mutation then return nil end
	if wantedTill ~= nil then
		mutation.state = {
			expiryChange = { oneofKind = 'expiresAt', expiresAt = wantedTill },
		}
	end

	return SetVehicleProperties(plate, { mutation }, reason, sourceUserId, sourceUserJob)
end
exports('setVehicleWantedState', SetVehicleWantedState)

--- Set vehicle props for a plate.
---@param plate string
---@param reason string|nil
---@param data table
---@param sourceUserId number|nil User DB ID to attribute the change to.
---@param sourceUserJob string|nil Job to attribute the change to.
--- Compatibility helper for the legacy scalar vehicle-props shape.
function SetVehicleProps(plate, reason, data, sourceUserId, sourceUserJob)
	if type(data) ~= 'table' then return nil end
	WarnUnsupportedLegacyProperties('vehicle props', data, {
		wanted = true,
		wantedReason = true,
		wantedTill = true,
	})

	local mutations = {}
	for field, key in pairs(vehicleLegacyPropertyKeys) do
		if data[field] ~= nil then
			local mutation = CreatePropertyMutation(key, data[field], data.wantedReason or reason)
			if field == 'wanted' and data.wantedTill ~= nil and mutation then
				mutation.state = {
					expiryChange = { oneofKind = 'expiresAt', expiresAt = data.wantedTill },
				}
			end
			if mutation then table.insert(mutations, mutation) end
		end
	end

	return SetVehicleProperties(plate, mutations, reason, sourceUserId, sourceUserJob)
end
exports('setVehicleProps', SetVehicleProps)
