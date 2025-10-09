local app_name = "rf2_capacity"
chdir("/SCRIPTS/RF2-dashboards/widgets")
local tool = nil
local tool_opt = loadScript(app_name .. "_opt.lua", "btd")()

local function create(zone, options)
    tool = assert(loadScript(app_name .. ".lua", "btd"))()
    return tool.create(zone, options)
end
local function update(wgt, options) return tool.update(wgt, options) end
local function background(wgt)      return tool.background(wgt) end
local function refresh(wgt)         return tool.refresh(wgt)    end

return {name=app_name, options=tool_opt.options, translate=tool_opt.translate, create=create, update=update, refresh=refresh, background=background, useLvgl=true}
