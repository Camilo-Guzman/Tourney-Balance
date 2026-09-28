local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Slayer
		### Passive
		**Trophy Hunter**
		- Each stack additionally grants 5% attack speed.
		- Damage bonus now also applies to ranged weapons.

		**Path of Carnage**
		- Attack speed increased to 10% (from 7.5%).

		### Career Skill
		**Leap**
		- Attack speed reduced to 15% (from 30%).

		### Talents
		**A Thousand Cuts**
		- Attack speed increased to 15% (from 10%).

		**Impatience**
		- Trophy Hunter stacks last 10 seconds (from 2).

		**High Tally**
		- Increases Trophy Hunter's maximum stacks to 5 (from 4).

		**Adrenaline Surge**
		- Changed to 67% cooldown reduction per Trophy Hunter stack (300% only at max stacks).

		**Oblivious to Pain**
		- Each Trophy Hunter stack additionally reduces damage taken by 3%.

		**Barge**
		- Stagger strength on dodge increased to medium_push (from light_push).
		- Stagger radius on dodge increased to 3 (from 1.5).
		- Now increases healing received by 50%.
		- Now converts 50% of damage taken into a non-lethal bleed lasting 10 seconds.

		**Dawi Drop**
		- Additionally grants max Trophy Hunter stacks (up to 5, with High Tally) when Leap starts.

		**No Escape**
		- Melee and ranged attacks no longer slow movement while Leap is active.
]]

--[[

	Passive

]]

local function tb_slayer_has_talent(unit, talent_name)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	return not not (talent_extension and talent_extension:has_talent(talent_name, "dwarf_ranger", true))
end

-- Impatience extends Trophy Hunter stacks, runs wherever the buff is added (server and owner)
local TB_IMPATIENCE_STACK_DURATION = 10

local function tb_slayer_trophy_hunter_duration(unit, sub_buff_template, duration, buff_extension, params)
	if duration and tb_slayer_has_talent(unit, "bardin_slayer_passive_movement_speed") then
		duration = TB_IMPATIENCE_STACK_DURATION
	end

	return duration, nil
end

