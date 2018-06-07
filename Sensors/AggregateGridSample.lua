local sensorInfo = {
	name = "Aggregation",
	desc = "Returns aggregation of given sample.",
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
local GetHeight = Spring.GetGroundHeight
local Extremes = Spring.GetGroundExtremes

-- Queue implementation by Pierre Chapuis

-- Source: https://github.com/catwell/cw-lua/tree/master/deque

-- License:
-- Copyright (C) 2013-2015 by Pierre Chapuis

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.


local push_right = function(self, x)
	assert(x ~= nil)
	self.tail = self.tail + 1
	self[self.tail] = x
  end
  
  local push_left = function(self, x)
	assert(x ~= nil)
	self[self.head] = x
	self.head = self.head - 1
  end
  
  local peek_right = function(self)
	return self[self.tail]
  end
  
  local peek_left = function(self)
	return self[self.head+1]
  end
  
  local pop_right = function(self)
	if self:is_empty() then return nil end
	local r = self[self.tail]
	self[self.tail] = nil
	self.tail = self.tail - 1
	return r
  end
  
  local pop_left = function(self)
	if self:is_empty() then return nil end
	local r = self[self.head+1]
	self.head = self.head + 1
	local r = self[self.head]
	self[self.head] = nil
	return r
  end
  
  local length = function(self)
	return self.tail - self.head
  end
  
  local is_empty = function(self)
	return self:length() == 0
  end
  
  
  local iter_right = function(self)
	local i = self.tail+1
	return function()
	  if i > self.head+1 then
		i = i-1
		return self[i]
	  end
	end
  end
  
  local iter_left = function(self)
	local i = self.head
	return function()
	  if i < self.tail then
		i = i+1
		return self[i]
	  end
	end
  end
  
  local methods = {
	push_right = push_right,
	push_left = push_left,
	peek_right = peek_right,
	peek_left = peek_left,
	pop_right = pop_right,
	pop_left = pop_left,
	iter_right = iter_right,
	iter_left = iter_left,
	length = length,
	is_empty = is_empty,
  }
  
  local newQueue = function()
	local r = {head = 0, tail = 0}
	return setmetatable(r, {__index = methods})
  end
  
  --- End of Queue implementation
  

local function newAggregation(point)
	local aggregation = {}
	aggregation.points = {}

	aggregation.center = point

	aggregation.maxX = point.x
	aggregation.maxZ = point.z
	aggregation.minX = point.x
	aggregation.minZ = point.z

	aggregation.diameter = {}
	aggregation.diameter.x = 0
	aggregation.diameter.z = 0
	
	return aggregation
end

local function addPointToAggregation(point, aggregation)
	-- New point on the aggregation
	aggregation.points[#aggregation.points+1] = point

	-- Updating dimensions of the aggregation
	if point.x > aggregation.maxX then aggregation.maxX = point.x end
	if point.x < aggregation.minX then aggregation.minX = point.x end
	if point.z > aggregation.maxZ then aggregation.maxZ = point.z end
	if point.z < aggregation.minZ then aggregation.minZ = point.z end

	aggregation.center = Vec3(aggregation.minX + (aggregation.maxX - aggregation.minX) /2, 0, aggregation.minZ + (aggregation.maxZ - aggregation.minZ) /2)
	
	aggregation.diameter.x = (aggregation.maxX - aggregation.minX) /2
	aggregation.diameter.z = (aggregation.maxZ - aggregation.minZ) /2
end


-- @description returns aggregation of the sample
return function(sample, debug)
	-- debug drawing inicialization
	if (debug and Script.LuaUI('boundary_init')) then
		Script.LuaUI.boundary_init()
	end
	
	if (debug and Script.LuaUI('circle_init')) then
		Script.LuaUI.circle_init()
	end

	
	local aggregations = {}
    local count = 0

	-- function called when new aggregation is found
	local function processPoint(highPoints, pointOfEntry, debug)
		local aggregation = newAggregation(pointOfEntry)
		
		local q = newQueue()
		q:push_left(pointOfEntry)

		-- BFS to cover whole sample & mark found points (so they won't be added later)
		while not q:is_empty() do
			local point = q:pop_left()

			point.checked = true
			addPointToAggregation(point, aggregation)

            if point.top and not point.top.checked then q:push_left(point.top) end
            if point.bottom and not point.bottom.checked then q:push_left(point.bottom) end
            if point.left and not point.left.checked then q:push_left(point.left) end
            if point.right and not point.right.checked then q:push_left(point.right) end
		end

		aggregations[count] = aggregation
		count = count + 1
	end

    local SizeX = sample.sizeX
    local SizeZ = sample.sizeZ

    local stepX = sample.stepX
    local stepZ = sample.stepZ

	-- iterates over all sample points & agregates them one structure
	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
            if sample[x] ~= nil and sample[x][z] ~= nil and not sample[x][z].checked then
                processPoint(sample, sample[x][z])
			end
		end
	end


	-- debug drawing widgets
	math.randomseed(os.time())
	local offset = math.random(10000, 10000000)

	if (debug and Script.LuaUI('boundary_update')) then
		for i, aggregation in pairs(aggregations) do
			Script.LuaUI.boundary_update(i+offset, { points = aggregation.points })
		end 
	end

	if (debug and Script.LuaUI('circle_update')) then
		local max = math.max
		for i, aggregation in pairs(aggregations) do
            -- different key MUST be selected so the circles doesn't overwrite themselves
			Script.LuaUI.circle_update(offset+i+#aggregations+#aggregations,
										{
											x=aggregation.center.x,
											y=aggregation.center.y,
											z=aggregation.center.z,
											radius= max(aggregation.diameter.x, aggregation.diameter.z),
											r = 20,
											g = 100,
											b = 0,
										})

			Script.LuaUI.circle_update(i+offset,
										{
											x=aggregation.center.x,
											y=aggregation.center.y,
											z=aggregation.center.z,
											radius=10,
											r = 200,
											g = 0,
											b = 0,
										})
		end 
	end

	return aggregations
end