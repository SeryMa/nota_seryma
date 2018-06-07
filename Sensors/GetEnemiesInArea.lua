local sensorInfo = {
	name = "Enemies",
	desc = "Returns enemies in given area.",
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
local GetUnits = Spring.GetUnitsInCylinder

local US = Spring.GetMyTeamID()
local THEM = 1 -- couldn't figure how to get this number properly...

-- @description return safe spaces found on map
return function(area, debug)
	local e = GetUnits(area.center.x, area.center.z, area.radius, THEM)


	if (debug and Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
    end
    
    if (debug and Script.LuaUI('circle_update')) then
		math.randomseed(os.time())
        local offset = math.random(10000, 10000000)
		
		for i = 1, #e do
			local x, y, z = Spring.GetUnitPosition(e[i])
			Script.LuaUI.circle_update(
				offset + i,
				{ x= x,
					y= y,
					z= z,
					radius=20,
					r = 250,
					g = 0,
					b = 0,
				})
			end
			Script.LuaUI.circle_update(
				offset,				
				{ x= area.center.x,
					y= area.center.y,
					z= area.center.z,
					radius=area.radius	,
					r = 250,
					g = 0,
					b = 0,
				})
		
	end

	return e
end