local app_name = "rf2_capacity"

local baseDir = "/SCRIPTS/RF2-dashboards/"
local build_gui

--------------------------------------------------------------
local function log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
    return
end
--------------------------------------------------------------

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

-----------------------------------------------------------------------------------------------------------------

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options

    wgt.values = {
        capaTotal = -1,
        capaUsed = -1,
        capaPercent = -1,
    }

    build_gui(wgt)
    return wgt
end

local function create(zone, options)
    local wgt = {

    }
    wgt.zone = zone
    wgt.options = options
    return update(wgt, options)
end
-----------------------------------------------------------------------------------------------------------------

local function buildBlackboxHorz(parentBox, wgt, myBatt, fPercent, getPercentColor)
    local percent = fPercent(wgt)
    local r = 30
    local fill_color = myBatt.bar_color or GREEN
    local fill_color= (getPercentColor~=nil) and getPercentColor(wgt, percent) or GREEN
    local tw = 4
    local th = 4

    -- local box = lvgl.box({x=myBatt.x, y=myBatt.y})
    -- local box = lvgl.box({x=100, y=100})
    -- box:rectangle({x=0, y=0, w=myBatt.w, h=myBatt.h, color=myBatt.bg_color, filled=true, rounded=8, thickness=4})
    -- lvgl.rectangle(box, {w=myBatt.w, h=myBatt.h, color=myBatt.bg_color, filled=true, rounded=8, thickness=4})
    -- box:rectangle({w=myBatt.w, h=myBatt.h, color=myBatt.bg_color, filled=true, rounded=8, thickness=4})

    -- local box2 = lvgl.box({x=200, y=100})
    -- lvgl.rectangle(box2, {x=0, y=0, w=30, h=30, color=BLUE, filled=false, rounded=8, thickness=2})

    local box = parentBox:box({x=myBatt.x, y=myBatt.y})
    box:rectangle({x=0, y=0, w=myBatt.w, h=myBatt.h, color=myBatt.bg_color, filled=true, rounded=6, thickness=8})
    box:rectangle({x=0, y=0, w=myBatt.w, h=myBatt.h, color=WHITE, filled=false, thickness=myBatt.fence_thickness or 3, rounded=8})
    box:rectangle({x=5, y=5,
        -- w=0, h=myBatt.h,
        filled=true, rounded=4,
        size =function() return math.floor(fPercent(wgt) / 100 * myBatt.w)-10, myBatt.h-10 end,
        color=function() return getPercentColor(wgt, percent) or GREEN end,
    })
    -- draw battery segments
    -- for i=0, myBatt.w, myBatt.segments_w do
    --     box:rectangle({x=i, y=0, w=1, h=myBatt.h, color=LIGHTGREY, filled=true})
    -- end

    -- -- draw plus terminal
    -- if myBatt.cath==true then
    --     box:rectangle({ x=myBatt.w,
    --         y=myBatt.h /2 - myBatt.cath_h /2 + th /2,
    --         w=myBatt.cath_w,
    --         h=myBatt.cath_h,
    --         color=BLUE, filled=true, rounded=1,
    --         -- visible=myBatt.cath -- bug, should support bool
    --     })
    --     box:rectangle({ x=myBatt.w + tw,
    --             y=myBatt.h /2 - myBatt.cath_h /2 + th,
    --             w=myBatt.cath_w,
    --             h=myBatt.cath_h,
    --             color=RED, filled=true, rounded=1,
    --             -- visible=myBatt.cath
    --     })
    -- end

    return box
end

build_gui = function(wgt)
    if (wgt == nil) then log("refresh(nil)") return end
    if (wgt.options == nil) then log("refresh(wgt.options=nil)") return end

    lvgl.clear()

    local isOnTop = wgt.zone.h < 60 --and wgt.zone.w < 120
    if isOnTop then
        -- global
        -- lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=lcd.RGB(0x111111), filled=true})
        local pMain = lvgl.box({x=0, y=0})

        -- capacity
        local bCapa = pMain:box({type="box", x=0, y=0})
        bCapa:label({text=function() return string.format("Capacity", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_6, color=wgt.options.text_color})
        buildBlackboxHorz(bCapa, wgt,
            {x=0, y=20,w=wgt.zone.w-20,h=wgt.zone.h-20,segments_w=5, color=WHITE, bg_color=GREY, cath_w=10, cath_h=80, segments_h=20, cath=false, fence_thickness=1},
            function(wgt) return wgt.values.capaPercent end,
            function(wgt) return wgt.values.capaColor end
        )
        -- bCapa:label({text=function() return string.format("%d%%", wgt.values.capaPercent) end, x=25, y=16, font=FS.FONT_16 ,color=WHITE})

    else
        -- global
        -- lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=lcd.RGB(0x111111), filled=true})
        local pMain = lvgl.box({x=10, y=10})

        -- capacity
        local bCapa = pMain:box({type="box", x=0, y=0})
        bCapa:label({text=function() return string.format("Capacity (Total: %s)", wgt.values.capaTotal) end,  x=0, y=0, font=FS.FONT_8, color=wgt.options.text_color})
        buildBlackboxHorz(bCapa, wgt,
            {x=0, y=25,w=140,h=35,segments_w=20, color=WHITE, bg_color=GREY, cath_w=10, cath_h=30, segments_h=20, cath=false, fence_thickness=2},
            function(wgt) return wgt.values.capaPercent end,
            function(wgt) return wgt.values.capaColor end
        )
        bCapa:label({text=function() return string.format("%d%%", wgt.values.capaPercent) end, x=25, y=30, font=FS.FONT_8 ,color=wgt.options.text_color})
        -- bCapa:label({text=function() return string.format("%dmah", wgt.values.capaTotal) end, x=5, y=18, font=FS.FONT_8 ,color=WHITE})
    end

end

local function updateCapa(wgt)
    -- capacity
    wgt.values.capaTotal = rf2fc.msp.cache.mspBatteryConfig.batteryCapacity or -1
    wgt.values.capaUsed = getValue("Capa")

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
end

local function background(wgt)
end

local function refresh(wgt)
    local is_avail, err = false, "no RF2_Server widget found"
    if rf2fc ~= nil and rf2fc.mspCacheTools ~= nil then
        is_avail, err = rf2fc.mspCacheTools.isCacheAvailable()
    end

    if is_avail == false then
        return
    end
    wgt.mspTool = rf2fc.mspCacheTools

    updateCapa(wgt)

end

return {create=create, update=update, background=background, refresh=refresh, }
