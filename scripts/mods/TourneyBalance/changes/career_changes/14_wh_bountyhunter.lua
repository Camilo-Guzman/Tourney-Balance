local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local is_local = require("scripts/mods/TourneyBalance/_api/shared_utils").is_local

--[[
	$BEGIN_TB
		---
		## Bounty Hunter
		### Passives
		**Blessed Kill (NEW)**
		- Melee Kills reset the cooldown of Blessed Shots (moved from Blessed Combat).
		- Melee kills reload 1 ammo into Victor's ranged weapon (moved from Salvaged Ammunition).

		### Talents
		**Steel Crescendo**
		- Corrected talent description to melee power (from power).

		**Blessed Combat**
		- Added ranged hits also grant 15% more attack speed for the next 6 attacks.
		- Removed the melee-kill reset Blessed Shots (moved to Blessed Kill passive).

		**Weight of Fire**
		- Increased ranged power per clip stack to 3% (from 1%).

		**Cruel Fortune**
		- Added a separate guaranteed critical hit (melee or ranged, 6s cooldown) on top of Blessed Shots.

		**Salvaged Ammunition**
		- Increased ammo restored to 25% of max ammo (from 20%).
		- Now triggers at or below 10% ammo remaining (from requiring fully empty).
		- Added effect to also trigger on special kills.
		- Blessed Kills reload 25% of the ranged weapon's clip size.

		**Rile the Mob**
		- Added effect to also grant the team 10% attack speed for 10s.

		**Job Well Done**
		- Decreased max damage reductions stacks to 20 (from 30).

		**Just Reward**
		- Decreased trigger time window to 4s (from 10s).

		**Double Shotted**
		- Increased cooldown reduction to 80% (from 60%).

		**Indiscriminate Blast**
		- Increased cooldown reduction to 60% (from 25%).
	$END_TB
]]

--[[

	Passives

]]
mod_api.insert_career_passives("wh_2", { "victor_bountyhunter_activate_passive_on_melee_kill" })
-- moved from Salvaged Ammunition: melee kills reload 1 ammo into the ranged weapon
mod_api.insert_talent_buff_template("witch_hunter", "tb_wh2_blessed_kill_reload_ammo", {
	buff_func = "victor_bounty_hunter_reload_on_kill",
	event = "on_kill",
})
mod_api.insert_career_passives("wh_2", { "tb_wh2_blessed_kill_reload_ammo" })
mod_api.insert_perk_text("tb_wh_2d", "Blessed Kill", "Melee kills reset the cooldown of Blessed Shots and reload 1 ammo into Victor's ranged weapon.")
mod_api.insert_career_perk_descriptions("wh_2", "tb_wh_2d")

--[[

	Talents

]]

--[[
	Steel Crescendo
]]
mod_api.update_talent("wh_bountyhunter", 2, 2, {
	description_values = { },
})
mod_api.insert_text("victor_bountyhunter_power_burst_on_no_ammo_desc_2", "When his ranged weapon is empty, Victor gains 15% Melee Power and 15% Attack Speed for 10 seconds.")


--[[
	Weight of Fire
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_power_level_on_clip_size_buff", {
	multiplier = 0.03, -- 0.01
})
mod_api.update_talent("wh_bountyhunter", 2, 3, {
	description_values = {
		{
			value_type = "percent",
			value = 0.03, --buff_tweak_data.victor_bountyhunter_power_level_on_clip_size_buff.multiplier,
		},
	},
})

--[[
	Blessed Combat
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_activate_passive_on_melee_kill", {
	activation_buff = "victor_bountyhunter_blessed_melee_damage_buff",
	buff_to_add = "victor_bountyhunter_blessed_melee_attack_speed_buff",
	update_func = "activate_buff_on_other_buff",
})
mod_api.insert_talent_buff_template("witch_hunter", "victor_bountyhunter_blessed_melee_attack_speed_buff", {
	stat_buff = "attack_speed",
	multiplier = 0.15,
	max_stacks = 1,
})
mod_api.insert_text("victor_bountyhunter_weapon_swap_buff_desc", "Melee strikes make up to the next 6 ranged shots deal 15%% more damage. Ranged hits make up to the next 6 melee strikes deal 15%% more damage and grants 15%% attack speed for the next 6 strikes.")

