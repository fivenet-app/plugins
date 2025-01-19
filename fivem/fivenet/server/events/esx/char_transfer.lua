if Config.Framework ~= 'esx' then
	return
end

-- Char Transfer - this is a custom ESX multichar event
AddEventHandler('esx_multichar:onCharTransfer', function(oldLicense, newLicense)
	exports[GetCurrentResourceName()]:TransferAccount(oldLicense, newLicense)
end)
