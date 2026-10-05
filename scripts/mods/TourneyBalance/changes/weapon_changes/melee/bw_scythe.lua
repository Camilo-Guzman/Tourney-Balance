local mod = get_mod("TourneyBalance")

--[[
    Scythe
]]
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT

Weapons.staff_scythe.actions.action_one.light_attack_03.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.staff_scythe.actions.action_one.light_attack_04.hit_mass_count = LINESMAN_HIT_MASS_COUNT

local STATE_SCYTHE = "scythe"
DamageProfileTemplates.heavy_slashing_linesman_scythe_diagonal.targets[1].power_distribution.attack = 0.55    --original 0.5

Weapons.staff_scythe.actions.action_one.light_attack_01.weapon_mode_overrides[STATE_SCYTHE].damage_profile = "medium_slashing_smiter"    --bret L3
Weapons.staff_scythe.actions.action_one.light_attack_02.weapon_mode_overrides[STATE_SCYTHE].damage_profile = "staff_scythe_L2_PA"
Weapons.staff_scythe.actions.action_one.light_attack_bopp.weapon_mode_overrides[STATE_SCYTHE].damage_profile = "staff_scythe_L2_PA"

NewDamageProfileTemplates.staff_scythe_L2_PA = {
    critical_strike = {
        -- attack_armor_power_modifer = { 1, 0.5, 1.5, 1, 1 },
        attack_armor_power_modifer = { 1, 0.8, 2.5, 1, 1 },
        impact_armor_power_modifer = { 1, 1, 1, 1, 1 }
    },
	charge_value = "light_attack",
    cleave_distribution = {
        attack = 0.275,
        impact = 0.25
    },
    armor_modifier = {
        attack = { 0.9, 0, 1.8, 1, 0.75 },
        impact = { 0.9, 0.5, 1, 1, 0.75 }
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075,
            impact = 0.075
        }
    },
    targets = {
        {
            -- boost_curve_coefficient_headshot = 1.5,    --deleted
            boost_curve_coefficient = 2,    --added
            dot_template_name = "burning_dot_3tick",
            dot_balefire_variant = true,
            boost_curve_type = "linesman_curve",
            attack_template = "heavy_slashing_linesman",
            power_distribution = {
                attack = 0.4,    --0.25
                impact = 0.25    --0.2
            },
            armor_modifier = {
                -- attack = { 1, 0.5, 1.8, 1, 0.75 },
                -- impact = { 0.9, 0.75, 1, 1, 0.75 }
                attack = { 1, 0.8, 1.75, 1, 0.75 },
                impact = { 1, 0.6, 1, 1, 0.75 }
            }
        },
        {
            dot_template_name = "burning_dot_3tick",
            dot_balefire_variant = true,
            boost_curve_type = "linesman_curve",
            attack_template = "slashing_linesman",
            power_distribution = {
                attack = 0.15,
                impact = 0.125
            }
        },
        {
            boost_curve_type = "linesman_curve",
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.1,
                impact = 0.1
            }
        }
    }
}
DamageProfileTemplates.scythe_discharge = {
	no_stagger_damage_reduction = true,
	charge_value = "heavy_attack",
	is_discharge = true,
	armor_modifier = {
		attack = {
			1,
			0.25,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
			0
		}
	},
	default_target = {
		attack_template = "drakegun",
		damage_type = "drakegun",
		power_distribution = {
			attack = 0.07,
			impact = 0.3-- 0.5 (Contols the stagger strength)
		}
	}
}

