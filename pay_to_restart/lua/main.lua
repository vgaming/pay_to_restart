-- << pay_to_restart

local wesnoth = wesnoth
local addon = pay_to_restart
local on_event = wesnoth.require("lua/on_event.lua")
local ipairs = ipairs
local print_as_json = print_as_json
local print = print

if wesnoth.current.turn > 1 then
	return
end
if addon.map_has_recruits() then
	wesnoth.message("Pay for Restart", "This add-on has been disabled because Map/Era have recruits")
end

local function get_gold(opt_side)
	return wml.variables["pay_to_restart_gold_start_" .. (opt_side or wesnoth.current.side)]
end
local function change_gold(opt_side, change)
	local team = wesnoth.sides[opt_side or wesnoth.current.side].team_name
	for _, side in ipairs(wesnoth.sides) do
		if side.team_name == team then
			local prev = wml.variables["pay_to_restart_gold_start_" .. side.side] or 0
			wml.variables["pay_to_restart_gold_start_" .. side.side] = prev + change
		end
	end
end

local payment = 10

on_event("side 1 turn 1", function()
	on_event("side 1 turn 1 refresh", function () -- register late in event queue
		for _, side in ipairs(wesnoth.sides) do
			if not get_gold(side.side) then
				change_gold(side.side, side.gold)
			end
		end
	end)
end)

on_event("side 1 turn 1 end,side 2 turn 1 end", function ()
	local is_restart
	if get_gold() < payment then
		is_restart = false
	else
		local result = addon.show_dialog {
			label = "Do you want to pay " .. payment .. " gold to re-randomize leaders?",
			options = {
				{ text = "No, leave current", image = "", func = function() print("option function") end},
				{ text = "Yes", image = "", func = function() print("option function") end},
			}
		}
		is_restart = result.index == 2
	end
	wml.variables["pay_to_restart_requested_" .. wesnoth.current.side] = is_restart
	if is_restart then
		change_gold(nil, - payment)
	end
	print_as_json("Turn 1 side:", wesnoth.current.side, "picked in dialog:", is_restart)
end)

local function loop_skip_turns()
	local finished = false
	on_event("turn refresh", function ()
		if finished then
			return
		elseif wesnoth.current.side ~= 1 then
			wesnoth.wml_actions.end_turn {}
		else
			wesnoth.wml_actions.modify_turns { current = 1 }
			finished = true
		end
	end)
end

on_event("side 2 turn 1 end", function ()
	local first_reset = wml.variables["pay_to_restart_requested_" .. 1]
	local second_reset = wml.variables["pay_to_restart_requested_" .. 2]
	print_as_json(first_reset, second_reset)
	if first_reset or second_reset then
		for _, side in ipairs(wesnoth.sides) do
			side.gold = get_gold(side.side)
		end
		loop_skip_turns()
	end
end)


-- >>
