local sensorInfo = {
	name = "GetUnitsInArea",
	desc = "Return number of units in given area - filtered by name.",
	author = "SeryMa",
	date = "2018-19-08",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- this sensor is not caching any values, it evaluates itself on every request

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

local GetUnitsInSphere = Spring.GetUnitsInSphere
local GetUnitDefID = Spring.GetUnitDefID

return function(area, name)
	local center = area.center
    local radius = area.radius
    
    local allUnitsAround = GetUnitsInSphere(center.x, center.y, center.z, radius)

    local found = 0

	for i=1, #allUnitsAround do
        local unitID = allUnitsAround[i]
        local unitName = UnitDefs[GetUnitDefID(unitID)].name 

        if name and unitName == name then
            found = found +1
        end
	end
	
	return found
end