local mod = get_mod("TourneyBalance")

--[[
	2h Sword (Kruber/Saltzpyre)
]]
--bop
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.35
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.damage_profile = "medium_slashing_smiter_2h"
--Heavies
--DamageProfileTemplates.heavy_slashing_linesman.targets[2].power_distribution.attack = 0.4
--DamageProfileTemplates.heavy_slashing_linesman.targets[2].armor_modifier = { attack = { 1, 0.4, 2, 1, 1 }, impact = { 1, 0.5, 0.5, 1, 1} }
--DamageProfileTemplates.heavy_slashing_linesman.targets[3].power_distribution.attack = 0.25
--DamageProfileTemplates.heavy_slashing_linesman.targets[4].power_distribution.attack = 0.20
--DamageProfileTemplates.heavy_slashing_linesman.default_target.power_distribution.attack = 0.14
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_two_handed_sword_heavy"
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_two_handed_sword_heavy"
NewDamageProfileTemplates.tb_two_handed_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.25,
			2,
			1,
			0.6
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.75,
		impact = 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.14,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.275
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.4,
				impact = 0.15
			},
			armor_modifier = {
				attack = { 1, 0.2, 2, 1, 0.6 },
				impact = { 1, 0.5, 0.5, 1, 1}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	}
}

--lights
--DamageProfileTemplates.medium_slashing_linesman.targets[1].power_distribution.attack = 0.275
--DamageProfileTemplates.medium_slashing_linesman.targets[2].power_distribution.attack = 0.2
--DamageProfileTemplates.medium_slashing_linesman.targets[3].power_distribution.attack = 0.15
--DamageProfileTemplates.medium_slashing_linesman.targets[1].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.medium_slashing_linesman.targets[2].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.medium_slashing_linesman.targets[3].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.medium_slashing_linesman.default_target.power_distribution.attack = 0.1
--DamageProfileTemplates.medium_slashing_linesman.cleave_distribution.impact = 0.4
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_two_handed_sword_light"
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_two_handed_sword_light"
NewDamageProfileTemplates.tb_two_handed_sword_light = {
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			1
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.3
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 1.5,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.275,
				impact = 0.15
			}
		},
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			}
		},
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.1
			}
		}
	}
}


