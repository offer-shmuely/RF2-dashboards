local app_name = "rf2_pids_list"

local baseDir = "/SCRIPTS/RF2-dashboards/"
local build_gui



local wgt = {
    values = {
        profile_id = -1,
        profile_id_str = "--",
    },
    currentBank = "--",
    -- mspCacheTools = nil,
    msp = {
        cache = {
            mspPidTuningAll = {
                {
                    roll =  { p = -1, i = -1, d = -1, f = -1},
                    pitch = { p = -1, i = -1, d = -1, f = -1},
                    yaw =   { p = -1, i = -1, d = -1 ,f = -1},
                },
                {
                    roll =  { p = -1, i = -1, d = -1, f = -1},
                    pitch = { p = -1, i = -1, d = -1, f = -1},
                    yaw =   { p = -1, i = -1, d = -1 ,f = -1},
                },
                {
                    roll =  { p = -1, i = -1, d = -1, f = -1},
                    pitch = { p = -1, i = -1, d = -1, f = -1},
                    yaw =   { p = -1, i = -1, d = -1 ,f = -1},
                },
                {
                    roll =  { p = -1, i = -1, d = -1, f = -1},
                    pitch = { p = -1, i = -1, d = -1, f = -1},
                    yaw =   { p = -1, i = -1, d = -1 ,f = -1},
                },
                {
                    roll =  { p = -1, i = -1, d = -1, f = -1},
                    pitch = { p = -1, i = -1, d = -1, f = -1},
                    yaw =   { p = -1, i = -1, d = -1 ,f = -1},
                },
                {
                    roll =  { p = -1, i = -1, d = -1, f = -1},
                    pitch = { p = -1, i = -1, d = -1, f = -1},
                    yaw =   { p = -1, i = -1, d = -1 ,f = -1},
                },
            }
        }
    }
}


--------------------------------------------------------------
local function log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
    return
end
--------------------------------------------------------------

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

-----------------------------------------------------------------------------------------------------------------

local function getPidValues(bank, axis, pidType)
    local axisMap = { "roll", "pitch", "yaw" }
    local axisName = axisMap[axis]

    local pidTypeMap = { "p", "i", "d", "f" }
    local pidKey = pidTypeMap[pidType]
    -- log("getPidValues: bank: %d, axis: %s, pidType: %s", bank, axisName, pidKey)
    local value = wgt.msp.cache.mspPidTuningAll[bank][axisName][pidKey]
    return value or "N/A"
    -- return string.format("%d-%d-%d", bank, axis, pidType)
end

local function onReceivedPidTuning(bank, data)
    -- log("onReceivedPidTuning: wgt: %s", wgt)
    -- log("onReceivedPidTuning: wgt: %s, data: %s, roll_p: %s", wgt, data, data.roll_p.value)
    wgt.msp.cache.mspPidTuningAll[bank] = {
        roll =  { p = data.roll_p.value , i = data.roll_i.value , d = data.roll_d.value , f = data.roll_f.value},
        pitch = { p = data.pitch_p.value, i = data.pitch_i.value, d = data.pitch_d.value, f = data.pitch_f.value},
        yaw =   { p = data.yaw_p.value  , i = data.yaw_i.value  , d = data.yaw_d.value  , f = data.yaw_f.value},
    }
end

local function readPids()
    log("readPids: wgt: %s", wgt)

    rf2.useApi("mspSetProfile").setPidProfile(1-1, function() return end, nil)
    rf2.useApi("mspPidTuning").read(onReceivedPidTuning, 1)

    rf2.useApi("mspSetProfile").setPidProfile(2-1, function() return end, nil)
    rf2.useApi("mspPidTuning").read(onReceivedPidTuning, 2)

    rf2.useApi("mspSetProfile").setPidProfile(3-1, function() return end, nil)
    rf2.useApi("mspPidTuning").read(onReceivedPidTuning, 3)

    rf2.useApi("mspSetProfile").setPidProfile(4-1, function() return end, nil)
    rf2.useApi("mspPidTuning").read(onReceivedPidTuning, 4)

    rf2.useApi("mspSetProfile").setPidProfile(5-1, function() return end, nil)
    rf2.useApi("mspPidTuning").read(onReceivedPidTuning, 5)

    rf2.useApi("mspSetProfile").setPidProfile(6-1, function() return end, nil)
    rf2.useApi("mspPidTuning").read(onReceivedPidTuning, 6)

    rf2.useApi("mspSetProfile").setPidProfile(wgt.values.profile_id-1, function() return end, nil)
end

-- ---------------------------------------------------------------------------------------------------------------

local function close()
    lvgl.confirm({title="Exit", message="exit config?",
        confirm=(function() lvgl.exitFullScreen() end)
    })
end

