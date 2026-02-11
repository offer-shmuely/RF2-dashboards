local M = {}

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

M.build_ui = function(  parentBox, wgt, a_x, a_y, a_color, a_txt, 
                        f_val, f_percent, 
                        a_icon, 
                        sensor)

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
    local function calcColor(f_percent, sensor)
        if sensor==nil then
            return GREY
        end
        local low_warn = sensor.low_warning or -9999
        local low_alert = sensor.low_alert or -9999
        local high_warn = sensor.high_warning or 9999
        local high_alert = sensor.high_alert or 9999

        local val = f_percent()
        if val>high_alert or val<low_alert then
            -- alert
            return lcd.RGB(0xFF623F)
        end
        if val>high_warn or val<low_warn then
            -- warning
            return lcd.RGB(0xFF8000)
        end
        -- ok
        return lcd.RGB(0x00A560)
    end

    local highWarnVal = 9999
    local highAlertVal = 9999
    if sensor~=nil then
        highWarnVal = sensor.high_warning
        highAlertVal = sensor.high_alert
    end

    local x1 = 0
    local x2 = 75
    local x3 = 120
    local rect_h = 20
    local rect_w = 130

    local function calcBarWidth(f_percent)
        local percent = f_percent()
        if percent == nil then return 0 end
        return math.floor((percent / 100) * rect_w)
    end

    parentBox:build({
        {type="box", x=a_x,y=a_y,
            children={
                {type="label", text=a_txt, x=x1, y=0,font=FS.FONT_8,color=titleGreyColor},

                -- -- shadow
                -- {type="rectangle",x=x2,y=0,w=rect_w,h=rect_h,color=lcd.RGB(0x000000),filled=true},
                -- background bar
                {type="rectangle",x=x2,y=0,w=rect_w,h=rect_h,color=lcd.RGB(0x444444),filled=true, rounded=2},
                -- foreground bar
                {type="rectangle",x=x2,y=0,
                    size=(function() return calcBarWidth(f_percent), rect_h end),
                    color=(function() return calcColor(f_percent, sensor) end),
                    filled=true, rounded=2,
                },

                -- shadow
                {type="rectangle",x=x3-5,y=1,w=50,h=rect_h-2,color=lcd.RGB(0x000000),filled=true,opacity=60, rounded=4},
                {type="label",x=x3,y=0,text= f_val,font=FS.FONT_8,color=txtColor},
            }
        }
    })

end

return M
