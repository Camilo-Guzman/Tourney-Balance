local mod = get_mod("TourneyBalance")

--[[
	Sienna Mace
]]
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.range_mod = 1.75
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.range_mod = 1.75
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.slide_armour_hit = true
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.slide_armour_hit = true

Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.damage_profile = "light_blunt_smiter_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.damage_profile = "light_blunt_smiter_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.damage_profile = "light_blunt_tank_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.damage_profile = "light_blunt_tank_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.damage_profile = "light_blunt_tank_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.damage_profile = "medium_blunt_smiter_heavy_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.damage_profile = "medium_blunt_tank_upper_1h_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.damage_profile = "medium_blunt_tank_upper_1h_wiz"

NewDamageProfileTemplates.medium_blunt_tank_upper_1h_wiz = {
	stagger_duration_modifier = 1.5,
	critical_strike = {
		attack_armor_power_modifer = {
			1.2,
			1,
			1.3,
			1.3,
			1.2
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.6,
		impact = 0.65
	},
	default_target = {
		boost_curve_type = "tank_curve",
		stagger_duration_modifier = 1.5,
		boost_curve_coefficient_headshot = 1.4,
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.3,
				impact = 0.3
			}
		},
		{
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.15,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
	armor_modifier = {
		attack = {
			1.5,
			0.8,
			1.3,
			1.3,
			1.6
		},
		impact = {
			1,
			1,
			0.5,
			1,
			0.75
		}
	},
}
NewDamageProfileTemplates.medium_blunt_smiter_heavy_wiz = {
	armor_modifier = {
		attack = {
			1,
			0.9,
			1.75,
			1,
			0.75
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.7
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	charge_value = "heavy_attack", -- was "light_attack": hits counted as light attacks for heavy attack talents/procs
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		boost_curve_coefficient_headshot = 1.1,
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.4,
			impact = 0.25
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	shield_break = true
}
NewDamageProfileTemplates.light_blunt_tank_wiz = {
	stagger_duration_modifier = 1.25,
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
			0.25,
			1.5,
			1,
			1.2
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
		attack = 0.2,
		impact = 0.6
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		boost_curve_coefficient_headshot = 1.4,
		power_distribution = {
			attack = 0.05,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1.5,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.175,
				impact = 0.25
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.175
			}
		}
	},
	armor_modifier = {
		attack = {
			1.8,
			0,
			1,
			1,
			1.6
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	}
}
NewDamageProfileTemplates.light_blunt_smiter_wiz = {
	armor_modifier = {
		attack = {
			1.5,
			1.1,
			2.5,
			1,
			1.4,
			0.6
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.2,
			0.9,
			2.75,
			1,
			1.2
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 1.2,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets = {
		[2] = {
			boost_curve_type = "smiter_curve",
			attack_template = "slashing_smiter",
			armor_modifier = {
				attack = {
					1,
					0.25,
					1,
					1,
					0.75
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	}
}

