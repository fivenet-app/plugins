-- These are non standard events, they need to be added by yourself to take advantage of
-- the job user activity tracking

if Config.Framework == 'esx' then
	AddEventHandler('esx_society:hired', function(xPlayer, xTarget)
		local sIdentifier = GetESXPlayerIdentifier(xPlayer)
		if not sIdentifier then return end
		local tIdentifier = GetESXPlayerIdentifier(xTarget)
		if not tIdentifier then return end

		local job = GetESXPlayerJob(xTarget)
		if not job then return end

		AddJobColleagueActivity(job.name, sIdentifier, tIdentifier, 1, nil, {})
	end)

	AddEventHandler('esx_society:gradeChanged', function(xPlayer, xTarget, promoted)
		local sIdentifier = GetESXPlayerIdentifier(xPlayer)
		if not sIdentifier then return end
		local tIdentifier = GetESXPlayerIdentifier(xTarget)
		if not tIdentifier then return end

		local job = GetESXPlayerJob(xTarget)
		if not job then return end

		local data = { oneofKind = 'gradeChange', gradeChange = { grade = job.grade, gradeLabel = job.grade_label } }
		AddJobColleagueActivity(job.name, sIdentifier, tIdentifier, promoted and 3 or 4, nil, data)
	end)

	AddEventHandler('esx_society:fired', function(xPlayer, xTarget)
		local sIdentifier = GetESXPlayerIdentifier(xPlayer)
		if not sIdentifier then return end
		local tIdentifier = GetESXPlayerIdentifier(xTarget)
		if not tIdentifier then return end

		local job = GetESXPlayerJob(xPlayer)
		if not job then return end

		AddJobColleagueActivity(job.name, sIdentifier, tIdentifier, 2, nil, {})
	end)
end
