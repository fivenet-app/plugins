-- Fines
local function checkIfBillingEnabledJob(target --[[string]])
	local job = string.gsub(target, 'society_', '')
	return Config.Events.BillingJobs[job]
end

AddEventHandler('esx_billing:sentBill', function(xPlayer, xTarget, type --[['fine'/ 'bill']], label, amount)
	if type ~= 'fine' then return end
	if not checkIfBillingEnabledJob(xPlayer.job.name) then return end

	local data = { fineChange = { removed = false, amount = amount }}

	addUserActivity(xPlayer.identifier, xTarget.identifier, 13, '', json.encode(data))
	updateOpenFines(xTarget.identifier, amount)
end)

AddEventHandler('esx_billing:removedBill', function(source, type, result)
	if type ~= 'fine' then return end
	if result.target_type ~= 'society' then return end
	if not checkIfBillingEnabledJob(result.target) then return end

	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local data = { fineChange = { removed = true, amount = -result.amount }}

	addUserActivity(xPlayer.identifier, result.identifier, 13, result.label, json.encode(data))
	updateOpenFines(result.identifier, -result.amount)
end)

AddEventHandler('esx_billing:paidBill', function(source, result)
	if result.target_type ~= 'society' then return end
	if not checkIfBillingEnabledJob(result.target) then return end

	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local data = { fineChange = { removed = false, amount = -result.amount }}

	addUserActivity(xPlayer.identifier, xPlayer.identifier, 13, result.label, json.encode(data))
	updateOpenFines(xPlayer.identifier, -result.amount)
end)
