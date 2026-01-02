local initTask = nil
local adjTellerTask = nil
local customTelemetryTask = nil
local isInitialized = false
local modelIsConnected = false
local lastTimeRssi = nil

--local function pilotConfigHasBeenReset()
--    return model.getGlobalVariable(7, 8) == 0
--end

local hasSensor = rf2.executeScript("F/hasSensor")

local function run()
    if getRSSI() > 0 and not modelIsConnected then
        modelIsConnected = true
    elseif getRSSI() == 0 and modelIsConnected then
        if lastTimeRssi and rf2.clock() - lastTimeRssi < 5 then
            -- Do not re-initialise if the RSSI is 0 for less than 5 seconds.
            -- This is also a work-around for https://github.com/ExpressLRS/ExpressLRS/issues/3207 (AUX channel bug in ELRS TX < 3.5.5)
            return
        end
        -- rf2.executeScript("F/pilotConfigReset")()
        if modelIsConnected then
            if initTask then
                initTask.reset()
                initTask = nil
            end
            adjTellerTask = nil
            customTelemetryTask = nil
            modelIsConnected = false
            isInitialized = false
            collectgarbage()
        end
    end

    if not isInitialized then
        adjTellerTask = nil
        customTelemetryTask = nil
        rf2.log("bg not initialized, running background_init.lua")
        collectgarbage()
        initTask = initTask or rf2.executeScript("background_init")
        local initTaskResult = initTask.run(modelIsConnected)
        if not initTaskResult.isInitialized then
            rf2.print("Not initialized yet")
            return 0
        end
        assert(initTaskResult.crsfCustomTelemetrySensors ~= nil, "crsfCustomTelemetrySensors is: nil")
        rf2.log("bg initTaskResult.crsfCustomTelemetryEnabled: %s", initTaskResult.crsfCustomTelemetryEnabled)
        if initTaskResult.crsfCustomTelemetryEnabled then
            rf2.log("bg loading rf2tlm_sensors.lua...")
            local requestedSensorsBySid = rf2.executeScript("rf2tlm_sensors.lua", initTaskResult.crsfCustomTelemetrySensors)
            rf2.log("bg loading rf2tlm.lua...")
            customTelemetryTask = rf2.executeScript("rf2tlm.lua", requestedSensorsBySid)
        end
        if initTask.useAdjustmentTeller then
            adjTellerTask = rf2.executeScript("adj_teller.lua")
        end
        initTask = nil
        isInitialized = true
        rf2.log("bg initialized")
    end

    if getRSSI() == 0 then
        return 0
    end

    -- rf2.log("adjTellerTask: %s", tostring(adjTellerTask))
    if adjTellerTask and adjTellerTask.run() == 2  then
        -- no adjustment sensors found
        rf2.log("adjTellerTask: no adjustment sensors found ---------------------------------")
        adjTellerTask = nil
        collectgarbage()
    end

    if customTelemetryTask then
        customTelemetryTask.run()
    end

    return 0
end

local function runProtected()
    local status, err = pcall(run)
    --[NIR
    if not status then rf2.print(err) end
    --]]
    --collectgarbage()
    --rf2.print("Mem: %d", collectgarbage("count")*1024)
    return isInitialized
end

return runProtected