--[[
	Cruel Fortune
]]
-- A fully separate guaranteed crit, independent of Blessed Shots
mod_api.insert_talent_buff_template("witch_hunter", "tb_wh2_cruel_fortune_crit_buff", {
	bonus = 1,
	icon = "victor_bountyhunter_passive_reduced_cooldown",
	max_stacks = 1,
	stat_buff = "critical_strike_chance",
})
mod_api.insert_proc_function("tb_wh2_cruel_fortune_remove_crit_buff", function (owner_unit, buff, params)
	if not ALIVE[owner_unit] then
		return
	end

	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local crit_buff = buff_extension:get_non_stacking_buff("tb_wh2_cruel_fortune_crit_buff")

	if crit_buff then
		buff_extension:remove_buff(crit_buff.id)
		buff_extension:add_buff("tb_wh2_cruel_fortune_cooldown_buff")
	end
end)
mod_api.insert_talent_buff_template("witch_hunter", "tb_wh2_cruel_fortune_crit_buff_removal", {
	buff_func = "tb_wh2_cruel_fortune_remove_crit_buff",
	event = "on_critical_action",
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_wh2_cruel_fortune_cooldown_buff", {
	buff_to_add = "tb_wh2_cruel_fortune_crit_buff",
	duration = 6,
	duration_end_func = "add_buff_local",
	icon = "victor_bountyhunter_passive_reduced_cooldown",
	is_cooldown = true,
	max_stacks = 1,
	refresh_durations = true,
})
mod_api.update_talent("wh_bountyhunter", 4, 2, {
	buffs = {
		"tb_wh2_cruel_fortune_crit_buff",
		"tb_wh2_cruel_fortune_crit_buff_removal",
	},
})
mod_api.insert_text("victor_bountyhunter_passive_reduced_cooldown_desc", "Reduces the cooldown of Blessed Shots to 6 seconds. Gain a separate guaranteed critical strike every 6 seconds.")

--[[
	Salvaged Ammunition
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_restore_ammo_on_elite_kill", {
	ammo_bonus_fraction = 0.25, -- 0.2
})
-- melee-kill reload moved to the Blessed Kill passive
mod_api.update_talent("wh_bountyhunter", 5, 2, {
	buffs = {
		"victor_bountyhunter_restore_ammo_on_elite_kill",
		"tb_victor_bounty_hunter_reload_on_kill",
	},
})
mod_api.insert_text("victor_bountyhunter_reload_on_kill_desc", "Killing an elite or special while below 10%% ammunition restores 25.0%% of max ammo. Blessed Kills now reloads 25%% of the ranged weapon's clip size from reserve ammo.")
-- trigger threshold also from specials
local function get_ranged_ammo_extension(inventory_extension)
	local slot_data = inventory_extension:get_slot_data("slot_ranged")
	local right_unit_1p = slot_data.right_unit_1p
	local left_unit_1p = slot_data.left_unit_1p

	return ScriptUnit.has_extension(right_unit_1p, "ammo_system") or ScriptUnit.has_extension(left_unit_1p, "ammo_system")
