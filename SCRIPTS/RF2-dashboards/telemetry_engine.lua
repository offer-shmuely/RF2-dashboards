local arg = {...}
local log = arg[1]
local app_name = arg[2]
local is_sim = arg[3]

local M = {}
local protocol
local telemetryState = false
local rob_sim = true
local NAN_VAL = 111
M.is_post_flight = false

local sensorTable
sensorTable = {
    -- VFR / RQly
    link_rqly = {
        name = "link_rqly",
        sourceId = (protocol=="sport") and "VFR" or "RQly",
        lastValueMin = NAN_VAL,
        update_sim = function(sensor)
            if sensor.lastValueMin == NAN_VAL then
                sensor.lastValueMin = 42
            end
        end,
        low_warning=90,
        low_alert=80,
        sim = {
            getValue = function() return 92 end,
        },
    },

    -- link power
    link_tx_power = {
        name = "link_tx_power",
        sourceId = "TPWR",
        lastValueMax = NAN_VAL,
        update_sim = function(sensor)
            if sensor.lastValueMax == NAN_VAL then
                sensor.lastValueMax = 100
            end
        end,
        sim = {
            getValue = function() return 25 end,
        },
    },

    -- isArmed
    isArmed = {
        name = "is_armed",
        sourceId = "ARM",
        -- getVal = function() return getValue("ARM") end,
        sim = {
            getValue = function() return 0 end,
        },
    },

    -- Arm disable flags
    armdisableflags = {
        name = "armdisableflags",
        sourceId = "ARMD",
        sim = {
            getValue = function() return 0 end,
        },
    },

    -- Voltage
    batt_voltage = {
        name = "bat-voltage",
        sourceId = "Vbat",
        lastValue = NAN_VAL,
        lastValueMin = NAN_VAL,
        update_sim = function(sensor)
            if sensor.lastValueMin == NAN_VAL then
                sensor.lastValueMin = 23.0
            end
        end,
        low_warning=15, -- 15%=3.710v
        low_alert=7,    --  7%=3.601v
        sim = {
            getValue = function() return 23.0 end,
        },
    },

    -- RxVoltage
    rx_voltage = {
        name = "rx_voltage",
        sourceId = "Vbec",
        lastValueMin = NAN_VAL,
        lastValueMax = NAN_VAL,
        isWarn = function()
            local dv = sensorTable.rx_voltage.lastValueMax - sensorTable.rx_voltage.lastValueMin
            if dv > 0.5 then
                log("rx_voltage.isWarn() called, dv=%s (min: %s, max: %s)", dv, sensorTable.rx_voltage.lastValueMin, sensorTable.rx_voltage.lastValueMax)
                return true
            end
            -- log("rx_voltage.isWarn() called, v=%s", v)
            return false
        end,
        isAlert = function()
            local dv = sensorTable.rx_voltage.lastValueMax - sensorTable.rx_voltage.lastValueMin
            if dv > 0.9 then
                log("rx_voltage.isAlert() called, dv=%s (min: %s, max: %s)", dv, sensorTable.rx_voltage.lastValueMin, sensorTable.rx_voltage.lastValueMax)
                return true
            end
            -- log("rx_voltage.isAlert() called, v=%s", v)
            return false
        end,
        -- low_warning=95,
        -- low_alert=90,
        fPercent = function(v)
            if v == NAN_VAL then
                return 0
            end
            if sensorTable.rx_voltage.lastValueMax <= 4.9 then
                return 0
            end
            return math.min(100, math.max(0, ((v - 4.9) / (sensorTable.rx_voltage.lastValueMax - 4.9)) * 100))
        end,
        update_sim = function(sensor)
            if sensor.lastValueMin == NAN_VAL then
                sensor.lastValueMin = 7.2
                sensor.lastValueMax = 7.2
            end
        end,
    },

    -- -- Cell Count
    -- cell_count = {
    --     name = "cell-count",
    --     sourceId = "Cel#",
    --     lastValue = NAN_VAL,
    -- },

    -- headspeed
    rpm = {
        name = "headspeed",
        sourceId = "Hspd", -- Hspd / RPM
        lastValueMax = NAN_VAL,
        update_sim = function(sensor)
            if sensor.lastValueMax == NAN_VAL then
                sensor.lastValueMax = 1800
            end
        end,
        high_warning = 100,
        high_alert = 100,
        sim = {
            getValue = function() return 1500 end,
        },
    },

    current = {
        name = "current",
        sourceId = "Curr",
        lastValueMax = NAN_VAL,
        update_sim = function(sensor)
            if sensor.lastValueMax == NAN_VAL then
                sensor.lastValueMax = 115
            end
        end,
        high_warning = 80,
        high_alert = 90,
        sim = {
            getValue = function() return 40 end,
        },
    },

    -- ESC Temperature
    temp_esc = {
        name = "esc_temp",
        sourceId = "Tesc", -- Tesc
        lastValue = NAN_VAL,
        lastValueMax = NAN_VAL,
        update_sim = function(sensor)
            if sensor.lastValueMax == NAN_VAL then
                sensor.lastValueMax = 120
            end
        end,
        high_warning = 80,
        high_alert = 90,
        sim = {
            getValue = function() return 40 end,
        },
        --     if isFahrenheit then
        --         -- Convert from Celsius to Fahrenheit
        --         return value * 1.8 + 32, major, "°F"
        --     end
        --     -- Default: return Celsius
        --     return value, major, "°C"
    },

    capa = {
        name = "capacity",
        sourceId = "Capa", -- Capa
        lastValue = NAN_VAL,
        low_warning = 20,
        low_alert = 10,
        sim = {
            getValue = function() return 1000 end,
        },
    },

    -- governor = {
    --     name = "governor",
    --     sourceId = nil,
    --         sim = { min = 0, max = 200 },
    -- },

    -- -- Adjustment
    -- adj_f = {
    --     name = "adj_func",
    --     sourceId = nil,
    --         sim = { min = 0, max = 10 },
    -- },

    -- adj_v = {
    --     name = "adj_val",
    --     sourceId = nil,
    --         sim = { min = 0, max = 2000 },
    -- },

    -- PID and Rate Profiles
    pid_profile = {
        name = "pid_profile",
        sourceId = "PID#",
        sim = {
            getValue = function() return 2 end,
        },
    },

    rate_profile = {
        name = "rate_profile",
        sourceId = "RTE#",
        sim = {
            getValue = function() return 3 end,
        },
    },

    -- Throttle
    throttle_percent = {
        name = "throttle_pct",
        sourceId = "Thr",
        lastValueMax = NAN_VAL,
        high_warning = 90,
        high_alert = 95,
        update_sim = function(sensor)
            if sensor.lastValueMax == NAN_VAL then
                sensor.lastValueMax = 76
            end
        end,
    },

    -- virtual is connected
    is_connected = {
        name = "is_connected",
        -- sourceId = "",
        getVal = function() return getRSSI() ~= 0 end,
        -- getValMin = function() return false end,
        -- getValMax = function() return true end,
        sim = {
            getValue = function() return true end,
        },
    },

}

