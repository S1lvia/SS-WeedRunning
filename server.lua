-- ND_Framework exports (edit with your framework's)
local NDCore = exports["ND_Core"]:GetCoreObject()

RegisterServerEvent('SS-WeedRunning:success')
AddEventHandler('SS-WeedRunning:success', function(pay)
    local player = source
    NDCore.Functions.AddMoney(pay, player, "cash")
end)

RegisterServerEvent("SS-WeedRunning:penalty")
AddEventHandler("SS-WeedRunning:penalty", function(money)
    local player = source
    NDCore.Functions.DeductMoney(money, player, "cash")
end)