local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Foot Knight
		### Career Ability
		- Ult blast radius buffed to 5 (from 3) for all ults.

		### Passives
		**Protective Presence**
		- Aura radius increased to 20 (from 5).

		**CDR on Damage Taken**
		- Reduced ult cooldown gain on damage taken to 0.35 (from 0.5).

		### Talents
		**Staggering Force**
		- Stagger power decreased to 20% (from 35%).

		**That's Bloody Teamwork!**
		- Grants 3.33% damage reduction per nearby ally (up to 3).

		**Have At Thee!**
		- Also procs when Mainstay marks an elite with a stagger count, even if the hit doesn't actually stagger it.

		**Crowd Clearer**
		- Duration increased to 5s (from 3s).

		**Rock of Reikland**
		- Global team passive; allies keep it while the Foot Knight is dead. Shows a buff icon.
		- Increased block cost reduction to 30% (from 20%)
		- Added 30% stamina recovery
		- Added 10% damage reduction

		**Comrades in Arms**
		- Closest player mode (green outline).
		- Guard select team mate mode (red outline with number); no range limit.
		- Press weapon_inspect while blocking to cycle between modes and team mates.

		**It's Hero Time**
		- Added 15s internal cooldown.
		
		**Inspiring Blow**
		- Now only affects the Foot Knight himself (no longer nearby allies).
		- Increased cooldown regeneration duration to 1.0s (from 0.5s).
		- Also procs when Mainstay marks an elite with a stagger count, even if the hit doesn't actually stagger it.
		- Mainstay grants effect at 10% cooldown regeneration for 1.0s

		**Numb to Pain**
		- Invulnerability duration on ult increased to 6s (from 3s).
		- Hit trading at 10% effectiveness.

		**Bull of Ostland**
		- Attack speed buff from ult hits lasts 15s (from 10s).
	$END_TB
]]

--[[

	Ultimate

]]
-- Increased ult cooldown
-- ActivatedAbilitySettings.es_2[1].cooldown = 40 -- 30

-- Charge + blast damage/stagger cleave. Edited in place: damage profiles resolve their cleave_distribution name to
-- this exact table at load (damage_profile_templates.lua), so swapping in a new table at runtime has no effect.
local charge_cleave_distribution = PowerLevelTemplates.cleave_distribution_markus_knight_charge
charge_cleave_distribution.attack = 4 -- 2
charge_cleave_distribution.impact = 4 -- 2

-- do_lunge is rebuilt on every activation, so it's adjusted after vanilla's _run_ability.
-- Battering Ram's wide charge (no stop on max hit mass) is applied by vanilla _run_ability itself.
mod:hook(CareerAbilityESKnight, "_run_ability", function (func, self, ...)
	func(self, ...)

	local lunge_damage = self._status_extension.do_lunge.damage

	lunge_damage.on_interrupt_blast.radius = 5 -- 3
end)

--[[

	Passives

]]
--[[
	Protective Presence
]]
-- Increase aura range - Repeat for all lvl 20 talents, because game creates snapshot of original values at load time
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_passive", {
	range = 20 -- 5
})
-- Nerf of aura damage reduction - Repeat for all lvl 20 talents, because game creates snapshot of original values at load time
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura", {
	multiplier = -0.15
})
mod_api.insert_text("career_passive_desc_es_2a_2", "Aura that reduces damage taken by 15%")

--[[
	Rock of Reikland - global passive
]]
local ROCK_OF_REIKLAND_BUFF = "tb_markus_knight_rock_of_reikland_buff"

mod_api.insert_talent_buff_template("empire_soldier", ROCK_OF_REIKLAND_BUFF, {
	{
		name = ROCK_OF_REIKLAND_BUFF,
		max_stacks = 1,
		stat_buff = "block_cost",
		multiplier = -0.3,
		icon = "markus_knight_passive_block_cost_aura",
	},
	{
		name = "tb_markus_knight_rock_of_reikland_stamina_regen",
		max_stacks = 1,
		stat_buff = "fatigue_regen",
		multiplier = 0.3,
	},
	{
		name = "tb_markus_knight_rock_of_reikland_damage_taken",
		max_stacks = 1,
		stat_buff = "damage_taken",
		multiplier = -0.1,
	},
})

