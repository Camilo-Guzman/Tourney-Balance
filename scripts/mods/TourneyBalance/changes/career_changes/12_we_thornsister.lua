local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Sister of the Thorn
		### Career Ability
		- Increased ultimate cooldown to 70s (from 40s).

		### Passives
		**A Cluster of Radiants**
		- Increased passive ultimate cooldown to 70s (from 60s).

		**A Sustenance of Leechlings**
		- Decreased temp health siphon from team to 10% (from 100%).

		### Talents
		**Surge of Malice**
		- Lowered required health threshold to 70% (from 90%).

		**Atharti's Delight**
		- Bleed is limited to 2 stack (from 3).

		**Briar's Malice**
		- Crit stacks granted increased to 3 (from 2)
		- Only consume crit stacks on hit, and at most 1 stack per attack (even against multiple enemies).

		**Bonded Spirit**
		- Updated description: Internal CD of losing cooldown is  1s.

		**Radiant Inheritance**
		- Can be activated with Thornwake (regular ult).
		- Recasting refreshes the and extends the duration to 20s.
		- Allies now also see a depleting-icon timer for the buff (previously a static icon).

		**Repel**
		- Additionally grants passive 100% increased stamina recovery.

		**Ironbark Thicket**
		- When holding cast, pressing weapon special key toggles a flat-wall mode (Ironbark Thicket icon)
		- A flat wall no longer blocks enemy movement, but enemies touching it are slowed by 50% for 10s.

		**Blackvenom Thicket**
		- Added 40% cooldown reduction.
	$END_TB
]]

--[[

	Ultimate

]]
mod_api.update_career_ability_cooldown("we_thornsister", 70) -- 40


--[[
	Passive
]]
--[[
	A Cluster of Radiants
]]
PassiveAbilitySettings.we_thornsister.passive_ability_classes[1].init_data.cooldown = 70 -- 60
mod_api.insert_text("career_passive_desc_we_thornsister", "Kerillian is granted Radiance (a free use of her career skill) every 70 seconds.")

--[[
	A Sustenance of Leechlings
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_temp_health_funnel_aura_buff", {
	multiplier = 0.10
})

--[[

	Talents

]]
--[[
	Surge of Malice
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_attack_speed_on_full", {
	health_threshold = 0.7, -- 0.9
})
mod_api.update_talent("we_thornsister", 2, 1, {
	description_values = {},
})
mod_api.insert_text("kerillian_thorn_sister_attack_speed_on_full_desc", "Increases attack speed by 15% while above 70% health.")

--[[
	Atharti's Delight
]]
-- Vanilla proc (any melee hit on a poisoned enemy), but the bleed only stacks once
BuffTemplates.thorn_sister_big_bleed.buffs[1].max_stacks = 1 -- 3
mod_api.insert_text("kerillian_thorn_sister_crit_big_bleed_desc_2", "Melee attacks against poisoned enemies inflict bleed.")


--[[
	Briar's Malice
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
	amount_to_add = 3, -- 2
})
mod_api.update_talent("we_thornsister", 2, 3, {
	description_values = {
		{
			value = 3, -- 2
		},
	},
})
-- consume 1 stack only on hit
-- Explosions can't rely on target_number: remote clients receive every explosion hit via rpc_buff_on_attack with
-- target_number hardcoded to 1, and the hits are spread over several frames (aoe damage ring buffer + network).
-- So an explosion consumes one stack, then further explosion hits are ignored for a short window.
local TB_CRIT_STACK_AOE_WINDOW = 0.5
local tb_crit_stack_last_aoe_consume_t = setmetatable({}, { __mode = "k" })
mod_api.insert_proc_function("tb_thorn_sister_remove_crit_stack_on_first_hit", function (owner_unit, buff, params)
	local attack_type = params[2]
	local target_number = params[4]

	if target_number and target_number > 1 then
		return
	end

	if attack_type == "aoe" or attack_type == "grenade" then
		local t = Managers.time:time("game")
		local last_consume_t = tb_crit_stack_last_aoe_consume_t[owner_unit]

		if last_consume_t and t - last_consume_t < TB_CRIT_STACK_AOE_WINDOW then
			return
		end

		tb_crit_stack_last_aoe_consume_t[owner_unit] = t
	end

	return ProcFunctions.remove_ref_buff_stack_woods(owner_unit, buff, params)
end)
-- Deepwood Staff's Lift consumes crit stack
mod_api.insert_proc_function("tb_thorn_sister_remove_crit_stack_on_lift", function (owner_unit, buff, params)
	local action_kind = params[1]

	if action_kind ~= "spirit_storm" then
		return
	end

	return ProcFunctions.remove_ref_buff_stack_woods(owner_unit, buff, params)
end)
mod_api.insert_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability_handler", {
	{
		name = "kerillian_thorn_sister_crit_on_any_ability_handler",
		buff_func = "tb_thorn_sister_remove_crit_stack_on_first_hit",
		buff_to_remove = "kerillian_thorn_sister_crit_on_any_ability_buff",
		event = "on_hit",
		max_stacks = 1,
	},
	{
		name = "kerillian_thorn_sister_crit_on_any_ability_handler_lift",
		buff_func = "tb_thorn_sister_remove_crit_stack_on_lift",
		buff_to_remove = "kerillian_thorn_sister_crit_on_any_ability_buff",
		event = "on_critical_action",
		max_stacks = 1,
	},
})

