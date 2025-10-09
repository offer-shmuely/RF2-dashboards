local app_name = "rf2_dbg"

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

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options
    return wgt
end

local function create(zone, options)
    local wgt = {zone = zone,options = options,}
    return update(wgt, options)
end
-----------------------------------------------------------------------------------------------------------------

local function tableToString(tbl)
    if (tbl == nil) then return "---" end
    local result = {}
    for key, val in pairs(tbl) do
        -- log("444444444444444 %s: %s", tostring(key), tostring(val))
        if type(val) == "table" then
            val = val.value
        end
        log("555555555555555 %s: %s", tostring(key), tostring(val))
        table.insert(result, string.format("%s: %s", tostring(key), tostring(val)))
    end
    return table.concat(result, "\n")
end


local function refresh(wgt)
    local is_avail, err = wgt.mspTool.isCacheAvailable()
    if is_avail == false then
        lcd.drawText(10 ,0, err, FS.FONT_8 + RED)
        return
    end

    local type
    if wgt.options.type == 1 then
        type = "mspBatteryState"
    elseif wgt.options.type == 2 then
        type = "mspBatteryConfig"
    elseif wgt.options.type == 3 then
        type = "mspDataflash"
    elseif wgt.options.type == 4 then
        type = "mspName"
    elseif wgt.options.type == 5 then
        type = "mspStatus"
    elseif wgt.options.type == 6 then
        type = "mspVersion"
    elseif wgt.options.type == 7 then
        type = "mspRescueProfile"
    end
    local txt = tableToString(rf2fc.msp.cache[type])

    lcd.drawText(10 ,0, type, FS.FONT_8)
    lcd.drawText(10 ,20, txt, FS.FONT_6)
end

return {name=app_name, create=create, update=update, refresh=refresh}
