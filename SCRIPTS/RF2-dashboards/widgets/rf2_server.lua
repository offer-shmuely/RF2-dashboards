local app_name = "rf2_server"
local baseDir = "/SCRIPTS/RF2-dashboards/"

rf2fc = {
    mspCacheTools = nil,
    msp = {
        ctl = {
            connected = false,
            msp_rx_request = false,
            mspStatus = false,
            mspName = false,
            mspDataflash = false,
            -- mspGovernorConfig = false,
            lastServerTime = 0,
            lastUpdateTime = 0,
        },
        -- crsf_telemetry_sensors = {},
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
            mspDataflash = {
                ready = nil,
                supported = nil,
                sectors = nil,
                totalSize = nil,
                usedSize = nil,
            },
            -- mspGovernorConfig = {
            --     gov_mode = nil,
            --     gov_startup_time = nil,
            --     gov_spoolup_time = nil,
            --     gov_tracking_time = nil,
            --     gov_recovery_time = nil,
            --     gov_zero_throttle_timeout = nil,
            --     gov_lost_headspeed_timeout = nil,
            --     gov_autorotation_timeout = nil,
            --     gov_autorotation_bailout_time = nil,
            --     gov_autorotation_min_entry_time = nil,
            --     gov_handover_throttle = nil,
            --     gov_pwr_filter = nil,
            --     gov_rpm_filter = nil,
            --     gov_tta_filter = nil,
            --     gov_ff_filter = nil,
            -- },
            mspBatteryConfig = {
                batteryCapacity = nil,
                batteryCellCount = nil,
                voltageMeterSource = nil,
                currentMeterSource = nil,
                vbatMinCellVoltage = nil,
                vbatMaxCellVoltage = nil,
                vbatFullCellVoltage = nil,
                vbatWarningCellVoltage = nil,
                lvcPercentage = nil,
                consumptionWarningPercentage = nil,
            },
            -- mspBatteryState = {
            --     batteryState = nil,
            --     batteryCellCount = nil,
            --     batteryCapacity = nil,
            --     batteryCapacityUsed = nil,
            --     batteryVoltage = nil,
            --     batteryCurrent = nil,
            --     batteryPercentageRemaining = nil,
            -- },
            mspRescueProfile = {
                mode = nil,
                flip_mode = nil,
            },
            -- mspTelemetryConfig = {
            --     telemetry_inverted = nil,
            --     telemetry_halfduplex = nil,
            --     telemetry_sensors = nil,
            --     telemetry_pinswap = nil,
            --     crsf_telemetry_mode = nil,
            --     crsf_telemetry_rate = nil,
            --     crsf_telemetry_ratio = nil,
            --     crsf_telemetry_sensors = nil,
            -- },

        },
        telem = {

        }
    }
}

loadScript(baseDir.."rf2.lua")()
rf2.enable_serial_debug = true


-- local image_file = rf2.baseDir.."/widgets/img/rf2_logo2.png"
local image_file = rf2.baseDir.."/widgets/img/rf2_logo3.png"

--------------------------------------------------------------
local function log(fmt, ...)
    rf2.log(fmt, ...)
    -- print(string.format("[%s] " .. fmt, app_name, ...))
end
--------------------------------------------------------------

log("-------------------------------------")
log("--- starting %s", app_name)

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

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

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options

    local img = bitmap.open(image_file)
    wgt.img = bitmap.resize(img, wgt.zone.w, wgt.zone.h)

    log("update options: %s", tableToString(options))
    return wgt
end

local function create(zone, options)
    local wgt = {
        zone = zone,
        options = options
    }
    wgt.tools = assert(rf2.loadScript("/widgets/lib_widget_tools.lua"))(nil, app_name)
    wgt.mspCacheTools = assert(rf2.loadScript("/widgets/mspCacheTools.lua"))()
    rf2fc.mspCacheTools = wgt.mspCacheTools

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

    backgroundTask = rf2.loadScript("background.lua")()

    rf2.tlmEngine = rf2.loadScript("/rfsuite/tasks/telemetry/telemetry.lua")(rf2.runningInSimulator)
    log("x-telemetery tlmTask: %s", rf2.tlmEngine)
    rf2.tlmEngine.init()

    state = STATE.WAIT_FOR_CONNECTION
end

