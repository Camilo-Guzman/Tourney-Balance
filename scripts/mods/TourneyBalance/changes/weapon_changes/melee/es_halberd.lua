local mod = get_mod("TourneyBalance")

--[[
	Halberd
]]
--light 1
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[2].power_distribution.attack = 0.225
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[3].power_distribution.attack = 0.15
--DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.4
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[1].armor_modifier.attack[1] = 1.25
--Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].start_time = 0.5
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.damage_profile = "tb_halberd_light_slash"
NewDamageProfileTemplates.tb_halberd_light_slash = {
	armor_modifier = "armor_modifier_axe_linesman_M",
	critical_strike = "critical_strike_axe_linesman_M",
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.25
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1.25,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.225,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.1
			}
		}
	}
}

--light 2
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile = "tb_halberd_light_stab"
NewDamageProfileTemplates.tb_halberd_light_stab = {
    charge_value = "light_attack",
	cleave_distribution = {
        attack = 0.075,
        impact = 0.075
    },
    critical_strike = {
        attack_armor_power_modifer = {
            1,
            .8,
            2.5,
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
    armor_modifier = {
        attack = {
            1,
            .7,
            2.25,
            1,
            0.75
        },
        impact = {
            1,
            0.75,
            1,
            1,
            0.75
        }
    },
    default_target = {
        boost_curve_coefficient_headshot = 2,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 1,
        attack_template = "stab_smiter",
        power_distribution = {
            attack = 0.25,
            impact = 0.125
        }
    },
    melee_boost_override = 2.5
}

--Heavy 2
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].armor_modifier.attack[1] = 1.15
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].power_distribution.attack = 0.45
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[2].power_distribution.attack = 0.35
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[3].power_distribution.attack = 0.25
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[4].power_distribution.attack = 0.15
--DamageProfileTemplates.heavy_slashing_linesman_polearm.default_target.power_distribution.attack = 0.10
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_halberd_heavy_slash"
NewDamageProfileTemplates.tb_halberd_heavy_slash = {
	armor_modifier = "armor_modifier_linesman_H",
	critical_strike = "critical_strike_linesman_H",
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_linesman_executioner_H",
	default_target =  {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1.75,
			headshot_boost_boss = 0.154,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			},
			armor_modifier = {
				attack = {
					1.15,
					0.5,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75,
			headshot_boost_boss = 0.154,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.35,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75,
			headshot_boost_boss = 0.154,
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75,
			headshot_boost_boss = 0.154,
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	},
}
--Heavy 1
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile = "tb_halberd_heavy_stab"
NewDamageProfileTemplates.tb_halberd_heavy_stab = {
    charge_value = "heavy_attack",
   	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
    critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.56,
			2.5,
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
	armor_modifier = {
		attack = {
			1,
			0.3,
			2,
			1,
			0.75
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75
		}
	},
	default_target = {
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "heavy_stab_smiter",
		power_distribution = {
			attack = 0.2,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2.8,
			headshot_boost_boss = 0.175,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 0.75,
			attack_template = "heavy_stab_smiter",
			armor_modifier = {
				attack = {
					1,
					0.56,
					2,
					1,
					0.75
				},
				impact = {
					1,
					0.65,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			}
		}
	},
	melee_boost_override = 2.5
}
--light 3 and push stab
--DamageProfileTemplates.medium_slashing_smiter_2h.default_target.boost_curve_coefficient_headshot = 2.5
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_down.damage_profile = "tb_halberd_light_chop"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_last.damage_profile = "tb_halberd_light_chop"
NewDamageProfileTemplates.tb_halberd_light_chop = { -- vanilla: medium_slashing_smiter_2h
	armor_modifier = {
		attack = {
			1.25, -- vanilla: 1
			1.25, -- vanilla: 0.8
			2.5, -- vanilla: 1.75
			1,
			0.75,
		},
		impact = {
			1,
			0.8, -- vanilla: 0.6
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			1.25, -- vanilla: 0.8
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
	default_target = {
		attack_template = "stab_smiter", -- vanilla: "slashing_smiter"
		boost_curve_coefficient = 1, -- vanilla: none
		boost_curve_coefficient_headshot = 1.5, -- vanilla: none
		boost_curve_type = "ninja_curve", -- vanilla: "smiter_curve"
		power_distribution = {
			attack = 0.325,
			impact = 0.2,
		},
		-- removed: armor_modifier (vanilla: <table>)
	},
	melee_boost_override = 2.5, -- vanilla: none
	shield_break = true,
}

--[[ Open Beta
-- two_handed_halberds_template_1
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_halberd_heavy_slash"
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile = "tb_halberd_heavy_stab"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_last.damage_profile = "tb_halberd_light_chop"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.damage_profile = "tb_halberd_light_slash"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile = "tb_halberd_light_stab"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_down.damage_profile = "tb_halberd_push_attack"

-- changed: targets[1].boost_curve_coefficient_headshot 1.75 -> 1
NewDamageProfileTemplates.tb_halberd_heavy_slash = { -- official: heavy_slashing_linesman_polearm
	armor_modifier = "armor_modifier_linesman_H",
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.145, -- official: 0.5
			2.5,
			1,
			1,
			0.05, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_linesman_executioner_H",
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		power_distribution = {
			attack = 0.1,
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			headshot_boost_boss = 0.154, -- official: none
			armor_modifier = {
				attack = {
					1.15, -- official: 1
					0.169, -- official: 0.5
					1.5,
					1,
					0.75,
					0.13, -- official: none
				},
				impact = {
					0.9,
					0.5,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.45, -- official: 0.325
				impact = 0.25,
			},
		},
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: 1
			headshot_boost_boss = 0.154, -- official: none
			power_distribution = {
				attack = 0.35, -- official: 0.25
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: none
			headshot_boost_boss = 0.154, -- official: none
			power_distribution = {
				attack = 0.25, -- official: 0.15
				impact = 0.1,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: none
			headshot_boost_boss = 0.154, -- official: none
			power_distribution = {
				attack = 0.15, -- official: 0.125
				impact = 0.075,
			},
		},
	},
}
-- changed: targets[1].boost_curve_coefficient_headshot 2.8 -> 2
NewDamageProfileTemplates.tb_halberd_heavy_stab = { -- official: heavy_slashing_smiter_stab_polearm
	armor_modifier = {
		attack = {
			1,
			0.3,
			2,
			1,
			0.75,
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.56, -- official: 0.5
			2.5,
			1,
			1,
			0.01, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5,
	default_target = {
		attack_template = "heavy_stab_smiter",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 0.75,
		power_distribution = {
			attack = 0.2,
			impact = 0.15,
		},
	},
	targets = {
		{
			attack_template = "heavy_stab_smiter",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 0.75,
			headshot_boost_boss = 0.175, -- official: none
			armor_modifier = {
				attack = {
					1,
					0.56, -- official: 0.45
					2,
					1,
					0.75,
					0.15, -- official: none
				},
				impact = {
					1,
					0.65,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.25,
			},
		},
	},
}

NewDamageProfileTemplates.tb_halberd_light_chop = { -- official: medium_slashing_smiter_2h
	armor_modifier = {
		attack = {
			1.25, -- official: 1
			1.25, -- official: 0.8
			2.5, -- official: 1.75
			1,
			0.75,
			0.03, -- official: none
		},
		impact = {
			1,
			0.8, -- official: 0.6
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			1.25, -- official: 0.8
			2.5,
			1,
			1,
			0.01, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5, -- official: none
	shield_break = true,
	default_target = {
		attack_template = "stab_smiter", -- official: "slashing_smiter"
		boost_curve_type = "ninja_curve", -- official: "smiter_curve"
		boost_curve_coefficient_headshot = 1.5, -- official: none
		boost_curve_coefficient = 1, -- official: none
		power_distribution = {
			attack = 0.325,
			impact = 0.2,
		},
		-- removed: armor_modifier (official: <table>)
	},
}

NewDamageProfileTemplates.tb_halberd_light_slash = { -- official: medium_slashing_axe_linesman
	armor_modifier = "armor_modifier_axe_linesman_M",
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0, -- official: 0.5
			1.5,
			1,
			1,
			0.01, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.4, -- official: 0.275
		impact = 0.25,
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.5,
			armor_modifier = {
				attack = {
					1.25, -- official: 1
					0.08, -- official: 0.3
					1.5,
					1,
					0.75,
					0.05, -- official: none
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.25,
				impact = 0.2,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.225, -- official: 0.15
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15, -- official: 0.1
				impact = 0.1,
			},
		},
	},
}

NewDamageProfileTemplates.tb_halberd_light_stab = { -- official: medium_slashing_smiter_stab
	armor_modifier = {
		attack = {
			1,
			0.7, -- official: 0.25
			2.25,
			1,
			0.75,
			0.1, -- official: none
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
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8, -- official: 0.4
			2.5,
			1,
			1,
			0.01, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5,
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient_headshot = 2,
		boost_curve_coefficient = 1,
		power_distribution = {
			attack = 0.25, -- official: 0.2
			impact = 0.125,
		},
	},
}

NewDamageProfileTemplates.tb_halberd_push_attack = { -- official: medium_slashing_smiter_2h
	armor_modifier = {
		attack = {
			1.25, -- official: 1
			1.25, -- official: 0.8
			2.5, -- official: 1.75
			1,
			0.75,
		},
		impact = {
			1,
			0.8, -- official: 0.6
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			1.25, -- official: 0.8
			2.5,
			1,
			1,
			1.17, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5, -- official: none
	shield_break = true,
	default_target = {
		attack_template = "stab_smiter", -- official: "slashing_smiter"
		boost_curve_type = "ninja_curve", -- official: "smiter_curve"
		boost_curve_coefficient_headshot = 1.5, -- official: none
		boost_curve_coefficient = 1, -- official: none
		power_distribution = {
			attack = 0.325,
			impact = 0.2,
		},
		-- removed: armor_modifier (official: <table>)
	},
	targets = {
		-- removed: [2] (official: <table>)
	},
}


--]]