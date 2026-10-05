local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local shared_utils = require("scripts/mods/TourneyBalance/_api/shared_utils")
local is_server = shared_utils.is_server
local is_local = shared_utils.is_local

--[[
	$BEGIN_TB
		---
		## Witch Hunter Captain
		### Talents
		**Riposte**
		- Fix description: crits also applpy to ranged attacks.
		- A melee headshot while Riposte is active grants one extra guaranteed melee crit on the next melee attack within 2 seconds (at most one extra crit per parry).

		**Templar's Knowledge**
		- Duration increased to 15s (from 5s).
		- Elites and specials take 25% more direct damage from Saltzpyre.

		**I Shall Judge You All**
		- Apply Witch Hunt and mark all enemies within Animosity's range.
		- Headshotting Witch-Hunted enemies extends the duration by 2s.

		**Fervency**
		- Increased duration to 10s (from 6s).
		- Added ult makes first 20 hits guaranteed melee crits.

		**The Unending Hunt**
		- Decreased crit chance granted to team to 15% (from 25%)
	$END_TB
]]


--[[

	WHC Talents

]]

--[[
	Riposte
]]
-- A melee headshot while Riposte is up grants a melee-only copy of it
local RIPOSTE_MELEE_COPY_BUFF = "tb_victor_witchhunter_guaranteed_melee_crit_on_headshot_buff"

local function is_melee_headshot(params)
	local hit_zone_name = params[3]
	local buff_type = params[5]

	return (buff_type == "MELEE_1H" or buff_type == "MELEE_2H") and (hit_zone_name == "head" or hit_zone_name == "neck")
end

-- Vanilla Riposte: still consumed by the first hit of any kind (was "dummy_function" + remove_on_proc)
mod_api.insert_proc_function("tb_riposte_consume", function (owner_unit, buff, params)
	if is_melee_headshot(params) and ALIVE[owner_unit] then
		ScriptUnit.extension(owner_unit, "buff_system"):add_buff(RIPOSTE_MELEE_COPY_BUFF)
	end

	return true
end)
mod_api.update_talent_buff_template("witch_hunter", "victor_witchhunter_guaranteed_crit_on_timed_block_buff", {
	buff_func = "tb_riposte_consume", -- "dummy_function"
})

-- Melee-only copy: consumed by the next melee hit (headshot or not) and doesn't chain, so there is at most one
-- extra crit per parry. Ranged hits and cleave targets are ignored.
local function is_first_melee_target(params)
	local target_number = params[4]
	local buff_type = params[5]

	return (buff_type == "MELEE_1H" or buff_type == "MELEE_2H") and target_number == 1
end

mod_api.insert_proc_function("tb_riposte_melee_copy_consume", function (owner_unit, buff, params)
	return is_first_melee_target(params)
end)
mod_api.insert_talent_buff_template("witch_hunter", RIPOSTE_MELEE_COPY_BUFF, {
	buff_func = "tb_riposte_melee_copy_consume",
	event = "on_hit",
	icon = "victor_witchhunter_guaranteed_crit_on_timed_block",
	duration = 2,
	max_stacks = 1,
	remove_on_proc = true,
	stat_buff = "critical_strike_chance_melee",
	bonus = 1,
})
mod_api.insert_text("victor_witchhunter_guaranteed_crit_on_timed_block_desc", "Parrying causes your next attack within 2 seconds to be a guaranteed critical hit. Landing a melee headshot during this window grants an additional guaranteed melee critical strike within 2 seconds.")

--[[
	Templar's Knowledge
]]
-- 25% damage increase to specials and elites under thp_stagger_changes.lua
-- Duration increase
mod_api.update_talent_buff_template("witch_hunter", "victor_witchhunter_improved_damage_taken_ping", {
	duration = 15, -- 5
})
mod_api.update_talent("wh_captain", 4, 1, {
	description = "victor_witchhunter_improved_damage_taken_ping_desc",
	description_values = {},
})
mod_api.insert_text("victor_witchhunter_improved_damage_taken_ping_desc", "Witch Hunt causes enemies to take an additional 5.0% damage. Victor deals additional 25.0% direct damage to enemies affected by Witch Hunt (excluding Lords and Bosses).")


