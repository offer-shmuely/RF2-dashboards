local app_name = "RF2-dashboards"

local baseDir = "/SCRIPTS/RF2-dashboards/"
local inSimu = string.sub(select(2,getVersion()), -4) == "simu"

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local lib_blackbox_horz = assert(rf2.loadScript("/widgets/parts/blackbox_horz.lua"))()

local M = {}

M.build_ui = function(wgt)
    if (wgt == nil) then log("refresh(nil)") return end
    if (wgt.options == nil) then log("refresh(wgt.options=nil)") return end
    local txtColor = wgt.options.textColor
    local titleGreyColor = LIGHTGREY

    lvgl.clear()

    -- global
    lvgl.rectangle({x=0, y=0, w=wgt.zone.w, h=wgt.zone.h, color=lcd.RGB(0x111111), filled=true})

    -- capacity
    local bCapa = lvgl.box({x=0, y=0})
    bCapa:label({text=function() return string.format("Capacity (Total: %s)", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor})

    lib_blackbox_horz.build_ui(bCapa, wgt,
        {x=10, y=17, w=wgt.zone.w-20, h=wgt.zone.h-17-10, segments_w=20, color=WHITE, bg_color=GREY, cath_w=10, cath_h=30, segments_h=20, cath=false},
        function(wgt) return wgt.values.capaPercent end,
        function(wgt) return wgt.values.capaColor end
    )
    bCapa:label({text=function() return wgt.values.capaPercent_txt end, x=25, y=16, font=FS.FONT_16 ,color=WHITE})
    bCapa:label({text=function() return string.format("used:\n%dmah", wgt.values.capaUsed or 0) end, x=wgt.zone.w-70, y=20, font=FS.FONT_6 ,color=WHITE})

    -- bCapa:label({text=function() return string.format("%dmah", wgt.values.capaTotal) end, x=5, y=18, font=FS.FONT_8 ,color=WHITE})

end


return M

