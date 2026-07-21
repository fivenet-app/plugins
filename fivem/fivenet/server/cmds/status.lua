RegisterCommand('fivenet_get_status', function(source)
	local status = exports[GetCurrentResourceName()]:GetStatus()
	if not status then
		local message = 'FiveNet sync status request did not return a response.'
		if source ~= 0 then
			TriggerClientEvent('fivenet:printStatus', source, message)
		else
			Logger.warn(message)
		end

		return
	end

	local encodedStatus = json.encode(status)
	if source ~= 0 then
		TriggerClientEvent('fivenet:printStatus', source, encodedStatus)
	else
		Logger.info(('FiveNet sync status: %s'):format(encodedStatus))
	end
end, true)