local function state_WAIT_FOR_CONNECTION(wgt)
    log("STATE.state_WAIT_FOR_CONNECTION")
    if wgt.is_telem == false then
        return
    end

    log("STATE.state_WAIT_FOR_CONNECTION (is_telem on)")

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
    -- rf2fc.msp.ctl.mspGovernorConfig = false
    rf2fc.msp.ctl.mspRescueProfile = false

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
        -- log("MSP> mspBatteryConfig voltageMeterSource: %s",     rf2fc.msp.cache.mspBatteryConfig.voltageMeterSource)
        -- log("MSP> mspBatteryConfig currentMeterSource: %s",     rf2fc.msp.cache.mspBatteryConfig.currentMeterSource)
        -- log("MSP> mspBatteryConfig vbatMinCellVoltage: %s",     rf2fc.msp.cache.mspBatteryConfig.vbatMinCellVoltage)
        -- log("MSP> mspBatteryConfig vbatMaxCellVoltage: %s",     rf2fc.msp.cache.mspBatteryConfig.vbatMaxCellVoltage)
        -- log("MSP> mspBatteryConfig vbatFullCellVoltage: %s",    rf2fc.msp.cache.mspBatteryConfig.vbatFullCellVoltage)
        -- log("MSP> mspBatteryConfig vbatWarningCellVoltage: %s", rf2fc.msp.cache.mspBatteryConfig.vbatWarningCellVoltage)
        -- log("MSP> mspBatteryConfig lvcPercentage: %s",          rf2fc.msp.cache.mspBatteryConfig.lvcPercentage)
        -- log("MSP> mspBatteryConfig consumptionWarningPercentage: %s", rf2fc.msp.cache.mspBatteryConfig.consumptionWarningPercentage)

        rf2fc.msp.ctl.mspBatteryConfig = true
    end)

    -- -- mspGovernorConfig
    -- rf2.useApi("mspGovernorConfig").read(function(_, ret)
    --     rf2fc.msp.ctl.connected = true
    --     rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
    --     log("MSP> mspGovernorConfig: %s", tableToString(ret))
    --     rf2fc.msp.cache.mspGovernorConfig = ret
    --     -- log("MSP> mspGovernorConfig: gov_mode: %s", tableToString(ret.gov_mode))
    --     -- log("MSP> mspGovernorConfig: gov_mode: %s", ret.gov_mode.value)
    --     -- log("MSP> mspGovernorConfig: gov_mode: %s", ret.gov_mode.table[ret.gov_mode.value])
    --     -- log("MSP> mspGovernorConfig: %s", tableToString(ret.gov_autorotation_bailout_time))
    --     log("MSP> mspGovernorConfig: governorMode: %s", wgt.mspCacheTools.governorMode())
    --     log("MSP> mspGovernorConfig: governorMode----: %s", wgt.mspCacheTools.governorMode())
    --     log("MSP> mspGovernorConfig: governorEnabled: %s", wgt.mspCacheTools.governorEnabled())

    --     rf2fc.msp.ctl.mspGovernorConfig = true
    -- end)

    -- mspRescueProfile
    rf2.useApi("mspRescueProfile").read(function(_, ret)
        rf2fc.msp.ctl.connected = true
        rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
        log("MSP> mspRescueProfile: %s", tableToString(ret))
        rf2fc.msp.cache.mspRescueProfile = ret

        rf2fc.msp.ctl.mspRescueProfile = true
    end)

    reqTS = rf2.clock()
    state = STATE.RETRIVE_PERMANENT_INFO
end

local function state_RETRIVE_PERMANENT_INFO(wgt)
    log("STATE.RETRIVE_PERMANENT_INFO")

    log("rf2fc.msp.ctl.mspName: %s", rf2fc.msp.ctl.mspName)
    -- log("rf2fc.msp.ctl.mspGovernorConfig: %s", rf2fc.msp.ctl.mspGovernorConfig)
    log("rf2fc.msp.ctl.mspRescueProfile: %s", rf2fc.msp.ctl.mspRescueProfile)

    if      rf2fc.msp.ctl.mspName           == true
        and rf2fc.msp.ctl.mspBatteryConfig  == true
        -- and rf2fc.msp.ctl.mspGovernorConfig == true
        and rf2fc.msp.ctl.mspRescueProfile  == true
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
    rf2fc.msp.ctl.mspDataflash = false

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


    -- -- mspBatteryState
    -- rf2.useApi("mspBatteryState").getData(function(_, ret)
    --     rf2fc.msp.ctl.connected = true
    --     rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
    --     -- log("MSP> mspBatteryState: %s", tableToString(ret))
    --     rf2fc.msp.cache.mspBatteryState = ret

    --     -- log("MSP> mspBatteryState batteryState: %s",         rf2fc.msp.cache.mspBatteryState.batteryState)
    --     -- log("MSP> mspBatteryState batteryCellCount: %s",     rf2fc.msp.cache.mspBatteryState.getBbatteryCellCountatteryCellCount)
    --     -- log("MSP> mspBatteryState batteryCapacity: %s",      rf2fc.msp.cache.mspBatteryState.batteryCapacity)
    --     -- log("MSP> mspBatteryState batteryCapacityUsed: %s",  rf2fc.msp.cache.mspBatteryState.batteryCapacityUsed)
    --     -- log("MSP> mspBatteryState batteryVoltage: %s",       rf2fc.msp.cache.mspBatteryState.batteryVoltage)
    --     -- log("MSP> mspBatteryState batteryCurrent: %s",       rf2fc.msp.cache.mspBatteryState.getBatteryCurrent)
    --     -- log("MSP> mspBatteryState batteryPercentageRemaining: %s",    rf2fc.msp.cache.mspBatteryState.batteryPercentageRemaining)

    --     rf2fc.msp.ctl.mspBatteryState = true
    -- end)

    -- mspDataflash
    rf2.useApi("mspDataflash").getDataflashSummary(function(_, ret)
        rf2fc.msp.ctl.connected = true
        rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
        -- log("MSP> mspDataflash: %s", tableToString(ret))
        rf2fc.msp.cache.mspDataflash = ret
        -- log("MSP> mspDataflash total: %s, used: %s, free: %s", wgt.mspCacheTools.blackboxSize().totalSize, wgt.mspCacheTools.blackboxSize().usedSize, wgt.mspCacheTools.blackboxSize().freeSize)
        rf2fc.msp.ctl.mspDataflash = true
    end)

    reqTS = rf2.clock()
    state = STATE.RETRIVE_LIVE_INFO
