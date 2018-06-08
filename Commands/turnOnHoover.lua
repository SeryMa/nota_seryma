function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Changesmode of all given units.",
		parameterDefs = {
			{ 
				name = "mode",
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


function Run(self, units, parameter)
	for i = 1, #units do
		Spring.GiveOrderToUnit(units[i], CMD.IDLEMODE, {parameter.mode}, {})
	end
	
	return SUCCESS
end


function Reset(self)
end
