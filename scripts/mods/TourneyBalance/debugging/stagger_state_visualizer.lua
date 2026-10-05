local mod = get_mod("TourneyBalance")
local color_presets = require("scripts/mods/TourneyBalance/debugging/_color_presets")

--[[

	Stagger State Visualizer

	Outlines enemies based on the sum of whichever stagger counts are enabled
	(real stagger count from blackboard.stagger, Mainstay's marked stagger count
	from the target's dummy_stagger buff - only shown if the local player has Mainstay,
	Bulwark's marked stagger count from the target's tb_tank_stagger_mark_buff stacks):
		0        -> no outline
		1        -> green
		2        -> yellow
		above 2  -> red

]]

OutlineSettings.colors.tb_stagger_green = {
	pulsate = false,
	pulse_multiplier = 50,
	color = { 255, 0, 255, 0 }, -- alpha, r, g, b (green)
}
OutlineSettings.colors.tb_stagger_yellow = {
	pulsate = false,
	pulse_multiplier = 50,
	color = { 255, 255, 255, 0 }, -- alpha, r, g, b (yellow)
}
OutlineSettings.colors.tb_stagger_red = {
	pulsate = false,
	pulse_multiplier = 50,
	color = { 255, 255, 0, 0 }, -- alpha, r, g, b (red)
}
OutlineSettings.templates.tb_stagger_1 = {
	method = "ai_alive",
	priority = 50,
	outline_color = OutlineSettings.colors.tb_stagger_green,
	flag = OutlineSettings.flags.non_wall_occluded,
}
OutlineSettings.templates.tb_stagger_2 = {
	method = "ai_alive",
	priority = 50,
	outline_color = OutlineSettings.colors.tb_stagger_yellow,
	flag = OutlineSettings.flags.non_wall_occluded,
}
OutlineSettings.templates.tb_stagger_3 = {
	method = "ai_alive",
	priority = 50,
	outline_color = OutlineSettings.colors.tb_stagger_red,
	flag = OutlineSettings.flags.non_wall_occluded,
}
local STAGGER_OUTLINE_TEMPLATES = {
	[1] = OutlineSettings.templates.tb_stagger_1,
	[2] = OutlineSettings.templates.tb_stagger_2,
	[3] = OutlineSettings.templates.tb_stagger_3,
}

local function get_stagger_state(total)
	if not total or total <= 0 then
		return 0
	elseif total == 1 then
		return 1
	elseif total == 2 then
		return 2
	else
		return 3
	end
end

local function get_mainstay_count(unit)
	local target_buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not target_buff_extension then
		return 0
	end

	return target_buff_extension:apply_buffs_to_value(0, "dummy_stagger")
end

local function get_tank_count(unit)
	local target_buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not target_buff_extension then
		return 0
	end

	return target_buff_extension:num_buff_type("tb_tank_stagger_mark_buff")
end

-- Mainstay marks only count for players with Mainstay, so only show them if the local player has it
local function local_player_has_mainstay()
	local local_player = Managers.player and Managers.player:local_player()
	local player_unit = local_player and local_player.player_unit
	local buff_extension = player_unit and ScriptUnit.has_extension(player_unit, "buff_system")

	return buff_extension and buff_extension:has_buff_perk("linesman_stagger_damage")
end

-- unit -> { outline_id = ..., state = ... }
local outlined_units = {}

