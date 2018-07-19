local sensorInfo = {
	name = "Get new custom formation",
	desc = "Return definition of the given formaiton",
	author = "SeryMa",
	date = "2018-06-13",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- instant, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

local formationDefinitions = {
	["tail"] = {
		name = "tail",
		positions = {
			[1]  = {0,0},		[2]  = {0,1},		[3]  = {0,2},		[4]  = {0,3},		[5]  = {0,4},
			[6]  = {0,5},		[7]  = {0,6},		[8]  = {0,7},		[9]  = {0,8},	[10] = {0,9},
			-- [11] = {-8,-16},	[12] = {-15,-3},	[13] = {-15,10},	[14] = {-5,18},		[15] = {8,19},
			-- [16] = {21,13},		[17] = {2522},		[18] = {21,-10},	[19] = {6,-20},		[20] = {-4,-22},
			-- [21] = {-17,-7},	[22] = {-22,2},		[23] = {-15,20},	[24] = {3,26},		[25] = {18,23},
			-- [26] = {29,10},		[27] = {28,-7},		[28] = {21,-20},	[29] = {5,-27},		[30] = {-13,-24},
		},
		generated = false,
		defaults = {
			spacing = Vec3(10, 1 ,10),
			hillyCoeficient = 30,
			constrained = true,
			variant = false,
			rotable = false,
		},		
	},
	-- ["wedge"] = {
	-- 	name = "wedge",
	-- 	positions = {
	-- 		[1]  = {0,0},
	-- 		[2]  = {-1,2},		[3]  = {0,2},		[4]  = {1,2},
	-- 		[5]  = {-2,1},		[6]  = {-1,1},		[7]  = {0,1,},		[8]  = {1,1},		[9]  = {2,1},
	-- 		[10]  = {-3,0},		[11]  = {-2,0},		[12]  = {-1,0},		[13]  = {0,3},		[14]  = {1,0},		[15]  = {2,0},		[16]  = {3,0},
	-- 		[17]  = {-4,-1},	[18]  = {-3,-1},	[19]  = {-2,-1},    [20]  = {-1,-1},	[21]  = {0,-1},		[22]  = {1,-1},		[23]  = {2,-1},		[24]  = {3,-1},		[25]  = {4,-1},
	-- 		[26]  = {-5,-2},	[27]  = {-4,-2},    [28]  = {-3,-2},	[29]  = {-2,-2},    [30]  = {-1,-2},	[31]  = {0,-2},		[32]  = {1,-2},		[33]  = {2,-2},		[34]  = {3,-2},		[35]  = {4,-2},		[36]  = {5,-2},
	-- 	},		
	-- 	generated = false,
	-- 	defaults = {
	-- 		spacing = Vec3(80, 1 ,100),
	-- 		hillyCoeficient = 20,
	-- 		constrained = true,
	-- 		variant = false,
	-- 		rotable = true,
	-- 	},		
	-- },
}

-- @description return stuctured description of the formation
-- @argument formationName [string] name of the formaiton
return function(formationName)
	local thisDefinition = formationDefinitions[formationName]
	local thisPositions = thisDefinition.positions
	local vectorPositions = {}
	local vectorPositionsCount = 0
	
	for i=1, #thisPositions do
		vectorPositionsCount = vectorPositionsCount + 1
		vectorPositions[vectorPositionsCount] = Vec3(thisPositions[i][1], 0, -thisPositions[i][2]) -- 
	end
	
	-- do not rewrite the originial table otherwise it is not robust on "reset"
	local finalDefinition = {
		name = thisDefinition.name,
		positions = vectorPositions,
		generated = thisDefinition.generated,
		defaults = thisDefinition.defaults,		
	}
	
	return finalDefinition
end