--[[
	I Shall Judge You All
]]
-- Headshotting a Witch Hunted enemy extends the isjya aura's duration by 1s
mod_api.insert_proc_function("tb_isjya_refresh_animosity_on_headshot", function (owner_unit, buff, params)
	if not Unit.alive(owner_unit) or not (is_server() or is_local(owner_unit)) then
		return
	end

	local hit_unit = params[1]
	local hit_zone_name = params[3]

	if hit_zone_name ~= "head" and hit_zone_name ~= "neck" then
		return
	end

	local hit_unit_buff_extension = hit_unit and ALIVE[hit_unit] and ScriptUnit.has_extension(hit_unit, "buff_system")

	if not hit_unit_buff_extension or not hit_unit_buff_extension:has_buff_type("defence_debuff_enemies") then
		return
	end

	local owner_buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local aura_buff = owner_buff_extension:get_buff_type("tb_isjya_aura")

	if aura_buff and aura_buff.duration then
		local t = Managers.time:time("game")
		local remaining = math.max(0, aura_buff.start_time + aura_buff.duration - t)

		aura_buff.start_time = t
		aura_buff.duration = remaining + 2 -- DURATION EXTENSION
	end
end)

mod_api.insert_talent_buff_template("witch_hunter", "tb_isjya_refresh_animosity_on_headshot", {
	buff_func = "tb_isjya_refresh_animosity_on_headshot",
	event = "on_hit",
})

mod_api.update_talent("wh_captain", 6, 1, {
	buffs = {
		"tb_isjya_refresh_animosity_on_headshot",
	},
})
mod_api.insert_text("victor_captain_activated_ability_stagger_ping_debuff_desc", "Animosity also grants an aura applying Witch Hunt and marking all enemies. Headshotting Witch-Hunted enemies extends the aura duration by 2 seconds.")

--[[ Ping Specials within ult radius on WHC ISJYA ULT ]]
local PING_DURATION = 15
local marked_enemies = {}

-- Mirrors AccessibilityOptions' "Dangerous Enemy" outline color exactly
-- isn't installed/enabled.
local function get_dangerous_enemy_color()
	local accessibility_options = get_mod("AccessibilityOptions")
	local marker_color = accessibility_options and OutlineSettings.colors.accessibility_dangerous_enemy_marker

	if not marker_color then
		return 227, 4, 4
	end

	local color = marker_color.color

	return color[2], color[3], color[4]
end

do
	local r, g, b = get_dangerous_enemy_color()

	OutlineSettings.colors.tb_judged_special = {
		pulsate = false,
		pulse_multiplier = 50,
		color = { 255, r, g, b }, -- alpha, r, g, b
	}
end
OutlineSettings.templates.tb_judged_special = {
	method = "ai_alive",
	priority = 15,
	outline_color = OutlineSettings.colors.tb_judged_special,
	flag = OutlineSettings.flags.non_wall_occluded,
}

-- Force every currently-tagged special's outline to redraw
local function refresh_judged_special_outlines()
	local color_table = OutlineSettings.colors.tb_judged_special

	for enemy_unit, data in pairs(marked_enemies) do
		if ALIVE[enemy_unit] and data.outline_id then
			local outline_extension = ScriptUnit.has_extension(enemy_unit, "outline_system")

			if outline_extension then
				outline_extension:update_outline({
					outline_color = table.clone(color_table),
				}, data.outline_id)
			end
		end
	end
end

-- Update outline color whenever AccessibilityOptions' Dangerous Enemy color changes.
mod:add_all_mods_loaded_function(function()
	local accessibility_options = get_mod("AccessibilityOptions")

	if not accessibility_options then
		return
	end

	accessibility_options:add_setting_changed_function(function ()
		local color = OutlineSettings.colors.tb_judged_special.color
		local r, g, b = get_dangerous_enemy_color()

		color[2], color[3], color[4] = r, g, b

		refresh_judged_special_outlines()
	end)
end)

