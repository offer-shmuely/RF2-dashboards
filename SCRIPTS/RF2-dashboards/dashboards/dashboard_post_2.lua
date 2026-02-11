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
local lib_post_bar = assert(loadScript(baseDir .. "/parts/post_bar.lua", "btd"))()

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
    local bx = 2
    local by = 65
    local dy = 29


    pMain:build({
        {type="box", x=10, y=10, children={
            {type="label", text="Flight Statistics", x=0, y=0, font=FS.FONT_12, color=txtColor},
        }}
    })
    -- flight time
    pMain:build({
        {type="box", x=270, y=2, children={
            {type="label", text="Flight Time", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.timer_str end, x=0, y=15, font=FS.FONT_16 ,color=txtColor},
        }}
    })

    -- flights count
    pMain:build({{type="box", x=380, y=2,
        children={
            {type="label", text="Total Flights", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", x=0, y=15, font=FS.FONT_16 ,color=WHITE,
                text=function() return string.format("%s", wgt.values.model_total_flights or "000") end
            },
        }
    }})

    -- -- xxx
    -- pMain:build({{type="box", x=280, y=0,
    --     children={
    --         {type="label", text="xxxx", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
    --         {type="label", x=0, y=15, font=FS.FONT_16 ,color=WHITE,
    --             text=function() return string.format("%s", wgt.values.model_total_flights or "000") end
    --         },
    --     }
    -- }})

    -- capacity
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Capacity",
        -- function() return string.format("%dmah", wgt.values.capaRemain or 0) end,
        -- function() return string.format("%d%% (used: %dmah)", wgt.values.capaPercent, wgt.values.capaUsed or 0) end,
        function() return string.format("%dmah", wgt.values.capaUsed or 0) end,
        function() return wgt.values.capaPercent or 0 end,
        nil,
        wgt.tlmEngine.sensorTable.capa
    )

    by = by + dy

    -- current
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Current",
        function() return string.format("+%dA", wgt.values.curr_max)  or "--A"end,
        function() return wgt.values.curr_max_percent end,
        nil,
        wgt.tlmEngine.sensorTable.current
    )

    by = by + dy

    -- temp
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0x1F96C2), "Esc Temp",
        function() return string.format("+%d°c", wgt.values.EscT_max or "--°c") end,
        function() return wgt.values.EscT_max_percent end,
        "temperature.png",
        wgt.tlmEngine.sensorTable.temp_esc
    )

    by = by + dy

    -- Battery
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Battery",
        function() return string.format("%.02fv",  wgt.values.volt) end,
        function() return wgt.values.cell_percent end,
        nil,
        wgt.tlmEngine.sensorTable.batt_voltage
    )

    by = by + dy

    -- RxVoltage
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Rx Volt",
        function() return string.format("%.02fv", wgt.values.v_rx_min) end,
        function() return wgt.tlmEngine.sensorTable.rx_voltage.fPercent(wgt.values.v_rx_min) end,
        nil,
        wgt.tlmEngine.sensorTable.rx_voltage
    )

    -------------------------------------------------------------------------------------------
    -- vertical line in the middle
    pMain:build({
        {type="vline",
            x=LCD_W/2, y=70,
            h=LCD_H - wgt.selfTopbarHeight -70 -15 -wgt.statusbar.height(),
            w=2,
            color=lcd.RGB(0x444444)
        }
    })

    bx = 260
    by = 65
    -------------------------------------------------------------------------------------------

    -- rqly
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "RQly",
        function() return string.format("%s%%", wgt.values.link_rqly_min) end,
        function() return wgt.values.link_rqly_min end,
        nil,
        wgt.tlmEngine.sensorTable.link_rqly
    )

    by = by + dy

    -- thr
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFFA72C), "Thr",
        function() return string.format("%s%%", wgt.values.thr_max) end,
        function() return wgt.values.thr_max end,
        nil,
        wgt.tlmEngine.sensorTable.throttle_percent
    )

    by = by + dy

    -- headspeed
    lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFFA72C), "Headspeed",
        function() return string.format("%srpm", wgt.values.rpm_max) end,
        function() return 100 end, -- we show the max, so hardcoded 100%
        nil,
        wgt.tlmEngine.sensorTable.rpm
    )

    -- lib_post_bar.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFFA72C), "RPM",
    --     "111",--function() return string.format("%s%%", wgt.values.rpm_max) end,
    --     "222",--function() return wgt.values.rpm_max end,
    --     nil,
    --     wgt.tlmEngine.sensorTable.throttle_percent
    --     -- wgt.tlmEngine.sensorTable.rpm
    -- )

    -- status bar
    wgt.statusbar.init("Shmuely", {
        -- {name="RQly-:", ftxt=function() return string.format("RQly-: %s%%", wgt.values.link_rqly_min) end,  color=GREEN, error_color=RED, error_cond=function() return (wgt.values.link_rqly < 80) end },
        -- {name="VBec-:", ftxt=function() return string.format("VBec-: %sV",  wgt.values.v_rx_min) end,       color=GREEN, error_color=RED, error_cond=function() return wgt.tlmEngine.sensorTable.rx_voltage.isWarn() end },
        -- {name="Curr+:", ftxt=function() return string.format("Curr+: %sV",  wgt.values.curr_max) end},
        -- {name="TPwr+:", ftxt=function() return string.format("TPwr+: %smw", wgt.values.link_tx_power_max) end},
        -- {name="Thr+:",  ftxt=function() return string.format("Thr+: %s%%",  wgt.values.thr_max) end},
    })
    wgt.statusbar.build_ui(pMain, wgt)


end

return M

