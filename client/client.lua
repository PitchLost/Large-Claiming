local ClaimRunning = false
local playersBase
local base1 = vector3(-1543.7310, -438.4480, 35.5967)
local base2 = vector3(966.0123, -130.2170, 74.3582)
local playersTeam = nil
local playersOutfitNumbers = {}
local blip -- Store a reference for the blip so it can be removed in the clean up function

-- Limit respawns variables 
local maxRespawns = 99
local respawnCount = 0

-- Timer respawn variables 
local respawnTime = 15
local timeLeft = respawnTime

-- Reset everything and remove the blip
    local function cleanUp()
        respawnCount = 0
        ClaimRunning = false
       -- TriggerEvent('qb-admin:client:ToggleNoClip', false) -- Take players out of no clip
        if blip then -- Check if the blip exists
            RemoveBlip(blip) -- Remove the blip
            blip = nil -- Reset the blip reference
        end
    end


    -- This is the function to limit the players respawns
    local function checkRespawnLimit() 
        local ped = GetPlayerPed(PlayerId())

        if ClaimRunning then
            respawnCount = respawnCount + 1
            print(maxRespawns, respawnCount)
            TriggerEvent('respawn:handleLivesUpdate', maxRespawns - respawnCount)
            if respawnCount == maxRespawns then 
                print('The player has used all of their respawns!')
                TriggerEvent('qb-admin:client:ToggleNoClip', true) -- Put the player into no clip
            end
    end
    end

    -- And this is the function to set a timer between each respawn instead
    
    local function waitRespawn() 
        TriggerEvent('respawn:canPlayerRespawn', false) 
        while (timeLeft ~= 0) do -- Whist we have time to wait
            Wait( 1000 ) -- Wait a second
            timeLeft = timeLeft - 1
            -- 1 Second should have past by now
            TriggerEvent('respawn:updateRespawnTimer', timeLeft)
            print(timeLeft)
        end
        TriggerEvent('respawn:canPlayerRespawn', true) 
        timeLeft = respawnTime
    end
    

-- Set player's outfit
local function setOutfit(ped, component, style, other1, other2)
    -- Trigger the server event with the outfit data
    print(PlayerId())
    TriggerServerEvent('setoutfit:changeOutfit', {component, style, other1, other2})
end

-- Show notification
local function ShowNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, 3000)
end

-- Join team function
local function joinTeam(team)
    print('Setting players team to:', team)
    TriggerServerEvent('largeClaiming:teamJoin', team, GetPlayerName(PlayerId()), PlayerId())
    playersTeam = team

    if team == 1 then 
        TriggerEvent('radio:forceconnect', 20)
    else if team == 2 then 
        TriggerEvent('radio:forceconnect', 30)
    end
end
end

-- Register commands for joining teams
RegisterCommand('join1', function() joinTeam(1) end, false)
RegisterCommand('join2', function() joinTeam(2) end, false)



-- Main command to start the round
RegisterCommand('largeStart', function()
    print('Player used a command to start the round')
    TriggerServerEvent('largeClaiming:claimStart')
end, false)

-- Set up large claim start event
RegisterNetEvent('server:largeClaimStart', function(BlipPosition, mapBases, useRandomBases)
    local ped = GetPlayerPed(PlayerId())
    SetEntityHealth(ped, 200) -- Heal player

    TriggerEvent('respawn:handleLivesUpdate', maxRespawns) -- Init the lives left ui

    -- Set the bases to random if needed

    if useRandomBases == true then 
        print(mapBases[1], mapBases[2])
        base1 = mapBases.team1
        base2 = mapBases.team2
    end



    -- Set outfit and base depending on team
    if playersTeam == 1 then
        -- Update the numbers for the players outfit
        playersOutfitNumbers = {11, 211, 0, 0}
        setOutfit(ped, playersOutfitNumbers[1], playersOutfitNumbers[2], playersOutfitNumbers[3], playersOutfitNumbers[4])
        playersBase = base1

    elseif playersTeam == 2 then
        -- Update the numbers for the players outfit
        playersOutfitNumbers = {11, 211, 1, 0}
        setOutfit(ped, playersOutfitNumbers[1], playersOutfitNumbers[2], playersOutfitNumbers[3], playersOutfitNumbers[4])
        playersBase = base2
    end



    SetEntityCoords(ped, playersBase.x, playersBase.y, playersBase.z, true, false, false, false)
    TriggerEvent('setSpawn:setPoint')
    -- Create blip on the map
    Citizen.CreateThread(function()
        local blipData ={ title = "Claiming Blip", colour = 5, id = 309, x = BlipPosition.x, y = BlipPosition.y, z = BlipPosition.z }
    
        

            blip = AddBlipForCoord(blipData.x, blipData.y, blipData.z)
            SetBlipSprite(blip, blipData.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, blipData.colour)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipData.title)
            EndTextCommandSetBlipName(blip)
        end) 
    ClaimRunning = true



    -- Main claiming loop
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if ClaimRunning then
                local playerCoords = GetEntityCoords(GetPlayerPed(PlayerId()))
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)

                if IsPedInVehicle(GetPlayerPed(PlayerId()), vehicle, false) then
                    SetVehicleColours(vehicle, playersTeam == 2 and 88 or 27, 1)
                end


                -- Check marker distance
                local distance = #(playerCoords - BlipPosition)
                if distance < 100.0 then
                    DrawMarker(21, BlipPosition.x, BlipPosition.y, BlipPosition.z + 1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 100, true, true, 2, nil, nil, false)
                    if distance < 2.0 then
                        ShowNotification('Press [G] to claim blip') 
                    if IsControlJustReleased(0, 47) then -- "G" key
                        ShowNotification('You claimed the blip')
                        TriggerServerEvent('largeClaiming:blipClaim', playersTeam)
                        print('Player has claimed the blip')
                    end
                end
                end
            end
        end
    end)
end)

-- Listen for the round end event
RegisterNetEvent('claiming:claimend', function() 
    SetEntityCoords(GetPlayerPed(PlayerId()), -1189.7291, -165.5747, 46.4072, true, false, false, false) -- Take player back to 

    cleanUp()
end)


-- Listen for the players spawn event to keep the players outfits set 
AddEventHandler('playerSpawned', function()
    print('Claiming:Player Spawned')
    setOutfit(ped, playersOutfitNumbers[1], playersOutfitNumbers[2], playersOutfitNumbers[3], playersOutfitNumbers[4]) -- Set the players outfit with the numbers set during the start claiming function
    Wait(100) -- Ensure that the setOutfit function runs only once
end)

-- Listen for the player dying

AddEventHandler('baseevents:onPlayerDied', function(killerType, deathData)
   checkRespawnLimit()
   waitRespawn()
end)

-- Listen for player getting killed by another player or themselves

AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
  checkRespawnLimit()
  waitRespawn()
end)



-- Start claiming from phone
RegisterNUICallback('phone:startClaiming', function(selection, cb) 
    print('Request from claiming app:', selection)
    TriggerServerEvent('largeClaiming:claimStart', selection.selection)
    cb('ok')  -- Sending a response back to the phone
end)

-- Join team from phone
RegisterNUICallback('phone:joinTeam', function(joiningTeam, cb) 
    print('Player joined team through phone:', joiningTeam)
    cb('ok')  -- Sending a response back to the phone
    joinTeam(joiningTeam.team)
end)

