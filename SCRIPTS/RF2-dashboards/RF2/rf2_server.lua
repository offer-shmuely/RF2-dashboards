local app_name = "rf2_server"
local baseDir = "/SCRIPTS/RF2-dashboards"

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_24=XLSIZE, FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}
local lvSCALE = lvgl.LCD_SCALE or 1
local is800 = (LCD_W==800)

local lvgl2 = { RGB=lcd.RGB }

rf2fc = {
    msp = {
        ctl = {
            connected = false,
            msp_rx_request = false,
            mspStatus = false,
            mspName = false,
            mspFlightStats = false,
            lastServerTime = 0,
            lastUpdateTime = 0,
        },
        cache = {
            mspName = nil,
            mspStatus = {
                flightModeFlags = nil,
                realTimeLoad = nil,
                cpuLoad = nil,
                armingDisableFlags = nil,
                profile = nil,
                rateProfile = nil,
            },
            mspTelemetryConfig = {
                telemetry_inverted = nil,
                telemetry_halfduplex = nil,
                telemetry_sensors = nil,
                telemetry_pinswap = nil,
                crsf_telemetry_mode = nil,
                crsf_telemetry_rate = nil,
                crsf_telemetry_ratio = nil,
                crsf_telemetry_sensors = nil,
            },
            mspFlightStats = {
                stats_total_flights = {value = nil},
                stats_total_time_s = {value = nil},
                stats_total_dist_m = {value = nil},
                stats_min_armed_time_s = {value = nil},
                -- Calculated fields
                statsEnabled = {value = nil},
            },
            mspBatteryConfig = {
                batteryCapacity = nil,
                batteryCellCount = nil,
            },
        },
    }
}

loadScript(baseDir.."/RF2/rf2.lua", "btd")()
rf2.enable_serial_debug = true


--------------------------------------------------------------
local function log(fmt, ...)
    rf2.log(fmt, ...)
    -- print(string.format("[%s] " .. fmt, app_name, ...))
end
--------------------------------------------------------------

log("-------------------------------------")
log("--- starting %s", app_name)

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_24=XLSIZE, FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

-- state machine
local STATE = {
    STARTING = 0,
    WAIT_FOR_CONNECTION_INIT = 1,
    WAIT_FOR_CONNECTION = 2,
    RETRIVE_PERMANENT_INFO_INIT = 3,
    RETRIVE_PERMANENT_INFO = 4,
    RETRIVE_LIVE_INFO_INIT = 5,
    RETRIVE_LIVE_INFO = 6,
    DONE_INIT = 7,
    DONE = 8,
    ON_AIR_INIT = 9,
    ON_AIR = 10,
}
local state = STATE.STARTING

local reqTS = 0
local backgroundTask
local interval_read_live_info_arm = 5
local interval_read_live_info_disarm = 1

local function tableToString(tbl)
    if (tbl == nil) then return "---" end
    local result = {}
    for key, value in pairs(tbl) do
        table.insert(result, string.format("%s: %s", tostring(key), tostring(value)))
    end
    return table.concat(result, ", ")
end

-----------------------------------------------------------------------------------------------------------------

local function build_ui(wgt)
    if (wgt == nil) then log("refresh(nil)") return end
    if (wgt.options == nil) then log("refresh(wgt.options=nil)") return end

    lvgl.clear()
    lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=function() return (rf2fc.msp.ctl.connected==true) and DARKGREEN or GREY end, filled=true})

    lvgl.image({x=0, y=0, w=wgt.zone.w, h=wgt.zone.h-5, fill=false,
        file=baseDir.."/img/rf2_logo.png"
        -- file=function() return (rf2fc.msp.ctl.connected==true) and baseDir.."/img/rf2_logo.png" or baseDir.."/img/rf2_logo2.png" end
    })

    -- lvgl.circle({x=63*lvSCALE, y=10*lvSCALE, radius=5, filled=true, color=function() return (rf2fc.msp.ctl.connected == true) and GREEN or GREY end})
    lvgl.circle({x=8*lvSCALE, y=8*lvSCALE, radius=5*lvSCALE, filled=true, color=function() return (rf2fc.msp.ctl.msp_rx_request) and GREEN or GREY end})

end


