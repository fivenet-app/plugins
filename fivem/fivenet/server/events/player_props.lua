if Config.UserProps.SetBloodType then
	if Config.Framework == 'esx' then
		AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
			setUserBloodType(xPlayer.identifier, Config.UserProps.BloodTypes[math.random(#Config.UserProps.BloodTypes)])
		end)
	elseif Config.Framework == 'qbcore' then
		AddEventHandler('QBCore:Server:PlayerLoaded', function(self)
			setUserBloodType(self.PlayerData.citizenid, Config.UserProps.BloodTypes[math.random(#Config.UserProps.BloodTypes)])
		end)
	end
end