--[[
	Trophy Hunter
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_stacking_damage_buff", {
	stat_buff = "increased_weapon_damage", -- increased_weapon_damage_melee, now ranged too (High Tally's stack already uses this)
	duration_modifier_func = tb_slayer_trophy_hunter_duration, -- Added
})

-- 5% attack speed per stack. High Tally gets its own template since max_stacks lives on the sub-buff
mod_api.insert_talent_buff_template("dwarf_ranger", "tb_bardin_slayer_passive_attack_speed", {
	stat_buff = "attack_speed",
	multiplier = 0.05,
	max_stacks = 3,
	duration = 2,
	refresh_durations = true,
	duration_modifier_func = tb_slayer_trophy_hunter_duration,
})
mod_api.insert_talent_buff_template("dwarf_ranger", "tb_bardin_slayer_passive_attack_speed_high_tally", {
	stat_buff = "attack_speed",
	multiplier = 0.05,
	max_stacks = 5,
	duration = 2,
	refresh_durations = true,
})
mod_api.insert_text("career_passive_desc_dr_2a_3", "Hitting an enemy grants a stack of Trophy Hunter, increasing weapon damage by 10% and attack speed by 5%. Lasts 2 seconds, stacks up to 3 times.")

-- Buffs making up one Trophy Hunter stack for this Slayer's talents (Impatience, High Tally, Adrenaline Surge)
local function tb_slayer_trophy_hunter_buff_names(owner_unit)
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local buff_names = {
		"bardin_slayer_passive_stacking_damage_buff",
		"tb_bardin_slayer_passive_attack_speed",
	}

	if talent_extension:has_talent("bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
		buff_names[1] = "bardin_slayer_passive_increased_max_stacks"
		buff_names[2] = "tb_bardin_slayer_passive_attack_speed_high_tally"
	end

	if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) then
		buff_names[#buff_names + 1] = "bardin_slayer_passive_movement_speed"
	end

	if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) then
		buff_names[#buff_names + 1] = "bardin_slayer_passive_cooldown_reduction_on_max_stacks"
	end

	-- Oblivious to Pain is in a different row, so it combines with High Tally
	if talent_extension:has_talent("bardin_slayer_damage_taken_capped", "dwarf_ranger", true) then
		local has_high_tally = buff_names[1] == "bardin_slayer_passive_increased_max_stacks"

		buff_names[#buff_names + 1] = has_high_tally and "tb_bardin_slayer_oblivious_damage_reduction_high_tally" or "tb_bardin_slayer_oblivious_damage_reduction"
	end

	return buff_names
end

mod_api.insert_proc_function("add_bardin_slayer_passive_buff", function(owner_unit, buff, params)
	if not Managers.state.network.is_server or not Unit.alive(owner_unit) then
		return
	end

	local buff_system = Managers.state.entity:system("buff_system")

	for _, buff_name in ipairs(tb_slayer_trophy_hunter_buff_names(owner_unit)) do
		buff_system:add_buff(owner_unit, buff_name, owner_unit, false)
	end
end)

--[[
	Path of Carnage
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_attack_speed", {
	multiplier = 0.1, -- 0.075
})
mod_api.insert_text("career_passive_desc_dr_2b_2", "Increases attack speed by 10%.")

--[[

	Career Skill

]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_activated_ability", {
	name = TalentBuffTemplates.dwarf_ranger.bardin_slayer_activated_ability.buffs[1].name, -- keep sub-buff name, the api would reset it to the template key
	multiplier = 0.15, -- 0.3
})
mod_api.insert_text("career_active_desc_dr_2_2", "Bardin leaps forward, staggering enemies where he lands. Grants 15% attack speed for 10 seconds.")

--[[

	Talents

]]

--[[
	A Thousand Cuts
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_attack_speed_on_double_one_handed_weapons", {
	multiplier = 0.15 -- 0.1
})
mod_api.insert_text("bardin_slayer_attack_speed_on_double_one_handed_weapons_desc", "Gain 15.0%% attack speed if wielding 2 one-handed weapons.")

--[[
	Impatience
]]
-- Only granted with Impatience, so it uses the extended Trophy Hunter duration directly
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_movement_speed", {
	duration = TB_IMPATIENCE_STACK_DURATION, -- 2
	icon = "bardin_slayer_passive_movement_speed", -- Added, Impatience's talent icon
})
mod_api.insert_text("bardin_slayer_passive_movement_speed_desc", "Each stack of Trophy Hunter increases movement speed by 10.0%%. Trophy Hunter stacks now last 10 seconds.")

--[[
	High Tally
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_increased_max_stacks", {
	max_stacks = 5, -- 4
})
mod_api.insert_text("bardin_slayer_passive_increased_max_stacks_desc", "Increases Trophy Hunter's maximum stacks to 5.")

--[[
	Adrenaline Surge
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_cooldown_reduction_on_max_stacks", {
	duration = 2,
	multiplier = 0.67, -- Added
	max_stacks = 3, -- 1
})
mod_api.insert_text("bardin_slayer_passive_cooldown_reduction_on_max_stacks_desc", "Each stack of Trophy Hunter increases cooldown regeneration by 67%.")

--[[
	Barge
]]
-- Medium push
ExplosionTemplates.bardin_slayer_push_on_dodge.explosion.damage_profile = "medium_push" -- light_push
ExplosionTemplates.bardin_slayer_push_on_dodge.explosion.radius = 3 -- 1.5
ExplosionTemplates.bardin_slayer_push_on_dodge.explosion.max_damage_radius = 3 -- 1.5
-- Also increases healing received and converts damage taken into a bleed (add_damage hook below)
mod_api.insert_talent_buff_template("dwarf_ranger", "tb_bardin_slayer_barge_healing_received", {
	stat_buff = "healing_received",
	multiplier = 0.5,
})
mod_api.update_talent("dr_slayer", 5, 3, {
	description = "bardin_slayer_push_on_dodge_desc",
	buffer = "both", -- the push procs on the owner, heals are resolved server side
	buffs = {
		"bardin_slayer_push_on_dodge",
		"tb_bardin_slayer_barge_healing_received",
	},
})
mod_api.insert_text("bardin_slayer_push_on_dodge_desc", "Effective dodges push nearby enemies. Half of damage taken converts into a non-lethal bleed lasting 10 seconds. Increases healing received by 50%. ")

