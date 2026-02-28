local app_name = "RF2-dashboards"
local app_ver = "2.2.16"

local baseDir = "/SCRIPTS/RF2-dashboards"
local inSimu = string.sub(select(2,getVersion()), -4) == "simu"

local timerNumber = 1

-- constants
local VCEL_LOW_THRESHOLD = 3.7
local CAPA_LOW_PERCENT = 10
local CAPA_MEDIUM_PERCENT = 30


local err_img = bitmap.open(baseDir.."/img/no_connection_wr.png")

local m_log = loadScript(baseDir.."/lib_log.lua", "btd")(app_name, baseDir)

local dashboard_styles = {
    [1] = "dashboard_fancy.lua",
    [2] = "dashboard_modern.lua",
    [3] = "dashboard_nitro.lua",
}
local dashboard_post_styles = {
    [1] = "dashboard_debug.lua", -- placeholder, same as flight dashboard
    [2] = "dashboard_post_1.lua",
    [3] = "dashboard_post_2.lua",
}
local dashboard_file_name = "dashboard_none.lua"
local dashboard_post_file_name = "dashboard_post_1.lua"
local curr_dashboard = nil

local runningInSimulator = string.sub(select(2, getVersion()), -4) == "simu"
local function m_clock()
    return getTime() / 100
end

local wgt = {
    app_ver = app_ver,
    values = {
        craft_name = "-----",
        timer_str = "--:--",
        rpm = -1,
        rpm_max = -1,
        rpm_percent = -1,
        profile_id = -1,
        profile_id_str = "--",
        rate_id = -1,
        rate_id_str = "--",

        vbat = -1,
        vcel = -1,
        vcel_min = -1,
        cell_percent = -1,
        volt = -1,
        v_rx = -1,
        v_rx_min = -1,
        v_rx_percent = -1,
        -- v_rx_min_percent = -1,
        curr = 0,
        curr_max = 0,
        curr_percent = 0,
        curr_max_percent = 0,
        capaTotal = -1,
        capaUsed = -1,
        capaPercent = -1,
        capaPercent_txt = "---",

        EscT = 0,
        EscT_max = 0,
        EscT_percent = 0,
        EscT_max_percent = 0,

        link_rqly = 0,
        link_rqly_min = 0,

        -- governor_str = "-------",
        is_arm = false,
        arm_fail = false,
        arm_disable_flags_list = nil,
        arm_disable_flags_txt = "",
        flight_stage = -1,
        flight_stage_str = "---",

        img_last_key = "---",
        img_craft_image_name = "---",

        thr = 0,
        thr_max = 0,

        -- model stats
        model_total_flights = nil,
        model_total_time = nil,
        model_total_time_str = "---",
    },
}

local rf2_curr_model_static_data = {
    msp_api_version = nil,
    craft_id = nil,
    craft_name = nil,
    cell_count = 4,
    battery_capacity = nil,
    rescue_on = nil,
    total_flights = nil,
    stat_total_time = nil,

}

--------------------------------------------------------------
local function log(fmt, ...)
    m_log.info(fmt, ...)
    return
end
--------------------------------------------------------------

local function read_curr_model_static_data()
    -- update rf2_curr_model_static_data
    rf2_curr_model_static_data.msp_api_version = rf2fc.msp.cache.mspApiVersion or nil
    rf2_curr_model_static_data.craft_id         = nil -- mcu id, command=160, not implemented yet
    rf2_curr_model_static_data.craft_name       = rf2fc.msp.cache.mspName or "---"
    rf2_curr_model_static_data.cell_count       = rf2fc.msp.cache.mspBatteryConfig.batteryCellCount or -1
    rf2_curr_model_static_data.battery_capacity = rf2fc.msp.cache.mspBatteryConfig.batteryCapacity or -1
    rf2_curr_model_static_data.rescue_on        = rf2fc.msp.cache.mspRescueProfile.mode == 1
    rf2_curr_model_static_data.total_flights    = rf2fc.msp.cache.mspFlightStats.stats_total_flights.value
    rf2_curr_model_static_data.stats_total_time = rf2fc.msp.cache.mspFlightStats.stats_total_time_s.value
end


-- local function tableToString(tbl)
--     if (tbl == nil) then return "---" end
--     local result = {}
--     for key, value in pairs(tbl) do
--         table.insert(result, string.format("%s: %s", tostring(key), tostring(value)))
--     end
--     return table.concat(result, ", ")
-- end

-----------------------------------------------------------------------------------------------------------------