end
mod_api.insert_proc_function("victor_bounty_hunter_ammo_fraction_gain_out_of_ammo", function (owner_unit, buff, params)
	if not is_local(owner_unit) then
		return
	end

	if ALIVE[owner_unit] then
		local killed_unit_breed_data = params[2]

		if killed_unit_breed_data.elite or killed_unit_breed_data.special then
			local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
			local ammo_extension = get_ranged_ammo_extension(inventory_extension)
			local max_ammo = ammo_extension:max_ammo()

			if ammo_extension:remaining_ammo() + ammo_extension:ammo_count() <= max_ammo * 0.1 then
				local ammo_bonus_fraction = buff.template.ammo_bonus_fraction
				local ammo_amount = math.max(math.round(max_ammo * ammo_bonus_fraction), 1)

				ammo_extension:add_ammo_to_reserve(ammo_amount)
			end
		end
	end
end)
-- melee kills also reload 25% of the ranged weapon's clip size from reserve ammo
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_bounty_hunter_reload_on_kill", {
	ammo_bonus_fraction = 0.25,
	buff_func = "tb_victor_bounty_hunter_reload_on_kill",
	event = "on_kill",
})
mod_api.insert_proc_function("tb_victor_bounty_hunter_reload_on_kill", function (owner_unit, buff, params)
	if not is_local(owner_unit) then
		return
	end

	if not ALIVE[owner_unit] then
		return
	end

	local killing_blow = params[1]
	local damage_source_name = killing_blow[DamageDataIndex.DAMAGE_SOURCE_NAME]
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local melee_slot_data = inventory_extension:get_slot_data("slot_melee")

	if not melee_slot_data or damage_source_name ~= melee_slot_data.item_data.name then
		return
	end

	local ammo_extension = get_ranged_ammo_extension(inventory_extension)

	if ammo_extension:clip_full() then
		return
	end

	local reserve_ammo = ammo_extension:remaining_ammo()

	if reserve_ammo < 1 then
		return
	end

	local clip_size = ammo_extension:clip_size()
	local clip_current_ammo = ammo_extension:ammo_count()
	local ammo_bonus_fraction = buff.template.ammo_bonus_fraction
	-- Blessed Kill already restores 1 ammo per melee kill; total restored 20% so -1
	local ammo_amount = math.max(math.round(clip_size * ammo_bonus_fraction) - 1, 0)

	-- clamp to the clip's remaining space
	ammo_amount = math.min(ammo_amount, clip_size - clip_current_ammo, reserve_ammo)

	ammo_extension._ammo_immediately_available = true

	ammo_extension:add_ammo(ammo_amount)

	ammo_extension._ammo_immediately_available = false

	ammo_extension:remove_ammo(ammo_amount)
end)

--[[
	Rile the Mob
]]
-- Ranged crits grant attack speed to Victor and all allies within 40m (same team proc as the vanilla movespeed buff).
mod_api.insert_talent_buff_template("witch_hunter", "tb_wh2_rile_the_mob_attack_speed_buff", {
	stat_buff = "attack_speed",
	multiplier = 0.1,
	duration = 10,
	max_stacks = 1,
	refresh_durations = true,
	-- icon = "victor_bountyhunter_movespeed_on_ranged_crit",
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_wh2_rile_the_mob_attack_speed", {
	buff_func = "add_team_buff_on_ranged_critical_hit",
	buff_to_add = "tb_wh2_rile_the_mob_attack_speed_buff",
	event = "on_hit",
})
mod_api.update_talent("wh_bountyhunter", 5, 1, {
	buffs = {
		"victor_bountyhunter_party_movespeed_on_ranged_crit",
		"tb_wh2_rile_the_mob_attack_speed",
	},
})
mod_api.insert_text("victor_bountyhunter_party_movespeed_on_ranged_crit_desc", "Ranged critical hits grant Victor and his allies 10%% increased movement speed and 10%% increased attack speed for 10s.")

--[[
	Job Well Done
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_stacking_damage_reduction_on_elite_or_special_kill_buff", {
	max_stacks = 20 -- 30
})
mod_api.update_talent("wh_bountyhunter", 5, 3, {
    description_values = {
		{
			value_type = "percent",
			value = -0.01
		},
		{
			value = 20 -- 30
		}
	},
})

--[[
	Just Reward
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_passive_cooldown_reduction", {
    cooldown = 4, -- 10
    multiplier = 0.2,
})
mod_api.update_talent("wh_bountyhunter", 6, 1, {
    description_values = {
	},
})
mod_api.insert_text("victor_bountyhunter_activated_ability_reset_cooldown_on_stacks_2_desc", "Ranged critical hits reduces the cooldown of Locked and Loaded by 20%. Can only trigger once every 4 seconds.")

--[[
	Double-Shotted
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_railgun_delayed_add", {
    max_stacks = 1,
    multiplier = 0.8, -- 0.6
})
mod_api.insert_text("victor_bountyhunter_activated_ability_railgun_desc_2", "Modifies Victor's sidearm to fire two powerful bullets in a straight line. Scoring a headshot with this attack will reduce the cooldown of Locked and Loaded by 80%%. This can only happen once")


--[[
	Indisctiminate blast cdr upped to 60%
]]
mod_api.update_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun", {
    multiplier = -0.6, -- -0.25
})
mod_api.update_talent("wh_bountyhunter", 6, 3, {
	description_values = {
		{
			value_type = "percent",
			value = 0.6, -- 0.25
		},
		{
			value = 20,
		},
	},
})