-- Same pattern as Sister of the Thorn's team auras (range = 100)
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_passive_block_cost_aura", {
	buff_to_add = ROCK_OF_REIKLAND_BUFF,
	update_func = "activate_buff_on_distance",
	range = 1000, -- 10
})
mod_api.update_talent("es_knight", 4, 1, {
	buffs = { "markus_knight_passive_block_cost_aura" },
	description = "tb_markus_knight_rock_of_reikland_desc",
	description_values = {},
})
mod_api.insert_text("tb_markus_knight_rock_of_reikland_desc", "Protective Presence is always active and grants 30% block cost reduction and 30% stamina regeneration.")

--[[
	Comrades in Arms - Adjustment from Passive

	Weapon Inspect (action_inspect) while holding block cycles who receives Comrades in Arms:
	closest ally (vanilla) -> teammate 2 -> teammate 3 -> ... -> back to closest.
	The Foot Knight himself is never a valid recipient in either mode.
	Manual mode ignores range entirely (whoever is selected gets it regardless of distance)

	Indicator (self-only, shown on the Knight's own buff bar):
	  - Closest mode: no icon at all (the default).
	  - Manual mode: tb_markus_knight_guard_mode_manual, debuff=true (red outline), stack count
	    = the selected teammate's number (2..N, matching "players besides FK numbered from 2 to N").
]]
mod_api.update_talent("es_knight", 4, 3, { -- update description
	description_values = {
	},
})
mod_api.insert_text("markus_knight_guard_desc", "Kruber gains 10.0% increased power. The closest ally to Kruber gains 50.0% damage reduction and 10.0% increased power. Passive aura from Protective Presence no longer affects allies.\n\nUse weapon inspect while holding block to cycle between guarding a select team mate or the closest one.")

-- owner_unit -> { mode = "closest" | "manual", index = N (1-based into teammate_indices), indicator_stack_ids }
local comrades_in_arms_cycle = {}

-- Stable, deterministic ordering
local function tb_get_comrades_in_arms_teammates(owner_unit)
	local players = Managers.player:players()
	local teammates = {}

	for _, player in pairs(players) do
		if player.player_unit ~= owner_unit then
			local sort_key = tostring(player:network_id()) .. "_" .. tostring(player:local_player_id())

			teammates[#teammates + 1] = {
				player = player,
				sort_key = sort_key,
			}
		end
	end

	table.sort(teammates, function (a, b)
		return a.sort_key < b.sort_key
	end)

	return teammates
end

local function tb_update_comrades_in_arms_indicator(owner_unit, state)
	local buff_system = Managers.state.entity:system("buff_system")

	-- Clear whatever stack count was showing before (no-op in closest mode, since there's nothing to show)
	local stack_ids = state.indicator_stack_ids

	if stack_ids then
		for i = 1, #stack_ids do
			buff_system:remove_server_controlled_buff(owner_unit, stack_ids[i])
		end
	end

	state.indicator_stack_ids = nil

	if state.mode == "manual" then
		local desired_count = state.index + 1 -- teammates are numbered 2..N
		local new_stack_ids = {}

		for _ = 1, desired_count do
			new_stack_ids[#new_stack_ids + 1] = buff_system:add_buff(owner_unit, "tb_markus_knight_guard_mode_manual", owner_unit, true)
		end

		state.indicator_stack_ids = new_stack_ids
	end
end

mod_api.insert_buff_function("tb_cycle_comrades_in_arms_target", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local teammates = tb_get_comrades_in_arms_teammates(owner_unit)

	if not teammates or #teammates == 0 then
		return
	end

	local state = comrades_in_arms_cycle[owner_unit]

	if not state then
		state = { mode = "closest", index = 0 }
		comrades_in_arms_cycle[owner_unit] = state
	end

	if state.mode == "closest" then
		state.mode = "manual"
		state.index = 1
	else
		state.index = state.index + 1

		if state.index > #teammates then
			state.mode = "closest"
			state.index = 0
		end
	end

	tb_update_comrades_in_arms_indicator(owner_unit, state)
end)

-- Fired by a client (or the host directly) whenever switching Guard Mode
-- mod_api.add_buff handles the client->server RPC, and this buff_func only ever mutates state server-side.
mod_api.insert_buff_template("tb_markus_knight_guard_cycle_pulse", {
	max_stacks = 1,
	refresh_durations = true,
	duration = 0.3,
	apply_buff_func = "tb_cycle_comrades_in_arms_target",
	reapply_buff_func = "tb_cycle_comrades_in_arms_target",
})
mod_api.insert_buff_template("tb_markus_knight_guard_mode_manual", {
	max_stacks = 99, -- 4
	debuff = true,
	icon = "markus_knight_passive_power_increase",
})

-- Global per-frame check on the local player only
local tb_action_inspect_was_pressed = false
local tb_is_comrades_in_arms_knight = false
local tb_next_comrades_in_arms_check_t = 0
local COMRADES_IN_ARMS_TALENT_CHECK_INTERVAL = 0.5

-- Chat print of the current guard target. The cycle state lives on the server, but the indicator
-- stack count (0 = closest, N = teammate index + 1) is synced to the Knight, so read it back from there.
-- The server clears then re-adds every stack on a switch, so wait for the count to settle before printing.
local tb_guard_announced_unit = nil
local tb_guard_announced_count = nil
local tb_guard_pending_count = nil
local tb_guard_pending_since_t = 0
local COMRADES_IN_ARMS_ANNOUNCE_SETTLE_TIME = 0.2

local function tb_announce_comrades_in_arms_target(owner_unit, t)
	local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

	if not buff_extension then
		return
	end

	local count = buff_extension:num_buff_type("tb_markus_knight_guard_mode_manual")

	-- New unit (spawn/respawn/talent swap): take the current state silently.
	if tb_guard_announced_unit ~= owner_unit then
		tb_guard_announced_unit = owner_unit
		tb_guard_announced_count = count
		tb_guard_pending_count = nil

		return
	end

	if count ~= tb_guard_pending_count then
		tb_guard_pending_count = count
		tb_guard_pending_since_t = t

		return
	end

	if count == tb_guard_announced_count or t - tb_guard_pending_since_t < COMRADES_IN_ARMS_ANNOUNCE_SETTLE_TIME then
		return
	end

	tb_guard_announced_count = count

	if count == 0 then
		mod:echo("Guarding the closest comrade.")

		return
	end

	local teammates = tb_get_comrades_in_arms_teammates(owner_unit)
	local target_entry = teammates[count - 1]
	local target_name = target_entry and target_entry.player:name() or "unknown"

	mod:echo(string.format("Guarding %s (%d).", target_name, count))
end

mod:add_update_function(function (dt)
	local local_player = Managers.player:local_player_safe(1)
	local owner_unit = local_player and local_player.player_unit

	if not owner_unit or not Unit.alive(owner_unit) then
		tb_action_inspect_was_pressed = false

		return
	end

	local t = Managers.time:time("main")

	if t >= tb_next_comrades_in_arms_check_t then
		tb_next_comrades_in_arms_check_t = t + COMRADES_IN_ARMS_TALENT_CHECK_INTERVAL

		local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

		tb_is_comrades_in_arms_knight = not not (talent_extension and talent_extension:has_talent("markus_knight_guard", "empire_soldier", true))
	end

	if not tb_is_comrades_in_arms_knight then
		tb_guard_announced_unit = nil

		return
	end

	tb_announce_comrades_in_arms_target(owner_unit, t)

	local status_extension = ScriptUnit.has_extension(owner_unit, "status_system")

	if not status_extension or not status_extension:is_blocking() then
		tb_action_inspect_was_pressed = false

		return
	end

	local input_extension = ScriptUnit.extension(owner_unit, "input_system")
	local is_pressed = input_extension:get("action_inspect")

	if is_pressed and not tb_action_inspect_was_pressed then
		mod_api.add_buff(owner_unit, "tb_markus_knight_guard_cycle_pulse")
	end

	tb_action_inspect_was_pressed = is_pressed
end)

-- Remove the guard buff we previously put on `unit` (tracked via buff.server_id, like activate_buff_on_distance)
local function tb_remove_guard_buff(buff_system, unit, buff_to_add)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local guard_buff = buff_extension and buff_extension:get_non_stacking_buff(buff_to_add)

	if guard_buff and guard_buff.server_id then
		buff_system:remove_server_controlled_buff(unit, guard_buff.server_id)
	end
end

mod_api.insert_buff_function("tb_activate_buff_on_selected_or_closest", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local state = comrades_in_arms_cycle[owner_unit]

	if not state or state.mode == "closest" then
		BuffFunctionTemplates.functions.activate_buff_on_closest_distance(owner_unit, buff, params)

		return
	end

	local buff_to_add = buff.template.buff_to_add
	local buff_system = Managers.state.entity:system("buff_system")
	local current_unit = buff.current_unit
	local teammates = tb_get_comrades_in_arms_teammates(owner_unit)
	local target_entry = teammates[state.index]
	local target_unit = target_entry and target_entry.player.player_unit

	-- The selected teammate died or their slot is gone (disconnected) - auto-revert to closest
	-- instead of silently buffing nobody until the player manually cycles back.
	if not target_unit or not ALIVE[target_unit] then
		state.mode = "closest"
		state.index = 0

		if current_unit then
			tb_remove_guard_buff(buff_system, current_unit, buff_to_add)

			buff.current_unit = nil
		end

		tb_update_comrades_in_arms_indicator(owner_unit, state)
		BuffFunctionTemplates.functions.activate_buff_on_closest_distance(owner_unit, buff, params)

		return
	end

	if current_unit and current_unit ~= target_unit then
		tb_remove_guard_buff(buff_system, current_unit, buff_to_add)
	end

	buff.current_unit = target_unit

	local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")

	if not target_buff_extension:has_buff_type(buff_to_add) then
		local server_id = buff_system:add_buff(target_unit, buff_to_add, owner_unit, true)
		local new_buff = target_buff_extension:get_non_stacking_buff(buff_to_add)

		if new_buff then
			new_buff.server_id = server_id
		end
	end
end)

mod_api.update_talent_buff_template("empire_soldier", "markus_knight_guard_defence", {
	buff_to_add = "markus_knight_guard_defence_buff",
	stat_buff = "damage_taken",
	update_func = "tb_activate_buff_on_selected_or_closest",
	remove_buff_func = "remove_aura_buff",
	range = 20 -- 5
})
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_guard", {
	buff_to_add = "markus_knight_passive_power_increase_buff",
	stat_buff = "power_level",
	remove_buff_func = "remove_aura_buff",
	icon = "markus_knight_passive_power_increase",
	update_func = "tb_activate_buff_on_selected_or_closest",
	range = 20 -- 5
})

--[[
	That's Bloody Teamwork - Adjustment from Passive
]]
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity", {
	buff_to_add = "markus_knight_damage_taken_ally_proximity_buff",
	range = 20, -- 5
	update_func = "activate_party_buff_stacks_on_ally_proximity", -- TODO: Check - Removed proc function, might break, replaced buff.range replaced w/ template.range
	chunk_size = 1,
	max_stacks = 3,
	remove_buff_func = "remove_party_buff_stacks"
})
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity_buff", {
	multiplier = -0.0333
})

