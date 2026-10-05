local mod = get_mod("TourneyBalance")

--[[
	Elven Spear
]]																						
-- values at v6.11.0 / v6.4.0
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_start = 0.347	-- official: 0.35 / 0.31
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_end = 0.39 		-- official: 0.37 / 0.35

Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_start = 0.223 -- official: 0.2 / 0.25
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_end = 0.3  	-- official: 0.3 / 0.3

Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_start = 0.19	-- official: 0.15 / 0.2
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_end = 0.33  	-- official: 0.3 / 0.3

Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_profile = "elven_spear_light_thrusts"
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_profile = "elven_spear_light_thrusts"
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_profile = "elven_spear_light_thrusts"

Weapons.two_handed_spears_elf_template_1.actions.action_one.heavy_attack_stab.damage_profile = "elven_spear_heavy_stab"
NewDamageProfileTemplates.elven_spear_light_thrusts = {
	armor_modifier = {
		attack = {
			1.22, -- 1
			0.35, -- 0.25
			2.25,
			1,
			0.75,
			0.45, -- 0.25
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.22, -- 1
			0.5, -- 0.4
			2.5,
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
	default_target = "default_target_stab_smiter_M_elf"
}
NewDamageProfileTemplates.elven_spear_heavy_stab = {
	armor_modifier = {
		attack = {
			1,
			0.45,
			2,
			1,
			0.75,
			0.6, -- 0.45
		},
		impact = {
			1,
			0.65,
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
			0.5,
			2.5,
			1,
			1,
			0.6, -- 0.5
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = "default_target_stab_smiter_H",
	targets = {
		{
			attack_template = "heavy_stab_smiter",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.45,
				impact = 0.25,
			}
		}
	}
}