end

local function state_RETRIVE_LIVE_INFO(wgt)
    log("STATE.RETRIVE_LIVE_INFO")

    if rf2fc.msp.ctl.mspStatus == true
        -- and rf2fc.msp.ctl.mspBatteryState == true
        and rf2fc.msp.ctl.mspDataflash == true
    then
        rf2fc.msp.ctl.msp_rx_request = false
        -- log("msp_rx_request: %s", rf2fc.msp.ctl.msp_rx_request)
        state = STATE.DONE_INIT
    end

    if (rf2.clock() - reqTS) > 10 then
        log("hang, read again...")
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
    local intrv = rf2fc.mspCacheTools.isArmed() and interval_read_live_info_arm or interval_read_live_info_disarm
    -- rf2.log("isArm: %s, intrv: %s", rf2fc.mspCacheTools.isArmed(), intrv)

    local rpm = getValue("Hspd")
    --rpm = 1000 --?????????????????????
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
    log("STATE.ON_AIR (no msp calls)")
    backgroundTask()
    -- fictive update time to avoid disconnection while on air
    rf2fc.msp.ctl.lastUpdateTime = rf2.clock()
    local rpm = getValue("Hspd")
    --rpm = 1000 --?????????????????????
    if (rpm < 100) then
        log("landed, back to DONE")
        state = STATE.DONE_INIT
    end
end

local function background(wgt)
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

    wgt.is_telem = wgt.tools.isTelemetryAvailable()
    if wgt.is_telem == false then
        state = STATE.WAIT_FOR_CONNECTION_INIT
        return
    end

    if state >= STATE.RETRIVE_PERMANENT_INFO then
        rf2.mspQueue:processQueue()
    end

    -- log("STATE.???")
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
    if (wgt == nil) then return end
    background(wgt)

    local bg_color = lcd.RGB(0x11, 0x11, 0x11)
    local txt_color = BLACK
    bg_color = GREY
    if rf2fc.msp.ctl.connected == true then
        bg_color = GREEN
        txt_color = BLACK
    end

    if rf2fc.msp.cache.armed == true then
        bg_color = ORANGE
    end

    local isOnTop = wgt.zone.h < 60 and wgt.zone.w < 120
    -- lcd.drawFilledRectangle(0, 0, LCD_W, LCD_H, bg_color)
    if isOnTop then
        lcd.drawFilledRectangle(0, 0, LCD_W, LCD_H, BLACK)
    end

    lcd.drawFilledCircle(63, 10, 5, bg_color)
    -- lcd.drawFilledRectangle(0, 0, wgt.zone.w, 60, bg_color)
    local y = 5

    -- rx/tx status
    lcd.drawFilledCircle(63, 25, 5, (rf2fc.msp.ctl.msp_rx_request) and GREEN or GREY)

    -- dbg
    lcd.drawText(wgt.zone.w - 20, 0, string.format("s:%s", state), FS.FONT_6 + GREY)

    if isOnTop then
        lcd.drawBitmap(wgt.img, 0, 0)
        local color1 = rf2fc.msp.ctl.connected and lcd.RGB(0x26C4FF) or GREY
        local color2 = rf2fc.msp.ctl.connected and ORANGE or GREY
        -- lcd.drawText(4 , -4, "RF", FS.FONT_16 + color1)
        -- lcd.drawText(37,  3,  "2", FS.FONT_16 + color1)
    else
        local txt = [[
RF2 Server
rules of the house:
* only one server widget allowed
* disable original rf2bg lua script on Special-Functions
* disable original rf2tlm lua script on custom-scripts
* put the server widget on topbar
]]

        lcd.drawText(20, y, txt, FS.FONT_8)
        y = y + 150

        lcd.drawText(10, y, string.format("state: %s", state), FS.FONT_6)
        if (state == STATE.ON_AIR) then
            lcd.drawText(100, y, " (on air, no MSP calls)", FS.FONT_6 + ORANGE)
        end
        y = y + 20

        lcd.drawText(10, y, (rf2fc.msp.ctl.connected == true) and "Connected" or "Waiting for connection", FS.FONT_6)
    end

end

return {name=app_name, create=create, update=update, refresh=refresh, background=background}

