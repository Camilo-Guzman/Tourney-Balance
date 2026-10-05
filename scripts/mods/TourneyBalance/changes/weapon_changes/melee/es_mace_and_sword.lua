local mod = get_mod("TourneyBalance")

--[[
	Mace and Sword
]]
--lights 1,2
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2"
NewDamageProfileTemplates.tb_1h_hammer_light_1_2 = {
	stagger_duration_modifier = 1.25,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.75,
			0.25
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
		attack = 0.23,
		impact = 0.6
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.225,
				impact = 0.25
			}
		},
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.175
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.35,
			1,
			1,
			0.75,
			0.25
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

--lights 3,4
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right_diagonal.damage_profile = "tb_1h_sword_light_1_2"

--Heavy
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_right = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_right = "mace_sword_heavy"

--Bopp
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_left = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_right = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.anim_time_scale = 1.15
NewDamageProfileTemplates.mace_sword_bopp = {
	stagger_duration_modifier = 1.5,
	charge_value = "light_attack",
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
			1,
			0.5,
			1,
			1
		}
	},
	cleave_distribution = {
		attack = 0.2,
		impact = 0.2
	},
	armor_modifier = {
		attack = {
			1,
			0.5,
			2.5,
			1,
			0.9,
			0.5
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.075,
			impact = 0.075
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
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
}
NewDamageProfileTemplates.mace_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.5,
			1.5,
			1,
			0.75,
			0.5
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.6,
			0.5
		},
		impact_armor_power_modifer = {
			0.9,
			0.5,
			1,
			1,
			0.75
		}
	},
    charge_value = "heavy_attack",
    cleave_distribution = {
        attack = 0.15,
        impact = 0.3
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075,
            impact = 0.075
        }
    },
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.275,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					1.5,
					1,
					0.75,
					0.5
				},
				impact = {
					1,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			},

		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	melee_boost_override = 6
}

