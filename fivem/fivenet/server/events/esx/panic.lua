if Config.Framework == 'esx' then
	-- Panicbutton
	AddEventHandler('esx_policeJob:panicButton', function(source, x --[[number]], y --[[number]], _, name)
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then return end

		-- Send panic button dispatches to source user's job only for now
		createDispatch(xPlayer.job.name, Config.Dispatches.PanicButtonTitle, name, x, y, false, xPlayer.identifier)
	end)
end
