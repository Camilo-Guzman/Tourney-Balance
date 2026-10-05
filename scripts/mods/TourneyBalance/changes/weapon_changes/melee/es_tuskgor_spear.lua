local mod = get_mod("TourneyBalance")

--[[
	Tuskgor Spear
]]
--[[  w/ Assassin
--- 10% Chaos:
-- 3-SHS Berserker => Light 1-Light 2-Light 3
--- 10% Chaos & 10% Infantry:
-- 2-SHS Marauders => Light 1-Light 2
]]
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_left.damage_profile 	= "tusk_spear_light_1"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_1.damage_profile 	= "tusk_spear_light_2"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_right.damage_profile 	= "tusk_spear_light_3"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_2.damage_profile 	= "tusk_spear_light_4"
Weapons.two_handed_heavy_spears_template.actions.action_one.heavy_attack_left.damage_profile 	= "tusk_spear_heavy_1"

NewDamageProfileTemplates.tusk_spear_light_1 = {
	armor_modifier = {
		attack = {
			1,
			0.35, -- 0.25
			2.25,
			1,
			0.75,
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.47, -- 0.4
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = "default_target_spear_stab_smiter_M"
}

NewDamageProfileTemplates.tusk_spear_light_2 = {
	armor_modifier = {
		attack = {
			1.335, -- 1
			0.45, -- 0.25
			2.75, -- 2.25
			1,
			1.05, -- 0.75
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.335, -- 1
			0.45, -- 0.4
			2.75, -- 2.5
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = "default_target_spear_stab_smiter_M"
}

NewDamageProfileTemplates.tusk_spear_light_3 = {
	armor_modifier = {
		attack = {
			1,
			0,
			2,
			1,
			1.16, -- 1 
			0.74, -- 0
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_L",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
			0.6 -- 0.5
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	default_target = "default_target_linesman_L",
	targets = "targets_linesman_spear_M",
}

NewDamageProfileTemplates.tusk_spear_light_4 = {
	armor_modifier = {
		attack = {
			2, -- 1
			0.9, -- 0.25
			2.25,
			1,
			1.65, -- 0.75
			1.08, -- 0.9
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.8, -- 1
			0.8, -- 0.4
			2.5,
			1,
			1.5, -- 1
			1.2, -- 0.8
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		}
	},
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_coefficient = 1,
		boost_curve_coefficient_headshot = 0.7, -- 1.5
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.25,
			impact = 0.25,
		}
	}
}

--- 10% Chaos:
-- 2-SHS SV => Heavy 1-Light2 OR Heavy 1/Light 1-BC-Light 1/Heavy 1
NewDamageProfileTemplates.tusk_spear_heavy_1 = {
	armor_modifier = {
		attack = {
			1.208, -- 1
			1.007, -- 0.45
			2,
			1,
			0.75,
		},
		impact = {
			1,
			0.65,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.13, -- 1
			0.947, -- 0.5
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = "default_target_stab_smiter_H",
	targets = {
		{
			attack_template = "heavy_stab_smiter",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			power_distribution = { -- Since this is a single target attack, I've removed the armor modifier table that was here to prevent it from overwriting the one above it. 
				attack = 0.45,
				impact = 0.25,
			},
		},
	},
}

