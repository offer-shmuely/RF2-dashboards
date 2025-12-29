local app_name = "RF2-dashboards"

local baseDir = "/SCRIPTS/RF2-dashboards/"
local inSimu = string.sub(select(2,getVersion()), -4) == "simu"

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local lib_blackbox_horz = assert(loadScript(baseDir .. "/widgets/parts/blackbox_horz.lua", "btd"))()

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
    pMain:build({{type="box", x=0, y=0,
        children={
            {type="label", text="Profile", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.profile_id_str end , x=6, y=10, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- rate profile
    pMain:build({{type="box", x=44, y=0,
        children={
            {type="label", text="Rate", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.rate_id_str end , x=2, y=10, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- batt profile
    -- pMain:build({{type="box", x=86, y=0,
    --     children={
    --         {type="label", text="Batt", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
    --         {type="label", text=function() return "1" end , x=2, y=10, font=FS.FONT_16 ,color=txtColor},
    --     }
    -- }})

    -- time
    pMain:build({
        {type="box", x=140, y=50, children={
            {type="label", text=function() return wgt.values.timer_str end, x=0, y=0, font=FS.FONT_38 ,color=txtColor},
        }}
    })

    -- rpm
    pMain:build({{type="box", x=185, y=115,
        children={
            {type="label", text="RPM",  x=25, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.rpm_str end, x=0, y=10, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- voltage
    local bVolt = pMain:box({x=5, y=45})
    bVolt:label({text="Battery", x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    bVolt:label({text=function() return string.format("%.02fv", wgt.values.volt) end , x=0, y=12, font=FS.FONT_16 ,color=txtColor})
    lib_blackbox_horz.build_ui(bVolt, wgt,
        {x=0, y=48,w=110,h=25,segments_w=20, color=WHITE, bg_color=GREY, cath_w=10, cath_h=8, segments_h=20, cath=true, fence_thickness=1},
        function(wgt) return wgt.values.cell_percent end,
        function(wgt) return wgt.values.cellColor end
    )

    -- capacity
    local bCapa = pMain:box({type="box", x=5, y=145})
    bCapa:label({text=function() return string.format("Capacity (Total: %s)", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    lib_blackbox_horz.build_ui(bCapa, wgt,
        {x=0, y=17,w=280,h=40,segments_w=20, color=WHITE, bg_color=GREY, cath_w=10, cath_h=30, segments_h=20, cath=false},
        function(wgt) return wgt.values.capaPercent end,
        function(wgt) return wgt.values.capaColor end
    )
    bCapa:label({text=function() return wgt.values.capaPercent_txt end, x=25, y=16, font=FS.FONT_16 ,color=WHITE})
    bCapa:label({text=function() return string.format("used:\n%dmah", wgt.values.capaUsed or 0) end, x=220, y=20, font=FS.FONT_6 ,color=WHITE})

    -- bCapa:label({text=function() return string.format("%dmah", wgt.values.capaTotal) end, x=5, y=18, font=FS.FONT_8 ,color=WHITE})

    -- current
    local bCurr = pMain:box({x=350, y=155})
    bCurr:label({text="Current",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    -- bCurr:label({text=function() return wgt.values.curr_str end, x=0, y=12, font=FS.FONT_16 ,color=function() return (wgt.values.curr < 100) and YELLOW or RED end },
    bCurr:label({text=function() return wgt.values.curr_str end, x=0, y=12, font=FS.FONT_16 ,color=txtColor})


    -- blackbox
    -- local bBB = pMain:box({type="box", x=350, y=160, visible=function() return wgt.values.bb_enabled end})
    -- bBB:label({text=function() return wgt.values.bb_txt end,  x=0, y=0, font=FS.FONT_6, color=function() return (wgt.values.bb_percent < 90) and titleGreyColor or RED end })
    -- buildBlackboxHorz(bBB, wgt,
    --     {x=0, y=18,w=110,h=20,segments_w=10, color=WHITE, bg_color=GREY, cath_w=10, cath_h=80, segments_h=20, cath=false, fence_thickness=2},
    --     function(wgt) return wgt.values.bb_percent end,
    --     function(wgt) return wgt.values.bbColor end
    -- )
    -- bBB:label({text=function() return string.format("%s%%", wgt.values.bb_percent) end, x=20, y=20, font=FS.FONT_8 ,color=WHITE})

    -- arm
    local bArm = pMain:box({x=140, y=5})
    bArm:label({x=22, y=5, text=function() return wgt.values.is_arm and "ARM" or "Not Armed" end, font=FS.FONT_12 ,
        color=function()
            if wgt.options.guiStyle==2 then
                return wgt.values.is_arm and RED or GREEN
            else
                return wgt.options.textColor
            end
        end
    })
    bArm:label({x=22, y=28, text=function() return wgt.values.flight_stage_str end, font=FS.FONT_8,
        color=WHITE
    })

    -- status bar
    local bStatusBar = pMain:box({x=0, y=wgt.zone.h-20})
    local statusBarColor = lcd.RGB(0x0078D4)
    bStatusBar:rectangle({x=0, y=0,w=wgt.zone.w, h=20, color=statusBarColor, filled=true})
    bStatusBar:rectangle({x=25, y=0,w=70, h=20, color=RED, filled=true, visible=function() return (wgt.values.link_rqly < 80) end })
    bStatusBar:label({x=3  , y=2, text=function() return string.format("elrs RQly-: %s%%", wgt.values.link_rqly_min) end, font=function() return (wgt.values.link_rqly >= 80) and FS.FONT_6 or FS.FONT_6  end, color=WHITE})
    bStatusBar:label({x=120, y=2, text=function() return string.format("TPwr+: %smw", wgt.values.link_tx_power_max) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=230, y=2, text=function() return string.format("VBec-: %sv", wgt.values.vbec_min) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=300, y=2, text=function() return string.format("Thr+: %s%%", wgt.values.thr_max) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=425, y=2, text="Shmuely", font=FS.FONT_6, color=YELLOW})

    -- image
    local isizew=150
    local isizeh=100
    local bImageArea = pMain:box({x=330, y=5})
    bImageArea:rectangle({x=0, y=0, w=isizew, h=isizeh, thickness=4, rounded=15, filled=false, color=GREY})
    bImageArea:image({x=0, y=0, w=isizew, h=isizeh, fill=false,
        file=function()
            return wgt.values.img_last_name
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
            {type="image", x=30, y=0, w=90, h=90, file=baseDir.."widgets/img/no_connection_wr.png"},
            {type="label", x=10, y=70, text=function() return wgt.not_connected_error end , font=FS.FONT_8, color=WHITE},
        }
    }})

    pMain:build({{type="box", x=0, y=0, visible=function() return dbg_layout_enabled end,
        children={
            {type="label", x=300, y=190, text=function() return string.format("dbgX: %d, dbgY: %d", dbgx, dbgy) end, font=FS.FONT_6, color=YELLOW},
                -- lcd.drawText(400,0, string.format("%sx%s", dbgx, dbgy), FS.FONT_8 + WHITE)
        }
    }})


end

return M

