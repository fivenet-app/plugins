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
-- These are client integration hooks called by FiveNet.
-- Replace the default implementations so they match your phone, radio, and other client-side plugins.
-- If you do not use a feature, you can leave the hook as a no-op or return false.
--
Functions = {}
-- Phone hook:
-- Called when FiveNet wants to dial a number from the tablet UI.
-- Return false to cancel the action or call your phone resource here.
-- See the README for a call example.
Functions.CallNumber = function(number --[[string]])
	if number == nil or number == '' then
        return false
    end

	-- If your phone plugin requires a client-side availability check, do it here.
	-- Example for GKSPhone:
	exports["gksphone"]:StartingCall(number)
	-- Example for LB Phone:
	-- exports["lb-phone"]:CreateCall(number)
end

-- Radio hook:
-- Called when FiveNet wants to set the player's radio frequency from the tablet UI.
-- Return false to cancel the action or call your radio resource here.
-- See the README for a tgiann's radio example.
Functions.SetRadioFrequency = function(frequency --[[number]])
	-- This is for pma-voice
	local currentChannel = exports['pma-voice']:getRadioChannel()

	if currentChannel ~= frequency then
		-- Example for tgiann's radio plugin
		TriggerEvent('tgiann-radio:t', frequency)
	end
end
