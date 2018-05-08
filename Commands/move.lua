function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Move to defined position",
		parameterDefs = {
			{ 
				name = "GroupLeader",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
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

-- speed-ups
local SpringGetUnitPosition = Spring.GetUnitPosition
local SpringGiveOrderToUnit = Spring.GiveOrderToUnit

local function ClearState(self)
	self.threshold = THRESHOLD_DEFAULT
	self.lastleaderPosition = Vec3(0,0,0)
end

function Run(self, units, parameter)
	local leader = parameter.GroupLeader -- unitId
	local fight = parameter.fight -- boolean
	
	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	local pointX, pointY, pointZ = SpringGetUnitPosition(leader)
	local leaderPosition = Vec3(pointX, pointY, pointZ)
	
	-- threshold of leader success
	if (leaderPosition == self.lastleaderPosition) then 
		self.threshold = self.threshold + THRESHOLD_STEP 
	else
		self.threshold = THRESHOLD_DEFAULT
	end
	self.lastleaderPosition = leaderPosition
	
	-- check leader success
	-- THIS LOGIC IS TEMPORARY, NOT CONSIDERING OTHER UNITS POSITION

		
	for i=1, #units do
		SpringGiveOrderToUnit(units[i], cmdID, leaderPosition:AsSpringVector(), {})
	end
	
	return RUNNING
end


function Reset(self)
	ClearState(self)
end