dbg_layout_enabled = false
dbgx, dbgy = 100, 100
local function getDxByStick(stk)
    local v = getValue(stk)
    if math.abs(v) < 15 then return 0 end
    local d = math.ceil(v / 400)
    return d
end
local function dbgLayout()
    dbg_layout_enabled = true
    local dw = getDxByStick("ail")
    dbgx = dbgx + dw
    dbgx = math.max(0, math.min(480, dbgx))

    local dh = getDxByStick("ele")
    dbgy = dbgy - dh
    dbgy = math.max(0, math.min(272, dbgy))
    -- log("%sx%s", dbgx, dbgy)
end
local function dbg_pos()
    log("dbg_pos: %sx%s", dbgx, dbgy)
    return dbgx, dbgy
end
local function dbg_x()
    log("dbg_pos: %sx%s", dbgx, dbgy)
    return dbgx
end

local function formatTime(wgt, t1)
    local dd_raw = t1.value
    local isNegative = false
    if dd_raw < 0 then
      isNegative = true
      dd_raw = math.abs(dd_raw)
    end

    local dd = math.floor(dd_raw / 86400)
    dd_raw = dd_raw - dd * 86400
    local hh = math.floor(dd_raw / 3600)
    dd_raw = dd_raw - hh * 3600
    local mm = math.floor(dd_raw / 60)
    dd_raw = dd_raw - mm * 60
    local ss = math.floor(dd_raw)

    local time_str
    if dd == 0 and hh == 0 then
      -- less than 1 hour, 59:59
      time_str = string.format("%02d:%02d", mm, ss)

    elseif dd == 0 then
      -- less than 24 hours, 23:59:59
      time_str = string.format("%02d:%02d:%02d", hh, mm, ss)
    else
      -- more than 24 hours
      if wgt.options.use_days == 0 then
        -- 25:59:59
        time_str = string.format("%02d:%02d:%02d", dd * 24 + hh, mm, ss)
      else
        -- 5d 23:59:59
        time_str = string.format("%dd %02d:%02d:%02d", dd, hh, mm, ss)
      end
    end
    if isNegative then
      time_str = '-' .. time_str
    end
    return time_str, isNegative
end

local function build_ui(wgt, file_name)
    curr_dashboard = assert(loadScript(baseDir .. "/dashboards/" ..file_name, "btd")(m_log.info, app_name, baseDir , wgt.tools, wgt.statusbar, inSimu))
    curr_dashboard.build_ui(wgt)
end

-------------------------------------------------------------------
local function close()
    lvgl.confirm({title="Exit", message="exit config?",
        confirm=(function() lvgl.exitFullScreen() end)
    })
end

-------------------------------------------------------------------

local dbgReplImg = 0
local dbgImgTp = 0
local function updateCraftName(wgt)
    local is_dbg_craft_change = false

    if is_dbg_craft_change == true then
        if (m_clock() - dbgReplImg > 5) then
            log("updateCraftName - interval")
            dbgImgTp = dbgImgTp + 1
            if dbgImgTp % 2 == 0 then
                wgt.values.craft_name = "sab601"
            else
                wgt.values.craft_name = "sab580"
            end
            log("updateCraftName - CraftName: %s", wgt.values.craft_name)
            dbgReplImg = m_clock()
        end
    else
        wgt.values.craft_name = rf2_curr_model_static_data.craft_name
    end
end

local function updateTimeCount(wgt)
    local t1 = model.getTimer(timerNumber - 1)
    local time_str, isNegative = formatTime(wgt, t1)
    wgt.values.timer_str = time_str
end

local function updateHeadspeed(wgt)
    wgt.values.rpm = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.rpm)
    wgt.values.rpm_max = wgt.tlmEngine.valueMax(wgt.tlmEngine.sensorTable.rpm)
    wgt.values.rpm_percent = (wgt.values.rpm_max > 0) and math.min(100, math.floor(100 * (wgt.values.rpm / wgt.values.rpm_max))) or 0
end

local function updateProfiles(wgt)
    -- current PID profile
    local val = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.pid_profile)
    wgt.values.profile_id = val
    wgt.values.profile_id_str = string.format("%s", wgt.values.profile_id)

    -- current rate profile
    local val = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.rate_profile)
    wgt.values.rate_id = val
    wgt.values.rate_id_str = string.format("%s", wgt.values.rate_id)
end

