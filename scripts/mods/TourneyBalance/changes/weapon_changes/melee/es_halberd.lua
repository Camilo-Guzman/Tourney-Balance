local mod = get_mod("TourneyBalance")

--[[
	Halberd
]]
--light 1
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[2].power_distribution.attack = 0.225
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[3].power_distribution.attack = 0.15
--DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.4
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[1].armor_modifier.attack[1] = 1.25
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].start_time = 0.5
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
			boost_curve_coefficient_headshot = 1,
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
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.35,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
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
			boost_curve_coefficient_headshot = 2,
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
NewDamageProfileTemplates.tb_halberd_light_chop = {
    charge_value = "light_attack",
	cleave_distribution = {
        attack = 0.075,
        impact = 0.075
    },
    critical_strike = {
        attack_armor_power_modifer = {
            1.25,
            .76,
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
            1.25,
            .76,
            2.5,
            1,
            0.75
        },
        impact = {
            1,
            0.8,
            1,
            1,
            0.75
        }
    },
    default_target = {
        boost_curve_coefficient_headshot = 1.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 1,
        attack_template = "stab_smiter",
        power_distribution = {
            attack = 0.325,
            impact = 0.2
        }
    },
    melee_boost_override = 2.5,
	shield_break = true
}

