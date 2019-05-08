-- << unit_analyze_common

local wesnoth = wesnoth
local addon = pay_to_restart
local ipairs = ipairs
local helper = wesnoth.require("lua/helper.lua")
local split_comma = addon.split_comma


local era_array = {}
local era_set = {}

for multiplayer_side in helper.child_range(wesnoth.game_config.era, "multiplayer_side") do
	local units = multiplayer_side.recruit or multiplayer_side.leader or ""
	for _, unit in ipairs(split_comma(units)) do
		if era_set[unit] == nil and wesnoth.unit_types[unit] then
			era_set[unit] = true
			era_array[#era_array + 1] = unit
		end
	end
end


local era_unit_rand_string = "1.." .. #era_array
local function random_leader()
	return era_array[helper.rand(era_unit_rand_string)]
end


addon.random_leader = random_leader

-- >>
