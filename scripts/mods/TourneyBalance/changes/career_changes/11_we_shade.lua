local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Shade
		### Career Ability
		- Lord and Boss boost_curve_multiplier_override incresed to 2 (from 1.8/1.5).
		- Reduced Infiltrate stealth duration to 3s (from 5s).

		### Passives
		**Assassin's Blade**
		- Increases movement speed by 10%. Added from Gladerunner.

		**Grim Fortune** (new, replaces Blur)
		- Increases critical strike chance by 10%.
		- Parrying an attack makes the next attack within 3s a guaranteed critical strike (melee or ranged).
		- Blur moved to the Blur talent (see Talents).

		**Murderous Prowess**
		- Charged critical backstabs only instantly slay the first 1 man-sized enemies an attack hits.

		### Talents
		**Cruelty**
		- Increased crit damage bonus to 80% (from 50%).

		**Exploit Weakness**
		- Poison, Bleed, and Burn each individually increase damage dealt by 20%. Stacks additive, up to 60% against a target suffering from all three.
		- All attacks apply bleed (WHC Flense, 3s + 3 stacks). Weapons keep their own poison, bleed or burn alongside it.

		**Chain Killer**
		- Melee headshots also grant the backstab damage bonus.
		- Charged backstabs from Khaine's Counter also grant the bonus.
		- Other attacks no longer remove the bonus.

		**Focused Slaying**
		- Only real backstabs from behind count (not Khaine's Counter or Ruthless Precision backstabs).

		**Bloodfetcher**
		- Changed ammo refund to 5% (from 1 ammo).
		- Melee headshots also refund ammo, sharing the 2s cooldown.

		**Blur** (moved from the passive, replaces Blood Drinker)
		- Parrying an attack and quickly dodging grants Kerillian stealth for a short period.
		- Increased parry window to 0.75s (from 0.5s).
		- Keeps Blood Drinker's effect: critical hits reduce damage taken by 20% for 5s.

		**Khaine's Counter** (new, replaces Spring-Heeled Assassin)
		- Parrying an attack makes all melee attacks count as backstabs for 6s within the normal 0.5s parry window, scaling down to 3s at the end of Shade's extended 0.75s window.

		**Ruthless Precision** (new, replaces Gladerunner)
		- Melee headshots count as backstabs.

		**Shimmer Strike**
		- Limited extending stealth to 4 times.
		- Increased duration granted from extending to 3s (from 1s).
		- Extending stealth reduces ultimate cooldown by 5%.

		**Hungry Wind**
		- Melee attacks are guaranteed critical strikes for the 10 seconds after leaving Infiltrate.
	$END_TB
]]

--[[

	Ultimate

]]
-- Raises the vanilla boss/elite cap on boost_damage_multiplier
-- The only source big enough to hit this cap is Shade's ult (shade_melee_boost grants 4)
-- Force-load Minotaur
if not Breeds.beastmen_minotaur then
	dofile("scripts/settings/breeds/breed_beastmen_minotaur")
end
local shade_boost_capped_breeds = {
	"chaos_exalted_sorcerer", -- 1.8
	"chaos_exalted_sorcerer_drachenfels", -- 1.8
	"chaos_spawn", -- 1.8
	"chaos_troll", -- 1.8
	"skaven_grey_seer", -- 1.8
	"skaven_rat_ogre", -- 1.8
	"skaven_storm_vermin_warlord", -- 1.8
	"skaven_stormfiend", -- 1.8
	"skaven_stormfiend_boss", -- 1.8
	"beastmen_minotaur", -- 1.5
	"chaos_exalted_champion_warcamp", -- 1.5
	"chaos_exalted_champion_norsca", -- 1.5
}
for _, breed_name in ipairs(shade_boost_capped_breeds) do
	Breeds[breed_name].boost_curve_multiplier_override = 2
end

