if Config.Framework == 'esx' then
	-- Jail
	AddEventHandler('esx_prison:jailPlayer', function(pPlayer, xPlayer, time --[[number]])
		local data = { oneofKind = 'jailChange', jailChange = { seconds = time, admin = false }}
		AddUserActivity(pPlayer.identifier, xPlayer.identifier, 12, '', data)
	end)

	AddEventHandler('esx_prison:unjailedByPlayer', function(xPlayer, pPlayer, _, type --[[ 'police'/ 'admin']])
		local data = { oneofKind = 'jailChange', jailChange = { seconds = 0, admin = type == 'admin' and true or false }}
		AddUserActivity(pPlayer.identifier, xPlayer.identifier, 12, '', data)
	end)

	AddEventHandler('esx_prison:escapePoliceNotify', function(xPlayer)
		local data = { oneofKind = 'jailChange', jailChange = { seconds = -1, admin = false }}
		AddUserActivity(xPlayer.identifier, xPlayer.identifier, 12, '', data)

		-- Set user wanted + user activity
		data = { wantedChange = { wanted = true }}
		AddUserActivity(xPlayer.identifier, xPlayer.identifier, 6, Config.Events.JailEscapeReason, data)
		SetUserWantedState(xPlayer.identifier, true)
	end)
end
