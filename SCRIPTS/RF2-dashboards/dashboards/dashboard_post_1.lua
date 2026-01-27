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
            {type="label", text="Timer", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
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
        function() return wgt.values.curr_max_str  or "--A"end,
        function() return wgt.values.curr_max_percent end,
        nil,
        wgt.tlmEngine.sensorTable.current
    )

    bx = bx + g_rad*2 + x_space

    -- temp
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0x1F96C2), "Temperature",
        function() return wgt.values.EscT_max_str or "--°c" end,
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

    bx = 5
    by = 110

    -- capacity
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Capacity",
        function() return string.format("%dmah", wgt.values.capaRemain or 0) end,
        function() return wgt.values.capaPercent or 0 end,
        nil,
        wgt.tlmEngine.sensorTable.capa
    )

    bx = bx + g_rad*2 + x_space

    -- Battery
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Battery",
        function() return string.format("%.02fv",  wgt.values.volt) end,
        function() return wgt.values.cell_percent end,
        nil,
        wgt.tlmEngine.sensorTable.batt_voltage
    )
    bx = bx + g_rad*2 + x_space

    -- BecVoltage
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "Bec Voltage",
        function() return string.format("%.02fv", wgt.values.vbec_min) end,
        function() return wgt.values.vbec_min_percent end,
        nil,
        wgt.tlmEngine.sensorTable.bec_voltage
    )
    -- -- capacity
    -- local bCapa = pMain:box({x=5, y=145})
    -- bCapa:label({text=function() return string.format("Capacity (Total: %s)", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    -- lib_blackbox_horz.build_ui(bCapa, wgt,
    --     {x=0, y=17,w=280,h=40,segments_w=20, color=WHITE, bg_color=BLACK, cath_w=10, cath_h=30, segments_h=20, cath=false},
    --     function(wgt) return wgt.values.capaPercent end,
    --     function(wgt) return wgt.values.capaColor end
    -- )
    -- bCapa:label({x=25,  y=16, font=FS.FONT_16 ,color=WHITE, text=function() return wgt.values.capaPercent_txt end})
    -- bCapa:label({x=110, y=22, font=FS.FONT_12 ,color=WHITE, text=function() return string.format("(%.02fv)", wgt.values.volt) end})
    -- -- bCapa:label({x=5, y=18, font=FS.FONT_8 ,color=WHITE, text=function() return string.format("%dmah", wgt.values.capaTotal) end})
    -- bCapa:label({text=function() return string.format("used:\n%dmah", wgt.values.capaUsed or 0) end, x=220, y=20, font=FS.FONT_6 ,color=WHITE})

    bx = bx + g_rad*2 + x_space

    -- rqly
    lib_post_arc.build_ui(pMain, wgt, bx, by, lcd.RGB(0xFF623F), "RQly (min)",
        function() return string.format("%s%%", wgt.values.link_rqly_min) end,
        function() return wgt.values.link_rqly_min end,
        nil,
        wgt.tlmEngine.sensorTable.link_rqly
    )


    -- status bar
    local bStatusBar = pMain:box({x=0, y=wgt.zone.h-20})
    local statusBarColor = lcd.RGB(0x0078D4)
    bStatusBar:rectangle({x=0, y=0,w=wgt.zone.w, h=20, color=statusBarColor, filled=true})
    bStatusBar:rectangle({x=25, y=0,w=70, h=20, color=RED, filled=true, visible=function() return (wgt.values.link_rqly < 80) end })
    bStatusBar:label({x=3  , y=2, text=function() return string.format("LQ-: %s%%", wgt.values.link_rqly_min) end, font=function() return (wgt.values.link_rqly >= 80) and FS.FONT_6 or FS.FONT_6  end, color=WHITE})
    bStatusBar:label({x=120, y=2, text=function() return string.format("TPwr+: %smw", wgt.values.link_tx_power_max) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=230, y=2, text=function() return string.format("VBec-: %sv", wgt.values.vbec_min) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=300, y=2, text=function() return string.format("Thr+: %s%%", wgt.values.thr_max) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=380, y=2, text="Shmuely", font=FS.FONT_6, color=YELLOW})

    wgt.statusbar.init("Shmuely", {
        {name="RQly-:", ftxt=function() return string.format("RQly-: %s%%", wgt.values.link_rqly_min) end,  color=GREEN, error_color=RED, error_cond=function() return (wgt.values.link_rqly < 80) end },
        {name="VBec-:", ftxt=function() return string.format("VBec-: %sV",  wgt.values.vbec_min) end,       color=GREEN, error_color=RED, error_cond=function() return wgt.tlmEngine.sensorTable.bec_voltage.isWarn() end },
        {name="Curr+:", ftxt=function() return string.format("Curr+: %sV",  wgt.values.curr_max) end},
        {name="TPwr+:", ftxt=function() return string.format("TPwr+: %smw", wgt.values.link_tx_power_max) end},
        {name="Thr+:",  ftxt=function() return string.format("Thr+: %s%%",  wgt.values.thr_max) end},
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

    -- failed to arm flags
    pMain:build({{type="box", x=100, y=25, visible=function() return wgt.values.arm_fail end,
        children={
            {type="rectangle", x=0, y=0, w=280, h=150, color=RED, filled=true, rounded=8, opacity=245},
            {type="label", text=function()
                return string.format("%s (%s)", wgt.values.arm_disable_flags_txt, wgt.values.arm_fail)
            end, x=10, y=0, font=FS.FONT_8, color=WHITE},
        }
    }})

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

