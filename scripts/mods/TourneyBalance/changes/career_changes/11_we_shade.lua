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
		**Grim Fortune** (added to the passive description next to Assassin's Blade)
		- Increases critical strike chance by 10%.

		**Blur**
		- Parrying (within Shade's 0.75s parry window) also makes the next hit a guaranteed critical backstab (1 stack, used up on hit).
		- Entering stealth (Infiltrate or Blur) removes it.

		**Murderous Prowess**
		- Charged critical backstabs no longer always instantly slay man-sized enemies.
		- Instead, parrying an attack (within Shade's 0.75s parry window) grants a charge (Blur icon): the next charged critical backstab instantly slays one man-sized enemy, using up the charge.

		### Talents
		**Cruelty**
		- Increased crit damage bonus to 80% (from 50%).

		**Exploit Weakness**
		- Poison, Bleed, and Burn each individually increase damage dealt by 20%. Stacks additive, up to 60% against a target suffering from all three.
		- All attacks apply bleed (WHC Flense, 3s + 3 stacks). Weapons keep their own poison, bleed or burn alongside it.

		**Chain Killer**
		- Melee headshots also grant the backstab damage bonus.
		- Each stack also increases headshot damage by 25%.
		- Other attacks no longer remove the bonus.

		**Bloodfetcher**
		- Changed ammo refund to 5% (from 1 ammo).
		- Melee headshots also refund ammo, sharing the 2s cooldown.

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
	Shared helpers
]]
-- Melee headshot by the breed's hit zone type, which covers head and neck
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

	Passive

]]
--[[
	Grim Fortune
]]
-- Vanilla kerillian_shade_passive_crit, never added to the passive in vanilla
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_passive_crit", {
	bonus = 0.1, -- 0.05
})
mod_api.insert_career_passives("we_1", {
	"kerillian_shade_passive_crit",
})
mod_api.insert_text("career_passive_desc_we_1b_2", "Double damage when attacking enemies from behind with melee attacks. Grim Fortune increases critical strike chance by 10%.")

--[[
	Blur
]]
-- A (long, 0.75s window) parry grants a guaranteed backstab and a guaranteed critical strike (vanilla
-- guaranteed_backstab perk, Blur's icon), for the next unstealthed hit. Used up by that hit (remove_on_proc).
-- It's never granted while invisible, and entering stealth (Blur or Infiltrate) removes it right away through
-- on_invisible, the same way vanilla's kerillian_shade_stealth_crits_remover reacts to on_visible.
-- on_timed_block_long and on_invisible both fire on the owning client, which is where backstabs and crits are decided
local PARRY_BACKSTAB_BUFF = "tb_kerillian_shade_parry_backstab"

mod_api.insert_talent_buff_template("wood_elf", PARRY_BACKSTAB_BUFF, {
	icon = "kerillian_shade_perk_blur",
	max_stacks = 1,
	event = "on_hit",
	remove_on_proc = true,
	stat_buff = "critical_strike_chance",
	bonus = 1,
	perks = {
		"guaranteed_backstab",
	},
})
mod_api.insert_proc_function("tb_shade_parry_backstab_on_parry", function (owner_unit, buff, params)
	local status_extension = ScriptUnit.has_extension(owner_unit, "status_system")

	if ALIVE[owner_unit] and status_extension and not status_extension:is_invisible() then
		ScriptUnit.extension(owner_unit, "buff_system"):add_buff(buff.template.buff_to_add)
	end
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_parry_backstab_passive", {
	buff_func = "tb_shade_parry_backstab_on_parry",
	buff_to_add = PARRY_BACKSTAB_BUFF,
	event = "on_timed_block_long",
})
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_parry_backstab_stealth_remover", {
	buff_func = "remove_buff_stack",
	event = "on_invisible",
	remove_buff_stack_data = {
		{
			buff_to_remove = PARRY_BACKSTAB_BUFF,
			num_stacks = 1,
			server_controlled = false,
		},
	},
})
mod_api.insert_career_passives("we_1", {
	"tb_kerillian_shade_parry_backstab_passive",
	"tb_kerillian_shade_parry_backstab_stealth_remover",
})
mod_api.insert_text("career_passive_desc_we_1d", "Parrying an attack and quickly dodging grants Kerillian stealth for a short period. Parrying also makes her next unstealthed hit a guaranteed critical backstab.")