-- Reveals/re-reveals every special within radius of position and applies Witch Hunt (+ Templar's Knowledge)
local function apply_isjya_special_marks(attacker_unit, position, radius, has_templars_knowledge)
	-- Re-sync from AccessibilityOptions here too (not just on setting-changed) so mark color is
	-- correct the first time it's actually used, regardless of mod load order.
	do
		local color = OutlineSettings.colors.tb_judged_special.color
		local r, g, b = get_dangerous_enemy_color()

		color[2], color[3], color[4] = r, g, b
	end

	local proximity_system = Managers.state.entity:system("proximity_system")
	local t = Managers.time:time("game")
	local radius_sq = radius * radius

	for enemy_unit, _ in pairs(proximity_system.ai_unit_extensions_map) do
		local breed = Unit.get_data(enemy_unit, "breed")
		local is_special = breed and breed.special
		local enemy_position = is_special and POSITION_LOOKUP[enemy_unit]

		if ALIVE[enemy_unit] and enemy_position and Vector3.distance_squared(position, enemy_position) <= radius_sq then
			if marked_enemies[enemy_unit] then
				marked_enemies[enemy_unit].expire_t = t + PING_DURATION
			else
				local ping_extension = ScriptUnit.has_extension(enemy_unit, "ping_system")

				if ping_extension then
					ping_extension:set_pinged(true, false, attacker_unit, false)

					local outline_extension = ScriptUnit.has_extension(enemy_unit, "outline_system")
					local outline_id = outline_extension and outline_extension:add_outline(OutlineSettings.templates.tb_judged_special)

					marked_enemies[enemy_unit] = {
						owner_unit = attacker_unit,
						expire_t = t + PING_DURATION,
						outline_id = outline_id,
					}
				end
			end

			if Managers.state.network.is_server then
				local buff_system = Managers.state.entity:system("buff_system")

				buff_system:add_buff_synced(enemy_unit, "defence_debuff_enemies", BuffSyncType.All, {
					external_optional_duration = PING_DURATION,
				})

				if has_templars_knowledge then
					buff_system:add_buff_synced(enemy_unit, "victor_witchhunter_improved_damage_taken_ping", BuffSyncType.All, {
						external_optional_duration = PING_DURATION,
					})
				end
			end
		end
	end
end

-- Applies Witch Hunt (+ Templar's Knowledge) to every enemy within radius of position.
local function apply_isjya_radius_debuff(attacker_unit, position, radius, has_templars_knowledge)
	if not Managers.state.network.is_server then
		return
	end

	local nearby_enemy_units = FrameTable.alloc_table()
	local proximity_system = Managers.state.entity:system("proximity_system")
	local broadphase = proximity_system.enemy_broadphase

	Broadphase.query(broadphase, position, radius, nearby_enemy_units)

	local buff_system = Managers.state.entity:system("buff_system")

	for _, enemy_unit in pairs(nearby_enemy_units) do
		if ALIVE[enemy_unit] then
			buff_system:add_buff_synced(enemy_unit, "defence_debuff_enemies", BuffSyncType.All, {
				external_optional_duration = PING_DURATION,
			})

			if has_templars_knowledge then
				buff_system:add_buff_synced(enemy_unit, "victor_witchhunter_improved_damage_taken_ping", BuffSyncType.All, {
					external_optional_duration = PING_DURATION,
				})
			end
		end
	end
end

-- isjya aura: while active, every 3s re-runs the marking/debuff
mod_api.insert_buff_function("tb_isjya_aura_pulse", function (unit, buff, params, world)
	if not HEALTH_ALIVE[unit] then
		return
	end

	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
	local has_templars_knowledge = talent_extension and talent_extension:has_talent("victor_witchhunter_improved_damage_taken_ping")

	local position = POSITION_LOOKUP[unit]

	apply_isjya_special_marks(unit, position, buff.range, has_templars_knowledge)
	apply_isjya_radius_debuff(unit, position, buff.range, has_templars_knowledge)
end)
local ISJYA_AURA_DURATION = 6
mod_api.insert_talent_buff_template("witch_hunter", "tb_isjya_aura", {
	icon = "victor_captain_activated_ability_stagger_ping_debuff",
	duration = ISJYA_AURA_DURATION,
	range = 10, -- Animosity's explosion radius
	update_func = "tb_isjya_aura_pulse",
	update_frequency = 3,
})

-- Register outline colors
local function tb_isjya_on_create_explosion(world, attacker_unit, impact_position, rotation, explosion_template, scale, damage_source, is_server, is_husk, damaging_unit, attacker_power_level, is_critical_strike, source_attacker_unit)
	if damage_source ~= "career_ability" or not ALIVE[attacker_unit] then
		return
	end

	local career_extension = ScriptUnit.has_extension(attacker_unit, "career_system")

	if not career_extension or career_extension:career_name() ~= "wh_captain" then
		return
	end

	local talent_extension = ScriptUnit.has_extension(attacker_unit, "talent_system")

	if not talent_extension or not talent_extension:has_talent("victor_captain_activated_ability_stagger_ping_debuff") then
		return
	end

	local has_templars_knowledge = talent_extension:has_talent("victor_witchhunter_improved_damage_taken_ping")

	apply_isjya_special_marks(attacker_unit, impact_position, explosion_template.explosion.radius * (scale or 1), has_templars_knowledge)

	-- Add ISJYA aura - if recasting while the old one is still active, reset
	if Managers.state.network.is_server then
		local buff_extension = ScriptUnit.extension(attacker_unit, "buff_system")
		local existing_aura = buff_extension:get_buff_type("tb_isjya_aura")

		if existing_aura then
			-- Duration drifts upward with each headshot extension (see the
			-- headshot proc above), so a recast must reset it back to base,
			-- not just re-anchor start_time.
			existing_aura.start_time = Managers.time:time("game")
			existing_aura.duration = ISJYA_AURA_DURATION
		else
			mod_api.add_buff(attacker_unit, "tb_isjya_aura")
		end
	end
end

-- Runs after the original, like a hook_safe. Registered through the dispatcher in TourneyBalance.lua.
mod:add_create_explosion_wrapper(function (func, ...)
	local result = func(...)

	tb_isjya_on_create_explosion(...)

	return result
end)

-- Clean up expired outlines
local MARK_EXPIRY_CHECK_INTERVAL = 1
local next_mark_expiry_check_t = 0
mod:add_ingame_hud_update_function(function (self)
	if not next(marked_enemies) then
		return
	end

	local t = Managers.time:time("game")
	local accessibility_options = get_mod("AccessibilityOptions")

	-- Keep animating every frame while Dangerous Enemy is set to Rainbow. Fetched fresh here (not
	-- from a cached file-scope local) since get_mod is cheap and this sidesteps any mod-load-order
	-- assumptions entirely - see the on_all_mods_loaded registration above for why a cached
	-- reference is risky.
	if accessibility_options and accessibility_options:get("outline_dangerous_color_group") == "rainbow" then
		local color = OutlineSettings.colors.tb_judged_special.color
		local r, g, b = get_dangerous_enemy_color()

		color[2], color[3], color[4] = r, g, b

		refresh_judged_special_outlines()
	end

	if t < next_mark_expiry_check_t then
		return
	end

	next_mark_expiry_check_t = t + MARK_EXPIRY_CHECK_INTERVAL

	for enemy_unit, data in pairs(marked_enemies) do
		if not ALIVE[enemy_unit] or t >= data.expire_t then
			if ALIVE[enemy_unit] then
				local ping_extension = ScriptUnit.has_extension(enemy_unit, "ping_system")

				if ping_extension then
					ping_extension:set_pinged(false, nil, data.owner_unit, false)
				end

				local outline_extension = ScriptUnit.has_extension(enemy_unit, "outline_system")

				if outline_extension and data.outline_id then
					outline_extension:remove_outline(data.outline_id)
				end
			end

			marked_enemies[enemy_unit] = nil
		end
	end
end)

--[[
	Fervency
]]
-- Extend durationto 10s
mod_api.update_talent_buff_template("witch_hunter", "victor_witchhunter_activated_ability_guaranteed_crit_self_buff", {
	duration = 10, -- 6
})

-- Additionall 20 stacks of guaranteed melee crit hits on ult use
mod_api.insert_talent_buff_template("witch_hunter", "tb_fervency_crit_stacks", { -- 20 stacks of melee crits buff
	icon = "victor_witchhunter_activated_ability_guaranteed_crit_self_buff",
	stat_buff = "critical_strike_chance_melee",
	bonus = 1,
	max_stacks = 20,
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_fervency_stack_provider", { -- provides the 20 stacks on ult
	buff_func = "add_buff_reff_buff_stack",
	buff_to_add = "tb_fervency_crit_stacks",
	amount_to_add = 20,
	event = "on_ability_activated",
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_fervency_stack_consumer", { -- consumes 1 stack per enemy hit
	buff_func = "remove_buff_stack",
	event = "on_melee_hit",
	max_stacks = 1,
	remove_buff_stack_data = {
		{ buff_to_remove = "tb_fervency_crit_stacks", num_stacks = 1 },
	},
})
mod_api.update_talent("wh_captain", 6, 2, {
	buffs = {
		"tb_fervency_stack_provider",
		"tb_fervency_stack_consumer"
	},
})
mod_api.insert_text("victor_witchhunter_activated_ability_guaranteed_crit_self_buff_desc", "Animosity grants Victor guaranteed melee critical strikes for 10 seconds and the next 20 melee hits. No longer affects teammates and ranged attacks.")

--[[
	Unending Hunt
]]
-- Teammates' crit chance reduced to 25% only when the caster has Unending Hunt (6-3); the caster keeps 25%
local function is_unending_hunt_ally(unit, params)
	local caster_unit = params and params.attacker_unit

	if not caster_unit or caster_unit == unit then
		return false
	end

	local talent_extension = ScriptUnit.has_extension(caster_unit, "talent_system")

	return talent_extension and talent_extension:has_talent("victor_witchhunter_activated_ability_refund_cooldown_on_enemies_hit") or false
end

do
	local crit_buff_template = TalentBuffTemplates.witch_hunter.victor_witchhunter_activated_ability_crit_buff
	local sub_buffs = crit_buff_template.buffs
	local vanilla_sub_buff = sub_buffs[1]

	vanilla_sub_buff.apply_condition = function (unit, template, params)
		return not is_unending_hunt_ally(unit, params)
	end

	-- Distinct name so num_buff_type/max_stacks don't collide with the vanilla sub-buff
	local unending_hunt_sub_buff = table.clone(vanilla_sub_buff)
	unending_hunt_sub_buff.name = "tb_unending_hunt_crit_buff"
	unending_hunt_sub_buff.bonus = 0.15 -- 0.25
	unending_hunt_sub_buff.apply_condition = function (unit, template, params)
		return is_unending_hunt_ally(unit, params)
	end

	sub_buffs[2] = unending_hunt_sub_buff
	BuffTemplates.victor_witchhunter_activated_ability_crit_buff = crit_buff_template
end
mod_api.update_talent("wh_captain", 6, 3, {
	description = "victor_witchhunter_activated_ability_refund_cooldown_on_enemies_hit_desc",
	description_values = {},
})
mod_api.insert_text("victor_witchhunter_activated_ability_refund_cooldown_on_enemies_hit_desc", "Hitting at least 10 enemies with Animosity refunds 40.0% of its cooldown. Critical strike chance bonus for allies is reduced to 15.0%.")

