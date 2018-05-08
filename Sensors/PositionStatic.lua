local sensorInfo = {
	name = "PositionStatic",
	desc = "Return position of the point unit. It is presumed the unit is static",
	author = "PepeAmpere",
	date = "2017-04-22",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = math.huge

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- @description return static position of the first unit
return function()
	return Sensors.Position()
end