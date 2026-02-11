local arg = {...}
local baseDir = arg[1]
local log = arg[2]
local app_name = arg[3]

local M = {}

local last_capa_perc_parted = nil
local last_capa_anounce = 0

local function m_clock()
    return getTime() / 100
end

M.init = function(wgt)
    last_capa_perc_parted = 100
end

local function playCapacityValue_by_percent(wgt)
    if wgt.options.enableAudio == 0 then
        return
    end

    log("playCapacityValue: %s", wgt.values.capaPercent)
    playFile(baseDir.."/sounds/capacity.wav")
    playNumber(wgt.values.capaPercent, 13, 0)
end

local function playCapacityValue_by_mah(wgt)
    if wgt.options.enableAudio == 0 then
        return
    end

    log("playCapacityValue: %s", wgt.values.capaPercent)
    local capa_used_parted = math.ceil(wgt.values.capaUsed / 100) * 100
    playNumber(capa_used_parted, 14, 0)
end

-- play capacity audio when capacity percent drops by 10%
-- play capacity audio when capacity percent is below 20% every 10 seconds
-- play capacity audio when capacity percent is below 30% every 20 seconds
M.run = function(wgt)
    local new_capa = wgt.values.capaPercent
    local new_capa_parted = math.ceil(new_capa / 10) * 10
    -- log("audio for capacity: last=%s new=%s", last_capa_perc_parted, new_capa_parted)
    if new_capa_parted < last_capa_perc_parted then
        last_capa_perc_parted = new_capa_parted
        log("audio for capacity - new capacity: %s", new_capa)
        playCapacityValue_by_percent(wgt)
        -- playCapacityValue_by_mah(wgt)
        return 1
    end


    if wgt.is_connected then
        if new_capa_parted < 20 then
            if m_clock() - last_capa_anounce > 10 then
                log("task_capa_audio: time to play critical capacity")
                playCapacityValue_by_percent(wgt)
                last_capa_anounce = m_clock()
            end
        elseif new_capa_parted < 30 then
            if m_clock() - last_capa_anounce > 20 then
                log("task_capa_audio: time to play low capacity")
                playCapacityValue_by_percent(wgt)
                last_capa_anounce = m_clock()
            end
        end
    end
    return 0
end


return M

