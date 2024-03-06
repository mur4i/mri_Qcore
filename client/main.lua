mriQ = {}
mriQ.Callbacks = {}
mriQ.Framework = nil
mriQ.Game = {}
mriQ.Functions = mriQ_Functions

mriQ.TriggerServerCallback = function(name, payload, func) 
    if not func then 
        func = function() end
    end

    mriQ.Callbacks[name] = func

    TriggerServerEvent("mri_Qcore:Server:HandleCallback", name, payload)
end

mriQ.Game.GetVehicleProperties = function(vehicle)
    if config.Framework == 'ESX' then
        return mriQ.Framework.Game.GetVehicleProperties(vehicle)
    elseif config.Framework == 'QB' then
        return mriQ.Framework.Functions.GetVehicleProperties(vehicle)
    end
end

mriQ.Game.SetVehicleProperties = function(vehicle, props) 
    if config.Framework == 'ESX' then
        return mriQ.Framework.Game.SetVehicleProperties(vehicle, props)
    elseif config.Framework == 'QB' then
        return mriQ.Framework.Functions.SetVehicleProperties(vehicle, props)
    end
end

mriQ.Draw3DText = function(x, y, z, scale, text, hideBox)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.40, 0.40)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)

    if not hideBox then 
        local factor = (string.len(text)) / 350

        DrawRect(_x,_y+0.0140, 0.025+ factor, 0.03, 0, 0, 0, 105)
    end
end

exports("getSharedObject", function()
    return mriQ
end)