--[[
	Bonded Spirit
]]
mod_api.insert_text("kerillian_thorn_sister_faster_passive_desc", "Reduce the cooldown of Radiance by 50%%, taking damage increases the cooldown by 2 seconds (1 second internal cooldown).")

--[[
	Radiant Inheritance
]]
-- longer duration for radiant inheritance
local radiant_thorn_stack_count = {}

-- Give allies a depleting-icon timer matching Kerillian's own
local radiant_thorn_ally_timer_ids = setmetatable({}, { __mode = "k" })
mod_api.insert_talent_buff_template("wood_elf", "tb_radiant_inheritance_ally_timer", {
	icon = "kerillian_thornsister_avatar",
	max_stacks = 1,
	refresh_durations = true,
})
local function tb_radiant_thorn_refresh_ally_timer(ally_unit, remaining_duration)
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_id = buff_system:add_buff_synced(ally_unit, "tb_radiant_inheritance_ally_timer", BuffSyncType.All, {
		external_optional_duration = remaining_duration,
	})

	-- A refresh of an already-tracked timer returns -1 (no new instance was created), so only
	-- overwrite the tracked id on a genuine first add - otherwise we'd lose the id needed to
	-- remove it later
	if buff_id and buff_id ~= -1 then
		radiant_thorn_ally_timer_ids[ally_unit] = buff_id
	end
end
local function tb_radiant_thorn_duration_modifier(unit, sub_buff_template, duration, buff_extension, params)
	local is_active = buff_extension:has_buff_type("kerillian_thorn_sister_team_buff_aura")
	local current_count = radiant_thorn_stack_count[unit] or 0
	local new_count = math.min(is_active and current_count + 1 or 1, 2)

	radiant_thorn_stack_count[unit] = new_count

	local final_duration = duration * new_count

	-- Push the freshly (re)cast duration to every ally currently in range
	if Managers.state.network.is_server then
		local side = Managers.state.side.side_by_unit[unit]

		if side then
			local range = sub_buff_template.range
			local range_squared = range * range
			local caster_position = POSITION_LOOKUP[unit]
			local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

			for i = 1, #player_and_bot_units do
				local ally_unit = player_and_bot_units[i]

				if ally_unit ~= unit and HEALTH_ALIVE[ally_unit] and Vector3.distance_squared(caster_position, POSITION_LOOKUP[ally_unit]) < range_squared then
					tb_radiant_thorn_refresh_ally_timer(ally_unit, final_duration)
				end
			end
		end
	end

	return final_duration
