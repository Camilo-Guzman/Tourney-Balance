local mod = get_mod("TourneyBalance")

--[[
	1h Axe (Bardin/Saltzpyre)
]]
-- lights
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.anim_time_scale = 1.3 --1.035
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.anim_time_scale = 1.3 --1.035
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.damage_profile = "light_1h_axe_tb_last"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.damage_profile = "light_1h_axe_tb_last"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_left.damage_profile = "light_1h_axe_tb_left_right"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_left.damage_profile = "light_1h_axe_tb_left_right"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_right.damage_profile = "light_1h_axe_tb_left_right"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_right.damage_profile = "light_1h_axe_tb_left_right"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_bopp.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_bopp.damage_profile = "light_1h_axe_tb"
NewDamageProfileTemplates.light_1h_axe_tb = {
	armor_modifier = {
		attack = {
			1.25,
			0.45,
			2.1,
			1,
			1,
			0.45
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
			1.25,
			0.45,
			2.75,
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
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 2,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
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
	},
}
NewDamageProfileTemplates.light_1h_axe_tb_last = {
	armor_modifier = {
		attack = {
			1.25,
			0.45,
			2.1,
			1,
			1,
			0.45
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
			1.25,
			0.45,
			2.75,
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
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.3,
		impact = 0.3
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 2,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
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
	},
}
NewDamageProfileTemplates.light_1h_axe_tb_left_right = {
	armor_modifier = {
		attack = {
			1.25,
			0.45,
			2.1,
			1,
			1,
			0.45
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
			1.25,
			0.45,
			2.75,
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
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.15,
		impact = 0.15
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 2,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
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
	},
}

--Heavy
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --1
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --1
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --1
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --1

Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_axe_tb"
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.damage_profile = "heavy_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.damage_profile = "heavy_1h_axe_tb"

NewDamageProfileTemplates.heavy_1h_axe_tb = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			2,
			1,
			0.75,
			1.3, -- 1,
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_blunt_smiter_2h_hammer_H",
	default_target = "default_target_slashing_smiter_finesse",
	shield_break = true,
	targets = "targets_smiter_M",
}