--[[
	Murderous Prowess
]]
-- The charged critical backstab instakill is no longer permanent: parrying grants a one-use charge (Blur's icon)
-- carrying the vanilla perk. The first instakill spends it, so it only ever slays one enemy. It lasts until used,
-- one at a time.
-- Parries are only detected on the owning client, but the perk is read on the server (calculate_damage override,
-- thp_stagger_damage_changes/01_damage_calc_changes.lua), so the charge is a synced buff (BuffSyncType.All): added on
-- the owner, synced to the server and relayed to everyone. server_apply_hit spends it on the server through
-- tb_consume_murderous_prowess_charge, and that removal is synced back to every peer
local MURDEROUS_PROWESS_CHARGE_BUFF = "tb_kerillian_shade_murderous_prowess_charge"

mod_api.remove_career_passives("we_1", {
	"kerillian_shade_passive_backstab_killing_blow",
})
mod_api.insert_talent_buff_template("wood_elf", MURDEROUS_PROWESS_CHARGE_BUFF, {
	icon = "kerillian_shade_perk_blur",
	max_stacks = 1,
	perks = {
		"crit_backstab_killing_blow",
	},
})
mod_api.insert_proc_function("tb_shade_murderous_prowess_charge_on_parry", function (owner_unit, buff, params)
	local player = Managers.player:owner(owner_unit)

	if not ALIVE[owner_unit] or not player or player.remote then
		return
	end

	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

	if not buff_extension:has_buff_type(buff.template.buff_to_add) then
		Managers.state.entity:system("buff_system"):add_buff_synced(owner_unit, buff.template.buff_to_add, BuffSyncType.All)
	end
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_murderous_prowess_parry", {
	buff_func = "tb_shade_murderous_prowess_charge_on_parry",
	buff_to_add = MURDEROUS_PROWESS_CHARGE_BUFF,
	event = "on_timed_block_long", -- same long parry window as Blur's guaranteed backstab
})
mod_api.insert_career_passives("we_1", {
	"tb_kerillian_shade_murderous_prowess_parry",
})

function mod.tb_consume_murderous_prowess_charge(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local charge = buff_extension and buff_extension:get_buff_type(MURDEROUS_PROWESS_CHARGE_BUFF)

	if charge then
		buff_extension:remove_buff(charge.id)
	end
end
-- Vanilla perk order: Dagger in the Dark (we_1a_2), Blur (we_1d), Murderous Prowess (we_1a_3)
mod_api.insert_text("career_passive_desc_we_1a_3", "Parrying an attack grants Murderous Prowess: the next charged critical backstab instantly slays a man-sized enemy.")

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
]]
--[[
	Chain Killer
]]
-- Charged backstab (incl. guaranteed backstabs) or melee headshot adds a stack; other hits no longer clear them
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
		buff_extension:add_buff("tb_kerillian_shade_charged_backstabs_headshot_buff")
		buff_extension:add_buff("kerillian_shade_passive_improved_crit_blocker")
	end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_shade_charged_backstabs", {
	buff_func = "tb_shade_buff_on_charged_backstab_or_headshot", -- "kerillian_shade_buff_on_charged_backstab"
})
-- Headshot damage copy of the stack buff (scales the headshot bonus), added alongside it. No icon: the vanilla one shows
local CHAIN_KILLER_HEADSHOT_MULTIPLIER = 0.25
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_shade_charged_backstabs_headshot_buff", {
	stat_buff = "headshot_multiplier",
	multiplier = CHAIN_KILLER_HEADSHOT_MULTIPLIER,
	duration = 5,
	max_stacks = 2,
	refresh_durations = true,
})
mod_api.update_talent("we_shade", 4, 1, {
	description = "kerillian_shade_charged_backstabs_desc",
	description_values = {},
})
mod_api.insert_text("kerillian_shade_charged_backstabs_desc", string.format("Successive charged backstabs and melee headshots increase backstab damage by 25%% and headshot damage by %d%% for 5 seconds. Stacks up to 2 times.", CHAIN_KILLER_HEADSHOT_MULTIPLIER * 100))

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
	icon = "kerillian_shade_perk_dagger_in_the_dark",
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