-- Adjustable from Debugging -> Stagger State Visualizer -> Count 1/2/3+ in the mod menu
local function apply_stagger_colors()
	local r1, g1, b1 = color_presets.resolve_color("tb_stagger_count_1_color_group", "tb_stagger_count_1_color_r", "tb_stagger_count_1_color_g", "tb_stagger_count_1_color_b", 0, 255, 0)
	local color_1 = OutlineSettings.colors.tb_stagger_green.color

	color_1[2], color_1[3], color_1[4] = r1, g1, b1

	local r2, g2, b2 = color_presets.resolve_color("tb_stagger_count_2_color_group", "tb_stagger_count_2_color_r", "tb_stagger_count_2_color_g", "tb_stagger_count_2_color_b", 255, 255, 0)
	local color_2 = OutlineSettings.colors.tb_stagger_yellow.color

	color_2[2], color_2[3], color_2[4] = r2, g2, b2

	local r3, g3, b3 = color_presets.resolve_color("tb_stagger_count_3_color_group", "tb_stagger_count_3_color_r", "tb_stagger_count_3_color_g", "tb_stagger_count_3_color_b", 255, 0, 0)
	local color_3 = OutlineSettings.colors.tb_stagger_red.color

	color_3[2], color_3[3], color_3[4] = r3, g3, b3

	-- Force any currently-outlined enemies to redraw immediately with the new color
	for unit, data in pairs(outlined_units) do
		if ALIVE[unit] then
			local outline_extension = ScriptUnit.has_extension(unit, "outline_system")

			if outline_extension then
				outline_extension:update_outline(table.clone(STAGGER_OUTLINE_TEMPLATES[data.state]), data.outline_id)
			end
		end
	end
end

apply_stagger_colors()

mod:add_setting_changed_function(apply_stagger_colors)

local function clear_outline(unit)
	local data = outlined_units[unit]

	if not data then
		return
	end

	if ALIVE[unit] then
		local outline_extension = ScriptUnit.has_extension(unit, "outline_system")

		if outline_extension then
			outline_extension:remove_outline(data.outline_id)
		end
	end

	outlined_units[unit] = nil
end

local function clear_all_outlines()
	for unit, _ in pairs(outlined_units) do
		clear_outline(unit)
	end
end

local function apply_stagger_outline(unit, state)
	local outline_extension = ScriptUnit.has_extension(unit, "outline_system")

	if not outline_extension then
		return
	end

	local data = outlined_units[unit]

	if not data then
		local outline_id = outline_extension:add_outline(STAGGER_OUTLINE_TEMPLATES[state])

		outlined_units[unit] = {
			outline_id = outline_id,
			state = state,
		}
	elseif data.state ~= state then
		outline_extension:update_outline(table.clone(STAGGER_OUTLINE_TEMPLATES[state]), data.outline_id)

		data.state = state
	end
end

local UPDATE_INTERVAL = 0.15
local next_update_t = 0

-- Settings cached here and refreshed only on actual change (TourneyBalance.lua's
-- mod:add_setting_changed_function dispatcher), instead of calling mod:get() every frame
-- (the enabled flag) or every 0.15s tick (include_real/include_mainstay) in the hot loop below.
local stagger_state_visualizer_enabled = mod:get("stagger_state_visualizer")
local include_real = mod:get("stagger_state_visualizer_include_real")
local include_mainstay = mod:get("stagger_state_visualizer_include_mainstay")
local include_tank = mod:get("stagger_state_visualizer_include_tank")

mod:add_setting_changed_function(function ()
	stagger_state_visualizer_enabled = mod:get("stagger_state_visualizer")
	include_real = mod:get("stagger_state_visualizer_include_real")
	include_mainstay = mod:get("stagger_state_visualizer_include_mainstay")
	include_tank = mod:get("stagger_state_visualizer_include_tank")

	if not stagger_state_visualizer_enabled and next(outlined_units) then
		clear_all_outlines()
	end
end)

mod:add_update_function(function (dt)
	if not stagger_state_visualizer_enabled then
		return
	end

	if not Managers.state or not Managers.state.game_mode then
		return
	end

	if not BLACKBOARDS then
		return
	end

	local t = Managers.time:time("game")

	if t < next_update_t then
		return
	end

	next_update_t = t + UPDATE_INTERVAL

	for unit, _ in pairs(outlined_units) do
		if not ALIVE[unit] or not BLACKBOARDS[unit] then
			clear_outline(unit)
		end
	end

	local show_mainstay = include_mainstay and local_player_has_mainstay()

	for unit, blackboard in pairs(BLACKBOARDS) do
		if ALIVE[unit] then
			local total = 0

			if include_real then
				total = total + (blackboard.stagger or 0)
			end

			if show_mainstay then
				total = total + get_mainstay_count(unit)
			end

			if include_tank then
				total = total + get_tank_count(unit)
			end

			local state = get_stagger_state(total)

			if state == 0 then
				clear_outline(unit)
			else
				apply_stagger_outline(unit, state)
			end
		end
	end
end)