--[[
	Unlisted: Ult CD on Taking Damage
]]
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_ability_cooldown_on_damage_taken", {
	bonus = 0.35 -- 0.5
})

--[[

	Talents

]]
--[[
	Staggering Force
]]
-- Stagger power decreased to 20% (from 35%)
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_power_level_impact", {
	multiplier = 0.2 --0.35
})
mod_api.update_talent("es_knight", 2, 1, {
	description_values = { -- update description
		{
			value_type = "percent",
			value = 0.2, -- buff_tweak_data.markus_knight_power_level_impact.multiplier
		}
	},
})

--[[
	Have At Thee!
	Proc from Mainstay stagger count on an elite
	thp_stagger_damage_changes/01_damage_calc_changes.lua > mod:hook_origin(DamageUtils, "server_apply_hit", ...)
]]
mod_api.update_talent("es_knight", 2, 2, { -- update description
	description_values = {
	},
})
mod_api.insert_text("markus_knight_power_level_on_stagger_elite_desc", "Inflicting stagger counts on an elite enemy increases power by 15.0% for 10 seconds.")

--[[
	Crowd Clearer
]]
-- Duration increased to 5s (from 3s)
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_attack_speed_on_push_buff", {
	duration = 5 -- 3
})
mod_api.update_talent("es_knight", 2, 3, { -- update description
	description_values = {
		{
			value_type = "percent",
			value = 0.15 -- buff_tweak_data.markus_knight_attack_speed_on_push_buff.multiplier
		},
		{
			value = 5 -- buff_tweak_data.markus_knight_attack_speed_on_push_buff.duration
		}
	},
})

