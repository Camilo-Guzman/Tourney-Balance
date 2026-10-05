local mod = get_mod("TourneyBalance")

--[[
	1h sword (Kruber/Sienna)
]]
Weapons.one_handed_swords_template_1.dodge_count = 4
--light 1,2
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].boost_curve_type = "ninja_curve"
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].boost_curve_type = "ninja_curve"
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].power_distribution.attack = 0.2
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].power_distribution.attack = 0.15
--DamageProfileTemplates.light_slashing_linesman_finesse.default_target.power_distribution.attack = 0.125
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2"
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_sword_light_1_2"
NewDamageProfileTemplates.tb_1h_sword_light_1_2 = {
	armor_modifier = {
		attack = {
			1,
			0,
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
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.35,
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
--light 3
DamageProfileTemplates.sword_1h_light_smiter_vertical.shield_break = true
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_last.range_mod = 1.4 --1.2

--Heavies
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].armor_modifier.attack = {	1, 0.65, 2, 1, 0.75 }  --{ 1, 0.5, 1, 1, 0.75 }
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_coefficient_headshot = 1.5
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].power_distribution.attack = 0.35 --0.3
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[2].power_distribution.attack = 0.175 --0.1
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[3].power_distribution.attack = 0.1
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_left.range_mod = 1.4 --1.25
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_right.range_mod = 1.4 --1.25
DamageProfileTemplates.medium_slashing_tank_1h_finesse.cleave_distribution = "cleave_distribution_tank_L"
DamageProfileTemplates.medium_slashing_tank_1h_finesse.critical_strike = "critical_strike_stab_smiter_H"


