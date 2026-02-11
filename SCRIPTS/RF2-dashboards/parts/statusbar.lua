local args = {...}
local log = args[1]
local app_name = args[2]
local tools = args[3]

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}

local values_elements_array = {
--  {name="abc", value_func=f, units="%", x=0, width=60, full_txt=""}
}

local dev_name = ""

local default_font_size = (LCD_H>272) and FS.FONT_8 or FS.FONT_6
local perd1 = tools.periodicInit()
local perd2 = tools.periodicInit()
tools.periodicStart(perd1, 1000)
tools.periodicStart(perd2, 100)
local status_bar_height = 0

local M = {}

local function separator_txt()
    return " | "
end
local function separator_width()
    local txt = separator_txt()
    local ts_w2, ts_h2, v_offset = tools.lcdSizeTextFixed(txt, default_font_size)
    return ts_w2
end

M.init = function(dev, elem_list)
    log("lib_statusbar init()")
    dev_name = dev
    values_elements_array = {}

    for i, elem in pairs(elem_list) do
        local txt = elem.ftxt()
        local ts_w2, ts_h2, v_offset = tools.lcdSizeTextFixed(txt, default_font_size)
        values_elements_array[#values_elements_array+1] = {name="|", value_func=separator_txt, x=0, width=separator_width()}
        values_elements_array[#values_elements_array+1] = {name=elem.name, value_func=elem.ftxt, x=0, width=0, color=elem.color, error_color=elem.error_color, error_cond=elem.error_cond}
    end
end

local function list_status()
    local last_x = 0
    log("values_elements_array status")
    for i, elem in pairs(values_elements_array) do
        elem.dx = last_x
        last_x = last_x + elem.width
        -- log("streach elem [%s] dx=%s, w=%s, last_x=%s", elem.name, elem.dx, elem.width, last_x )
        log("streach elem [%s] dx=%s, w=%s", elem.name, elem.dx, elem.width)
    end
end

M.streach = function()
    if #values_elements_array == 0 then return end
    -- log("lib_statusbar streach()")
    local last_x = 0
    for i, elem in pairs(values_elements_array) do
        local txt = elem.value_func()
        local ts_w1, ts_h1, v_offset = tools.lcdSizeTextFixed(txt , default_font_size)
        if values_elements_array[i].name == "|" then
            elem.width = separator_width()
        else
            elem.width = ts_w1
        end
        last_x = last_x + elem.width
        -- log("streach elem [%s] dx=%s, w=%s, last_x =%s", elem.name, elem.dx, elem.width, last_x )
    end

    last_x = 0
    for i, elem in pairs(values_elements_array) do
        elem.dx = last_x
        last_x = last_x + elem.width
    end
    -- list_status()
end

local head_x = 0
M.slide = function(slide_dx)
    if #values_elements_array == 0 then return end
    slide_dx = slide_dx or 1
    -- log("lib_statusbar slide()")
    head_x = head_x - slide_dx
    local first_elem = values_elements_array[1]
    if head_x + first_elem.dx + first_elem.width//2 < 0 then
        -- remove first element and add to end
        -- log("slide elem [%s] off screen (size before remove: %s)", first_elem.name, #values_elements_array )
        table.remove(values_elements_array, 1)
        -- log("slide elem [%s] off screen (size after remove: %s)", first_elem.name, #values_elements_array )
        values_elements_array[#values_elements_array+1] = first_elem
        -- log("slide elem [%s] off screen (size after add: %s)", first_elem.name, #values_elements_array )
        head_x = head_x + first_elem.width
    end

    for i, elem in pairs(values_elements_array) do
        -- recalculate dx positions
        local last_x = 0
        for j, e in pairs(values_elements_array) do
            e.dx = last_x
            last_x = last_x + e.width
        end
        -- log("slide elem [%s] moved to end", first_elem.name )
    end

end

M.height = function()
    return status_bar_height
end

M.build_ui = function(parentBox, wgt)
    local nan_w, sb_h, v_offset = tools.lcdSizeTextFixed("XXXXXXXXXX", default_font_size)
    sb_h = sb_h + 7
    status_bar_height = sb_h
    local bStatusBar = parentBox:box({x=0, y=wgt.zone.h-wgt.selfTopbarHeight-sb_h})
    local statusBarColor = lcd.RGB(0x0078D4)

    bStatusBar:rectangle({x=0, y=0,w=wgt.zone.w, h=sb_h, color=statusBarColor, filled=true})
    -- bStatusBar:rectangle({x=25, y=0,w=70, h=ts_h2, color=RED, filled=true, visible=function() return (wgt.values.link_rqly < 80) end })

    local dev_w, dev_h, dev_v_offset = tools.lcdSizeTextFixed(dev_name, default_font_size)
    bStatusBar:label({x=LCD_W-dev_w-3, y=2, text=dev_name, font=default_font_size, color=YELLOW})

    local bStatusBarValuesArea = bStatusBar:box({x=0, y=0, w=LCD_W-dev_w-5, h=sb_h})

    local last_x = 0
    for i, elem in pairs(values_elements_array) do

        bStatusBarValuesArea:rectangle({
            pos=function()
                return head_x + elem.dx-3, 2
            end,
            size=function() return elem.width+6, sb_h-4 end,
            filled=true,
            font=default_font_size,
            rounded=2,
            color=function()
                if elem.error_cond and elem.error_cond() then
                    return elem.error_color or RED
                else
                    return elem.color or WHITE
                end
            end,
            visible=function()
                if elem.error_cond and elem.error_cond() then
                    return true
                else
                    return false
                end
            end

        })
        bStatusBarValuesArea:label({
            pos=function()
                return head_x + elem.dx, 4+v_offset
            end,
            text=function()
                return elem.value_func()
            end,
            font=default_font_size,
            color=function()
                if elem.error_cond and elem.error_cond() then
                    return WHITE
                else
                    return elem.color or WHITE
                end
            end
        })
        -- bStatusBarValuesArea:rectangle({
        --     pos=function()
        --         return values_elements_array[i].x, 4+v_offset
        --     end,
        --     size=function() return values_elements_array[i].width, ts_h2+10 end,
        --     filled=false,
        --     font=default_font_size,
        --     color=RED
        -- })
    end

    M.streach()
end

M.refresh = function()
    if tools.periodicHasPassed(perd1, false) then
        M.streach()
        tools.periodicReset(perd1)
    end
    if tools.periodicHasPassed(perd2, false) then
        M.slide()
        tools.periodicReset(perd2)
    end
end

return M
