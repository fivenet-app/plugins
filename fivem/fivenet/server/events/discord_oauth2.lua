if Config.Discord.ConnectOnJoin and Config.Discord.OAuth2Provider ~= '' then
	-- Create Discord OAuth2 connection on join
	AddEventHandler('playerJoining', function(newID)
		local discordId  = GetPlayerIdentifierByType(source, 'discord')
		local identifier = ESX.GetIdentifier(source)

		if identifier and discordId then
			addOAuth2DiscordIdentifier(identifier, discordId, GetPlayerName(newID))
		end
	end)
end
