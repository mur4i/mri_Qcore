Citizen.CreateThread(function() 
    while mriQ.Framework == nil do
        if Config.Framework == 'ESX' then
            mriQ.Framework = exports["es_extended"]:getSharedObject()
        else if Config.Framework == 'QB' then
                mriQ.Framework = exports["qb-core"]:GetCoreObject()
            end
        end

        Citizen.Wait(1)
    end
end)