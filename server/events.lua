RegisterNetEvent("mri_Qcore:Server:HandleCallback")
AddEventHandler("mri_Qcore:Server:HandleCallback", function(name, payload)
    local source = source

    if mriQ.Callbacks[name] then
        mriQ.Callbacks[name](source, payload, function(cb) 
            TriggerClientEvent("mri_Qcore:Client:HandleCallback", source, name, cb)
        end)
    end 
end)

AddEventHandler("onResourceStart", function() 
    mriQ.CheckUpdate()
end)