function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Loads given units.",
		parameterDefs = {
			{ 
				name = "What",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "",
			},
			-- { 
			-- 	name = "fight",
			-- 	variableType = "expression",
			-- 	componentType = "editBox",
			-- 	defaultValue = "false",
			-- }
			-- { 
			-- 	name = "Where",
			-- 	variableType = "expression",
			-- 	componentType = "editBox",
			-- 	defaultValue = "",
			-- },
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
	local what = parameter.What
	--local where = parameter.Where
	
	

	Spring.Echo()

	Load(self, units, what)

	return RUNNING
end


function Reset(self)
	ClearState(self)
end
