local arg = {...}
local is_sim = arg[1]

local telemetry = {}
local sensors = {}
local protocol, crsfSOURCE
local telemetryState = false
local log = rf2.log

local sensorTable = {

    -- link_qly = {
    --     name = "link_qly",
    --     mandatory = true,
    --     sourceId = nil,
    --     sensors = {
    --         sim = { min=0, max = 100 },
    --         sport = {{key="0xF010/26", sourceId=nil}},
    --         crsf = {{ crsfId = 0x0014, key="0x0014/2", sourceId=nil }},
    --     },
    -- },

    -- rssi = {
    --     name = "rssi",
    --     mandatory = true,
    --     maxmin_trigger = nil,
    --     sourceId = nil,
    --     sensors = {
    --         sim = {appId = 0xF101 },
    --         sport = {{ appId = 0xF101, key="0xF101/24", sourceId=nil }},
    --         crsf = {{ crsfId = 0x14, key="0x0014/0", sourceId=nil }},
    --     },
    -- },

    -- Arm Flags
    armflags = {
        name = "arming_flags",
        mandatory = true,
        stats = false,
        set_telemetry_sensors = 90,
        sourceId = nil,
        sensors = {
            sim = {
                { uid = 0x5001, unit = nil, dec = nil,
                  value = function() return rfsuite.utils.simSensors('armflags') end,
                  min = 0, max = 2 },
            },
            sport = {
                { appId = 0x5122 },
                { appId = 0x5462 },
            },
            crsf = {
                { appId = 0x1202 },
            },
        },
        onchange = function(value)
                if value == 1 or value == 3 then
                    rfsuite.session.isArmed = true
                else
                    rfsuite.session.isArmed = false
                end
        end,
    },

    -- Voltage Sensors
    batt_voltage = {
        name = "bat-voltage",
        stats = true,
        sourceId = "Vbat",
        sensors = {
            sim = {
                getValue = function() return 23.0 end,
                getValueMax = function() return 25.6 end,
            },
            sport = {
                { appId = 0x0210 },
                { appId = 0x0211 },
                { appId = 0x0218 },
                { appId = 0x021A },
            },
            crsf = {
                { appId = 0x1011 },
                { appId = 0x1041 },
                { appId = 0x1051 },
                { appId = 0x1080 },
            },
        },
    },

    -- RPM Sensors
    rpm = {
        name = "headspeed",
        stats = true,
        sourceId = "Hspd", -- Hspd / RPM
        sensors = {
            sim = {
                getValue = function() return 1500 end,
                getValueMax = function() return 1800 end,
            },
            sport = {
                { key="0x0500/27", sourceId=nil },
            },
            crsf = {
                { key = "0x10C0/0", sourceId = nil },
            },
        },
    },

    current = {
        name = "current",
        sourceId = "Curr", --???
        -- getValue = function() return getValue("Curr") end,
        -- getMaxValue = function() return getValue("Curr+") end,

        sensors = {
            sim = {
                -- getValue = function() return math.random(0, 150) end,
                -- getValueMax = function() return math.random(60, 150) end,
                getValue = function() return 40 end,
                getValueMax = function() return 120 end,

            },
            sport = {
                { key="0x0028/0", sourceId=nil },
                { key="0x0208/0", sourceId=nil },
                { key="0x0201/0", sourceId=nil },
                { key="0x0200/27", sourceId=nil},
            },
            crsf = {
                { key="0x1012/0", sourceId=nil },
                { key="0x1042/0", sourceId=nil },
                { key="0x104A/0", sourceId=nil },
            },
        },
    },

    -- ESC Temperature Sensors
    temp_esc = {
        name = "esc_temp",
        sourceId = "Tesc", -- Tesc
        sensors = {
            sim = {
                -- getValue = function() return math.random(0, 80) end,
                -- getValueMax = function() return math.random(60, 130) end,
                getValue = function() return 40 end,
                getValueMax = function() return 120 end,
            }, -- Tmp1, Tmp2, EscT
            sport = {
                { key="0x0401/27", sourceId=nil, mspgt = 12.08},
                { key="0x0418", sourceId=nil },
            },
            crsf = {
                { appId = 0x10A0, key="0x10A0", sourceId=nil },
                { appId = 0x1047, key="0x1047", sourceId=nil },
            },
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
        sensors = {
            sim = {
                getValue = function() return 1000 end,
                getValueMax = function() return 1000 end,
            },
            sport = {{ appId = 0x5250 }},
            crsf = {{ appId = 0x1013 }},
        },
    },

    -- governor = {
    --     name = "governor",
    --     sourceId = nil,
    --     sensors = {
    --         sim = { min = 0, max = 200 },
    --         sport = {
    --             { appId = 0x5125 },
    --             { appId = 0x5450 },
    --         },
    --         crsf = {{ appId = 0x1205 }},
    --     },
    -- },

    -- -- Adjustment Sensors
    -- adj_f = {
    --     name = "adj_func",
    --     mandatory = true,
    --     stats = false,
    --     sourceId = nil,
    --     sensors = {
    --         sim = { min = 0, max = 10 },
    --         sport = {{ appId = 0x5110 }},
    --         crsf = {{ appId = 0x1221 }},
    --     },
    -- },

    -- adj_v = {
    --     name = "adj_val",
    --     mandatory = true,
    --     stats = false,
    --     sourceId = nil,
    --     sensors = {
    --         sim = { min = 0, max = 2000 },
    --         sport = {{ appId = 0x5111 }},
    --         crsf = {{ appId = 0x1222 }},
    --     },
    -- },

    -- PID and Rate Profiles
    pid_profile = {
        name = "pid_profile",
        sourceId = "PID#",
        sensors = {
            sim = {
                getValue = function() return 2 end,
                -- getValueMax = function() return 1800 end,
            },
            sport = {
                { appId = 0x5130 },
                { appId = 0x5471 },
            },
            crsf = {{ appId = 0x1211 }},
        },
    },

    rate_profile = {
        name = "rate_profile",
        sourceId = "RTE#",
        sensors = {
            sim = {
                getValue = function() return 3 end,
            },
            sport = {
                { appId = 0x5131 },
                { appId = 0x5472 },
            },
            crsf = {
                { appId = 0x1212 },
            },
        },
    },

    -- Throttle Sensors
    throttle_percent = {
        name = "throttle_pct",
        sourceId = "Thr",
        sensors = {
            sim = {
                getValue = function() return 40 end,
                getValueMax = function() return 77 end,
            },
            sport = {
                { appId = 0x5440 },
                { appId = 0x51A4 },
                { appId = 0x5269 },
            },
            crsf = {
                { appId = 0x1035 },
            },
        },
    },

    -- -- Arm Disable Flags
    -- armdisableflags = {
    --     name = "armdisableflags",
    --     sourceId = nil,
    --     sensors = {
    --         sim = {
    --             { uid = 0x5015, unit = nil, dec = nil,
    --               value = function() return rfsuite.utils.simSensors('armdisableflags') end,
    --               min = 0, max = 65536 },
    --         },
    --         sport = {
    --             { appId = 0x5123 },
    --         },
    --         crsf = {
    --             { appId = 0x1203 },
    --         },
    --     },
    -- },

    -- -- Bec Voltage
    -- bec_voltage = {
    --     name = "bec_voltage",
    --     sourceId = nil,
    --     sensors = {
    --         sim = {
    --             { uid = 0x5017, unit = UNIT_VOLT, dec = 2,
    --               value = function() return rfsuite.utils.simSensors('bec_voltage') end,
    --               min = 0, max = 3000 },
    --         },
    --         sport = {
    --             { appId = 0x0901 },
    --             { appId = 0x0219 },
    --         },
    --         crsf = {
    --             { appId = 0x1081 },
    --             { appId = 0x1049 },
    --         },
    --     },
    -- },

    -- -- Cell Count
    -- cell_count = {
    --     name = "cell_count",
    --     mandatory = false,
    --     stats = false,
    --     set_telemetry_sensors = nil,
    --     sourceId = nil,
    --     sensors = {
    --         sim = {
    --             { uid = 0x5018, unit = nil, dec = 0,
    --               value = function() return rfsuite.utils.simSensors('cell_count') end,
    --               min = 0, max = 50 },
    --         },
    --         sport = {
    --             { appId = 0x5260 },
    --         },
    --         crsf = {
    --             { appId = 0x1020 },
    --         },
    --     },
    -- },

}


local function match_existing_sensor(name, key, sourceId)
    log("x-telemetery discoverAllSensors: match_existing_sensor(name: %s, key: %s, sourceId:%s)", name, key, sourceId)
    -- local tableExplorer = assert(loadScript("/WIDGETS/_libs/table_explorer.lua", "btd"))()
    -- if (name ~= "rssi") then
    --     return nil
    -- end

    -- log("x-telemetery discoverAllSensors: matching for: %s", name)
    for _, sensorInfo in pairs(sensorTable) do
        -- log("x-telemetery discoverAllSensors: match? : %s", sensorInfo.name)

        local sensOptions = sensorInfo.sensors[protocol]
        for _, sensor in ipairs(sensOptions) do
            -- log("x-telemetery getFieldInfo -- " .. tableExplorer.toString(sensor))
            -- log("x-telemetery discoverAllSensors: key: %s (? %s)", sensor.key, key)
            if (sensor.key and sensor.key == key) then
                log("x-telemetery discoverAllSensors: found match for: %s", sensorInfo.name)
                sensor.sourceId = sourceId
                return
            end
        end
    end
    return
end

local function discoverAllSensors()
    if is_sim then
        log("x-telemetery discoverAllSensors: discoverAllSensors() --> SIM (simulation mode)")
        protocol = "sim"
        return
    end
    local info = getFieldInfo("telem1")
    if info == nil then
        log("error: getFieldInfo(telem1) --> nil")
        return {}
    end
    local firstId = info.id

    --
    for n = 0, 59, 1 do
        local sensor = model.getSensor(n)
        if sensor ~= nil and sensor.name ~= '' then
            --type (number) 0 = custom, 1 = calculated
            --name (string) Name
            --unit (number) See list of units in the appendix of the OpenTX Lua Reference Guide
            --prec (number) Number of decimals
            --id (number) Only custom sensors
            --instance (number) Only custom sensors
            --formula (number) Only calculated sensors. 0 = Add etc. see list of formula choices in Companion popup

            local sourceId = firstId + (n * 3)
            local key = string.format("0x%04X/%d", sensor.id, sensor.instance)
            -- log("x-telemetery5  %s, %s, prec:%s, units:%s, type:%s, sourceId: %s",sensor.name, key, sensor.prec, sensor.unit , sensor.type, sourceId)

            match_existing_sensor(sensor.name, key, sourceId)
        end
    end
end

function telemetry.choose_best_sensors()
    -- local tableExplorer = assert(loadScript("/WIDGETS/_libs/table_explorer.lua", "btd"))()

    -- ??? better to do with live data?
    log("x-telemetery discoverAllSensors: choose best sensor")
    for _, sensorInfo in pairs(sensorTable) do
        local sensOptions = sensorInfo.sensors[protocol]
        for _, sensor in ipairs(sensOptions) do
            if sensorInfo.sourceId == nil then
                if sensor.sourceId ~= nil then
                    sensorInfo.sourceId = sensor.sourceId
                    log("x-telemetery discoverAllSensors: found match for: %s", sensorInfo.name)
                end
            end
        end
        log("x-telemetery discoverAllSensors: choose best for: %s --> %s", sensorInfo.name, sensorInfo.sourceId)
        -- log("x-telemetery15 best match \n%s", tableExplorer.toString(sensorInfo))
    end

    log("x-telemetery7 temp: %s-%s", getValue("EstT"), telemetry.getValue(sensorTable.temp_esc))
    log("x-telemetery7 temp: %s-%s", getValue("EstT"), telemetry.getValue(sensorTable.temp_esc))

    log("x-telemetery7 rssi: %s-%s", getValue("RSSI"), telemetry.getValue(sensorTable.rssi))
    log("x-telemetery7 rssi: %s-%s", getValue("1RSS"), telemetry.getValue(sensorTable.rssi))
    log("x-telemetery7 rssi: %s-%s", getValue("2RSS"), telemetry.getValue(sensorTable.rssi))
    log("x-telemetery7 link_qly: %s-%s",  getValue("RQly"), telemetry.getValue(sensorTable.link_qly))
    log("x-telemetery7 vfr: %s-%s",  getValue("VFR"), telemetry.getValue(sensorTable.link_qly))
    log("x-telemetery7 curr: %s-%s", getValue("Curr"), telemetry.getValue(sensorTable.current))
    log("x-telemetery7 pid_profile: %s-%s", getValue("pid_profile"), telemetry.getValue(sensorTable.pid_profile))

    return
end


local function searchForProtocol()
    if is_sim then
        log("x-telemetery7  searchForProtocol() --> SIM (simulation mode)")
        return "sim"
    end
    for n = 0, 59, 1 do
        local sensor = model.getSensor(n)
        if sensor ~= nil and sensor.name ~= '' then
            if sensor.name == "RSSI" or sensor.name == "VFR" then
                log("x-telemetery7  searchForProtocol() --> SPOPRT (by %s)", sensor.name)
                return "sport"
            end
            if sensor.name == "1RSS" or sensor.name == "2RSS" or sensor.name == "RQly" then
                log("x-telemetery7  searchForProtocol() --> CRSF (by %s)", sensor.name)
                return "crsf"
            end
        end
    end
    log("x-telemetery7  searchForProtocol() --> SIM (sensor not found)")
    return "sim"
end


function telemetry.getSensorProtocol()
    return protocol
end

function telemetry.getValue(sensorObj)
    if sensorObj == nil then
        -- log("x-telemetery7  getValue() --> sensorObj is nil")
        return -1
    end

    if is_sim then
        -- log("x-telemetery7  gerValue(%s:%s) --> SIM (simulation mode)", sensorObj.name, sensorObj.sourceId)
        local sm = sensorObj.sensors.sim
        if not sm then
            return -2
        end

        if sm.getValue then
            local v = sm.getValue()
            -- log("x-telemetery7  gerValue(%s:%s) --> SIM (simulation mode) = %s", sensorObj.name, sensorObj.sourceId, v)
            return v
        end
        return -3
    end

    local value = getValue(sensorObj.sourceId)
    return value
end

function telemetry.getValueMax(objSensor)
    if objSensor == nil then
        -- log("x-telemetery7  getValueMax() --> sensorObj is nil")
        return -1
    end

    if is_sim then
        -- log("x-telemetery7  getValueMax(%s:%s) --> SIM (simulation mode)", objSensor.name, objSensor.sourceId)
        local sm = objSensor.sensors.sim
        if not sm then
            return -2
        end
        if sm.getValueMax then
            local v = sm.getValueMax()
            -- log("x-telemetery7  gerValue(%s:%s) --> SIM (simulation mode) = %s", sensorObj.name, sensorObj.sourceId, v)
            return v
        end
        return -3
    end

    -- local value_max = getValue(objSensor.sourceId+2)
    local value_max = getValue(objSensor.sourceId .. "+")
    return value_max
end


function telemetry.getSensorSource(name)
    if not sensorTable[name] then return nil end

    if sensors[name] then
        return sensors[name]
    end

    local function checkCondition(sensorEntry)
        if not (rfsuite.session and rfsuite.session.apiVersion) then
            return true
        end
        local roundedApiVersion = rfsuite.utils.round(rfsuite.session.apiVersion, 2)
        if sensorEntry.mspgt then
            return roundedApiVersion >= rfsuite.utils.round(sensorEntry.mspgt, 2)
        elseif sensorEntry.msplt then
            return roundedApiVersion <= rfsuite.utils.round(sensorEntry.msplt, 2)
        end
        return true
    end

    if system.getVersion().simulation == true then
        protocol = "sport"
        for _, sensor in ipairs(sensorTable[name].sensors.sim or {}) do
            -- handle sensors in regular formt
            if sensor.uid then
                if sensor and type(sensor) == "table" then
                    local sensorQ = { appId = sensor.uid, category = CATEGORY_TELEMETRY_SENSOR }
                    local source = system.getSource(sensorQ)
                    if source then
                        sensors[name] = source
                        return source
                    end
                end
            else
                -- handle smart sensors / regular lookups
                if checkCondition(sensor) and type(sensor) == "table" then
                    sensor.mspgt = nil
                    sensor.msplt = nil
                    local source = system.getSource(sensor)
                    if source then
                        sensors[name] = source
                        return source
                    end
                end
            end
        end

    elseif rfsuite.session.telemetryType == "crsf" then
        if not crsfSOURCE then
            crsfSOURCE = system.getSource({ appId = 0xEE01 })
        end
        if crsfSOURCE then
            protocol = "crsf"
            for _, sensor in ipairs(sensorTable[name].sensors.crsf or {}) do
                if checkCondition(sensor) and type(sensor) == "table" then
                    sensor.mspgt = nil
                    sensor.msplt = nil
                    local source = system.getSource(sensor)
                    if source then
                        sensors[name] = source
                        return source
                    end
                end
            end
        else
            protocol = "crsfLegacy"
            for _, sensor in ipairs(sensorTable[name].sensors.crsfLegacy or {}) do
                local source = system.getSource(sensor)
                if source then
                    sensors[name] = source
                    return source
                end
            end
        end

    elseif rfsuite.session.telemetryType == "sport" then
        protocol = "sport"
        for _, sensor in ipairs(sensorTable[name].sensors.sport or {}) do
            if checkCondition(sensor) and type(sensor) == "table" then
                sensor.mspgt = nil
                sensor.msplt = nil
                local source = system.getSource(sensor)
                if source then
                    sensors[name] = source
                    return source
                end
            end
        end
    else
        protocol = "unknown"
    end

    return nil
end

--- Retrieves the value of a telemetry sensor by its key.
-- This function now supports both physical sensors (linked to telemetry sources)
-- and virtual/computed sensors (which define a `.source` function in sensorTable).
--
-- 1. If the sensorTable entry includes a `source` function (virtual/computed sensor),
--    this function is called and its `.value()` result is returned.
-- 2. Otherwise, attempts to resolve the sensor as a physical/real telemetry source.
--    If found, returns its value; otherwise, returns nil.
-- 3. If a `localizations` function is defined for the sensor, it is applied to
--    transform the raw value and resolve units as needed.
--
-- @param sensorKey The key identifying the telemetry sensor.
-- @return The sensor value (possibly transformed), primary unit (major), and secondary unit (minor) if available.
function telemetry.getSensor(sensorKey)
    local entry = sensorTable[sensorKey]

    if entry and type(entry.source) == "function" then
        local src = entry.source()
        if src and type(src.value) == "function" then
            local value, major, minor = src.value()
            major = major or entry.unit
            return value, major, minor
        end
    end

    -- Physical/real telemetry source
    local source = telemetry.getSensorSource(sensorKey)
    if not source then
        return nil
    end

    -- get initial defaults
    local value = source:value()
    local major = entry and entry.unit or nil
    local minor = nil

    return value, major, minor
end

--[[
    Function: telemetry.validateSensors
    Purpose: Validates the sensors and returns a list of either valid or invalid sensors based on the input parameter.
    Parameters:
        returnValid (boolean) - If true, the function returns only valid sensors. If false, it returns only invalid sensors.
    Returns:
        table - A list of sensors with their keys and names. The list contains either valid or invalid sensors based on the returnValid parameter.
    Notes:
        - The function uses a rate limit to avoid frequent validations.
        - If telemetry is not active, it returns all sensors.
        - The function considers the mandatory flag for invalid sensors.
]]
function telemetry.validateSensors(returnValid)
    local now = rfsuite.clock
    if (now - lastValidationTime) < VALIDATION_RATE_LIMIT then
        return lastValidationResult
    end
    lastValidationTime = now

    if not rfsuite.session.telemetryState then
        local allSensors = {}
        for key, sensor in pairs(sensorTable) do
            table.insert(allSensors, { key = key, name = sensor.name })
        end
        lastValidationResult = allSensors
        return allSensors
    end

    local resultSensors = {}
    for key, sensor in pairs(sensorTable) do
        local sensorSource = telemetry.getSensorSource(key)
        local isValid = (sensorSource ~= nil and sensorSource:state() ~= false)
        if returnValid then
            if isValid then
                table.insert(resultSensors, { key = key, name = sensor.name })
            end
        else
            if not isValid and sensor.mandatory ~= false then
                table.insert(resultSensors, { key = key, name = sensor.name })
            end
        end
    end

    lastValidationResult = resultSensors
    return resultSensors
end

--[[
    Function: telemetry.simSensors
    Description: Simulates sensors by iterating over a sensor table and returning a list of valid sensors.
    Parameters:
        returnValid (boolean) - A flag indicating whether to return valid sensors.
    Returns:
        result (table) - A table containing the names and first sport sensors of valid sensors.

    This function is used to build a list of sensors that are available in 'simulation mode'
]]
function telemetry.simSensors(returnValid)
    local result = {}
    for key, sensor in pairs(sensorTable) do
        local name = sensor.name
        local firstSportSensor = sensor.sensors.sim and sensor.sensors.sim[1]
        if firstSportSensor then
            table.insert(result, { name = name, sensor = firstSportSensor })
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
function telemetry.active()
    return rfsuite.session.telemetryState or false
end

function telemetry.init()
    protocol = searchForProtocol()

    -- discoverAllSensors()

    -- telemetry.choose_best_sensors()
end

-- allow sensor table to be accessed externally
telemetry.sensorTable = sensorTable


return telemetry
