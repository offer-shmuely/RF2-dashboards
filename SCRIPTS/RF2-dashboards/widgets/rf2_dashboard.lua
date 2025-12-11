local app_name = "RF2-dashboards"

local baseDir = "/SCRIPTS/RF2-dashboards/"
local inSimu = string.sub(select(2,getVersion()), -4) == "simu"

local timerNumber = 1

local err_img = bitmap.open(baseDir.."widgets/img/no_connection_wr.png")

local dashboard_styles = {
    [1] = "rf2_dashboard_fancy.lua",
    [2] = "rf2_dashboard_modern.lua",
    [3] = "rf2_dashboard_capa.lua",
}


local wgt = {
    values = {
        craft_name = "-------",
        timer_str = "--:--",
        rpm = -1,
        rpm_str = "---",
        profile_id = -1,
        profile_id_str = "--",
        rate_id = -1,
        rate_id_str = "--",

        vbat = -1,
        vcel = -1,
        cell_percent = -1,
        volt = -1,
        curr = 0,
        curr_max = 0,
        curr_str = "0",
        curr_max_str = "0",
        curr_percent = 0,
        curr_max_percent = 0,
        capaTotal = -1,
        capaUsed = -1,
        capaPercent = -1,
        capaPercent_txt = "---",

        EscT = 0,
        EscT_max = 0,
        EscT_str = "0",
        EscT_max_str = "0",
        EscT_percent = 0,
        EscT_max_percent = 0,

        rqly = 0,
        rqly_min = 0,
        rqly_str = 0,
        rqly_min_str = 0,

        -- governor_str = "-------",
        bb_enabled = true,
        bb_percent = 0,
        bb_size = 0,
        bb_txt = "Blackbox: --% 0MB",
        rescue_on = false,
        rescue_txt = "--",
        is_arm = false,
        arm_fail = false,
        arm_disable_flags_list = nil,
        arm_disable_flags_txt = "",

        img_last_name = "---",
        img_craft_name_for_image = "---",
        img_box_1 = nil,
        img_replacment_area1 = nil,
        img_box_2 = nil,
        img_replacment_area2 = nil,

        thr = 0,
        thr_max = 0,
    },

}


-- Data gathered from commercial lipo sensors
local percent_list_lipo = {
    {3.000,  0},
    {3.093,  1}, {3.196,  2}, {3.301,  3}, {3.401,  4}, {3.477,  5}, {3.544,  6}, {3.601,  7}, {3.637,  8}, {3.664,  9}, {3.679, 10},
    {3.683, 11}, {3.689, 12}, {3.692, 13}, {3.705, 14}, {3.710, 15}, {3.713, 16}, {3.715, 17}, {3.720, 18}, {3.731, 19}, {3.735, 20},
    {3.744, 21}, {3.753, 22}, {3.756, 23}, {3.758, 24}, {3.762, 25}, {3.767, 26}, {3.774, 27}, {3.780, 28}, {3.783, 29}, {3.786, 30},
    {3.789, 31}, {3.794, 32}, {3.797, 33}, {3.800, 34}, {3.802, 35}, {3.805, 36}, {3.808, 37}, {3.811, 38}, {3.815, 39}, {3.818, 40},
    {3.822, 41}, {3.825, 42}, {3.829, 43}, {3.833, 44}, {3.836, 45}, {3.840, 46}, {3.843, 47}, {3.847, 48}, {3.850, 49}, {3.854, 50},
    {3.857, 51}, {3.860, 52}, {3.863, 53}, {3.866, 54}, {3.870, 55}, {3.874, 56}, {3.879, 57}, {3.888, 58}, {3.893, 59}, {3.897, 60},
    {3.902, 61}, {3.906, 62}, {3.911, 63}, {3.918, 64}, {3.923, 65}, {3.928, 66}, {3.939, 67}, {3.943, 68}, {3.949, 69}, {3.955, 70},
    {3.961, 71}, {3.968, 72}, {3.974, 73}, {3.981, 74}, {3.987, 75}, {3.994, 76}, {4.001, 77}, {4.007, 78}, {4.014, 79}, {4.021, 80},
    {4.029, 81}, {4.036, 82}, {4.044, 83}, {4.052, 84}, {4.062, 85}, {4.074, 86}, {4.085, 87}, {4.095, 88}, {4.105, 89}, {4.111, 90},
    {4.116, 91}, {4.120, 92}, {4.125, 93}, {4.129, 94}, {4.135, 95}, {4.145, 96}, {4.176, 97}, {4.179, 98}, {4.193, 99}, {4.200,100},
}

