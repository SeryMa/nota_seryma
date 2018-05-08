function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Move according to wind.",
		parameterDefs = {
			{ 
				name = "fight",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "false",
			}
		}
	}
end

-- constants
local THRESHOLD_STEP = 25
local THRESHOLD_DEFAULT = 0

-- speedups
local SpringGetWind = Spring.GetWind
local SpringGetUnitPosition = Spring.GetUnitPosition
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

local function ClearState(self)
	self.threshold = THRESHOLD_DEFAULT
	self.lastleaderPosition = Vec3(0,0,0)
end

function Run(self, units, parameter)
	local fight = parameter.fight -- boolean
	
	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	local dirX, dirY, dirZ, strength, normDirX, normDirY, normDirZ = SpringGetWind()
	local windDirection = Vec3(normDirX, normDirY, normDirZ) * strength
 
	Spring.Echo("listenToWind - [" .. strength .. "] [" .. normDirX .. "] [" .. normDirY)
	Spring.Echo("listenToWind - [" .. #windDirection .. "] [" .. dirX .. "] [" .. dirY)

	for i=1, #units do
		local unit = units[i]
		local unitPosition = Vec3(SpringGetUnitPosition(units[i]))
		local finalPosition = unitPosition+windDirection

		
		Spring.Echo("listenToWind - [" .. #windDirection .. "] [" .. #unitPosition .. "] [" .. #finalPosition)
		SpringGiveOrderToUnit(unit, cmdID, finalPosition, {})
	end
	
	return RUNNING
end


function Reset(self)
	ClearState(self)
end