--[[
	Infiltrate
	Shimmer Strike
	Hungry Wind
	Cloak of Pain
]]
-- Reduce ult stealth duration
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_activated_ability", {
	duration = 3 -- 5
})
-- internal
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_short_blocker", {
	duration = 3 -- 5
})
--[[
	Hungry Wind
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_phasing", {
	duration = 3 -- 5
})
--[[
	Cloak of Pain
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_restealth", {
	duration = 3 -- 5
})
mod_api.insert_text("career_active_desc_we_1_2", "Kerillian becomes undetectable, can pass through enemies, and deals greatly increased melee damage. Lasts for 3 seconds or until she deals damage.")

--[[

	Passive
]]
--[[
	Blur
]]
-- Blur moves out of the passive into talent row 5 (see Blur under Talents); its buff keeps the long parry window
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_parry", {
	event = "on_timed_block_long", -- "on_timed_block"
})
mod_api.remove_career_passives("we_1", {
	"kerillian_shade_passive_stealth_parry",
})
mod_api.remove_career_perk_description("we_1", "career_passive_name_we_1d") -- vanilla Blur perk entry

--[[
	Grim Fortune
]]
-- 10% crit chance (vanilla kerillian_shade_passive_crit at 5%, never added to the passive in vanilla)
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_passive_crit", {
	bonus = 0.1, -- 0.05
})
-- A guaranteed crit (melee or ranged) for 3 seconds after a (long) parry, used up by the next attack that hits.
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_grim_fortune_parry", {
	buff_func = "add_buff_local",
	buff_to_add = "tb_kerillian_shade_grim_fortune_crit_buff",
	event = "on_timed_block_long",
})
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_grim_fortune_crit_buff", {
	duration = 3,
	max_stacks = 1,
	refresh_durations = true,
	icon = "kerillian_shade_perk_dagger_in_the_dark",
	stat_buff = "critical_strike_chance",
	bonus = 1,
})
-- Removed on hit (same vanilla remover as the passive's kerillian_shade_stealth_crits_remover)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_grim_fortune_crit_consumer", {
	buff_func = "remove_buff_stack",
	event = "on_hit",
	remove_buff_stack_data = {
		{
			buff_to_remove = "tb_kerillian_shade_grim_fortune_crit_buff",
			num_stacks = 1,
			server_controlled = false,
		},
	},
})
mod_api.insert_career_passives("we_1", {
	"kerillian_shade_passive_crit",
	"tb_kerillian_shade_grim_fortune_parry",
	"tb_kerillian_shade_grim_fortune_crit_consumer",
})
mod_api.insert_perk_text("tb_we_1_grim_fortune", "Grim Fortune", "Increases critical strike chance by 10%. Parrying an attack grants a guaranteed critical strike lasting 3 seconds.")
mod_api.insert_career_perk_descriptions("we_1", "tb_we_1_grim_fortune")

--[[
	Gladerunner
]]
-- Gladerunner moves onto the passive, described in Assassin's Blade's passive description
mod_api.insert_career_passives("we_1", {
	"kerillian_shade_movement_speed",
})
mod_api.insert_text("career_passive_desc_we_1b_2", "Double damage when attacking enemies from behind with melee attacks. Gladerunner increases movement speed by 10%.")

--[[
	Murderous Prowess
]]
-- Vanilla instakill (kerillian_shade_passive_backstab_killing_blow), limited to the first 2 enemies each attack hits.
-- The limit is applied where the perk is read, in the calculate_damage override
-- (thp_stagger_damage_changes/01_damage_calc_changes.lua)
mod_api.insert_text("career_passive_desc_we_1a_3", "Charged critical backstabs instantly slay 1 man-sized enemy.")

--[[

	Talents

]]
--[[
	Cruelty
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_increased_critical_strike_damage", {
	multiplier = 0.8 -- 0.5
})
mod_api.update_talent("we_shade", 2, 1, {
	description = "kerillian_shade_increased_critical_strike_damage_desc",
	description_values = {},
	buffs = {
		"kerillian_shade_increased_critical_strike_damage",
	},
})
mod_api.insert_text("kerillian_shade_increased_critical_strike_damage_desc", "Increases critical strike damage bonus by 80.0%.")