local function updateCell(wgt)
    local vbat     = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.batt_voltage)
    local vbat_min = wgt.tlmEngine.valueMin(wgt.tlmEngine.sensorTable.batt_voltage)

    local cell_count = rf2_curr_model_static_data.cell_count or 1

    local vcel = cell_count > 0 and (vbat / cell_count) or 0
    local vcel_min = cell_count > 0 and (vbat_min / cell_count) or 0

    local batPercent = wgt.tools.getCellPercent(vcel)
    -- log("vbat: %s, vcel: %s, BatPercent: %s", vbat, vcel, batPercent)

    wgt.values.vbat = vbat
    wgt.values.vcel = vcel
    wgt.values.vcel_min = vcel_min
    wgt.values.cell_percent = batPercent
    wgt.values.volt = (wgt.options.showTotalVoltage==1) and vbat or vcel
    wgt.values.cellColor = (vcel < VCEL_LOW_THRESHOLD) and RED or lcd.RGB(0x00963A) --GREEN
end

local function updateCurr(wgt)
    local curr_top = wgt.options.currTop
    local val     = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.current)
    local val_max = wgt.tlmEngine.valueMax(wgt.tlmEngine.sensorTable.current)
    -- log("telemetery8: updateCurr:  curr: %s, curr_max: %s", curr, curr_max)

    wgt.values.curr = val
    wgt.values.curr_max = val_max
    wgt.values.curr_percent = math.min(100, math.floor(100 * (val / curr_top)))
    wgt.values.curr_max_percent = math.min(100, math.floor(100 * (val_max / curr_top)))
end

local function updateCapa(wgt)
    -- capacity
    local val  = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.capa)

    wgt.values.capaTotal = (rf2_curr_model_static_data.battery_capacity or 0) * (100-wgt.options.reserve_capa) // 100
    wgt.values.capaUsed = val

    if wgt.values.capaTotal==nil or wgt.values.capaTotal==nan or wgt.values.capaTotal==0 then
        wgt.values.capaTotal = -1
        wgt.values.capaUsed = 0
    end

    wgt.values.capaRemain = wgt.values.capaTotal - wgt.values.capaUsed
    wgt.values.capaPercent = (wgt.values.capaTotal > 0) and math.floor(100 * wgt.values.capaRemain // wgt.values.capaTotal) or 0
    local p = wgt.values.capaPercent
    if (p < CAPA_LOW_PERCENT) then
        wgt.values.capaColor = RED
    elseif (p < CAPA_MEDIUM_PERCENT) then
        wgt.values.capaColor = ORANGE
    else
        wgt.values.capaColor = lcd.RGB(0x00963A) --GREEN
    end

    wgt.values.capaPercent_txt = string.format("%d%%", wgt.values.capaPercent)
end

local function updateRxVoltage(wgt)
    wgt.values.v_rx     = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.rx_voltage)
    wgt.values.v_rx_min = wgt.tlmEngine.valueMin(wgt.tlmEngine.sensorTable.rx_voltage)


    wgt.values.v_rx_cell_count = wgt.tools.calcCellCount(wgt.values.v_rx)
    local vcel = wgt.values.v_rx_cell_count > 0 and (wgt.values.v_rx / wgt.values.v_rx_cell_count) or 0
    wgt.values.v_rx_percent = wgt.tools.getCellPercent(vcel)
    -- log("updateRxVoltage:  v_rx: %s, v_rx_min: %s, %s%% (cell:%s)", wgt.values.v_rx, wgt.values.v_rx_min, wgt.values.v_rx_percent, wgt.values.v_rx_cell_count)
end

