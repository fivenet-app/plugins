Config = {}

-- Your FiveNet URL without a trailing slash
Config.WebURL = 'https://demo.fivenet.app'

Config.Hotkey = {}
-- If the tablet hotkey should be registered
Config.Hotkey.Enable = true
-- Tablet hotkey key
Config.Hotkey.Key = 'F5'

-- Postal Code Command (should mark the postal code on the player's map)
Config.PostalCommand = 'plz'

-- Functions to implement functionality matching your server's framework
Functions = {}
-- Call phone number
Functions.CallNumber = function(number --[[string]])
	-- Check if the user has a phone item (example for ESX)
	if ESX ~= nil and not ESX.getInventoryItem('phone') and not ESX.getInventoryItem('phone_jailbreak') then
		return false
	end

	-- Your phone plugin call number code here
end

-- Set radio frequency
Functions.SetRadioFrequency = function(frequency --[[number]])
	-- This is for pma-voice
	local currentChannel = exports['pma-voice']:getRadioChannel()

	if currentChannel ~= frequency then
		TriggerEvent('tgiann-radio:t', frequency)
	end
end
