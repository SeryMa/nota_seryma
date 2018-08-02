local sensorInfo = {
	name = "Buying info",
	desc = "Returns code of the best unit to buy.",
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
local goldRatio = {3, 1, 2}
local codes = {"armmav", "armfark", "armspy"}
-- Mavericks, FARKs, Infiltrators


-- @description return safe spaces found on map
return function(units)
	local mavericks = #units.fighters
	local infiltrators = #units.spies
	local farks = #units.collectors

	if infiltrators == 0 then return codes[3] end
	if mavericks <= 3 then return codes[1] end
	if farks == 0 then return codes[2] end

	local all = mavericks + infiltrators + farks
	
	if 2 * mavericks <= all then return codes[1] end
	if farks < 5 and 6 * farks <= all then return codes[2] end
	if infiltrators < 8 and 3 * infiltrators <= all then return codes[3] end

	return codes[1]
end