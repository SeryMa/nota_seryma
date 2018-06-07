local sensorInfo = {
	name = "StructuredSample",
	desc = "Samples map using predicate - returns valid points as a [x][z] grid.",
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

	pointsOfInterest.stepX = stepX
    pointsOfInterest.stepZ = stepZ
    
    pointsOfInterest.sizeX = SizeX
    pointsOfInterest.sizeZ = SizeZ
	
	-- samplig for cycle - covers whole map & selects any points, that are interesting for us
	for x = 1, SizeX, stepX do
		if pointsOfInterest[x] == nil then pointsOfInterest[x] = {} end
		for z = 1, SizeZ, stepZ do
			local point = Vec3(x, GetHeight(x, z), z)
			if predicate(point) then
				pointsOfInterest[x][z] = point
--			else
--			 	pointsOfInterest[x][z] = nil
			end
		end
	end

	-- referencing for cycle - puts references into the sample
	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			if pointsOfInterest[x][z] then
				pointsOfInterest[x][z].top = pointsOfInterest[x-stepX] and pointsOfInterest[x-stepX][z] or nil
				pointsOfInterest[x][z].bottom = pointsOfInterest[x+stepX] and pointsOfInterest[x+stepX][z] or nil
				pointsOfInterest[x][z].left = pointsOfInterest[x][z-stepZ]
				pointsOfInterest[x][z].right = pointsOfInterest[x][z+stepZ]
			end
		end
	end

    
    if (debug and Script.LuaUI('circle_update')) then
        math.randomseed(os.time())
        local offset = math.random(10000, 10000000)

        for x = 1, SizeX, stepX do
            for z = 1, SizeZ, stepZ do
                if pointsOfInterest[x][z] then
                    Script.LuaUI.circle_update(
                        offset + x*SizeX + z,
                        { x=pointsOfInterest[x][z].x,
                          y=pointsOfInterest[x][z].y,
                          z=pointsOfInterest[x][z].z,
                          radius=15,
                          r = 0,
                          g = 0,
                          b = 100,
                        })
                end
            end
        end
	end

	return pointsOfInterest
end