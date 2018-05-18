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


-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

function getInfo()
    return {
        period = 0 -- no caching
    }
end

function endGame()
    message.SendRules({
        subject = "CTP_playerTriggeredGameEnd",
        data = {},
    })
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


	local i = 1
	while i < #units and i < #positions do
		local position = positions[i%#positions]
		local unit = units[i%#units]

		Spring.Echo("------------------------")
		Spring.Echo(i)
		Spring.Echo(#units)
		Spring.Echo(i%#units)
		Spring.Echo("------------------------")

		pos = Vec3(position.x, position.y, position.z)
		SpringGiveOrderToUnit(unit, cmdID, pos:AsSpringVector(), {})	

	end

	-- if #units > #positions then
	-- 	for i,position in pairs(positions) do
	-- 		pos = Vec3(position.x, position.y, position.z)

	-- 		SpringGiveOrderToUnit(units[i], cmdID, pos:AsSpringVector(), {})	
	-- 	end
	-- end

	return RUNNING
end


function Reset(self)
	ClearState(self)
end
