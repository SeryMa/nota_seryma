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
local GetHeight = Spring.GetGroundHeight
local Extremes = Spring.GetGroundExtremes

local Sample = Sensors.nota_seryma.SampleMapStructured
local SmoothSample = Sensors.nota_seryma.SmoothSample
local Aggregate = Sensors.nota_seryma.AggregateGridSample
local GetEnemies = Sensors.nota_seryma.GetEnemiesInArea


local function GetAreaAroundPoint(point, radius)
	local area = {}

	area.center = point
	area.radius = radius

	return area
end

local function GetRange(teamID)
	local IDs = Spring.GetTeamUnitsCounts(teamID)

	local max = nil

	for ID,_ in pairs(IDs) do
		if ID ~= "n" and ID ~= "unknown" and max < UnitDefs[ID].maxWeaponRange then
			max = UnitDefs[ID].maxWeaponRange
		end
	end

	return max and max or 1000 -- hard-coded threshold
end

-- @description return safe spaces found on map
return function(gridSize, assurance, ratio, debug)

	local avoidRange = assurance * GetRange(1) --hard-coded team number!!!

	local function isEnemySafe(point)
		--return GetHeight(point.x, point.z) < hillHeight
		local s = GetAreaAroundPoint(point, avoidRange) 
		local e = GetEnemies(s)
		
		return #e == 0
	end

	local Lowest, Highest = Extremes()
	-- every below this value is considered as a safe
	local safeHeight = Lowest + (Highest - Lowest) * (ratio)
	local function isLow(point)
		return GetHeight(point.x, point.z) < safeHeight
	end

	local function isSafe(point)
		return isLow(point) or isEnemySafe(point)
	end

	--local safePoints = Sample(gridSize, isSafe, false)
	local safePoints = SmoothSample(gridSize, isSafe, 5, debug) 
	

	return safePoints 
end