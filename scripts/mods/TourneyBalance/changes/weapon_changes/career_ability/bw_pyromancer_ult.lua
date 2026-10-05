local mod = get_mod("TourneyBalance")

-- Pyromancer ult
-- Lower weapon swap timer after casting ult
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_release.default.total_time = 0.3 -- 1
-- Burning Head
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.attack = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.attack = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.attack_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.attack = 0.5
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.impact = 0.5
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}
DamageProfileTemplates.fire_spear_trueflight.friendly_fire_multiplier = 0 -- remove FF on Crit


