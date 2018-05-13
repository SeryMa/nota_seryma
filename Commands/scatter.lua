function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Sccaters units accros positions.",
		parameterDefs = {
			{ 
				name = "Targets",
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

local function Move(self, units, position)
	for i=1, #units do
		SpringGiveOrderToUnit(units[i], cmdID, position, {})
	end
end

function Run(self, units, parameter)
	local positions = parameter.Targets -- unitId
	local fight = parameter.fight -- boolean
	
	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	for i,position in pairs(positions) do
		pos = Vec3(position.x, 0, position.z)

		SpringGiveOrderToUnit(units[i], cmdID, pos:AsSpringVector(), {})	
	end

	-- local groupSize = math.floor(#units / #positions)

	-- local send = 0
	-- local pos = 1
	-- while send < #units do

	-- 	local u = {}
	-- 	for unit = send + 1, send + 1 + groupSize do
	-- 		table.insert(u, units[unit])
	-- 	end

	-- 	Spring.Echo("Size")
	-- 	Spring.Echo(#u)

	-- 	--Move(self, u, positions[pos])
	-- 	for i=1, #u do
	-- 		local position = Vec3(positions[pos].x, 0, positions[pos].z)
	-- 		position.y = 0

	-- 		Spring.Echo("vec")
	-- 		Spring.Echo(i)
	-- 		-- Spring.Echo("vec")
	-- 		-- Spring.Echo(position)
	-- 		-- Spring.Echo(position.x)
	-- 		-- Spring.Echo(position.y)
	-- 		-- Spring.Echo(position.z)

	-- 		SpringGiveOrderToUnit(u[i], cmdID, position:AsSpringVector(), {})
	-- 	end

	-- 	pos = pos + 1
	-- 	send = send + #u
	-- end



	return RUNNING
end

function Reset(self)
	ClearState(self)
end
