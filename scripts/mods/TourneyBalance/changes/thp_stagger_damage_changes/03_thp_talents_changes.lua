local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	$BEGIN_TB
		---
		## THP Talents
		### Careers
		- No changes

		### Talents
		**Execute**
		- Decreased THP from chaos elite kills to 10 (from 15).
		- Decreased THP from chaos warrior kills to 20 (from 30).
		- Decreased THP from monster kills to 35 from (from 50).

		**Reaper**
		- Updated description: Max 5 enemies per swing.

		**Sting**
		- Removed THP on hit (from 0.5).
		- Decreased THP on crit to 1.5 (from 2).
		- Increased THP on headshot to 3 (from 2).

		**Second Wind**
		- Reduced stagger THP for pushes.
		- Reduced stagger THP for shield bashes.
		- Reduced stagger THP for Billhook.
		- Reduced stagger THP for Ensorcelled Reaper.

	$END_TB
]]
--[[
	THP on Kill - Bloodlust
]]
mod_api.insert_buff_template("tb_bloodlust", {
	multiplier = 0.2,
	name = "bloodlust",
	event_buff = true,
	buff_func = "heal_percentage_of_enemy_hp_on_melee_kill",
	event = "on_kill",
	perks = { buff_perks.smiter_healing },
})

--[[
	Reaper - THP on Cleave
]]
mod_api.insert_buff_template("tb_reaper", {
	multiplier = -0.05,
	name = "reaper",
	event_buff = true,
	buff_func = "heal_damage_targets_on_melee",
	event = "on_player_damage_dealt",
	perks = { buff_perks.linesman_healing },
	max_targets = 5,
	bonus = 0.25
})

--[[
	Regrowth - THP on Crit
]]
mod_api.insert_proc_function("tb_heal_finesse_damage_on_melee", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local heal_amount_crit = 1.5
	local heal_amount_hs = 3
	local has_procced = buff.has_procced
	local hit_unit = params[1]
	local hit_zone_name = params[3]
	local target_number = params[4]
	local attack_type = params[2]
	local critical_hit = params[6]
	local breed = AiUtils.unit_breed(hit_unit)
	if target_number == 1 then
		buff.has_procced = false
		has_procced = false
	end
	if ALIVE[owner_unit] and breed and (attack_type == "light_attack" or attack_type == "heavy_attack") and not has_procced then
		if hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot" then
			buff.has_procced = true

			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount_hs, "heal_from_proc")
		end

		if critical_hit then
			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount_crit, "heal_from_proc")

			buff.has_procced = true
		end
	end
end)

mod_api.insert_buff_template("tb_regrowth", {
	name = "regrowth",
	event_buff = true,
	buff_func = "tb_heal_finesse_damage_on_melee",
	event = "on_hit",
	perks = { buff_perks.ninja_healing },
})

--[[
	Vanguard - THP on Stagger
]]
mod_api.insert_proc_function("tb_heal_stagger_targets_on_melee", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	if ALIVE[owner_unit] then
		local hit_unit = params[1]
		local damage_profile = params[2]
		local attack_type = damage_profile.charge_value
		local stagger_value = params[6]
		local stagger_type = params[4]
		local target_index = params[8]
		local breed = AiUtils.unit_breed(hit_unit)
		local multiplier = buff.multiplier
		local is_push = damage_profile.is_push
		local is_discharge = damage_profile.is_discharge
		local stagger_calulation = stagger_type or stagger_value
		local heal_amount = stagger_calulation * multiplier
		local death_extension = ScriptUnit.has_extension(hit_unit, "death_system")
		local is_corpse = death_extension.death_is_done == false --???
		local is_shield_slam = nil

		if damage_profile.default_target.attack_template and damage_profile.default_target.attack_template == "heavy_blunt_fencer" then
			is_shield_slam = true
		end

		if is_push then
			heal_amount = 0.6
		end

		local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
      	local equipment = inventory_extension:equipment()
		local slot_data = equipment.slots.slot_melee

		if slot_data then
			local item_data = slot_data.item_data
			local weapon_template = item_data.template
			local item_name = item_data.name
			local damage_profile_aoe = Weapons[weapon_template].actions.action_one[attack_type] and Weapons[weapon_template].actions.action_one[attack_type].damage_profile_aoe or nil

			if item_name == "wh_2h_billhook" and heal_amount == 9 then -- Excuse me what are we gating here???
				heal_amount = 2
			end
			if item_name == "bw_ghost_scythe" and is_discharge and not is_push and heal_amount > 0 then
				heal_amount = 0.25	-- Change this number to adjust thp gain per target
			end
            if 	(item_name == "dr_shield_axe" or "dr_shield_hammer" or "es_mace_shield" or "es_sword_shield" or "wh_hammer_shield")
			 	and attack_type == "heavy_attack"
				and is_shield_slam
				and heal_amount > 0 then
					if damage_profile_aoe then
                		heal_amount = 0.75 -- nerf shield thp gain
					end
            end
    	end
		--- TODO: stagger thp from corpses?
		-- Stagger THP only procs on: the first 4 cleave targets on light/heavy melee attacks/pushes/bashes
		-- `is_corpse` (death_is_done == false) is true for units that are alive or still
		-- mid-death-reaction, not for units whose death reaction has finished, so this does
		-- NOT currently exclude settled corpses from proccing stagger THP.
		if target_index and target_index < 5 and breed and not breed.is_hero and (attack_type == "light_attack" or attack_type == "heavy_attack" or attack_type == "action_push") and not is_corpse then
			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
		end
	end
end)
mod_api.insert_buff_template("tb_vanguard", {
	multiplier = 1,
	name = "vanguard",
	event_buff = true,
	buff_func = "tb_heal_stagger_targets_on_melee",
	event = "on_stagger",
	perks = { buff_perks.tank_healing }
})