--[[
	Exploit Weakness
]]
-- Marker perk so the shared damage hook (thp_stagger_damage_changes/02_damage_taken_changes.lua) can detect this talent and apply the split poison/bleed/burn bonus instead of the vanilla single poison-or-bleed bonus
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_increased_damage_on_poisoned_or_bleeding_enemy", {
	perks = {
		"kerillian_shade_increased_damage_on_poisoned_or_bleeding_enemy",
	},
})
-- Every hit applies this talent's own copy of the Flense bleed (weapon_bleed_dot_whc), alongside the weapon's own dot.
-- The talent is server-buffered in vanilla, and clients relay their hits to the server (buff_on_attack)
mod_api.insert_buff_template("tb_kerillian_shade_exploit_weakness_bleed_dot", {
	apply_buff_func = "start_dot_damage",
	damage_profile = "bleed",
	duration = 3,
	hit_zone = "neck",
	max_stacks = 3,
	refresh_durations = true,
	time_between_dot_damages = 0.75,
	update_func = "apply_dot_damage",
	update_start_delay = 0.75,
	perks = {
		"bleeding",
	},
})
local tb_exploit_weakness_dot_params = {}
mod_api.insert_proc_function("tb_shade_exploit_weakness_dots_on_hit", function (owner_unit, buff, params)
	local hit_unit = params[1]

	if not Managers.state.network.is_server or not ALIVE[owner_unit] or not HEALTH_ALIVE[hit_unit] then
		return
	end

	local hit_unit_buff_extension = ScriptUnit.has_extension(hit_unit, "buff_system")

	if not hit_unit_buff_extension then
		return
	end

	local career_extension = ScriptUnit.has_extension(owner_unit, "career_system")
	local power_level = career_extension and career_extension:get_career_power_level()
	local dots_to_add = buff.template.dots_to_add

	for i = 1, #dots_to_add do
		table.clear(tb_exploit_weakness_dot_params)

		tb_exploit_weakness_dot_params.attacker_unit = owner_unit
		tb_exploit_weakness_dot_params.power_level = power_level

		hit_unit_buff_extension:add_buff(dots_to_add[i], tb_exploit_weakness_dot_params)
	end
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_exploit_weakness_dots", {
	buff_func = "tb_shade_exploit_weakness_dots_on_hit",
	event = "on_hit",
	dots_to_add = {
		"tb_kerillian_shade_exploit_weakness_bleed_dot",
	},
})
mod_api.update_talent("we_shade", 2, 2, {
	description = "kerillian_shade_increased_damage_on_poisoned_or_bleeding_enemy_desc",
	description_values = {},
	buffs = {
		"kerillian_shade_increased_damage_on_poisoned_or_bleeding_enemy",
		"tb_kerillian_shade_exploit_weakness_dots",
	},
})
mod_api.insert_text("kerillian_shade_increased_damage_on_poisoned_or_bleeding_enemy_desc", "Increases damage by 20.0% for each type of status effect (poison, bleed, burn) afflicting the enemy. All attacks apply bleed.")

--[[
	Row 4: melee headshots also trigger Chain Killer's and Bloodfletcher's backstab effects.
	Focused Slaying only triggers on real backstabs from behind.
]]
-- Same headshot check as Ruthless Precision (01_damage_calc_changes.lua): the breed's hit zone type, which covers
-- head and neck
local function tb_shade_is_melee_headshot(breed, hit_zone_name, attack_type)
	return (attack_type == "light_attack" or attack_type == "heavy_attack") and breed and hit_zone_name and DamageUtils.get_breed_damage_multiplier_type(breed, hit_zone_name) == "headshot"
end

