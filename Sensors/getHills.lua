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

function Queue_new ()
  	return {first = 0, last = -1}
end

function Queue_pushleft (list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function Queue_pushright (list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function Queue_popleft (list)
  	if Queue_empty(list) then error("list is empty") end
	
	  local first = list.first
	local value = list[first]
	list[first] = nil        -- to allow garbage collection
	list.first = first + 1
	return value
end

function Queue_popright (list)
	if Queue_empty(list) then error("list is empty") end
	
	local last = list.last
	local value = list[last]
	list[last] = nil         -- to allow garbage collection
	list.last = last - 1
	return value
end

function Queue_empty(list)
	return list.first > list.last 
end

local function Distance(point, center)
	return math.sqrt((center.x - point.x) * (center.x - point.x) + (center.z - point.z) * (center.z - point.z))
end

local function isCloseEnough(point, center, threshold)
	return Distance(point, center) < threshold
end

local function newHill(point)
	local hill = {}
	hill.points = {}

	hill.center = point

	hill.maxX = point.x
	hill.maxZ = point.z
	hill.minX = point.x
	hill.minZ = point.z

	hill.diameter = {}
	hill.diameter.x = 0
	hill.diameter.z = 0
	
	return hill
end

local function addPointToHill(point, hill)
	-- New point on the hill
	hill.points[#hill.points+1] = point

	-- Updating dimensions of the hill
	if point.x > hill.maxX then hill.maxX = point.x end
	if point.x < hill.minX then hill.minX = point.x end
	if point.z > hill.maxZ then hill.maxZ = point.z end
	if point.z < hill.minZ then hill.minZ = point.z end

	hill.center = {x = hill.minX + (hill.maxX - hill.minX) /2, z = hill.minZ + (hill.maxZ - hill.minZ) /2}
	
	hill.diameter.x = (hill.maxX - hill.minX) /2
	hill.diameter.z = (hill.maxZ - hill.minZ) /2
end


-- @description return hills on the map
return function(gridSize, ratio)
	-- debug drawing inicialization
	if (Script.LuaUI('boundary_init')) then
		Script.LuaUI.boundary_init()
	end
	
	if (Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end

	
	local hills = {}
	local count = 0

	local Lowest, Highest = Extremes()
	local stepX = SizeX / gridSize
	local stepZ = SizeZ / gridSize

	-- every height above this value is considered as a hill
	local hillHeight = Lowest + (Highest - Lowest) * (ratio)

	local function isHill(point)
		return GetHeight(point.x, point.z) > hillHeight
	end

	-- function called when new hill is found
	local function processPoint(highPoints, point)
		local hill = newHill(point)
		
		local q = Queue_new()
		Queue_pushleft(q, point)

		-- BFS to cover whole hill & mark found points (so they won't be added later)
		while not Queue_empty(q) do
			local hillPoint = Queue_popleft(q)

			hillPoint.checked = true
			addPointToHill(hillPoint, hill)

			if highPoints[hillPoint.x+stepX] ~= nil and highPoints[hillPoint.x+stepX][hillPoint.z] ~= nill and not highPoints[hillPoint.x+stepX][hillPoint.z].checked then Queue_pushleft(q, highPoints[hillPoint.x+stepX][hillPoint.z]) end
			if highPoints[hillPoint.x-stepX] ~= nil and highPoints[hillPoint.x-stepX][hillPoint.z] ~= nill and not highPoints[hillPoint.x-stepX][hillPoint.z].checked then Queue_pushleft(q, highPoints[hillPoint.x-stepX][hillPoint.z]) end
			if highPoints[hillPoint.x] ~= nil and highPoints[hillPoint.x][hillPoint.z+stepZ] ~= nill and not highPoints[hillPoint.x][hillPoint.z+stepZ].checked then Queue_pushleft(q, highPoints[hillPoint.x][hillPoint.z+stepZ]) end
			if highPoints[hillPoint.x] ~= nil and highPoints[hillPoint.x][hillPoint.z-stepZ] ~= nill and not highPoints[hillPoint.x][hillPoint.z-stepZ].checked then Queue_pushleft(q, highPoints[hillPoint.x][hillPoint.z-stepZ]) end
		end

		hills[count] = hill
		count = count + 1
	end


	local highPoints = {}
	
	-- samplig for cycle - covers whole map & selects any points, that form a hill
	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			local point = {x=x,z=z,y=GetHeight(x, z), checked = false}
			if isHill(point) then
				if highPoints[x] == nil then highPoints[x] = {} end
				highPoints[x][z] = point
			end
		end
	end

	-- iterates over all "high" points & agregates them into hills
	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			if highPoints[x] ~= nil and highPoints[x][z] ~= nil and not highPoints[x][z].checked then
				processPoint(highPoints, highPoints[x][z])
			end
		end
	end


	-- debug drawing widgets
	if (Script.LuaUI('boundary_update')) then
		for i, hill in pairs(hills) do
			Script.LuaUI.boundary_update(i, { points = hill.points })
		end 
	end

	if (Script.LuaUI('circle_update')) then
		for i, hill in pairs(hills) do
			Script.LuaUI.circle_update(i, { x=hill.center.x,y=hillHeight,z=hill.center.z,radius=30})
		end 
	end

	if (Script.LuaUI('circle_update')) then
		local max = math.max
		for i, hill in pairs(hills) do
			-- different key MUST be selected so the circles doesn't overwrite themselves
			Script.LuaUI.circle_update(i+#hills+#hills, {x=hill.center.x,y=hillHeight,z=hill.center.z,radius= max(hill.diameter.x, hill.diameter.z)})
		end 
	end

	return hills
end