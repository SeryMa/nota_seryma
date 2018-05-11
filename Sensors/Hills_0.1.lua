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

-- speedups
local GetHeight = Spring.GetGroundHeight
local SizeX = Game.mapSizeX
local SizeZ = Game.mapSizeZ
local Extremes = Spring.GetGroundExtremes

local function Distance(point, center)
	return math.sqrt((center.x - point.x) * (center.x - point.x) + (center.z - point.z) * (center.z - point.z))
end

local function isCloseEnough(point, center, threshold)
	return Distance(point, center) < threshold
end

-- @description return hills on the map
return function(gridSize, ratio)
	if (Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end

	if (Script.LuaUI('boundary_init')) then
		Script.LuaUI.boundary_init()
	end
	
	local hills = {}
	local count = 0

	local Lowest, Highest = Extremes()

	local stepX = SizeX / gridSize
	local stepZ = SizeZ / gridSize

	local boundaryStepX = stepX / gridSize
	local boundaryStepZ = stepZ / gridSize

	local hillHeight = Lowest + (Highest - Lowest) * (ratio)

	local function isHill(point)
		return GetHeight(point.x, point.z) > hillHeight
	end

	local function newHill(point)
		local hill = {}
		hill.boundary = {}
		local edge = point

		while isHill(edge) do
			edge.x = edge.x+boundaryStepX
		end
		edge.x = edge.x-boundaryStepX

		table.insert(hill.boundary, edge)

		local x = edge.x
		local z = edge.z

		while #hill.boundary < 3 or Distance({x=x,z=z}, edge) > math.max(boundaryStepX, boundaryStepZ) do
			
			
			local top = isHill({x=x+boundaryStepX, z=z})
			local left = isHill({x=x, z=z+boundaryStepZ})
			local bottom = isHill({x=x-boundaryStepX, z=z})
			local right = isHill({x=x, z=z-boundaryStepZ})
			
			if not top and left then
				table.insert(hill.boundary, {x=x, z=z+boundaryStepZ})
				z = z+boundaryStepZ
			end
			if not left and bottom then
				table.insert(hill.boundary, {x=x-boundaryStepX, z=1})
				x = x-boundaryStepX
			end
			if not bottom and right then
				table.insert(hill.boundary, {x=x, z=z-boundaryStepZ})
				z = z-boundaryStepZ
			end
			if not right and top then
				table.insert(hill.boundary, {x=x+boundaryStepX, z=z})
				x=x+boundaryStepX
			end
		end

		local maxX = hill.boundary[1].x
		local maxZ = hill.boundary[1].z
		local minX = hill.boundary[1].x
		local minZ = hill.boundary[1].z

		for _, boundary in pairs(hill.boundary) do
			if boundary.x > maxX then maxX = boundary.x end
			if boundary.x < minX then minX = boundary.x end
			
			if boundary.z > maxZ then maxZ = boundary.z end
			if boundary.z < minZ then minZ = boundary.z end
		end

		hill.center = {x = minX+ (maxX - minX) /2, z = minZ + (maxZ - minZ) /2}
		hill.diameter = math.max(maxX-minX, maxZ-minZ)
		hill.height = GetHeight(hill.center.x, hill.center.z)

		return hill
	end

	local function processPoint(point)
		--local point = {x=x,z=z}

		for i, hill in pairs(hills) do
			if isCloseEnough(point, hill.center, hill.diameter) then return end
		end
		
		--hills[count] = Vec3(x, GetHeight(x,z), z)
		hills[count] = newHill(point)
		count = count + 1
	end

	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			if GetHeight(x,z) > hillHeight then
				processPoint({x=x,z=z})
			end
		end
	end

	if (Script.LuaUI('boundary_update')) then
		for i, hill in pairs(hills) do
			Script.LuaUI.boundary_update(
				i, -- key
				{	-- data
					points = hill.boundary
				}
			)
		end 
	end

	if (Script.LuaUI('circle_update')) then
		for i, hill in pairs(hills) do
			Script.LuaUI.circle_update(
				i, -- key
				{	-- data
					x=hill.center.x,y=hillHeight,z=hill.center.z,radius=hill.diameter
				}
			)
			break
		end 
	end

	return hills
end