local function build_ui_dbg(wgt)
    if (wgt == nil) then log("refresh(nil)") return end
    if (wgt.options == nil) then log("refresh(wgt.options=nil)") return end

    local txt = [[
RF2 Server
rules of the house:
* only one server widget allowed
* disable original "RF Tool" lua widget (on topbar)
* disable original rf2bg lua script (on special-functions)
* disable original rf2tlm lua script (on custom-scripts)
* put the server widget on topbar
]]

    lvgl.clear()
    -- lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=GREY, filled=true})

    local y = 5

    lvgl.label({x=20*lvSCALE, y=y*lvSCALE, text=txt})
    y = y + 150

    lvgl.label({x=10*lvSCALE, y=y*lvSCALE, text=function() return string.format("state: %s", state) end})
    lvgl.label({x=100*lvSCALE, y=y*lvSCALE, color=ORANGE, text=" (on air, no MSP calls)", visible=function() return state == STATE.ON_AIR end})
    y = y + 20

    lvgl.label({x=10*lvSCALE, y=y*lvSCALE, text=function() return (rf2fc.msp.ctl.connected == true) and "Connected" or "Waiting for connection" end})

    lvgl.circle({x=63*lvSCALE, y=25*lvSCALE, radius=5, filled=true, color=function() return (rf2fc.msp.ctl.msp_rx_request) and GREEN or GREY end})

end

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options

    log("update options: %s", tableToString(options))

    local isOnTop = wgt.zone.h < 60 and wgt.zone.w < 120
    if isOnTop then
        build_ui(wgt)
    else
        build_ui_dbg(wgt)
    end

    return wgt
end

local function create(zone, options)
    local wgt = {
        zone = zone,
        options = options
    }
    return update(wgt, options)
end
-----------------------------------------------------------------------------------------------------------------

local function state_STARTING()
    log("STATE.STARTING")
    state = STATE.WAIT_FOR_CONNECTION_INIT
end

local function state_WAIT_FOR_CONNECTION_INIT(wgt)
    log("STATE.WAIT_FOR_CONNECTION_INIT")
    rf2.apiVersion = nil

    rf2.mspQueue = rf2.executeScript("MSP/mspQueue.lua")
    --rf2.showMemoryUsage("MSP queue loaded")
    rf2.mspQueue.maxRetries = 3
    rf2.mspHelper = rf2.executeScript("MSP/mspHelper.lua")
    --rf2.showMemoryUsage("MSP helper loaded")

    backgroundTask = loadScript(baseDir .."/RF2/background.lua", "btd")()

    state = STATE.WAIT_FOR_CONNECTION
end

local function state_WAIT_FOR_CONNECTION(wgt)
    log("\nSTATE.state_WAIT_FOR_CONNECTION")
    if wgt.is_telem == false then
        return
    end

    log("STATE.state_WAIT_FOR_CONNECTION (is_telem==on)")

    backgroundTask()

    -- isInitialized?
    if (rf2.apiVersion ~= nil) then
        state = STATE.RETRIVE_PERMANENT_INFO_INIT
        log("STATE.WAIT_FOR_CONNECTION: connected")
    end
end

local function state_RETRIVE_PERMANENT_INFO_INIT(wgt)
    log("STATE.RETRIVE_PERMANENT_INFO_INIT")

    rf2fc.msp.ctl.msp_rx_request = true
    rf2fc.msp.ctl.mspName = false

    log("msp_rx_request: %s", rf2fc.msp.ctl.msp_rx_request)

    -- rf2.useApi("mspApiVersion").getApiVersion(function(_, version)
    --         rf2fc.msp.ctl.connected = true
    --         rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
    --         rf2.apiVersion = version
    --         log("MSP> mspApiVersion: apiVersion: %s", rf2.apiVersion)
    --     end)

    -- mspName
    rf2.useApi("mspName").getModelName(function(_, ret)
        rf2fc.msp.ctl.connected = true
        rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
        log("MSP> got mspName: %s", ret)
        rf2fc.msp.cache.mspName = ret

        log("------ Heli Name: rf2fc.msp.ctl.connected %s", rf2fc.msp.ctl.connected)
        rf2fc.msp.ctl.mspName = true
    end)


    -- mspBatteryConfig
    rf2.useApi("mspBatteryConfig").getData(function(_, ret)
        rf2fc.msp.ctl.connected = true
        rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
        -- log("MSP> mspBatteryConfig: %s", tableToString(ret))
        rf2fc.msp.cache.mspBatteryConfig = ret
        -- log("MSP> mspBatteryConfig batteryCapacity: %s",        rf2fc.msp.cache.mspBatteryConfig.batteryCapacity)
        -- log("MSP> mspBatteryConfig batteryCellCount: %s",       rf2fc.msp.cache.mspBatteryConfig.batteryCellCount)
        rf2fc.msp.ctl.mspBatteryConfig = true
    end)

    reqTS = rf2.clock()
    state = STATE.RETRIVE_PERMANENT_INFO
