-- Setup API client on immediately
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		exports[GetCurrentResourceName()]:SetupClient(Config.API.Host, Config.API.Token)
	end
end)
