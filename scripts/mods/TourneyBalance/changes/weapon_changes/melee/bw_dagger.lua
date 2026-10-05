local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
    Dagger
]]
mod_api.insert_buff_template("dagger_push_attack_bleed_to_burn_buff", {
	apply_buff_func = "start_dot_damage",
	damage_profile = "dagger_push_attack_burn_dot_profile",
	damage_type = "burninating",
	duration = 2,
	hit_zone = "neck",
	max_stacks = 1,
	name = "burning_dot_1tick",
	refresh_durations = true,
	time_between_dot_damages = 0.75,
	update_func = "apply_dot_damage",
	update_start_delay = 0.75,
	perks = {
		buff_perks.burning,
	},
})
DotTypeLookup.dagger_push_attack_bleed_to_burn_buff = "burning_dot"

mod_api.insert_buff_template("dagger_push_attack_bleed_to_burn_buff_balefire", {
	apply_buff_func = "start_dot_damage",
	damage_profile = "dagger_push_attack_burn_dot_profile",
	damage_type = "burninating",
	duration = 2,
	hit_zone = "neck",
	max_stacks = 1,
	name = "burning_dot_1tick",
	refresh_durations = true,
	time_between_dot_damages = 0.75,
	update_func = "apply_dot_damage",
	update_start_delay = 0.75,
	perks = {
		buff_perks.burning_balefire,
	},
})
DotTypeLookup.dagger_push_attack_bleed_to_burn_buff_balefire = "burning_dot"
BalefireBurnDotLookup["dagger_push_attack_bleed_to_burn_buff"] = "dagger_push_attack_bleed_to_burn_buff_balefire"
BalefireDots["dagger_push_attack_bleed_to_burn_buff_balefire"] = true

NewDamageProfileTemplates.sienna_dagger_light_1 = {
	armor_modifier = {
		attack = {
			1.14, -- 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},		
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_fencer_L",
	critical_strike = "critical_strike_linesman_fencer_L",
	default_target = {
		attack_template = "light_slashing_linesman_hs",
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.125, -- 0.075
			impact = 0.05,
		},
	},
	targets = "targets_linesman_fencer_L"
}
NewDamageProfileTemplates.sienna_dagger_light_2 = {
	armor_modifier = {
		attack = {
			1.21, -- 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_fencer_L",
	critical_strike = "critical_strike_linesman_fencer_L",
	default_target = {
		attack_template = "light_slashing_linesman_hs",
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.125, -- 0.075
			impact = 0.05,
		},
	},
	targets = "targets_linesman_fencer_L"
}
NewDamageProfileTemplates.sienna_dagger_light_3 = {
	armor_modifier = {
		attack = {
			1.25, -- 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_fencer_L",
	critical_strike = "critical_strike_linesman_fencer_L",
	default_target = "default_target_linesman_fencer_L",
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_coefficient_headshot = 3, -- 2.5
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.125,
				impact = 0.05,
			},
		}
	}
}
NewDamageProfileTemplates.sienna_dagger_light_4 = {
	armor_modifier = {
		attack = {
			1.5, -- 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_fencer_L",
	critical_strike = "critical_strike_linesman_fencer_L",
	default_target = {
		attack_template = "light_slashing_linesman_hs",
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.125, -- 0.075
			impact = 0.05,
		},
	},
	targets = "targets_linesman_fencer_L"
}
NewDamageProfileTemplates.dagger_push_attack_burn_dot_profile = {
	charge_value = "n/a",
	is_dot = true,
	no_stagger = true,
	no_stagger_damage_reduction_ranged = true,
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25,
	},
	armor_modifier = {
		attack = {
			1,
			0.5,
			1,
			0.25,
			0.5,
			0,
		},
		impact = {
			1,
			0.5,
			1,
			0.25,
			0.5,
			0,
		},
	},
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_coefficient = 0.2,
		boost_curve_type = "tank_curve",
		damage_type = "burninating",
		power_distribution = {
			attack = 0.075,
			impact = 0,
		},
	},
}
NewDamageProfileTemplates.dagger_push_attack_bleed_to_burn = {
	armor_modifier = "armor_modifier_fencer_stab_L_AP",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_fencer_stab_L",
	default_target = "default_target_fencer_stab_L",
	require_damage_for_dot = true,
	targets = {
		{
			attack_template = "light_stab_smiter",
			boost_curve_coefficient_headshot = 3,
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "dagger_push_attack_bleed_to_burn_buff",
			power_distribution = {
				attack = 0.12,
				impact = 0.08,
			},
		},
	},
}
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_left.damage_profile = "sienna_dagger_light_1"
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_right.damage_profile = "sienna_dagger_light_2"
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_stab.damage_profile = "sienna_dagger_light_3"
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_last.damage_profile = "sienna_dagger_light_4"
Weapons.one_handed_daggers_template_1.actions.action_one.push_stab.damage_profile = "dagger_push_attack_bleed_to_burn"

