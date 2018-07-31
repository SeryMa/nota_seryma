local sensorInfo = {
	name = "Get units",
	desc = "Returns all players unit, categorized for DOTA uses.",
	author = "SeryMa",
	date = "2017-05-16",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 60 

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups

local defaultCategorization = {
	fighters = {"armmav"},
	collectors = {"armfark"},
	spies = {"armspy"},
	artillery = {"armbox"},
	transport = {"armatlas"},
}

-- @description return safe spaces found on map
return function(categorization)
	if categorization == nil then categorization = defaultCategorization end

	local units = {}
	units["free"] = {} 

	local uncategorizedUnits =  Spring.GetTeamUnits(Spring.GetMyTeamID())

	for category, types in pairs(categorization) do
		units[category] = {}

		for i=1, #uncategorizedUnits do
			local unitID = uncategorizedUnits[i]
			local unitName = UnitDefs[Spring.GetUnitDefID(unitID)].name 

			local categorized = false
			for j = 1, #types do
				if unitName == types[j] then
					units[category][#units[category]+1] = unitID
					categorized = true

					--Spring.Echo("unit " .. unitName .. " going into " .. category)
				end			
			end

			if not categorized then
				units["free"] [#units["free"]+1] = unitID
				--Spring.Echo("unit " .. unitName .. " is uncat")
			end
		end		
	end




	return units
end