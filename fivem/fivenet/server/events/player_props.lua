if Config.UserProps.SetBloodType then
	AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
		setUserBloodType(xPlayer.identifier, Config.UserProps.BloodTypes[math.random(#Config.UserProps.BloodTypes)])
	end)
end