end
-- Piggybacks on the same per-tick range check the real aura buff already uses
local tb_radiant_thorn_vanilla_activate_buff_on_distance = BuffFunctionTemplates.functions.activate_buff_on_distance
mod_api.insert_buff_function("tb_radiant_thorn_activate_buff_on_distance", function (owner_unit, buff, params)
	tb_radiant_thorn_vanilla_activate_buff_on_distance(owner_unit, buff, params)

	if not Managers.state.network.is_server then
		return
	end

	local side = Managers.state.side.side_by_unit[owner_unit]

	if not side then
		return
	end

	local remaining_duration = buff.duration and buff.start_time + buff.duration - Managers.time:time("game")
	local range = buff.range
	local range_squared = range * range
	local caster_position = POSITION_LOOKUP[owner_unit]
	local buff_system = Managers.state.entity:system("buff_system")
	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

	for i = 1, #player_and_bot_units do
		local ally_unit = player_and_bot_units[i]

		if ally_unit ~= owner_unit and HEALTH_ALIVE[ally_unit] then
			local inside = Vector3.distance_squared(caster_position, POSITION_LOOKUP[ally_unit]) < range_squared
			local timer_id = radiant_thorn_ally_timer_ids[ally_unit]

			if inside and not timer_id and remaining_duration and remaining_duration > 0 then
				tb_radiant_thorn_refresh_ally_timer(ally_unit, remaining_duration)
			elseif not inside and timer_id then
				buff_system:remove_buff_synced(ally_unit, timer_id)
				radiant_thorn_ally_timer_ids[ally_unit] = nil
			end
		end
	end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_team_buff_aura", {
	duration = 10,
	max_stacks = 2,
	refresh_durations = true,
	duration_modifier_func = tb_radiant_thorn_duration_modifier,
	update_func = "tb_radiant_thorn_activate_buff_on_distance",
})
-- trigger radiant inheritance on regular ult too, not just extra-charge uses
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_team_buff", {
	event = "on_ability_cooldown_started",
})
mod_api.insert_text("kerillian_thorn_sister_passive_team_buff_desc", "Consuming Radiance or Thornwake grants Kerillian and nearby allies 15.0%% power and 5.0%% critical strike chance for 10 seconds. Duration can stack 2 times.")

--[[
	Repel
]]
mod_api.insert_talent_buff_template("wood_elf", "tb_repel_stamina_recovery", {
	stat_buff = "fatigue_regen",
	multiplier = 1.0,
})
mod_api.update_talent("we_thornsister", 5, 3, {
	description = "kerillian_thorn_sister_big_push_desc",
	description_values = {},
	buffs = {
		"kerillian_thorn_sister_big_push",
		"tb_repel_stamina_recovery",
	},
})
mod_api.insert_text("kerillian_thorn_sister_big_push_desc", "Pushing at full stamina increases the strength and range of the push by 100%. Increases stamina recovery by 100%.")

--[[
	Ironbark Thicket
]]
-- Only kerillian_thorn_sister_tanky_wall tilts. action_three toggles flat-wall mode while aiming (unused by
-- this weapon otherwise). Casting with it off = vanilla upright wall. Casting with it on = fully flat, which
-- no longer blocks movement (collision tilts with the mesh) but slows any enemy that touches it instead.
local function tb_tilt_wall_rotation(wall_rotation, tilt_angle)
	local up = Vector3.up()
	local forward = Quaternion.forward(wall_rotation)
	local cos_t = math.cos(tilt_angle)
	local sin_t = math.sin(tilt_angle)
	local tilted_up = up * cos_t + forward * sin_t
	local tilted_forward = forward * cos_t - up * sin_t

	return Quaternion.look(tilted_forward, tilted_up)
end

-- Flat wall segments, weak-keyed; set in spawn_func below, read by the enemy-slow hook further down.
local tb_flat_wall_units = setmetatable({}, { __mode = "k" })
-- Shared by both slow mechanisms below.
local TB_FLAT_WALL_ENEMY_SLOW_MULTIPLIER = 0.5 -- 50% slowdown

-- AI movement has two independent code paths, so the slow is applied in two places:
-- (1) navbot-driven pathing (normal walk/run), via AINavigationExtension's movement-modifier stack - same
-- API the Necromancer's own charge slow uses.
mod_api.insert_buff_function("tb_apply_flat_wall_enemy_slow", function (unit, buff, params, world)
	if Managers.state.network.is_server then
		local navigation_extension = ScriptUnit.has_extension(unit, "ai_navigation_system")

		if navigation_extension then
			buff.movement_modifier_id = navigation_extension:add_movement_modifier(buff.template.multiplier)
		end
	end
end)
mod_api.insert_buff_function("tb_remove_flat_wall_enemy_slow", function (unit, buff, params, world)
	if Managers.state.network.is_server and buff.movement_modifier_id then
		local navigation_extension = ScriptUnit.has_extension(unit, "ai_navigation_system")

		if navigation_extension then
			navigation_extension:remove_movement_modifier(buff.movement_modifier_id)
		end
	end
end)
mod_api.insert_buff_template("tb_flat_wall_enemy_slow", {
	apply_buff_func = "tb_apply_flat_wall_enemy_slow",
	remove_buff_func = "tb_remove_flat_wall_enemy_slow",
	multiplier = TB_FLAT_WALL_ENEMY_SLOW_MULTIPLIER, -- direct factor, not a stacking_multiplier delta
	duration = 10, -- runs its full course from first touch - refresh_durations deliberately omitted
	max_stacks = 1,
})
-- (2) charges/lunges bypass the navbot and set velocity directly via locomotion_extension:set_wanted_velocity,
-- so scale it there too. Two parallel extension implementations exist (Lua vs engine-optimized); hook both.
-- Confirmed normal navbot movement never calls set_wanted_velocity, so no double-application between (1)/(2).
local function tb_scale_velocity_if_slowed(unit, wanted_velocity)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if buff_extension and buff_extension:has_buff_type("tb_flat_wall_enemy_slow") then
		return wanted_velocity * TB_FLAT_WALL_ENEMY_SLOW_MULTIPLIER
	end

	return wanted_velocity