-- Real backstab from behind (vanilla _check_backstab angle, ignoring guaranteed_backstab)
local function tb_shade_is_behind_target(owner_unit, target_unit)
	local owner_to_target_dir = Vector3.normalize(POSITION_LOOKUP[target_unit] - POSITION_LOOKUP[owner_unit])
	local target_direction = Quaternion.forward(Unit.local_rotation(target_unit, 0))
	local hit_angle = Vector3.dot(target_direction, owner_to_target_dir)

	return hit_angle >= 0.55 and hit_angle <= 1
end

--[[
	Chain Killer
]]
-- Charged backstab (incl. Khaine's Counter) or melee headshot adds a stack; other hits no longer clear them
mod_api.insert_proc_function("tb_shade_buff_on_charged_backstab_or_headshot", function (owner_unit, buff, params)
	local hit_unit = params[1]

	if not ALIVE[owner_unit] or not ALIVE[hit_unit] then
		return
	end

	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local backstab = tb_shade_is_behind_target(owner_unit, hit_unit) or buff_extension:has_buff_perk("guaranteed_backstab")
	local headshot = tb_shade_is_melee_headshot(Unit.get_data(hit_unit, "breed"), params[3], params[2])
	local attack_type = params[2]

	if (backstab and attack_type == "heavy_attack" or headshot) and not buff_extension:has_buff_type("kerillian_shade_passive_improved_crit_blocker") then
		buff_extension:add_buff(buff.template.buff_to_add)
		buff_extension:add_buff("kerillian_shade_passive_improved_crit_blocker")
	end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_charged_backstabs", {
	buff_func = "tb_shade_buff_on_charged_backstab_or_headshot", -- "kerillian_shade_buff_on_charged_backstab"
})
mod_api.update_talent("we_shade", 4, 1, {
	description = "kerillian_shade_charged_backstabs_desc",
	description_values = {},
})
mod_api.insert_text("kerillian_shade_charged_backstabs_desc", "Successive charged backstabs and melee headshots increase backstab damage by 25% for 5 seconds. Stacks up to 2 times.")

--[[
	Focused Slaying
]]
-- Only real backstab kills from behind (not Khaine's Counter / Ruthless Precision). params: killing_blow, breed, killed_unit
mod_api.insert_proc_function("tb_shade_cooldown_regen_on_real_backstab_kill", function (owner_unit, buff, params)
	local player = Managers.player:owner(owner_unit)
	local killed_unit = params[3]

	if not player or not ALIVE[owner_unit] or not ALIVE[killed_unit] then
		return
	end

	local backstab_multiplier = params[1][DamageDataIndex.BACKSTAB_MULTIPLIER]
	local backstab = backstab_multiplier and backstab_multiplier > 1 and tb_shade_is_behind_target(owner_unit, killed_unit)

	if backstab and (player.local_player or Managers.state.network.is_server and player.bot_player) then
		ScriptUnit.extension(owner_unit, "buff_system"):add_buff(buff.template.buff_to_add)
	end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_backstabs_cooldown_regeneration", {
	buff_func = "tb_shade_cooldown_regen_on_real_backstab_kill", -- "kerillian_shade_cooldown_regen_on_backstab_kill"
})
mod_api.update_talent("we_shade", 4, 2, {
	description = "kerillian_shade_backstabs_cooldown_regeneration_desc",
	description_values = {},
})
mod_api.insert_text("kerillian_shade_backstabs_cooldown_regeneration_desc", "Killing an enemy with a direct backstab from behind increases cooldown regeneration by 100% for 3 seconds.")