--[[
	It's Hero Time
]]
-- 10s ICD nerf
mod_api.insert_buff_template("tb_markus_knight_hero_time_ready_buff", {
	icon = "markus_knight_movement_speed_on_incapacitated_allies",
})
mod_api.insert_buff_template("tb_markus_knight_hero_time_cooldown_buff", {
	icon = "markus_knight_movement_speed_on_incapacitated_allies",
 	is_cooldown = true,
 	duration = 10,
 	duration_end_func = "add_buff_local",
 	buff_to_add = "tb_markus_knight_hero_time_ready_buff",
})
mod_api.insert_buff_function("markus_hero_time_reset", function (player_unit, buff, params)
	if not Unit.alive(player_unit) then
		return
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
	
	if not buff_extension or buff_extension:has_buff_type("tb_markus_knight_hero_time_cooldown_buff") then
	 	return
	end

	local career_extension = ScriptUnit.has_extension(player_unit, "career_system")

	if not career_extension or career_extension:current_ability_cooldown(1) == 0 then
		return
	end

	career_extension:reduce_activated_ability_cooldown_percent(1) -- 0.7

	local ready_buff = buff_extension:get_buff_type("tb_markus_knight_hero_time_ready_buff")
	
	if ready_buff then
		buff_extension:remove_buff(ready_buff.id)
	end
	
	buff_extension:add_buff("tb_markus_knight_hero_time_cooldown_buff")
end)
mod_api.insert_text("markus_knight_charge_reset_on_incapacitated_allies_desc", "Resets cooldown on Valiant Charge when an ally is incapacitated. 10 second cooldown.")

