local mod = get_mod("TourneyBalance")

--[[
    Javelin
]]
DamageProfileTemplates.thrown_javelin.armor_modifier_near.attack = { 1, 0.7, 1.1, 1, 0.75, 0.25 }
DamageProfileTemplates.thrown_javelin.armor_modifier_far.attack = { 1, 0.7, 1.1, 1, 0.75, 0.25 }
DamageProfileTemplates.thrown_javelin.cleave_distribution = { attack = 0.8, impact = 0.8 }
DamageProfileTemplates.thrown_javelin.default_target = {
	boost_curve_coefficient_headshot = 1.6,
	boost_curve_type = "smiter_curve",
	boost_curve_coefficient = 1,
	attack_template = "projectile_javelin",
	power_distribution_near = {
		attack = 0.8,
		impact = 0.85
	},
	power_distribution_far = {
		attack = 0.8,
		impact = 0.85
	},
	range_modifier_settings = {	dropoff_start = 30,	dropoff_end = 50 }
}