end
mod:hook(AILocomotionExtension, "set_wanted_velocity", function (func, self, wanted_velocity)
	func(self, tb_scale_velocity_if_slowed(self._unit, wanted_velocity))
end)
mod:hook(AILocomotionExtensionC, "set_wanted_velocity", function (func, self, wanted_velocity)
	func(self, tb_scale_velocity_if_slowed(self._unit, wanted_velocity))
end)

-- Cosmetic marker buff: shows Ironbark's own talent icon while flat-wall mode is toggled on.
mod_api.insert_buff_template("tb_flat_wall_mode_active", {
	icon = "kerillian_thornsister_healing_wall",
	max_stacks = 1,
})
local function tb_remove_buff_type(buff_extension, buff_name)
	local stacks = buff_extension:get_stacking_buff(buff_name)

	if stacks then
		for i = 1, #stacks do
			buff_extension:remove_buff(stacks[i].id)
		end
	end
end
-- Toggle (not hold) via action_three, edge-detected so holding it doesn't rapid-fire the toggle. State lives
-- on owner_unit (not self) so it persists across separate casts rather than resetting each time.
local tb_flat_wall_toggle_state = setmetatable({}, { __mode = "k" })
mod:hook_safe(ActionCareerWEThornsisterTargetWall, "_update_targeting", function (self)
	if self.is_bot then
		self._wall_tilt_angle = 0
		return
	end

	local owner_unit = self.owner_unit
	local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

	if not (talent_extension and talent_extension:has_talent("kerillian_thorn_sister_tanky_wall")) then
		tb_flat_wall_toggle_state[owner_unit] = nil
		self._tb_action_three_was_held = false
		self._wall_tilt_angle = 0
		return
	end

	local input_extension = ScriptUnit.extension(owner_unit, "input_system")
	local action_three_held = input_extension:get("action_three")

	if action_three_held and not self._tb_action_three_was_held then
		local is_now_active = not tb_flat_wall_toggle_state[owner_unit]

		tb_flat_wall_toggle_state[owner_unit] = is_now_active

		local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

		if buff_extension then
			if is_now_active then
				buff_extension:add_buff("tb_flat_wall_mode_active")
			else
				tb_remove_buff_type(buff_extension, "tb_flat_wall_mode_active")
			end
		end
	end

	self._tb_action_three_was_held = action_three_held
	self._wall_tilt_angle = tb_flat_wall_toggle_state[owner_unit] and math.pi / 2 or 0
end)
-- Carry the tilt angle through the action chain to spawn_func.
mod:hook(ActionCareerWEThornsisterTargetWall, "finish", function (func, self, reason, data)
	local targeting_data = func(self, reason, data)

	if targeting_data then
		targeting_data.wall_tilt_angle = self._wall_tilt_angle or 0
	end

	-- Left click while aiming chains into another targeting sub-action (thorn_wall_target_flip / _flip_back),
	-- which also finishes this one - keep the toggle across that, since the ult is still being aimed.
	local next_action_settings = data and data.new_action_settings

	if next_action_settings and next_action_settings.kind == "career_we_thornsister_target_wall" then
		return targeting_data
	end

	-- Otherwise reset: finish() is the one guaranteed exit point for this action, cast or not. Vanilla's
	-- targeting_data is non-nil whenever a valid target was ever found, even if the actual interrupting action
	-- turns out not to be the fire action (e.g. cancelling via a weapon swap after aiming at a valid spot) - so
	-- branching on it here would miss that case. Safe to do here: a genuine cast's angle was already
	-- copied onto targeting_data above, as a plain number disconnected from this table from this point on.
	local owner_unit = self.owner_unit

	tb_flat_wall_toggle_state[owner_unit] = nil

	local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

	if buff_extension then
		tb_remove_buff_type(buff_extension, "tb_flat_wall_mode_active")
	end

	return targeting_data
end)
mod:hook(ActionCareerWEThornsisterWall, "client_owner_start_action", function (func, self, new_action, t, chain_action_data, power_level, action_init_data)
	self._wall_tilt_angle = chain_action_data and chain_action_data.wall_tilt_angle or 0

	func(self, new_action, t, chain_action_data, power_level, action_init_data)
end)
-- Fold the tilt into wall_rotation here so it survives request_spawn_template_unit's RPC to the server - a
-- plain Lua variable doesn't, since spawn_func runs later from the RPC handler, not synchronously inside this.
mod:hook(ActionCareerWEThornsisterWall, "_spawn_wall", function (func, self, num_segments, segments, wall_rotation)
	local should_tilt = self.talent_extension:has_talent("kerillian_thorn_sister_tanky_wall")
	local tilt_angle = should_tilt and self._wall_tilt_angle or 0
	local final_wall_rotation = tilt_angle > 0 and tb_tilt_wall_rotation(wall_rotation, tilt_angle) or wall_rotation

	func(self, num_segments, segments, final_wall_rotation)
end)

