local sensorInfo = {
	name = "Utils",
	desc = "Returns table of utility functions. This 'sensor' is NOT meant to be called within game - it's designed for lua calls only.",
	author = "SeryMa",
	date = "2017-05-16",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- speedups


-- functions
function moveGroup(destination, group, fight)
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	for i=1, #group do
		moveSingle(destination, group[i], fight)
	end
end

function moveSingle(destination, unitId, fight)
	local cmdID = CMD.MOVE
	if (fight) then cmdID = CMD.FIGHT end

	SpringGiveOrderToUnit(unitId, cmdID, destination:AsSpringVector(), {})
end

function Queue.new ()
	local self = setmetatable({}, MyClass)
	self.q = {first = 0, last = -1}
	return self
end

function Queue.pushleft (self, value)
	local first = self.q.first - 1
	self.q.first = first
	self.q[first] = value
end

function Queue.pushright (self, value)
	local last = self.q.last + 1
	self.q.last = last
	self.q[last] = value
end

function Queue.popleft (self)
	if self:empty() then error("Queue is empty") end
  
	local first = self.q.first
	local value = self.q[first]
	self.q[first] = nil        -- to allow garbage collection
	self.q.first = first + 1
	return value
end

function Queue.popright (self)
	if self:empty() then error("Queue is empty") end
  
	local last = self.q.last
	local value = self.q[last]
	self.q[last] = nil         -- to allow garbage collection
	self.q.last = last - 1
	return value
end

function Queue.empty(self)
	return self.first > self.q.last 
end

function isCloseEnough(pointA, pointB, threshold)
  	return pointA:Distance(pointB) < threshold
end

-- @description return all utility functions
return function()
	local fun = {


	}



	return debug.getlocal(1, a)
end