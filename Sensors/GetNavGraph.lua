local sensorInfo = {
	name = "Get nav graph",
	desc = "Creates pathfinding graph.",
	author = "SeryMa",
	date = "2017-05-16",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

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

function getNearestSample(sample, point)
	local SizeX = sample.sizeX
    local SizeZ = sample.sizeZ

    local stepX = sample.stepX
    local stepZ = sample.stepZ

	local dist = nil
	local coords = nil

	local num = 0

	for x = 1, SizeX, stepX do
		for z = 1, SizeZ, stepZ do
			num = num+1
			if sample[x] ~= nil and sample[x][z] ~= nil then
				local newDist = sample[x][z].smooth:Distance(point)
				if not coords or newDist < dist then
					dist = newDist
					coords = sample[x][z]
				end
			end
		end
	end

	return coords
end



-- speedups



-- @description return path as points from - to
return function(sample, pointOfEntry, debug)
	local navGraph = {}
		
	local q = newQueue()
	local start = getNearestSample(sample, pointOfEntry)
	
	q:push_right(start)
	start.prev = nil
	while not q:is_empty() do
		local point = q:pop_left()

		point.checked = true
		navGraph[#navGraph+1] = point

		if point.top and not point.top.checked then
			q:push_right(point.top)
			point.top.prev = point
		end
		
		if point.bottom and not point.bottom.checked then
			q:push_right(point.bottom)
			point.bottom.prev = point
		end

		if point.left and not point.left.checked then
			q:push_right(point.left)
			point.left.prev = point
		end

		if point.right and not point.right.checked then
			q:push_right(point.right)
			point.right.prev = point
		end
	end

	
	if debug and (Script.LuaUI('line_init')) then
		Script.LuaUI.line_init()
	end

	if debug and (Script.LuaUI('line_update')) then
		for i=1, #navGraph do
			if navGraph[i].prev then
				Script.LuaUI.line_update({from = navGraph[i].smooth, to = navGraph[i].prev.smooth})
			end
		end
	end


	return navGraph 
end