--[[
	Bloodfletcher
]]
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_backstabs_replenishes_ammunition", {
	buff_func = "tb_ammo_fraction_gain_on_backstab",
	event = "on_backstab",
	ammo_bonus_fraction = 0.05,
})
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_backstabs_replenishes_ammunition_cooldown", {
	icon = "kerillian_shade_backstabs_replenishes_ammunition",
	duration = 2,
})
local function tb_shade_ammo_fraction_gain(owner_unit, buff)
	local player = Managers.player:owner(owner_unit)

	if player and player.remote then
		return
	end

	local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

	if buff_extension and not buff_extension:has_buff_type("tb_kerillian_shade_backstabs_replenishes_ammunition_cooldown") then
		if ALIVE[owner_unit] then
			local buff_template = buff.template
			local weapon_slot = "slot_ranged"
			local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
			local slot_data = inventory_extension:get_slot_data(weapon_slot)
			local right_unit_1p = slot_data.right_unit_1p
			local left_unit_1p = slot_data.left_unit_1p
			local ammo_extension = GearUtils.get_ammo_extension(right_unit_1p, left_unit_1p)
			local ammo_bonus_fraction = buff_template.ammo_bonus_fraction

			-- Only refund 5% ammo
			if ammo_extension then
				local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)
				ammo_extension:add_ammo_to_reserve(ammo_amount)
			end
		end

		buff_extension:add_buff("tb_kerillian_shade_backstabs_replenishes_ammunition_cooldown")
	end
end
mod_api.insert_proc_function("tb_ammo_fraction_gain_on_backstab", function (owner_unit, buff, params)
	tb_shade_ammo_fraction_gain(owner_unit, buff)
end)
-- Melee headshots also refund ammo, sharing the backstab refund's cooldown
mod_api.insert_proc_function("tb_ammo_fraction_gain_on_headshot", function (owner_unit, buff, params)
	local hit_unit = params[1]

	if tb_shade_is_melee_headshot(Unit.get_data(hit_unit, "breed"), params[3], params[2]) then
		tb_shade_ammo_fraction_gain(owner_unit, buff)
	end
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_headshots_replenishes_ammunition", {
	buff_func = "tb_ammo_fraction_gain_on_headshot",
	event = "on_hit",
	ammo_bonus_fraction = 0.05,
})
mod_api.update_talent("we_shade", 4, 3, {
	description = "kerillian_shade_backstabs_replenishes_ammunition_desc",
	description_values = {},
	buffs = {
		"tb_kerillian_shade_backstabs_replenishes_ammunition",
		"tb_kerillian_shade_headshots_replenishes_ammunition",
	},
})
mod_api.insert_text("kerillian_shade_backstabs_replenishes_ammunition_desc", "Backstabs and melee headshots return 5% of maximum ammunition. 2 second cooldown.")

--[[
	Blur (moved from the passive, replaces Blood Drinker)
]]
-- Vanilla Blur, applied on both sides like the vanilla passive buff, plus Blood Drinker's damage reduction on crit.
-- Blood Drinker is a server talent in vanilla, but on_critical_hit procs on both the owner and the server here, so its
-- trigger only adds the buff on the server (vanilla add_buff from the client would add it a second time via RPC)
mod_api.insert_proc_function("tb_shade_add_buff_on_server", function (owner_unit, buff, params)
	if Managers.state.network.is_server then
		ProcFunctions.add_buff(owner_unit, buff, params)
	end
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_blur_damage_reduction_on_critical_hit", {
	buff_func = "tb_shade_add_buff_on_server",
	buff_to_add = "kerillian_shade_damage_reduction_on_critical_hit_buff", -- vanilla: 20% for 5s
	event = "on_critical_hit",
})
mod_api.insert_talent("we_shade", 5, 1, "tb_kerillian_shade_blur", {
	buffer = "both",
	icon = "kerillian_shade_perk_blur",
	buffs = {
		"kerillian_shade_passive_stealth_parry",
		"tb_kerillian_shade_blur_damage_reduction_on_critical_hit",
	},
})
mod_api.insert_talent_text("tb_kerillian_shade_blur", "Blur", "Parrying an attack and quickly dodging grants Kerillian stealth for a short period. Critical hits reduce damage taken by 20% for 5 seconds.")

