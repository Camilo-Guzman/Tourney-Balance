local mod = get_mod("TourneyBalance")

--[[
 	Hammer & Tome
]]
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.damage_profile 		= "hammer_and_tome_heavy_1_charged"
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_stab_charged.damage_profile 		= "hammer_and_tome_heavy_2_charged"
NewDamageProfileTemplates.hammer_and_tome_heavy_1_charged = {
	armor_modifier = {
		attack = {
			1,
			1.4, -- 0.8
			1.75,
			1,
			0.75,
			1.27, -- 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1.2, -- 0.8
			2.5,
			1,
			1,
			1.08, -- 0.8
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
	default_target = "default_target_smiter_M",
	shield_break = true,
	targets = {
		attack_template = "slashing_smiter",
		boost_curve_coefficient = 2,
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.4, -- 0.45
			impact = 0.25, -- 0.35
		},
	},
}

-- More consistent Monk/Berserker damage
-- 1-SHS Assassins as they pounce
-- Bodyshot + Fury also kills them in one hit
NewDamageProfileTemplates.hammer_and_tome_heavy_2_charged = {
	armor_modifier = {
		attack = {
			2.112, -- 1
			0.8,
			1.75,
			1,
			1.44, -- 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.6, -- 1
			0.8,
			2.5,
			1,
			1.283, -- 1
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
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_coefficient = 2,
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.45, -- 0.4
			impact = 0.25,
		},
	},
	shield_break = true,
	targets = "targets_smiter_M",
}


