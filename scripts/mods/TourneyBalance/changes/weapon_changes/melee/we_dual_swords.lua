local mod = get_mod("TourneyBalance")

--[[
	Dual Swords
]]
-- Lights
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_dual_swords_light_1"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_dual_swords_light_2"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_up_left.damage_profile = "tb_dual_swords_light_3"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_up_right.damage_profile = "tb_dual_swords_light_4"
NewDamageProfileTemplates.tb_dual_swords_light_1 = {
    armor_modifier = {
        attack = {
            1.05, -- 1.25, 0.85
            0,
            2,
            1,
            1.17 -- 1
        },
        impact = {
            1,
            0.2, -- 0.3, Why was this 0.3? Why is it undocumented?
            0.5,
            1,
            1
        }
    },
    critical_strike = {
        attack_armor_power_modifer = {
            0.83, -- 1.25, 0.75
            0.5,
            2, -- 2.5
            1,
            0.95 -- 1
        },
        impact_armor_power_modifer = {
            1,
            0.25, -- 0.5, Why was this 0.5? Why is it undocumented?
            0.5, 
            1,
            1
        }
    },
    charge_value = "light_attack",
    cleave_distribution = {
        attack = 0.3, -- 0.25
        impact = 0.2
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.08, -- 0.125
            impact = 0.05
        }
    },
    targets = {
        {
            boost_curve_coefficient_headshot = 0.65, -- 1.5, 2
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient = 1, -- 1, 2
            attack_template = "light_slashing_linesman_hs",
            power_distribution = {
                attack = 0.2, -- 0.2
                impact = 0.1
            }
        },
        {
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient_headshot = 0.75, -- 1, 2
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.16, -- 0.015
                impact = 0.084 -- 0.075
            },
        },
		{
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient_headshot = 0.85, -- 1, 2
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.12, -- 0.125
                impact = 0.067 -- 0.075
            },
        }
    },
}

NewDamageProfileTemplates.tb_dual_swords_light_2 = {
    armor_modifier = {
        attack = {
            1.2, -- 1.25, 0.85
            0,
            2.1,
            1,
            1.37 -- 1
        },
        impact = {
            1,
            0.2, -- 0.3, Why was this 0.3? Why is it undocumented?
            0.5,
            1,
            1
        }
    },
    critical_strike = {
        attack_armor_power_modifer = {
            0.905, -- 1.25, 0.75
            0.5,
            2.1, -- 2.5
            1,
            1.1 -- 1
        },
        impact_armor_power_modifer = {
            1,
            0.25, -- 0.5, Why was this 0.5? Why is it undocumented?
            0.5,
            1,
            1
        }
    },
    charge_value = "light_attack",
    cleave_distribution = {
        attack = 0.347, -- 0.25, 0.3
        impact = 0.2
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075, -- 0.125
            impact = 0.05
        }
    },
    targets = {
        {
            boost_curve_coefficient_headshot = 0.65, -- 1.5, 2
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient = 1, -- 1, 2
            attack_template = "light_slashing_linesman_hs",
            power_distribution = {
                attack = 0.2,
                impact = 0.1
            }
        },
        {
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient_headshot = 0.75, -- 1, 2
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.175, -- 0.15
                impact = 0.088 -- 0.075
            },
        },
		{
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient_headshot = 0.85, -- 1, 2
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.125, -- 0.125
                impact = 0.075 -- 0.005
            },
        },
		{
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient_headshot = 0.95, -- 1, 2
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.1, -- 0.125
                impact = 0.063 -- 0.005
            },
        }
    },
}

NewDamageProfileTemplates.tb_dual_swords_light_3 = {
	armor_modifier = {
		attack = {
			1.33, -- 1.25
			0,
			2.2, -- 2
			1,
			1.6, -- 1
		},
		impact = {
			1,
			0.2,
			0.5,
			1,
			1,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.07, -- 1.25
			0.3,
			2.3, -- 2.5
			1,
			1.3, -- 1
		},
		impact_armor_power_modifer = {
			1,
			0.25,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.407, -- 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.1, -- 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_coefficient_headshot = 0.6, -- 1.5
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.2, -- 0.135
				impact = 0.1, -- 0.075
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.65, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.18, -- 0.09
				impact = 0.09, -- 0.05
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.7, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.16, -- 0.075
				impact = 0.08, -- 0.05
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.75, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.14, -- 0.075
				impact = 0.07, -- 0.05
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.8, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.12, -- 0.075
				impact = 0.06, -- 0.05
			},
		}
	},
}

NewDamageProfileTemplates.tb_dual_swords_light_4 = {
	armor_modifier = {
		attack = {
			1.6, -- 1.25
			0,
			2.64, -- 2
			1,
			1.9, -- 1
		},
		impact = {
			1,
			0.2,
			0.5,
			1,
			1,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.33, -- 1.25
			0.3,
			2.5,
			1,
			1.58, -- 1
		},
		impact_armor_power_modifer = {
			1,
			0.25,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.407, -- 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, --  -- 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_coefficient_headshot = 0.55, -- 1.5
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.2, -- 0.135
				impact = 0.1, -- 0.075
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.65, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.185, -- 0.09
				impact = 0.09, -- 0.05
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.75, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.17, -- 0.075
				impact = 0.08, -- 0.05
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.85, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.165, -- 0.075
				impact = 0.07, -- 0.05
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_coefficient_headshot = 0.95, -- 1
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.14, -- 0.075
				impact = 0.06, -- 0.05
			},
		}
	},
}

-- Heavy (test me)
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_right = "tb_dual_swords_heavy_2"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_left = "tb_dual_swords_heavy_2"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_right = "tb_dual_swords_heavy_1"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_left = "tb_dual_swords_heavy_1"
NewDamageProfileTemplates.tb_dual_swords_heavy_1 = {
	armor_modifier = {
		attack = {
			0.93, -- 1		
			0.19, -- 0.25, 0.2
			2,
			1,
			0.5 -- 0.6		
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.08, -- 1
			0.13, -- 0.5
			2.5,
			1,
			0.6 -- 1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.225, -- 0.45,
		impact = 0.2 -- 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.07,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 0.33, -- 1
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.3,
				impact = 0.275
			},
			--armor_modifier = {
			--	attack = { 1, 0.2, 2, 1, 0.6 },
			--	impact = { 1, 0.5, 0.5, 1, 1 }
			--}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.15
			},
			--armor_modifier = {
			--	attack = { 1, 0.2, 2, 1, 0.6 },
			--	impact = { 1, 0.5, 0.5, 1, 1}
			--}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.125,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	}
}

NewDamageProfileTemplates.tb_dual_swords_heavy_2 = {
	armor_modifier = {
		attack = {
			1.35, -- 1, 0.75
			0.19, -- 0.25
			2,
			1,
			0.6
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.03, -- 1
			0.1, -- 0.5
			2.5,
			1,
			0.45 -- 1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.225, -- 0.45,
		impact = 0.2 -- 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.07,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.3,
				impact = 0.275
			},
			--armor_modifier = {
			--	attack = { 1, 0.2, 2, 1, 0.6 },
			--	impact = { 1, 0.5, 0.5, 1, 1 }
			--}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.15
			},
			--armor_modifier = {
			--	attack = { 1, 0.2, 2, 1, 0.6 },
			--	impact = { 1, 0.5, 0.5, 1, 1}
			--}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.125,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	}
}

