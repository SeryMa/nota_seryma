function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Drop units into given area.",
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

function isEmpty(unitID)
	local defID = SpringGetUnitDefID(unitID)

	if defID and UnitDefs[defID] and UnitDefs[defID].isTransport then
		return #SpringGetTransportedUnits(unitID) == 0
	end

	return true
end


function issueUnLoadingCommandToUnit(unitID, area)
	SpringGiveOrderToUnit(unitID, CMD.UNLOAD_UNITS, {area.center.x, area.center.y, area.center.z, area.radius}, {})
	
	SpringGiveOrderToUnit(unitID, CMD.MOVE, {area.center.x - area.radius - math.random(-150, 250), area.center.y, area.center.z + area.radius + math.random(-150, 250)}, {"shift"})
end


function Run(self, units, parameter)
	math.randomseed(os.time())

	local allDone = true
	for i = 1, #units do
		if SpringGetUnitCommands(units[i], 0) == 0 then
			if isEmpty(units[i]) then
				allDone = allDone and true
			else
				allDone = false

				--perform unloading
				if SpringGetUnitCommands(units[i], 0) == 0 then
					issueUnLoadingCommandToUnit(units[i], parameter.Area)
				end
			end
		else
			allDone = false
		end
	end

	if allDone then return SUCCESS
	else return RUNNING end

end


function Reset(self)

end
