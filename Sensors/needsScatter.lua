local sensorInfo = {
	name = "Needs sccatter",
	desc = "Returns true, if given units needs to be sccattered.",
	author = "SeryMa",
	date = "2017-05-16",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups
local GetUnitPosition = Spring.GetUnitPosition

-- @description return safe spaces found on map
return function(untis, points, thresholdDistance)
    local covered = 0
    for j=1, #points do
        for i=1, #units do
            local pos = Vec3(GetUnitPosition(units[i]))
            if pos:Distance(points[j]) < thresholdDistance then
                Spring.Echo(pos:Distance(points[j]))
                covered = covered + 1
                break
            end
        end
    end


    return covered == #points or covered == #units
end