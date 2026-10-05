local mod = get_mod("TourneyBalance")

--[[
	Holy Hammer
]]
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile	= "holy_hammer_light_2"
NewDamageProfileTemplates.holy_hammer_light_2 = {
	armor_modifier = {
		attack = {
			1.5, -- 1
			1.05, -- 0.8
			2,
			1,
			1.01, -- 0.75
			1, 
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.36, -- 1
			0.95, -- 0.8
			2.5,
			1,
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
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_coefficient = 2,
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.4,
			impact = 0.25,
		},
	},
	shield_break = true,
	targets = "targets_smiter_M",
}

Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "tb_2h_hammer_light_3_priest"
Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "tb_2h_hammer_heavy_2_priest"
DamageProfileTemplates.priest_hammer_heavy_blunt_tank_upper.targets[2].power_distribution.attack = 0.1
DamageProfileTemplates.priest_hammer_blunt_smiter.armor_modifier.attack[2] = 2.025
DamageProfileTemplates.priest_hammer_blunt_smiter.armor_modifier.attack[6] = 1.2
DamageProfileTemplates.priest_hammer_blunt_smiter.critical_strike.attack_armor_power_modifer[2] = 1.8
NewDamageProfileTemplates.tb_2h_hammer_light_3_priest = {
	stagger_duration_modifier = 1.5,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.3,
		impact = 0.8
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.2
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.2,
			1,
			1,
			0.75
		},
		impact = {
			1,
			1,
			0.5,
			1,
			0.75
		}
	}
}

NewDamageProfileTemplates.tb_2h_hammer_heavy_2_priest = {
	stagger_duration_modifier = 1.8,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.6,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.8
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.125
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "heavy_blunt_tank",
			power_distribution = {
				attack = 0.5,
				impact = 0.3
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					2,
					1,
					0.75
				},
				impact = {
					1.5,
					1,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "heavy_blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.225
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.2
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75
		}
	}
}
