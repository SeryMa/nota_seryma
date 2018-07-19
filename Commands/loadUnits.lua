function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Loads units inside given area.",
		parameterDefs = {
			{ 
				name = "Targets",
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
		-- either the transporter is already carrying or is going to carry
		-- (no interference of other commands is expected)

		-- Spring.Echo("Max c: " .. UnitDefs[defID].transportCapacity)
		-- Spring.Echo("- laoded " .. #SpringGetTransportedUnits(unitID))
		-- Spring.Echo("- comms " .. SpringGetUnitCommands(unitID, 0))

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

function getFreeTransporter(units, lastIndex)
	for i = lastIndex, #units do
		local realCapacity = getSingleCapacity(units[i])

		if realCapacity > 0 then
			return units[i], realCapacity, i+1
		end
	end

	return nil, 0
end

function issueLoadingCommandToUnit(unitID, area)
	Spring.GiveOrderToUnit(unitID, CMD.LOAD_UNITS, {area.center.x, area.center.y, area.center.z, area.radius}, {})
end

local targets
local init
function Run(self, units, parameter)
	if not init then
		init = true
		targets = parameter.Targets
	end

	--TODO: remove debug widget using
	local debug = false
    if (debug and Script.LuaUI('circle_update')) then
		if (debug and Script.LuaUI('circle_init')) then Script.LuaUI.circle_init() end
    
		for i = 1, #targets do
			local x, y, z = Spring.GetUnitPosition(targets[i])
			Script.LuaUI.circle_update(
				i,
				{ x=x,
					y=y,
					z=z,
					radius=15,
					r = 0,
					g = 0,
					b = 100,
				})
        end
    end

	local targetCount = math.min(#targets, getCapacity(units))

	-- Spring.Echo("Selected: " .. targetCount)
	-- Spring.Echo("T " .. #targets)
	-- Spring.Echo("C " .. getCapacity(units))

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
	local transporterIndex = 1
	while i < targetCount do
		-- local transporter = units[i+1]
		-- local capacity = getSingleCapacity(transporter)

		local transporter, capacity, foundIndex = getFreeTransporter(units, transporterIndex)
		transporterIndex = foundIndex

		-- all transports are full -- most probably an issue with order queue
		if not transporter or capacity == 0 then return FAILURE end

		for _ = 1, capacity do
			target = table.remove(targets)

			SpringGiveOrderToUnit(transporter, CMD.LOAD_UNITS, {target}, {"shift"})
		end

		i = i + capacity
	end

	return RUNNING
end


function Reset(self)
	targets = nil
	init = false
end
