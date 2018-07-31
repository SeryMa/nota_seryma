local sensorInfo = {
	name = "Read line",
	desc = "Returns info about given line.",
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
local GetUnits = Spring.GetUnitsInCylinder
local getIntel = Sensors.core.MissionInfo

local US = Spring.GetMyTeamID()
local THEM = 1 -- couldn't figure how to get this number properly...

-- @description return safe spaces found on map
return function(line, currentInfo, debug)
	local lineInfo
	if line == "Top" or line == "top" then lineInfo = currentInfo.corridors.Top.points
	elseif line == "Middle" or line == "mid" then lineInfo = currentInfo.corridors.Middle.points
	elseif line == "Bottom" or line == "bot" then lineInfo = currentInfo.corridors.Bottom.points
	else 
		Spring.Echo("Wrong parameter given: " .. line)
		return nil
	end

	local intel = {}

	local ourLastStrong
	local dangerZone = {}
	for i = 1, #lineInfo do
		if lineInfo[i].isStrongpoint then
			if lineInfo[i].ownerAllyID == US then
				ourLastStrong = lineInfo[i]
				dangerZone = {}
			else
				intel.lastOurs = ourLastStrong
				intel.firstTheir = lineInfo[i]
				intel.dangerZone = dangerZone
				break
			end
		else
			dangerZone[#dangerZone+1] = lineInfo[i]
		end
	end
	
	if debug and (Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end

	-- if no enemy strongpoint is found, there is nothig of value going on this line
	if intel.firstTheir == nil then return nil end

	if (debug and Script.LuaUI('circle_update')) then
        math.randomseed(os.time())
		local offset = math.random(10000, 10000000)
		
		for i=1, #intel.dangerZone do
				Script.LuaUI.circle_update(
					offset + i,
					{ x=intel.dangerZone[i].position.x,
					  y=intel.dangerZone[i].position.y,
					  z=intel.dangerZone[i].position.z,
					  radius=20,
					  r = 200,
					  g = 100,
					  b = 100,
					})
		end

		Script.LuaUI.circle_update(
				offset,
				{ x=intel.lastOurs.position.x,
				  y=intel.lastOurs.position.y,
				  z=intel.lastOurs.position.z,
				  radius=40,
				  r = 000,
				  g = 000,
				  b = 200,
				})
		Script.LuaUI.circle_update(
				offset-1,
				{ x=intel.firstTheir.position.x,
				  y=intel.firstTheir.position.y,
				  z=intel.firstTheir.position.z,
				  radius=40,
				  r = 200,
				  g = 000,
				  b = 000,
				})
	end


	return intel
end