local function updateModelStats(wgt)
    wgt.values.model_total_flights = rf2_curr_model_static_data.total_flights -- or nil
    -- log("[updateFlightStat] Total flights: [%s]", wgt.values.model_total_flights)
    wgt.values.model_total_time = rf2_curr_model_static_data.stats_total_time or 0
    wgt.values.model_total_time_str = formatTime(wgt, {value=wgt.values.model_total_time//60})
end

local function updateFlightStage(wgt)
    wgt.values.flight_stage     = wgt.task_flight_stage.getFlightStage()
    wgt.values.flight_stage_str = wgt.task_flight_stage.getFlightStageStr()
end

local function updateArm(wgt)
    wgt.values.is_arm           = wgt.tlmEngine.armingToolsIsArmed()
    wgt.values.is_arm_requested = wgt.tlmEngine.armingToolsIsArmRequested()
    wgt.values.arm_fail = (wgt.values.is_arm_requested == true and wgt.values.is_arm == false)

    -- if flags == nil then
    --     wgt.values.arm_disable_flags_list = {}
    --     wgt.values.arm_disable_flags_txt = "---"
    --     wgt.values.arm_fail = false
    --     return
    -- end

    -- flags = 0x31090186
    -- rf2.log("disableFlags: flags:%s", flags)

    wgt.values.arm_disable_flags_list = {}
    wgt.values.arm_disable_flags_txt = ""
    -- wgt.values.arm_fail = false

    if wgt.values.arm_fail == true then
        local flagList = wgt.tlmEngine.armingToolsArmDisabledFlags()
        if flagList == nil then
            return
        end

        wgt.values.arm_disable_flags_list = flagList
        -- wgt.values.arm_disable_flags_txt = ""
        -- wgt.values.arm_fail = false

        -- log("disableFlags len: %s", #flagList)
        if (#flagList > 0) then
            for i in pairs(flagList) do
                -- log("disableFlags: %s", i)
                -- log("disableFlags: %s", flagList[i])
                wgt.values.arm_disable_flags_txt = wgt.values.arm_disable_flags_txt .. "* " .. flagList[i] .. ".\n"
            end
        end
    end
end

local function updateThr(wgt)
    wgt.values.thr     = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.throttle_percent)
    wgt.values.thr_max = wgt.tlmEngine.valueMax(wgt.tlmEngine.sensorTable.throttle_percent)
end

local function updateTemperature(wgt)
    local tempTop = wgt.options.tempTop
    wgt.values.EscT     = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.temp_esc)
    wgt.values.EscT_max = wgt.tlmEngine.valueMax(wgt.tlmEngine.sensorTable.temp_esc)

    wgt.values.EscT_percent     = math.min(100, math.floor(100 * (wgt.values.EscT / tempTop)))
    wgt.values.EscT_max_percent = math.min(100, math.floor(100 * (wgt.values.EscT_max / tempTop)))
end

local function updateELRS(wgt)
    wgt.values.link_rqly         = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.link_rqly)
    wgt.values.link_rqly_min     = wgt.tlmEngine.valueMin(wgt.tlmEngine.sensorTable.link_rqly)
    wgt.values.link_tx_power     = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.link_tx_power)
    wgt.values.link_tx_power_max = wgt.tlmEngine.valueMax(wgt.tlmEngine.sensorTable.link_tx_power)
end

local function calcImageKey(wgt)
    local modleCraftName = model.getInfo().bitmap
    local key = wgt.values.craft_name .. "|" .. modleCraftName
    -- log("updateImage - imageKey: %s", key)
    return key
end
local function updateImage(wgt)
    local newKey = calcImageKey(wgt)
    if wgt.values.img_last_key == newKey then
        -- log("updateImage - image key not changed")
        return
    end

    log("updateImage - craft name changed --> craft_name: %s, img_craft_image_name: %s", wgt.values.craft_name, wgt.values.img_craft_image_name)
    wgt.values.img_last_key = newKey

    local filename = "/IMAGES/" .. wgt.values.craft_name .. ".png"
    log("updateImage - checking image: %s", filename)
    if wgt.tools.isFileExist(filename) == true then
        log("updateImage - found image for model: %s", filename)
        wgt.values.img_craft_image_name = filename
        return
    end
    local filename = "/IMAGES/" .. wgt.values.craft_name .. ".jpg"
    log("updateImage - checking image: %s", filename)
    if wgt.tools.isFileExist(filename) == true then
        log("updateImage - found image for model: %s", filename)
        wgt.values.img_craft_image_name = filename
        return
    end

    local filename = "/IMAGES/" .. model.getInfo().bitmap
    log("updateImage - checking image: %s", filename)
    if wgt.tools.isFileExist(filename) == true then
        log("updateImage - found image for craft: %s", filename)
        wgt.values.img_craft_image_name = filename
        return
    end

    wgt.values.img_craft_image_name = baseDir.."/img/rf2_logo.png"
end

local function updateOnNoConnection()
    wgt.values.arm_disable_flags_txt = ""
    wgt.values.arm_fail = false
    wgt.not_connected_error = "no connection to RF2 FC"
end

---------------------------------------------------------------------------------------

local function onFlightStateChanged(oldState, newState)
    log("onFlightStateChanged: %s", newState)

    if newState == wgt.task_flight_stage.FLIGHT_STATE.PRE_FLIGHT then
        build_ui(wgt, dashboard_file_name)
        wgt.tlmEngine.is_post_flight = false

    elseif newState == wgt.task_flight_stage.FLIGHT_STATE.ON_AIR_PENDING then
        wgt.tlmEngine.resetSensorsMinMax()
        wgt.tlmEngine.is_post_flight = false

    elseif newState == wgt.task_flight_stage.FLIGHT_STATE.ON_AIR then
        build_ui(wgt, dashboard_file_name)
        wgt.tlmEngine.is_post_flight = false

    elseif newState == wgt.task_flight_stage.FLIGHT_STATE.POST_FLIGHT then
        build_ui(wgt, dashboard_post_file_name)
        wgt.tlmEngine.is_post_flight = true
    end
