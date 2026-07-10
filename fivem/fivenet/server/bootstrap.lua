-- Setup the API client on resource start.
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end

	exports[GetCurrentResourceName()]:SetupClient(
		Config.API.Host,
		Config.API.Token,
		Config.API.Insecure,
		Config.Debug
	)
end)
