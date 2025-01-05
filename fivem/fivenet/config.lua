Config = {}

-- Your FiveNet URL without a trailing slash
Config.WebURL = "https://fivenet.app"

-- Enable the tracking of players
Config.EnableTracking = true
-- Theses jobs will be tracked
Config.TrackingJobs = {
	["ambulance"] = true,
	["doj"] = true,
	["police"] = true,
}
-- Players without this item will be updated as 'hidden', set false (without quotes) otherwise
Config.TrackingItem = "radio"
-- Interval in ms until positions will be updated
Config.TrackingInterval = 3000

-- These jobs will be timeclocked tracked
Config.TimeclockJobs = {
	["ambulance"] = true,
	["doj"] = true,
    ["police"] = true,
    -- Can also be other jobs that are ESX `onDuty` enabled
}

Config.Events = {}
-- Jobs bills that will cause an user activity to be created for the billing cycle events
Config.Events.BillingJobs = {
	["doj"] = true,
	["police"] = true,
}

-- Name of the Discord OAuth2 provider from the FiveNet server config
Config.DiscordOAuth2Provider = "discord"

Config.Dispatches = {}
Config.Dispatches.CivilProtectionJobs = {
	["police"] = true,
}

Config.UserProps = {}
-- Which blood types to set for users if it isn't set yet (on join)
Config.UserProps.BloodTypes = {
	"A+", "A-",
    "B+", "B-",
    "AB+", "AB-",
    "O+", "O-",
}
