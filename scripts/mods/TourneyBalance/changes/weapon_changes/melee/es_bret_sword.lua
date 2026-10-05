local mod = get_mod("TourneyBalance")

--[[
	Bretonnian Longsword
]]
--Bret Sword Light 2, Heavy 1 & 2 buffs
--1H Axe Heavy attack buff
Weapons.bastard_sword_template.actions.action_one.light_attack_right.damage_profile = "bret_sword_light_2"
Weapons.bastard_sword_template.actions.action_one.light_attack_bopp.damage_profile = "tb_bret_sword_push_attack"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_left.damage_profile = "bret_sword_heavy_1_2"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_right.damage_profile = "bret_sword_heavy_1_2"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_down.damage_profile = "tb_bret_sword_heavy_3"
--Light
NewDamageProfileTemplates.bret_sword_light_2 = {
	armor_modifier = "armor_modifier_linesman_M",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_M",
	critical_strike = "critical_strike_linesman_M",
	default_target = "default_target_linesman_M",
	targets = {
		{
			attack_template = "slashing_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.225,
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.2, -- 0.125,
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15, -- 0.1,
				impact = 0.1,
			},
		},
	},
}
-- Push-attack
NewDamageProfileTemplates.tb_bret_sword_push_attack = {
	armor_modifier = "armor_modifier_smiter_M",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_smiter_M_2h",
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		armor_modifier = {
			attack = {
				1.25,
				0.8,
				2.5,
				1,
				0.75,
			},
			impact = {
				1,
				0.8,
				1,
				1,
				0.75,
			},
		},
		power_distribution = {
			attack = 0.4, -- 0.325
			impact = 0.2,
		},
	},
	shield_break = true,
	targets = "targets_smiter_M",
}
--Heavy
NewDamageProfileTemplates.bret_sword_heavy_1_2 = {
	armor_modifier = "armor_modifier_axe_linesman_H",
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.455, -- 0.35,
		impact = 0.455, -- 0.35,
	},
	critical_strike = "critical_strike_axe_linesman_H",
	default_target = "default_target_axe_linesman_H",
	targets = "targets_axe_linesman_H",
}
-- Heavy 3
NewDamageProfileTemplates.tb_bret_sword_heavy_3 = {
	armor_modifier = {
		attack = {
			1,
			0.515, -- 0.5
			1.5,
			1,
			0.75,
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_smiter_H",
	default_target = "default_target_smiter_H",
	shield_break = true,
	targets = "targets_smiter_H",
}