local WALL_TYPES = table.enum("default", "bleed")
local UNIT_NAMES = {
	default = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01",
	bleed = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_bleed"
}
SpawnUnitTemplates.thornsister_thorn_wall_unit = {
	spawn_func = function (source_unit, position, rotation, state_int, group_spawn_index)
		local UNIT_NAME = UNIT_NAMES[WALL_TYPES.default]
		local UNIT_TEMPLATE_NAME = "thornsister_thorn_wall_unit"
		local wall_index = state_int
		local despawn_sound_event = "career_ability_kerillian_sister_wall_disappear"
		local life_time = 6
		-- forward.z is ~0 for an untilted wall_rotation and ~±1 for a flat (pi/2-tilted) one. Coarse threshold on
		-- purpose: when a client casts, the rotation arrives via rpc_request_spawn_template_unit with network
		-- compression, so an upright wall's forward.z is only approximately 0 - a tight epsilon misread it as flat.
		-- Also gates the nav-tag volume below, which is rotation-independent and would otherwise still block
		-- AI pathing through a flat wall regardless of the mesh/collision itself being tilted.
		local is_tilted = math.abs(Quaternion.forward(rotation).z) > 0.5
		local area_damage_params = {
			aoe_dot_damage = 0,
			radius = 0.3,
			area_damage_template = "we_thornsister_thorn_wall",
			invisible_unit = false,
			nav_tag_volume_layer = "temporary_wall",
			create_nav_tag_volume = not is_tilted,
			aoe_init_damage = 0,
			damage_source = "career_ability",
			aoe_dot_damage_interval = 0,
			damage_players = false,
			source_attacker_unit = source_unit,
			life_time = life_time
		}
		local props_params = {
			life_time = life_time,
			owner_unit = source_unit,
			despawn_sound_event = despawn_sound_event,
			wall_index = wall_index
		}
		local health_params = {
			health = 20
		}
		local buffs_to_add = nil
		local source_talent_extension = ScriptUnit.has_extension(source_unit, "talent_system")

		if source_talent_extension then
			if source_talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
				local life_time_mult = 1
				local life_time_bonus = 4.2
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				-- Wide wall duration
				-- props_params.life_time = (6 / 10) * (props_params.life_time * life_time_mult + life_time_bonus)
				props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
			elseif source_talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
				local life_time_mult = 0.17
				local life_time_bonus = 0
				area_damage_params.create_nav_tag_volume = false
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
				UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
			end
		end

		local extension_init_data = {
			area_damage_system = area_damage_params,
			props_system = props_params,
			health_system = health_params,
			death_system = {
				death_reaction_template = "thorn_wall",
				is_husk = false
			},
			hit_reaction_system = {
				is_husk = false,
				hit_reaction_template = "level_object"
			}
		}
		-- Baked directly into the spawn call, not set afterward via Unit.set_local_rotation: clients rebuild
		-- their own copy of the unit from a network snapshot captured at spawn time, so a large post-spawn
		-- rotation change wouldn't reliably reach them.
		local random_spin = Quaternion(Vector3.up(), math.random() * 2 * math.pi - math.pi)
		local final_rotation = is_tilted and Quaternion.multiply(rotation, random_spin) or random_spin
		local wall_unit = Managers.state.unit_spawner:spawn_network_unit(UNIT_NAME, UNIT_TEMPLATE_NAME, extension_init_data, position, final_rotation)

		if is_tilted then
			tb_flat_wall_units[wall_unit] = true
		end

		local buff_extension = ScriptUnit.has_extension(wall_unit, "buff_system")

		if buff_extension and buffs_to_add then
			for i = 1, #buffs_to_add do
				buff_extension:add_buff(buffs_to_add[i])
			end
		end

		local thorn_wall_extension = ScriptUnit.has_extension(wall_unit, "props_system")

		if thorn_wall_extension then
			thorn_wall_extension.group_spawn_index = group_spawn_index
		end
	end
}
mod_api.insert_text("kerillian_thorn_sister_tanky_wall_desc_2", "Increase the width of the Thorn Wall and duration to 10 seconds.\n\nPressing weapon special while casting switches to Thornbed. Enemies walking through it are slowed by 50%% for 10 seconds.")

