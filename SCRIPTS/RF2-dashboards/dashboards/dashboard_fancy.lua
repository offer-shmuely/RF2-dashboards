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

local M = {
    name = "fancy",
    is_need_capa_audio = true,
}

local function lvglHPercent(p)
    return math.floor(p * LCD_W/100)
end
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
    lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=lcd.RGB(0x111111), filled=true})

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

    -- pid profile (bank)
    pMain:box({x=0, y=0,
        children={
            {type="label", text="Profile", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.profile_id_str end , x=6*lvSCALE, y=10*lvSCALE, font=FS.FONT_16 ,color=txtColor},
        }
    })

    -- rate profile
    pMain:box({x=44*lvSCALE, y=0,
        children={
            {type="label", text="Rate", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.rate_id_str end , x=2*lvSCALE, y=10*lvSCALE, font=FS.FONT_16 ,color=txtColor},
        }
    })

    -- batt profile
    -- pMain:box({x=86, y=0,
    --     children={
    --         {type="label", text="Batt", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
    --         {type="label", text=function() return "1" end , x=2, y=10, font=FS.FONT_16 ,color=txtColor},
    --     }
    -- }})

    -- voltage
    local bVolt = pMain:box({x=5*lvSCALE, y=45*lvSCALE})
    bVolt:label({text="Battery", x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    bVolt:label({text=function() return string.format("%.02fv", wgt.values.volt) end , x=0, y=12*lvSCALE, font=FS.FONT_16 ,color=txtColor})
    lib_blackbox_horz.build_ui(bVolt, wgt,
        {x=0, y=48*lvSCALE,w=110*lvSCALE,h=25*lvSCALE,segments_w=20, color=WHITE, bg_color=GREY, cath_w=10, cath_h=8, segments_h=20, cath=true, fence_thickness=1},
        function(wgt) return wgt.values.cell_percent end,
        function(wgt) return wgt.values.cellColor end
    )

    -- capacity
    local bCapa = pMain:box({x=5*lvSCALE, y=is800 and 250 or 145})
    bCapa:label({text=function() return string.format("Capacity (Total: %s)", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    lib_blackbox_horz.build_ui(bCapa, wgt,
        {x=0, y=17*lvSCALE,w=300*lvSCALE,h=40*lvSCALE,segments_w=20, color=WHITE, bg_color=GREY, cath_w=10, cath_h=30, segments_h=20, cath=false},
        function(wgt) return wgt.values.capaPercent end,
        function(wgt) return wgt.values.capaColor end
    )
    bCapa:label({text=function() return string.format("%d%%", wgt.values.capaPercent) end, x=25*lvSCALE, y=16*lvSCALE, font=FS.FONT_16 ,color=WHITE})
    bCapa:label({text=function() return string.format("used:\n%dmah", wgt.values.capaUsed or 0) end, x=220*lvSCALE, y=20*lvSCALE, font=FS.FONT_6 ,color=WHITE})
    -- bCapa:label({text=function() return string.format("%dmah", wgt.values.capaTotal) end, x=5, y=18, font=FS.FONT_8 ,color=WHITE})

    -- arm
    pMain:box({x=140*lvSCALE, y=5*lvSCALE,
        children={
            {type="label", x=22*lvSCALE, y=5*lvSCALE, font=FS.FONT_12,
                text=function() return wgt.values.is_arm and "ARM" or "Not Armed" end,
                color=function()
                    return wgt.values.is_arm and RED or GREEN
                    -- return wgt.options.textColor
                end
            },
            {type="label", x=22*lvSCALE, y=30*lvSCALE, color=titleGreyColor, font=FS.FONT_6, text=function() return wgt.values.flight_stage_str end},
        }
    })

    -- time
    pMain:box({x=140*lvSCALE, y=50*lvSCALE,
        children={
            {type="label", text=function() return wgt.values.timer_str end, x=0, y=0, font=FS.FONT_38 ,color=txtColor},
        }
    })

    -- rpm
    pMain:box({x=185*lvSCALE, y=115*lvSCALE,
        children={
            {type="label", text="RPM",  x=25*lvSCALE, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return string.format("%s",wgt.values.rpm) end, x=0, y=10*lvSCALE, font=FS.FONT_16 ,color=txtColor},
        }
    })

    -- image
    local isizew=is800 and 340 or 150
    local isizeh=is800 and 200 or 100
    pMain:box({x=330*lvSCALE, y=5*lvSCALE, visible=function() return wgt.is_connected==true end,
        children={
            -- {type="rectangle", x=0, y=0, w=isizew, h=isizeh, thickness=4, rounded=15, filled=false, color=GREY},
            {type="image", x=0, y=0, w=isizew, h=isizeh, fill=false, file=function() return wgt.values.img_craft_image_name end},
            -- craft name
            {type="rectangle", x=6*lvSCALE, y=isizeh-25*lvSCALE, w=isizew-20, h=20*lvSCALE, filled=true, rounded=8*lvSCALE, color=DARKGREY, opacity=200},
            {type="label", text=function() return wgt.values.craft_name end,  x=15*lvSCALE, y=isizeh-25*lvSCALE, font=FS.FONT_8 ,color=txtColor},
            -- flights count
            {type="label", x=8*lvSCALE, y=isizeh+10*lvSCALE, font=FS.FONT_8, color=lcd.RGB(0x999999),
                text=function() return string.format("%s Flights", wgt.values.model_total_flights or "000") end,
            },
        }
    })

    -- current
    pMain:box({x=340*lvSCALE, y=isizeh+40*lvSCALE,
        -- pos=function() return wgt.dbgx*lvSCALE, wgt.dbgy*lvSCALE end,
        children={
            {type="label", text="Current",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return string.format("%dA", wgt.values.curr) end, x=0, y=12*lvSCALE, font=FS.FONT_16 ,color=txtColor},
        }
    })

    -- failed to arm flags
    pMain:box({x=100*lvSCALE, y=25*lvSCALE, visible=function() return wgt.values.arm_fail end,
        children={
            {type="rectangle", x=0, y=0, w=280*lvSCALE, h=150*lvSCALE, color=RED, filled=true, rounded=8*lvSCALE, opacity=245},
            {type="label", text=function()
                return string.format("Arming not allowed: \n%s", wgt.values.arm_disable_flags_txt)
            end, x=10*lvSCALE, y=0, font=FS.FONT_8, color=WHITE},
        }
    })

    -- no connection
    pMain:box({x=330*lvSCALE, y=5*lvSCALE, visible=function() return wgt.is_connected==false end,
        children={
            {type="rectangle", x=0, y=0, w=isizew, h=isizeh, rounded=15*lvSCALE, filled=true, opacity=250, color=BLACK},
            {type="image",     x=0, y=0, w=isizew, h=isizeh, file=baseDir.."/img/no_connection_wr.png"},
            {type="label",     x=10*lvSCALE, y=70*lvSCALE, text=function() return wgt.not_connected_error end , font=FS.FONT_8, color=WHITE},
        }
    })

    pMain:box({x=0, y=0, visible=function() return wgt.dbg_layout_enabled end,
        children={
            {type="label", x=300*lvSCALE, y=190*lvSCALE, text=function() return string.format("dbgX: %d, dbgY: %d", wgt.dbgx, wgt.dbgy) end, font=FS.FONT_6, color=YELLOW},
        }
    })

    -- app_ver
    pMain:box({x=LCD_W -46*lvSCALE, y=LCD_H -82*lvSCALE,
        children={
            {type="label", text=function() return string.format("v%s", wgt.app_ver) end , x=0, y=0, font=FS.FONT_6 ,color=lcd.RGB(0x999999)},
        }
    })

    -- status bar
    wgt.statusbar.init("Shmuely", {
        {name="LQ-:",   ftxt=function() return string.format("LQ: %s/%s%%",         wgt.values.link_rqly,   wgt.values.link_rqly_min) end, color=GREEN, error_color=RED, error_cond=function() return wgt.values.link_rqly_min<80 end },
        {name="VBec-:", ftxt=function() return string.format("VBec: %0.1f/%0.1fV",  wgt.values.v_rx,        wgt.values.v_rx_min     ) end, color=GREEN, error_color=RED, error_cond=function() return wgt.tlmEngine.sensorTable.rx_voltage.isWarn() end },
        {name="Curr+:", ftxt=function() return string.format("A: %d/%dA",           wgt.values.curr,        wgt.values.curr_max     ) end},
        {name="TPwr+:", ftxt=function() return string.format("TPwr+: %smw",         wgt.values.link_tx_power_max                    ) end},
        {name="Thr+:",  ftxt=function() return string.format("Thr+: %s%%",          wgt.values.thr_max                              ) end},
    })
    wgt.statusbar.build_ui(pMain, wgt)

end

M.refresh = function(wgt, event, touchState)
    wgt.statusbar.refresh()
end

return M