local function searchForProtocol()
    if is_sim then
        -- log("x-telemetery7  searchForProtocol() --> SIM (simulation mode)")
        return "sim"
    end
    for n = 0, 59, 1 do
        local sensor = model.getSensor(n)
        if sensor ~= nil and sensor.name ~= '' then
            if sensor.name == "RSSI" or sensor.name == "VFR" then
                -- log("x-telemetery7  searchForProtocol() --> SPOPRT (by %s)", sensor.name)
                return "sport"
            end
            if sensor.name == "1RSS" or sensor.name == "2RSS" or sensor.name == "RQly" then
                -- log("x-telemetery7  searchForProtocol() --> CRSF (by %s)", sensor.name)
                return "crsf"
            end
        end
    end
    -- log("x-telemetery7  searchForProtocol() --> SIM (sensor not found)")
    return "sim"
end


function M.getSensorProtocol()
    return protocol
end

function M.value(objSensor)
    if objSensor == nil then
        log("x-telemetery7  value() --> objSensor is nil")
        return -1
    end

    -- in post-flight mode, return the stored value
    if M.is_post_flight then
        if objSensor.lastValue ~= nil then
            return objSensor.lastValue
        end
    end

    if is_sim and not rob_sim then
        -- log("x-telemetery7  value(%s:%s) --> SIM (simulation mode)", objSensor.name, objSensor.sourceId)
        if not objSensor.sim then
            return -2
        end
        if not objSensor.sim.getValue then
            return -3
        end

        local v = objSensor.sim.getValue()
        -- log("x-telemetery7  value(%s:%s) --> SIM (simulation mode) = %s", objSensor.name, objSensor.sourceId, v)
        return v
    end

    local sourceId = objSensor.sourceId
    if type(sourceId) == "function" then
        sourceId = sourceId()
    end

    local v
    if objSensor.getVal and type(objSensor.getVal) == "function" then
        v = objSensor.getVal()
    else
        v = getValue(sourceId)
    end
    -- objSensor.lastValue = v
    return v
end

function M.valueMin(objSensor)
    if objSensor == nil then
        log("x-telemetery  getValueMin() --> objSensor is nil")
        return -1
    end

    if objSensor.lastValueMin == nil then return -3 end

    return objSensor.lastValueMin
end

function M.valueMax(objSensor)
    if objSensor == nil then
        log("x-telemetery7  valueMax() --> objSensor is nil")
        return -1
    end

    if objSensor.lastValueMax == nil then return -3 end

    return objSensor.lastValueMax
end