-- Fix Hero Time not proccing if ally already disabled
mod_api.insert_buff_function("markus_knight_movespeed_on_incapacitated_ally", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local side = Managers.state.side.side_by_unit[owner_unit]
	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
	local num_units = #player_and_bot_units
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local buff_to_add = template.buff_to_add
	local disabled_allies = 0

	for i = 1, num_units do
		local unit = player_and_bot_units[i]
		local status_extension = ScriptUnit.extension(unit, "status_system")
		local is_disabled = status_extension:is_disabled()

		if is_disabled then
			disabled_allies = disabled_allies + 1
		end
	end

	if not buff.disabled_allies then
		buff.disabled_allies = 0
	end

	if buff_extension:has_buff_type(buff_to_add) then
		if disabled_allies <= buff.disabled_allies then
			local buff_id = buff.buff_id

			if buff_id then
				buff_system:remove_server_controlled_buff(owner_unit, buff_id)

				buff.buff_id = nil
			end
		end
	elseif disabled_allies > 0 and disabled_allies > buff.disabled_allies then
		buff.buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
	end

	buff.disabled_allies = disabled_allies

	-- It's Hero Time: show the "ready" icon (disabled along with the ICD)
	if not buff_extension:has_buff_type("tb_markus_knight_hero_time_ready_buff") and not buff_extension:has_buff_type("tb_markus_knight_hero_time_cooldown_buff") then
	 	buff_system:add_buff(owner_unit, "tb_markus_knight_hero_time_ready_buff", owner_unit, true)
	end
end)

--[[
	Inspiring Blow - self only (not nearby allies)
	Proc from Mainstay stagger count on an elite
	thp_stagger_damage_changes/01_damage_calc_changes.lua > mod:hook_origin(DamageUtils, "server_apply_hit", ...)
]]
-- Vanilla's own buff_func (markus_knight_reduce_cooldown_on_stagger) applies to nearby allies in
-- range; buff_on_stagger_enemy (same one Have At Thee uses) is self-only.
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_cooldown_on_stagger_elite", {
	buff_func = "buff_on_stagger_enemy"
})
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_cooldown_buff", {
	duration = 1.5, -- 0.5
	multiplier = 2, -- 2
	icon = "markus_knight_improved_passive_defence_aura"
})
mod_api.insert_text("markus_knight_cooldown_on_stagger_elite_desc", "Staggering an elite enemy (with Mainstay) accelerates your own cooldown by 200%% (20%%) for 1.5 (1.5) seconds.")

