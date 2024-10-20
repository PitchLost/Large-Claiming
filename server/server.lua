local oxmysql = exports['oxmysql']


local ClaimedBy = 'Nobody' -- track who currently has the blip claimed
local Winner -- Who won
local running = false
local randomBases = true


local bases = {
    route68 = { 
       team1 = vector3(36.4627, 2783.2817, 57.8781),
       team2 = vector3(1970.1016, 3112.8921, 46.9060)
    }, 
    upper_city = { 
        team1 = vector3(1153.3260, -470.0843, 66.5488), 
        team2 = vector3(323.8300, -216.1817, 54.0863)
    },
    upper_city2 = { 
        team1 = vector3(612.5729, 96.5348, 92.5296),
        team2 = vector3(-202.6879, 309.1059, 96.9464)
    },
    center_city = { 
        team1 = vector3(-544.9374, -898.9460, 24.0027), 
        team2 = vector3(-53.8968, -1112.8329, 26.4358)
    },
    lower_city = { 
        team1 = vector3(-56.4493, -1837.6132, 26.5895), 
        team2 = vector3(-310.7020, -1489.6252, 30.4560)
    },

}

local maps = {
    dorset = {
        label = 'Dorset Drive',
        coords = vector3(-505.2339, -442.6332, 34.4815),
        base = bases["upper_city"]
    },
    juice_stand = { 
        label = 'Juice Stand', 
        coords = vector3(-440.9536, 1595.0804, 358.4684),
        base = bases['route68']
    },
    hornbills = { 
        label = 'Hornbills', 
        coords = vector3(-379.4147, 218.2973, 83.6615),
        base = bases['upper_city']
    }, 
    mirror_dam = { 
        label = 'Mirror Dam', 
        coords = vector3(1672.0819, -26.4105, 173.7747),
        base = bases['upper_city']
    }, 
    vinewood_dam = { 
        label = 'Vinewood Dam', 
        coords = vector3(17.9526, 636.4360, 207.3899),
        base = bases['upper_city2']
    }, 
    southside_1 = { 
        label = 'Southside', 
        coords = vector3(87.3494, -1670.3772, 29.1794),
        base = bases['center_city']
    }, 
    sandy_shack = { 
        label = 'Sandy Shack', 
        coords = vector3(2156.6040, 3385.6965, 45.4848),
        base = bases['route68']
    }, 
    saints_hill_1 = { 
        label = 'South Saints Hills', 
        coords = vector3(1183.6158, 3265.2258, 39.3734), 
        base = bases['route68']
    }, 
    saints_hill_2 = { 
        label = 'North Saints Hill', 
        vector3(648.8430, 3506.5798, 34.0673),
        base = bases['route68']
    }, 
    route68 = { 
        label = 'Route 68', 
        coords = vector3(1202.1342, 2654.3083, 37.8519),
        base = bases['route68']
    }, 
    rehab_1 = { 
        label = 'Rehab 1',
        coords = vector3(-1572.2084, 772.6788, 189.1942),
        base = bases['upper_city2']
    },
    rehab_2 = { 
        lable = 'Rehab 2', 
        coords = vector3(-1516.6917, 851.4228, 181.5948),
        base = bases['upper_city']
    }

}




local function claimEnd() 
    -- Set the Winner global variable to the team that currently has the blip claimed
    Winner = ClaimedBy

    -- Trigger the end round event
    TriggerClientEvent('claiming:claimend', -1)

    -- Send a message to all players that the round is over
    TriggerClientEvent('chat:addMessage', -1, {args = {'Claiming','The Winner is... Team '.. Winner}, color = 255, 0, 0})

    -- Set the running flag to false ending all loops
    running = false
end

RegisterNetEvent('largeClaiming:claimStart', function(selection) 
    running = true
    -- Set the map
    local blipPos -- Define a variable to store the blipPos as
    local mapKeys = {} -- Have an array to iterate over with a random index

    -- Use a loop to iterate through each map adding it to the mapKeys
    for k in pairs(maps) do
        table.insert(mapKeys, k)
    end
    -- Make a randomMap variable to use if the selected map is random
    local randomMap = mapKeys[math.random(#mapKeys)]

    -- At the moment just set blipPos to the random map since there is no current function to decide between random or choosen map
    
        if selection == 'random' then
            print('random map')
            blipPos = maps[randomMap]

        else
            print('not random map', selection)
            blipPos = maps[selection]
        end
        
    

    print('blipPos.base',blipPos.base)
    print('blipPos.base.team1', blipPos.base.team1)
    TriggerClientEvent('server:largeClaimStart',-1,  
    blipPos.coords,
    blipPos.base,
    randomBases
)

print(blipPos.label)
TriggerClientEvent('chat:addMessage', -1, {args = {'Claiming','Claiming round started! The map is '.. blipPos.label}, color = 255, 0, 0})



   
Citizen.CreateThread(function()
    local time = 20 -- 20 mins

while true do
    if running == true then 
        

        
        while (time ~= 0) do -- Whist we have time to wait
            Wait( 60000 ) -- Wait a second
            time = time - 1
            local message = time.. ' minutes left'
            TriggerClientEvent('chat:addMessage', -1, {args = {'Claiming',message}, color = 255, 0, 0})
            print('Timer tick')
            -- 1 Second should have past by now
        end
        -- When the above loop has finished, the time should have passed. We can now do something
            claimEnd()
        end
    Citizen.Wait(100)
    end
end)
end)


-- Claiming round blip claim
RegisterNetEvent('largeClaiming:blipClaim', function(claimer) 
    -- This will check if the person that triggered the event already has the blip claimed. It will exit the function if they do
    if claimer == ClaimedBy then
        return
    end
    -- Now we know that the claimer does not have the blip so we can start executing the rest of claim function 
    
    -- Update the ClaimedBy global variable
    ClaimedBy = claimer

    -- Send a chat message to every player that the blip has been claimed
    TriggerClientEvent('chat:addMessage', -1, {args = {'Claiming','Blip claimed by Team '.. claimer}, color = 255, 0, 0})
end)

RegisterNetEvent('largeClaiming:teamJoin', function(team, name) 
    print(team, name)
    TriggerClientEvent('chat:addMessage', -1, {args = {'Claiming', name.. ' just joined team '.. team}, color = 255, 0, 0})
end)



