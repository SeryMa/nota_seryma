local sensorInfo = {
	name = "Are units close",
	desc = "Returns true if all the units are close to each other.",
	author = "SeryMa",
	date = "2017-04-22",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

local GetUnitPosition = Spring.GetUnitPosition


return function(units, requiredDistance)
    if #units <= 1 then return true end
    
    local ref = Vec3(GetUnitPosition(units[1]))
    
    for i = 2, #units do
        local pos = Vec3(GetUnitPosition(units[i]))

        if ref:Distance(pos) > requiredDistance then
            return false
        end
    end

    return true
end