--- This function return the percentage remaining in a single Lipo cel
local function getCellPercent(cellValue)
    if cellValue == nil then
        return 0
    end

    -- if voltage too low, return 0%
    if cellValue <= percent_list_lipo[1][1] then
        return 0
    end

    -- if voltage too high, return 100%
    if cellValue >= percent_list_lipo[#percent_list_lipo][1] then
        return 100
    end

    -- binary search
    local l = 1
    local u = #percent_list_lipo
    while true do
        local n = (u + l) // 2
        if cellValue >= percent_list_lipo[n][1] and cellValue <= percent_list_lipo[n+1][1] then
            -- return closest value
            if cellValue < (percent_list_lipo[n][1] + percent_list_lipo[n + 1][1]) / 2 then
                return percent_list_lipo[n][2]
            else
                return percent_list_lipo[n+1][2]
            end
        end
        if cellValue < percent_list_lipo[n][1] then
            u = n
        else
            l = n
        end
    end

    return 0
end

--------------------------------------------------------------
local function log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
    return
end
--------------------------------------------------------------

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}


local function tableToString(tbl)
    if (tbl == nil) then return "---" end
    local result = {}
    for key, value in pairs(tbl) do
        table.insert(result, string.format("%s: %s", tostring(key), tostring(value)))
    end
    return table.concat(result, ", ")
end

local function isFileExist(file_name)
    rf2.log("is_file_exist()")
    local hFile = io.open(file_name, "r")
    if hFile == nil then
        rf2.log("file not exist - %s", file_name)
        return false
    end
    io.close(hFile)
    rf2.log("file exist - %s", file_name)
    return true
end

-----------------------------------------------------------------------------------------------------------------

local dbgx, dbgy = 100, 100
local function getDxByStick(stk)
    local v = getValue(stk)
    if math.abs(v) < 15 then return 0 end
    local d = math.ceil(v / 400)
    return d
end
local function dbgLayout()
    local dw = getDxByStick("ail")
    dbgx = dbgx + dw
    dbgx = math.max(0, math.min(480, dbgx))

    local dh = getDxByStick("ele")
    dbgy = dbgy - dh
    dbgy = math.max(0, math.min(272, dbgy))
    -- log("%sx%s", dbgx, dbgy)
    -- lcd.drawFilledRectangle(100,100, 70,25, GREY)
    lcd.drawText(400,0, string.format("%sx%s", dbgx, dbgy), FS.FONT_8 + WHITE)
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
      -- less then 1 hour, 59:59
      time_str = string.format("%02d:%02d", mm, ss)

    elseif dd == 0 then
      -- lass then 24 hours, 23:59:59
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

local build_ui = function(wgt, file_name)
    local ui_lib = assert(loadScript(baseDir .. "/widgets/dashboards/" ..file_name))()
    ui_lib.build_ui(wgt)
end

-------------------------------------------------------------------
local function close()
    lvgl.confirm({title="Exit", message="exit config?",
        confirm=(function() lvgl.exitFullScreen() end)
    })
end

-------------------------------------------------------------------

local replImg = 0
local imgTp = 0
local function updateCraftName(wgt)
    local is_dbg_craft_change = true

    if is_dbg_craft_change == true then
        if (rf2.clock() - replImg > 5) then
            rf2.log("updateCraftName - interval")
            imgTp = imgTp + 1
            if imgTp % 2 == 0 then
                wgt.values.craft_name = "sab601"
            else
                wgt.values.craft_name = "sab588"
            end
            rf2.log("updateCraftName - newCraftName: %s", wgt.values.craft_name)
            replImg = rf2.clock()
        end
    else
        wgt.values.craft_name = wgt.mspTool.craftName()
    end

end

local function updateTimeCount(wgt)
    local t1 = model.getTimer(timerNumber - 1)
    local time_str, isNegative = formatTime(wgt, t1)
    wgt.values.timer_str = time_str
end

local function updateRpm(wgt)
    local val     = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.rpm)
    -- local rpm_max = rf2.tlmEngine.getValueMax(rf2.tlmEngine.sensorTable.rpm)
    wgt.values.rpm = val
    wgt.values.rpm_str = string.format("%s",val)
end

local function updateProfiles(wgt)
    -- Current PID profile
    local val = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.pid_profile)
    wgt.values.profile_id = val
    wgt.values.profile_id_str = string.format("%s", wgt.values.profile_id)

    -- Current Rate profile
    local val = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.rate_profile)
    wgt.values.rate_id = val
    wgt.values.rate_id_str = string.format("%s", wgt.values.rate_id)
end

