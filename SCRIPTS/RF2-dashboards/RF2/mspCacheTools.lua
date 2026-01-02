local M = {}

function M.craftName()   return rf2fc.msp.cache.mspName or "---" end
-- function M.governorMode()
--     if rf2fc.msp.cache.mspGovernorConfig.gov_mode == nil then
--         return "---"
--     end
--     return rf2fc.msp.cache.mspGovernorConfig.gov_mode.table[rf2fc.msp.cache.mspGovernorConfig.gov_mode.value]
-- end
-- function M.governorEnabled() return M.governorMode() ~= "OFF" end

-- function M.blackboxEnable()
--     return rf2fc.msp.cache.mspDataflash.ready==true and rf2fc.msp.cache.mspDataflash.supported==true
-- end

-- function M.blackboxSize()
--     if rf2fc.msp.cache.mspDataflash.ready ~= true then
--         return { enabled=false, totalSize=0, usedSize=0, freeSize=0 }
--     end
--     return { enabled=M.blackboxEnable(), totalSize= rf2fc.msp.cache.mspDataflash.totalSize, usedSize= rf2fc.msp.cache.mspDataflash.usedSize, freeSize= rf2fc.msp.cache.mspDataflash.totalSize - rf2fc.msp.cache.mspDataflash.usedSize }
-- end

function M.isCacheAvailable()
    if rf2fc == nil or rf2fc.msp == nil or rf2fc.msp.cache == nil then
        return false, "no RF2_Server widget found"
    end
    if rf2fc.msp.ctl.connected ~= true then
        return false,"Heli not connected"
    end
    rf2fc.msp.ctl.lastServerTime = rf2.clock()

    if (rf2.clock() - rf2fc.msp.ctl.lastServerTime) > 1 then
        return false, "server widget stopped"
    end

    if (rf2.clock() - rf2fc.msp.ctl.lastUpdateTime) > 15 then
        return false, "no data form server"
    end

    return true, "ok"
end


function M.armingDisableFlagsList()
    local flags = rf2fc.msp.cache.mspStatus.armingDisableFlags
    if flags == nil then
        return nil
    end

    -- flags = 0x31090186
    -- rf2.log("disableFlags: flags:%s", flags)

    local result = {}


    local t = ""
    for i = 0, 25 do
        if bit32.band(flags, bit32.lshift(1, i)) ~= 0 then
            if i == 0 then table.insert(result, "No Gyro") end
            if i == 1 then table.insert(result, "Failsafe is active") end
            if i == 2 then table.insert(result, "No valid receiver signal is detected") end
            if i == 3 then table.insert(result, "The FAILSAFE switch was activated") end
            if i == 4 then table.insert(result, "Box Fail Safe") end
            if i == 5 then table.insert(result, "Governor") end
            --if i == 6 then table.insert(result, "Crash Detected") end
            if i == 7 then table.insert(result, "Throttle not idle") end

            if i == 8 then table.insert(result, "Craft is not level enough") end
            if i == 9 then table.insert(result, "Arming too soon after power on") end
            if i == 10 then table.insert(result, "No Pre Arm") end
            if i == 11 then table.insert(result, "System load is too high") end
            if i == 12 then table.insert(result, "Calibrating") end
            if i == 13 then table.insert(result, "CLI is active") end
            if i == 14 then table.insert(result, "CMS Menu") end
            if i == 15 then table.insert(result, "BST") end

            if i == 16 then table.insert(result, "MSP connection is active") end
            if i == 17 then table.insert(result, "Paralyze mode activate") end
            if i == 18 then table.insert(result, "GPS") end
            if i == 19 then table.insert(result, "Resc") end
            if i == 20 then table.insert(result, "RPM Filter") end
            if i == 21 then table.insert(result, "Reboot Required") end
            if i == 22 then table.insert(result, "DSHOT Bitbang") end
            if i == 23 then table.insert(result, "Accelerometer calibration required") end

            if i == 24 then table.insert(result, "ESC/Motor Protocol not configured") end
            if i == 25 then table.insert(result, "Arm Switch") end
        end
    end
    return result
end

function M.isArmed()
    local flags = rf2fc.msp.cache.mspStatus.flightModeFlags
    if flags == nil then
        return false
    end

    local armFlag = bit32.band(flags, 0x01)
    return armFlag == 1
end

return M


