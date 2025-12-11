local app_name = "RF2-dashboards"

local baseDir = "/SCRIPTS/RF2-dashboards/"
local inSimu = string.sub(select(2,getVersion()), -4) == "simu"

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local lib_blackbox_horz = assert(loadScript(baseDir .. "/widgets/parts/blackbox_horz.lua"))()

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

    -- -- craft name
    -- local pCraftName = pMain:box({x=160, y=160})
    -- pCraftName:label({text="Heli Name",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    -- pCraftName:label({text=function() return wgt.values.craft_name end,  x=0, y=15, font=FS.FONT_12 ,color=txtColor})

    -- pid profile (bank)
    pMain:build({{type="box", x=0, y=0,
        children={
            -- {type="rectangle", x=0, y=0, w=40, h=50, color=YELLOW},
            {type="label", text="Profile", x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="label", text=function() return wgt.values.profile_id_str end , x=6, y=10, font=FS.FONT_16 ,color=txtColor},
        }
    }})

    -- rate profile
    pMain:build({{type="box", x=44, y=0,
        children={
            -- {type="rectangle", x=0, y=0, w=40, h=50, color=YELLOW},
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
    local bCurr = pMain:box({x=350, y=110})
    bCurr:label({text="Current",  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})
    -- bCurr:label({text=function() return wgt.values.curr_str end, x=0, y=12, font=FS.FONT_16 ,color=function() return (wgt.values.curr < 100) and YELLOW or RED end },
    bCurr:label({text=function() return wgt.values.curr_str end, x=0, y=12, font=FS.FONT_16 ,color=txtColor})

    -- -- governor
    -- pMain:build({{type="box", x=10, y=186,
    --      children={
    --          -- {type="label", text="RPM",  x=25, y=0, font=FS.FONT_6, color=WHITE},
    --          {type="label", text=function() return wgt.values.governor_str end, x=0, y=0, font=FS.FONT_6 ,color=WHITE},
    --      }
    -- }})

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
    bArm:label({x=22, y=11, text=function() return wgt.values.is_arm and "ARM" or "Not Armed" end, font=FS.FONT_12 ,
        color=function()
            if wgt.options.guiStyle==2 then
                return wgt.values.is_arm and RED or GREEN
            else
                return wgt.options.textColor
            end
        end
    })

    -- status bar
    local bStatusBar = pMain:box({x=0, y=wgt.zone.h-20})
    local statusBarColor = lcd.RGB(0x0078D4)
    bStatusBar:rectangle({x=0, y=0,w=wgt.zone.w, h=20, color=statusBarColor, filled=true})
    bStatusBar:rectangle({x=25, y=0,w=70, h=20, color=RED, filled=true, visible=function() return (wgt.values.rqly_min < 80) end })
    bStatusBar:label({x=3  , y=2, text=function() return string.format("elrs RQly-: %s%%", wgt.values.rqly_min) end, font=function() return (wgt.values.rqly_min >= 80) and FS.FONT_6 or FS.FONT_6  end, color=WHITE})
    bStatusBar:label({x=120, y=2, text=function() return string.format("TPwr+: %smw", getValue("TPWR+")) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=230, y=2, text=function() return string.format("VBec-: %sv", getValue("Vbec-")) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=300, y=2, text=function() return string.format("Thr+: %s%%", wgt.values.thr_max) end, font=FS.FONT_6, color=WHITE})
    bStatusBar:label({x=425, y=2, text="Shmuely", font=FS.FONT_6, color=YELLOW})
    -- bStatusBar:label({x=390, y=2, text=rf2.LUA_VERSION, font=FS.FONT_6, color=WHITE})

    -- image
    local isizew=150
    local isizeh=100
    local bImageArea = pMain:box({x=330, y=5})
    bImageArea:rectangle({x=0, y=0, w=isizew, h=isizeh, thickness=4, rounded=15, filled=false, color=GREY})
    local bImg = bImageArea:box({})
    bImageArea:image({x=0, y=0, w=isizew, h=isizeh, fill=false,
        file=function()
            return "/IMAGES/".. wgt.values.img_craft_name_for_image .. ".png"
        end
    })


    -- craft name
    local bCraftName = pMain:box({x=330, y=60})
    bCraftName:rectangle({x=10, y=20, w=isizew-20, h=20, filled=true, rounded=8, color=DARKGREY, opacity=200})
    bCraftName:label({text=function() return wgt.values.craft_name end,  x=15, y=20, font=FS.FONT_8 ,color=txtColor})

    -- failed to arm flags
    local bFailedArmFlags = pMain:box({x=100, y=25, visible=function() return wgt.values.arm_fail end})
    bFailedArmFlags:rectangle({x=0, y=0, w=280, h=150, color=RED, filled=true, rounded=8, opacity=245})
    bFailedArmFlags:label({text=function()
        return string.format("%s (%s)", wgt.values.arm_disable_flags_txt, wgt.values.arm_fail)
    end, x=10, y=0, font=FS.FONT_8, color=WHITE})

    -- no connection
    local bNoConn = lvgl.box({x=330, y=10, visible=function() return wgt.is_connected==false end})
    bNoConn:rectangle({x=5, y=10, w=isizew-10, h=isizeh-10, rounded=15, filled=true, color=BLACK, opacity=250})
    bNoConn:label({x=10, y=80, text=function() return wgt.not_connected_error end , font=FS.FONT_8, color=WHITE})
    bNoConn:image({x=30, y=0, w=90, h=90, file=baseDir.."widgets/img/no_connection_wr.png"})

end

return M

