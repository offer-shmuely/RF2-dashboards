---- #########################################################################
---- #                                                                       #
---- # License: Creative Commons Attribution-NoDerivatives 4.0 (CC BY-ND)    #
---- # https://creativecommons.org/licenses/by-nd/4.0/                       #
---- #                                                                       #
---- # You are free to use and modify this software for personal use.        #
---- # You may share this software in its original, unmodified form,         #
---- # as long as appropriate credit is given to the original author.        #
---- #                                                                       #
---- # Redistribution of modified versions is NOT permitted.                 #
---- #                                                                       #
---- # Copyright (c) 2023-2026 Offer Shmuely. All rights reserved.           #
---- #                                                                       #
---- #########################################################################

local arg = {...}
local log = arg[1]
local app_name = arg[2]
local baseDir = arg[3]
local tools = arg[4]
local statusbar = arg[5]
local inSimu = arg[6]

-- better font size names
local FS = {FONT_38=XXLSIZE, FONT_16=DBLSIZE, FONT_12=MIDSIZE, FONT_8=0, FONT_6=SMLSIZE}
local lvSCALE = lvgl.LCD_SCALE or 1

-- sensor list: built dynamically from wgt.tlmEngine.sensorTable at build_ui time
local sensorIds = {}

-- status values per sensor: nil=not run, ok, fail, missing, duplicated
local testState = {
    ran     = false,
    final_result = "-- not tested yet--",
    sensors = {
        -- name
        -- defined_in_rf
        -- exist_in_etx
        -- unique
        -- is_ok
    },
}

