local app_name = "rf2_image"

local is_first_time = true
local baseDir = "/SCRIPTS/RF2-dashboards/"

local NA_IMAGE_NAME = "widgets/img/rf2_image_def.png"
local na_img


local function log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
end

local function fileExists(name)
    local f = io.open(name, "r")
    if f then
        io.close(f)
        return true
    end
    return false
end


local function update(wgt, options)
    if (wgt == nil) then return end
    wgt.options = options
    wgt.last_craftName = nil
    wgt.last_image_name = nil
    wgt.is_image_exist = nil

    local img = bitmap.open(baseDir..NA_IMAGE_NAME)
    na_img = bitmap.resize(img, wgt.zone.w,wgt.zone.h)
    assert(na_img, "Failed to load image: " .. baseDir..NA_IMAGE_NAME)
end

local function create(zone, options)
    local wgt = {
        zone = zone,
        options = options
    }
    update(wgt, options)
    return wgt
end

local function background(wgt)
end

local function getCraftName(wgt)
    -- get the craft name from the rf2fc (msp)
    local is_avail = false
    if rf2fc ~= nil and rf2fc.mspCacheTools ~= nil then
        is_avail, err = rf2fc.mspCacheTools.isCacheAvailable()
    end

    local craftName
    if is_avail == true then
        -- log("msp cache is available")
        wgt.mspTool = rf2fc.mspCacheTools
        craftName = wgt.mspTool.craftName()
        return craftName
    else
        log("msp cache is NOT available")
        return "---"
    end
end

local function loadImage(wgt, craftName)
    -- local imageName = craftName~=nil and "/IMAGES/" .. craftName .. ".png" or "---"
    if craftName == "---" then
        wgt.img = nil
        collectgarbage()
        wgt.img = na_img
        wgt.last_craftName = craftName
        wgt.last_image_name = NA_IMAGE_NAME
        wgt.is_image_exist = true
        return
    end

    local imageName = "/IMAGES/" .. craftName .. ".png"
    -- wgt.last_image_name = imageName

    if fileExists(imageName) then
        wgt.is_image_exist = true
    else
        log("Failed to load image for model: %s=%s", craftName, imageName)
        imageName = NA_IMAGE_NAME
        wgt.is_image_exist = false
    end

    wgt.img = nil
    collectgarbage()
    local img = bitmap.open(imageName)
    wgt.img = bitmap.resize(img, wgt.zone.w,wgt.zone.h)
    assert(wgt.img, "Failed to load image: " .. imageName)

    -- if wgt.img == nil then
    --     log("Failed to load image for model: %s", imageName)
    --     wgt.img = na_img
    --     wgt.is_image_exist = false
    -- end

    wgt.last_craftName = craftName
    wgt.last_image_name = imageName
    log("Loaded image for model: %s=%s", craftName, imageName)
    collectgarbage()
end
---------------------------------------------------------------------------------------------------

local function refresh(wgt, event, touchState)
    if (wgt == nil) then return end
    if (wgt.options == nil) then return end

    local newCraftName = getCraftName(wgt)
    -- log("newCraftName: %s", newCraftName)

    if newCraftName ~= wgt.last_craftName then
        log("model changed, %s --> %s", wgt.last_craftName, newCraftName)
        loadImage(wgt, newCraftName)
    end

    assert(wgt.img, "image is nil")
    lcd.drawBitmap(wgt.img, 0, 0)

    if rf2fc.msp.ctl.connected == false then
        lcd.drawText(0, 0, "Heli not connected", 0 + GREY + BLINK)
    elseif wgt.is_image_exist == false then
        lcd.drawText(0, 0, string.format("No Image for: [%s]", wgt.last_craftName), 0 + BOLD + RED + BLINK)
        lcd.drawText(0, 20, wgt.last_image_name, SMLSIZE)
    end

end

return {name=app_name, create=create, update=update, background=background, refresh=refresh}