function M.updatePostFlightValues()
    -- log("telemetry.updatePostFlightValues() called")
    for key, sensor in pairs(sensorTable) do
        -- log("updatePostFlightValues: key=%s, name=%s, sourceId=%s", key, sensor.name, sensor.sourceId)
        local v = M.value(sensor)

        if sensor.lastValue ~= nil then
            sensor.lastValue = v
        end

        if sensor.lastValueMin ~= nil then
            -- log("updateMin [%s] %s?=%s --> %s (v%s)", sensor.name, sensor.lastValueMin, NAN_VAL, (sensor.lastValueMin == NAN_VAL), v)
            if v ~= NAN_VAL then
                if sensor.lastValueMin == NAN_VAL then
                    sensor.lastValueMin = v
                else
                    sensor.lastValueMin = math.min(v, sensor.lastValueMin)
                end
            end
        end

        if sensor.lastValueMax ~= nil then
            if sensor.lastValueMax == NAN_VAL then
                sensor.lastValueMax = v
            else
                sensor.lastValueMax = math.max(v, sensor.lastValueMax)
            end
        end

        -- if sensor.update ~= nil then
        --     sensor.update(sensor)
        -- end
        if is_sim and sensor.update_sim ~= nil then
            sensor.update_sim(sensor)
        end

    end
end

function M.resetSensorsMinMax()
    -- log("telemetry.resetSensorsMinMax() called")
    -- for i = 0, 63 do
    --     model.resetSensor(i)
    -- end

    log("telemetry reset lastValue to NAN_VAL")
    for key, sensor in pairs(sensorTable) do
        -- log(" resetting sensor: %s", sensor.name)
        if sensor.lastValue ~= nil then
            sensor.lastValue = NAN_VAL
        end
        if sensor.lastValueMin ~= nil then
            sensor.lastValueMin = NAN_VAL
        end
        if sensor.lastValueMax ~= nil then
            sensor.lastValueMax = NAN_VAL
        end
    end

    -- log("telemetry.resetSensorsMinMax() completed")
end


function M.armingToolsIsArmed()
    local val  = M.value(sensorTable.isArmed)
    local is_arm = (val == 1 or val == 3)
    -- log("isArmed: %s  (raw val: %s)", is_arm, val)
    return is_arm
end

function M.armingToolsIsArmRequested()
    local flags  = M.value(sensorTable.armdisableflags)
    -- local is_arm_requested1 = bit32.band(flags, 0x2000000)
    -- log("is_arm_requested1: %s  (raw val: 0x%X)", is_arm_requested1, flags)
    local is_arm_requested2 = bit32.band(flags, bit32.lshift(1, 25)) ~= 0
    -- log("is_arm_requested2: %s  (raw val: 0x%X)", is_arm_requested2, flags)
    return is_arm_requested2
end

function M.armingToolsArmDisabledFlags()
    local flags  = M.value(sensorTable.armdisableflags)
    log("armdisableflags raw: 0x%X", flags)

    local result = {}

    local t = ""
    for i = 0, 25 do
        if bit32.band(flags, bit32.lshift(1, i)) ~= 0 then
            if i == 0 then table.insert(result, "No Gyro") end
            if i == 1 then table.insert(result, "Failsafe is active") end
            if i == 2 then table.insert(result, "No valid receiver signal is detected") end
            if i == 3 then table.insert(result, "The FAILSAFE switch was activated") end
            if i == 4 then table.insert(result, "Box Fail Safe") end
            if i == 5 then table.insert(result, "Governor") end
            --if i == 6 then table.insert(result, "Crash Detected") end
            if i == 7 then table.insert(result, "Throttle not idle") end

            if i == 8 then table.insert(result, "Craft is not level enough") end
            if i == 9 then table.insert(result, "Arming too soon after power on") end
            if i == 10 then table.insert(result, "No Pre Arm") end
            if i == 11 then table.insert(result, "System load is too high") end
            if i == 12 then table.insert(result, "Calibrating") end
            if i == 13 then table.insert(result, "CLI is active") end
            if i == 14 then table.insert(result, "CMS Menu") end
            if i == 15 then table.insert(result, "BST") end

            if i == 16 then table.insert(result, "MSP connection is active") end
            if i == 17 then table.insert(result, "Paralyze mode activate") end
            if i == 18 then table.insert(result, "GPS") end
            if i == 19 then table.insert(result, "Resc") end
            if i == 20 then table.insert(result, "RPM Filter") end
            if i == 21 then table.insert(result, "Reboot Required") end
            if i == 22 then table.insert(result, "DSHOT Bitbang") end
            if i == 23 then table.insert(result, "Accelerometer calibration required") end

            if i == 24 then table.insert(result, "ESC/Motor Protocol not configured") end
            -- if i == 25 then table.insert(result, "Arm Requested") end -- Arm Switch
        end
    end
    return result
end


--[[
    Function: telemetry.active
    Description: Checks if telemetry is active. Returns true if the system is in simulation mode, otherwise returns the state of telemetry.
    Returns:
        - boolean: true if in simulation mode or telemetry is active, false otherwise.
]]
function M.active()
    return rfsuite.session.telemetryState or false
end

function M.init()
    protocol = searchForProtocol()
end

-- allow sensor table to be accessed externally
M.sensorTable = sensorTable


return M
