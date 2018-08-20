local sensorInfo = {
	name = "Position",
	desc = "Return position of a unit.",
	author = "SeryMa",
	date = "2017-04-22",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups
local SpringGetUnitPosition = Spring.GetUnitPosition

-- @description return of the given unit
return function(unitId)
	local x,y,z = SpringGetUnitPosition(unitId)
	return Vec3(x,y,z)
end