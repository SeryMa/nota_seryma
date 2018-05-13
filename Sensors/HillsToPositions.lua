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

-- @description return hills on the map
return function(hills)
    local positions = {}

    for i, hill in pairs(hills) do
        table.insert(positions, hill.center)
	end 
	
	return positions
end