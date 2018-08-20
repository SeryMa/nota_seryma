local sensorInfo = {
	name = "GetAlive",
	desc = "Return first alive unit from given units.",
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
local isDead = Spring.GetUnitIsDead


-- @description return of the given unit
return function(units)
   for i = 1, #units do
        local unit = units[i]
        if unit ~= nil and not isDead(unit) then  
            return unit
        end
    end

	return nil
end