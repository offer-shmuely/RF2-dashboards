local M = {}

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}
local lvSCALE = lvgl.LCD_SCALE or 1
local is800 = (LCD_W==800)
local function lvglPercent(p)
    return math.floor((LCD_W - 20) * p / 100)
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

M.build_ui = function(  parentBox, wgt, col, line, a_color, a_txt,
                        f_val, f_percent,
                        a_icon,
                        sensor)

    local bx = 2*lvSCALE
    local by = 65*lvSCALE
    local dy = 29*lvSCALE
    local theFont = FS.FONT_8
    if is800 then
        dy = 55
        theFont = FS.FONT_12
    end

    local a_x = (col ==1) and 2*lvSCALE or lvglPercent(54)
    local a_y = by + (line-1) * dy
    local titleGreyColor = LIGHTGREY
    local txtColor = wgt.options.textColor

    local x1 = 0
    local x2 = lvglPercent(15) --  75*lvSCALE
    local x3 = lvglPercent(25) -- 120*lvSCALE
    local rect_h = 20
    local rect_w = 130
    local rect_txt_shadow_w = 70
    if is800 then
        rect_h = 40
        rect_w = 240
        rect_txt_shadow_w = 120
    end

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
                    color=(function() return calcColor(wgt, f_percent, sensor) end),
                    filled=true, rounded=2,
                },

                -- val shadow
                {type="rectangle",x=x3-5*lvSCALE,y=1, color=lcd.RGB(0x000000), filled=true, opacity=60, rounded=4,
                    size=(function()
                        local ts_w, ts_h, v_offset = wgt.tools.lcdSizeTextFixed(f_val(), theFont)
                        return ts_w+10*lvSCALE, rect_h-2
                    end),
                },
                -- val text
                {type="label",x=x3,y=0,text= f_val,font=theFont,color=txtColor},
            }
        }
    })

end

return M
