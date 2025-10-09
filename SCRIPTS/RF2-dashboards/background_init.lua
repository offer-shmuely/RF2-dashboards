local initializationDone = false
local crsfCustomTelemetryEnabled = false
local crsfCustomTelemetrySensors = nil

local settings = {
    useAdjustmentTeller = 1,
}
local useAdjustmentTeller = settings.useAdjustmentTeller == 1 or false



local sensorsDiscoveredTimeout = 0
local hasSensor = rf2.executeScript("F/hasSensor")
local customTelemetryTask
local function waitForCrsfSensorsDiscovery()
    if not crossfireTelemetryPush() or rf2.runningInSimulator then
        -- Model does not use CRSF/ELRS
        return 0
    end

    local sensorsDiscovered = hasSensor("TPWR")
    if not sensorsDiscovered then
        -- Wait 10 secs for telemetry script to discover sensors before continuing with MSP calls,
        -- since MSP can interfere with discovering custom sensors
        sensorsDiscoveredTimeout = rf2.clock() + 10
    end

    if sensorsDiscoveredTimeout ~= 0 then
        if rf2.clock() < sensorsDiscoveredTimeout then
            --rf2.print("Waiting for sensors to be discovered...")
            customTelemetryTask = customTelemetryTask or assert(rf2.loadScript("rf2tlm.lua"))()
            customTelemetryTask.run()
            return 1 -- wait for sensors to be discovered
        end
        sensorsDiscoveredTimeout = 0
        customTelemetryTask = nil
        collectgarbage()
        return 2 -- sensors might just have been discovered
    end

    --rf2.print("Sensors already discovered")
    return 0
end

local queueInitialized = false
local function initializeQueue()
    --rf2.log("Initializing MSP queue")

    rf2.mspQueue.maxRetries = -1       -- retry indefinitely

    rf2.useApi("mspApiVersion").getApiVersion(
        function(_, version)
            rf2.log("API version: %s", version)
            rf2.apiVersion = version


            if rf2.apiVersion >= 12.07 then

                rf2.useApi("mspTelemetryConfig").getTelemetryConfig(
                    function(_, config)
                        crsfCustomTelemetryEnabled = config.crsf_telemetry_mode.value == 1
                        crsfCustomTelemetrySensors = config.crsf_telemetry_sensors
                    end)
            end

            rf2.useApi("mspSetRtc").setRtc(
                function()
                    playTone(1600, 300, 0, PLAY_BACKGROUND)
                    --rf2.print("RTC set")
                    rf2.mspQueue.maxRetries = 3
                    initializationDone = true
                end)
        end)
end

local function initialize(modelIsConnected)
    local sensorsDiscoveryWaitState = waitForCrsfSensorsDiscovery()
    if sensorsDiscoveryWaitState == 1 then
        return false
    end

    if not modelIsConnected then
        return false
    end

    if not queueInitialized then
        initializeQueue()
        queueInitialized = true
    end

    rf2.mspQueue:processQueue()

    return initializationDone
end

local function run(modelIsConnected)
    return
    {
        isInitialized = initialize(modelIsConnected),
        crsfCustomTelemetryEnabled = crsfCustomTelemetryEnabled,
        crsfCustomTelemetrySensors = crsfCustomTelemetrySensors
    }
end

local function reset()
    rf2.mspQueue:clear()
    rf2.apiVersion = nil
end

return { run = run, reset = reset, useAdjustmentTeller = useAdjustmentTeller }
