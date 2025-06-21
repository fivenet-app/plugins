function createDispatch(job --[[string]], message --[[string]], description --[[string]], anon --[[bool]])
	TriggerServerEvent('fivenet:createDispatchFromClient', job, message, description, anon)
end
exports('createDispatch', createDispatch)
