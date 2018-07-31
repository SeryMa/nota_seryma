local sensorInfo = {
	name = "HPinArea",
	desc = "Return the total HP in area.",
	author = "PepeAmpere",
	date = "2017-06-12",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- this sensor is not caching any values, it evaluates itself on every request
local HEALTH_IF_UNKNOWN = 300

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- @description Return table with different context HP counts
-- @argument area [table] {center = Vec3, radius = number} 
-- @return HPs [table] table with HP counts for different contexts
return function(area)
	local center = area.center
	local radius = area.radius
	
	-- helper structure in case we consider only our group members (in range) as allies
	local ourGroupMapping = {}
	for i=1, units.length do
		ourGroupMapping[units[i]] = true
	end
	
	local alliedHP = 0
	local ourGroupHP = 0
	local enemyHP = 0
	
	local allUnitsAround = Spring.GetUnitsInSphere(center.x, center.y, center.z, radius)
	
	for i=1, #allUnitsAround do
		local thisUnitID = allUnitsAround[i]
		
		local health = Spring.GetUnitHealth(thisUnitID)
		if (health == nil) then health = HEALTH_IF_UNKNOWN end
		
		local isAllied = Spring.IsUnitAllied(thisUnitID)
		if (isAllied) then
			alliedHP = alliedHP + health
			if (ourGroupMapping[thisUnitID] ~= nil) then -- here we instantly check if unit with given ID is in our group
				ourGroupHP = ourGroupHP + health
			end
		else
			enemyHP = enemyHP + health
		end
	end
	
	return {
		allied = alliedHP,
		ourGroup = ourGroupHP,
		enemy = enemyHP,
	}
end