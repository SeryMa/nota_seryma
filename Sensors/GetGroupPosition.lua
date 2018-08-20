local sensorInfo = {
	name = "Position",
	desc = "Return position of a unit.",
	author = "SeryMa",
	date = "2017-04-22",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups
local GetUnitPosition = Spring.GetUnitPosition
local isDead = Spring.GetUnitIsDead

local function average(tab, trim)
    if trim == nil then trim = 0 end

    local sum = 0
    
    local count = #tab
    local trimCount = math.floor(trim * count)

    for i = trimCount+1, count - trimCount do
        sum = sum + tab[i]
    end
     
    return sum / (count - 2*trimCount)
end


-- @description return of the given unit
return function(units)

    if debug and (Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end

    local xs = {}
    local ys = {}
    local zs = {}

    for i = 1, #units do
        local unit = units[i]

        if unit ~= nil and not isDead(unit) then  
            local x, y, z = GetUnitPosition(unit)
            
            xs[#xs +1] = x
            ys[#ys +1] = y
            zs[#zs +1] = z
        end
    end

    table.sort(xs)
    table.sort(ys)
    table.sort(zs)

    -- for i = 1, #xs do
    --     Spring.Echo(xs[i])
    -- end

	return Vec3(average(xs, 0.2), average(ys, 0.2), average(zs, 0.2))
end