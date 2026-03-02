local arg = {...}
local log = arg[1]
local app_name = arg[2]
local baseDir = arg[3]
local tools = arg[4]
local statusbar = arg[5]
local inSimu = arg[6]

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}
local lvSCALE = lvgl.LCD_SCALE or 1
local is800 = (LCD_W==800)

local lib_blackbox_horz = assert(loadScript(baseDir .. "/parts/blackbox_horz.lua", "btd"))()
local lib_post_arc = assert(loadScript(baseDir .. "/parts/post_arc.lua", "btd"))()

local M = {}


local function lvglHFactor(p)
    return math.floor(p * LCD_W / 480)
end

local function lvglVFactor(p)
    return math.floor(p * LCD_H / 272)
end

M.build_ui = function(wgt)
    if (wgt == nil) then log("refresh(nil)") return end
    if (wgt.options == nil) then log("refresh(wgt.options=nil)") return end
    local txtColor = wgt.options.textColor
    local titleGreyColor = LIGHTGREY

    lvgl.clear()

    -- global
    lvgl.rectangle({x=0, y=0, w=LCD_W*lvSCALE, h=LCD_H*lvSCALE, color=lcd.RGB(0x111111), filled=true})

    -- top bar
    lvgl.box({x=0, y=0, w=LCD_W*lvSCALE, h=40*lvSCALE, visible=function() return wgt.isNeedTopbar end,
        children={
            {type="rectangle", x=0, y=0, w=LCD_W*lvSCALE, h=40*lvSCALE, color=DARKGREY, filled=true},
            {type="label", x=60*lvSCALE, y=2*lvSCALE, font=FS.FONT_16, color=txtColor, text=function() return wgt.values.craft_name end},
            {type="image", x=0, y=0, w=45*lvSCALE, h=45*lvSCALE, file="/SCRIPTS/RF2-dashboards/img/rf2_logo.png"},
        }
    })

    -- main dashboard area
    local pMain = lvgl.box({x=0, y=wgt.selfTopbarHeight*lvSCALE})

    -- current
    lib_post_arc.build_ui(pMain, wgt, 1,1, lcd.RGB(0xFF623F), "Current",
        function() return string.format("+%dA", wgt.values.curr_max)  or "--A"end,
        function() return wgt.values.curr_max_percent end,
        nil,
        wgt.tlmEngine.sensorTable.current
    )

    -- temp
    lib_post_arc.build_ui(pMain, wgt, 1,2, lcd.RGB(0x1F96C2), "Esc Temp",
        function() return string.format("+%d°c", wgt.values.EscT_max or "--°c") end,
        function() return wgt.values.EscT_max_percent end,
        "temperature.png",
        wgt.tlmEngine.sensorTable.temp_esc
    )

    -- thr
    lib_post_arc.build_ui(pMain, wgt, 1,3, lcd.RGB(0xFFA72C), "Throttle",
        function() return string.format("%s%%", wgt.values.thr_max) end,
        function() return wgt.values.thr_max end,
        nil,
        wgt.tlmEngine.sensorTable.throttle_percent
    )

    -- rqly
    lib_post_arc.build_ui(pMain, wgt, 1,4, lcd.RGB(0xFF623F), "Link Quality",
        function() return string.format("%s%%", wgt.values.link_rqly_min) end,
        function() return wgt.values.link_rqly_min end,
        nil,
        wgt.tlmEngine.sensorTable.link_rqly
    )

    -- Battery
    lib_post_arc.build_ui(pMain, wgt, 2,1, lcd.RGB(0xFF623F), "Battery",
        function() return string.format("%.02fv",  wgt.values.volt) end,
        function() return wgt.values.cell_percent end,
        nil,
        wgt.tlmEngine.sensorTable.batt_voltage
    )

    -- RxVoltage
    lib_post_arc.build_ui(pMain, wgt, 2,2, lcd.RGB(0xFF623F), "Rx Volt",
        function() return string.format("%.02fv", wgt.values.v_rx_min) end,
        function() return wgt.tlmEngine.sensorTable.rx_voltage.fPercent(wgt.values.v_rx_min) end,
        nil,
        wgt.tlmEngine.sensorTable.rx_voltage
    )

    -- headspeed
    lib_post_arc.build_ui(pMain, wgt, 2,3, lcd.RGB(0xFF623F), "Headspeed",
        function() return string.format("%srpm", wgt.values.rpm_max) end,
        function() return wgt.values.rpm_percent end,
        nil,
        wgt.tlmEngine.sensorTable.rpm
    )

    -- capacity
    lib_post_arc.build_ui(pMain, wgt, 2,4, lcd.RGB(0xFF623F), "Capacity",
        function() return string.format("%d%%\nUsed: %dmah", wgt.values.capaPercent, wgt.values.capaUsed or 0) end,
        function() return wgt.values.capaPercent or 0 end,
        nil,
        wgt.tlmEngine.sensorTable.capa
    )

    -- image & more
    local isizew=150*lvSCALE
    local isizeh=100*lvSCALE
    local right_col_x = is800 and 440*lvSCALE or 330
    pMain:box({x=right_col_x, y=5*lvSCALE,
        children={
            -- image
            {type="rectangle", x=0, y=0, w=isizew, h=isizeh, thickness=4, rounded=15, filled=false, color=GREY},
            {type="image", x=0, y=0, w=isizew, h=isizeh, fill=false, file=function() return wgt.values.img_craft_image_name end},
            -- craft name
            {type="rectangle", x=6*lvSCALE, y=isizeh-25*lvSCALE, w=isizew-20, h=20*lvSCALE, filled=true, rounded=8*lvSCALE, color=DARKGREY, opacity=200},
            {type="label", text=function() return wgt.values.craft_name end,  x=15*lvSCALE, y=isizeh-25*lvSCALE, font=FS.FONT_8 ,color=txtColor},
            -- flights count
            {type="label",  x=8*lvSCALE, y=isizeh+10*lvSCALE, font=FS.FONT_12 ,color=WHITE,
                text=function() return string.format("%s Flights", wgt.values.model_total_flights or "000") end,
            },
            -- time
            {type="label", text="Time", x=8*lvSCALE, y=isizeh+50*lvSCALE, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.timer_str end, x=8*lvSCALE, y=isizeh+60*lvSCALE, font=FS.FONT_16 ,color=txtColor},
        }
    })

    -- status bar
    wgt.statusbar.init("Shmuely", {
        {name="LQ-:",   ftxt=function() return string.format("LQ-: %s%%",     wgt.values.link_rqly_min) end,  color=GREEN, error_color=RED, error_cond=function() return (wgt.is_connected and wgt.values.link_rqly_min < 80) end },
        {name="VBec-:", ftxt=function() return string.format("VBec-: %0.1fV", wgt.values.v_rx_min) end,       color=GREEN, error_color=RED, error_cond=function() return wgt.tlmEngine.sensorTable.rx_voltage.isWarn() end },
        {name="Curr+:", ftxt=function() return string.format("A+: %dA",       wgt.values.curr_max) end},
        {name="TPwr+:", ftxt=function() return string.format("TPwr+: %smw",   wgt.values.link_tx_power_max) end},
        {name="Thr+:",  ftxt=function() return string.format("Thr+: %s%%",    wgt.values.thr_max) end},
    })
    wgt.statusbar.build_ui(pMain, wgt)


end

return M

