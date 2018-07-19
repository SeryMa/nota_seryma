local sensorInfo = {
	name = "Create group of units",
	desc = "Return group of given units",
	author = "SeryMa",
	date = "2018-06-13",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

return function(units)
	local groupArray = {}
	
	for i = 1, #units do
		groupArray[units[i]] = i
	end
	
	return groupArray  
end