--[[
	Khaine's Counter (new, replaces Spring-Heeled Assassin, keeping its icon in that slot)
]]
-- Guaranteed backstabs after a parry: 6s in the 0.5s window, down to 3s at the end of the 0.75s window.
-- The parry event is owner-only; the buff is synced to the server so Chain Killer's server copy sees it.
local tb_khaines_counter_params = {}
mod_api.insert_proc_function("tb_shade_khaines_counter_on_parry", function (owner_unit, buff, params)
	if not ALIVE[owner_unit] then
		return
	end

	local template = buff.template
	local t = Managers.time:time("game")
	local status_extension = ScriptUnit.extension(owner_unit, "status_system")
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local short_window_end = status_extension.timed_block
	local long_window_end = status_extension.timed_block_long
	local short_window = short_window_end and (t < short_window_end or buff_extension:has_buff_type("power_up_deus_block_procs_parry_exotic"))
	local duration = template.short_window_duration

	if not short_window and short_window_end and long_window_end and long_window_end > short_window_end then
		local progress = math.clamp((t - short_window_end) / (long_window_end - short_window_end), 0, 1)

		duration = math.lerp(template.short_window_duration, template.long_window_duration, progress)
	end

	-- Don't cut a longer remaining buff short (refreshing applies the new duration)
	local existing_buff = buff_extension:get_buff_type(template.buff_to_add)

	if existing_buff and existing_buff.end_time and existing_buff.end_time - t >= duration then
		return
	end

	table.clear(tb_khaines_counter_params)

	tb_khaines_counter_params.external_optional_duration = duration

	Managers.state.entity:system("buff_system"):add_buff_synced(owner_unit, template.buff_to_add, BuffSyncType.LocalAndServer, tb_khaines_counter_params)
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_khaines_counter_parry", {
	buff_func = "tb_shade_khaines_counter_on_parry",
	buff_to_add = "tb_kerillian_shade_khaines_counter_backstab_buff",
	event = "on_timed_block_long",
	short_window_duration = 6, -- within the 0.5s window
	long_window_duration = 3, -- at the end of the 0.75s window
})
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_khaines_counter_backstab_buff", {
	duration = 6, -- overridden per parry by tb_kerillian_shade_khaines_counter_parry
	max_stacks = 1,
	refresh_durations = true,
	icon = "kerillian_shade_movement_speed_on_critical_hit", -- Spring-Heeled Assassin's icon marks backstabs
	perks = {
		"guaranteed_backstab",
	},
})
mod_api.insert_talent("we_shade", 5, 2, "tb_kerillian_shade_khaines_counter", {
	buffer = "client",
	icon = "kerillian_shade_movement_speed_on_critical_hit",
	buffs = {
		"tb_kerillian_shade_khaines_counter_parry",
	},
})
mod_api.insert_talent_text("tb_kerillian_shade_khaines_counter", "Khaine's Counter", "Parrying an attack makes all melee attacks count as backstabs for 6 seconds, down to 3 seconds the later the parry.")

--[[
	Ruthless Precision (new, replaces Gladerunner, which moved to the passive)
]]
-- Melee headshots count as backstabs (perk read in 01_damage_calc_changes.lua, hence buffer "both").
-- Backstab feedback for converted headshots, as in ActionSweep._check_backstab (on_backstab plays Shade's backstab sound)
mod:hook(ActionSweep, "_play_character_impact", function (func, self, is_server, attacker_unit, hit_unit, breed, hit_position, hit_zone_name, current_action, damage_profile, target_index, power_level, attack_direction, blocking, boost_curve_multiplier, is_critical_strike, backstab_multiplier, ...)
	if not blocking and (not backstab_multiplier or backstab_multiplier <= 1) and damage_profile and HEALTH_ALIVE[hit_unit]
		and tb_shade_is_melee_headshot(breed, hit_zone_name, damage_profile.charge_value) then
		local buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

		if buff_extension and buff_extension:has_buff_perk("tb_headshot_counts_as_backstab") and buff_extension:apply_buffs_to_value(1, "backstab_multiplier") > 1 then
			local first_person_extension = ScriptUnit.has_extension(attacker_unit, "first_person_system")

			if first_person_extension then
				first_person_extension:play_hud_sound_event("hud_player_buff_backstab")
			end

			local side = Managers.state.side.side_by_unit[attacker_unit]
			local player_and_bot_units = side and side.PLAYER_AND_BOT_UNITS

			if player_and_bot_units then
				for i = 1, #player_and_bot_units do
					local friendly_buff_extension = ScriptUnit.has_extension(player_and_bot_units[i], "buff_system")

					if friendly_buff_extension then
						friendly_buff_extension:trigger_procs("on_backstab", hit_unit)
					end
				end
			end
		end
	end

	return func(self, is_server, attacker_unit, hit_unit, breed, hit_position, hit_zone_name, current_action, damage_profile, target_index, power_level, attack_direction, blocking, boost_curve_multiplier, is_critical_strike, backstab_multiplier, ...)
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_ruthless_precision_headshot_backstab", {
	perks = {
		"tb_headshot_counts_as_backstab",
	},
})
mod_api.insert_talent("we_shade", 5, 3, "tb_kerillian_shade_ruthless_precision", {
	buffer = "both",
	icon = "kerillian_shade_movement_speed", -- reuse Gladerunner's old icon, since this replaces it in this slot
	buffs = {
		"tb_kerillian_shade_ruthless_precision_headshot_backstab",
	},
})
mod_api.insert_talent_text("tb_kerillian_shade_ruthless_precision", "Ruthless Precision", "Melee headshots count as backstabs.")

