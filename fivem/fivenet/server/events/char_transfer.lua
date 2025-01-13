-- Char Transfer - this is a custom ESX multichar event
AddEventHandler('esx_multichar:onCharTransfer', function(selectedfirstCharacter, selectedSecondCharacter)
	-- Delete any existing account with the target license
	MySQL.update('DELETE FROM `fivenet_accounts` WHERE `license` = ?', {
		getLicenseFromIdentifier(getLicenseFromIdentifier(selectedSecondCharacter)),
	})

	-- Update existing account license when it exists
	MySQL.update('UPDATE `fivenet_accounts` SET `license` = ? WHERE `license` = ?', {
		getLicenseFromIdentifier(getLicenseFromIdentifier(selectedfirstCharacter)),
		getLicenseFromIdentifier(getLicenseFromIdentifier(selectedSecondCharacter)),
	})
end)
