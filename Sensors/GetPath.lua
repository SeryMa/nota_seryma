local sensorInfo = {
	name = "Get path",
	desc = "Gets path using provided nav graph.",
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

function getNearestNavPoint(navGraph, point)
	local dist = nil
	local coords = nil

	for i = 1, #navGraph do
		local newDist = navGraph[i].smooth:Distance(point)
		if not coords or newDist < dist then
			dist = newDist
			coords = navGraph[i]
		end
	end

	return coords
end

-- speedups


-- @description return path as points from navGraph leading 'to'
return function(navGraph, to, debug)
	local to = getNearestNavPoint(navGraph, to)

	local path = {}

	while to.prev do
		path[#path+1] = to
		to = to.prev
	end

	if debug and (Script.LuaUI('line_init')) then
		Script.LuaUI.line_init()
	end
	if debug and (Script.LuaUI('line_update')) then
		for i=1, #path do
			if path[i].prev then
				Script.LuaUI.line_update({from = path[i].smooth, to = path[i].prev.smooth})
			end
		end
	end

	if debug and (Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end
	if (debug and Script.LuaUI('circle_update')) then
        math.randomseed(os.time())
		local offset = math.random(10000, 10000000)
		
		for i=1, #path do
				Script.LuaUI.circle_update(
					offset + i,
					{ x=path[i].smooth.x,
					  y=path[i].smooth.y,
					  z=path[i].smooth.z,
					  radius=20,
					  r = 200,
					  g = 100,
					  b = 100,
					})
		end
	end
	
	return path 
end