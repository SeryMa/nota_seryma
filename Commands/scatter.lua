function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Sccaters units accros given positions.",
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
			},
			{ 
				name = "distanceThreshold",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "100",
			}
		}
	}
end


-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

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
local GetUnitPosition = Spring.GetUnitPosition
local GiveOrderToUnit = Spring.GiveOrderToUnit

local function ClearState(self)
	self.threshold = THRESHOLD_DEFAULT
	self.lastleaderPosition = Vec3(0,0,0)
end

local sqrt = math.sqrt
local function Distance(point, center)
	return sqrt((center.x - point.x) * (center.x - point.x) + (center.z - point.z) * (center.z - point.z))
end

function Run(self, units, parameter)
	local positions = parameter.Targets -- array of positions
	local fight = parameter.fight -- boolean
	local distanceThreshold = parameter.distanceThreshold 

	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	local done = 0

	local max = 0
	if #units > #positions then max = #units
	else max = #positions end

	for i = 0, max-1 do
		local position = positions[1 + i%#positions]
		local unit = units[1 + i%#units]

		if Distance(position, Vec3(GetUnitPosition(unit))) < distanceThreshold then
			done = done + 1
		else
			pos = Vec3(position.x, position.y, position.z)
			GiveOrderToUnit(unit, cmdID, pos:AsSpringVector(), {})
		end
	end

	-- once 90% of units arrives to given destination declare SUCCESS
	if done > 0.9 * #units then return SUCCESS
	else return RUNNING
	end
end


function Reset(self)
	ClearState(self)
end
