local mod = get_mod("TourneyBalance")

--[[
	Elf 1h Sword
]]
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.damage_profile = "light_slashing_smiter_finesse"
Weapons.we_one_hand_sword_template_1.dodge_count = 4
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.range_mod = 1.3
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.range_mod = 1.4
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.anim_time_scale = 0.81
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[1].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_elven_sword_push_attack" -- official: "light_slashing_linesman_elf", prev TB: "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.damage_profile = "tb_elven_sword_light_1" -- official: "light_slashing_linesman_elf", prev TB: "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.damage_profile = "tb_elven_sword_light_2" -- official: "light_slashing_linesman_elf", prev TB: "tb_1h_sword_light_1_2"

-- These attacks are effectively the same as tb_1h_sword_light_1_2 for now.
NewDamageProfileTemplates.tb_elven_sword_light_1 = { -- official: light_slashing_linesman_elf
	armor_modifier = {
		attack = {
			1, -- official: 0.8
			0,
			2,
			1,
			1,
		},
		impact = {
			1, -- official: 0.75
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.35,
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.2, -- official: 0.21
				impact = 0.1,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			power_distribution = {
				attack = 0.15, -- official: 0.185
				impact = 0.075,
			},
		},
	},
}


NewDamageProfileTemplates.tb_elven_sword_light_2 = { -- official: light_slashing_linesman_elf
	armor_modifier = {
		attack = {
			1, -- official: 0.8
			0,
			2,
			1,
			1,
		},
		impact = {
			1, -- official: 0.75
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.35,
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.2, -- official: 0.21
				impact = 0.1,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			power_distribution = {
				attack = 0.15, -- official: 0.185
				impact = 0.075,
			},
		},
	},
}


NewDamageProfileTemplates.tb_elven_sword_push_attack = { -- official: light_slashing_linesman_elf
	armor_modifier = {
		attack = {
			1, -- official: 0.8
			0,
			2,
			1,
			1,
		},
		impact = {
			1, -- official: 0.75
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.35,
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.2, -- official: 0.21
				impact = 0.1,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			power_distribution = {
				attack = 0.15, -- official: 0.185
				impact = 0.075,
			},
		},
	},
}


