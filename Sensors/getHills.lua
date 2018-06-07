local sensorInfo = {
	name = "Hills",
	desc = "Returns position of hills on map.",
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
local GetHeight = Spring.GetGroundHeight
local Extremes = Spring.GetGroundExtremes

local Sample = Sensors.nota_seryma.SampleMapStructured
local Aggregate = Sensors.nota_seryma.AggregateGridSample


-- @description return hills on the map
return function(gridSize, ratio)

	local Lowest, Highest = Extremes()

	-- every height above this value is considered as a hill
	local hillHeight = Lowest + (Highest - Lowest) * (ratio)

	local function isHill(point)
		return GetHeight(point.x, point.z) > hillHeight
	end


	local highPoints = Sample(gridSize, isHill)
	
	-- -- samplig for cycle - covers whole map & selects any points, that form a hill
	-- for x = 1, SizeX, stepX do
	-- 	for z = 1, SizeZ, stepZ do
	-- 		local point = {x=x,z=z,y=GetHeight(x, z), checked = false}
	-- 		if isHill(point) then
	-- 			if highPoints[x] == nil then highPoints[x] = {} end
	-- 			highPoints[x][z] = point
	-- 		end
	-- 	end
	-- end

	local hills = Aggregate(highPoints, true)

	--  SizeX = highPoints.sizeX
    --  SizeZ = highPoints.sizeZ

    --  stepX = highPoints.stepX
    --  stepZ = highPoints.stepZ

	-- -- iterates over all "high" points & agregates them into hills
	-- for x = 1, SizeX, stepX do
	-- 	for z = 1, SizeZ, stepZ do
	-- 		if highPoints[x] ~= nil and highPoints[x][z] ~= nil and not highPoints[x][z].checked then
	-- 			processPoint(highPoints, highPoints[x][z])
	-- 		end
	-- 	end
	-- end

	return hills
end