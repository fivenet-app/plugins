function createDispatch(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
	if type(job) ~= "string" then
		print('error: createDispatch (client-side) expects a string (single job only) for job, got ' .. type(job))
		return
	end

	TriggerServerEvent('fivenet:createDispatchFromClient', job, message, description, x, y, anon)
end
exports('createDispatch', createDispatch)
