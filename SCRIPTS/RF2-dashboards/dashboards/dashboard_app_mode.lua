local arg = {...}
local log = arg[1]
local app_name = arg[2]
local baseDir = arg[3]
local tools = arg[4]
local statusbar = arg[5]
local inSimu = arg[6]

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local M = {}

M.build_ui = function(wgt)
    lvgl.clear()
    local bMain = lvgl.box({x=0, y=0})
    bMain:label({text = app_name, x=140,y=10, color=WHITE, font=FS.FONT_12})

    local pg = lvgl.page({title="Rotorflight Dashboard", subtitle="Config",
        back=close,
        icon="/SCRIPTS/RF2-dashboards/img/rf2_logo.png",
        -- flexFlow=lvgl.FLOW_COLUMN,
        -- flexFlow=lvgl.FLOW_ROW,
        -- flexPad=30,
    })

end

return M

