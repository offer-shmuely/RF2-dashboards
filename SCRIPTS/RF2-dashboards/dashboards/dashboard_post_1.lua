local arg = {...}
local log = arg[1]
local app_name = arg[2]
local baseDir = arg[3]
local tools = arg[4]
local statusbar = arg[5]
local inSimu = arg[6]

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local lib_blackbox_horz = assert(loadScript(baseDir .. "/parts/blackbox_horz.lua", "btd"))()
local lib_post_arc = assert(loadScript(baseDir .. "/parts/post_arc.lua", "btd"))()

local M = {}

M.build_ui = function(wgt)
    if (wgt == nil) then log("refresh(nil)") return end
    if (wgt.options == nil) then log("refresh(wgt.options=nil)") return end
    local txtColor = wgt.options.textColor
    local titleGreyColor = LIGHTGREY

    local dx = 20

    lvgl.clear()

    -- global
    lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=lcd.RGB(0x111111), filled=true})

    -- top bar
    lvgl.box({x=0, y=0, w=LCD_W, h=40, visible=function() return wgt.isNeedTopbar end,
        children={
            {type="rectangle", x=0, y=0, w=LCD_W, h=40, color=DARKGREY, filled=true},
            {type="label", x=60, y=2, font=FS.FONT_16, color=txtColor, text=function() return wgt.values.craft_name end},
            {type="image", x=0, y=0, w=45, h=45, file="/SCRIPTS/RF2-dashboards/img/rf2_logo.png"},
        }
    })


    -- main dashboard area
    local pMain = lvgl.box({x=0, y=wgt.selfTopbarHeight})


    -- time
    pMain:build({
        {type="box", x=370, y=130, children={
            {type="label", text="Time", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.timer_str end, x=0, y=15, font=FS.FONT_16 ,color=txtColor},
        }}
    })


    local g_rad = 40
    local g_thick = 8--11
    local gm_rad = g_rad-10
    local gm_thick = 8
    local g_y1 = 5
    local g_y2 = 85
    local g_angel_min = 140
    local g_angel_max = 400
    local x_space = 5
    local function calEndAngle(percent)
        if percent==nil then return 0 end
        local v = ((percent/100) * (g_angel_max-g_angel_min)) + g_angel_min
        return v
    end
    local bx = 5
    local by = 5

    -- current
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Current",
        function() return string.format("+%dA", wgt.values.curr_max)  or "--A"end,
        function() return wgt.values.curr_max_percent end,
        nil,
        wgt.tlmEngine.sensorTable.current
    )

    bx = bx + g_rad*2 + x_space

    -- temp
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0x1F96C2), "Esc Temp",
        function() return string.format("+%d°c", wgt.values.EscT_max or "--°c") end,
        function() return wgt.values.EscT_max_percent end,
        "temperature.png",
        wgt.tlmEngine.sensorTable.temp_esc
    )

    bx = bx + g_rad*2 + x_space

    -- thr
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFFA72C), "Throttle",
        function() return string.format("%s%%", wgt.values.thr_max) end,
        function() return wgt.values.thr_max end,
        nil,
        wgt.tlmEngine.sensorTable.throttle_percent
    )

    bx = bx + g_rad*2 + x_space

    -- rqly
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Link Quality",
        function() return string.format("%s%%", wgt.values.link_rqly_min) end,
        function() return wgt.values.link_rqly_min end,
        nil,
        wgt.tlmEngine.sensorTable.link_rqly
    )

    bx = 5
    by = 110

    -- Battery
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Battery",
        function() return string.format("%.02fv",  wgt.values.volt) end,
        function() return wgt.values.cell_percent end,
        nil,
        wgt.tlmEngine.sensorTable.batt_voltage
    )
    bx = bx + g_rad*2 + x_space

    -- RxVoltage
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Rx Volt",
        function() return string.format("%.02fv", wgt.values.v_rx_min) end,
        function() return wgt.tlmEngine.sensorTable.rx_voltage.fPercent(wgt.values.v_rx_min) end,
        nil,
        wgt.tlmEngine.sensorTable.rx_voltage
    )

    bx = bx + g_rad*2 + x_space

    -- headspeed
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Headspeed",
        function() return string.format("%srpm", wgt.values.rpm_max) end,
        function() return wgt.values.rpm_percent end,
        nil,
        wgt.tlmEngine.sensorTable.rpm
    )

    bx = bx + g_rad*2 + x_space

    -- capacity
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Capacity",
        function() return string.format("%d%% (used: %dmah)", wgt.values.capaPercent, wgt.values.capaUsed or 0) end,
        function() return wgt.values.capaPercent or 0 end,
        nil,
        wgt.tlmEngine.sensorTable.capa
    )


    -- status bar
    wgt.statusbar.init("Shmuely", {
        {name="RQly-:", ftxt=function() return string.format("LQ-: %s%%",     wgt.values.link_rqly_min) end,  color=GREEN, error_color=RED, error_cond=function() return (wgt.is_connected and wgt.values.link_rqly_min < 80) end },
        {name="VBec-:", ftxt=function() return string.format("VBec-: %0.1fV", wgt.values.v_rx_min) end,       color=GREEN, error_color=RED, error_cond=function() return wgt.tlmEngine.sensorTable.rx_voltage.isWarn() end },
        {name="Curr+:", ftxt=function() return string.format("A+: %dA",       wgt.values.curr_max) end},
        {name="TPwr+:", ftxt=function() return string.format("TPwr+: %smw",   wgt.values.link_tx_power_max) end},
        {name="Thr+:",  ftxt=function() return string.format("Thr+: %s%%",    wgt.values.thr_max) end},
    })
    wgt.statusbar.build_ui(pMain, wgt)


    -- image
    local isizew=150
    local isizeh=100
    pMain:box({x=330, y=5,
        children={
            -- {type="rectangle", x=0, y=0, w=isizew, h=isizeh, thickness=4, rounded=15, filled=false, color=GREY},
            {type="image", x=0, y=0, w=isizew, h=isizeh, fill=false, file=function() return wgt.values.img_craft_image_name end}
        }
    })

    -- flights count
    pMain:build({{type="box", x=340, y=105,
        children={
            {type="label", x=0, y=0, font=FS.FONT_12 ,color=WHITE,
                text=function() return string.format("%s Flights", wgt.values.model_total_flights or "000") end
            },
        }
    }})
    -- air time
    pMain:build({{type="box", x=420, y=105,
        children={
            {type="label", x=0, y=0, font=FS.FONT_6 ,color=lcd.RGB(0x999999),
                text=function() return string.format("%s Min", wgt.values.model_total_time_str or "---") end
            },
        }
    }})

    -- craft name
    local bCraftName = pMain:box({x=330, y=60})
    bCraftName:rectangle({x=10, y=20, w=isizew-20, h=20, filled=true, rounded=8, color=DARKGREY, opacity=200})
    bCraftName:label({text=function() return wgt.values.craft_name end,  x=15, y=20, font=FS.FONT_8 ,color=txtColor})

    -- -- failed to arm flags
    -- pMain:build({{type="box", x=100, y=25, visible=function() return wgt.values.arm_fail end,
    --     children={
    --         {type="rectangle", x=0, y=0, w=280, h=150, color=RED, filled=true, rounded=8, opacity=245},
    --         {type="label", text=function()
    --             return string.format("%s (%s)", wgt.values.arm_disable_flags_txt, wgt.values.arm_fail)
    --         end, x=10, y=0, font=FS.FONT_8, color=WHITE},
    --     }
    -- }})

    -- -- no connection
    -- pMain:build({{type="box", x=330, y=10, visible=function() return wgt.is_connected==false end,
    --     children={
    --         {type="rectangle", x=5, y=10, w=isizew-10, h=isizeh-20, rounded=15, filled=true, opacity=250, color=BLACK},
    --         {type="image", x=30, y=0, w=90, h=90, file=baseDir.."/img/no_connection_wr.png"},
    --         {type="label", x=10, y=70, text=function() return wgt.not_connected_error end , font=FS.FONT_8, color=WHITE},
    --     }
    -- }})

end

return M

