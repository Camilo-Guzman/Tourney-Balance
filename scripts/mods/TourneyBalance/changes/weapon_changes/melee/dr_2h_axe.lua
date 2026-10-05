local mod = get_mod("TourneyBalance")

--[[
	2h Axe
]]
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.damage_profile = "heavy_2h_axe_tb"
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_2h_axe_tb"
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.slide_armour_hit = true --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.slide_armour_hit = true --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT --nil
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_up.anim_time_scale = 0.9 --0.81
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.1
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.damage_profile = "bopp_2h_axe_tb"
NewDamageProfileTemplates.heavy_2h_axe_tb = {
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.6,
			2,
			1,
			1,
			0.75
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.6,
		impact = 0.35
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.75,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.125
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 0.75,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.5
			},
			armor_modifier = {
				attack = {
					0.9,
					0.5,
					2,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.125
			}
		}
	}
}

NewDamageProfileTemplates.bopp_2h_axe_tb = {
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.5,
			1,
			0.75
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
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
		attack = 0.275,
		impact = 0.6
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
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
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
				attack = 0.15,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	}
}