-- Separate, weaker buff for the Mainstay stagger-count proc
mod_api.insert_buff_template("tb_markus_knight_cooldown_buff_mainstay", {
	max_stacks = 1,
	refresh_durations = true,
	stat_buff = "cooldown_regen",
	duration = 1.5,
	multiplier = 0.2,
	icon = "markus_knight_improved_passive_defence_aura",
})

--[[
	Numb to Pain
]]
-- Invulnerability on ult duration increased to 6s
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_ability_invulnerability_buff", {
	duration = 5 -- 3
})
mod_api.update_talent("es_knight", 6, 1, {
	description_values = {
		{
			value = 6 -- 3
		}
	},
})
mod_api.insert_text("markus_knight_ability_invulnerability_desc", "Valiant Charge makes Kruber immune to damage for %s seconds. Damage prevented reduces the cooldown of Valiant Charge at 20%% effectiveness.")

-- Numb to Pain is a damage_taken -100% stat buff
-- Hit trading: damage prevented by Numb to Pain still charges the ult at the normal on-damage-taken rate.
local NUMB_TO_PAIN_BUFF = "markus_knight_ability_invulnerability_buff"
local CDR_ON_DAMAGE_TAKEN_BUFF = "markus_knight_ability_cooldown_on_damage_taken"
local ULT_REGEN_MODIFIER = 0.1 -- x * 0.35

local tb_reduce_cooldown_on_owner = require("scripts/mods/TourneyBalance/_api/shared_utils").reduce_cooldown_on_owner

-- Registered through the dispatcher in TourneyBalance.lua
mod:add_apply_buffs_to_damage_wrapper(function (func, current_damage, attacked_unit, attacker_unit, damage_source, ...)
	local buff_extension = ScriptUnit.has_extension(attacked_unit, "buff_system")
	local numb_to_pain = buff_extension and buff_extension:get_non_stacking_buff(NUMB_TO_PAIN_BUFF)
	local damage_taken_stat = numb_to_pain and numb_to_pain.stat_buff_index and buff_extension._stat_buffs.damage_taken[numb_to_pain.stat_buff_index]

	if not damage_taken_stat then
		return func(current_damage, attacked_unit, attacker_unit, damage_source, ...)
	end

	local saved_multiplier = damage_taken_stat.multiplier

	damage_taken_stat.multiplier = saved_multiplier - numb_to_pain.multiplier

	local prevented_damage = func(current_damage, attacked_unit, attacker_unit, damage_source, ...)

	damage_taken_stat.multiplier = saved_multiplier

	-- Same conditions as vanilla's proc: real damage, not self-inflicted, not temp health decay
	if prevented_damage > 0 and attacker_unit ~= attacked_unit and damage_source ~= "temporary_health_degen" then
		local bonus = BuffTemplates[CDR_ON_DAMAGE_TAKEN_BUFF].buffs[1].bonus

		tb_reduce_cooldown_on_owner(attacked_unit, bonus * prevented_damage * ULT_REGEN_MODIFIER)
	end

	return 0
end)

--[[
	Bull of Ostland
]]
-- Attack speed buff from ult hits lasts 15s (from 10s)
mod_api.update_talent_buff_template("empire_soldier", "markus_knight_ability_attack_speed_enemy_hit_buff", {
	duration = 15 -- 10
})
mod_api.update_talent("es_knight", 6, 3, { -- update description (update_talent replaces the whole list, so all three values are listed)
	description_values = {
		{
			value_type = "percent",
			value = 0.03, -- buff_tweak_data.markus_knight_ability_attack_speed_enemy_hit_buff.multiplier
		},
		{
			value = 15, -- 10, buff_tweak_data.markus_knight_ability_attack_speed_enemy_hit_buff.duration
		},
		{
			value = 10, -- buff_tweak_data.markus_knight_ability_attack_speed_enemy_hit_buff.max_stacks
		},
	},
})



