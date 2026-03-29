local M = {}

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local lvSCALE = lvgl.LCD_SCALE or 1
local is800 = (LCD_W==800)
local g_angel_min = 140
local g_angel_max = 400


local function calEndAngle(f_percent)
    local percent = f_percent()
    if percent==nil then return 0 end
    local v = ((percent/100) * (g_angel_max-g_angel_min)) + g_angel_min
    return v
end

local function calcColor(wgt, f_percent, sensor)
    if sensor==nil then
        return GREY
    end
    if wgt.tlmEngine.isAlert(sensor) then
        return lcd.RGB(0xFF0000)
    end
    if wgt.tlmEngine.isWarn(sensor) then
        return lcd.RGB(0xFF8000)
    end

    -- everything is good
    return lcd.RGB(0x00FF00)
end

M.build_ui = function(parentBox, wgt, line, col, a_color, a_txt,
                        f_val,
                        f_percent,
                        a_icon,
                        sensor)

    local titleGreyColor = LIGHTGREY
    local txtColor = wgt.options.textColor

    local g_rad = is800 and 70 or 30
    local g_thick = is800 and 14 or 8 --11
    local gm_rad = g_rad-10
    local gm_thick = 8
    local g_y1 = 5*lvSCALE
    local g_y2 = 85*lvSCALE
    local x_space = 10*lvSCALE
    local y_space = 30*lvSCALE
    local text = {
        x=is800 and 0 or 15,
        y=is800 and 80 or 70}

    parentBox:box({x=(col-1)* (g_rad*2 + x_space), y=(line-1) * (g_rad*2 + y_space),
        children={
            -- {type="rectangle", x=0, y=0, w=(g_rad*2)+10, h=(g_rad*2)+10, color=RED, filled=true},
            {type="label", text=a_txt,  x=0, y=0, font=FS.FONT_6, color=titleGreyColor},
            {type="arc", x=g_rad, y=g_rad+20*lvSCALE,
                radius=g_rad, thickness=g_thick, startAngle=g_angel_min, endAngle=g_angel_max, rounded=true,
                color=lcd.RGB(0x444444)},
            {type="arc", x=g_rad, y=g_rad+20*lvSCALE,
                radius=g_rad, thickness=g_thick, startAngle=g_angel_min,
                endAngle=function() return calEndAngle(f_percent) end,
                rounded=true,
                color=function() return calcColor(wgt, f_percent, sensor) end,
            },

            {type="label", x=text.x, y=text.y, w=g_rad*2, h=g_rad*2, text=f_val, font=FS.FONT_8, color=txtColor, align=is800 and CENTER or 0},
            -- {type="image", x=35*lvSCALE, y=25*lvSCALE, file="/SCRIPTS/RF2-dashboards/img/"..a_icon, w=16*lvSCALE, h=16*lvSCALE, visible=a_icon~=nil},
        }
    })

end

return M