end

local function state_RETRIVE_PERMANENT_INFO(wgt)
    log("STATE.RETRIVE_PERMANENT_INFO")

    log("rf2fc.msp.ctl.mspName: %s", rf2fc.msp.ctl.mspName)

    if      rf2fc.msp.ctl.mspName           == true
        and rf2fc.msp.ctl.mspBatteryConfig  == true
        then

        rf2fc.msp.ctl.msp_rx_request = false
        log("msp_rx_request: %s", rf2fc.msp.ctl.msp_rx_request)
        state = STATE.RETRIVE_LIVE_INFO_INIT
    end

    if (rf2.clock() - reqTS) > 10 then
        log("hang, read again...")
        state = STATE.RETRIVE_PERMANENT_INFO_INIT
    end

end

local function state_RETRIVE_LIVE_INFO_INIT(wgt)
    log("STATE.RETRIVE_LIVE_INFO_INIT")

    rf2fc.msp.ctl.msp_rx_request = true
    rf2fc.msp.ctl.mspStatus = false
    rf2fc.msp.ctl.mspTelemetryConfig = false
    rf2fc.msp.ctl.mspFlightStats = false

    log("msp_rx_request: %s", rf2fc.msp.ctl.msp_rx_request)

    -- mspStatus
    rf2.useApi("mspStatus").getStatus(function(_, ret)
        rf2fc.msp.ctl.connected = true
        rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
        -- log("MSP> mspStatus: %s", tableToString(ret))
        -- rf2fc.msp.cache.mspStatus = ret
        rf2fc.msp.cache.mspStatus = ret
        rf2fc.msp.ctl.mspStatus = true
    end)

    -- mspTelemetryConfig
    rf2.useApi("mspTelemetryConfig").getTelemetryConfig(function(_, ret)
        -- log("MSP> mspTelemetryConfig: %s", tableToString(ret))
        rf2fc.msp.cache.mspTelemetryConfig = ret
        log("MSP> mspTelemetryConfig crsf_telemetry_mode: %s, crsf_telemetry_rate: %s, crsf_telemetry_ratio: %s", ret.crsf_telemetry_mode.value, ret.crsf_telemetry_rate.value, ret.crsf_telemetry_ratio.value)
        rf2fc.msp.ctl.mspTelemetryConfig = true
    end)

    local function onReceiveFlightStat(x, config)
        -- rf2.log("Total flights 2: [%s]", config.stats_total_flights.value)
        -- rf2.log("Total flights 3: [%s]", rf2fc.msp.cache.mspFlightStats.stats_total_flights.value)
        rf2fc.msp.ctl.connected = true
        rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
        rf2fc.msp.ctl.mspFlightStats = true
        log("MSP> mspFlightStats stats_total_flights: %s, stats_total_time_s: %s, stats_min_armed_time_s: %s, statsEnabled: %s",
            rf2fc.msp.cache.mspFlightStats.stats_total_flights.value,
            rf2fc.msp.cache.mspFlightStats.stats_total_time_s.value,
            rf2fc.msp.cache.mspFlightStats.stats_min_armed_time_s.value,
            rf2fc.msp.cache.mspFlightStats.statsEnabled.value)
    end

    -- flights count
    if rf2.apiVersion >= 12.09 then
        rf2.useApi("mspFlightStats").read(onReceiveFlightStat, nil, rf2fc.msp.cache.mspFlightStats)
    else
        rf2fc.msp.ctl.mspFlightStats = true
    end


    reqTS = rf2.clock()
    state = STATE.RETRIVE_LIVE_INFO
end