-- Barge bleed: pooled DoT buff like Warrior Priest Shield-of-Faith, new hits add to it and refresh duration
local TB_BARGE_BLEED_SOURCE = "life_tap"
-- wounded_dot does not interrupt interaction
local TB_BARGE_BLEED_TYPE = "wounded_dot"
local TB_BARGE_BLEED_DURATION = 10
local TB_BARGE_BLEED_RATIO = 0.5 -- share of each hit moved into the bleed

-- add_buff params don't reach reapply (the common case here), so smuggle the amount via upvalue instead
local tb_barge_pending_damage_amount = 0

mod_api.insert_buff_function("tb_barge_bleed_add_value", function (unit, buff, params)
	buff.value = (buff.value or 0) + tb_barge_pending_damage_amount
	buff.ticks_left = TB_BARGE_BLEED_DURATION
end)
mod_api.insert_buff_function("tb_barge_bleed_tick", function (unit, buff, params)
	if not Managers.state.network.is_server or not ALIVE[unit] then
		return
	end

	local ticks_left = buff.ticks_left or 0

	if ticks_left <= 0 or not buff.value or buff.value <= 0 then
		return
	end

	local damage_per_tick = buff.value / ticks_left

	buff.value = buff.value - damage_per_tick
	buff.ticks_left = ticks_left - 1

	-- Non-lethal: never tick below 1 health, excess is discarded
	local health_extension = ScriptUnit.has_extension(unit, "health_system")
	local current_health = health_extension and health_extension:current_health() or 0

	damage_per_tick = math.min(damage_per_tick, current_health - 1)

	if damage_per_tick <= 0 then
		return
	end

	DamageUtils.add_damage_network(unit, unit, damage_per_tick, "full", TB_BARGE_BLEED_TYPE, nil, Vector3(0, 0, 0), TB_BARGE_BLEED_SOURCE, nil, unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)
end)
mod_api.insert_buff_template("tb_bardin_slayer_barge_bleed", {
	icon = "bardin_slayer_crit_chance", -- twitch bleed icon
	debuff = true,
	max_stacks = 1,
	duration = TB_BARGE_BLEED_DURATION,
	update_frequency = 1,
	refresh_durations = true,
	apply_buff_func = "tb_barge_bleed_add_value",
	reapply_buff_func = "tb_barge_bleed_add_value",
	update_func = "tb_barge_bleed_tick",
})
mod_api.insert_text("tb_bardin_slayer_barge_bleed", "Bleeding")

-- Intercepts the instance before it reaches the health pool; banks it into the bleed pool
mod:hook(PlayerUnitHealthExtension, "add_damage", function (func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, ...)
	local unit = self.unit

	if self.is_server and damage_amount and damage_amount > 0 and damage_source_name ~= TB_BARGE_BLEED_SOURCE and damage_source_name ~= "temporary_health_degen" and HEALTH_ALIVE[unit] and tb_slayer_has_talent(unit, "bardin_slayer_push_on_dodge") then
		-- Added through the buff system so the owner's client also gets the buff and shows its bleed icon.
		-- It applies on the server right away (so the upvalue still reaches it), client copies only display: the tick is server only
		local buff_system = Managers.state.entity:system("buff_system")

		tb_barge_pending_damage_amount = damage_amount * TB_BARGE_BLEED_RATIO
		buff_system:add_buff(unit, "tb_bardin_slayer_barge_bleed", unit, false)
		tb_barge_pending_damage_amount = 0

		return func(self, attacker_unit, damage_amount * (1 - TB_BARGE_BLEED_RATIO), hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, ...)
	end

	return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, ...)
end)

