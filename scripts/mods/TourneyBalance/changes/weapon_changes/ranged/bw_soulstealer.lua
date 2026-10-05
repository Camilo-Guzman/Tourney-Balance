local mod = get_mod("TourneyBalance")

--[[
	Soulstealer
]]
-- Added Bulwark to the list as well
Weapons.staff_death.actions.action_two.default.prioritized_breeds = {
	beastmen_standard_bearer = 1,  
	beastmen_bestigor = 0.75,
	chaos_vortex_sorcerer = 1,
	chaos_corruptor_sorcerer = 1, 
	chaos_raider = 0.75,
	chaos_warrior = 0.75,
	chaos_bulwark = 0.75,
	chaos_berzerker = 0.75,
	skaven_warpfire_thrower = 1,	 
	skaven_gutter_runner = 1,
	skaven_pack_master = 1, 
	skaven_poison_wind_globadier = 1, 
	skaven_ratling_gunner = 1,
	skaven_loot_rat = 1, 
	skaven_plague_monk = 0.75,
	skaven_storm_vermin_commander = 0.75, 
	skaven_storm_vermin = 0.75, 
	skaven_storm_vermin_with_shield = 0.75,
	skaven_storm_vermin_champion = 0.75,
}
Weapons.staff_death.actions.action_one.default.impact_data.damage_profile = "soulstealer_left_click"
Weapons.staff_death.actions.action_one.default.chain_hit_settings.damage_profile = "soulstealer_left_click"
Weapons.staff_death.actions.action_one.default_02.impact_data.damage_profile = "soulstealer_left_click"
Weapons.staff_death.actions.action_one.default_02.chain_hit_settings.damage_profile = "soulstealer_left_click"
Weapons.staff_death.actions.action_one.soul_rip.damage_steps[2].damage_profile = "soulstealer_soul_rip_aka_da_suck"

NewDamageProfileTemplates.soulstealer_left_click = {
	charge_value = "projectile",
	no_friendly_fire = true,
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = false,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.13, -- 0.35
			1.2,
			1,
			0.64, -- 1
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
			0.8,
			0.32,
			1,
			1,
			0.75, -- 0.8
			0.05,
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
		attack = 0,
		impact = 0,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_coefficient = 0.75,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "linesman_curve",
		dot_balefire_variant = true,
		dot_template_name = "death_staff_dot",
		power_distribution = {
			attack = 0.24,
			impact = 0.25,
		},
		range_modifier_settings = carbine_dropoff_ranges,
	},
	targets = {
		{
			attack_template = "fireball",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.16,
				impact = 0.25,
			},
			range_modifier_settings = carbine_dropoff_ranges,
		},
		{
			attack_template = "fireball",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.08,
				impact = 0.25,
			},
			range_modifier_settings = carbine_dropoff_ranges,
		},
		{
			attack_template = "fireball",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.06,
				impact = 0.22,
			},
			range_modifier_settings = carbine_dropoff_ranges,
		},
		{
			attack_template = "fireball",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.08,
				impact = 0.18,
			},
			range_modifier_settings = carbine_dropoff_ranges,
		},
	},
}

NewDamageProfileTemplates.soulstealer_soul_rip_aka_da_suck = {
	charge_value = "heavy_instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			0.95, -- 1
			0.637, -- 1.4
			1.6, -- 3
			1,
			0.23, -- 1
			0.54, -- 1
		},
		impact_armor_power_modifer = {
			1,
			0, -- 1
			1,
			1,
			1,
			0, -- 1
		},
	},
	armor_modifier_near = {
		attack = {
			1.295, -- 1
			0.806, -- 1.2
			2.1, -- 2.5
			1,
			0.4, -- 0.75
			0.7,
		},
		impact = {
			1,
			0, -- 1
			1,
			1,
			1,
			0, -- 1
		},
	},
	armor_modifier_far = {
		attack = {
			1.295, -- 1
			0.72, -- 1
			1.5, -- 2.5
			1,
			0.36, -- 0.75
			0.63, -- 0.7
		},
		impact = {
			1,
			0, -- 1
			1,
			1,
			1,
			0, -- 1
		},
	},
	cleave_distribution = {
		attack = 0.35,
		impact = 0.3,
	},
	default_target = {
		attack_template = "shot_sniper",
		boost_curve_coefficient = 1,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "smiter_curve",
		headshot_boost_boss = 0.5,
		power_distribution_near = {
			attack = 1.1,
			impact = 0.5,
		},
		power_distribution_far = {
			attack = 0.9,
			impact = 0.5,
		},
		range_modifier_settings = sniper_dropoff_ranges,
	},
}


