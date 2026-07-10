--- Normalize the (dispatches) job payload into the FiveNet API shape.
---@param job string|table
---@return table
function NormalizeJobsToJobList(job --[[string/table]])
	local jobs = {}

	if type(job) ~= 'table' then
		job = { job }
	end

	for _, entry in ipairs(job) do
		if type(entry) == 'table' then
			jobs[#jobs + 1] = {
				name = entry.name,
			}
		else
			jobs[#jobs + 1] = {
				name = entry,
			}
		end
	end

	return {
		jobs = jobs,
	}
end

--- Normalize a framework job object into the common FiveNet shape.
---@param job table
---@param onDuty boolean|nil
---@return table
function NormalizePlayerJob(job, onDuty)
	if not job then
		return {
			name = 'unemployed',
			label = 'Unemployed',
			grade = 0,
			gradeLabel = 'Unemployed',
			onDuty = onDuty and true or false,
		}
	end

	local grade = job.grade
	local gradeLabel = job.grade_label or job.gradeLabel

	if type(grade) == 'table' then
		gradeLabel = gradeLabel or grade.name
		grade = grade.level
	end

	return {
		name = job.name,
		label = job.label,
		grade = grade or 0,
		gradeLabel = gradeLabel or 'Unemployed',
		onDuty = onDuty and true or false,
	}
end
