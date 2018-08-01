local sensorInfo = {
	name = "Divide units",
	desc = "Divides units into specified groups.",
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

-- @description return safe spaces found on map
return function(units, count)
    local groups = {}
    
    for i = 1, count do
        groups[i] = {}
    end

    for i = 1, #units do
        groups[(i%count) + 1][#groups[(i%count) + 1]+1] = units[i]
    end

    return groups
end