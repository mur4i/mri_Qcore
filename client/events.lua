RegisterNetEvent("mri_Qcore:Client:HandleCallback")
AddEventHandler("mri_Qcore:Client:HandleCallback", function(name, data)
    if mriQ.Callbacks[name] then
        mriQ.Callbacks[name](data)
        mriQ.Callbacks[name] = nil
    end
end)

RegisterNetEvent("mri_Qcore:getSharedObject")
AddEventHandler("mri_Qcore:getSharedObject", function(cb)
    if cb and type(cb) == 'function' then
        cb(mriQ)
    end
end)
