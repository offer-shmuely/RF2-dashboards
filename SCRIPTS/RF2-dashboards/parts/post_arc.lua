local M = {}

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local g_angel_min = 140
local g_angel_max = 400


local function calEndAngle(f_percent)
    local percent = f_percent()
    if percent==nil then return 0 end
    local v = ((percent/100) * (g_angel_max-g_angel_min)) + g_angel_min
    return v
end

local function calcColor(f_percent, sensor)
    if sensor==nil then
        return GREY
    end

    -- detection by alert/warn functions
    if sensor.isAlert ~=nil or sensor.isWarn ~=nil then
        if sensor.isAlert ~=nil and sensor.isAlert() then
            return lcd.RGB(0xFF0000)
        end
        if sensor.isWarn ~=nil and sensor.isWarn() then
            return lcd.RGB(0xFF8000)
        end

        return lcd.RGB(0x00FF00)
    end


    -- detection by percent thresholds
    local low_warn = sensor.low_warning or -9999
    local low_alert = sensor.low_alert or -9999
    local high_warn = sensor.high_warning or 9999
    local high_alert = sensor.high_alert or 9999

    local val = f_percent()

    if val>high_alert or val<low_alert then
        return lcd.RGB(0xFF0000)
    end
    if val>high_warn or val<low_warn then
        return lcd.RGB(0xFF8000)
    end

    -- everything is good
    return lcd.RGB(0x00FF00)
end

M.build_ui = function(parentBox, wgt, a_x, a_y, a_color, a_txt,
                        f_val,
                        f_percent,
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
    local x_space = 10


    local highWarnVal = 9999
    local highAlertVal = 9999
    if sensor~=nil then
        highWarnVal = sensor.high_warning
        highAlertVal = sensor.high_alert
    end

    parentBox:build({
        {type="box", x=a_x, y=a_y,
            children={
                {type="label", text=a_txt,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
                {type="arc", x=30, y=50,
                    radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=g_angel_max, rounded=true,
                    color=lcd.RGB(0x444444)},
                {type="arc", x=30, y=50,
                    radius=g_rad, thickness=g_thick, startAngle=g_angel_min,
                    endAngle=function() return calEndAngle(f_percent) end,
                    color=function() return calcColor(f_percent, sensor) end,
                },

                {type="label", x=15, y=70, text= f_val, font=FS.FONT_8, color=txtColor},
                -- {type="image", x=35, y=25, file="/SCRIPTS/RF2-dashboards/img/"..a_icon, w=16, h=16, visible=a_icon~=nil},
            }
        }
    })

end

return M
