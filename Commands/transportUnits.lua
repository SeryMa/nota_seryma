function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Loads given units",
		parameterDefs = {
			-- { 
			-- 	name = "Units",
			-- 	variableType = "expression",
			-- 	componentType = "editBox",
			-- 	defaultValue = "",
			-- },
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

local function ClearState(self)
	self.threshold = THRESHOLD_DEFAULT
	self.lastleaderPosition = Vec3(0,0,0)
end

local function Move(self, units, fight, position)
	-- pick the spring command implementing the move
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	for i=1, #units do
		SpringGiveOrderToUnit(units[i], cmdID, position, {})
	end
end

local function Load(self, units, target)
	for i=1, #units do
		SpringGiveOrderToUnit(units[i], CMD.LOAD_UNITS, target, {})
	end
end

local function UnLoad(self, units, target)
	for i=1, #units do
		SpringGiveOrderToUnit(units[i], CMD.UNLOAD_UNITS, target, {})
	end
end


function Run(self, units, parameter)
	--local what = parameter.Units
	local where = parameter.Area
	--local where = parameter.Where
	

	if where == nil then
		Load(self, units, what)
	else
		local t = {where.center.x, where.center.y, where.center.z, where.radius}
		Spring.Echo(t)
		Spring.Echo(t[1])
		Load(self, units, t)
	end

	return RUNNING
end


function Reset(self)
	ClearState(self)
end
