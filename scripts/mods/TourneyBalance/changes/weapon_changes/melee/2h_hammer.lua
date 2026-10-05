local mod = get_mod("TourneyBalance")

--[[
	2h Hammer (Kruber/Bardin)
]]
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_2h_hammer_heavy"
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_2h_hammer_heavy"
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_push_left_up.damage_profile = "tb_2h_hammer_heavy"
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.anim_time_scale = 1.2
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.anim_time_scale = 1.2
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT

NewDamageProfileTemplates.tb_2h_hammer_heavy = {
	stagger_duration_modifier = 1.8,
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
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
		attack = 0.3,
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
				attack = 0.275,
				impact = 0.3
			},
			armor_modifier = {
				attack = {
					1.5,
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
				attack = 0.15,
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


