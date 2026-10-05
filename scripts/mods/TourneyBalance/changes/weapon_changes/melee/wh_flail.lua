local mod = get_mod("TourneyBalance")

--[[
	Flail
]]
--Light 1, 2, Bopp Attack Speed--
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_left.anim_time_scale = 1 * 1.25	-- 1.0
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_right.anim_time_scale = 1 * 1.35	-- 1.0
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1 * 1.3	-- 1.1

--Light 1, 2, 3, 4 Movement Speed--
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_left.buff_data.external_multiplier = 0.85	-- 0.75
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_right.buff_data.external_multiplier = 0.85	--0.75
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.buff_data.external_multiplier = 0.85	--0.75
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.buff_data.external_multiplier = 1.0	--0.75

--New Damage Profiles Applied--
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.damage_profile = "light_1h_flail_tb"
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.damage_profile = "light_1h_flail_tb"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack.damage_profile = "heavy_1h_flail_tb"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_flail_tb"

--Light 1, 2, Bopp Stagger Cleave
DamageProfileTemplates.light_blunt_tank_spiked.cleave_distribution.impact = 0.5			--0.25
--New Damage Profiles Flail Lights 3,4
NewDamageProfileTemplates.light_1h_flail_tb = {
	armor_modifier = {
		attack = {
			1.25,
			0.9,
			2.5,
			1,
			1,
			0.9
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
			0.9,
			2.75,
			1,
			0.9
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
		boost_curve_coefficient_headshot = 1.5,
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

--Flail Heavy 1,2-- --Increased Target 2 Damage from 0.15 to 0.25-- --Increased Target 3 Damage from 0.075 to 0.12--
NewDamageProfileTemplates.heavy_1h_flail_tb = {
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
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
			1.0,
			1.3,
			1.3,
			1.3
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
		attack = 0.6,
		impact = 0.65
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "blunt_tank",
		power_distribution = {
			attack = 0.075,
			impact = 0.3
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
		[1] = {
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			boost_curve_coefficient_headshot = 1, --1.5
			armor_modifier = {
				attack = {
					1.3,
					0.8,
					1.3,
					1.3,
					1.3,
					1
				},
				impact = {
					1,
					1,
					0.5,
					1,
					0.75,
				}
			},
			power_distribution = {
				attack = 0.3,
				impact = 0.3
			}
		},
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.22, --0.25
				impact = 0.3
			}
		},
		[3] = {
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.10, --0.12
				impact = 0.3
			}
		}
	}
}