local function build_ui()
    lvgl.clear()
    lvgl.rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=lcd.RGB(0x11, 0x11, 0x11), filled=true, hide=true})
    local bMain = lvgl.box({x=0, y=0})
    bMain:label({x=10,y=10, color=WHITE, font=FS.FONT_8, text = "All PID's \ncomparison viewer"})
    bMain:label({x=10,y=60, color=RED, font=FS.FONT_8, text = "< change to fullscreen >"})
    -- bMain:qrcode({data="https://luadoc.edgetx.org", x=30, y=30, h=100,w=100, color=BLUE, bgColor=RED})
end


local function build_ui_appmode(wgt)
    lvgl.clear()
    local bMain = lvgl.box({x=0, y=0})
    bMain:label({text = app_name, x=140,y=10, color=WHITE, font=FS.FONT_12})

    local pg = lvgl.page({title="Rotorflight Dashboard", subtitle="Config",
        back=close,
        icon="/SCRIPTS/RF2-dashboards/widgets/img/rf2_logo.png",
        -- flexFlow=lvgl.FLOW_COLUMN,
        -- flexFlow=lvgl.FLOW_ROW,
        -- flexPad=30,
    })
    -- pg:rectangle({x=0, y=0, w=LCD_W, h=LCD_H, color=RED, filled=true, hide=false})

    -- pg:build({
    --     { type="setting", x=0, y=10, title="Craft Name (on FC)",
    --         children={
    --             { type="textEdit", x=150, y=0, w=180, maxLen=20,
    --                 value="sab goblin sport",
    --                 set=(function(val) txt=val end)
    --             },
    --             { type="button", text="reload", x=340, y=0, press=readCurrentBank},
    --             { type="button", text="Save", x=410, y=0, press=(function(wgt) readPids(wgt) end)},
    --         }
    --     }
    -- })

    pg:build({
        { type="setting", x=0, y=0, -- title="Craft Name (on FC)",
            children={
                { type="label", x=5, y=0,
                    text=function()
                        return string.format("Profile: %s", wgt.values.profile_id_str)
                    end,
                    font=BOLD
                },
                { type="button", text="read...", x=200, y=0, press=readPids},
                { type="toggle", title="short/long", x=400, y=0,
                    get=function() return wgt.show_3_or_6 or 0 end,
                    set=function(val) wgt.show_3_or_6=val end
                },
            }
        }
    })


    -- pg:label({x=5, y=0, text=function() return string.format("PID list: %s", wgt.values.profile_id) end, font=BOLD})

    local bPidList = pg:box({x=0, y=50})
    local lineColor = lcd.RGB(0xCCCCCC)
    local pTitles = {"P", "I", "D", "F"}
    local axisTitles = {"roll", "pitch", "yaw"}
    for i=1, 6 do
        bPidList:label({x=80+(i-1)*60, y=0, text="Profile " .. i,
            visible=function() return i<=3 or wgt.show_3_or_6==1 end
        })
        bPidList:vline({x=80-10 +(i-1)*60, y=5, h=360, w=1, color=lineColor,
            visible=function() return i<=3 or wgt.show_3_or_6==1 end
        })
    end

    for axis=1,3 do
        local h2 = (axis-1)*120+20
        -- bPidList:hline({x=50, y=h2+5, w=400, h=25, color=lineColor, rounded=true})
        bPidList:rectangle({x=40, y=h2, w=420, h=25, color=lineColor, filled=true, rounded=9})
        bPidList:label({x=200, y=h2, text=axisTitles[axis], font=BOLD})
        for p=1,4 do
            local h1 = h2 +(p-1)*20 +30
            bPidList:label({x=45, y=h1, text=pTitles[p]})
            local max_col = (wgt.show_3_or_6==1) and 6 or 3
            for i=1, 6 do
                -- bPidList:rectangle({x=70+(i-1)*60, y=h1, w=60, h=25, color=RED, filled=false})
                bPidList:label({x=70+(i-1)*60, y=h1, w=60,
                    text=function() return getPidValues(i, axis, p) end,
                    font=function() return (i==wgt.values.profile_id) and BOLD or 0 end,
                    align=CENTER,
                    visible=function() return i<=3 or wgt.show_3_or_6==1 end
                })
            end
        end
    end
    -- bPidList:hline({x=50, y=25, w=400, h=1, color=lineColor})--, rounded=true})
    -- bPidList:vline({x=50-10 +(7-1)*70, y=5, h=110, w=1, color=lineColor})--, rounded=true})

end

local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options

    log("isFullscreen: %s", lvgl.isFullScreen())
    log("isAppMode: %s", lvgl.isAppMode())

    if lvgl.isFullScreen() then
        log("update: in app mode")
        build_ui_appmode(wgt)
    else
        log("update: NOT app mode")
        build_ui(wgt)
    end

    return wgt
end

local function create(zone, options)
    wgt.zone = zone
    wgt.options = options
    return update(wgt, options)
end
-----------------------------------------------------------------------------------------------------------------

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


end

return {create=create, update=update, background=background, refresh=refresh, }
