local sensorInfo = {
	name = "Hills",
	desc = "Returns position of hills on map.",
	author = "SeryMa",
	date = "2017-05-16",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups
local SpringGetWind = Spring.GetWind

-- @description return current wind statistics
return function()
	local positions = Sensors.Common.metalPositions()
	local spots = {}
	for i=1, #positions do
		spots[i] = Vec3(positions[i].posX, positions[i].height, positions[i].posZ)
	end
	return spots
end