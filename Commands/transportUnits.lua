function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Loads units inside given area.",
		parameterDefs = {
			{ 
				name = "Area",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
		}
	}
end


-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

-- @description return current wind statistics
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
local SpringGetTransportedUnits = Spring.GetUnitIsTransporting
local SpringGetUnitsInArea = Spring.GetUnitsInCylinder
local SpringGetUnitDefID = Spring.GetUnitDefID
local SpringGetUnitCommands = Spring.GetUnitCommands


local teamID = Spring.GetLocalTeamID()

function getTargets(area)
	return SpringGetUnitsInArea(area.center.x, area.center.z, area.radius, teamID)
end

function getSingleCapacity(unitID)
	local defID = SpringGetUnitDefID(unitID)

	--local capacity = defId and 0 or UnitDefs[defId].transportCapacity
	local capacity = 0
	if defID and UnitDefs[defID] and UnitDefs[defID].isTransport then
		capacity = UnitDefs[defID].transportCapacity
					- #SpringGetTransportedUnits(unitID)
					- SpringGetUnitCommands(unitID, 0)
	end

	return capacity
end

function getCapacity(units)
	local capacity = 0
	for i = 1, #units do
		capacity = capacity + getSingleCapacity(units[i])
	end
	
	return capacity
end

function getFreeTransporter(units)
	for i = 1, #units do
		-- either the transporter is already carrying or is going to carry
		-- (no interference of other commands is expected)
		local realCapacity = getSingleCapacity(units[i]) - SpringGetUnitCommands(units[i], 0)

		if realCapacity > 0 then
			return units[i], realCapacity
		end
	end

	return nil, 0
end

function issueLoadingCommandToUnit(unitID, area)
	Spring.GiveOrderToUnit(unitID, CMD.LOAD_UNITS, {area.center.x, area.center.y, area.center.z, area.radius}, {})
end

local targets
function Run(self, units, parameter)
	if not targets then targets = getTargets(parameter.Area) end

	local targetCount = math.min(#targets, getCapacity(units))

	Spring.Echo("Capacity: " .. getCapacity(units))
	Spring.Echo("Targets: " .. #targets)
	Spring.Echo("TarCount: " .. targetCount)

	if targetCount == 0 then
		for i = 1, #units do
			if SpringGetUnitCommands(units[i], 0) ~= 0 then
				return RUNNING
			end
		end

		-- no targets and no issued commands - win!
		return SUCCESS
	end

	-- give command to all units
	local i = 0
	while i < targetCount do
		local transporter, capacity = getFreeTransporter(units)

		-- all transports are full -- most probably an issue with order queue
		if not transporter then return FAILURE end

		local ts = {}
		for _ = 1, capacity do
			target = table.remove(targets)

			SpringGiveOrderToUnit(transporter, CMD.LOAD_UNITS, {target}, {})
		end

		i = i + capacity
	end

	-- -- check whether all units fullfilled their commands
	-- for i = 1, #units do
	-- 	if SpringGetUnitCommands(units[i], 0) > 0 then return RUNNING end
	-- end

	return RUNNING
end


function Reset(self)
	targets = nil
end