local function updateCell(wgt)
    -- local batPercent = getValue("Bat%")
    local vbat     = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.batt_voltage)
    local vbat_min = rf2.tlmEngine.getValueMax(rf2.tlmEngine.sensorTable.batt_voltage)

    local cell_count = rf2fc.msp.cache.mspBatteryConfig.batteryCellCount or -1

    local vcel = cell_count > 0 and (vbat / cell_count) or 0
    local vcel_min = cell_count > 0 and (vbat_min / cell_count) or 0

    local batPercent = getCellPercent(vcel)
    -- log("vbat: %s, vcel: %s, BatPercent: %s", vbat, vcel, batPercent)

    wgt.values.vbat = vbat
    wgt.values.vcel = vcel
    wgt.values.cell_percent = batPercent
    wgt.values.volt = (wgt.options.showTotalVoltage==1) and vbat or vcel
    wgt.values.cellColor = (vcel < 3.7) and RED or lcd.RGB(0x00963A) --GREEN
end

local function updateCurr(wgt)
    local curr_top = wgt.options.currTop
    local val     = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.current)
    local val_max = rf2.tlmEngine.getValueMax(rf2.tlmEngine.sensorTable.current)
    -- log("telemetery8: updateCurr:  curr: %s, curr_max: %s", curr, curr_max)

    wgt.values.curr = val
    wgt.values.curr_max = val_max
    wgt.values.curr_percent = math.min(100, math.floor(100 * (val / curr_top)))
    wgt.values.curr_max_percent = math.min(100, math.floor(100 * (val_max / curr_top)))
    wgt.values.curr_str = string.format("%dA", wgt.values.curr)
    wgt.values.curr_max_str = string.format("+%dA", wgt.values.curr_max)
end

