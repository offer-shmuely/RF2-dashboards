local arg = {...}
local baseDir = arg[1]
local log = arg[2]
local app_name = arg[3]
local onFlightStateChanged = arg[4]  -- callback

local M = {}

-- state machine
M.FLIGHT_STATE = {
    PRE_FLIGHT = 0,
    ON_AIR = 1,
    ON_AIR_PENDING = 2,
    POST_FLIGHT = 3,
}
local state = M.FLIGHT_STATE.PRE_FLIGHT

-- thresholds for state transitions
local RPM_TAKEOFF_THRESHOLD = 100  -- RPM above which we consider the heli airborne
local RPM_LANDING_THRESHOLD = 50   -- RPM below which we consider the heli landed
local STATE_CHANGE_DELAY = 500     -- delay in 10ms units (500 = 5 seconds)

-- state transition tracking
local takeoff_condition_start_time = nil
local landing_condition_start_time = nil

-- state entry handlers
local function onEnterStatePreFlight()
    log("task_flight_stage: -> pre_flight")
    local oldState = state
    state = M.FLIGHT_STATE.PRE_FLIGHT
    onFlightStateChanged(oldState, state)
end

local function onEnterStateOnAirPending(head_speed)
    log("task_flight_stage: -> on_air pending (rpm: %s)", head_speed)
    local oldState = state
    state = M.FLIGHT_STATE.ON_AIR_PENDING
    onFlightStateChanged(oldState, state)
end

local function onEnterStateOnAir(head_speed)
    log("task_flight_stage: -> on_air (rpm: %s)", head_speed)
    local oldState = state
    state = M.FLIGHT_STATE.ON_AIR
    onFlightStateChanged(oldState, state)
    playFile("takeoff.wav")  -- audio notification
end

local function onEnterStatePostFlight(head_speed)
    log("task_flight_stage: -> post_flight (rpm: %s)", head_speed)
    local oldState = state
    state = M.FLIGHT_STATE.POST_FLIGHT
    onFlightStateChanged(oldState, state)
    playFile("landing.wav")  -- audio notification
end

M.init = function(wgt)
    log("task_flight_stage.init called")
    takeoff_condition_start_time = nil
    landing_condition_start_time = nil
    onEnterStatePreFlight()
end

local updateStateIfNeeded = function(head_speed, is_arm)

    local current_time = getTime()

    -- state machine transitions
    if state == M.FLIGHT_STATE.PRE_FLIGHT or state == M.FLIGHT_STATE.ON_AIR_PENDING then
        if head_speed < RPM_TAKEOFF_THRESHOLD or is_arm==false then
            if takeoff_condition_start_time~=nil then
                log("task_flight_stage: takeoff aborted")
                onEnterStatePreFlight()
            end
            takeoff_condition_start_time = nil
            return
        end

        if takeoff_condition_start_time == nil then
            takeoff_condition_start_time = current_time
            log("task_flight_stage: takeoff condition, waiting %s seconds", STATE_CHANGE_DELAY / 100)
            onEnterStateOnAirPending(head_speed)
            return
        end

        if (current_time - takeoff_condition_start_time) >= STATE_CHANGE_DELAY then
            onEnterStateOnAir(head_speed)
            takeoff_condition_start_time = nil
        end
        return

    elseif state == M.FLIGHT_STATE.ON_AIR then
        if head_speed > RPM_LANDING_THRESHOLD or is_arm==true then
            if landing_condition_start_time~=nil then
                log("task_flight_stage: landing aborted")
            end
            landing_condition_start_time = nil
            return
        end

        if landing_condition_start_time == nil then
            landing_condition_start_time = current_time
            log("task_flight_stage: landing condition, waiting %s seconds", STATE_CHANGE_DELAY / 100)
            return
        end

        if (current_time - landing_condition_start_time) >= STATE_CHANGE_DELAY then
            onEnterStatePostFlight(head_speed)
            landing_condition_start_time = nil
        end

    elseif state == M.FLIGHT_STATE.POST_FLIGHT then
        if is_arm==false then
            if takeoff_condition_start_time~=nil then
                log("task_flight_stage: takeoff aborted")
                onEnterStatePreFlight()
            end
            takeoff_condition_start_time = nil
            return
        end

        if takeoff_condition_start_time == nil then
            takeoff_condition_start_time = current_time
            log("task_flight_stage: takeoff condition, waiting %s seconds", STATE_CHANGE_DELAY / 100)
            onEnterStateOnAirPending(head_speed)
            return
        end

        if (current_time - takeoff_condition_start_time) >= STATE_CHANGE_DELAY then
            onEnterStateOnAir(head_speed)
            takeoff_condition_start_time = nil
        end
        return

    end

end

M.getFlightStage = function()
    return state
end
M.getFlightStageStr = function()
    local stateStrs = {
        [M.FLIGHT_STATE.PRE_FLIGHT]  = "Pre-Flight",
        [M.FLIGHT_STATE.ON_AIR_PENDING] = "On Air Pending",
        [M.FLIGHT_STATE.ON_AIR]      = "On Air",
        [M.FLIGHT_STATE.POST_FLIGHT] = "Post-Flight",
    }
    return stateStrs[state] or "---"
end

M.isOnPreFlight = function()
    return state == M.FLIGHT_STATE.PRE_FLIGHT
end

M.isOnAir = function()
    return state == M.FLIGHT_STATE.ON_AIR
end

M.isOnGround = function()
    return state == M.FLIGHT_STATE.PRE_FLIGHT  or state == M.FLIGHT_STATE.ON_AIR_PENDING or state == M.FLIGHT_STATE.POST_FLIGHT
end

M.isPostFlight = function()
    return state == M.FLIGHT_STATE.POST_FLIGHT
end

M.run = function(wgt)
    local head_speed = wgt.values.rpm
    local is_arm = wgt.values.is_arm
    if head_speed == nil then
        return 0
    end

    updateStateIfNeeded(head_speed, is_arm)
    return 0
end

return M
