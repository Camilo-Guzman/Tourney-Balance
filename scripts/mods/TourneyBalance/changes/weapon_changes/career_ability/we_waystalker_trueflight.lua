local mod = get_mod("TourneyBalance")

--[[
    Trueshot Volley
]]
-- Added breed prioritization
Weapons.kerillian_waywatcher_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}

-- Trueflight FF crit reduced
DamageProfileTemplates.arrow_sniper_trueflight = {
    charge_value = "projectile",
    no_stagger_damage_reduction_ranged = true,
    critical_strike = {
        attack_armor_power_modifer = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
        },
        impact_armor_power_modifer = {
            1,
            1,
            0,
            1,
            1,
            1
        }
    },
    armor_modifier_near = {
        attack = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            1
        }
    },
    armor_modifier_far = {
        attack = {
            1.5,
            1,
            2,
            0.25,
            1,
            0.6
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            0
        }
    },
    cleave_distribution = {
        attack = 0.375,
        impact = 0.375
    },
    default_target = {
        boost_curve_coefficient_headshot = 2.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 0.75,
        attack_template = "arrow_sniper",
        power_distribution_near = {
            attack = 0.5,
            impact = 0.3
        },
        power_distribution_far = {
            attack = 0.5,
            impact = 0.25
        },
        range_dropoff_settings = sniper_dropoff_ranges
    },
	friendly_fire_multiplier = 0.25
}
DamageProfileTemplates.arrow_sniper_ability_piercing.friendly_fire_multiplier = 0.25


