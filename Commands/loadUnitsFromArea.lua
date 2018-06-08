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
			{ 
				name = "SafeArea",
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
		local realCapacity = getSingleCapacity(units[i])

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
local init
function Run(self, units, parameter)
	if not init then
		init = true
		targets = {}
		local unitsInArea = getTargets(parameter.Area)
		local safeUnits = getTargets(parameter.SafeArea)

		for i = 1, #unitsInArea do
			local potentialTarget = unitsInArea[i]
			local colide = false 
			for j = 1, #units do
				if potentialTarget == units[j] then
					-- we have transports inside rescue area
					colide = true
				end
			end

			for j = 1, #safeUnits do
				if potentialTarget == safeUnits[j] then
					-- we have transports inside rescue area
					colide = true
				end
			end

			if not colide then targets[#targets+1] = potentialTarget end
		end
	end

	local debug = true
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
	local i = 1
	while i <= targetCount do
		local transporter = units[i]
		local capacity = getSingleCapacity(transporter)

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
