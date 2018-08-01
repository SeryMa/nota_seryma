function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Move custom group to defined position.",
		parameterDefs = {
			{ 
				name = "groupDefintion",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			{ 
				name = "position",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			{ 
				name = "formation", -- relative formation
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "<relative formation>",
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
	self.lastPointmanPosition = Vec3(0,0,0)
end

function Run(self, units, parameter)
	local customGroup = parameter.groupDefintion -- table
	local position = parameter.position -- Vec3
	local formation = parameter.formation -- array of Vec3
	local fight = parameter.fight -- boolean
	
	if #customGroup == 0 then return SUCCESS end

	--Spring.Echo(dump(parameter.formation))
	
	-- validation
	-- if (#units > #formation) then
		-- Logger.warn("formation.move", "Your formation size [" .. #formation .. "] is smaller than needed for given count of units [" .. #units .. "] in this group.") 
		-- return FAILURE
	-- end
	
	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end
	
	local pointmanID = customGroup[1]
	local pointmanDistance = position:Distance(Vec3(SpringGetUnitPosition(pointmanID)))
	for i = 2, #customGroup do
		local currentDistance = position:Distance(Vec3(SpringGetUnitPosition(customGroup[i])))
		if currentDistance < pointmanDistance then
			pointmanID = customGroup[i]
			pointmanDistance = currentDistance
		end
	end
    
	local pointX, pointY, pointZ = SpringGetUnitPosition(pointmanID)
	local pointmanPosition = Vec3(pointX, pointY, pointZ)

	-- threshold of pointan success
	if (pointmanPosition == self.lastPointmanPosition) then 
		self.threshold = self.threshold + THRESHOLD_STEP 
	else
		self.threshold = THRESHOLD_DEFAULT
	end
	self.lastPointmanPosition = pointmanPosition
	
	-- check pointman success
	-- THIS LOGIC IS TEMPORARY, NOT CONSIDERING OTHER UNITS POSITION
	local pointmanOffset = formation[1]
	local pointmanWantedPosition = position + pointmanOffset
	if (pointmanPosition:Distance(pointmanWantedPosition) < self.threshold) then
		return SUCCESS
	else
		for i=1, #customGroup do
			local unitID = customGroup[i]

			if unitID == pointmanID then 
				SpringGiveOrderToUnit(pointmanID, cmdID, pointmanWantedPosition:AsSpringVector(), {})
			else
				local thisUnitWantedPosition = pointmanPosition - pointmanOffset + formation[1 + (i % #formation)]
				SpringGiveOrderToUnit(unitID, cmdID, thisUnitWantedPosition:AsSpringVector(), {})
			end
		end
		
		return RUNNING
	end
end


function Reset(self)
	ClearState(self)
end
