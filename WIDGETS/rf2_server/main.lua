local app_name = "rf2_server"
local widg_dir = "/SCRIPTS/RF2-dashboards/RF2/"
chdir(widg_dir)
local tool_opt = loadScript(widg_dir..app_name .. "_opt.lua", "btd")()

local function create(zone, options)
    local tool = assert(loadScript(widg_dir..app_name .. ".lua", "btd"))()
    local wgt = tool.create(zone, options)
    wgt._tool = tool
    return wgt
end
local function update(wgt, options) return wgt._tool.update(wgt, options) end
local function background(wgt)      return wgt._tool.background(wgt)      end
local function refresh(wgt)         return wgt._tool.refresh(wgt)         end

return {name=app_name, options=tool_opt.options, translate=tool_opt.translate, create=create, update=update, refresh=refresh, background=background, useLvgl=true}
