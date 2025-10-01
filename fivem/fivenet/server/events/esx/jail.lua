if Config.Framework == 'esx' then
	-- Jail
	AddEventHandler('esx_prison:jailPlayer', function(pPlayer, xPlayer, time --[[number]])
		local data = { oneofKind = 'jailChange', jailChange = { seconds = time, admin = false }}
		addUserActivity(pPlayer.identifier, xPlayer.identifier, 12, '', data)
	end)

	AddEventHandler('esx_prison:unjailedByPlayer', function(xPlayer, pPlayer, _, type --[[ 'police'/ 'admin']])
		local data = { oneofKind = 'jailChange', jailChange = { seconds = 0, admin = type == 'admin' and true or false }}
		addUserActivity(pPlayer.identifier, xPlayer.identifier, 12, '', data)
	end)

	AddEventHandler('esx_prison:escapePoliceNotify', function(xPlayer)
		local data = { oneofKind = 'jailChange', jailChange = { seconds = -1, admin = false }}
		addUserActivity(xPlayer.identifier, xPlayer.identifier, 12, '', data)

		-- Set user wanted + user activity
		data = { wantedChange = { wanted = true }}
		addUserActivity(xPlayer.identifier, xPlayer.identifier, 6, Config.Events.JailEscapeReason, data)
		setUserWantedState(xPlayer.identifier, true)
	end)
end