local function updateCapa(wgt)
    -- capacity
    -- local val     = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.capa)
    local val_max = rf2.tlmEngine.getValueMax(rf2.tlmEngine.sensorTable.capa)

    wgt.values.capaTotal = rf2fc.msp.cache.mspBatteryConfig.batteryCapacity or -1
    wgt.values.capaUsed = val_max

    if wgt.values.capaTotal == nil or wgt.values.capaTotal == nan or wgt.values.capaTotal ==0 then
        wgt.values.capaTotal = -1
        wgt.values.capaUsed = 0
    end

    if wgt.values.capaTotal == nil or wgt.values.capaTotal == nan or wgt.values.capaTotal ==0 then
        wgt.values.capaTotal = -1
        wgt.values.capaUsed = 0
    end
    wgt.values.capaPercent = math.floor(100 * (wgt.values.capaTotal - wgt.values.capaUsed) // wgt.values.capaTotal)
    local p = wgt.values.capaPercent
    if (p < 10) then
        wgt.values.capaColor = RED
    elseif (p < 30) then
        wgt.values.capaColor = ORANGE
    else
        wgt.values.capaColor = lcd.RGB(0x00963A) --GREEN
    end

    wgt.values.capaPercent_txt = string.format("%d%%", wgt.values.capaPercent)
end

-- local function updateGovernor(wgt)
--     if wgt.mspTool.governorEnabled() then
--         wgt.values.governor_str = string.format("%s", wgt.mspTool.governorMode())
--     else
--         wgt.values.governor_str = "OFF"
--     end
-- end

local function updateBB(wgt)
    wgt.values.bb_enabled = wgt.mspTool.blackboxEnable()

    if wgt.values.bb_enabled then
        local blackboxInfo = wgt.mspTool.blackboxSize()
        if blackboxInfo.totalSize > 0 then
            wgt.values.bb_percent = math.floor(100*(blackboxInfo.usedSize/blackboxInfo.totalSize))
        end
        wgt.values.bb_size = math.floor(blackboxInfo.totalSize/ 1000000)
        wgt.values.bb_txt = string.format("Blackbox: %s mb", wgt.values.bb_size)
    end
    wgt.values.bbColor = (wgt.values.bb_percent < 90) and lcd.RGB(0x00963A) or RED -- lcd.RGB(0x00963A) ~ GREEN
    -- log("bb_percent: %s", wgt.values.bb_percent)
    -- log("bb_size: %s", wgt.values.bb_size)
end

local function updateRescue(wgt)
    wgt.values.rescue_on = rf2fc.msp.cache.mspRescueProfile.mode == 1

    -- rescue enabled?
    wgt.values.rescue_txt = wgt.values.rescue_on and "ON" or "OFF"
    -- -- local rescueFlip = rf2fc.msp.cache.mspRescueProfile.flip_mode == 1
    -- -- if rescueOn then
    -- --     txt = string.format("%s (%s)", txt, (rescueFlip) and "Flip" or "No Flip")
    -- -- end
end

local  function updateArm(wgt)
    wgt.values.is_arm = wgt.mspTool.isArmed()
    -- log("isArmed %s:", wgt.values.is_arm)
    local flagList = wgt.mspTool.armingDisableFlagsList()
    wgt.values.arm_disable_flags_list = flagList
    wgt.values.arm_disable_flags_txt = ""
    wgt.values.arm_fail = false

    if flagList ~= nil then
        -- log("disableFlags len: %s", #flagList)
        if (#flagList == 0) then
            wgt.values.arm_fail = false
        else
            wgt.values.arm_fail = true
            for i in pairs(flagList) do
                -- log("disableFlags: %s", i)
                -- log("disableFlags: %s", flagList[i])
                wgt.values.arm_disable_flags_txt = wgt.values.arm_disable_flags_txt .. flagList[i] .. "\n"
            end

        end
    end

end

local function updateThr(wgt)
    local val     = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.throttle_percent)
    local val_max = rf2.tlmEngine.getValueMax(rf2.tlmEngine.sensorTable.throttle_percent)
    wgt.values.thr = val
    wgt.values.thr_max = val_max
end

local function updateTemperature(wgt)
    local tempTop = wgt.options.tempTop
    local val = rf2.tlmEngine.getValue(rf2.tlmEngine.sensorTable.temp_esc)
    local val_max = rf2.tlmEngine.getValueMax(rf2.tlmEngine.sensorTable.temp_esc)
    wgt.values.EscT = val
    wgt.values.EscT_max = val_max

    wgt.values.EscT_str = string.format("%d°c", wgt.values.EscT)
    wgt.values.EscT_max_str = string.format("+%d°c", wgt.values.EscT_max)

    wgt.values.EscT_percent = math.min(100, math.floor(100 * (wgt.values.EscT / tempTop)))
    wgt.values.EscT_max_percent = math.min(100, math.floor(100 * (wgt.values.EscT_max / tempTop)))
end

local function updateELRS(wgt)
    wgt.values.rqly = getValue("RQly")
    if (wgt.values.rqly <= 0) then
        wgt.values.rqly = getValue("VFR")
    end
    local rqly_min = getValue("RQly-")
    if (rqly_min <= 0) then
        rqly_min = getValue("VFR-")
    end

    if rqly_min > 0 then
        wgt.values.rqly_min = rqly_min
    end
    wgt.values.rqly_str = string.format("%d%%", wgt.values.rqly)
    wgt.values.rqly_min_str = string.format("%d%%", wgt.values.rqly_min)
end



local function updateImage(wgt)
    local newCraftName = wgt.values.craft_name
    if newCraftName == wgt.values.img_craft_name_for_image then
        -- log("updateImage - craft name not changed")
        return
    end
    -- log("updateImage - craft name changed --> newCraftName: %s, img_craft_name_for_image: %s", wgt.values.craft_name, wgt.values.img_craft_name_for_image)

    local filename = "/IMAGES/"..newCraftName..".png"
    log("updateImage - is-exist image: %s", filename)
    if isFileExist(filename) ==false then
        filename = "/IMAGES/".. model.getInfo().bitmap
        if filename == "" or isFileExist(filename) ==false then
            filename = baseDir.."widgets/img/rf2_logo.png"
        end
    end

    if filename ~= wgt.values.img_last_name then
        log("updateImage - model changed, %s --> %s", wgt.values.img_last_name, filename)
        wgt.values.img_last_name = filename
        wgt.values.img_craft_name_for_image = newCraftName
    end
end

local function updateOnNoConnection()
    wgt.values.arm_disable_flags_txt = ""
    wgt.values.arm_fail = false
end

---------------------------------------------------------------------------------------

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options
    wgt.not_connected_error = "Not connected"

    log("isFullscreen: %s", lvgl.isFullScreen())
    log("isAppMode: %s", lvgl.isAppMode())

    local dashboard_file_name = dashboard_styles[wgt.options.guiStyle] or dashboard_styles[1]
    if lvgl.isFullScreen() then
        dashboard_file_name = "rf2_dashboard_app_mode.lua"
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

    if rf2.tlmEngine then
        updateTimeCount(wgt)
        updateRpm(wgt)
        updateProfiles(wgt)
        updateCell(wgt)
        updateCurr(wgt)
        updateCapa(wgt)
        updateThr(wgt)
        updateTemperature(wgt)
        updateImage(wgt)
        updateELRS(wgt)
    end

    wgt.is_connected = false
    wgt.not_connected_error = "no RF2_Server widget found"
    if rf2fc == nil then
        updateOnNoConnection()
        return
    else
        if rf2fc.mspCacheTools ~= nil then
            wgt.is_connected, wgt.not_connected_error = rf2fc.mspCacheTools.isCacheAvailable()
            if wgt.is_connected==false then
                log("Not connected---")
                updateOnNoConnection()
                return
            end
        end
    end
    wgt.mspTool = rf2fc.mspCacheTools

    updateCraftName(wgt)
    -- updateGovernor(wgt)
    updateBB(wgt) -- ???
    updateRescue(wgt) --???
    updateArm(wgt)

end

local function refresh(wgt, event, touchState)
    if (wgt == nil) then return end

    background(wgt)

   dbgLayout()
end

return {create=create, update=update, background=background, refresh=refresh}