end

local function update(wgt_new, options)
    log("update")
    wgt.options = options
    wgt.zone = wgt_new.zone
    wgt.is_connected = false
    updateOnNoConnection()

    wgt.tools     = assert(loadScript(baseDir .. "/lib_widget_tools.lua", "btd"))(m_log, app_name)
    wgt.statusbar = assert(loadScript(baseDir .. "/parts/statusbar.lua",  "btd"))(m_log.info, app_name, wgt.tools)
    wgt.tlmEngine = assert(loadScript(baseDir .. "/telemetry_engine.lua", "btd"))(m_log.info, app_name, runningInSimulator)
    log("x-telemetery tlmTask: %s", wgt.tlmEngine)
    wgt.tlmEngine.init()

    wgt.periodicResetTlmAfterConnection = wgt.tools.periodicInit()

    wgt.task_capa_audio = loadScript(baseDir .. "/tasks/task_capa_audio.lua", "btd")(baseDir, log, app_name)
    wgt.task_capa_audio.init()

    wgt.task_flight_stage = loadScript(baseDir .. "/tasks/task_flight_stage.lua", "btd")(baseDir, log, app_name, onFlightStateChanged)
    wgt.task_flight_stage.init()


    log("is_fullscreen: %s", lvgl.isFullScreen())
    log("is_app_mode: %s", lvgl.isAppMode())

    dashboard_file_name = dashboard_styles[wgt.options.guiStyle] or dashboard_styles[1]
    dashboard_post_file_name = dashboard_post_styles[wgt.options.guiStylePost] or dashboard_post_styles[1]

    -- if user requested no post dashboard (same as flight dashboard)
    -- if wgt.options.guiStylePost == #dashboard_post_styles then
    if wgt.options.guiStylePost == 1 then
        dashboard_post_file_name = dashboard_file_name
    end

    wgt.isNeedTopbar = (wgt.zone.w == LCD_W and wgt.zone.h == LCD_H)
    wgt.selfTopbarHeight = wgt.isNeedTopbar and 40 or 0

    if lvgl.isFullScreen() then
        dashboard_file_name = "dashboard_app_mode.lua"
    end
    log("update: gui style: %s", dashboard_file_name)
    build_ui(wgt, dashboard_file_name)
    return wgt
end

local function create(zone, options)
    wgt.zone = zone
    wgt.options = options
    return update(wgt, options)
end

local function background(wgt)
    local prev_is_connected = wgt.is_connected
    wgt.is_connected = wgt.tlmEngine.value(wgt.tlmEngine.sensorTable.is_connected)

    if prev_is_connected==false and wgt.is_connected==true and wgt.task_flight_stage.isOnPreFlight() then
        log("background: connection re-established")
        wgt.tlmEngine.resetSensorsMinMax()
        wgt.tools.periodicStart(wgt.periodicResetTlmAfterConnection, 4000)
    end

    -- reset tlm also 4 seconds after connection
    if wgt.is_connected == true and wgt.tools.periodicHasPassed(wgt.periodicResetTlmAfterConnection) then
        wgt.tools.periodicStop(wgt.periodicResetTlmAfterConnection)
        log("background: reset telem on 4 sec after connection...")
        wgt.tlmEngine.resetSensorsMinMax()
    end

    if wgt.task_flight_stage.isPostFlight()==false then
        wgt.tlmEngine.updatePostFlightValues()
    end

    updateTimeCount(wgt)
    updateHeadspeed(wgt)
    updateProfiles(wgt)
    updateCell(wgt)
    updateCurr(wgt)
    updateCapa(wgt)
    updateRxVoltage(wgt)
    updateThr(wgt)
    updateTemperature(wgt)
    updateImage(wgt)
    updateELRS(wgt)
    updateFlightStage(wgt)
    updateArm(wgt)

    wgt.task_capa_audio.run(wgt)
    wgt.task_flight_stage.run(wgt)

    if wgt.is_connected == false then
        updateOnNoConnection()
        return
    end


    ----  model static data  ----------------------------------------------------------------------------
    read_curr_model_static_data()

    updateCraftName(wgt)
    -- updateGovernor(wgt)
    updateModelStats(wgt)
end

local function refresh(wgt, event, touchState)
    if (wgt == nil) then return end

    background(wgt)

    if curr_dashboard.refresh ~= nil then
        curr_dashboard.refresh(wgt, event, touchState)
    end
--    dbgLayout()
end

return {create=create, update=update, background=background, refresh=refresh}
