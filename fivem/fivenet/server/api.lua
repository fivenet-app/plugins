-- Setup API client on immediately
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		exports[GetCurrentResourceName()]:SetupClient(Config.API.Host, Config.API.Token, Config.API.Insecure, Config.Debug)
	end
end)

function getCurrentTimestamp() --[[resources.timestamp.Timestamp]]
	return { timestamp = { seconds = GetCloudTimeAsInt(), nanos = 0 } }
end
