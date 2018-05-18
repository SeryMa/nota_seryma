local sensorInfo = {
	name = "Debug",
	desc = "",
	author = "SeryMa",
	date = "2018-04-16",
	license = "none",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- @description return current wind statistics
return function(units)

	local ID = units[1]

	Spring.Echo(ID)
	Spring.Echo(UnitDefs[ID])

	for i = 1, 5000 do
		if UnitDefs[i] then
			Spring.Echo(UnitDefs[i].humanName)
			Spring.Echo(i)
			
		end
	end

	
	return UnitDefs[ID]

end
