Config = {}

-- !!! Make sure to configure your FiveNet API credentials correctly here!
Config.API = {}
-- Your FiveNet Hostname, must be with port if your port is not 443,
-- requires the FiveNet instance to be using HTTPS.
Config.API.Host = "demo.fivenet.app"
Config.API.Token = "YOUR_SYNC_API_TOKEN"

Config.Tracking = {}
-- Enable the tracking of players
Config.Tracking.Enable = true
-- Theses jobs will be tracked
Config.Tracking.Jobs = {
	["ambulance"] = true,
	["doj"] = true,
	["police"] = true,
}
-- Players without this item will be updated as 'hidden', set false (without quotes) otherwise
Config.Tracking.Item = "radio"
-- Interval in ms until positions will be updated
Config.Tracking.Interval = 3000

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

Config.Discord = {}
-- Automatically create discord OAuth2 connections when a player joining has a discord id
Config.Discord.ConnectOnJoin = true
-- Name of the Discord OAuth2 provider from the FiveNet server config
Config.Discord.OAuth2Provider = "discord"

Config.Dispatches = {}
Config.Dispatches.CivilProtectionJobs = {
	["police"] = true,
}

Config.UserProps = {}
-- If enabled will set the blood type for an user on "join/loaded" event
Config.UserProps.SetBloodType = true
-- Which blood types to set for users if it isn't set yet (on join)
Config.UserProps.BloodTypes = {
	"A+", "A-",
	"B+", "B-",
	"AB+", "AB-",
	"O+", "O-",
}