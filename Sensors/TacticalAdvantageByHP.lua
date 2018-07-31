local sensorInfo = {
	name = "tacticalAdvantageByHP",
	desc = "Return advantage value based on sums of HPs of friendly and enemy units in given radius.",
	author = "PepeAmpere",
	date = "2017-19-03",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- this sensor is not caching any values, it evaluates itself on every request

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- @description Return ratio of HP of friendly and enemey units
-- @argument center [Vec3] vector which defines center of the scanned area
-- @argument radius [number] max distance scanned
-- @argument onlyOurGroup [boolean|optional] TRUE (default): all our group members in given radius considered, FALSE: all friendly units in given radius considered
-- @return number [number] value between 0 (only enemy units) and 1 (only allied units)
-- @comment 1) There exist "units" table containing all group units in given context
return function(center, radius, onlyOurGroup) -- TBD reworked to "area" type
	if (onlyOurGroup == nil) then onlyOurGroup = true end -- in not defined, it is TRUE
	if (onlyOurGroup and units.length == 0) then -- if we have no units
		return 0
	end	
	if (onlyOurGroup and not Sensors.Common.groupEnemyInRange(radius)) then -- no enemies around (the condition of the sensor is stronger than we need, but its ok)
		return 1
	end
	
	-- TBD reworked to "area" type
	local areaHPs = Sensors.map.HPinArea({center = center, radius = radius})
	local alliedHP = areaHPs.allied
	local enemyHP = areaHPs.enemy
	
	-- conditions at the beginning make sure we do not divide by zero
	return alliedHP/(alliedHP + enemyHP)
end