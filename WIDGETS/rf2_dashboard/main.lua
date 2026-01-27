local app_name = "rf2_dashboard"
local widg_dir = "/SCRIPTS/RF2-dashboards/"
chdir(widg_dir)
local tool = nil

local ver, radio, maj, minor, rev, osname = getVersion()
local nVer = maj*1000000 + minor*1000 + rev
--wgt.log("version: %s, %s %s %s %s", string.format("%d.%03d.%03d", maj, minor, rev), nVer<2011000, nVer>2011000, nVer>=2011000, nVer>=2011000)
local is_valid_ver = (nVer>=2011003)
print(string.format("Version: %s, nVer: %d, is_valid_ver: %s", string.format("%d.%03d.%03d", maj, minor, rev), nVer, tostring(is_valid_ver)))

local tool_opt
if is_valid_ver == true then
    tool_opt = loadScript(widg_dir..app_name .. "_opt.lua", "btd")()
else
    tool_opt = {
        options={},
        translate={}
    }
end

local function create(zone, options)
    if is_valid_ver==true then
        tool = assert(loadScript(widg_dir..app_name .. ".lua", "btd"))()
    else
        tool = {
            create = function(zone, options) return {zone=zone,options=options} end,
            update = function(wgt, options)  return wgt end,
            refresh = function(wgt) 
                lcd.drawText(10, 10, app_name.."\nRequires EdgeTX 2.11.3 or higher\nPlease upgrade your Radio", RED)
                -- return 0 
            end,
            background = function(wgt) return end
        }
    end

    return tool.create(zone, options)
end
local function update(wgt, options) return tool.update(wgt, options) end
local function refresh(wgt)         return tool.refresh(wgt) end
local function background(wgt)      return tool.background(wgt) end

return {name=app_name, options=tool_opt.options, translate=tool_opt.translate, create=create, update=update, refresh=refresh, background=background, useLvgl=is_valid_ver}
