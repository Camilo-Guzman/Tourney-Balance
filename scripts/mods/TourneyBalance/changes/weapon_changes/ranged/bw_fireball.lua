local mod = get_mod("TourneyBalance")

-- Fireball
-- Removed smokecloud on charged fireball
ExplosionTemplates.fireball_charged.explosion = {
	use_attacker_power_level = true,
	radius_min = 1.25,
	sound_event_name = "drakepistol_hit",
	radius_max = 3,
	attacker_power_level_offset = 0.25,
	max_damage_radius_min = 0.5,
	alert_enemies_radius = 10,
	damage_profile_glance = "fireball_charged_explosion_glance",
	max_damage_radius_max = 2,
	alert_enemies = true,
	damage_profile = "fireball_charged_explosion",
	effect_name = "fx/wpnfx_drake_pistols_projectile_impact"
}
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.impact_data = {
	damage_profile = "staff_fireball_charged",
	aoe = ExplosionTemplates.fireball_charged
}
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.ignore_shield_hit = true
Weapons.staff_fireball_fireball_template_1.actions.action_one.default.impact_data.damage_profile = "staff_fireball_tourney"
NewDamageProfileTemplates.staff_fireball_tourney = {
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

DamageProfileTemplates.staff_fireball_charged.cleave_distribution.attack = 1.2
DamageProfileTemplates.staff_fireball_charged.cleave_distribution.impact = 1.2
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_near.attack = 0.375
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_far.attack = 0.375
DamageProfileTemplates.staff_fireball_charged.armor_modifier.attack[5] = 1.3


