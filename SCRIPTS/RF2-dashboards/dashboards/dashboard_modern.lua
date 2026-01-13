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
    local pMain = lvgl.box({x=0, y=0})

    -- pid profile (bank)
    pMain:build({{type="box", x=30+280, y=150,
        children={
            {type="label", text="Profile", x=0, y=40, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.profile_id_str end , x=6, y=0, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- rate profile
    pMain:build({{type="box", x=74+280, y=150,
        children={
            {type="label", text="Rate", x=0, y=40, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.rate_id_str end , x=2, y=0, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- batt profile
    -- pMain:build({{type="box", x=116+280, y=150,
    --     children={
    --         {type="label", text="Batt", x=0, y=40, font=FS.FONT_6, color=titleGreyColor},
    --         {type="label", text=function() return "1" end , x=2, y=0, font=FS.FONT_16 ,color=txtColor},
    --     }
    -- }})

    -- time
    pMain:build({
        {type="box", x=40, y=0, children={
            {type="label", text="Timer", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.timer_str end, x=0, y=15, font=FS.FONT_16 ,color=txtColor},
        }}
    })

    -- rpm
    pMain:build({{type="box", x=145, y=0,
        children={
            {type="label", text="Head Speed",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.rpm_str end, x=0, y=15, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- capacity
    local bCapa = pMain:box({x=5, y=145})
    bCapa:label({text=function() return string.format("Capacity (Total: %s)", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    lib_blackbox_horz.build_ui(bCapa, wgt,
        {x=0, y=17,w=280,h=40,segments_w=20, color=WHITE, bg_color=BLACK, cath_w=10, cath_h=30, segments_h=20, cath=false},
        function(wgt) return wgt.values.capaPercent end,
        function(wgt) return wgt.values.capaColor end
    )
    bCapa:label({x=25,  y=16, font=FS.FONT_16 ,color=WHITE, text=function() return wgt.values.capaPercent_txt end})
    bCapa:label({x=110, y=22, font=FS.FONT_12 ,color=WHITE, text=function() return string.format("(%.02fv)", wgt.values.volt) end})
    -- bCapa:label({x=5, y=18, font=FS.FONT_8 ,color=WHITE, text=function() return string.format("%dmah", wgt.values.capaTotal) end})
    bCapa:label({text=function() return string.format("used:\n%dmah", wgt.values.capaUsed or 0) end, x=220, y=20, font=FS.FONT_6 ,color=WHITE})


    -- current
    local g_rad = 40
    local g_thick = 8--11
    local gm_rad = g_rad-10
    local gm_thick = 8
    local g_y = 55
    local g_angel_min = 140
    local g_angel_max = 400
    local function calEndAngle(percent)
        if percent==nil then return 0 end
        local v = ((percent/100) * (g_angel_max-g_angel_min)) + g_angel_min
        return v
    end

    local bCurr = pMain:box({x=2, y=g_y})
    bCurr:label({text="Current",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    bCurr:label({x=35, y=40, text=function() return wgt.values.curr_str end, font=FS.FONT_8, color=txtColor})
    bCurr:label({x=30, y=65, text=function() return wgt.values.curr_max_str end, font=FS.FONT_8, color=txtColor})
    bCurr:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=g_angel_max, rounded=true, color=lcd.RGB(0x222222)})
    -- bCurr:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.curr_max_percent) end, color=lcd.RGB(0xFF623F), opacity=180})
    bCurr:arc({x=50, y=50, radius=gm_rad, thickness=gm_thick, startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.curr_max_percent) end, color=lcd.RGB(0xFF623F), opacity=180})
    bCurr:arc({x=50, y=50, radius=g_rad , thickness=g_thick,  startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.curr_percent)     end, color=lcd.RGB(0xFF623F)})

    -- thr
    local bThr = pMain:box({x=2+2*g_rad+10, y=g_y })
    bThr:label({text="thr",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    bThr:label({x=35, y=40, text=function() return string.format("%s%%", wgt.values.thr)      end, font=FS.FONT_8, color=txtColor})
    bThr:label({x=35, y=65, text=function() return string.format("+%s%%", wgt.values.thr_max) end, font=FS.FONT_8, color=txtColor})
    bThr:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=g_angel_max, color=lcd.RGB(0x222222)})
    bThr:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.thr_max) end, color=lcd.RGB(0xFFA72C), opacity=80})
    bThr:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.thr)     end, color=lcd.RGB(0xFFA72C)})

    -- temp
    local bTemp = pMain:box({x=2+4*g_rad+20, y=g_y})
    bTemp:label({text="temp",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    bTemp:label({x=35, y=40, text=function() return (wgt.values.EscT_str or "--°c") end, font=FS.FONT_8, color=txtColor})
    bTemp:label({x=35, y=65, text=function() return (wgt.values.EscT_max_str or "--°c") end, font=FS.FONT_8, color=txtColor})
    bTemp:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=g_angel_max, color=lcd.RGB(0x222222)})
    -- bTemp:arc({x=50, y=50, radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.EscT_max_percent) end, color=lcd.RGB(0x1F96C2), opacity=180})
    bTemp:arc({x=50, y=50, radius=gm_rad, thickness=gm_thick, startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.EscT_max_percent) end, color=lcd.RGB(0x1F96C2), opacity=180})
    bTemp:arc({x=50, y=50, radius=g_rad,  thickness=g_thick,  startAngle=g_angel_min, endAngle=function() return calEndAngle(wgt.values.EscT_percent)     end, color=lcd.RGB(0x1F96C2)})

    -- image
    local isizew=150
    local isizeh=100
    local bImageArea = pMain:box({x=330, y=5})
    -- bImageArea:rectangle({x=0, y=0, w=isizew, h=isizeh, thickness=4, rounded=15, filled=false, color=GREY})
    bImageArea:image({x=0, y=0, w=isizew, h=isizeh, fill=false,
        file=function()
            return wgt.values.img_craft_image_name
        end
    })

    -- flights count
    pMain:build({{type="box", x=340, y=105,
                    -- pos= function() return dbgx, dbgy end,
        children={
            {type="label", text=function() return string.format("%s Flights", wgt.values.model_total_flights or "000") end , x=0, y=0, font=FS.FONT_6 ,color=lcd.RGB(0x999999)},
            -- {type="label", text="Flights: ", x=50, y=2, font=FS.FONT_6, color=lcd.RGB(0x999999)},
        }
    }})
    -- air time
    pMain:build({{type="box", x=420, y=105,
        children={
            -- {type="label", text="Air Time: ", x=0, y=2, font=FS.FONT_6, color=lcd.RGB(0x999999)},
            -- {type="label", text=function() return wgt.values.model_total_time_str or "---" end , x=55, y=0, font=FS.FONT_6 ,color=lcd.RGB(0x999999)},
            {type="label", text=function() return string.format("%s Min", wgt.values.model_total_time_str or "---") end , x=0, y=0, font=FS.FONT_6 ,color=lcd.RGB(0x999999)},
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

    -- no connection
    pMain:build({{type="box", x=330, y=10, visible=function() return wgt.is_connected==false end,
        children={
            {type="rectangle", x=5, y=10, w=isizew-10, h=isizeh-20, rounded=15, filled=true, opacity=250, color=BLACK},
            {type="image", x=30, y=0, w=90, h=90, file=baseDir.."/img/no_connection_wr.png"},
            {type="label", x=10, y=70, text=function() return wgt.not_connected_error end , font=FS.FONT_8, color=WHITE},
        }
    }})


    -- app_ver
    pMain:build({{type="box", x=LCD_W -50, y=LCD_H -80,
        children={
            {type="label", text=function() return string.format("v: %s", wgt.app_ver) end , x=0, y=0, font=FS.FONT_6 ,color=lcd.RGB(0x999999)},
        }
    }})

    -- status bar
    wgt.statusbar.init("VenbS & Shmuely", {
        {name="LQ-:",   ftxt=function() return string.format("LQ: %s/%s%%",         wgt.values.link_rqly,   wgt.values.link_rqly_min) end, color=GREEN, error_color=RED, error_cond=function() return (wgt.values.link_rqly < 80) end },
        {name="VBec-:", ftxt=function() return string.format("VBec: %0.1f/%0.1fV",  wgt.values.vbec,        wgt.values.vbec_min     ) end, color=GREEN, error_color=RED, error_cond=function() return wgt.tlmEngine.sensorTable.bec_voltage.isWarn() end },
        {name="Curr+:", ftxt=function() return string.format("A: %d/%dA",           wgt.values.curr,        wgt.values.curr_max     ) end},
        {name="TPwr+:", ftxt=function() return string.format("TPwr+: %smW",         wgt.values.link_tx_power_max                    ) end},
        {name="Thr+:",  ftxt=function() return string.format("Thr+: %s%%",          wgt.values.thr_max                              ) end},
    })
    wgt.statusbar.build_ui(pMain, wgt)

end

M.refresh = function(wgt, event, touchState)
    wgt.statusbar.refresh()
end

return M

