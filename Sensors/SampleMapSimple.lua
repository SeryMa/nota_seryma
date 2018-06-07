local sensorInfo = {
	name = "SimpleSample",
	desc = "Samples map using predicate - returns valid points as a 1D table. Fewer predicate calls, compared to the structured version.",
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
local SizeX = Game.mapSizeX
local SizeZ = Game.mapSizeZ

local GetHeight = Spring.GetGroundHeight

-- @description return samples on the map
return function(gridSize, predicate, debug)
	if (debug and Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end

	local pointsOfInterest = {}
	local count = 0

	local stepX = SizeX / gridSize
	local stepZ = SizeZ / gridSize
	
	-- samplig for cycle - covers whole map & selects any points, that are interesting for us
	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			local point = Vec3(x, GetHeight(x, z), z)
			if predicate(point) then
				count = count + 1
				pointsOfInterest[count] = point
			end
		end
	end

	if (debug and Script.LuaUI('circle_update')) then
		for i =1, #pointsOfInterest do
			Script.LuaUI.circle_update(i, { poin,radius=5})
		end 
	end

	return pointsOfInterest
end