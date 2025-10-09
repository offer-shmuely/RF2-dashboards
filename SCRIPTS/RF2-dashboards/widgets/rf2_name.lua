local app_name = "rf2_name"

local baseDir = "/SCRIPTS/RF2-dashboards/"

--------------------------------------------------------------
local function log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
    return
end
--------------------------------------------------------------

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

-----------------------------------------------------------------------------------------------------------------
local function background(wgt)
end

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options
    return wgt
end

local function create(zone, options)
    local wgt = {
        zone = zone,
        options = options,
    }
    return update(wgt, options)
end
-----------------------------------------------------------------------------------------------------------------

local function refresh(wgt)
    local is_avail, err = false, "no RF2_Server widget found"
    if rf2fc ~= nil and rf2fc.mspCacheTools ~= nil then
        is_avail, err = rf2fc.mspCacheTools.isCacheAvailable()
    end

    if is_avail == false then
        lcd.drawText(10 ,0, err, FS.FONT_8 + LIGHTGREY)
        -- lcd.drawText(10 ,0, "---------", FS.FONT_8 + RED)
        return
    end

    local craftName = rf2fc.msp.cache.mspName or "---"

    lcd.drawText(10 ,0, craftName, FS.FONT_12 + wgt.options.text_color)
end

return {name=app_name, create=create, update=update, background=background, refresh=refresh}