--[[
	Shimmer Strike
]]
-- protects from proccing multiple times per swing
mod_api.insert_talent_buff_template("wood_elf", "tb_shimmer_abuser", {
	duration = 0.1,
	max_stacks = 1
})
-- removes a shimmer charge when you kill an elite/special
mod_api.insert_talent_buff_template("wood_elf", "tb_shimmer_handler", {
	buff_func = "tb_shimmer_control",
	buff_to_remove = "tb_shimmer_charges",
	event = "on_kill_elite_special",
	max_stacks = 1
})
mod_api.insert_talent_buff_template("wood_elf", "tb_shimmer_activator", {
	buff_func = "add_buff_reff_buff_stack",
	buff_to_add = "tb_shimmer_charges",
	event = "on_ability_activated",
	max_stacks = 1,
	amount_to_add = 4, -- gives 4 shimmer uses when you ult
})
-- controls how many shimmer uses you have left
mod_api.insert_talent_buff_template("wood_elf", "tb_shimmer_charges", {
	max_stacks = 4, -- maximum shimmer uses at once
	icon = "kerillian_shade_passive_stealth_on_backstab_kill"
})
mod_api.insert_talent_buff_template("wood_elf", "kerillian_shade_ult_invis_combo_window", {
	buff_func = "shade_combo_stealth_extend_on_kill",
	duration = 0.3,
	refresh_durations = true,
	event = "on_kill_elite_special",
	extend_time = 3, -- 1
	max_stacks = 1,
	icon = "kerillian_shade_passive_stealth_on_backstab_kill",
	remove_buff_func = "kerillian_shade_missed_combo_window"
})
-- Fix: clear leftover shimmer charges once the stealth extension ends, so they can't be
-- silently spent on an unrelated kill outside of Infiltrate
local tb_shimmer_vanilla_on_shade_activated_ability_remove = BuffFunctionTemplates.functions.on_shade_activated_ability_remove
mod_api.insert_buff_function("tb_shade_ult_invis_remove", function (unit, buff, params, world)
	tb_shimmer_vanilla_on_shade_activated_ability_remove(unit, buff, params, world)

	if ALIVE[unit] then
		local buff_extension = ScriptUnit.extension(unit, "buff_system")
		local shimmer_charges = buff_extension:get_stacking_buff("tb_shimmer_charges")

		if shimmer_charges then
			for i = #shimmer_charges, 1, -1 do
				buff_extension:remove_buff(shimmer_charges[i].id)
			end
		end
	end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_ult_invis", {
	remove_buff_func = "tb_shade_ult_invis_remove",
})
mod_api.insert_proc_function("shade_combo_stealth_on_hit", function (owner_unit, buff, params)
	if ALIVE[owner_unit] then
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		
		if not buff_extension:has_buff_type("kerillian_shade_ult_invis_combo_blocker") then
			if buff_extension:num_buff_stacks("tb_shimmer_charges") > 0 then -- only gives shimmer buff if you have charges
				buff_extension:add_buff("kerillian_shade_ult_invis_combo_window")
			end
			if buff_extension:num_buff_stacks("tb_shimmer_charges") <= 0 then -- always removes invis if you have no charges and hit an enemy
				buff_extension:remove_buff(buff.id)
			end
		end
	end
end)
mod_api.insert_proc_function("tb_shimmer_control", function (owner_unit, buff, params)
	if ALIVE[owner_unit] then
		local buff_template = buff.template
		local buff_name = buff_template.buff_to_remove
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		local buffs = buff_extension:get_stacking_buff(buff_name)
		
		if buffs then
			local num_stacks = #buffs
			
			if not buff_extension:has_buff_type("tb_shimmer_abuser") then
				if num_stacks > 0 then
					local buff_id = buffs[num_stacks].id

					buff_extension:remove_buff(buff_id)
					buff_extension:add_buff("tb_shimmer_abuser")

					-- Refund 5% of the ultimate's cooldown for each shimmer consumed
					local career_extension = ScriptUnit.extension(owner_unit, "career_system")

					career_extension:reduce_activated_ability_cooldown_percent(0.05)
				end
			end
		end
	end
end)
mod_api.update_talent("we_shade", 6, 1, {
	description = "kerillian_shade_activated_stealth_combo_desc",
	description_values = {},
	buffs = {
		"tb_shimmer_activator", -- adds necessary buffs to shimmer talent to handle having capped uses
		"tb_shimmer_handler"
	}
})
mod_api.insert_text("kerillian_shade_activated_stealth_combo_desc", "Leaving Infiltrate grants stealth for 3 seconds. Killing an Elite or Special extends this duration by 3 seconds and refunds 5.0% of the ultimate's cooldown, up to a maximum of 4 times.")

