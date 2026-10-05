local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Battle Wizard
		### Career Ability
		- Increased cooldown to 60s (from 50s).
		- Increased fire trail linger time to 1.5s (from 0.25).
		- Increased time between DOT damages to 0.75s (from 0.25).

		### Talents
		**Famished Flames**
		- Increased burn damage increase to 150% (from 100%).
		- Increased non-burn damage decreaseto 30% (from 15%).

		**Lingering Flames**
		- Added burn damage reduction 67%.

		**Soot Shield**
		- Decreased damage reduction per stack to 5% (from 8%).
		- Increased max stacks to 4 (from 3).

		**Fires from Ash**
		- Decreased cooldown reduction to 2% (from 3%).

		**Immersive Immolation**
		- Decreased required targets for attack speed to 1 (from 4).

		**Kaboom!**
		- Added 20% cooldown reduction.
	$END_TB
]]

--[[

	Ultimate

]]
mod_api.update_career_ability_cooldown("bw_2", 60) 
--Firetrail nerf (Fatshark please)
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod_api.insert_buff_template("sienna_adept_ability_trail", {
    apply_buff_func = "start_dot_damage",
    damage_profile = "burning_dot",
    damage_type = "burninating",
    leave_linger_time = 1.5, -- 0.25,
    max_stacks = 1,
    name = "sienna_adept_ability_trail",
    on_max_stacks_overflow_func = "reapply_buff",
    time_between_dot_damages = 0.75, -- 0.25,
    update_func = "apply_dot_damage",
    update_start_delay = 0.25,
    perks = { buff_perks.burning, }
})

--[[

	Talents

]]
--[[
    Famished Flames
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_adept_increased_burn_damage", {
    multiplier = 1.5, -- 1,
})
mod_api.update_talent_buff_template("bright_wizard", "sienna_adept_reduced_non_burn_damage", {
    multiplier = -0.3, -- -0.15,
})
mod_api.insert_text("sienna_adept_increased_burn_damage_reduced_non_burn_damage_desc", "Burning damage over time is increased by 150.0%%. All non-burn damage is reduced by 30.0%%.")


--[[
    Lingering Flames
]]
mod_api.insert_talent_buff_template("bright_wizard", "battle_wizard_lingering_reduced_dot_damage", {
    stat_buff = "increased_burn_dot_damage",
    multiplier = -0.67,
})
mod_api.update_talent("bw_adept", 2, 3, {
    buffs = {
        "battle_wizard_lingering_reduced_dot_damage"
    },
})
mod_api.insert_text("sienna_adept_infinite_burn_desc", "Sienna's burning effects now last until the affected enemy dies. Burning effects do not stack and deal 67% reduced damage.")

--[[
    Soot Shield
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05, -- -0.08,
	max_stacks = 4 -- 8
})
mod_api.update_talent("bw_adept", 5, 1, {
    description_values = {
        {
            value_type = "percent",
            value = 0.05, --buff_tweak_data.sienna_adept_damage_reduction_on_ignited_enemy_buff.multiplier,
        },
        {
            value = 5, --buff_tweak_data.sienna_adept_damage_reduction_on_ignited_enemy_buff.duration,
        },
        {
            value = 4, --buff_tweak_data.sienna_adept_damage_reduction_on_ignited_enemy_buff.max_stacks,
        },
    },
})

--[[
    Fires from Ash
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_adept_cooldown_reduction_on_burning_enemy_killed", {
    cooldown_reduction = 0.02 --0.03
})
mod_api.update_talent("bw_adept", 5, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.02
        }
    },
})

--[[
    Immersive Immolation
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_adept_attack_speed_on_enemies_hit_buff", {
    stat_buff = "attack_speed_melee", -- "attack_speed"
})

mod_api.update_talent_buff_template("bright_wizard", "sienna_adept_attack_speed_on_enemies_hit", {
    required_targets = 1 -- 4
})
mod_api.update_talent("bw_adept", 5, 3, {
    description_values = {
        {
            value = 1, --buff_tweak_data.sienna_adept_attack_speed_on_enemies_hit.required_targets,
        },
        {
            value_type = "percent",
            value = 0.15, --buff_tweak_data.sienna_adept_attack_speed_on_enemies_hit_buff.multiplier,
        },
        {
            value = 5, --buff_tweak_data.sienna_adept_attack_speed_on_enemies_hit_buff.duration,
        },
    },
})

--[[
    Kaboom!
]]
mod_api.insert_talent_buff_template("bright_wizard", "sienna_adept_activated_ability_explosion_buff", {
    stat_buff = "activated_cooldown",
	multiplier = -0.2
})
mod_api.update_talent("bw_adept", 6, 2, {
	buffs = {
        "sienna_adept_activated_ability_explosion_buff"
    },
})
mod_api.insert_text("sienna_adept_activated_ability_explosion_desc", "Fire Walk explosion radius and burn damage increased. No longer leaves a burning trail. Cooldown of Fire Walk reduced by 20%.")


