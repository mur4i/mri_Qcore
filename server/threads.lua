Citizen.CreateThread(function() 
    while mriQ.Framework == nil do
        if config.Framework == 'ESX' then
            mriQ.Framework = exports["es_extended"]:getSharedObject()
        else if config.Framework == 'QB' then
                mriQ.Framework = exports["qb-core"]:GetCoreObject()
            end
        end

        Citizen.Wait(1)
    end
end)