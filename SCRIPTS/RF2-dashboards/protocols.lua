local function getProtocol()
    if sportTelemetryPush() ~= nil then
        return "sp"
    elseif crossfireTelemetryPush() ~= nil  or rf2.runningInSimulator then
        return "crsf"
    elseif ghostTelemetryPush() ~= nil then
        return "ghst"
    else
        return "---"
    end
end

local protocol = assert(getProtocol(), "Telemetry protocol\n     not supported!")

return protocol
