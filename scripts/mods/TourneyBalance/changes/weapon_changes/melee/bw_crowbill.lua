local mod = get_mod("TourneyBalance")

--[[
	Crowbill
]]
Weapons.one_handed_crowbill.actions.action_one.heavy_attack.damage_profile = "crowbill_heavy_1"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_left.damage_profile = "crowbill_heavy_2"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_right_up.damage_profile = "crowbill_heavy_3"
Weapons.one_handed_crowbill.actions.action_one.light_attack_last.damage_profile = "crowbill_light_1"
Weapons.one_handed_crowbill.actions.action_one.light_attack_upper.damage_profile = "crowbill_light_2"
Weapons.one_handed_crowbill.actions.action_one.light_attack_right.damage_profile = "crowbill_light_3"
Weapons.one_handed_crowbill.actions.action_one.light_attack_left.damage_profile = "crowbill_light_4"
Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.damage_profile = "crowbill_push_attack"
Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.05

NewDamageProfileTemplates.crowbill_heavy_1 = { -- high damage, very difficult to headshot with
	armor_modifier = {
		attack = {
			1.66, -- 1
			1.2, -- 0.9
			2,
			1,
			1,
			1.2, -- 0.9
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.5,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.25, -- 1
			0.93, -- 0.8
			2.5,
			1,
			1,
			1, -- 0.8
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_coefficient = 1,
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.325,
				impact = 0.21,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.25,
				impact = 0.175,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.175,
				impact = 0.14,
			},
		},
	},
	shield_break = true,
}
NewDamageProfileTemplates.crowbill_heavy_2 = { -- lots of crit cleave
	armor_modifier = {
		attack = {
			1.3, -- 1
			0.9,
			2,
			1,
			1,
			0.9,
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.5,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.77, -- 1
			2,
			1,
			0.83, -- 1
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_coefficient = 1,
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.34,
				impact = 0.22,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.28,
				impact = 0.19,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.22,
				impact = 0.16,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.16,
				impact = 0.13,
			},
		},
	},
	shield_break = true,
}
NewDamageProfileTemplates.crowbill_heavy_3 = { -- high headshot damage,
	armor_modifier = {
		attack = {
			1,
			0.8,
			1.75,
			1,
			0.83, -- 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
			1,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.73, -- 0.8
			1.75, -- 2.5
			1,
			1,
			0.8,
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 2, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.75, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.325,
				impact = 0.21,
			},
		},
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.5, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.25,
				impact = 0.175,
			},
		},
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.25, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.175,
				impact = 0.14,
			},
		},
	},
	shield_break = true,
}
NewDamageProfileTemplates.crowbill_light_1 = {
	armor_modifier = {
		attack = {
			1.143, -- 1
			1,
			2,
			1,
			1,
			0.85, -- 0.5
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.1, -- 1
			0.94, -- 1
			1.8, -- 2
			1,
			1,
			0.9, -- 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.21, -- 0.175
				impact = 0.1,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.32,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.165,
				impact = 0.091,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.16,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.12,
				impact = 0.082,
			},
		},
	},
}
NewDamageProfileTemplates.crowbill_light_2 = { -- Needs to do more damage than Light 1 to avoid Light 1->BC shennanigans
	armor_modifier = {
		attack = {
			1.14, -- 1
			1.06, -- 1
			2,
			1,
			1.05, -- 1, 1.32
			0.85, -- 0.5
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.94, -- 1
			2,
			1,
			0.97, -- 1
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
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.245, -- 0.175
				impact = 0.1,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.4,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.211, -- 0.175
				impact = 0.095,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.3,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.177, -- 0.175
				impact = 0.09,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.2,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.143, -- 0.175
				impact = 0.085,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.1,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.109, -- 0.175
				impact = 0.08,
			},
		},
	},
}
NewDamageProfileTemplates.crowbill_light_3 = {
	armor_modifier = {
		attack = {
			1.2, -- 1
			1.1, -- 1
			2,
			1,
			1.1, -- 1
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.1, -- 1
			1,
			2,
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
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.255, -- 0.175, 0.237
				impact = 0.1,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.375,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.21, -- 0.175, 0.237
				impact = 0.094,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.25,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.165, -- 0.175, 0.237
				impact = 0.087,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.125,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.120, -- 0.175, 0.237
				impact = 0.081,
			},
		},
	}
}
NewDamageProfileTemplates.crowbill_light_4 = { -- high headshot damage, low bodyshot damage
	armor_modifier = {
		attack = {
			1, -- 1
			1.1, -- 0.5
			2.2, -- 1.5
			1,
			1.1, -- 0.75
			1.25, -- 0.5
		},
		impact = {
			1,
			1.25,
			1,
			1,
			0.75,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1, -- 0.5
			2,
			1,
			1,
			1.1, -- 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_coefficient = 0.75,
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "burning_stab_fencer",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2.5, -- 1.5
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.2,
				impact = 0.2,
			},
		},
		{
			attack_template = "burning_stab_fencer",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2.32, -- 1.5
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.167,
				impact = 0.158,
			},
		},
		{
			attack_template = "burning_stab_fencer",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2.16, -- 1.5
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.133,
				impact = 0.118,
			},
		},
	}
}
NewDamageProfileTemplates.crowbill_push_attack = { -- 5% crit chance to give this attack a reason to exist, should help necro
	armor_modifier = "armor_modifier_pointy_smiter_L",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_pointy_smiter_L",
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.175,
				impact = 0.1,
			},
		},
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.375,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.15,
				impact = 0.094,
			},
		},
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.25,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.125,
				impact = 0.088,
			},
		},
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.125,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.1,
				impact = 0.082,
			},
		},
	}
}


