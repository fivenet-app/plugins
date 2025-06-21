function createDispatch(job --[[string]], message --[[string]], description --[[string]], x --[[number]], y --[[number]], anon --[[bool]])
	TriggerServerEvent('fivenet:createDispatchFromClient', job, message, description, x, y, anon)
end
exports('createDispatch', createDispatch)
