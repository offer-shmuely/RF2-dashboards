local args = {...}
local log = args[1]
local app_name = args[2]
local tools = args[3]

local lvgl2 = { RGB=lcd.RGB }

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_24=XLSIZE, FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}
local lvSCALE = lvgl.LCD_SCALE or 1
local is800 = (LCD_W==800)

local values_elements_array = {
    --  {name="abc", value_func=f, color=WHITE, sensor=nil, icon="temperature.png"}
}

local default_font_size = (LCD_H > 272) and FS.FONT_8 or FS.FONT_6
local icon_size = is800 and 28*lvSCALE or 18*lvSCALE
local row_gap = 4*lvSCALE
local area_height = 0
local dev_name = ""
local NUM_ROWS = 2 -- sensors flow left-to-right and wrap into this many lines, anchored to the bottom

local M = {}

local function warnColor(wgt, sensor, normalColor)
    if wgt.tlmEngine.isAlert(sensor) then
        return RED
    elseif wgt.tlmEngine.isWarn(sensor) then
        return ORANGE
    else
        return normalColor
    end
end

M.init = function(wgt, dev_n, elem_list)
    log("lib_statusarea init()")
    dev_name = dev_n
    values_elements_array = {}

    for i, elem in pairs(elem_list) do
        values_elements_array[#values_elements_array+1] = {
            name=elem.name,
            value_func=elem.ftxt,
            color=elem.color,
            sensor=elem.sensor,
            icon=elem.icon,
        }
    end
end

M.height = function()
    return area_height
end

-- rounded card, icon left + text right, fills on warn/alert
local function buildSensorBox(bStatusArea, wgt, elem, row_h, col_w)
    bStatusArea:rectangle({
        pos=function() return elem.dx+row_gap//2, elem.dy+row_gap//2 end,
        size=function() return col_w-row_gap, row_h-row_gap end,
        filled=true,
        rounded=4*lvSCALE,
        color=function() return warnColor(wgt, elem.sensor, lvgl2.RGB(0x222222)) end,
    })

    -- icon slot is reserved even when unused, so icons/text line up across all cards
    local icon_x = elem.dx + row_gap*2
    local text_x = icon_x + icon_size + row_gap
    if elem.icon ~= nil then
        bStatusArea:image({
            pos=function() return icon_x, elem.dy + (row_h-icon_size)//2 end,
            w=icon_size, h=icon_size,
            file="/SCRIPTS/RF2-dashboards/img/"..elem.icon,
        })
    end

    -- shrink the font to fit the remaining column width, so long values never spill out of the card
    local max_w = elem.dx + col_w - text_x - row_gap
    local max_h = row_h - row_gap
    bStatusArea:label({
        pos=function()
            local _, _, h, v_off = tools.getFontSize(wgt, elem.value_func(), max_w, max_h, default_font_size)
            return text_x, elem.dy + (row_h-h)//2 + v_off
        end,
        text=function() return elem.value_func() end,
        font=function()
            local fontSize = tools.getFontSize(wgt, elem.value_func(), max_w, max_h, default_font_size)
            return fontSize
        end,
        color=function()
            if wgt.tlmEngine.isWarn(elem.sensor) then return WHITE end
            return elem.color or WHITE
        end,
    })
end

M.build_ui = function(parentBox, wgt)
    if #values_elements_array == 0 then return end

    local _, txt_h = tools.lcdSizeTextFixed("Xg", default_font_size)
    local row_h = math.max(icon_size, txt_h) + row_gap

    local items_per_row = math.ceil(#values_elements_array / NUM_ROWS)
    local item_w = wgt.zone.w // items_per_row
    area_height = NUM_ROWS * row_h

    -- anchored to the bottom of the screen, spans the full width
    local bStatusArea = parentBox:box({x=0, y=wgt.zone.h-area_height -5, w=wgt.zone.w, h=area_height})

    -- -- dev name, top-right corner of the screen
    -- parentBox:label({
    --     pos=function()
    --         local dev_w = tools.lcdSizeTextFixed(dev_name, FS.FONT_6)
    --         return wgt.zone.w - dev_w - row_gap, row_gap
    --     end,
    --     text=dev_name,
    --     font=FS.FONT_6,
    --     color=YELLOW,
    -- })

    for i, elem in pairs(values_elements_array) do
        local col = (i-1) % items_per_row
        local row = (i-1) // items_per_row
        elem.dx = col * item_w
        elem.dy = row * row_h
        buildSensorBox(bStatusArea, wgt, elem, row_h, item_w)
    end
end

M.refresh = function()
    -- values are read live via value_func, nothing periodic to do
end

return M

