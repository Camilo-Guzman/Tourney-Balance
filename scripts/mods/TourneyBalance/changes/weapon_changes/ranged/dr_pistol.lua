local mod = get_mod("TourneyBalance")

--[[
    Masterwork Pistol Nerf
]]
local shotgun_dropoff_ranges = {
	dropoff_end = 15,
	dropoff_start = 8,
}
Weapons.heavy_steam_pistol_template_1.actions.action_one.default.impact_data.damage_profile = "masterwork_pistol_shot"
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.impact_data.damage_profile = "masterwork_pistol_shot"
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.impact_data.damage_profile = "masterwork_pistol_shot"
NewDamageProfileTemplates.masterwork_pistol_shot = {
	charge_value = "instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1.4,
			1.17,
			1,
			0.75,
			0.5,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	armor_modifier_near = {
		attack = {
			0.91, -- 1
			1.2,
			1.17,
			1,
			0.75,
			0,
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0,
		},
	},
	armor_modifier_far = {
		attack = {
			1,
			1,
			1,
			1,
			0.75,
			0,
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0,
		},
	},
	cleave_distribution = {
		attack = 0.3,
		impact = 0.3,
	},
	default_target = {
		attack_template = "shot_sniper",
		boost_curve_coefficient = 1,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "smiter_curve",
		headshot_boost_boss = 0.5,
		power_distribution_near = {
			attack = 1,
			impact = 0.5,
		},
		power_distribution_far = {
			attack = 0.5,
			impact = 0.5,
		},
		range_modifier_settings = shotgun_dropoff_ranges
	},
}