--[[

	Text Localization

]]
mod_api.insert_text("bloodlust_name", "Execute")
mod_api.insert_text("reaper_name", 	"Carve")
mod_api.insert_text("regrowth_name", 	"Sting")
mod_api.insert_text("vanguard_name", 	"Second Wind")
mod_api.insert_text("tb_bloodlust_desc",	"Killing an enemy with a Melee Attack grants Temporary Health based on the health of the slain enemy.")
mod_api.insert_text("tb_reaper_desc", 		"Damaging multiple enemies in one Melee Attack grants Temporary Health. Max 5 enemies.")
mod_api.insert_text("tb_regrowth_desc", 	"Melee Critical Strikes grant 1.5 Temporary Health. Melee Headshots grant 3 Temporary Health. Melee Critical Headshots grant 4.5 Temporary Health.")
mod_api.insert_text("tb_vanguard_desc", 	"Staggering enemies with a Melee Attack grants Temprorary Health based on the Stagger Strength.")

-- Replacing THP Talents
local VANGUARD = 1
local REAPER = 2
local BLOODLUST = 3
local REGROWTH = 4
local THP_TALENT_OPTIONS = {
	[BLOODLUST] = {
		display_name = "bloodlust_name",
		description = "tb_bloodlust_desc",
		buffs = { "tb_bloodlust" },
	},
	[REAPER] = {
		display_name = "reaper_name",
		description = "tb_reaper_desc",
		buffs = { "tb_reaper" },
	},
	[REGROWTH] = {
		display_name = "regrowth_name",
		description = "tb_regrowth_desc",
		buffs = { "tb_regrowth" },
		description_values = {},
	},
	[VANGUARD] = {
		display_name = "vanguard_name",
		description = "tb_vanguard_desc",
		buffs = { "tb_vanguard" },
	},
}
-- career_name, talent 1-1, talent 1-2, talent 1-3
local talent_first_row = {
	{ "es_mercenary", 		REAPER, 	BLOODLUST, 	VANGUARD },
	{ "es_huntsman", 		VANGUARD, 	BLOODLUST, 	REAPER },
	{ "es_knight", 			VANGUARD, 	REAPER, 	BLOODLUST },
	{ "es_questingknight", 	VANGUARD, 	BLOODLUST, 	REAPER },

	{ "dr_ranger", 			VANGUARD, 	REAPER, 	BLOODLUST },
	{ "dr_ironbreaker", 	VANGUARD, 	BLOODLUST, 	REAPER },
	{ "dr_slayer", 			REAPER, 	BLOODLUST, 	REGROWTH },
	{ "dr_engineer", 		VANGUARD, 	REAPER, 	BLOODLUST },

	{ "we_waywatcher", 		REGROWTH, 	REAPER, 	BLOODLUST },
	{ "we_maidenguard", 	REAPER, 	BLOODLUST, 	REGROWTH }, -- Second Wind -> Sting
	{ "we_shade", 			REGROWTH, 	BLOODLUST, 	REAPER },
	{ "we_thornsister", 	REGROWTH, 	BLOODLUST, 	REAPER },

	{ "wh_captain", 		REGROWTH, 	REAPER, 	BLOODLUST },
	{ "wh_bountyhunter", 	REGROWTH, 	BLOODLUST, 	REAPER },
	{ "wh_zealot", 			REAPER, 	BLOODLUST, 	VANGUARD },
	{ "wh_priest", 			VANGUARD, 	REAPER, 	BLOODLUST },

	{ "bw_adept", 			VANGUARD, 	BLOODLUST, 	REAPER },
	{ "bw_scholar", 		REAPER, 	BLOODLUST, 	REGROWTH },
	{ "bw_unchained", 		VANGUARD, 	REAPER, 	BLOODLUST },
	{ "bw_necromancer", 	REAPER, 	BLOODLUST, 	REGROWTH },
}

for i = 1, #talent_first_row do
	local entry = talent_first_row[i]
	local career = entry[1]

	for slot = 1, 3 do
		mod_api.update_talent(career, 1, slot, THP_TALENT_OPTIONS[entry[slot + 1]])
	end
end

