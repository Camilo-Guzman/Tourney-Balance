local mod = get_mod("TourneyBalance")

--[[
    Conflag
]]
DamageProfileTemplates.geiser.targets[1].power_distribution.attack = 0.5
ExplosionTemplates.conflag.aoe.duration = 10
ExplosionTemplates.conflag.aoe.damage_interval = 2

Weapons.staff_fireball_geiser_template_1.actions.action_one.default.impact_data.damage_profile = "staff_conflag_tourney"
NewDamageProfileTemplates.staff_conflag_tourney = {
	charge_value = "projectile",
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.35,
			1.5,
			1,
			1,
			0.25,
		},
		impact_armor_power_modifer = {
			1,
			0.6,
			0,
			0,
			1,
			0.25,
		},
	},
	armor_modifier = {
		attack = {
			1,
			0.35,
			1.5,
			1,
			1,
			0,
		},
		impact = {
			1,
			0.6,
			0,
			0,
			0.5,
			0,
		},
	},
	cleave_distribution = {
		attack = 0.1,
		impact = 0.1,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_coefficient = 0.75,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "linesman_curve",
		power_distribution_near = {
			attack = 0.44, --0.35,
			impact = 0.3,
		},
		power_distribution_far = {
			attack = 0.3, --0.15,
			impact = 0.15,
		},
		range_modifier_settings = carbine_dropoff_ranges,
	},
}


