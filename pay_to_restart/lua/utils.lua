-- << utils | pay_to_restart

local addon = pay_to_restart
local ipairs = ipairs

local function map_has_keeps()
	local width,height,_ = wesnoth.get_map_size()
	for x = 1, width do
		for y = 1, height do
			local terr = wesnoth.get_terrain(x, y)
			local info = wesnoth.get_terrain_info(terr)
			if info.keep then
				return true
			end
		end
	end
end
local function humans_can_recruit()
	for _, side in ipairs(wesnoth.sides) do
		if #side.recruit ~= 0 and side.__cfg.allow_player then
			return true
		end
	end
end
local map_has_recruits_result
function addon.map_has_recruits()
	if not map_has_recruits_result then
		map_has_recruits_result = humans_can_recruit() and map_has_keeps()
	end
	return map_has_recruits_result
end


function addon.split_comma(str)
	local result = {}
	local n = 1
	for s in string.gmatch(str or "", "%s*[^,]+%s*") do
		if s ~= "" and s ~= "null" then
			result[n] = s
			n = n + 1
		end
	end
	return result
end

-- >>
