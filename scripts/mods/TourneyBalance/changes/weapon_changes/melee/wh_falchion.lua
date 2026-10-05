local mod = get_mod("TourneyBalance")

--Falchion
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_left.damage_profile = "tb_falchion_lights"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_right.damage_profile = "tb_falchion_lights"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_falchion_lights"

NewDamageProfileTemplates.tb_falchion_lights = {
	armor_modifier = {
		attack = {
			1,
			0.2,
			2,
			1,
			1
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
		attack = 0.3,
		impact = 0.2
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.125,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 2,
			attack_template = "light_slashing_linesman_hs",
			power_distribution = {
				attack = 0.2,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	},
}