local function state_RETRIVE_LIVE_INFO(wgt)
    -- log("STATE.RETRIVE_LIVE_INFO")

    if rf2fc.msp.ctl.mspStatus == true
        -- and rf2fc.msp.ctl.mspBatteryState == true
        and rf2fc.msp.ctl.mspTelemetryConfig == true
        and rf2fc.msp.ctl.mspFlightStats == true
    then
        rf2fc.msp.ctl.msp_rx_request = false
        -- log("[RETRIVE_LIVE_INFO] msp_rx_request: %s", rf2fc.msp.ctl.msp_rx_request)
        state = STATE.DONE_INIT
    end

    if (rf2.clock() - reqTS) > 10 then
        -- log("[RETRIVE_LIVE_INFO] hang, read again...")
        state = STATE.RETRIVE_LIVE_INFO_INIT
    end
end

local function state_DONE_INIT(wgt)
    log("STATE.DONE_INIT")
    backgroundTask()
    reqTS = rf2.clock()
    state = STATE.DONE
end

local function state_DONE(wgt)
    -- log("STATE.DONE")
    backgroundTask()

    local tLastRead = rf2.clock() - reqTS
    local intrv = interval_read_live_info_disarm

    local rpm = getValue("Hspd")
    if (rpm > 100) then
        log("motor running, move to on-air")
        state = STATE.ON_AIR_INIT
    end

    if tLastRead > intrv then
        log("interval to read again...")
        reqTS = rf2.clock()
        state = STATE.RETRIVE_LIVE_INFO_INIT
    end
end

local function state_ON_AIR_INIT(wgt)
    log("STATE.ON_AIR_INIT")
    backgroundTask()
    state = STATE.ON_AIR
end

local function state_ON_AIR(wgt)
    -- log("STATE.ON_AIR (no msp calls)")
    backgroundTask()
    -- fictive update time to avoid disconnection while on air
    rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
    local rpm = getValue("Hspd")
    if (rpm < 100) then
        log("landed, back to DONE")
        state = STATE.DONE_INIT
    end
end

local function background(wgt)
    if (wgt == nil) then return end

    rf2fc.msp.ctl.lastServerTime = rf2.clock()

    if state == STATE.ON_AIR then
        return state_ON_AIR(wgt)
    end

    -- not on air, msp allowed

    if (rf2.clock() - rf2fc.msp.ctl.lastUpdateTime) > 10 then
        rf2fc.msp.ctl.connected = false
    end
    -- if (getValue("RQly") <= 0 and getValue("VFR") <= 0) then
    --     rf2fc.msp.ctl.connected = false
    -- end

    -- wgt.is_telem = wgt.tools.isTelemetryAvailable()
    wgt.is_telem = (getRSSI() > 0)
    if wgt.is_telem == false then
        state = STATE.WAIT_FOR_CONNECTION_INIT
        return
    end

    if state >= STATE.RETRIVE_PERMANENT_INFO then
        rf2.mspQueue:processQueue()
    end

    if state == STATE.STARTING then
        return state_STARTING()

    elseif state == STATE.WAIT_FOR_CONNECTION_INIT then
        return state_WAIT_FOR_CONNECTION_INIT(wgt)
    elseif state == STATE.WAIT_FOR_CONNECTION then
        return state_WAIT_FOR_CONNECTION(wgt)

    elseif state == STATE.RETRIVE_PERMANENT_INFO_INIT then
        return state_RETRIVE_PERMANENT_INFO_INIT(wgt)
    elseif state == STATE.RETRIVE_PERMANENT_INFO then
        return state_RETRIVE_PERMANENT_INFO(wgt)

    elseif state == STATE.RETRIVE_LIVE_INFO_INIT then
        return state_RETRIVE_LIVE_INFO_INIT(wgt)
    elseif state == STATE.RETRIVE_LIVE_INFO then
        return state_RETRIVE_LIVE_INFO(wgt)

    elseif state == STATE.DONE_INIT then
        return state_DONE_INIT(wgt)
    elseif state == STATE.DONE then
        return state_DONE(wgt)

    elseif state == STATE.ON_AIR_INIT then
        return state_ON_AIR_INIT(wgt)
    elseif state == STATE.ON_AIR then
        return state_ON_AIR(wgt)
    end

    -- impossible state
    error("Something went wrong with the script!")
end

local function refresh(wgt)
    background(wgt)
end

return {name=app_name, create=create, update=update, refresh=refresh, background=background}

