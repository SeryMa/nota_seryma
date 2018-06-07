local sensorInfo = {
	name = "Safe space",
	desc = "Returns spaces that are threat safe.",
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
return function(gridSize, predicate, smooth, debug)
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
			local origin = Vec3(x, GetHeight(x, z), z)
			if predicate(origin) then
				if pointsOfInterest[x][z] == nil then pointsOfInterest[x][z] = {} end
				pointsOfInterest[x][z].origin = origin

				local maxX = x
				local minX = x
				local maxZ = z
				local minZ = z

				for subX = x-stepX, x+stepX, stepX/smooth do
					for subZ = z-stepZ, z+stepZ, stepZ/smooth do				
						local point = Vec3(subX, GetHeight(subX, subZ), subZ)

						if predicate(point) then
							if point.x > maxX then maxX = point.x end
							if point.x < minX then minX = point.x end
							if point.z > maxZ then maxZ = point.z end
							if point.z < minZ then minZ = point.z end
						end
					end
				end

				pointsOfInterest[x][z].smooth = Vec3(minX + (maxX - minX) /2, 0, minZ + (maxZ - minZ) /2)
			end
		end
	end

	-- referencing for cycle - puts references into the sample
	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			if pointsOfInterest[x][z] and pointsOfInterest[x][z].origin then
			-- the first condition would suffice
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
		local offset2 = math.random(10000, 10000000)

        for x = 1, SizeX, stepX do
            for z = 1, SizeZ, stepZ do
                if pointsOfInterest[x][z] and pointsOfInterest[x][z].origin then
                    -- Script.LuaUI.circle_update(
                    --     offset + x*SizeX + z,
                    --     { x=pointsOfInterest[x][z].origin.x,
                    --       y=pointsOfInterest[x][z].origin.y,
                    --       z=pointsOfInterest[x][z].origin.z,
                    --       radius=15,
                    --       r = 200,
                    --       g = 0,
                    --       b = 0,
					-- 	})
						
						Script.LuaUI.circle_update(
							offset2 + x*SizeX + z,
							{ x=pointsOfInterest[x][z].smooth.x,
							  y=pointsOfInterest[x][z].smooth.y,
							  z=pointsOfInterest[x][z].smooth.z,
							  radius=15,
							  r = 0,
							  g = 100,
							  b = 100,
							})

						-- if (Script.LuaUI('exampleDebug_update')) then
						-- 	Script.LuaUI.exampleDebug_update(
						-- 		x*SizeX + z, -- key
						-- 		{	-- data
						-- 			startPos = pointsOfInterest[x][z].origin, 
						-- 			endPos = pointsOfInterest[x][z].smooth
						-- 		}
						-- 	)
						-- end
                end
            end
        end
	end

	return pointsOfInterest
end
