function createDispatch(job --[[string]], message --[[string]], description --[[string]], anon --[[bool]])
	TriggerServerEvent('fivenet:createDispatch', job, message, description, anon)
end
exports('createDispatch', createDispatch)
