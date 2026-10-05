local mod = get_mod("TourneyBalance")

--[[
	1h hammer (Kruber/Bardin)
]]
Weapons.one_handed_hammer_template_1.dodge_count = 4
Weapons.one_handed_hammer_template_2.dodge_count = 4
Weapons.one_handed_hammer_priest_template.dodge_count = 4

--light 1, 2, bop
--DamageProfileTemplates.light_blunt_tank.cleave_distribution.attack = 0.23
--DamageProfileTemplates.light_blunt_tank_diag.targets[1].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.light_blunt_tank_diag.targets[2].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.light_blunt_tank_diag.targets[1].power_distribution.attack = 0.225 --0.175
--DamageProfileTemplates.light_blunt_tank_diag.armor_modifier.attack = { 1, 0.35, 1, 1, 0.75, 0.25 } --{ 1, 0, 1, 1, 0 }
--DamageProfileTemplates.light_blunt_tank_diag.critical_strike.attack_armor_power_modifer = {	1, 0.5, 1, 0.75, 0.35 } --{ 1, 0.5, 1, 1, 0.25 }
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_left.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_01.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile = "tb_1h_hammer_light_1_2"

--light 3, 4
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_last.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_last.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.damage_profile = "tb_1h_hammer_light_3_4"
NewDamageProfileTemplates.tb_1h_hammer_light_3_4 = {
	armor_modifier = {
		attack = {
			1.25,
			0.65,
			3,
			1,
			1.25,
			0.6
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
			0.75,
			2.75,
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
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets = "targets_smiter_L"
}

--Heavies
--DamageProfileTemplates.medium_blunt_smiter_1h.armor_modifier.attack = { 1, 0.8, 2.5, 0.75, 1 } -- { 1, 0.8, 1.75, 0.75, 0.8 }
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "tb_1h_hammer_heavy"
NewDamageProfileTemplates.tb_1h_hammer_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75
		}
	},
	critical_strike = "critical_strike_smiter_M",
	charge_value = "heavy_attack", -- WHY WAS THIS LIGHT ATTACK BEFORE???
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_smiter_M",
	targets = "targets_smiter_M",
	shield_break = true
}


