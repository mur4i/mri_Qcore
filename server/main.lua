mriQ = {}
mriQ.Callbacks = {}
mriQ.Players = {}
mriQ.Framework = nil
mriQ.Functions = mriQ_Functions
mriQ.Vehicles = nil
mriQ.MySQL = {
    Async = {},
    Sync = {}
}

mriQ.RegisterServerCallback = function(name, func) 
    mriQ.Callbacks[name] = func
end

mriQ.TriggerCallback = function(name, source, payload, cb) 
    if not cb then 
        cb = function() end
    end

    if mriQ.Callbacks[name] then 
        mriQ.Callbacks[name](source, payload, cb)
    end
end

mriQ.Log = function(str) 
    print("[\x1b[44mmri_Qcore\x1b[0m]: " .. str)
end

mriQ.MySQL.Async.Fetch = function(query, variables, cb) 
    if not cb or type(cb) ~= 'function' then 
        cb = function() end
    end

    if Config.MySQL == 'mysql-async' then
        return exports["mysql-async"]:mysql_fetch_all(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        return exports["oxmysql"]:prepare(query, variables, cb) 
    end
end

mriQ.MySQL.Sync.Fetch = function(query, variables) 
    local result = {}
    local finishedQuery = false
    local cb = function(r) 
        result = r
        finishedQuery = true
    end

    if Config.MySQL == 'mysql-async' then
        exports["mysql-async"]:mysql_fetch_all(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        exports["oxmysql"]:execute(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end

    return result
end

mriQ.MySQL.Async.Execute = function(query, variables, cb) 
    if Config.MySQL == 'mysql-async' then
        return exports["mysql-async"]:mysql_execute(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        return exports["oxmysql"]:update(query, variables, cb)
    end
end

mriQ.MySQL.Sync.Execute = function(query, variables) 
    local result = {}
    local finishedQuery = false
    local cb = function(r) 
        result = r
        finishedQuery = true
    end

    if Config.MySQL == 'mysql-async' then
        exports["mysql-async"]:mysql_execute(query, variables, cb) 
    elseif Config.MySQL == 'oxmysql' then
        exports["oxmysql"]:execute(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end
    
    return result
end

mriQ.IsPlayerAvailable = function(source) 
    local available = false

    if type(source) == 'number' then 
        if Config.Framework == 'ESX' then
            available = mriQ.Framework.GetPlayerFromId(source) ~= nil
        elseif Config.Framework == 'QB' then
            available = mriQ.Framework.Functions.GetPlayer(source) ~= nil
        end
    elseif type(source) == 'string' then
        if Config.Framework == 'ESX' then
            available = mriQ.Framework.GetPlayerFromIdentifier(identifier) ~= nil
        elseif Config.Framework == 'QB' then
            available = mriQ.Framework.Functions.GetSource(identifier) ~= nil
        end
    end

    return available
end

mriQ.GetPlayerIdentifier = function(source)
    if mriQ.IsPlayerAvailable(source) then
        if Config.Framework == 'ESX' then
            local xPlayer = mriQ.Framework.GetPlayerFromId(source)
            return xPlayer.getIdentifier()
        elseif Config.Framework == 'QB' then
            return mriQ.Framework.Functions.GetIdentifier(source, 'license')
        end
    else
        return nil
    end
end

mriQ.CreatePlayer = function(xPlayer) 
    local player = {}

    if not xPlayer then 
        return nil
    end

    if Config.Framework == 'ESX' then 
        player.name = xPlayer.getName()
        player.accounts = {}
        for _,v in ipairs(xPlayer.getAccounts()) do 
            if v.name == 'bank' then 
                player.accounts["bank"] = v.money
            elseif v.name == 'money' then
                player.accounts["cash"] = v.money
            end
        end
        if xPlayer.variables.sex == 'm' then 
            player.gender = 'male' 
        else
            player.gender = 'female'
        end
        player.job = {
            name = xPlayer.getJob().name,
            label = xPlayer.getJob().label
        }
        player.birth = xPlayer.variables.dateofbirth

        player.getBank = function() 
            return xPlayer.getAccount("bank").money 
        end
        player.getMoney = xPlayer.getMoney
        player.addBank = function(amount) 
            xPlayer.addAccountMoney('bank', amount) 
        end
        player.addMoney = xPlayer.addMoney
        player.removeBank = function(amount) 
            xPlayer.removeAccountMoney('bank', amount) 
        end
        player.removeMoney = xPlayer.removeMoney
    elseif Config.Framework == 'QB' then
        player.name = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        player.accounts = {
            bank =  xPlayer.PlayerData.money.bank,
            cash = xPlayer.PlayerData.money.cash
        }
        if xPlayer.PlayerData.charinfo.gender == 0 then 
            player.gender = 'male'
        else
            player.gender = 'female'
        end
        player.job = {
            name = xPlayer.PlayerData.job.name,
            label = xPlayer.PlayerData.job.label
        }
        player.birth = xPlayer.PlayerData.charinfo.birthdate

        player.getBank = function() 
            return xPlayer.Functions.GetMoney("bank")
        end
        player.getMoney = function()
            return xPlayer.Functions.GetMoney("cash") 
        end
        player.addBank = function(amount)
            return xPlayer.Functions.AddMoney("bank", amount, "") 
        end
        player.addMoney = function(amount)
            return xPlayer.Functions.AddMoney("cash", amount, "") 
        end
        player.removeBank = function(amount) 
            return xPlayer.Functions.RemoveMoney("bank", amount, "")
        end
        player.removeMoney = function(amount) 
            return xPlayer.Functions.RemoveMoney("cash", amount, "")
        end
    end

    return player
end

mriQ.GetPlayer = function(source)
    if mriQ.IsPlayerAvailable(source) then 
        local xPlayer = nil

        if Config.Framework == 'ESX' then
            xPlayer = mriQ.Framework.GetPlayerFromId(source)
        elseif Config.Framework == 'QB' then
            xPlayer = mriQ.Framework.Functions.GetPlayer(source)
        end

        return mriQ.CreatePlayer(xPlayer)
    else
        return nil
    end
end

mriQ.GetPlayerFromIdentifier = function(identifier) 
    if mriQ.IsPlayerAvailable(identifier) then 
        local xPlayer = nil

        if Config.Framework == 'ESX' then
            xPlayer = mriQ.Framework.GetPlayerFromIdentifier(identifier)
        elseif Config.Framework == 'QB' then
            xPlayer = mriQ.Framework.Functions.GetPlayer(mriQ.Framework.Functions.GetSource(identifier))
        end

        return mriQ.CreatePlayer(xPlayer)
    else
        return nil
    end
end

mriQ.GetAllVehicles = function(force)
    if mriQ.Vehicles and not force then 
        return mriQ.Vehicles
    end

    local vehicles = {}

    if Config.Framework == 'ESX' then
        local data = mriQ.MySQL.Sync.Fetch("SELECT * FROM vehicles", {})

        for k, v in ipairs(data) do 
            vehicles[v.model] = {
                model = v.model,
                name = v.name,
                category = v.category,
                price = v.price
            }
        end
        
    elseif Config.Framework == 'QB' then 
        for k,v in pairs(mriQ.Framework.Shared.Vehicles) do
            vehicles[k] = {
                model = k,
                name = v.name,
                category = v.category,
                price = v.price
            } 
        end
    end

    mriQ.Vehicles = vehicles

    return vehicles
end

mriQ.GetVehicleByName = function(name) 
    local vehicles = mriQ.GetAllVehicles(false)
    local targetVehicle = nil

    for k,v in pairs(vehicles) do
        if v.name == name then 
            targetVehicle = v
            break
        end
    end 

    return targetVehicle
end

mriQ.GetVehicleByHash = function(hash) 
    local vehicles = mriQ.GetAllVehicles(false)
    local targetVehicle = nil

    for k,v in pairs(vehicles) do
        if GetHashKey(v.model) == hash then 
            targetVehicle = v
            break
        end
    end

    return targetVehicle
end

mriQ.GetPlayerVehicles = function(source) 
    local identifier = mriQ.GetPlayerIdentifier(source)

    if identifier then 
        local vehicles = mriQ.GetAllVehicles(false)
        local playerVehicles = {}

        if Config.Framework == 'ESX' then
            local data = mriQ.MySQL.Sync.Fetch("SELECT * FROM owned_vehicles WHERE owner = @identifier", { ["@identifier"] = identifier })

            for k,v in ipairs(data) do
                local vehicleDetails = mriQ.GetVehicleByHash(json.decode(v.vehicle).model)

                if not vehicleDetails then 
                    vehicleDetails = {
                        name = nil,
                        model = json.decode(v.vehicle).model,
                        category = nil,
                        price = nil
                    }
                end

                table.insert(playerVehicles, {
                    name = vehicleDetails.name,
                    model = vehicleDetails.model,
                    category = vehicleDetails.category,
                    plate = v.plate,
                    fuel = v.fuel or 100,
                    price = vehicleDetails.price,
                    properties = json.decode(v.vehicle),
                    stored = v.stored,
                    garage = v.garage or nil
                })
            end
        elseif Config.Framework == 'QB'  then
            local data = mriQ.MySQL.Sync.Fetch("SELECT * FROM player_vehicles WHERE license = @identifier", { ["@identifier"] = identifier })

            for k,v in ipairs(data) do
                if v.stored == 1 then
                    v.stored = true
                else
                    v.stored = false 
                end

                table.insert(playerVehicles, {
                    name = vehicles[v.vehicle].name,
                    model = vehicles[v.vehicle].model,
                    category = vehicles[v.vehicle].category,
                    plate = v.plate,
                    fuel = v.fuel,
                    price = vehicles[v.vehicle].price or -1,
                    properties = json.decode(v.mods),
                    stored = v.stored,
                    garage = v.garage
                })
            end
        end

        return playerVehicles
    else
        return nil
    end
end

mriQ.UpdatePlayerVehicle = function(source, plate, vehicleData) 
    local identifier = mriQ.GetPlayerIdentifier(source)

    if identifier then 
        local playerVehicles = mriQ.GetPlayerVehicles(source)
        local targetVehicle = nil

        for k,v in ipairs(playerVehicles) do
             if v.plate == plate then
                targetVehicle = v 
            end
        end

        if not targetVehicle then 
            return false
        end

        local query = nil
        if Config.Framework == 'ESX' then
            query = "UPDATE owned_vehicles SET vehicle = @props, stored = @stored, garage = @garage WHERE owner = @identifier AND plate = @plate"
        elseif Config.Framework == 'QB' then
            query = "UPDATE player_vehicles SET mods = @props, stored = @stored, garage = @garage WHERE license = @identifier AND plate = @plate"
        end

        if query then 
            mriQ.MySQL.Sync.Execute(query, {
            ["@props"] = json.encode(vehicleData.properties or targetVehicle.properties),
            ["@stored"] = vehicleData.stored,
            ["@garage"] = vehicleData.garage,
            ["@identifier"] = identifier,
            ["@plate"] = plate
            })

            return true
        else
            return false
        end

    else
        return false
    end
end

mriQ.UpdateVehicleOwner = function(plate, target) 
    local identifier = mriQ.GetPlayerIdentifier(target)

    if not identifier then 
        return false
    end

    local query = nil
    if Config.Framework == 'ESX' then
        query = "UPDATE owned_vehicles SET owner = @newOwner WHERE plate = @plate" 
    elseif Config.Framework == 'QB' then
        query = "UPDATE player_vehicles SET license = @newOwner WHERE plate = @plate"
    end

    if query then 
        mriQ.MySQL.Sync.Execute(query, { ["@newOwner"] = identifier, ["@plate"] = plate })

        return true
    else
        return false
    end
end

mriQ.CheckUpdate = function() 
    PerformHttpRequest("https://api.github.com/repos/tunasayin/mri_Qcore/releases/latest", function(errorCode, rawData, headers) 
        if rawData ~= nil then
            local data = json.decode(tostring(rawData))
            local version = string.gsub(data.tag_name, "v", "")
            local installedVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

            if installedVersion == version then
                mriQ.Log("An update is available for mri_Qcore. Download update from: " .. data.html_url) 
            end
        end
    end)
end

exports("getSharedObject", function() 
    return mriQ
end)