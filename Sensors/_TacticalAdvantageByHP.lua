local sensorInfo = {
	name = "tacticalAdvantageByHPForGroundAttack",
	desc = "Return T/F if there is higher tactical advantage by HP than wanted.",
	author = "PepeAmpere",
	date = "2017-19-03",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 60 -- once per two seconds is enough

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- @description Return ratio of HP of friendly and enemey units
-- @argument radius [number] max distance scanned
-- @return number [number] value between 0 (only enemy units) and 1 (only allied units)
-- @comment 1) There exist "units" table containing all group units in given context
-- @comment 2) First unit in "unitGroup" is conisdered to be leader/pointman of the whole group
return function(radius, unitGroup, advantageThreshold)
    if unitGroup == nil then unitGroup = units end
    if advantageThreshold == nil then advantageThreshold = 0.7 end

	if (#unitGroup < 1) then -- if we have not at least one unit
		return false
	end	
	local pointmanX, pointmanY, pointmanZ = Spring.GetUnitPosition(unitGroup[1])
	local pointmanPosition = Vec3(pointmanX, pointmanY, pointmanZ)
	local currentTacticalAdvantage = Sensors.map.TacticalAdvantageByHP(pointmanPosition, radius, true)
	
	-- enough for attack?
	if (currentTacticalAdvantage >= advantageThreshold) then
        return true
    else
        return false
	end
end