--[[
	Oblivious to Pain
]]
-- Keeps the vanilla boss/elite damage cap, which is read server side
mod_api.update_talent("dr_slayer", 5, 1, {
	description = "bardin_slayer_damage_taken_capped_desc_2",
	description_values = {},
	buffer = "server",
	buffs = {
		"bardin_slayer_damage_taken_capped",
	},
})
-- 3% damage reduction per Trophy Hunter stack, granted with each stack (tb_slayer_trophy_hunter_buff_names).
-- Separate High Tally template since max_stacks lives on the sub-buff
mod_api.insert_talent_buff_template("dwarf_ranger", "tb_bardin_slayer_oblivious_damage_reduction", {
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	stat_buff = "damage_taken",
	multiplier = -0.03,
	max_stacks = 3,
	duration = 2,
	refresh_durations = true,
	duration_modifier_func = tb_slayer_trophy_hunter_duration,
})
mod_api.insert_talent_buff_template("dwarf_ranger", "tb_bardin_slayer_oblivious_damage_reduction_high_tally", {
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	stat_buff = "damage_taken",
	multiplier = -0.03,
	max_stacks = 5,
	duration = 2,
	refresh_durations = true,
})
mod_api.insert_text("bardin_slayer_damage_taken_capped_desc_2", "Damage taken from Bosses and Elites is reduced by half, down to a minimum of 10 damage. Each stack of Trophy Hunter reduces damage taken by 3%.")

--[[
	Dawi Drop
]]
-- Grant max Trophy Hunter stacks
mod_api.insert_text("bardin_slayer_activated_ability_leap_damage_desc", "Increases power by %g%% while airborne during Leap. Leaping grants maximum Trophy Hunter stacks.")
mod:hook_safe(CareerAbilityDRSlayer, "_do_leap", function (self)
	local do_leap = self._status_extension.do_leap

	if not do_leap then
		return
	end

	local leap_events = do_leap.leap_events
	local original_start = leap_events.start

	leap_events.start = function (this)
		if original_start then
			original_start(this)
		end

		local unit_3p = this.unit

		if not tb_slayer_has_talent(unit_3p, "bardin_slayer_activated_ability_leap_damage") then -- Dawi Drop only
			return
		end

		-- Leap events only run on the Slayer's own machine. The host adds the stacks directly,
		-- a client asks the host to add them, which syncs them back to the client
		local buff_names = tb_slayer_trophy_hunter_buff_names(unit_3p)
		local buff_system = Managers.state.network.is_server and Managers.state.entity:system("buff_system")

		for _ = 1, 5 do -- covers max_stacks 3 (base/Impatience/Adrenaline Surge) and 5 (High Tally)
			for _, buff_name in ipairs(buff_names) do
				if buff_system then
					buff_system:add_buff(unit_3p, buff_name, unit_3p, false)
				else
					mod_api.add_buff(unit_3p, buff_name)
				end
			end
		end
	end
end)

--[[
	No Escape
]]
-- While the No Escape Leap buff is up, melee and ranged weapon actions don't slow movement.
-- Carried objects (sacks, statues, torches) use the same buffs, so only the weapon slots are affected
local TB_NO_ESCAPE_MOVEMENT_PENALTY_BUFFS = {
	"planted_decrease_movement",
	"planted_fast_decrease_movement",
	"planted_charging_decrease_movement",
}
local TB_NO_ESCAPE_WEAPON_SLOTS = {
	slot_melee = true,
	slot_ranged = true,
}

local function tb_no_escape_removes_movement_penalty(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not (buff_extension and buff_extension:has_buff_type("bardin_slayer_activated_ability_movement")) then
		return false
	end

	local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")

	return not not (inventory_extension and TB_NO_ESCAPE_WEAPON_SLOTS[inventory_extension:get_wielded_slot_name()])
end

for _, buff_name in ipairs(TB_NO_ESCAPE_MOVEMENT_PENALTY_BUFFS) do
	mod:add_buff_apply_condition(buff_name, function (unit, template, params)
		return mod:is_action_movement_speed_up(params) or not tb_no_escape_removes_movement_penalty(unit)
	end)
end
mod_api.insert_text("bardin_slayer_activated_ability_movement_desc_2", "Leap increases movement speed by %g%% and removes movement slowdown from weapons for 10 seconds.")

