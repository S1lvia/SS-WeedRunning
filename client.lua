local pedCoords = GetEntityCoords(PlayerPedId())
local markerCoords = vector3(18.2040, 343.0439, 115.3874)
local startedRunning = false
local atSpot = false
local atPlace = false
local random = math.random

AddTextEntry('start_running', 'Press ~INPUT_WEAPON_SPECIAL_TWO~ to start running.')
AddTextEntry('drop_off', 'Press ~INPUT_WEAPON_SPECIAL_TWO~ to drop off the weed.')

-- Display's a notification anchored to the minimap.
---@param text string
local function notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Randomly selects an item from a specified table.
---@param table table
---@return index
local function randomItem(table)
    local keys = {}
    for key, value in pairs(table) do
        keys[#keys + 1] = key
    end
    index = keys[random(1, #keys)]
    return table[index]
end

-- Ends the running session.
local function endRun()
    SetWaypointOff()
    startedRunning = false
    atSpot = false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not startedRunning and #(pedCoords - markerCoords) <= 15.0 then
            DrawMarker(1, markerCoords.x, markerCoords.y, markerCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 153, 51, 255, 50, false, true, 2.0, nil, nil, false)

            if #(pedCoords - markerCoords) <= 2.0 then
                DisplayHelpTextThisFrame('start_running')

                if IsControlJustPressed(0, 51) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                    startedRunning = true

                    waypoint = randomItem(Config.DropOffs)
                    wpCoords = vector3(waypoint.x, waypoint.y, waypoint.z)
                    SetWaypointOff()
                    SetNewWaypoint(waypoint.x, waypoint.y)
                    notify('I\'ve marked the first ~y~drop off spot~s~ on your minimap.')

                    while startedRunning and not atSpot do
                        Citizen.Wait(0)

                        if #(pedCoords - wpCoords) <= 25.0 then
                            atSpot = true
                            break
                        else
                            Citizen.Wait(1000)
                        end
                    end

                    if atSpot then
                        notify('You\'ve arrived at your ~g~drop off spot~s~, find the place to leave it!')
                        SetWaypointOff()
                    end
                elseif IsControlJustPressed(0, 51) and IsPedInAnyVehicle(PlayerPedId(), true) then
                    notify('You ~y~can\'t~s~ start running in a vehicle.')
                end
            end
        else
            Citizen.Wait(2000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if startedRunning and #(pedCoords - wpCoords) <= 15.0 then
            DrawMarker(1, wpCoords.x, wpCoords.y, wpCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 153, 51, 255, 50, false, true, 2.0, nil, nil, false)

            if #(pedCoords - wpCoords) <= 2.0 then
                pay = waypoint.pay
                DisplayHelpTextThisFrame('drop_off')
                if IsControlJustPressed(0, 51) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                endRun()
                TriggerServerEvent("SS-WeedRunning:success", pay)
                drawnotifcolor("You have finished this drop. \nMoney Earnt: ~g~$" .. pay, 140)


                elseif IsControlJustPressed(0, 51) and IsPedInAnyVehicle(PlayerPedId(), true) then
                    notify('You ~y~can\'t~s~ drop off in a vehicle.')
                end
            end
        else
            Citizen.Wait(2000)
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        pedCoords = GetEntityCoords(PlayerPedId())
        Wait(500)
    end
end)

function drawnotifcolor(text, color)
    Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end

Citizen.CreateThread(function()
    if Config.Marker == true then
        local blip = AddBlipForCoord(markerCoords.x, markerCoords.y, markerCoords.z)
        SetBlipSprite(blip, 140)
        SetBlipDisplay(blip, 4)
        SetBlipColour(blip, 21)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Weed Running")
        EndTextCommandSetBlipName(blip)
    end
end)

RegisterCommand('endrun', function()
    if startedRunning then 
        endRun() 
    else 
        notify('You\'re ~r~NOT~s~ currently in a run.')
    end
end, false)