-- populate sensorIds and testState from the live telemetry engine sensor table
local function buildSensorList(wgt)
    sensorIds = {}
    for _, entry in pairs(wgt.tlmEngine.sensorTable) do
        if entry.sourceId ~= nil then
            sensorIds[#sensorIds + 1] = entry.sourceId
        end
    end
    table.sort(sensorIds)
    testState.ran     = false
    testState.sensors = {}
    for i = 1, #sensorIds do
        testState.sensors[i] = {
            name = sensorIds[i],
            defined_in_rf = nil,
            exist_in_etx = nil,
            unique = nil,
            is_ok = nil,
        }
    end
    log("build_sensor_list: found %s sensors", tostring(#sensorIds))
end

---------------------------------------------------------------------------------------------------
-- build a set of sensor names that appear more than once in the model
local function buildDuplicateSet()
    local seen    = {}
    local dup_set = {}
    for i = 0, 40 do
        local s = model.getSensor(i)
        if s ~= nil then
            local name = s.name
            if seen[name] then
                dup_set[name] = true
            else
                seen[name] = true
            end
        end
    end
    return dup_set
end

local RF_SENSOR_ID_BY_SOURCE = {
    Vbat = 3,
    Curr = 4,
    Capa = 5,
    Thr = 15,
    Vbec = 43,
    Tesc = 50,
    Hspd = 60,
    ARM = 90,
    ARMD = 91,
    ["PID#"] = 95,
    ["RTE#"] = 96,
}

local function isDefinedInRf(sensorName)

    local crsf_telemetry_sensors = rf2fc.msp.cache.mspTelemetryConfig.crsf_telemetry_sensors

    if crsf_telemetry_sensors == nil then
        return true --???
    end

    local sensorId = RF_SENSOR_ID_BY_SOURCE[sensorName]
    if sensorId == nil then
        return false
    end

    if crsf_telemetry_sensors ~= nil then
        for i = 1, #crsf_telemetry_sensors do
            if crsf_telemetry_sensors[i] == sensorId then
                return true
            end
        end
    end

    local telemetrySensorsMask = cfg.telemetry_sensors
    if type(telemetrySensorsMask) == "table" then
        telemetrySensorsMask = telemetrySensorsMask.value
    end
    if type(telemetrySensorsMask) == "number" and sensorId >= 0 and sensorId < 32 then
        if bit32.band(telemetrySensorsMask, bit32.lshift(1, sensorId)) ~= 0 then
            return true
        end
    end

    return false
end

local function requestTelemetryConfig(callback)
    if rf2 == nil or rf2.useApi == nil then
        log("request_telemetry_config: rf2 api unavailable")
        callback(nil)
        return
    end

    local mspTelemetryConfig = rf2.useApi("mspTelemetryConfig")
    if mspTelemetryConfig == nil or mspTelemetryConfig.getTelemetryConfig == nil then
        log("request_telemetry_config: msptelemetryconfig api unavailable")
        callback(nil)
        return
    end

    mspTelemetryConfig.getTelemetryConfig(function(_, config)
        callback(config)
    end)
end


local function runTests()
    testState.final_result = "OK"

    for i = 1, #sensorIds do
        local name = sensorIds[i]
        testState.sensors[i].name = name
        testState.sensors[i].defined_in_rf = nil
        testState.sensors[i].exist_in_etx = nil
        testState.sensors[i].unique = nil
        testState.sensors[i].is_ok = nil
    end

    for i = 1, #sensorIds do
        local name = sensorIds[i]
        local defined_in_rf = isDefinedInRf(name)
        testState.sensors[i].defined_in_rf = defined_in_rf

        log("run_tests: sensor=%s defined_in_rf=%s", name, tostring(defined_in_rf))
        if defined_in_rf == false then
            testState.final_result = "FAIL"
        end
    end

    -- is exist in etx?
    for i = 1, #sensorIds do
        local name = sensorIds[i]
        local exist_in_etx = tools.isSensorExist(name)
        testState.sensors[i].exist_in_etx = exist_in_etx

        log("run_tests: sensor=%s exist_in_etx=%s", name, tostring(exist_in_etx))
        if not exist_in_etx then
            testState.final_result = "FAIL"
        end
    end

    -- is unique model? (not duplicated)
    local dup_set = buildDuplicateSet()
    for i = 1, #sensorIds do
        local name = sensorIds[i]
        if dup_set[name] then
            testState.sensors[i].unique = false
            testState.final_result = "FAIL"
        else
            testState.sensors[i].unique = true
        end
        log("run_tests: sensor=%s unique=%s", name, tostring(testState.sensors[i].unique))
    end

    for i = 1, #sensorIds do
        local name = sensorIds[i]
        local sensorState = testState.sensors[i]
        if sensorState.defined_in_rf == false or sensorState.exist_in_etx == false or sensorState.unique == false then
            sensorState.is_ok = false
        elseif sensorState.defined_in_rf == true and sensorState.exist_in_etx == true and sensorState.unique == true then
            sensorState.is_ok = true
        else
            sensorState.is_ok = nil
        end
        log("run_tests: sensor=%s is_ok=%s", name, tostring(sensorState.is_ok))
    end

    testState.ran = true
end


-- local function runTests()
--     log("run_tests: running sensor diagnostics")

--     testState.ran = false
--     requestTelemetryConfig(
--         function(cfg)
--             log("run_tests: telemetry config available=%s", tostring(cfg ~= nil))
--             runTestsWithConfig(cfg)
--         end
--     )
-- end

---------------------------------------------------------------------------------------------------
local M = {}

local function getBoolText(value)
    if value == nil then
        return "---"
    end
    if value then
        return "OK"
    end
    return "NO"
end

local function getBoolColor(value)
    if value == nil then
        return LIGHTGREY
    end
    if value then
        return GREEN
    end
    return RED
end

local function getBoolTextColor(value)
    if value == nil then
        return BLACK
    end
    return WHITE
end


local function getStatusColor(sensorState)
    if sensorState == nil then
        return LIGHTGREY
    end
    if sensorState.unique == false then
        return YELLOW
    end
    if sensorState.defined_in_rf == false or sensorState.exist_in_etx == false then
        return RED
    end
    if sensorState.defined_in_rf == nil or sensorState.exist_in_etx == nil or sensorState.unique == nil then
        return LIGHTGREY
    end
    if sensorState.defined_in_rf and sensorState.exist_in_etx and sensorState.unique then
        return GREEN
    end
    return RED
end

local function showStatusPopup(sensorState)
    local sensorName = sensorState.name

    local statusText = ""
    if sensorState.defined_in_rf == false then
        statusText = statusText .. "\n" .. " sensor []"..sensorName.."] need to be defined in rotorflight"
    end

    if sensorState.exist_in_etx == false then
        statusText = statusText .. "\n" .. " sensor [" ..sensorName.."] need to be discovered in TX telemetry sensors"
    end

    if sensorState.unique == false then
        statusText = statusText .. "\n" .. " sensor [" ..sensorName.."] is duplicated, need to delete one of the instances in telemetry sensors page"
    end

    log("show_status_popup: sensor=%s status=%s", sensorName, statusText)
    lvgl.message({
        title="Issues with sensor [" .. sensorName .. "]",
        message=statusText,
        -- close=(function() end),
    })
end

M.build_ui = function(wgt)
    buildSensorList(wgt)

    lvgl.clear()

    local pg = lvgl.page({
        title="Sensor Diagnostics",
        subtitle=app_name,
        icon="/SCRIPTS/RF2-dashboards/img/rf2_logo.png",
    })

    local bList = pg:rectangle({x=0, y=0, w=LCD_W, color=BLACK, filled=true})

    pg:build({
        -- run tests button (native press handler ? no touch detection needed)
        { type="button", x=LCD_W-110*lvSCALE, y=10, text="Run Tests",
            press=function() runTests() end
        },

        -- overall result
        {type="label", x=10*lvSCALE, y=4*lvSCALE,
            font=FS.FONT_12,
            color=function()
                if testState.ran == false then return LIGHTGREY end
                if testState.final_result == "FAIL" then return RED end
                return GREEN
            end,
            text=function() return string.format("Sensors status: %s", testState.final_result) end,
        },

    })

    local HEADER_Y    = 50 * lvSCALE
    local HEADER_BG_Y = HEADER_Y - 2 * lvSCALE
    local HEADER_BG_H = 20 * lvSCALE
    local ROW_START_Y = 76 * lvSCALE
    local ROW_H       = 24 * lvSCALE
    local STATUS_DY   = 10 * lvSCALE
    local NAME_X      = 10 * lvSCALE
    local RF_X        = 105 * lvSCALE
    local ETX_X       = 195 * lvSCALE
    local UNIQUE_X    = 285 * lvSCALE
    local CELL_W      = 80 * lvSCALE
    local CELL_H      = 20 * lvSCALE
    local CELL_PAD_X  = 3 * lvSCALE
    local INFO_W      = 56 * lvSCALE
    local INFO_X      = math.min(UNIQUE_X + CELL_W + 4 * lvSCALE, LCD_W - INFO_W - 4 * lvSCALE)

    bList:build({
        {type="rectangle", x=0, y=HEADER_BG_Y, w=LCD_W, h=HEADER_BG_H, color=DARKGREY, filled=true},

        { type="label", x=NAME_X, y=HEADER_Y, text="Name", color=WHITE, font=FS.FONT_6 },
        { type="label", x=RF_X, y=HEADER_Y, text="Defined in RF", color=WHITE, font=FS.FONT_6 },
        { type="label", x=ETX_X, y=HEADER_Y, text="Exist in TX", color=WHITE, font=FS.FONT_6 },
        { type="label", x=UNIQUE_X, y=HEADER_Y, text="Unique in TX", color=WHITE, font=FS.FONT_6 },
        { type="label", x=INFO_X, y=HEADER_Y, text="Info", color=WHITE, font=FS.FONT_6 },
    })

    local last_y = 0
    for i = 1, #sensorIds do
        local idx   = i
        local row_y = ROW_START_Y + (i - 1) * ROW_H
        last_y = row_y

        bList:label({
            x=NAME_X, y=row_y,
            text=function() return testState.sensors[idx].name or "---" end,
            color=LIGHTGREY, font=FS.FONT_8,
        })

        bList:rectangle({
            x=RF_X - CELL_PAD_X,
            y=row_y - 1 * lvSCALE,
            w=CELL_W,
            h=CELL_H,
            filled=true,
            rounded=2,
            color=function() return getBoolColor(testState.sensors[idx].defined_in_rf) end,
        })

        bList:label({
            x=RF_X, y=row_y,
            w=CELL_W - CELL_PAD_X,
            align=CENTER,
            font=FS.FONT_6,
            color=function() return getBoolTextColor(testState.sensors[idx].defined_in_rf) end,
            text=function()  return getBoolText(testState.sensors[idx].defined_in_rf) end,
        })

        bList:rectangle({
            x=ETX_X - CELL_PAD_X,
            y=row_y - 1 * lvSCALE,
            w=CELL_W,
            h=CELL_H,
            filled=true,
            rounded=2,
            color=function() return getBoolColor(testState.sensors[idx].exist_in_etx) end,
        })

        bList:label({
            x=ETX_X, y=row_y,
            w=CELL_W - CELL_PAD_X,
            align=CENTER,
            font=FS.FONT_6,
            color=function() return getBoolTextColor(testState.sensors[idx].exist_in_etx) end,
            text=function()  return getBoolText(testState.sensors[idx].exist_in_etx) end,
        })

        bList:rectangle({
            x=UNIQUE_X - CELL_PAD_X,
            y=row_y - 1 * lvSCALE,
            w=CELL_W,
            h=CELL_H,
            filled=true,
            rounded=2,
            color=function() return getBoolColor(testState.sensors[idx].unique) end,
        })

        bList:label({
            x=UNIQUE_X, y=row_y,
            w=CELL_W - CELL_PAD_X,
            align=CENTER,
            font=FS.FONT_6,
            color=function() return getBoolTextColor(testState.sensors[idx].unique) end,
            text=function()  return getBoolText(testState.sensors[idx].unique) end,
        })

        bList:button({
            x=INFO_X, y=row_y,
            w=INFO_W,
            h=ROW_H,
            text="Info",
            press=function() showStatusPopup(testState.sensors[idx]) end,
            visible=function()
                return testState.sensors[idx].is_ok == false
            end,
        })
    end

    bList:build({
        {type="label", x=10*lvSCALE, y=last_y + 40*lvSCALE, font=FS.FONT_6, color=LIGHTGREY,
            text=function()
                local cfg = rf2fc.msp.cache.mspTelemetryConfig
                if cfg == nil or cfg.crsf_telemetry_mode == nil or cfg.crsf_telemetry_rate == nil or cfg.crsf_telemetry_ratio == nil then
                    return "Telemetry config: N/A"
                end
                return string.format("Telemetry config: crsf_mode=%s rate=%s ratio=%s",
                    cfg.crsf_telemetry_mode.value, cfg.crsf_telemetry_rate.value, cfg.crsf_telemetry_ratio.value)
                    -- return "Telemetry config: N/A"
            end,
        }
    })
end


M.refresh = function(wgt, event, touchState)
    -- button press is handled natively by the lvgl.page button widget
end

return M