-- Registered last on purpose: piggybacks on the wall's own per-tick area-effect (which already slows nearby
-- allies) to also slow nearby enemies, for segments tracked as flat above. If registering a hook on this
-- particular table (AreaDamageTemplates.templates[name], not AreaDamageTemplates[name] directly) ever breaks,
-- keeping it last means that failure can't silently prevent the rest of this section from loading.
local tb_flat_wall_last_check_t = setmetatable({}, { __mode = "k" })
local TB_FLAT_WALL_CHECK_INTERVAL = 0.1 -- fixed interval; per-frame scanning got expensive with many enemies nearby
local TB_FLAT_WALL_ENEMY_SLOW_RADIUS = 0.5 -- kept separate from the 0.3 "radius" param (ally-slow/nav-tag)
mod:hook(AreaDamageTemplates.templates.we_thornsister_thorn_wall.client, "update", function (func, world, radius, aoe_unit, ...)
	func(world, radius, aoe_unit, ...)

	if not tb_flat_wall_units[aoe_unit] then
		return
	end

	local t = Managers.time:time("game")
	local last_check_t = tb_flat_wall_last_check_t[aoe_unit]

	if last_check_t and t - last_check_t < TB_FLAT_WALL_CHECK_INTERVAL then
		return
	end

	tb_flat_wall_last_check_t[aoe_unit] = t

	local side = Managers.state.side.side_by_unit[aoe_unit]

	if not side then
		return
	end

	local area_damage_position = POSITION_LOOKUP[aoe_unit]

	if not area_damage_position then
		return
	end

	local enemy_units = side:enemy_units()

	for _, enemy_unit in pairs(enemy_units) do
		local unit_position = POSITION_LOOKUP[enemy_unit]

		if unit_position then
			-- horizontal-only, so terrain height differences between the wall and an enemy's feet don't matter
			local distance = Vector3.distance_squared(Vector3.flat(unit_position), Vector3.flat(area_damage_position))

			if distance < TB_FLAT_WALL_ENEMY_SLOW_RADIUS * TB_FLAT_WALL_ENEMY_SLOW_RADIUS then
				local buff_extension = ScriptUnit.has_extension(enemy_unit, "buff_system")

				if buff_extension then
					buff_extension:add_buff("tb_flat_wall_enemy_slow")
				end
			end
		end
	end
end)

--[[
	Blackvenom Thicket
]]
mod_api.update_talent("we_thornsister", 6, 3, {
    buffs = {
        "tb_blackvenom_cdr"
    }
})
mod_api.insert_talent_buff_template("wood_elf", "tb_blackvenom_cdr", {
	stat_buff = "activated_cooldown",
	multiplier = -0.4,
	max_stacks = 1
})
mod_api.insert_text("kerillian_thorn_sister_debuff_wall_desc_2", "Thornwake instead causes roots to burst from the ground, staggering enemies and applying Blackvenom to them. Reduces cooldown by 40%%.")