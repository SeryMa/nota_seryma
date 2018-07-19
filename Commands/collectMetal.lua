function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Move to metal position",
		parameterDefs = {
			{ 
				name = "safePoints",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			{ 
				name = "safeDistance",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "200",
			},
		}
	}
end


-- speed-ups
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit
local GetUnitPosition = Spring.GetUnitPosition
local SpringGetUnitsInArea = Spring.GetUnitsInCylinder
local SpringGetUnitDefID = Spring.GetUnitDefID
local SpringGetUnitCommands = Spring.GetUnitCommands

local function getRange(unit)
	return UnitDefs[SpringGetUnitDefID(unit)].losRadius
end

local function Collect(unit)
	local collectingSpot = Vec3(GetUnitPosition(unit))	
	local range = getRange(unit)

	-- only issue the command if the command queue is empty
	if Spring.GetCommandQueue(unit, 0) < 1 then	
		SpringGiveOrderToUnit(unit,  CMD.RECLAIM, {collectingSpot.x, collectingSpot.y, collectingSpot.z, 2*range}, {"shift"})		
	end

	-- local foreman = units[1]
	-- local collectingSpot = Vec3(GetUnitPosition(foreman))
	
	-- --Define features to be collected
	-- local range = UnitDefs[SpringGetUnitDefID(foreman)].losRadius

	-- --Check how many features with metal are left
	-- local listFeaturesArea = Spring.GetFeaturesInCylinder(collectingSpot.x, collectingSpot.z, range)

	-- local restToBeCollected = false
	-- for k = 1, #listFeaturesArea do 	
	-- 	local remainingMetal,_,_,_,_ = Spring.GetFeatureResources(listFeaturesArea[k])
	-- 	if remainingMetal > 0 then
	-- 		restToBeCollected = true
	-- 	end	
	-- end
	
	-- --Spring.Echo(dump(restToBeCollected))
	
	-- -- check success	
	-- if (not restToBeCollected) then
	-- 	return SUCCESS
	
	-- -- give order to collect
	-- else
	-- 	if (not self.haveorders or (Spring.GetCommandQueue(units[1], 0) < 1)) then
	-- 		for i=1, #units do
	-- 			SpringGiveOrderToUnit(units[i],  CMD.RECLAIM, {collectingSpot.x, collectingSpot.y, collectingSpot.z, range}, {})
	-- 		end
	-- 		self.haveorders = true
	-- 	end
	-- end
end





--local GetEnemies = Sensors.nota_seryma.GetEnemiesInArea
local function canSeeEnemy(unit)
	return Spring.GetUnitNearestEnemy(unit, getRange(unit), false) ~= nil
end

local function getClosest(pos, points)
	local distance = points[1]:Distance(pos)
	local point = points[1]
	for i = 2, #points do
		local actDist = points[i]:Distance(pos)
		if distance > actDist then
			distance = actDist
			point = points[i]
		end
	end

	return point
end


local function ClearState(self)
end

function Run(self, units, parameter)
	for i = 1, #units do
		local unit = units[i]
		local pos = Vec3(GetUnitPosition(unit))
		local safePoint = getClosest(pos, parameter.safePoints)

		-- if can see enemy, or the unit is far away, return to base, else keep collecting
		if canSeeEnemy(unit) or pos:Distance(safePoint) > parameter.safeDistance then
			-- retreat to safe position
			SpringGiveOrderToUnit(unit,  CMD.MOVE, {safePoint.x, safePoint.y, safePoint.z}, {})
		else
			-- if no enemy to see => collect metal
			Collect(unit)
		end
	end
	
	
	return RUNNING
end


function Reset(self)
	ClearState(self)
end