--[[
	Hungry Wind
]]
-- Reduce the post-Infiltrate movement speed/Power/pass-through window
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_phasing_buff", {
	duration = 10,
})
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_movespeed_buff", {
	duration = 10,
})
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_power_buff", {
	duration = 10,
	apply_buff_func = "tb_hungry_wind_add_crit_buff",
	reapply_buff_func = "tb_hungry_wind_add_crit_buff", -- re-ulting while the window is active refreshes the power buff
})
-- Guaranteed melee crits for the Hungry Wind window (same approach as WHC's Fervency:
-- victor_witchhunter_activated_ability_guaranteed_crit_self_buff). Only Hungry Wind adds kerillian_shade_power_buff,
-- from vanilla on_shade_activated_ability_remove, which only runs on the owning peer
mod_api.insert_talent_buff_template("wood_elf", "tb_hungry_wind_crit_buff", {
	duration = 10, -- keep in sync with kerillian_shade_power_buff
	max_stacks = 1,
	refresh_durations = true,
	icon = "kerillian_shade_perk_dagger_in_the_dark", -- same crit icon as Grim Fortune
	stat_buff = "critical_strike_chance_melee",
	bonus = 1,
})
mod_api.insert_buff_function("tb_hungry_wind_add_crit_buff", function (unit, buff, params, world)
	if ALIVE[unit] then
		ScriptUnit.extension(unit, "buff_system"):add_buff("tb_hungry_wind_crit_buff")
	end
end)
mod_api.update_talent("we_shade", 6, 2, {
	description = "kerillian_shade_activated_ability_phasing_desc",
	description_values = {},
})
mod_api.insert_text("kerillian_shade_activated_ability_phasing_desc", "Leaving Infiltrate grants Kerillian 10% movement speed, 15% Power, guaranteed melee critical strikes and the ability to pass through enemies for 10 seconds. Infiltrate no longer grants bonus damage.")
