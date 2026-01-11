Config = {}

-- Enable debug mode for additional logging
Config.Debug = false

-- Your FiveNet URL without a trailing slash but with the protocol (http:// or https://) in front
-- The port is only needed when using a non-standard port (not 80 for http or 443 for https)
Config.WebURL = 'https://demo.fivenet.app'

Config.Hotkey = {}
-- If the tablet hotkey should be registered
Config.Hotkey.Enable = true
-- Tablet hotkey key
Config.Hotkey.Key = 'F5'

-- Postal Code Command (should mark the postal code on the player's map)
Config.PostalCommand = 'plz'

--
-- FUNCTIONS
-- These functions are called by FiveNet to interact with your server's framework or other plugins.
--
-- You must implement these functions according to your server's setup, plugins, etc.
--
Functions = {}
-- Call phone number
Functions.CallNumber = function(number --[[string]])
	-- Check if the user has a phone item (example for ESX)
	if ESX ~= nil and not ESX.getInventoryItem('phone') and not ESX.getInventoryItem('phone_jailbreak') then
		return false
	end

	-- Your phone plugin call number code here
	-- Example for GKSPhone
	exports["gksphone"]:StartingCall(number)
end

-- Set radio frequency
Functions.SetRadioFrequency = function(frequency --[[number]])
	-- This is for pma-voice
	local currentChannel = exports['pma-voice']:getRadioChannel()

	if currentChannel ~= frequency then
		-- Example for tgiann's radio plugin
		TriggerEvent('tgiann-radio:t', frequency)
	end
end
