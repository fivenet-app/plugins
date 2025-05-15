if Config.Framework ~= 'esx' then
	return
end

-- Fines
AddEventHandler('esx_billing:sentBill', function(xPlayer, xTarget, type --[['fine'/ 'bill']], label, amount)
	if type ~= 'fine' then return end
	if not checkIfBillingEnabledJob(xPlayer.job.name) then return end

	local data = { oneofKind = 'fineChange', fineChange = { removed = false, amount = amount }}

	addUserActivity(xPlayer.identifier, xTarget.identifier, 13, '', data)
	updateOpenFines(xTarget.identifier, amount)
end)

AddEventHandler('esx_billing:removedBill', function(source, type, result)
	if type ~= 'fine' then return end
	if result.target_type ~= 'society' then return end
	if not checkIfBillingEnabledJob(result.target) then return end

	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local data = { oneofKind = 'fineChange', fineChange = { removed = true, amount = -result.amount }}

	addUserActivity(xPlayer.identifier, result.identifier, 13, result.label, data)
	updateOpenFines(result.identifier, -result.amount)
end)

AddEventHandler('esx_billing:paidBill', function(source, result)
	if result.target_type ~= 'society' then return end
	if not checkIfBillingEnabledJob(result.target) then return end

	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local data = { oneofKind = 'fineChange', fineChange = { removed = false, amount = -result.amount }}

	addUserActivity(xPlayer.identifier, xPlayer.identifier, 13, result.label, data)
	updateOpenFines(xPlayer.identifier, -result.amount)
end)
