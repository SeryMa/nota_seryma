local sensorInfo = {
	name = "Clear all",
	desc = "Clears all debug widget drawings.",
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

-- @description return of the given unit
return function(unitId)
	if (Script.LuaUI('boundary_init')) then
		Script.LuaUI.boundary_init()
	end
	
	if (Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end
end