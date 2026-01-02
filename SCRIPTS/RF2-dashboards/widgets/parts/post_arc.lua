local M = {}

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

M.build_ui = function(parentBox, wgt, a_x, a_y, a_color, a_txt, f_val, f_percent, a_icon)

    local titleGreyColor = LIGHTGREY
    local txtColor = wgt.options.textColor

    local g_rad = 30
    local g_thick = 8--11
    local gm_rad = g_rad-10
    local gm_thick = 8
    local g_y1 = 5
    local g_y2 = 85
    local g_angel_min = 140
    local g_angel_max = 400
    local x_space = 10

    local function calEndAngle(f_percent)
        percent = f_percent()
        if percent==nil then return 0 end
        local v = ((percent/100) * (g_angel_max-g_angel_min)) + g_angel_min
        return v
    end

    parentBox:build({
        {type="box", x=a_x, y=a_y,
            children={
                {type="label", text=a_txt,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
                {type="arc", x=30, y=50,
                    radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=g_angel_max, rounded=true,
                    color=lcd.RGB(0x222222)},
                {type="arc", x=30, y=50,
                    radius=g_rad, thickness=g_thick, startAngle=g_angel_min,
                    endAngle=function() return calEndAngle(f_percent) end,
                    color=a_color},
                {type="label", x=15, y=70, text= f_val, font=FS.FONT_8, color=txtColor},
                -- {type="image", x=35, y=25, file="/SCRIPTS/RF2-dashboards/widgets/img/"..a_icon, w=16, h=16, visible=a_icon~=nil},
            }
        }
    })

end

return M
