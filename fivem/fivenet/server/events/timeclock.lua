-- Timeclock on/off duty tracking
local function timeclockTrack(job --[[string]], identifier --[[string]], clockOn --[[bool]])
	if not Config.TimeclockJobs[job] then return end

	if clockOn then
		setTimeclockEntry(identifier, {
			job = job,
			date = getCurrentTimestamp(),
		})
	else
		setTimeclockEntry(identifier, {
			job = job,
			date = getCurrentTimestamp(),
			endTime = getCurrentTimestamp(),
		})
	end
end

AddEventHandler('esx:setJob', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if not xPlayer then return end

	if Config.TrackCharIDs then
		-- Update last char ID if user has FiveNet account
		setLastCharID(identifier)
	end

	-- If lastJob is nil, user left job's duty
	timeclockTrack(xPlayer.job.name, xPlayer.identifier, xPlayer.job.onDuty)
end)

AddEventHandler('esx:playerDropped', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if not xPlayer then return end

	-- Check if job is enabled for timeclock tracking
	if not Config.TimeclockJobs[xPlayer.job.name] then return end

	timeclockTrack(xPlayer.job.name, xPlayer.identifier, false)
end)
