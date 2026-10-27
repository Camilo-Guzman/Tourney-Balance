-- Weapon sweep (TourneyBalance): everything that differs from official, per weapon.
-- Not covered: changes made through hooks, buffs, mod_api calls or shared locals.

-- ################ melee ################

-- ======== bastard_sword_template ========

--[[
	$BEGIN_TB
		## bastard_sword_template

		* action_one.heavy_attack_down: Changed damage_profile to tb_bret_sword_heavy_3 (from heavy_slashing_smiter)
		* action_one.heavy_attack_down: Increased armor_modifier.attack[2] to 0.515 (from 0.5, +3%)
		* action_one.heavy_attack_left: Changed damage_profile to bret_sword_heavy_1_2 (from heavy_slashing_axe_linesman)
		* action_one.heavy_attack_left: Increased cleave_distribution.attack to 0.455 (from 0.35, +30%)
		* action_one.heavy_attack_left: Increased cleave_distribution.impact to 0.455 (from 0.35, +30%)
		* action_one.heavy_attack_right: Changed damage_profile to bret_sword_heavy_1_2 (from heavy_slashing_axe_linesman)
		* action_one.heavy_attack_right: Increased cleave_distribution.attack to 0.455 (from 0.35, +30%)
		* action_one.heavy_attack_right: Increased cleave_distribution.impact to 0.455 (from 0.35, +30%)
		* action_one.light_attack_bopp: Changed damage_profile to tb_bret_sword_push_attack (from medium_slashing_smiter_2h)
		* action_one.light_attack_bopp: Increased default_target.power_distribution.attack to 0.4 (from 0.325, +23%)
		* action_one.light_attack_right: Changed damage_profile to bret_sword_light_2 (from medium_slashing_linesman)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.2 (from 0.125, +60%)
		* action_one.light_attack_right: Increased targets[3].power_distribution.attack to 0.15 (from 0.1, +50%)

	$END_TB
]]

Weapons.bastard_sword_template.actions.action_one.heavy_attack_down.damage_profile = "tb_bret_sword_heavy_3" -- official: "heavy_slashing_smiter"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_left.damage_profile = "bret_sword_heavy_1_2" -- official: "heavy_slashing_axe_linesman"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_right.damage_profile = "bret_sword_heavy_1_2" -- official: "heavy_slashing_axe_linesman"
Weapons.bastard_sword_template.actions.action_one.light_attack_bopp.damage_profile = "tb_bret_sword_push_attack" -- official: "medium_slashing_smiter_2h"
Weapons.bastard_sword_template.actions.action_one.light_attack_right.damage_profile = "bret_sword_light_2" -- official: "medium_slashing_linesman"

-- bret_sword_heavy_1_2: replaces the existing block
-- used by Weapons.bastard_sword_template.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.bastard_sword_template.actions.action_one.heavy_attack_right.damage_profile
NewDamageProfileTemplates.bret_sword_heavy_1_2 = { -- official: heavy_slashing_axe_linesman
	armor_modifier = "armor_modifier_axe_linesman_H",
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_axe_linesman_H",
	cleave_distribution = {
		attack = 0.455, -- official: 0.35
		impact = 0.455, -- official: 0.35
	},
	default_target = "default_target_axe_linesman_H",
	targets = "targets_axe_linesman_H",
}

-- bret_sword_light_2: replaces the existing block
-- used by Weapons.bastard_sword_template.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.bret_sword_light_2 = { -- official: medium_slashing_linesman
	armor_modifier = "armor_modifier_linesman_M",
	charge_value = "light_attack",
	critical_strike = "critical_strike_linesman_M",
	cleave_distribution = "cleave_distribution_linesman_M",
	default_target = "default_target_linesman_M",
	targets = {
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.225,
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.2, -- official: 0.125
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15, -- official: 0.1
				impact = 0.1,
			},
		},
	},
}

-- tb_bret_sword_heavy_3: replaces the existing block
-- used by Weapons.bastard_sword_template.actions.action_one.heavy_attack_down.damage_profile
NewDamageProfileTemplates.tb_bret_sword_heavy_3 = { -- official: heavy_slashing_smiter
	armor_modifier = {
		attack = {
			1,
			0.515, -- official: 0.5
			1.5,
			1,
			0.75,
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_smiter_H",
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = "default_target_smiter_H",
	targets = "targets_smiter_H",
}

-- tb_bret_sword_push_attack: replaces the existing block
-- used by Weapons.bastard_sword_template.actions.action_one.light_attack_bopp.damage_profile
NewDamageProfileTemplates.tb_bret_sword_push_attack = { -- official: medium_slashing_smiter_2h
	armor_modifier = "armor_modifier_smiter_M",
	charge_value = "light_attack",
	critical_strike = "critical_strike_smiter_M_2h",
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		armor_modifier = {
			attack = {
				1.25,
				0.8,
				2.5,
				1,
				0.75,
			},
			impact = {
				1,
				0.8,
				1,
				1,
				0.75,
			},
		},
		power_distribution = {
			attack = 0.4, -- official: 0.325
			impact = 0.2,
		},
	},
	targets = "targets_smiter_M",
}

-- ======== dual_wield_axe_falchion_template ========

--[[
	$BEGIN_TB
		## dual_wield_axe_falchion_template

		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_bopp: Removed hit_mass_count (was <table>)
		* action_one.light_attack_down_left: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_down_left: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_left_diagonal: Added hit_mass_count: <table>
		* action_one.light_attack_right_diagonal: Added hit_mass_count: <table>

	$END_TB
]]

Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_bopp.hit_mass_count = nil -- official: <table>
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = { -- official: none
	beastmen_gor = 0.6,
	beastmen_ungor = 0.6,
	chaos_berzerker = 0.6,
	chaos_fanatic = 0.6,
	chaos_marauder = 0.6,
	chaos_marauder_with_shield = 0.6,
	chaos_raider = 0.6,
	skaven_clan_rat = 0.6,
	skaven_clan_rat_with_shield = 0.6,
	skaven_plague_monk = 0.6,
	skaven_slave = 0.6,
}
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_right_diagonal.hit_mass_count = { -- official: none
	beastmen_gor = 0.6,
	beastmen_ungor = 0.6,
	chaos_berzerker = 0.6,
	chaos_fanatic = 0.6,
	chaos_marauder = 0.6,
	chaos_marauder_with_shield = 0.6,
	chaos_raider = 0.6,
	skaven_clan_rat = 0.6,
	skaven_clan_rat_with_shield = 0.6,
	skaven_plague_monk = 0.6,
	skaven_slave = 0.6,
}

-- light_slashing_smiter (official profile, changed in place)
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter_diag, light_slashing_smiter_diag_1h and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter.armor_modifier.attack[2] = 0.82 -- official: 0.65
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter_diag, light_slashing_smiter_diag_1h and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter.armor_modifier.attack[6] = 0.82 -- official: 0.6

-- light_slashing_smiter_dual (official profile, changed in place)
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter_dual.armor_modifier.attack[2] = 0.82 -- official: 0.65
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter_dual.armor_modifier.attack[6] = 0.82 -- official: 0.6

-- ======== dual_wield_axes_template_1 ========

--[[
	$BEGIN_TB
		## dual_wield_axes_template_1

		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.heavy_attack: Reduced anim_time_scale to 0.925 (from 1.035, -11%)
		* action_one.heavy_attack_2: Increased anim_time_scale to 1.1 (from 1.035, +6%)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.heavy_attack_3: Increased additional_critical_strike_chance to 0.2 (from 0)
		* action_one.heavy_attack_3: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack_3: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.push: Added fatigue_cost: action_stun_push
		* action_one.push: Changed damage_profile_inner to light_push (from medium_push)

	$END_TB
]]

Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack.anim_time_scale = 0.925 -- official: 1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_2.anim_time_scale = 1.1 -- official: 1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_3.additional_critical_strike_chance = 0.2 -- official: 0
Weapons.dual_wield_axes_template_1.actions.action_one.push.damage_profile_inner = "light_push" -- official: "medium_push"
Weapons.dual_wield_axes_template_1.actions.action_one.push.fatigue_cost = "action_stun_push" -- official: none

-- uses light_slashing_smiter_dual (exported under dual_wield_axe_falchion_template)

-- light_slashing_smiter_dual_bopp (official profile, changed in place)
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter_dual_bopp.armor_modifier.attack[2] = 0.82 -- official: 0.65
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter_dual_bopp.armor_modifier.attack[6] = 0.82 -- official: 0.6

-- ======== dual_wield_daggers_template_1 ========

--[[
	$BEGIN_TB
		## dual_wield_daggers_template_1

		* Increased max_fatigue_points to 6 (from 4, +50%)
		* action_one.heavy_attack: Reduced allowed_chain_actions[5].start_time to 0.35 (from 0.5, -30%)
		* action_one.heavy_attack_stab: Reduced allowed_chain_actions[5].start_time to 0.35 (from 0.5, -30%)
		* action_one.light_attack_left: Increased additional_critical_strike_chance to 0.1 (from 0)
		* action_one.light_attack_right: Increased additional_critical_strike_chance to 0.1 (from 0)

	$END_TB
]]

Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.allowed_chain_actions[5].start_time = 0.35 -- official: 0.5
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.allowed_chain_actions[5].start_time = 0.35 -- official: 0.5
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_left.additional_critical_strike_chance = 0.1 -- official: 0
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_right.additional_critical_strike_chance = 0.1 -- official: 0
Weapons.dual_wield_daggers_template_1.max_fatigue_points = 6 -- official: 4

-- ======== dual_wield_hammer_sword_template ========

--[[
	$BEGIN_TB
		## dual_wield_hammer_sword_template

		* action_one.heavy_attack: Added armor_modifier.attack[6]: 0.5
		* action_one.heavy_attack: Added critical_strike.attack_armor_power_modifer[6]: 0.5
		* action_one.heavy_attack: Added targets[1].armor_modifier.attack[6]: 0.5
		* action_one.heavy_attack: Changed damage_profile_left to mace_sword_heavy (from medium_slashing_axe_linesman_1h)
		* action_one.heavy_attack: Changed damage_profile_right to mace_sword_heavy (from medium_slashing_axe_linesman_1h)
		* action_one.heavy_attack: Increased armor_modifier.attack[1] to 1 (from 0.9, +11%)
		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 0.5 (from 0)
		* action_one.heavy_attack: Increased armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.heavy_attack: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.heavy_attack: Increased cleave_distribution.impact to 0.3 (from 0.25, +20%)
		* action_one.heavy_attack: Reduced armor_modifier.impact[2] to 0.3 (from 0.5, -40%)
		* action_one.heavy_attack: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.heavy_attack: Reduced cleave_distribution.attack to 0.15 (from 0.275, -45%)
		* action_one.heavy_attack: Reduced critical_strike.attack_armor_power_modifer[5] to 0.6 (from 1, -40%)
		* action_one.heavy_attack: Reduced critical_strike.impact_armor_power_modifer[1] to 0.9 (from 1, -10%)
		* action_one.heavy_attack: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 1, -50%)
		* action_one.heavy_attack: Reduced critical_strike.impact_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.heavy_attack_2: Added armor_modifier.attack[6]: 0.5
		* action_one.heavy_attack_2: Added critical_strike.attack_armor_power_modifer[6]: 0.5
		* action_one.heavy_attack_2: Added targets[1].armor_modifier.attack[6]: 0.5
		* action_one.heavy_attack_2: Changed damage_profile_left to mace_sword_heavy (from medium_slashing_axe_linesman_1h)
		* action_one.heavy_attack_2: Changed damage_profile_right to mace_sword_heavy (from medium_slashing_axe_linesman_1h)
		* action_one.heavy_attack_2: Increased anim_time_scale to 1.15 (from 1.035, +11%)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[1] to 1 (from 0.9, +11%)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[2] to 0.5 (from 0)
		* action_one.heavy_attack_2: Increased armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.heavy_attack_2: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.heavy_attack_2: Increased cleave_distribution.impact to 0.3 (from 0.25, +20%)
		* action_one.heavy_attack_2: Reduced armor_modifier.impact[2] to 0.3 (from 0.5, -40%)
		* action_one.heavy_attack_2: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.heavy_attack_2: Reduced cleave_distribution.attack to 0.15 (from 0.275, -45%)
		* action_one.heavy_attack_2: Reduced critical_strike.attack_armor_power_modifer[5] to 0.6 (from 1, -40%)
		* action_one.heavy_attack_2: Reduced critical_strike.impact_armor_power_modifer[1] to 0.9 (from 1, -10%)
		* action_one.heavy_attack_2: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 1, -50%)
		* action_one.heavy_attack_2: Reduced critical_strike.impact_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_bopp: Added armor_modifier.attack[6]: 0.5
		* action_one.light_attack_bopp: Added stagger_duration_modifier: 1.5
		* action_one.light_attack_bopp: Changed damage_profile_left to mace_sword_bopp (from light_slashing_axe_linesman)
		* action_one.light_attack_bopp: Changed damage_profile_right to mace_sword_bopp (from light_blunt_tank_spiked)
		* action_one.light_attack_bopp: Changed default_target.attack_template to light_blunt_tank (from light_slashing_linesman)
		* action_one.light_attack_bopp: Changed default_target.boost_curve_type to tank_curve (from linesman_curve)
		* action_one.light_attack_bopp: Changed targets[1].attack_template to blunt_tank (from slashing_linesman)
		* action_one.light_attack_bopp: Changed targets[1].boost_curve_type to tank_curve (from linesman_curve)
		* action_one.light_attack_bopp: Changed targets[2].attack_template to light_blunt_tank (from slashing_linesman)
		* action_one.light_attack_bopp: Changed targets[2].boost_curve_type to tank_curve (from linesman_curve)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 0.5 (from 0)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[3] to 2.5 (from 1.5, +67%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[5] to 0.9 (from 0.75, +20%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[2] to 1 (from 0.25, +300%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased critical_strike.attack_armor_power_modifer[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_bopp: Increased targets[1].power_distribution.attack to 0.2 (from 0.195, +3%)
		* action_one.light_attack_bopp: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_bopp: Reduced cleave_distribution.attack to 0.2 (from 0.25, -20%)
		* action_one.light_attack_bopp: Reduced critical_strike.impact_armor_power_modifer[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_bopp: Reduced targets[2].power_distribution.attack to 0.075 (from 0.125, -40%)
		* action_one.light_attack_bopp: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_bopp: Removed targets[1].boost_curve_coefficient_headshot (was 2)
		* action_one.light_attack_bopp: Removed targets[3] (was <table>)
		* action_one.light_attack_left: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman)
		* action_one.light_attack_left: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_left: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_left_diagonal: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_left_diagonal: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_left_diagonal: Added hit_mass_count: <table>
		* action_one.light_attack_left_diagonal: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left_diagonal: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_left_diagonal: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_left_diagonal: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_left_diagonal: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_left_diagonal: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_left_diagonal: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_left_diagonal: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_left_diagonal: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left_diagonal: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_left_diagonal: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_left_diagonal: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_right: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_right: Added hit_mass_count: <table>
		* action_one.light_attack_right: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_right: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_right: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_right: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_right: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right_diagonal: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman)
		* action_one.light_attack_right_diagonal: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right_diagonal: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right_diagonal: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_right_diagonal: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right_diagonal: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_right_diagonal: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right_diagonal: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)

	$END_TB
]]

Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_left = "mace_sword_heavy" -- official: "medium_slashing_axe_linesman_1h"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_right = "mace_sword_heavy" -- official: "medium_slashing_axe_linesman_1h"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.anim_time_scale = 1.15 -- official: 1.035
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_left = "mace_sword_heavy" -- official: "medium_slashing_axe_linesman_1h"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_right = "mace_sword_heavy" -- official: "medium_slashing_axe_linesman_1h"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_left = "mace_sword_bopp" -- official: "light_slashing_axe_linesman"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_right = "mace_sword_bopp" -- official: "light_blunt_tank_spiked"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = { -- official: none
	beastmen_bestigor = 0.5,
	beastmen_gor = 0.5,
	beastmen_ungor = 0.75,
	chaos_berzerker = 0.5,
	chaos_fanatic = 0.75,
	chaos_marauder = 0.5,
	chaos_marauder_with_shield = 0.5,
	chaos_raider = 0.5,
	chaos_warrior = 1e+01,
	skaven_clan_rat = 0.5,
	skaven_clan_rat_with_shield = 0.5,
	skaven_slave = 0.75,
	skaven_storm_vermin = 0.5,
	skaven_storm_vermin_commander = 0.5,
	skaven_storm_vermin_with_shield = 0.5,
}
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.hit_mass_count = { -- official: none
	beastmen_bestigor = 0.5,
	beastmen_gor = 0.5,
	beastmen_ungor = 0.75,
	chaos_berzerker = 0.5,
	chaos_fanatic = 0.75,
	chaos_marauder = 0.5,
	chaos_marauder_with_shield = 0.5,
	chaos_raider = 0.5,
	chaos_warrior = 1e+01,
	skaven_clan_rat = 0.5,
	skaven_clan_rat_with_shield = 0.5,
	skaven_slave = 0.75,
	skaven_storm_vermin = 0.5,
	skaven_storm_vermin_commander = 0.5,
	skaven_storm_vermin_with_shield = 0.5,
}
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right_diagonal.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman"

-- mace_sword_bopp: replaces the existing block
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_left
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_right
NewDamageProfileTemplates.mace_sword_bopp = { -- official: light_blunt_tank_spiked (comments compare against it; also replaces light_slashing_axe_linesman)
	armor_modifier = {
		attack = {
			1,
			0.5, -- official: 0.25
			2.5, -- official: 1.5
			1,
			0.9, -- official: 1
			0.5, -- official: none
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.5,
	cleave_distribution = {
		attack = 0.2, -- official: 0.25
		impact = 0.2, -- official: 0.25
	},
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.2,
				impact = 0.125,
			},
		},
		{
			attack_template = "light_blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.1,
			},
		},
	},
}

-- mace_sword_heavy: replaces the existing block
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_left
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_right
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_left
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_right
NewDamageProfileTemplates.mace_sword_heavy = { -- official: medium_slashing_axe_linesman_1h
	armor_modifier = {
		attack = {
			1, -- official: 0.9
			0.5, -- official: 0
			1.5,
			1,
			0.75,
			0.5, -- official: none
		},
		impact = {
			1, -- official: 0.9
			0.3, -- official: 0.5
			0.5, -- official: 1
			1,
			1, -- official: 0.75
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.6, -- official: 1
			0.5, -- official: none
		},
		impact_armor_power_modifer = {
			0.9, -- official: 1
			0.5, -- official: 1
			1,
			1,
			0.75, -- official: 1
		},
	},
	cleave_distribution = {
		attack = 0.15, -- official: 0.275
		impact = 0.3, -- official: 0.25
	},
	melee_boost_override = 6,
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 2,
			armor_modifier = {
				attack = {
					1,
					0.5,
					1.5,
					1,
					0.75,
					0.5, -- official: none
				},
				impact = {
					1,
					0.5,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.275,
				impact = 0.2,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.2,
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.1,
				impact = 0.1,
			},
		},
	},
}

-- tb_1h_hammer_light_1_2: replaces the existing block
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.damage_profile
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.damage_profile
-- used by Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_01.damage_profile
-- used by Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile
-- used by Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_right.damage_profile
-- ...and 2 more
NewDamageProfileTemplates.tb_1h_hammer_light_1_2 = { -- official: light_blunt_tank_diag
	armor_modifier = {
		attack = {
			1,
			0.35, -- official: 0
			1,
			1,
			0.75, -- official: 1
			0.25, -- official: none
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5, -- official: 0.25
			1.5,
			1,
			0.75, -- official: 1
			0.25, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.25,
	cleave_distribution = {
		attack = 0.23, -- official: 0.2
		impact = 0.6,
	},
	default_target = {
		attack_template = "light_blunt_tank", -- official: "light_blunt_linesman"
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.05,
			impact = 0.15,
		},
	},
	targets = {
		{
			attack_template = "blunt_tank", -- official: "blunt_linesman"
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 2, -- official: 1.5
			power_distribution = {
				attack = 0.225, -- official: 0.175
				impact = 0.25,
			},
		},
		{
			attack_template = "light_blunt_tank", -- official: "light_blunt_linesman"
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 2, -- official: none
			power_distribution = {
				attack = 0.075,
				impact = 0.175,
			},
		},
	},
}

-- tb_1h_sword_light_1_2: replaces the existing block
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right_diagonal.damage_profile
-- used by Weapons.one_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.one_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile
-- used by Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.damage_profile
-- used by Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.damage_profile
-- ...and 1 more
NewDamageProfileTemplates.tb_1h_sword_light_1_2 = { -- official: light_slashing_linesman (comments compare against it; also replaces light_slashing_linesman_elf, light_slashing_linesman_finesse)
	armor_modifier = {
		attack = {
			1,
			0,
			2,
			1,
			1,
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.35,
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2, -- official: 1.5
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.2, -- official: 0.175
				impact = 0.1,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2, -- official: 1.5
			power_distribution = {
				attack = 0.15, -- official: 0.125
				impact = 0.075,
			},
		},
	},
}

-- ======== dual_wield_hammers_priest_template ========

--[[
	$BEGIN_TB
		## dual_wield_hammers_priest_template

		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_down: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_down: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)

	$END_TB
]]

-- light_blunt_smiter (official profile, changed in place)
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag, light_slashing_smiter_diag_1h and 7 more (14 profiles)
DamageProfileTemplates.light_blunt_smiter.armor_modifier.attack[2] = 0.82 -- official: 0.65
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag, light_slashing_smiter_diag_1h and 7 more (14 profiles)
DamageProfileTemplates.light_blunt_smiter.armor_modifier.attack[6] = 0.82 -- official: 0.6

-- light_blunt_smiter_dual (official profile, changed in place)
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag, light_slashing_smiter_diag_1h and 7 more (14 profiles)
DamageProfileTemplates.light_blunt_smiter_dual.armor_modifier.attack[2] = 0.82 -- official: 0.65
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag, light_slashing_smiter_diag_1h and 7 more (14 profiles)
DamageProfileTemplates.light_blunt_smiter_dual.armor_modifier.attack[6] = 0.82 -- official: 0.6

-- ======== dual_wield_hammers_template ========

--[[
	$BEGIN_TB
		## dual_wield_hammers_template

		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.heavy_attack: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_down: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_down: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)

	$END_TB
]]

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- uses light_blunt_smiter_dual (exported under dual_wield_hammers_priest_template)

-- ======== dual_wield_swords_template_1 ========

--[[
	$BEGIN_TB
		## dual_wield_swords_template_1

		* action_one.heavy_attack: Added default_target.boost_curve_coefficient_headshot: 0.25
		* action_one.heavy_attack: Added targets[1].boost_curve_coefficient: 2
		* action_one.heavy_attack: Added targets[3]: <table>
		* action_one.heavy_attack: Added targets[4]: <table>
		* action_one.heavy_attack: Changed damage_profile_left to tb_dual_swords_heavy_1 (from light_slashing_linesman_dual_medium)
		* action_one.heavy_attack: Changed damage_profile_right to tb_dual_swords_heavy_1 (from light_slashing_linesman_dual_medium)
		* action_one.heavy_attack: Changed targets[1].attack_template to heavy_slashing_linesman (from light_slashing_linesman_hs)
		* action_one.heavy_attack: Changed targets[1].boost_curve_type to linesman_curve (from ninja_curve)
		* action_one.heavy_attack: Changed targets[2].attack_template to heavy_slashing_linesman (from light_slashing_linesman)
		* action_one.heavy_attack: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.heavy_attack: Increased critical_strike.attack_armor_power_modifer[1] to 1.08 (from 1, +8%)
		* action_one.heavy_attack: Increased targets[1].power_distribution.attack to 0.3 (from 0.15, +100%)
		* action_one.heavy_attack: Increased targets[1].power_distribution.impact to 0.275 (from 0.125, +120%)
		* action_one.heavy_attack: Increased targets[2].power_distribution.attack to 0.2 (from 0.125, +60%)
		* action_one.heavy_attack: Increased targets[2].power_distribution.impact to 0.15 (from 0.075, +100%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[1] to 0.93 (from 1, -7%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[2] to 0.19 (from 0.25, -24%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[5] to 0.5 (from 1, -50%)
		* action_one.heavy_attack: Reduced cleave_distribution.attack to 0.225 (from 0.25, -10%)
		* action_one.heavy_attack: Reduced critical_strike.attack_armor_power_modifer[2] to 0.13 (from 0.5, -74%)
		* action_one.heavy_attack: Reduced critical_strike.attack_armor_power_modifer[5] to 0.6 (from 1, -40%)
		* action_one.heavy_attack: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 0.75, -33%)
		* action_one.heavy_attack: Reduced default_target.power_distribution.attack to 0.07 (from 0.075, -7%)
		* action_one.heavy_attack: Reduced targets[1].boost_curve_coefficient_headshot to 0.33 (from 2, -84%)
		* action_one.heavy_attack: Removed melee_boost_override (was 3.5)
		* action_one.heavy_attack: Removed targets[1].armor_modifier (was <table>)
		* action_one.heavy_attack_2: Added default_target.boost_curve_coefficient_headshot: 0.25
		* action_one.heavy_attack_2: Added targets[1].boost_curve_coefficient: 2
		* action_one.heavy_attack_2: Added targets[3]: <table>
		* action_one.heavy_attack_2: Added targets[4]: <table>
		* action_one.heavy_attack_2: Changed damage_profile_left to tb_dual_swords_heavy_2 (from light_slashing_linesman_dual_medium)
		* action_one.heavy_attack_2: Changed damage_profile_right to tb_dual_swords_heavy_2 (from light_slashing_linesman_dual_medium)
		* action_one.heavy_attack_2: Changed targets[1].attack_template to heavy_slashing_linesman (from light_slashing_linesman_hs)
		* action_one.heavy_attack_2: Changed targets[1].boost_curve_type to linesman_curve (from ninja_curve)
		* action_one.heavy_attack_2: Changed targets[2].attack_template to heavy_slashing_linesman (from light_slashing_linesman)
		* action_one.heavy_attack_2: Increased armor_modifier.attack[1] to 1.35 (from 1, +35%)
		* action_one.heavy_attack_2: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.heavy_attack_2: Increased critical_strike.attack_armor_power_modifer[1] to 1.03 (from 1, +3%)
		* action_one.heavy_attack_2: Increased targets[1].power_distribution.attack to 0.3 (from 0.15, +100%)
		* action_one.heavy_attack_2: Increased targets[1].power_distribution.impact to 0.275 (from 0.125, +120%)
		* action_one.heavy_attack_2: Increased targets[2].power_distribution.attack to 0.2 (from 0.125, +60%)
		* action_one.heavy_attack_2: Increased targets[2].power_distribution.impact to 0.15 (from 0.075, +100%)
		* action_one.heavy_attack_2: Reduced armor_modifier.attack[2] to 0.19 (from 0.25, -24%)
		* action_one.heavy_attack_2: Reduced armor_modifier.attack[5] to 0.6 (from 1, -40%)
		* action_one.heavy_attack_2: Reduced cleave_distribution.attack to 0.225 (from 0.25, -10%)
		* action_one.heavy_attack_2: Reduced critical_strike.attack_armor_power_modifer[2] to 0.1 (from 0.5, -80%)
		* action_one.heavy_attack_2: Reduced critical_strike.attack_armor_power_modifer[5] to 0.45 (from 1, -55%)
		* action_one.heavy_attack_2: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 0.75, -33%)
		* action_one.heavy_attack_2: Reduced default_target.power_distribution.attack to 0.07 (from 0.075, -7%)
		* action_one.heavy_attack_2: Reduced targets[1].boost_curve_coefficient_headshot to 1 (from 2, -50%)
		* action_one.heavy_attack_2: Removed melee_boost_override (was 3.5)
		* action_one.heavy_attack_2: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_left: Added targets[1].boost_curve_coefficient: 1
		* action_one.light_attack_left: Added targets[3]: <table>
		* action_one.light_attack_left: Changed damage_profile to tb_dual_swords_light_1 (from light_slashing_linesman_dual_swords)
		* action_one.light_attack_left: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Increased armor_modifier.attack[5] to 1.17 (from 1, +17%)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.3 (from 0.25, +20%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.3, +67%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.08 (from 0.075, +7%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.2 (from 0.135, +48%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.impact to 0.1 (from 0.075, +33%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.16 (from 0.09, +78%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.impact to 0.084 (from 0.05, +68%)
		* action_one.light_attack_left: Reduced armor_modifier.attack[1] to 1.05 (from 1.25, -16%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[1] to 0.83 (from 1.25, -34%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[3] to 2 (from 2.5, -20%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[5] to 0.95 (from 1, -5%)
		* action_one.light_attack_left: Reduced targets[1].boost_curve_coefficient_headshot to 0.65 (from 1.5, -57%)
		* action_one.light_attack_left: Reduced targets[2].boost_curve_coefficient_headshot to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Added targets[1].boost_curve_coefficient: 1
		* action_one.light_attack_right: Added targets[3]: <table>
		* action_one.light_attack_right: Added targets[4]: <table>
		* action_one.light_attack_right: Changed damage_profile to tb_dual_swords_light_2 (from light_slashing_linesman_dual_swords)
		* action_one.light_attack_right: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Increased armor_modifier.attack[3] to 2.1 (from 2, +5%)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1.37 (from 1, +37%)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.347 (from 0.25, +39%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.3, +67%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[5] to 1.1 (from 1, +10%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.2 (from 0.135, +48%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.impact to 0.1 (from 0.075, +33%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.175 (from 0.09, +94%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.impact to 0.088 (from 0.05, +76%)
		* action_one.light_attack_right: Reduced armor_modifier.attack[1] to 1.2 (from 1.25, -4%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[1] to 0.905 (from 1.25, -28%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[3] to 2.1 (from 2.5, -16%)
		* action_one.light_attack_right: Reduced targets[1].boost_curve_coefficient_headshot to 0.65 (from 1.5, -57%)
		* action_one.light_attack_right: Reduced targets[2].boost_curve_coefficient_headshot to 0.75 (from 1, -25%)
		* action_one.light_attack_up_left: Added targets[3]: <table>
		* action_one.light_attack_up_left: Added targets[4]: <table>
		* action_one.light_attack_up_left: Added targets[5]: <table>
		* action_one.light_attack_up_left: Changed damage_profile to tb_dual_swords_light_3 (from light_slashing_linesman_dual_swords)
		* action_one.light_attack_up_left: Increased armor_modifier.attack[1] to 1.33 (from 1.25, +6%)
		* action_one.light_attack_up_left: Increased armor_modifier.attack[3] to 2.2 (from 2, +10%)
		* action_one.light_attack_up_left: Increased armor_modifier.attack[5] to 1.6 (from 1, +60%)
		* action_one.light_attack_up_left: Increased cleave_distribution.attack to 0.407 (from 0.25, +63%)
		* action_one.light_attack_up_left: Increased critical_strike.attack_armor_power_modifer[5] to 1.3 (from 1, +30%)
		* action_one.light_attack_up_left: Increased default_target.power_distribution.attack to 0.1 (from 0.075, +33%)
		* action_one.light_attack_up_left: Increased targets[1].power_distribution.attack to 0.2 (from 0.135, +48%)
		* action_one.light_attack_up_left: Increased targets[1].power_distribution.impact to 0.1 (from 0.075, +33%)
		* action_one.light_attack_up_left: Increased targets[2].power_distribution.attack to 0.18 (from 0.09, +100%)
		* action_one.light_attack_up_left: Increased targets[2].power_distribution.impact to 0.09 (from 0.05, +80%)
		* action_one.light_attack_up_left: Reduced critical_strike.attack_armor_power_modifer[1] to 1.07 (from 1.25, -14%)
		* action_one.light_attack_up_left: Reduced critical_strike.attack_armor_power_modifer[3] to 2.3 (from 2.5, -8%)
		* action_one.light_attack_up_left: Reduced targets[1].boost_curve_coefficient_headshot to 0.6 (from 1.5, -60%)
		* action_one.light_attack_up_left: Reduced targets[2].boost_curve_coefficient_headshot to 0.65 (from 1, -35%)
		* action_one.light_attack_up_right: Added targets[3]: <table>
		* action_one.light_attack_up_right: Added targets[4]: <table>
		* action_one.light_attack_up_right: Added targets[5]: <table>
		* action_one.light_attack_up_right: Changed damage_profile to tb_dual_swords_light_4 (from light_slashing_linesman_dual_swords)
		* action_one.light_attack_up_right: Increased armor_modifier.attack[1] to 1.6 (from 1.25, +28%)
		* action_one.light_attack_up_right: Increased armor_modifier.attack[3] to 2.64 (from 2, +32%)
		* action_one.light_attack_up_right: Increased armor_modifier.attack[5] to 1.9 (from 1, +90%)
		* action_one.light_attack_up_right: Increased cleave_distribution.attack to 0.407 (from 0.25, +63%)
		* action_one.light_attack_up_right: Increased critical_strike.attack_armor_power_modifer[1] to 1.33 (from 1.25, +6%)
		* action_one.light_attack_up_right: Increased critical_strike.attack_armor_power_modifer[5] to 1.58 (from 1, +58%)
		* action_one.light_attack_up_right: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_up_right: Increased targets[1].power_distribution.attack to 0.2 (from 0.135, +48%)
		* action_one.light_attack_up_right: Increased targets[1].power_distribution.impact to 0.1 (from 0.075, +33%)
		* action_one.light_attack_up_right: Increased targets[2].power_distribution.attack to 0.185 (from 0.09, +106%)
		* action_one.light_attack_up_right: Increased targets[2].power_distribution.impact to 0.09 (from 0.05, +80%)
		* action_one.light_attack_up_right: Reduced targets[1].boost_curve_coefficient_headshot to 0.55 (from 1.5, -63%)
		* action_one.light_attack_up_right: Reduced targets[2].boost_curve_coefficient_headshot to 0.65 (from 1, -35%)

	$END_TB
]]

Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_left = "tb_dual_swords_heavy_1" -- official: "light_slashing_linesman_dual_medium"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_right = "tb_dual_swords_heavy_1" -- official: "light_slashing_linesman_dual_medium"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_left = "tb_dual_swords_heavy_2" -- official: "light_slashing_linesman_dual_medium"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_right = "tb_dual_swords_heavy_2" -- official: "light_slashing_linesman_dual_medium"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_dual_swords_light_1" -- official: "light_slashing_linesman_dual_swords"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_dual_swords_light_2" -- official: "light_slashing_linesman_dual_swords"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_up_left.damage_profile = "tb_dual_swords_light_3" -- official: "light_slashing_linesman_dual_swords"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_up_right.damage_profile = "tb_dual_swords_light_4" -- official: "light_slashing_linesman_dual_swords"

-- tb_dual_swords_heavy_1: replaces the existing block
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_left
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_right
NewDamageProfileTemplates.tb_dual_swords_heavy_1 = { -- official: light_slashing_linesman_dual_medium
	armor_modifier = {
		attack = {
			0.93, -- official: 1
			0.19, -- official: 0.25
			2,
			1,
			0.5, -- official: 1
		},
		impact = {
			1,
			0.5, -- official: 0.25
			0.5,
			1,
			1,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.08, -- official: 1
			0.13, -- official: 0.5
			2.5,
			1,
			0.6, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.5, -- official: 0.75
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.225, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25, -- official: none
		power_distribution = {
			attack = 0.07, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman", -- official: "light_slashing_linesman_hs"
			boost_curve_type = "linesman_curve", -- official: "ninja_curve"
			boost_curve_coefficient_headshot = 0.33, -- official: 2
			boost_curve_coefficient = 2, -- official: none
			power_distribution = {
				attack = 0.3, -- official: 0.15
				impact = 0.275, -- official: 0.125
			},
			-- removed: armor_modifier (official: <table>)
		},
		{
			attack_template = "heavy_slashing_linesman", -- official: "light_slashing_linesman"
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			power_distribution = {
				attack = 0.2, -- official: 0.125
				impact = 0.15, -- official: 0.075
			},
		},
		{ -- official: none
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.125,
				impact = 0.1,
			},
		},
		{ -- official: none
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.075,
			},
		},
	},
	-- removed: melee_boost_override (official: 3.5)
}

-- tb_dual_swords_heavy_2: replaces the existing block
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_left
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_right
NewDamageProfileTemplates.tb_dual_swords_heavy_2 = { -- official: light_slashing_linesman_dual_medium
	armor_modifier = {
		attack = {
			1.35, -- official: 1
			0.19, -- official: 0.25
			2,
			1,
			0.6, -- official: 1
		},
		impact = {
			1,
			0.5, -- official: 0.25
			0.5,
			1,
			1,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.03, -- official: 1
			0.1, -- official: 0.5
			2.5,
			1,
			0.45, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.5, -- official: 0.75
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.225, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25, -- official: none
		power_distribution = {
			attack = 0.07, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman", -- official: "light_slashing_linesman_hs"
			boost_curve_type = "linesman_curve", -- official: "ninja_curve"
			boost_curve_coefficient_headshot = 1, -- official: 2
			boost_curve_coefficient = 2, -- official: none
			power_distribution = {
				attack = 0.3, -- official: 0.15
				impact = 0.275, -- official: 0.125
			},
			-- removed: armor_modifier (official: <table>)
		},
		{
			attack_template = "heavy_slashing_linesman", -- official: "light_slashing_linesman"
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			power_distribution = {
				attack = 0.2, -- official: 0.125
				impact = 0.15, -- official: 0.075
			},
		},
		{ -- official: none
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.125,
				impact = 0.1,
			},
		},
		{ -- official: none
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.075,
			},
		},
	},
	-- removed: melee_boost_override (official: 3.5)
}

-- tb_dual_swords_light_1: replaces the existing block
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_left.damage_profile
NewDamageProfileTemplates.tb_dual_swords_light_1 = { -- official: light_slashing_linesman_dual_swords
	armor_modifier = {
		attack = {
			1.05, -- official: 1.25
			0,
			2,
			1,
			1.17, -- official: 1
		},
		impact = {
			1,
			0.2,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			0.83, -- official: 1.25
			0.5, -- official: 0.3
			2, -- official: 2.5
			1,
			0.95, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.25,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.3, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.08, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.65, -- official: 1.5
			boost_curve_coefficient = 1, -- official: none
			power_distribution = {
				attack = 0.2, -- official: 0.135
				impact = 0.1, -- official: 0.075
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 0.75, -- official: 1
			power_distribution = {
				attack = 0.16, -- official: 0.09
				impact = 0.084, -- official: 0.05
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.85,
			power_distribution = {
				attack = 0.12,
				impact = 0.067,
			},
		},
	},
}

-- tb_dual_swords_light_2: replaces the existing block
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.tb_dual_swords_light_2 = { -- official: light_slashing_linesman_dual_swords
	armor_modifier = {
		attack = {
			1.2, -- official: 1.25
			0,
			2.1, -- official: 2
			1,
			1.37, -- official: 1
		},
		impact = {
			1,
			0.2,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			0.905, -- official: 1.25
			0.5, -- official: 0.3
			2.1, -- official: 2.5
			1,
			1.1, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.25,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.347, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.65, -- official: 1.5
			boost_curve_coefficient = 1, -- official: none
			power_distribution = {
				attack = 0.2, -- official: 0.135
				impact = 0.1, -- official: 0.075
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 0.75, -- official: 1
			power_distribution = {
				attack = 0.175, -- official: 0.09
				impact = 0.088, -- official: 0.05
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.85,
			power_distribution = {
				attack = 0.125,
				impact = 0.075,
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.95,
			power_distribution = {
				attack = 0.1,
				impact = 0.063,
			},
		},
	},
}

-- tb_dual_swords_light_3: replaces the existing block
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_up_left.damage_profile
NewDamageProfileTemplates.tb_dual_swords_light_3 = { -- official: light_slashing_linesman_dual_swords
	armor_modifier = {
		attack = {
			1.33, -- official: 1.25
			0,
			2.2, -- official: 2
			1,
			1.6, -- official: 1
		},
		impact = {
			1,
			0.2,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.07, -- official: 1.25
			0.3,
			2.3, -- official: 2.5
			1,
			1.3, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.25,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.407, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.1, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.6, -- official: 1.5
			power_distribution = {
				attack = 0.2, -- official: 0.135
				impact = 0.1, -- official: 0.075
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.65, -- official: 1
			power_distribution = {
				attack = 0.18, -- official: 0.09
				impact = 0.09, -- official: 0.05
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.7,
			power_distribution = {
				attack = 0.16,
				impact = 0.08,
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			power_distribution = {
				attack = 0.14,
				impact = 0.07,
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.8,
			power_distribution = {
				attack = 0.12,
				impact = 0.06,
			},
		},
	},
}

-- tb_dual_swords_light_4: replaces the existing block
-- used by Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_up_right.damage_profile
NewDamageProfileTemplates.tb_dual_swords_light_4 = { -- official: light_slashing_linesman_dual_swords
	armor_modifier = {
		attack = {
			1.6, -- official: 1.25
			0,
			2.64, -- official: 2
			1,
			1.9, -- official: 1
		},
		impact = {
			1,
			0.2,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.33, -- official: 1.25
			0.3,
			2.5,
			1,
			1.58, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.25,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.407, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 0.55, -- official: 1.5
			power_distribution = {
				attack = 0.2, -- official: 0.135
				impact = 0.1, -- official: 0.075
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.65, -- official: 1
			power_distribution = {
				attack = 0.185, -- official: 0.09
				impact = 0.09, -- official: 0.05
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			power_distribution = {
				attack = 0.17,
				impact = 0.08,
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.85,
			power_distribution = {
				attack = 0.165,
				impact = 0.07,
			},
		},
		{ -- official: none
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.95,
			power_distribution = {
				attack = 0.14,
				impact = 0.06,
			},
		},
	},
}

-- ======== es_deus_01_template ========

--[[
	$BEGIN_TB
		## es_deus_01_template

		* action_one.heavy_attack_right: Changed damage_profile to medium_slashing_smiter_es_01 (from medium_slashing_tank_es_01)
		* action_one.light_attack_right: Added hit_mass_count: <table>

	$END_TB
]]

Weapons.es_deus_01_template.actions.action_one.heavy_attack_right.damage_profile = "medium_slashing_smiter_es_01" -- official: "medium_slashing_tank_es_01"
Weapons.es_deus_01_template.actions.action_one.light_attack_right.hit_mass_count = { -- official: none
	beastmen_bestigor = 0.5,
	beastmen_gor = 0.5,
	beastmen_ungor = 0.75,
	chaos_berzerker = 0.5,
	chaos_fanatic = 0.75,
	chaos_marauder = 0.5,
	chaos_marauder_with_shield = 0.5,
	chaos_raider = 0.5,
	chaos_warrior = 1e+01,
	skaven_clan_rat = 0.5,
	skaven_clan_rat_with_shield = 0.5,
	skaven_slave = 0.75,
	skaven_storm_vermin = 0.5,
	skaven_storm_vermin_commander = 0.5,
	skaven_storm_vermin_with_shield = 0.5,
}

-- ======== markus_questingknight_career_skill_weapon ========

--[[
	$BEGIN_TB
		## markus_questingknight_career_skill_weapon

		* action_career_release.default_tank: Added hit_mass_count.skaven_plague_monk: 0.6
		* action_career_release.default_tank: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_career_release.default_tank: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_career_release.default_tank: Changed unlimited_cleave to false (from true)
		* action_career_release.default_tank: Increased hit_mass_count.beastmen_bestigor to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.beastmen_gor to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.chaos_berzerker to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.chaos_marauder to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.chaos_marauder_with_shield to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.chaos_raider to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.skaven_clan_rat to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Increased hit_mass_count.skaven_clan_rat_with_shield to 0.6 (from 0.5, +20%)
		* action_career_release.default_tank: Reduced cleave_distribution.attack to 0.5 (from 1e+02, -100%)
		* action_career_release.default_tank: Reduced damage_window_start to 0.05 (from 0.15, -67%)
		* action_career_release.default_tank: Reduced hit_mass_count.beastmen_ungor to 0.6 (from 0.75, -20%)
		* action_career_release.default_tank: Reduced hit_mass_count.chaos_fanatic to 0.6 (from 0.75, -20%)
		* action_career_release.default_tank: Reduced hit_mass_count.chaos_warrior to 0.5 (from 1e+01, -95%)
		* action_career_release.default_tank: Reduced hit_mass_count.skaven_slave to 0.6 (from 0.75, -20%)
		* action_career_release.default_tank: Removed hit_mass_count.skaven_storm_vermin_with_shield (was 0.5)

	$END_TB
]]

Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.damage_window_start = 0.05 -- official: 0.15
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.beastmen_bestigor = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.beastmen_gor = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.beastmen_ungor = 0.6 -- official: 0.75
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.chaos_berzerker = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.chaos_fanatic = 0.6 -- official: 0.75
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.chaos_marauder = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.chaos_marauder_with_shield = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.chaos_raider = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.chaos_warrior = 0.5 -- official: 1e+01
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_clan_rat = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_clan_rat_with_shield = 0.6 -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_plague_monk = 0.6 -- official: none
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_slave = 0.6 -- official: 0.75
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_storm_vermin_with_shield = nil -- official: 0.5
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.unlimited_cleave = false -- official: true

-- questing_knight_career_sword_tank (official profile, changed in place)
DamageProfileTemplates.questing_knight_career_sword_tank.cleave_distribution.attack = 0.5 -- official: 1e+02

-- ======== one_hand_axe_shield_template_1 ========

--[[
	$BEGIN_TB
		## one_hand_axe_shield_template_1

		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_hand_axe_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- shield_slam (official profile, changed in place)
DamageProfileTemplates.shield_slam.critical_strike.impact_armor_power_modifer[5] = 1.5 -- official: 1

-- shield_slam_target (official profile, changed in place)
DamageProfileTemplates.shield_slam_target.critical_strike.impact_armor_power_modifer[5] = 2 -- official: 1

-- ======== one_hand_axe_template_1 ========

--[[
	$BEGIN_TB
		## one_hand_axe_template_1

		* action_one.heavy_attack_left: Added range_mod: 1.2
		* action_one.heavy_attack_left: Changed damage_profile to heavy_1h_axe_tb (from axe_1h_heavy_smiter_vertical)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[6] to 1.3 (from 1.1, +18%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[2] to 0.8 (from 0.95, -16%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[3] to 2 (from 2.5, -20%)
		* action_one.heavy_attack_left: Reduced armor_modifier.impact[2] to 0.8 (from 0.95, -16%)
		* action_one.heavy_attack_right: Added range_mod: 1.2
		* action_one.heavy_attack_right: Changed damage_profile to heavy_1h_axe_tb (from axe_1h_heavy_smiter_vertical)
		* action_one.heavy_attack_right: Increased armor_modifier.attack[6] to 1.3 (from 1.1, +18%)
		* action_one.heavy_attack_right: Reduced armor_modifier.attack[2] to 0.8 (from 0.95, -16%)
		* action_one.heavy_attack_right: Reduced armor_modifier.attack[3] to 2 (from 2.5, -20%)
		* action_one.heavy_attack_right: Reduced armor_modifier.impact[2] to 0.8 (from 0.95, -16%)
		* action_one.light_attack_bopp: Changed damage_profile to light_1h_axe_tb (from axe_1h_light_smiter_vertical)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased default_target.boost_curve_coefficient_headshot to 2 (from 1.75, +14%)
		* action_one.light_attack_bopp: Reduced armor_modifier.attack[2] to 0.45 (from 0.65, -31%)
		* action_one.light_attack_bopp: Reduced armor_modifier.attack[3] to 2.1 (from 2.5, -16%)
		* action_one.light_attack_bopp: Reduced armor_modifier.attack[6] to 0.45 (from 0.6, -25%)
		* action_one.light_attack_bopp: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_bopp: Reduced default_target.power_distribution.attack to 0.25 (from 0.3, -17%)
		* action_one.light_attack_last: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_last: Added armor_modifier.impact[6]: 0.25
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_last: Changed damage_profile to light_1h_axe_tb_last (from axe_1h_light_smiter_horizontal)
		* action_one.light_attack_last: Increased anim_time_scale to 1.3 (from 1.035, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_last: Increased armor_modifier.attack[3] to 2.1 (from 1, +110%)
		* action_one.light_attack_last: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_last: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_last: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_last: Increased default_target.power_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_last: Increased default_target.power_distribution.impact to 0.175 (from 0.075, +133%)
		* action_one.light_attack_last: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.attack[1] to 1 (from 1.25, -20%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.attack[2] to 0.25 (from 0.45, -44%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.attack[3] to 1 (from 2, -50%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.impact[1] to 0.75 (from 0.9, -17%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.impact[2] to 0.25 (from 0.4, -38%)
		* action_one.light_attack_last: Reduced targets[2].power_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_last: Reduced targets[2].power_distribution.impact to 0.075 (from 0.125, -40%)
		* action_one.light_attack_last: Removed targets[1] (was <table>)
		* action_one.light_attack_left: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_left: Added armor_modifier.impact[6]: 0.25
		* action_one.light_attack_left: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Changed damage_profile to light_1h_axe_tb_left_right (from axe_1h_light_smiter_diag)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_left: Increased armor_modifier.attack[3] to 2.1 (from 1, +110%)
		* action_one.light_attack_left: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_left: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_left: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_left: Increased default_target.power_distribution.impact to 0.175 (from 0.075, +133%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.attack[1] to 1 (from 1.25, -20%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.attack[2] to 0.25 (from 0.45, -44%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.attack[3] to 1 (from 2, -50%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.impact[1] to 0.75 (from 0.9, -17%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.impact[2] to 0.25 (from 0.4, -38%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.impact to 0.075 (from 0.125, -40%)
		* action_one.light_attack_left: Removed targets[1] (was <table>)
		* action_one.light_attack_right: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_right: Added armor_modifier.impact[6]: 0.25
		* action_one.light_attack_right: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to light_1h_axe_tb_left_right (from axe_1h_light_smiter_diag)
		* action_one.light_attack_right: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_right: Increased armor_modifier.attack[3] to 2.1 (from 1, +110%)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_right: Increased default_target.power_distribution.impact to 0.175 (from 0.075, +133%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.attack[1] to 1 (from 1.25, -20%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.attack[2] to 0.25 (from 0.45, -44%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.attack[3] to 1 (from 2, -50%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.impact[1] to 0.75 (from 0.9, -17%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.impact[2] to 0.25 (from 0.4, -38%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.impact to 0.075 (from 0.125, -40%)
		* action_one.light_attack_right: Removed targets[1] (was <table>)

	$END_TB
]]

Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_axe_tb" -- official: "axe_1h_heavy_smiter_vertical"
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 -- official: none
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.damage_profile = "heavy_1h_axe_tb" -- official: "axe_1h_heavy_smiter_vertical"
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 -- official: none
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_bopp.damage_profile = "light_1h_axe_tb" -- official: "axe_1h_light_smiter_vertical"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.anim_time_scale = 1.3 -- official: 1.035
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.damage_profile = "light_1h_axe_tb_last" -- official: "axe_1h_light_smiter_horizontal"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_left.damage_profile = "light_1h_axe_tb_left_right" -- official: "axe_1h_light_smiter_diag"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_right.damage_profile = "light_1h_axe_tb_left_right" -- official: "axe_1h_light_smiter_diag"

-- heavy_1h_axe_tb: replaces the existing block
-- used by Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.damage_profile
-- used by Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.damage_profile
NewDamageProfileTemplates.heavy_1h_axe_tb = { -- official: axe_1h_heavy_smiter_vertical
	armor_modifier = {
		attack = {
			1,
			0.8, -- official: 0.95
			2, -- official: 2.5
			1,
			0.75,
			1.3, -- official: 1.1
		},
		impact = {
			1,
			0.8, -- official: 0.95
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_blunt_smiter_2h_hammer_H",
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = "default_target_slashing_smiter_finesse",
	targets = "targets_smiter_M",
}

-- light_1h_axe_tb: replaces the existing block
-- used by Weapons.one_hand_axe_template_1.actions.action_one.light_attack_bopp.damage_profile
-- used by Weapons.one_hand_axe_template_2.actions.action_one.light_attack_bopp.damage_profile
NewDamageProfileTemplates.light_1h_axe_tb = { -- official: axe_1h_light_smiter_vertical
	armor_modifier = {
		attack = {
			1.25,
			0.45, -- official: 0.65
			2.1, -- official: 2.5
			1,
			1, -- official: 0.75
			0.45, -- official: 0.6
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.45, -- official: 0.75
			2.75,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	ignore_stagger_reduction = true,
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 2, -- official: 1.75
		power_distribution = {
			attack = 0.25, -- official: 0.3
			impact = 0.175,
		},
	},
	targets = {
		[2] = {
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			armor_modifier = {
				attack = {
					1,
					0.25,
					1,
					1,
					0.75,
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.075,
				impact = 0.075,
			},
		},
	},
}

-- light_1h_axe_tb_last: replaces the existing block
-- used by Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.damage_profile
-- used by Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.damage_profile
NewDamageProfileTemplates.light_1h_axe_tb_last = { -- official: axe_1h_light_smiter_horizontal
	armor_modifier = {
		attack = {
			1.25, -- official: 1
			0.45, -- official: 0.25
			2.1, -- official: 1
			1,
			1, -- official: 0.75
			0.45, -- official: none
		},
		impact = {
			1, -- official: 0.75
			0.5, -- official: 0.25
			1,
			1,
			0.75,
			0.25, -- official: none
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.45, -- official: 0.75
			2.75,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.3,
		impact = 0.3,
	},
	ignore_stagger_reduction = true,
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 2, -- official: none
		power_distribution = {
			attack = 0.25, -- official: 0.075
			impact = 0.175, -- official: 0.075
		},
	},
	targets = {
		[2] = {
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			armor_modifier = {
				attack = {
					1, -- official: 1.25
					0.25, -- official: 0.45
					1, -- official: 2
					1,
					0.75,
				},
				impact = {
					0.75, -- official: 0.9
					0.25, -- official: 0.4
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.075, -- official: 0.15
				impact = 0.075, -- official: 0.125
			},
		},
		-- removed: [1] (official: <table>)
	},
}

-- light_1h_axe_tb_left_right: replaces the existing block
-- used by Weapons.one_hand_axe_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.one_hand_axe_template_1.actions.action_one.light_attack_right.damage_profile
-- used by Weapons.one_hand_axe_template_2.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.one_hand_axe_template_2.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.light_1h_axe_tb_left_right = { -- official: axe_1h_light_smiter_diag
	armor_modifier = {
		attack = {
			1.25, -- official: 1
			0.45, -- official: 0.25
			2.1, -- official: 1
			1,
			1, -- official: 0.75
			0.45, -- official: none
		},
		impact = {
			1, -- official: 0.75
			0.5, -- official: 0.25
			1,
			1,
			0.75,
			0.25, -- official: none
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.45, -- official: 0.75
			2.75,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.15,
		impact = 0.15,
	},
	ignore_stagger_reduction = true,
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 2, -- official: none
		power_distribution = {
			attack = 0.25, -- official: 0.075
			impact = 0.175, -- official: 0.075
		},
	},
	targets = {
		[2] = {
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			armor_modifier = {
				attack = {
					1, -- official: 1.25
					0.25, -- official: 0.45
					1, -- official: 2
					1,
					0.75,
				},
				impact = {
					0.75, -- official: 0.9
					0.25, -- official: 0.4
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.075, -- official: 0.15
				impact = 0.075, -- official: 0.125
			},
		},
		-- removed: [1] (official: <table>)
	},
}

-- ======== one_hand_axe_template_2 ========

--[[
	$BEGIN_TB
		## one_hand_axe_template_2

		* action_one.heavy_attack_left: Added range_mod: 1.2
		* action_one.heavy_attack_left: Changed damage_profile to heavy_1h_axe_tb (from axe_1h_heavy_smiter_vertical)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[6] to 1.3 (from 1.1, +18%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[2] to 0.8 (from 0.95, -16%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[3] to 2 (from 2.5, -20%)
		* action_one.heavy_attack_left: Reduced armor_modifier.impact[2] to 0.8 (from 0.95, -16%)
		* action_one.heavy_attack_right: Added range_mod: 1.2
		* action_one.heavy_attack_right: Changed damage_profile to heavy_1h_axe_tb (from axe_1h_heavy_smiter_vertical)
		* action_one.heavy_attack_right: Increased armor_modifier.attack[6] to 1.3 (from 1.1, +18%)
		* action_one.heavy_attack_right: Reduced armor_modifier.attack[2] to 0.8 (from 0.95, -16%)
		* action_one.heavy_attack_right: Reduced armor_modifier.attack[3] to 2 (from 2.5, -20%)
		* action_one.heavy_attack_right: Reduced armor_modifier.impact[2] to 0.8 (from 0.95, -16%)
		* action_one.light_attack_bopp: Changed damage_profile to light_1h_axe_tb (from axe_1h_light_smiter_vertical)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased default_target.boost_curve_coefficient_headshot to 2 (from 1.75, +14%)
		* action_one.light_attack_bopp: Reduced armor_modifier.attack[2] to 0.45 (from 0.65, -31%)
		* action_one.light_attack_bopp: Reduced armor_modifier.attack[3] to 2.1 (from 2.5, -16%)
		* action_one.light_attack_bopp: Reduced armor_modifier.attack[6] to 0.45 (from 0.6, -25%)
		* action_one.light_attack_bopp: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_bopp: Reduced default_target.power_distribution.attack to 0.25 (from 0.3, -17%)
		* action_one.light_attack_last: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_last: Added armor_modifier.impact[6]: 0.25
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_last: Changed damage_profile to light_1h_axe_tb_last (from axe_1h_light_smiter_horizontal)
		* action_one.light_attack_last: Increased anim_time_scale to 1.3 (from 1.035, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_last: Increased armor_modifier.attack[3] to 2.1 (from 1, +110%)
		* action_one.light_attack_last: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_last: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_last: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_last: Increased default_target.power_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_last: Increased default_target.power_distribution.impact to 0.175 (from 0.075, +133%)
		* action_one.light_attack_last: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.attack[1] to 1 (from 1.25, -20%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.attack[2] to 0.25 (from 0.45, -44%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.attack[3] to 1 (from 2, -50%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.impact[1] to 0.75 (from 0.9, -17%)
		* action_one.light_attack_last: Reduced targets[2].armor_modifier.impact[2] to 0.25 (from 0.4, -38%)
		* action_one.light_attack_last: Reduced targets[2].power_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_last: Reduced targets[2].power_distribution.impact to 0.075 (from 0.125, -40%)
		* action_one.light_attack_last: Removed targets[1] (was <table>)
		* action_one.light_attack_left: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_left: Added armor_modifier.impact[6]: 0.25
		* action_one.light_attack_left: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Changed damage_profile to light_1h_axe_tb_left_right (from axe_1h_light_smiter_diag)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_left: Increased armor_modifier.attack[3] to 2.1 (from 1, +110%)
		* action_one.light_attack_left: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_left: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_left: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_left: Increased default_target.power_distribution.impact to 0.175 (from 0.075, +133%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.attack[1] to 1 (from 1.25, -20%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.attack[2] to 0.25 (from 0.45, -44%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.attack[3] to 1 (from 2, -50%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.impact[1] to 0.75 (from 0.9, -17%)
		* action_one.light_attack_left: Reduced targets[2].armor_modifier.impact[2] to 0.25 (from 0.4, -38%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.impact to 0.075 (from 0.125, -40%)
		* action_one.light_attack_left: Removed targets[1] (was <table>)
		* action_one.light_attack_right: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_right: Added armor_modifier.impact[6]: 0.25
		* action_one.light_attack_right: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to light_1h_axe_tb_left_right (from axe_1h_light_smiter_diag)
		* action_one.light_attack_right: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_right: Increased armor_modifier.attack[3] to 2.1 (from 1, +110%)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_right: Increased default_target.power_distribution.impact to 0.175 (from 0.075, +133%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.75, -40%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.attack[1] to 1 (from 1.25, -20%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.attack[2] to 0.25 (from 0.45, -44%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.attack[3] to 1 (from 2, -50%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.impact[1] to 0.75 (from 0.9, -17%)
		* action_one.light_attack_right: Reduced targets[2].armor_modifier.impact[2] to 0.25 (from 0.4, -38%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.impact to 0.075 (from 0.125, -40%)
		* action_one.light_attack_right: Removed targets[1] (was <table>)

	$END_TB
]]

Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_axe_tb" -- official: "axe_1h_heavy_smiter_vertical"
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 -- official: none
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.damage_profile = "heavy_1h_axe_tb" -- official: "axe_1h_heavy_smiter_vertical"
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 -- official: none
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_bopp.damage_profile = "light_1h_axe_tb" -- official: "axe_1h_light_smiter_vertical"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.anim_time_scale = 1.3 -- official: 1.035
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.damage_profile = "light_1h_axe_tb_last" -- official: "axe_1h_light_smiter_horizontal"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_left.damage_profile = "light_1h_axe_tb_left_right" -- official: "axe_1h_light_smiter_diag"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_right.damage_profile = "light_1h_axe_tb_left_right" -- official: "axe_1h_light_smiter_diag"

-- uses heavy_1h_axe_tb (exported under one_hand_axe_template_1)

-- uses light_1h_axe_tb (exported under one_hand_axe_template_1)

-- uses light_1h_axe_tb_last (exported under one_hand_axe_template_1)

-- uses light_1h_axe_tb_left_right (exported under one_hand_axe_template_1)

-- ======== one_hand_falchion_template_1 ========

--[[
	$BEGIN_TB
		## one_hand_falchion_template_1

		* action_one.light_attack_bopp: Added targets[1].boost_curve_coefficient: 2
		* action_one.light_attack_bopp: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_bopp: Changed damage_profile to tb_falchion_lights (from light_slashing_axe_linesman_upper)
		* action_one.light_attack_bopp: Changed default_target.attack_template to light_slashing_linesman (from slashing_upper)
		* action_one.light_attack_bopp: Changed targets[1].attack_template to light_slashing_linesman_hs (from slashing_upper)
		* action_one.light_attack_bopp: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_bopp: Changed targets[2].attack_template to light_slashing_linesman (from slashing_upper)
		* action_one.light_attack_bopp: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 0.2 (from 0)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[2] to 0.3 (from 0.25, +20%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased cleave_distribution.attack to 0.3 (from 0.25, +20%)
		* action_one.light_attack_bopp: Increased critical_strike.attack_armor_power_modifer[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_bopp: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_bopp: Increased targets[1].power_distribution.attack to 0.2 (from 0.195, +3%)
		* action_one.light_attack_bopp: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_bopp: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_bopp: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 1, -50%)
		* action_one.light_attack_bopp: Reduced critical_strike.impact_armor_power_modifer[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_bopp: Reduced default_target.power_distribution.impact to 0.05 (from 0.075, -33%)
		* action_one.light_attack_bopp: Reduced targets[1].power_distribution.impact to 0.1 (from 0.125, -20%)
		* action_one.light_attack_bopp: Reduced targets[2].power_distribution.impact to 0.075 (from 0.1, -25%)
		* action_one.light_attack_bopp: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_bopp: Removed targets[3] (was <table>)
		* action_one.light_attack_left: Added targets[1].boost_curve_coefficient: 2
		* action_one.light_attack_left: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Changed damage_profile to tb_falchion_lights (from light_slashing_axe_linesman)
		* action_one.light_attack_left: Changed default_target.attack_template to light_slashing_linesman (from slashing_upper)
		* action_one.light_attack_left: Changed targets[1].attack_template to light_slashing_linesman_hs (from slashing_upper)
		* action_one.light_attack_left: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Changed targets[2].attack_template to light_slashing_linesman (from slashing_upper)
		* action_one.light_attack_left: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.2 (from 0)
		* action_one.light_attack_left: Increased armor_modifier.attack[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_left: Increased armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_left: Increased armor_modifier.impact[2] to 0.3 (from 0.25, +20%)
		* action_one.light_attack_left: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.3 (from 0.25, +20%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.2 (from 0.195, +3%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_left: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_left: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 1, -50%)
		* action_one.light_attack_left: Reduced critical_strike.impact_armor_power_modifer[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_left: Reduced default_target.power_distribution.impact to 0.05 (from 0.075, -33%)
		* action_one.light_attack_left: Reduced targets[1].power_distribution.impact to 0.1 (from 0.125, -20%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.impact to 0.075 (from 0.1, -25%)
		* action_one.light_attack_left: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_left: Removed targets[3] (was <table>)
		* action_one.light_attack_right: Added targets[1].boost_curve_coefficient: 2
		* action_one.light_attack_right: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to tb_falchion_lights (from light_slashing_axe_linesman)
		* action_one.light_attack_right: Changed default_target.attack_template to light_slashing_linesman (from slashing_upper)
		* action_one.light_attack_right: Changed targets[1].attack_template to light_slashing_linesman_hs (from slashing_upper)
		* action_one.light_attack_right: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Changed targets[2].attack_template to light_slashing_linesman (from slashing_upper)
		* action_one.light_attack_right: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Increased armor_modifier.attack[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.2 (from 0)
		* action_one.light_attack_right: Increased armor_modifier.attack[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_right: Increased armor_modifier.impact[2] to 0.3 (from 0.25, +20%)
		* action_one.light_attack_right: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.3 (from 0.25, +20%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[3] to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.2 (from 0.195, +3%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_right: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_right: Reduced critical_strike.impact_armor_power_modifer[2] to 0.5 (from 1, -50%)
		* action_one.light_attack_right: Reduced critical_strike.impact_armor_power_modifer[3] to 0.5 (from 1, -50%)
		* action_one.light_attack_right: Reduced default_target.power_distribution.impact to 0.05 (from 0.075, -33%)
		* action_one.light_attack_right: Reduced targets[1].power_distribution.impact to 0.1 (from 0.125, -20%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.impact to 0.075 (from 0.1, -25%)
		* action_one.light_attack_right: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_right: Removed targets[3] (was <table>)

	$END_TB
]]

Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_falchion_lights" -- official: "light_slashing_axe_linesman_upper"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_left.damage_profile = "tb_falchion_lights" -- official: "light_slashing_axe_linesman"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_right.damage_profile = "tb_falchion_lights" -- official: "light_slashing_axe_linesman"

-- tb_falchion_lights: replaces the existing block
-- used by Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_bopp.damage_profile
-- used by Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.tb_falchion_lights = { -- official: light_slashing_axe_linesman (comments compare against it; also replaces light_slashing_axe_linesman_upper)
	armor_modifier = {
		attack = {
			1, -- official: 0.9
			0.2, -- official: 0
			2, -- official: 1.5
			1,
			1, -- official: 0.75
		},
		impact = {
			1, -- official: 0.9
			0.3, -- official: 0.25
			0.5, -- official: 1
			1,
			1, -- official: 0.75
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2, -- official: 1.5
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5, -- official: 1
			0.5, -- official: 1
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.3, -- official: 0.25
		impact = 0.2,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05, -- official: 0.075
		},
	},
	targets = {
		{
			attack_template = "light_slashing_linesman_hs", -- official: "slashing_linesman"
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 2, -- official: none
			power_distribution = {
				attack = 0.2, -- official: 0.195
				impact = 0.1, -- official: 0.125
			},
			-- removed: armor_modifier (official: <table>)
		},
		{
			attack_template = "light_slashing_linesman", -- official: "slashing_linesman"
			boost_curve_type = "ninja_curve", -- official: "linesman_curve"
			boost_curve_coefficient_headshot = 2, -- official: none
			power_distribution = {
				attack = 0.15, -- official: 0.125
				impact = 0.075, -- official: 0.1
			},
		},
		-- removed: [3] (official: <table>)
	},
}

-- ======== one_handed_crowbill ========

--[[
	$BEGIN_TB
		## one_handed_crowbill

		* action_one.heavy_attack: Added critical_strike.attack_armor_power_modifer[6]: 1
		* action_one.heavy_attack: Added critical_strike.impact_armor_power_modifer[6]: 0.5
		* action_one.heavy_attack: Added default_target.boost_curve_coefficient: 1
		* action_one.heavy_attack: Added targets[2].boost_curve_coefficient: 2
		* action_one.heavy_attack: Added targets[3]: <table>
		* action_one.heavy_attack: Added targets[4]: <table>
		* action_one.heavy_attack: Changed damage_profile to crowbill_heavy_1 (from crowbill_1h_heavy_smiter)
		* action_one.heavy_attack: Changed targets[2].attack_template to slashing_smiter (from light_blunt_tank)
		* action_one.heavy_attack: Changed targets[2].boost_curve_type to smiter_curve (from tank_curve)
		* action_one.heavy_attack: Increased armor_modifier.attack[1] to 1.66 (from 1, +66%)
		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 1.2 (from 0.9, +33%)
		* action_one.heavy_attack: Increased armor_modifier.attack[6] to 1.2 (from 0.9, +33%)
		* action_one.heavy_attack: Increased critical_strike.attack_armor_power_modifer[1] to 1.25 (from 1, +25%)
		* action_one.heavy_attack: Increased targets[1].power_distribution.attack to 0.4 (from 0.35, +14%)
		* action_one.heavy_attack: Increased targets[2].power_distribution.attack to 0.325 (from 0.2, +63%)
		* action_one.heavy_attack: Increased targets[2].power_distribution.impact to 0.21 (from 0.15, +40%)
		* action_one.heavy_attack: Reduced cleave_distribution.attack to 0.075 (from 0.3, -75%)
		* action_one.heavy_attack: Reduced cleave_distribution.impact to 0.075 (from 0.3, -75%)
		* action_one.heavy_attack: Reduced critical_strike.attack_armor_power_modifer[2] to 0.93 (from 1, -7%)
		* action_one.heavy_attack: Reduced critical_strike.impact_armor_power_modifer[2] to 0.8 (from 1, -20%)
		* action_one.heavy_attack_left: Added critical_strike.attack_armor_power_modifer[6]: 1
		* action_one.heavy_attack_left: Added critical_strike.impact_armor_power_modifer[6]: 1
		* action_one.heavy_attack_left: Added default_target.boost_curve_coefficient: 1
		* action_one.heavy_attack_left: Added targets[2].boost_curve_coefficient: 2
		* action_one.heavy_attack_left: Added targets[3]: <table>
		* action_one.heavy_attack_left: Added targets[4]: <table>
		* action_one.heavy_attack_left: Added targets[5]: <table>
		* action_one.heavy_attack_left: Changed damage_profile to crowbill_heavy_2 (from crowbill_1h_heavy_smiter)
		* action_one.heavy_attack_left: Changed targets[2].attack_template to slashing_smiter (from light_blunt_tank)
		* action_one.heavy_attack_left: Changed targets[2].boost_curve_type to smiter_curve (from tank_curve)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[1] to 1.3 (from 1, +30%)
		* action_one.heavy_attack_left: Increased targets[1].power_distribution.attack to 0.4 (from 0.35, +14%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.attack to 0.34 (from 0.2, +70%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.impact to 0.22 (from 0.15, +47%)
		* action_one.heavy_attack_left: Reduced cleave_distribution.attack to 0.075 (from 0.3, -75%)
		* action_one.heavy_attack_left: Reduced cleave_distribution.impact to 0.075 (from 0.3, -75%)
		* action_one.heavy_attack_left: Reduced critical_strike.attack_armor_power_modifer[2] to 0.77 (from 1, -23%)
		* action_one.heavy_attack_left: Reduced critical_strike.attack_armor_power_modifer[3] to 2 (from 2.5, -20%)
		* action_one.heavy_attack_left: Reduced critical_strike.attack_armor_power_modifer[5] to 0.83 (from 1, -17%)
		* action_one.heavy_attack_right_up: Added armor_modifier.impact[6]: 1
		* action_one.heavy_attack_right_up: Added critical_strike.attack_armor_power_modifer[6]: 0.8
		* action_one.heavy_attack_right_up: Added targets[1]: <table>
		* action_one.heavy_attack_right_up: Added targets[2].boost_curve_coefficient: 2
		* action_one.heavy_attack_right_up: Added targets[2].boost_curve_coefficient_headshot: 1.75
		* action_one.heavy_attack_right_up: Added targets[3]: <table>
		* action_one.heavy_attack_right_up: Added targets[4]: <table>
		* action_one.heavy_attack_right_up: Changed damage_profile to crowbill_heavy_3 (from crowbill_1h_heavy_smiter_diag)
		* action_one.heavy_attack_right_up: Changed default_target.attack_template to light_blunt_tank (from slashing_smiter)
		* action_one.heavy_attack_right_up: Changed default_target.boost_curve_type to tank_curve (from smiter_curve)
		* action_one.heavy_attack_right_up: Changed targets[2].attack_template to blunt_linesman (from light_blunt_tank)
		* action_one.heavy_attack_right_up: Changed targets[2].boost_curve_type to smiter_curve (from tank_curve)
		* action_one.heavy_attack_right_up: Increased armor_modifier.attack[5] to 0.83 (from 0.75, +11%)
		* action_one.heavy_attack_right_up: Increased targets[2].power_distribution.attack to 0.325 (from 0.1, +225%)
		* action_one.heavy_attack_right_up: Increased targets[2].power_distribution.impact to 0.21 (from 0.1, +110%)
		* action_one.heavy_attack_right_up: Reduced critical_strike.attack_armor_power_modifer[2] to 0.73 (from 0.8, -9%)
		* action_one.heavy_attack_right_up: Reduced critical_strike.attack_armor_power_modifer[3] to 1.75 (from 2.5, -30%)
		* action_one.heavy_attack_right_up: Reduced default_target.power_distribution.attack to 0.1 (from 0.4, -75%)
		* action_one.heavy_attack_right_up: Reduced default_target.power_distribution.impact to 0.1 (from 0.25, -60%)
		* action_one.heavy_attack_right_up: Removed default_target.boost_curve_coefficient (was 2)
		* action_one.heavy_attack_right_up: Removed default_target.boost_curve_coefficient_headshot (was 1.5)
		* action_one.light_attack_bopp: Added additional_critical_strike_chance: 0.05
		* action_one.light_attack_bopp: Added armor_modifier.attack[6]: 0.5
		* action_one.light_attack_bopp: Added armor_modifier.impact[6]: 0.5
		* action_one.light_attack_bopp: Added targets[1].boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_bopp: Added targets[2].boost_curve_coefficient_headshot: 1.375
		* action_one.light_attack_bopp: Added targets[3]: <table>
		* action_one.light_attack_bopp: Added targets[4]: <table>
		* action_one.light_attack_bopp: Changed damage_profile to crowbill_push_attack (from crowbill_1h_light_smiter_upper)
		* action_one.light_attack_bopp: Changed default_target.attack_template to slashing_smiter (from slashing_upper)
		* action_one.light_attack_bopp: Changed targets[1].attack_template to blunt_tank_uppercut (from slashing_upper)
		* action_one.light_attack_bopp: Changed targets[1].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_bopp: Changed targets[2].attack_template to blunt_tank_uppercut (from slashing_upper)
		* action_one.light_attack_bopp: Changed targets[2].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 1 (from 0.25, +300%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[3] to 2 (from 1, +100%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_bopp: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_bopp: Increased targets[2].power_distribution.attack to 0.15 (from 0.1, +50%)
		* action_one.light_attack_bopp: Reduced cleave_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_bopp: Reduced cleave_distribution.impact to 0.075 (from 0.15, -50%)
		* action_one.light_attack_bopp: Reduced targets[2].power_distribution.impact to 0.094 (from 0.1, -6%)
		* action_one.light_attack_bopp: Removed default_target.boost_curve_coefficient_headshot (was 1.5)
		* action_one.light_attack_bopp: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_bopp: Removed targets[2].armor_modifier (was <table>)
		* action_one.light_attack_last: Added critical_strike.attack_armor_power_modifer[6]: 0.9
		* action_one.light_attack_last: Added critical_strike.impact_armor_power_modifer[6]: 1
		* action_one.light_attack_last: Added targets[1]: <table>
		* action_one.light_attack_last: Added targets[2].boost_curve_coefficient_headshot: 1.32
		* action_one.light_attack_last: Added targets[3]: <table>
		* action_one.light_attack_last: Changed damage_profile to crowbill_light_1 (from light_pointy_smiter)
		* action_one.light_attack_last: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.light_attack_last: Changed default_target.boost_curve_type to smiter_curve (from ninja_curve)
		* action_one.light_attack_last: Changed targets[2].attack_template to blunt_linesman (from slashing_smiter)
		* action_one.light_attack_last: Changed targets[2].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_last: Increased armor_modifier.attack[1] to 1.143 (from 1, +14%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.85 (from 0.5, +70%)
		* action_one.light_attack_last: Increased critical_strike.attack_armor_power_modifer[1] to 1.1 (from 1, +10%)
		* action_one.light_attack_last: Increased targets[2].power_distribution.attack to 0.165 (from 0.075, +120%)
		* action_one.light_attack_last: Increased targets[2].power_distribution.impact to 0.091 (from 0.075, +21%)
		* action_one.light_attack_last: Reduced critical_strike.attack_armor_power_modifer[2] to 0.94 (from 1, -6%)
		* action_one.light_attack_last: Reduced critical_strike.attack_armor_power_modifer[3] to 1.8 (from 2, -10%)
		* action_one.light_attack_last: Reduced default_target.power_distribution.attack to 0.075 (from 0.175, -57%)
		* action_one.light_attack_last: Reduced default_target.power_distribution.impact to 0.075 (from 0.1, -25%)
		* action_one.light_attack_last: Removed default_target.boost_curve_coefficient_headshot (was 1.5)
		* action_one.light_attack_last: Removed targets[2].armor_modifier (was <table>)
		* action_one.light_attack_left: Added armor_modifier.attack[6]: 1.25
		* action_one.light_attack_left: Added critical_strike.attack_armor_power_modifer[6]: 1.1
		* action_one.light_attack_left: Added critical_strike.impact_armor_power_modifer[6]: 1
		* action_one.light_attack_left: Added targets[2]: <table>
		* action_one.light_attack_left: Added targets[3]: <table>
		* action_one.light_attack_left: Changed damage_profile to crowbill_light_4 (from light_blunt_smiter_stab_burn)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 1.1 (from 0.5, +120%)
		* action_one.light_attack_left: Increased armor_modifier.attack[3] to 2.2 (from 1.5, +47%)
		* action_one.light_attack_left: Increased armor_modifier.attack[5] to 1.1 (from 0.75, +47%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 1 (from 0.5, +100%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2.5 (from 1.5, +67%)
		* action_one.light_attack_right: Added targets[1].boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_right: Added targets[2].boost_curve_coefficient_headshot: 1.375
		* action_one.light_attack_right: Added targets[3]: <table>
		* action_one.light_attack_right: Added targets[4]: <table>
		* action_one.light_attack_right: Changed damage_profile to crowbill_light_3 (from crowbill_1h_light_smiter_diag)
		* action_one.light_attack_right: Changed targets[1].attack_template to blunt_linesman (from slashing_smiter)
		* action_one.light_attack_right: Changed targets[1].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_right: Changed targets[2].attack_template to blunt_linesman (from slashing_smiter)
		* action_one.light_attack_right: Changed targets[2].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_right: Increased armor_modifier.attack[1] to 1.2 (from 1, +20%)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 1.1 (from 0.25, +340%)
		* action_one.light_attack_right: Increased armor_modifier.attack[3] to 2 (from 1, +100%)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1.1 (from 0.75, +47%)
		* action_one.light_attack_right: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[1] to 1.1 (from 1, +10%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.255 (from 0.175, +46%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.21 (from 0.1, +110%)
		* action_one.light_attack_right: Reduced cleave_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_right: Reduced cleave_distribution.impact to 0.075 (from 0.15, -50%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.impact to 0.094 (from 0.1, -6%)
		* action_one.light_attack_right: Removed default_target.boost_curve_coefficient_headshot (was 1.5)
		* action_one.light_attack_right: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_right: Removed targets[2].armor_modifier (was <table>)
		* action_one.light_attack_upper: Added armor_modifier.attack[6]: 0.85
		* action_one.light_attack_upper: Added armor_modifier.impact[6]: 0.5
		* action_one.light_attack_upper: Added targets[1].boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_upper: Added targets[2].boost_curve_coefficient_headshot: 1.4
		* action_one.light_attack_upper: Added targets[3]: <table>
		* action_one.light_attack_upper: Added targets[4]: <table>
		* action_one.light_attack_upper: Added targets[5]: <table>
		* action_one.light_attack_upper: Changed damage_profile to crowbill_light_2 (from crowbill_1h_light_smiter_flat)
		* action_one.light_attack_upper: Changed default_target.attack_template to slashing_smiter (from blunt_tank)
		* action_one.light_attack_upper: Changed targets[1].attack_template to blunt_linesman (from blunt_tank)
		* action_one.light_attack_upper: Changed targets[1].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_upper: Changed targets[2].attack_template to blunt_linesman (from blunt_tank)
		* action_one.light_attack_upper: Changed targets[2].boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_upper: Increased armor_modifier.attack[1] to 1.14 (from 1, +14%)
		* action_one.light_attack_upper: Increased armor_modifier.attack[2] to 1.06 (from 0.25, +324%)
		* action_one.light_attack_upper: Increased armor_modifier.attack[3] to 2 (from 1, +100%)
		* action_one.light_attack_upper: Increased armor_modifier.attack[5] to 1.05 (from 0.75, +40%)
		* action_one.light_attack_upper: Increased armor_modifier.impact[1] to 1 (from 0.75, +33%)
		* action_one.light_attack_upper: Increased armor_modifier.impact[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_upper: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_upper: Increased targets[1].power_distribution.attack to 0.245 (from 0.175, +40%)
		* action_one.light_attack_upper: Increased targets[2].power_distribution.attack to 0.211 (from 0.1, +111%)
		* action_one.light_attack_upper: Reduced cleave_distribution.attack to 0.075 (from 0.15, -50%)
		* action_one.light_attack_upper: Reduced cleave_distribution.impact to 0.075 (from 0.15, -50%)
		* action_one.light_attack_upper: Reduced critical_strike.attack_armor_power_modifer[2] to 0.94 (from 1, -6%)
		* action_one.light_attack_upper: Reduced critical_strike.attack_armor_power_modifer[5] to 0.97 (from 1, -3%)
		* action_one.light_attack_upper: Reduced targets[2].power_distribution.impact to 0.095 (from 0.1, -5%)
		* action_one.light_attack_upper: Removed default_target.boost_curve_coefficient_headshot (was 1.5)
		* action_one.light_attack_upper: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_upper: Removed targets[2].armor_modifier (was <table>)

	$END_TB
]]

Weapons.one_handed_crowbill.actions.action_one.heavy_attack.damage_profile = "crowbill_heavy_1" -- official: "crowbill_1h_heavy_smiter"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_left.damage_profile = "crowbill_heavy_2" -- official: "crowbill_1h_heavy_smiter"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_right_up.damage_profile = "crowbill_heavy_3" -- official: "crowbill_1h_heavy_smiter_diag"
Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.05 -- official: none
Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.damage_profile = "crowbill_push_attack" -- official: "crowbill_1h_light_smiter_upper"
Weapons.one_handed_crowbill.actions.action_one.light_attack_last.damage_profile = "crowbill_light_1" -- official: "light_pointy_smiter"
Weapons.one_handed_crowbill.actions.action_one.light_attack_left.damage_profile = "crowbill_light_4" -- official: "light_blunt_smiter_stab_burn"
Weapons.one_handed_crowbill.actions.action_one.light_attack_right.damage_profile = "crowbill_light_3" -- official: "crowbill_1h_light_smiter_diag"
Weapons.one_handed_crowbill.actions.action_one.light_attack_upper.damage_profile = "crowbill_light_2" -- official: "crowbill_1h_light_smiter_flat"

-- crowbill_heavy_1: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.heavy_attack.damage_profile
NewDamageProfileTemplates.crowbill_heavy_1 = { -- official: crowbill_1h_heavy_smiter
	armor_modifier = {
		attack = {
			1.66, -- official: 1
			1.2, -- official: 0.9
			2,
			1,
			1,
			1.2, -- official: 0.9
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25, -- official: 1
			0.93, -- official: 1
			2.5,
			1,
			1,
			1, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			0.8, -- official: 1
			1,
			1,
			1,
			0.5, -- official: none
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default", -- official: "crowbill_1h_heavy_smiter_cleave_distribution"
	shield_break = true,
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient = 1, -- official: none
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.4, -- official: 0.35
				impact = 0.25,
			},
		},
		{
			attack_template = "slashing_smiter", -- official: "light_blunt_tank"
			boost_curve_type = "smiter_curve", -- official: "tank_curve"
			boost_curve_coefficient = 2, -- official: none
			power_distribution = {
				attack = 0.325, -- official: 0.2
				impact = 0.21, -- official: 0.15
			},
		},
		{ -- official: none
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.25,
				impact = 0.175,
			},
		},
		{ -- official: none
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.175,
				impact = 0.14,
			},
		},
	},
}

-- crowbill_heavy_2: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.heavy_attack_left.damage_profile
NewDamageProfileTemplates.crowbill_heavy_2 = { -- official: crowbill_1h_heavy_smiter
	armor_modifier = {
		attack = {
			1.3, -- official: 1
			0.9,
			2,
			1,
			1,
			0.9,
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.77, -- official: 1
			2, -- official: 2.5
			1,
			0.83, -- official: 1
			1, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1, -- official: none
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default", -- official: "crowbill_1h_heavy_smiter_cleave_distribution"
	shield_break = true,
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient = 1, -- official: none
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.4, -- official: 0.35
				impact = 0.25,
			},
		},
		{
			attack_template = "slashing_smiter", -- official: "light_blunt_tank"
			boost_curve_type = "smiter_curve", -- official: "tank_curve"
			boost_curve_coefficient = 2, -- official: none
			power_distribution = {
				attack = 0.34, -- official: 0.2
				impact = 0.22, -- official: 0.15
			},
		},
		{ -- official: none
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.28,
				impact = 0.19,
			},
		},
		{ -- official: none
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.22,
				impact = 0.16,
			},
		},
		{ -- official: none
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.16,
				impact = 0.13,
			},
		},
	},
}

-- crowbill_heavy_3: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.heavy_attack_right_up.damage_profile
NewDamageProfileTemplates.crowbill_heavy_3 = { -- official: crowbill_1h_heavy_smiter_diag
	armor_modifier = {
		attack = {
			1,
			0.8,
			1.75,
			1,
			0.83, -- official: 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
			1, -- official: none
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.73, -- official: 0.8
			1.75, -- official: 2.5
			1,
			1,
			0.8, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = {
		attack_template = "light_blunt_tank", -- official: "slashing_smiter"
		boost_curve_type = "tank_curve", -- official: "smiter_curve"
		power_distribution = {
			attack = 0.1, -- official: 0.4
			impact = 0.1, -- official: 0.25
		},
		-- removed: boost_curve_coefficient (official: 2)
		-- removed: boost_curve_coefficient_headshot (official: 1.5)
	},
	targets = {
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "blunt_linesman", -- official: "light_blunt_tank"
			boost_curve_type = "smiter_curve", -- official: "tank_curve"
			boost_curve_coefficient_headshot = 1.75, -- official: none
			boost_curve_coefficient = 2, -- official: none
			power_distribution = {
				attack = 0.325, -- official: 0.1
				impact = 0.21, -- official: 0.1
			},
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.25,
				impact = 0.175,
			},
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "smiter_curve",
			boost_curve_coefficient_headshot = 1.25,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.175,
				impact = 0.14,
			},
		},
	},
}

-- crowbill_light_1: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.light_attack_last.damage_profile
NewDamageProfileTemplates.crowbill_light_1 = { -- official: light_pointy_smiter
	armor_modifier = {
		attack = {
			1.143, -- official: 1
			1,
			2,
			1,
			1,
			0.85, -- official: 0.5
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.1, -- official: 1
			0.94, -- official: 1
			1.8, -- official: 2
			1,
			1,
			0.9, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1, -- official: none
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "slashing_smiter", -- official: "blunt_smiter"
		boost_curve_type = "smiter_curve", -- official: "ninja_curve"
		power_distribution = {
			attack = 0.075, -- official: 0.175
			impact = 0.075, -- official: 0.1
		},
		-- removed: boost_curve_coefficient_headshot (official: 1.5)
	},
	targets = {
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.5,
			power_distribution = {
				attack = 0.21,
				impact = 0.1,
			},
		},
		{
			attack_template = "blunt_linesman", -- official: "slashing_smiter"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.32, -- official: none
			power_distribution = {
				attack = 0.165, -- official: 0.075
				impact = 0.091, -- official: 0.075
			},
			-- removed: armor_modifier (official: <table>)
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.16,
			power_distribution = {
				attack = 0.12,
				impact = 0.082,
			},
		},
	},
}

-- crowbill_light_2: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.light_attack_upper.damage_profile
NewDamageProfileTemplates.crowbill_light_2 = { -- official: crowbill_1h_light_smiter_flat
	armor_modifier = {
		attack = {
			1.14, -- official: 1
			1.06, -- official: 0.25
			2, -- official: 1
			1,
			1.05, -- official: 0.75
			0.85, -- official: none
		},
		impact = {
			1, -- official: 0.75
			0.5, -- official: 0.25
			1,
			1,
			1, -- official: 0.75
			0.5, -- official: none
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.94, -- official: 1
			2,
			1,
			0.97, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default", -- official: "crowbill_1h_light_smiter_flat_cleave_distribution"
	default_target = {
		attack_template = "slashing_smiter", -- official: "blunt_tank"
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
		-- removed: boost_curve_coefficient_headshot (official: 1.5)
	},
	targets = {
		{
			attack_template = "blunt_linesman", -- official: "blunt_tank"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.5, -- official: none
			power_distribution = {
				attack = 0.245, -- official: 0.175
				impact = 0.1,
			},
			-- removed: armor_modifier (official: <table>)
		},
		{
			attack_template = "blunt_linesman", -- official: "blunt_tank"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.4, -- official: none
			power_distribution = {
				attack = 0.211, -- official: 0.1
				impact = 0.095, -- official: 0.1
			},
			-- removed: armor_modifier (official: <table>)
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.3,
			power_distribution = {
				attack = 0.177,
				impact = 0.09,
			},
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.2,
			power_distribution = {
				attack = 0.143,
				impact = 0.085,
			},
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.1,
			power_distribution = {
				attack = 0.109,
				impact = 0.08,
			},
		},
	},
}

-- crowbill_light_3: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.crowbill_light_3 = { -- official: crowbill_1h_light_smiter_diag
	armor_modifier = {
		attack = {
			1.2, -- official: 1
			1.1, -- official: 0.25
			2, -- official: 1
			1,
			1.1, -- official: 0.75
		},
		impact = {
			1, -- official: 0.75
			0.5, -- official: 0.25
			1,
			1,
			1, -- official: 0.75
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.1, -- official: 1
			1,
			2,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default", -- official: "crowbill_1h_light_smiter_diag_cleave_distribution"
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
		-- removed: boost_curve_coefficient_headshot (official: 1.5)
	},
	targets = {
		{
			attack_template = "blunt_linesman", -- official: "slashing_smiter"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.5, -- official: none
			power_distribution = {
				attack = 0.255, -- official: 0.175
				impact = 0.1,
			},
			-- removed: armor_modifier (official: <table>)
		},
		{
			attack_template = "blunt_linesman", -- official: "slashing_smiter"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.375, -- official: none
			power_distribution = {
				attack = 0.21, -- official: 0.1
				impact = 0.094, -- official: 0.1
			},
			-- removed: armor_modifier (official: <table>)
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.25,
			power_distribution = {
				attack = 0.165,
				impact = 0.087,
			},
		},
		{ -- official: none
			attack_template = "blunt_linesman",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.125,
			power_distribution = {
				attack = 0.12,
				impact = 0.081,
			},
		},
	},
}

-- crowbill_light_4: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.light_attack_left.damage_profile
NewDamageProfileTemplates.crowbill_light_4 = { -- official: light_blunt_smiter_stab_burn
	armor_modifier = {
		attack = {
			1,
			1.1, -- official: 0.5
			2.2, -- official: 1.5
			1,
			1.1, -- official: 0.75
			1.25, -- official: none
		},
		impact = {
			1,
			1.25,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1, -- official: 0.5
			2,
			1,
			1,
			1.1, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1, -- official: none
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 2,
		boost_curve_coefficient = 0.75,
		power_distribution = {
			attack = 0.1,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "burning_stab_fencer",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2.5, -- official: 1.5
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.2,
				impact = 0.2,
			},
		},
		{ -- official: none
			attack_template = "burning_stab_fencer",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2.32,
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.167,
				impact = 0.158,
			},
		},
		{ -- official: none
			attack_template = "burning_stab_fencer",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2.16,
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.133,
				impact = 0.118,
			},
		},
	},
}

-- crowbill_push_attack: replaces the existing block
-- used by Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.damage_profile
NewDamageProfileTemplates.crowbill_push_attack = { -- official: crowbill_1h_light_smiter_upper
	armor_modifier = "armor_modifier_pointy_smiter_L", -- official: "crowbill_1h_light_smiter_upper_armor_modifier"
	charge_value = "light_attack",
	critical_strike = "critical_strike_pointy_smiter_L",
	cleave_distribution = "cleave_distribution_smiter_default", -- official: "crowbill_1h_light_smiter_upper_cleave_distribution"
	default_target = {
		attack_template = "slashing_smiter", -- official: "slashing_upper"
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
		-- removed: boost_curve_coefficient_headshot (official: 1.5)
	},
	targets = {
		{
			attack_template = "blunt_tank_uppercut", -- official: "slashing_upper"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.5, -- official: none
			power_distribution = {
				attack = 0.175,
				impact = 0.1,
			},
			-- removed: armor_modifier (official: <table>)
		},
		{
			attack_template = "blunt_tank_uppercut", -- official: "slashing_upper"
			boost_curve_type = "ninja_curve", -- official: "smiter_curve"
			boost_curve_coefficient_headshot = 1.375, -- official: none
			power_distribution = {
				attack = 0.15, -- official: 0.1
				impact = 0.094, -- official: 0.1
			},
			-- removed: armor_modifier (official: <table>)
		},
		{ -- official: none
			attack_template = "blunt_tank_uppercut",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.25,
			power_distribution = {
				attack = 0.125,
				impact = 0.088,
			},
		},
		{ -- official: none
			attack_template = "blunt_tank_uppercut",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 1.125,
			power_distribution = {
				attack = 0.1,
				impact = 0.082,
			},
		},
	},
}

-- ======== one_handed_daggers_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_daggers_template_1

		* action_one.light_attack_last: Changed damage_profile to sienna_dagger_light_4 (from dagger_1h_light_linesman)
		* action_one.light_attack_last: Increased armor_modifier.attack[1] to 1.5 (from 1, +50%)
		* action_one.light_attack_last: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_last: Reduced cleave_distribution.attack to 0.25 (from 0.26, -4%)
		* action_one.light_attack_left: Changed damage_profile to sienna_dagger_light_1 (from dagger_1h_light_linesman)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 1.14 (from 1, +14%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_left: Reduced cleave_distribution.attack to 0.25 (from 0.26, -4%)
		* action_one.light_attack_right: Changed damage_profile to sienna_dagger_light_2 (from dagger_1h_light_linesman)
		* action_one.light_attack_right: Increased armor_modifier.attack[1] to 1.21 (from 1, +21%)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_right: Reduced cleave_distribution.attack to 0.25 (from 0.26, -4%)
		* action_one.light_attack_stab: Changed damage_profile to sienna_dagger_light_3 (from dagger_1h_light_smiter_stab)
		* action_one.light_attack_stab: Changed default_target.attack_template to light_slashing_linesman_hs (from light_stab_smiter)
		* action_one.light_attack_stab: Changed targets[1].attack_template to light_slashing_linesman_hs (from light_stab_smiter)
		* action_one.light_attack_stab: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_stab: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_stab: Increased armor_modifier.impact[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_stab: Increased cleave_distribution.attack to 0.25 (from 0.075, +233%)
		* action_one.light_attack_stab: Increased cleave_distribution.impact to 0.2 (from 0.075, +167%)
		* action_one.light_attack_stab: Increased targets[1].power_distribution.attack to 0.125 (from 0.12, +4%)
		* action_one.light_attack_stab: Reduced armor_modifier.attack[2] to 0 (from 0.25, -100%)
		* action_one.light_attack_stab: Reduced critical_strike.impact_armor_power_modifer[2] to 0.1 (from 0.5, -80%)
		* action_one.light_attack_stab: Reduced default_target.power_distribution.impact to 0.05 (from 0.075, -33%)
		* action_one.light_attack_stab: Reduced targets[1].power_distribution.impact to 0.05 (from 0.08, -38%)
		* action_one.light_attack_stab: Removed default_target.boost_curve_coefficient_headshot (was 3)
		* action_one.light_attack_stab: Removed require_damage_for_dot (was true)
		* action_one.light_attack_stab: Removed targets[1].dot_balefire_variant (was true)
		* action_one.light_attack_stab: Removed targets[1].dot_template_name (was weapon_bleed_dot_dagger)
		* action_one.push_stab: Changed damage_profile to dagger_push_attack_bleed_to_burn (from light_fencer_stab)
		* action_one.push_stab: Changed targets[1].dot_template_name to dagger_push_attack_bleed_to_burn_buff (from weapon_bleed_dot_dagger)

	$END_TB
]]

Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_last.damage_profile = "sienna_dagger_light_4" -- official: "dagger_1h_light_linesman"
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_left.damage_profile = "sienna_dagger_light_1" -- official: "dagger_1h_light_linesman"
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_right.damage_profile = "sienna_dagger_light_2" -- official: "dagger_1h_light_linesman"
Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_stab.damage_profile = "sienna_dagger_light_3" -- official: "dagger_1h_light_smiter_stab"
Weapons.one_handed_daggers_template_1.actions.action_one.push_stab.damage_profile = "dagger_push_attack_bleed_to_burn" -- official: "light_fencer_stab"

-- dagger_push_attack_bleed_to_burn: replaces the existing block
-- used by Weapons.one_handed_daggers_template_1.actions.action_one.push_stab.damage_profile
NewDamageProfileTemplates.dagger_push_attack_bleed_to_burn = { -- official: light_fencer_stab
	armor_modifier = "armor_modifier_fencer_stab_L_AP",
	charge_value = "light_attack",
	critical_strike = "critical_strike_fencer_stab_L",
	require_damage_for_dot = true,
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_fencer_stab_L",
	targets = {
		{
			attack_template = "light_stab_smiter",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 3,
			dot_balefire_variant = true,
			dot_template_name = "dagger_push_attack_bleed_to_burn_buff", -- official: "weapon_bleed_dot_dagger"
			power_distribution = {
				attack = 0.12,
				impact = 0.08,
			},
		},
	},
}

-- dagger_push_attack_burn_dot_profile: replaces the existing block
NewDamageProfileTemplates.dagger_push_attack_burn_dot_profile = { -- official: none (new profile)
	armor_modifier = {
		attack = {
			1,
			0.5,
			1,
			0.25,
			0.5,
			0,
		},
		impact = {
			1,
			0.5,
			1,
			0.25,
			0.5,
			0,
		},
	},
	charge_value = "n/a",
	no_stagger_damage_reduction_ranged = true,
	is_dot = true,
	no_stagger = true,
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25,
	},
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient = 0.2,
		damage_type = "burninating",
		power_distribution = {
			attack = 0.075,
			impact = 0,
		},
	},
}

-- sienna_dagger_light_1: replaces the existing block
-- used by Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_left.damage_profile
NewDamageProfileTemplates.sienna_dagger_light_1 = { -- official: dagger_1h_light_linesman
	armor_modifier = {
		attack = {
			1.14, -- official: 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = "critical_strike_linesman_fencer_L",
	cleave_distribution = "cleave_distribution_linesman_fencer_L", -- official: "dagger_1h_light_linesman_cleave_distribution"
	default_target = {
		attack_template = "light_slashing_linesman_hs",
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = "targets_linesman_fencer_L",
}

-- sienna_dagger_light_2: replaces the existing block
-- used by Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.sienna_dagger_light_2 = { -- official: dagger_1h_light_linesman
	armor_modifier = {
		attack = {
			1.21, -- official: 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = "critical_strike_linesman_fencer_L",
	cleave_distribution = "cleave_distribution_linesman_fencer_L", -- official: "dagger_1h_light_linesman_cleave_distribution"
	default_target = {
		attack_template = "light_slashing_linesman_hs",
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = "targets_linesman_fencer_L",
}

-- sienna_dagger_light_3: replaces the existing block
-- used by Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_stab.damage_profile
NewDamageProfileTemplates.sienna_dagger_light_3 = { -- official: dagger_1h_light_smiter_stab
	armor_modifier = {
		attack = {
			1.25, -- official: 1
			0, -- official: 0.25
			1.5,
			1,
			1, -- official: 0.75
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1, -- official: 0.75
		},
	},
	charge_value = "light_attack",
	critical_strike = "critical_strike_linesman_fencer_L", -- official: "dagger_1h_light_smiter_stab_critical_strike"
	cleave_distribution = "cleave_distribution_linesman_fencer_L", -- official: "dagger_1h_light_smiter_stab_cleave_distribution"
	default_target = "default_target_linesman_fencer_L", -- official: "dagger_1h_light_smiter_stab_default_target"
	targets = {
		{
			attack_template = "light_slashing_linesman_hs", -- official: "light_stab_smiter"
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 3,
			power_distribution = {
				attack = 0.125, -- official: 0.12
				impact = 0.05, -- official: 0.08
			},
			-- removed: dot_balefire_variant (official: true)
			-- removed: dot_template_name (official: "weapon_bleed_dot_dagger")
		},
	},
	-- removed: require_damage_for_dot (official: true)
}

-- sienna_dagger_light_4: replaces the existing block
-- used by Weapons.one_handed_daggers_template_1.actions.action_one.light_attack_last.damage_profile
NewDamageProfileTemplates.sienna_dagger_light_4 = { -- official: dagger_1h_light_linesman
	armor_modifier = {
		attack = {
			1.5, -- official: 1
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = "critical_strike_linesman_fencer_L",
	cleave_distribution = "cleave_distribution_linesman_fencer_L", -- official: "dagger_1h_light_linesman_cleave_distribution"
	default_target = {
		attack_template = "light_slashing_linesman_hs",
		boost_curve_type = "ninja_curve",
		power_distribution = {
			attack = 0.125, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = "targets_linesman_fencer_L",
}

-- ======== one_handed_flail_shield_template ========

--[[
	$BEGIN_TB
		## one_handed_flail_shield_template

		* action_one.light_attack_01: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_01: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_02: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_02: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_02_pose: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_02_pose: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_03: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.light_attack_04: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.light_attack_05: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.light_attack_05_removed_shield_slam: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_05_removed_shield_slam: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_bopp: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_flail_shield_template.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- light_blunt_tank_spiked (official profile, changed in place)
-- in preset cleave_distribution_tank_spiked_L (only this profile uses it)
DamageProfileTemplates.light_blunt_tank_spiked.cleave_distribution.impact = 0.5 -- official: 0.25

-- uses shield_slam_target (exported under one_hand_axe_shield_template_1)

-- ======== one_handed_flail_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_flail_template_1

		* action_one.heavy_attack: Added ignore_stagger_reduction: true
		* action_one.heavy_attack: Added targets[1].armor_modifier: <table>
		* action_one.heavy_attack: Added targets[1].boost_curve_coefficient_headshot: 1
		* action_one.heavy_attack: Changed damage_profile to heavy_1h_flail_tb (from medium_blunt_tank_spiked)
		* action_one.heavy_attack: Changed default_target.attack_template to blunt_tank (from light_blunt_tank)
		* action_one.heavy_attack: Changed targets[3].attack_template to blunt_tank (from light_blunt_tank)
		* action_one.heavy_attack: Increased armor_modifier.impact[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack: Increased default_target.power_distribution.attack to 0.075 (from 0.05, +50%)
		* action_one.heavy_attack: Increased default_target.power_distribution.impact to 0.3 (from 0.05, +500%)
		* action_one.heavy_attack: Increased targets[2].power_distribution.attack to 0.22 (from 0.15, +47%)
		* action_one.heavy_attack: Increased targets[2].power_distribution.impact to 0.3 (from 0.15, +100%)
		* action_one.heavy_attack: Increased targets[3].power_distribution.attack to 0.1 (from 0.075, +33%)
		* action_one.heavy_attack: Increased targets[3].power_distribution.impact to 0.3 (from 0.1, +200%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[1] to 1 (from 1.3, -23%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[2] to 0.25 (from 0.8, -69%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[3] to 1 (from 1.3, -23%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[4] to 1 (from 1.3, -23%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.heavy_attack: Reduced armor_modifier.impact[1] to 0.75 (from 1, -25%)
		* action_one.heavy_attack: Reduced armor_modifier.impact[2] to 0.25 (from 1, -75%)
		* action_one.heavy_attack: Removed default_target.stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack: Removed stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack: Removed targets[1].stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack: Removed targets[2].stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack: Removed targets[3].stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack_left: Added ignore_stagger_reduction: true
		* action_one.heavy_attack_left: Added targets[1].armor_modifier: <table>
		* action_one.heavy_attack_left: Added targets[1].boost_curve_coefficient_headshot: 1
		* action_one.heavy_attack_left: Changed damage_profile to heavy_1h_flail_tb (from medium_blunt_tank_spiked)
		* action_one.heavy_attack_left: Changed default_target.attack_template to blunt_tank (from light_blunt_tank)
		* action_one.heavy_attack_left: Changed targets[3].attack_template to blunt_tank (from light_blunt_tank)
		* action_one.heavy_attack_left: Increased armor_modifier.impact[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack_left: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack_left: Increased default_target.power_distribution.attack to 0.075 (from 0.05, +50%)
		* action_one.heavy_attack_left: Increased default_target.power_distribution.impact to 0.3 (from 0.05, +500%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.attack to 0.22 (from 0.15, +47%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.impact to 0.3 (from 0.15, +100%)
		* action_one.heavy_attack_left: Increased targets[3].power_distribution.attack to 0.1 (from 0.075, +33%)
		* action_one.heavy_attack_left: Increased targets[3].power_distribution.impact to 0.3 (from 0.1, +200%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[1] to 1 (from 1.3, -23%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[2] to 0.25 (from 0.8, -69%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[3] to 1 (from 1.3, -23%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[4] to 1 (from 1.3, -23%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.heavy_attack_left: Reduced armor_modifier.impact[1] to 0.75 (from 1, -25%)
		* action_one.heavy_attack_left: Reduced armor_modifier.impact[2] to 0.25 (from 1, -75%)
		* action_one.heavy_attack_left: Removed default_target.stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack_left: Removed stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack_left: Removed targets[1].stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack_left: Removed targets[2].stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack_left: Removed targets[3].stagger_duration_modifier (was 1.5)
		* action_one.light_attack_bopp: Increased anim_time_scale to 1.3 (from 1.1, +18%)
		* action_one.light_attack_bopp: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.light_attack_down: Added buff_data.external_multiplier: 0.85
		* action_one.light_attack_down: Added default_target.boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_down: Changed damage_profile to light_1h_flail_tb (from light_blunt_smiter)
		* action_one.light_attack_down: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_down: Increased armor_modifier.attack[2] to 0.9 (from 0.65, +38%)
		* action_one.light_attack_down: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_down: Increased armor_modifier.attack[6] to 0.9 (from 0.6, +50%)
		* action_one.light_attack_down: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.75, +20%)
		* action_one.light_attack_down: Reduced critical_strike.attack_armor_power_modifer[5] to 0.9 (from 1, -10%)
		* action_one.light_attack_last: Added buff_data.external_multiplier: 1
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_last: Changed damage_profile to light_1h_flail_tb (from light_blunt_smiter)
		* action_one.light_attack_last: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.9 (from 0.65, +38%)
		* action_one.light_attack_last: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.9 (from 0.6, +50%)
		* action_one.light_attack_last: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.75, +20%)
		* action_one.light_attack_last: Reduced critical_strike.attack_armor_power_modifer[5] to 0.9 (from 1, -10%)
		* action_one.light_attack_left: Added buff_data.external_multiplier: 0.85
		* action_one.light_attack_left: Increased anim_time_scale to 1.25 (from 1, +25%)
		* action_one.light_attack_left: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Added buff_data.external_multiplier: 0.85
		* action_one.light_attack_right: Increased anim_time_scale to 1.35 (from 1, +35%)
		* action_one.light_attack_right: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)

	$END_TB
]]

Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack.damage_profile = "heavy_1h_flail_tb" -- official: "medium_blunt_tank_spiked"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_flail_tb" -- official: "medium_blunt_tank_spiked"
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.3 -- official: 1.1
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.buff_data.external_multiplier = 0.85 -- official: none
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.damage_profile = "light_1h_flail_tb" -- official: "light_blunt_smiter"
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.buff_data.external_multiplier = 1 -- official: none
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.damage_profile = "light_1h_flail_tb" -- official: "light_blunt_smiter"
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.25 -- official: 1
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_left.buff_data.external_multiplier = 0.85 -- official: none
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.35 -- official: 1
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_right.buff_data.external_multiplier = 0.85 -- official: none

-- heavy_1h_flail_tb: replaces the existing block
-- used by Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack.damage_profile
-- used by Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack_left.damage_profile
NewDamageProfileTemplates.heavy_1h_flail_tb = { -- official: medium_blunt_tank_spiked
	armor_modifier = {
		attack = {
			1, -- official: 1.3
			0.25, -- official: 0.8
			1, -- official: 1.3
			1, -- official: 1.3
			0.75, -- official: 1
		},
		impact = {
			0.75, -- official: 1
			0.25, -- official: 1
			1, -- official: 0.5
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
			1,
			1.3,
			1.3,
			1.3,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1, -- official: 0.5
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.6,
		impact = 0.65,
	},
	ignore_stagger_reduction = true, -- official: none
	default_target = {
		attack_template = "blunt_tank", -- official: "light_blunt_tank"
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.075, -- official: 0.05
			impact = 0.3, -- official: 0.05
		},
		-- removed: stagger_duration_modifier (official: 1.5)
	},
	targets = {
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1, -- official: none
			armor_modifier = { -- official: none
				attack = {
					1.3,
					0.8,
					1.3,
					1.3,
					1.3,
					1,
				},
				impact = {
					1,
					1,
					0.5,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.3,
				impact = 0.3,
			},
			-- removed: stagger_duration_modifier (official: 1.5)
		},
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.22, -- official: 0.15
				impact = 0.3, -- official: 0.15
			},
			-- removed: stagger_duration_modifier (official: 1.5)
		},
		{
			attack_template = "blunt_tank", -- official: "light_blunt_tank"
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.1, -- official: 0.075
				impact = 0.3, -- official: 0.1
			},
			-- removed: stagger_duration_modifier (official: 1.5)
		},
	},
	-- removed: stagger_duration_modifier (official: 1.5)
}

-- light_1h_flail_tb: replaces the existing block
-- used by Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.damage_profile
-- used by Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.damage_profile
NewDamageProfileTemplates.light_1h_flail_tb = { -- official: light_blunt_smiter
	armor_modifier = {
		attack = {
			1.25,
			0.9, -- official: 0.65
			2.5,
			1,
			1, -- official: 0.75
			0.9, -- official: 0.6
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.9, -- official: 0.75
			2.75,
			1,
			0.9, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	ignore_stagger_reduction = true,
	default_target = {
		attack_template = "slashing_smiter", -- official: "light_blunt_smiter"
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 1.5, -- official: none
		power_distribution = {
			attack = 0.25,
			impact = 0.175,
		},
	},
	targets = {
		[2] = {
			attack_template = "slashing_smiter",
			boost_curve_type = "smiter_curve",
			armor_modifier = {
				attack = {
					1,
					0.25,
					1,
					1,
					0.75,
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.075,
				impact = 0.075,
			},
		},
	},
}

-- uses light_blunt_tank_spiked (exported under one_handed_flail_shield_template)

-- ======== one_handed_flails_flaming_template ========

--[[
	$BEGIN_TB
		## one_handed_flails_flaming_template

		* action_one.heavy_attack: Reduced default_target.power_distribution.impact to 0.375 (from 0.95, -61%)
		* action_one.light_attack_bopp: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.light_attack_down: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_down: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_left: Added hit_mass_count: <table>
		* action_one.light_attack_left: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Added hit_mass_count: <table>
		* action_one.light_attack_right: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)

	$END_TB
]]

Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_left.hit_mass_count = { -- official: none
	beastmen_bestigor = 0.5,
	beastmen_gor = 0.5,
	beastmen_ungor = 0.75,
	chaos_berzerker = 0.5,
	chaos_fanatic = 0.75,
	chaos_marauder = 0.5,
	chaos_marauder_with_shield = 0.5,
	chaos_raider = 0.5,
	chaos_warrior = 1e+01,
	skaven_clan_rat = 0.5,
	skaven_clan_rat_with_shield = 0.5,
	skaven_slave = 0.75,
	skaven_storm_vermin = 0.5,
	skaven_storm_vermin_commander = 0.5,
	skaven_storm_vermin_with_shield = 0.5,
}
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_right.hit_mass_count = { -- official: none
	beastmen_bestigor = 0.5,
	beastmen_gor = 0.5,
	beastmen_ungor = 0.75,
	chaos_berzerker = 0.5,
	chaos_fanatic = 0.75,
	chaos_marauder = 0.5,
	chaos_marauder_with_shield = 0.5,
	chaos_raider = 0.5,
	chaos_warrior = 1e+01,
	skaven_clan_rat = 0.5,
	skaven_clan_rat_with_shield = 0.5,
	skaven_slave = 0.75,
	skaven_storm_vermin = 0.5,
	skaven_storm_vermin_commander = 0.5,
	skaven_storm_vermin_with_shield = 0.5,
}

-- heavy_blunt_smiter_burn (official profile, changed in place)
-- in preset default_target_smiter_burn_H.power_distribution (only this profile uses it)
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.impact = 0.375 -- official: 0.95

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- uses light_blunt_tank_spiked (exported under one_handed_flail_shield_template)

-- ======== one_handed_hammer_book_priest_preview_template ========

--[[
	$BEGIN_TB
		## one_handed_hammer_book_priest_preview_template

		* action_one.light_attack_01: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_01: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_01_pose: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_01_pose: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_02: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_02: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)

	$END_TB
]]

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- ======== one_handed_hammer_book_priest_template ========

--[[
	$BEGIN_TB
		## one_handed_hammer_book_priest_template

		* action_one.heavy_attack_left_charged: Added armor_modifier.attack[6]: 1.27
		* action_one.heavy_attack_left_charged: Added critical_strike.attack_armor_power_modifer[6]: 1.08
		* action_one.heavy_attack_left_charged: Added targets.attack_template: slashing_smiter
		* action_one.heavy_attack_left_charged: Added targets.boost_curve_coefficient: 2
		* action_one.heavy_attack_left_charged: Added targets.boost_curve_type: smiter_curve
		* action_one.heavy_attack_left_charged: Added targets.power_distribution: <table>
		* action_one.heavy_attack_left_charged: Changed damage_profile to hammer_and_tome_heavy_1_charged (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_left_charged: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_left_charged: Increased armor_modifier.attack[2] to 1.4 (from 0.8, +75%)
		* action_one.heavy_attack_left_charged: Increased critical_strike.attack_armor_power_modifer[2] to 1.2 (from 0.8, +50%)
		* action_one.heavy_attack_left_charged: Removed targets[2] (was <table>)
		* action_one.heavy_attack_stab_charged: Changed damage_profile to hammer_and_tome_heavy_2_charged (from medium_blunt_smiter_1h_thrust)
		* action_one.heavy_attack_stab_charged: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_stab_charged: Increased armor_modifier.attack[1] to 2.112 (from 1, +111%)
		* action_one.heavy_attack_stab_charged: Increased armor_modifier.attack[5] to 1.44 (from 0.75, +92%)
		* action_one.heavy_attack_stab_charged: Increased critical_strike.attack_armor_power_modifer[1] to 1.6 (from 1, +60%)
		* action_one.heavy_attack_stab_charged: Increased critical_strike.attack_armor_power_modifer[5] to 1.283 (from 1, +28%)
		* action_one.heavy_attack_stab_charged: Reduced default_target.power_distribution.impact to 0.25 (from 0.35, -29%)
		* action_one.light_attack_01: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_01: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_01_pose: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_01_pose: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_02: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_02: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)

	$END_TB
]]

Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.damage_profile = "hammer_and_tome_heavy_1_charged" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_stab_charged.damage_profile = "hammer_and_tome_heavy_2_charged" -- official: "medium_blunt_smiter_1h_thrust"

-- hammer_and_tome_heavy_1_charged: replaces the existing block
-- used by Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.damage_profile
NewDamageProfileTemplates.hammer_and_tome_heavy_1_charged = { -- official: medium_blunt_smiter_1h
	armor_modifier = {
		attack = {
			1,
			1.4, -- official: 0.8
			1.75,
			1,
			0.75,
			1.27, -- official: none
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1.2, -- official: 0.8
			2.5,
			1,
			1,
			1.08, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = "default_target_smiter_M", -- official: inline table (differs)
	targets = {
		attack_template = "slashing_smiter", -- official: none
		boost_curve_coefficient = 2, -- official: none
		boost_curve_type = "smiter_curve", -- official: none
		power_distribution = { -- official: none
			attack = 0.4,
			impact = 0.25,
		},
		-- removed: [2] (official: <table>)
	},
}

-- hammer_and_tome_heavy_2_charged: replaces the existing block
-- used by Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_stab_charged.damage_profile
NewDamageProfileTemplates.hammer_and_tome_heavy_2_charged = { -- official: medium_blunt_smiter_1h_thrust
	armor_modifier = {
		attack = {
			2.112, -- official: 1
			0.8,
			1.75,
			1,
			1.44, -- official: 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.6, -- official: 1
			0.8,
			2.5,
			1,
			1.283, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = {
		attack_template = "slashing_smiter", -- official: "blunt_smiter"
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		power_distribution = {
			attack = 0.45,
			impact = 0.25, -- official: 0.35
		},
	},
	targets = "targets_smiter_M",
}

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- ======== one_handed_hammer_priest_template ========

--[[
	$BEGIN_TB
		## one_handed_hammer_priest_template

		* action_one.heavy_attack_01: Added range_mod: 1.2
		* action_one.heavy_attack_01: Changed damage_profile to tb_1h_hammer_heavy (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_01: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_01: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.heavy_attack_01: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.heavy_attack_02: Added range_mod: 1.2
		* action_one.heavy_attack_02: Changed damage_profile to tb_1h_hammer_heavy (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_02: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_02: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.heavy_attack_02: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_01: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_01: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_01: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_01: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_01: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_01: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_01: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_01: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_01: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_01: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_01: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_01: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_01: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_01: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_02: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_02: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_02: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_02: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_02: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_02: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_02: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_02: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_02: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_02: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_02: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_02: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_02: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_02: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_03: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_03: Changed damage_profile to tb_1h_hammer_light_3_4 (from light_blunt_smiter)
		* action_one.light_attack_03: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_03: Increased armor_modifier.attack[3] to 3 (from 2.5, +20%)
		* action_one.light_attack_03: Increased armor_modifier.attack[5] to 1.25 (from 0.75, +67%)
		* action_one.light_attack_04: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_04: Changed damage_profile to tb_1h_hammer_light_3_4 (from light_blunt_smiter)
		* action_one.light_attack_04: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_04: Increased anim_time_scale to 1.5 (from 1.215, +23%)
		* action_one.light_attack_04: Increased armor_modifier.attack[3] to 3 (from 2.5, +20%)
		* action_one.light_attack_04: Increased armor_modifier.attack[5] to 1.25 (from 0.75, +67%)

	$END_TB
]]

Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.damage_profile = "tb_1h_hammer_heavy" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.range_mod = 1.2 -- official: none
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "tb_1h_hammer_heavy" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.range_mod = 1.2 -- official: none
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_01.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "tb_1h_hammer_light_3_4" -- official: "light_blunt_smiter"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.anim_time_scale = 1.5 -- official: 1.215
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.damage_profile = "tb_1h_hammer_light_3_4" -- official: "light_blunt_smiter"

-- tb_1h_hammer_heavy: replaces the existing block
-- used by Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.damage_profile
-- used by Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile
-- used by Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.damage_profile
-- used by Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.damage_profile
NewDamageProfileTemplates.tb_1h_hammer_heavy = { -- official: medium_blunt_smiter_1h
	armor_modifier = {
		attack = {
			1,
			0.8,
			2.5, -- official: 1.75
			1,
			1, -- official: 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_smiter_M",
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = "default_target_smiter_M", -- official: inline table (differs)
	targets = "targets_smiter_M",
}

-- uses tb_1h_hammer_light_1_2 (exported under dual_wield_hammer_sword_template)

-- tb_1h_hammer_light_3_4: replaces the existing block
-- used by Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile
-- used by Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.damage_profile
-- used by Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.damage_profile
-- used by Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_last.damage_profile
-- used by Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.damage_profile
-- used by Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_last.damage_profile
NewDamageProfileTemplates.tb_1h_hammer_light_3_4 = { -- official: light_blunt_smiter
	armor_modifier = {
		attack = {
			1.25,
			0.65,
			3, -- official: 2.5
			1,
			1.25, -- official: 0.75
			0.6,
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.75,
			2.75,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	ignore_stagger_reduction = true,
	default_target = {
		attack_template = "slashing_smiter", -- official: "light_blunt_smiter"
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 2, -- official: none
		power_distribution = {
			attack = 0.25,
			impact = 0.175,
		},
	},
	targets = "targets_smiter_L",
}

-- ======== one_handed_hammer_shield_priest_template ========

--[[
	$BEGIN_TB
		## one_handed_hammer_shield_priest_template

		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_hammer_shield_priest_template.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- uses shield_slam (exported under one_hand_axe_shield_template_1)

-- uses shield_slam_target (exported under one_hand_axe_shield_template_1)

-- ======== one_handed_hammer_shield_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_hammer_shield_template_1

		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_hammer_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- uses shield_slam (exported under one_hand_axe_shield_template_1)

-- uses shield_slam_target (exported under one_hand_axe_shield_template_1)

-- ======== one_handed_hammer_shield_template_2 ========

--[[
	$BEGIN_TB
		## one_handed_hammer_shield_template_2

		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_hammer_shield_template_2.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- uses light_blunt_smiter (exported under dual_wield_hammers_priest_template)

-- uses shield_slam (exported under one_hand_axe_shield_template_1)

-- uses shield_slam_target (exported under one_hand_axe_shield_template_1)

-- ======== one_handed_hammer_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_hammer_template_1

		* action_one.heavy_attack_left: Added range_mod: 1.2
		* action_one.heavy_attack_left: Changed damage_profile to tb_1h_hammer_heavy (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_left: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.heavy_attack_right: Added range_mod: 1.2
		* action_one.heavy_attack_right: Changed damage_profile to tb_1h_hammer_heavy (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_right: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_right: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.heavy_attack_right: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_down: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_down: Changed damage_profile to tb_1h_hammer_light_3_4 (from light_blunt_smiter)
		* action_one.light_attack_down: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_down: Increased anim_time_scale to 1.5 (from 1.215, +23%)
		* action_one.light_attack_down: Increased armor_modifier.attack[3] to 3 (from 2.5, +20%)
		* action_one.light_attack_down: Increased armor_modifier.attack[5] to 1.25 (from 0.75, +67%)
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_last: Changed damage_profile to tb_1h_hammer_light_3_4 (from light_blunt_smiter)
		* action_one.light_attack_last: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_last: Increased armor_modifier.attack[3] to 3 (from 2.5, +20%)
		* action_one.light_attack_last: Increased armor_modifier.attack[5] to 1.25 (from 0.75, +67%)
		* action_one.light_attack_left: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_left: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_left: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_left: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_left: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_left: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_left: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_right: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_right: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_right: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_right: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_right: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_right: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)

	$END_TB
]]

Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_1h_hammer_heavy" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 -- official: none
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_1h_hammer_heavy" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 -- official: none
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.anim_time_scale = 1.5 -- official: 1.215
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.damage_profile = "tb_1h_hammer_light_3_4" -- official: "light_blunt_smiter"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_last.damage_profile = "tb_1h_hammer_light_3_4" -- official: "light_blunt_smiter"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"

-- uses tb_1h_hammer_heavy (exported under one_handed_hammer_priest_template)

-- uses tb_1h_hammer_light_1_2 (exported under dual_wield_hammer_sword_template)

-- uses tb_1h_hammer_light_3_4 (exported under one_handed_hammer_priest_template)

-- ======== one_handed_hammer_template_2 ========

--[[
	$BEGIN_TB
		## one_handed_hammer_template_2

		* action_one.heavy_attack_left: Added range_mod: 1.2
		* action_one.heavy_attack_left: Changed damage_profile to tb_1h_hammer_heavy (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_left: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.heavy_attack_right: Added range_mod: 1.2
		* action_one.heavy_attack_right: Changed damage_profile to tb_1h_hammer_heavy (from medium_blunt_smiter_1h)
		* action_one.heavy_attack_right: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.heavy_attack_right: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.heavy_attack_right: Increased armor_modifier.attack[5] to 1 (from 0.75, +33%)
		* action_one.light_attack_down: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_down: Changed damage_profile to tb_1h_hammer_light_3_4 (from light_blunt_smiter)
		* action_one.light_attack_down: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_down: Increased anim_time_scale to 1.5 (from 1.215, +23%)
		* action_one.light_attack_down: Increased armor_modifier.attack[3] to 3 (from 2.5, +20%)
		* action_one.light_attack_down: Increased armor_modifier.attack[5] to 1.25 (from 0.75, +67%)
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 2
		* action_one.light_attack_last: Changed damage_profile to tb_1h_hammer_light_3_4 (from light_blunt_smiter)
		* action_one.light_attack_last: Changed default_target.attack_template to slashing_smiter (from light_blunt_smiter)
		* action_one.light_attack_last: Increased armor_modifier.attack[3] to 3 (from 2.5, +20%)
		* action_one.light_attack_last: Increased armor_modifier.attack[5] to 1.25 (from 0.75, +67%)
		* action_one.light_attack_left: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_left: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_left: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_left: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_left: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_left: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_left: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_left: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Added armor_modifier.attack[6]: 0.25
		* action_one.light_attack_right: Added critical_strike.attack_armor_power_modifer[6]: 0.25
		* action_one.light_attack_right: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to tb_1h_hammer_light_1_2 (from light_blunt_tank_diag)
		* action_one.light_attack_right: Changed default_target.attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_right: Changed targets[1].attack_template to blunt_tank (from blunt_linesman)
		* action_one.light_attack_right: Changed targets[2].attack_template to light_blunt_tank (from light_blunt_linesman)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.35 (from 0)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.23 (from 0.2, +15%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.25, +100%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.225 (from 0.175, +29%)
		* action_one.light_attack_right: Reduced armor_modifier.attack[5] to 0.75 (from 1, -25%)
		* action_one.light_attack_right: Reduced critical_strike.attack_armor_power_modifer[5] to 0.75 (from 1, -25%)

	$END_TB
]]

Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.damage_profile = "tb_1h_hammer_heavy" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 -- official: none
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.damage_profile = "tb_1h_hammer_heavy" -- official: "medium_blunt_smiter_1h"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 -- official: none
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.anim_time_scale = 1.5 -- official: 1.215
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.damage_profile = "tb_1h_hammer_light_3_4" -- official: "light_blunt_smiter"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_last.damage_profile = "tb_1h_hammer_light_3_4" -- official: "light_blunt_smiter"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_left.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2" -- official: "light_blunt_tank_diag"

-- uses tb_1h_hammer_heavy (exported under one_handed_hammer_priest_template)

-- uses tb_1h_hammer_light_1_2 (exported under dual_wield_hammer_sword_template)

-- uses tb_1h_hammer_light_3_4 (exported under one_handed_hammer_priest_template)

-- ======== one_handed_hammer_wizard_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_hammer_wizard_template_1

		* action_one.heavy_attack: Added critical_strike.impact_armor_power_modifer[6]: 0.5
		* action_one.heavy_attack: Added default_target.boost_curve_coefficient_headshot: 1.1
		* action_one.heavy_attack: Changed damage_profile to medium_blunt_smiter_heavy_wiz (from mace_1h_heavy_smiter_vertical)
		* action_one.heavy_attack: Increased armor_modifier.attack[2] to 0.9 (from 0.8, +12%)
		* action_one.heavy_attack: Increased default_target.power_distribution.attack to 0.4 (from 0.3, +33%)
		* action_one.heavy_attack: Increased range_mod to 1.5 (from 1.37, +9%)
		* action_one.heavy_attack: Reduced armor_modifier.attack[3] to 1.75 (from 2, -13%)
		* action_one.heavy_attack: Reduced armor_modifier.impact[5] to 0.7 (from 0.75, -7%)
		* action_one.heavy_attack: Reduced critical_strike.impact_armor_power_modifer[2] to 0.8 (from 1, -20%)
		* action_one.heavy_attack: Reduced default_target.power_distribution.impact to 0.25 (from 0.3, -17%)
		* action_one.heavy_attack: Removed armor_modifier.attack[6] (was 1)
		* action_one.heavy_attack: Removed critical_strike.attack_armor_power_modifer[6] (was 1)
		* action_one.heavy_attack: Removed default_target.dot_balefire_variant (was true)
		* action_one.heavy_attack: Removed default_target.dot_template_name (was burning_dot_3tick)
		* action_one.heavy_attack: Removed stagger_duration_modifier (was 1.5)
		* action_one.heavy_attack_left: Added default_target.boost_curve_coefficient_headshot: 1.4
		* action_one.heavy_attack_left: Changed damage_profile to medium_blunt_tank_upper_1h_wiz (from mace_1h_heavy_tank_diag)
		* action_one.heavy_attack_left: Changed targets[1].attack_template to blunt_tank (from heavy_blunt_tank)
		* action_one.heavy_attack_left: Changed targets[2].attack_template to blunt_tank (from heavy_blunt_tank)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[1] to 1.5 (from 1, +50%)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[2] to 0.8 (from 0)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[4] to 1.3 (from 1, +30%)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[5] to 1.6 (from 0.75, +113%)
		* action_one.heavy_attack_left: Increased range_mod to 1.75 (from 1.37, +28%)
		* action_one.heavy_attack_left: Increased targets[1].power_distribution.attack to 0.3 (from 0.15, +100%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.attack to 0.15 (from 0.1, +50%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[3] to 1.3 (from 1.5, -13%)
		* action_one.heavy_attack_left: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.heavy_attack_left: Reduced cleave_distribution.impact to 0.65 (from 0.7, -7%)
		* action_one.heavy_attack_left: Reduced critical_strike.attack_armor_power_modifer[1] to 1.2 (from 1.3, -8%)
		* action_one.heavy_attack_left: Reduced critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1.3, -8%)
		* action_one.heavy_attack_left: Reduced default_target.power_distribution.impact to 0.05 (from 0.1, -50%)
		* action_one.heavy_attack_left: Reduced targets[2].power_distribution.impact to 0.15 (from 0.2, -25%)
		* action_one.heavy_attack_left: Reduced targets[3].power_distribution.impact to 0.1 (from 0.15, -33%)
		* action_one.heavy_attack_left: Removed default_target.dot_balefire_variant (was true)
		* action_one.heavy_attack_left: Removed default_target.dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_left: Removed targets[1].armor_modifier (was <table>)
		* action_one.heavy_attack_left: Removed targets[1].dot_balefire_variant (was true)
		* action_one.heavy_attack_left: Removed targets[1].dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_left: Removed targets[2].dot_balefire_variant (was true)
		* action_one.heavy_attack_left: Removed targets[2].dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_left: Removed targets[3].dot_balefire_variant (was true)
		* action_one.heavy_attack_left: Removed targets[3].dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_right_up: Added default_target.boost_curve_coefficient_headshot: 1.4
		* action_one.heavy_attack_right_up: Changed damage_profile to medium_blunt_tank_upper_1h_wiz (from mace_1h_heavy_tank_diag)
		* action_one.heavy_attack_right_up: Changed targets[1].attack_template to blunt_tank (from heavy_blunt_tank)
		* action_one.heavy_attack_right_up: Changed targets[2].attack_template to blunt_tank (from heavy_blunt_tank)
		* action_one.heavy_attack_right_up: Increased armor_modifier.attack[1] to 1.5 (from 1, +50%)
		* action_one.heavy_attack_right_up: Increased armor_modifier.attack[2] to 0.8 (from 0)
		* action_one.heavy_attack_right_up: Increased armor_modifier.attack[4] to 1.3 (from 1, +30%)
		* action_one.heavy_attack_right_up: Increased armor_modifier.attack[5] to 1.6 (from 0.75, +113%)
		* action_one.heavy_attack_right_up: Increased range_mod to 1.75 (from 1.37, +28%)
		* action_one.heavy_attack_right_up: Increased targets[1].power_distribution.attack to 0.3 (from 0.15, +100%)
		* action_one.heavy_attack_right_up: Increased targets[2].power_distribution.attack to 0.15 (from 0.1, +50%)
		* action_one.heavy_attack_right_up: Reduced armor_modifier.attack[3] to 1.3 (from 1.5, -13%)
		* action_one.heavy_attack_right_up: Reduced armor_modifier.impact[3] to 0.5 (from 1, -50%)
		* action_one.heavy_attack_right_up: Reduced cleave_distribution.impact to 0.65 (from 0.7, -7%)
		* action_one.heavy_attack_right_up: Reduced critical_strike.attack_armor_power_modifer[1] to 1.2 (from 1.3, -8%)
		* action_one.heavy_attack_right_up: Reduced critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1.3, -8%)
		* action_one.heavy_attack_right_up: Reduced default_target.power_distribution.impact to 0.05 (from 0.1, -50%)
		* action_one.heavy_attack_right_up: Reduced targets[2].power_distribution.impact to 0.15 (from 0.2, -25%)
		* action_one.heavy_attack_right_up: Reduced targets[3].power_distribution.impact to 0.1 (from 0.15, -33%)
		* action_one.heavy_attack_right_up: Removed default_target.dot_balefire_variant (was true)
		* action_one.heavy_attack_right_up: Removed default_target.dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_right_up: Removed targets[1].armor_modifier (was <table>)
		* action_one.heavy_attack_right_up: Removed targets[1].dot_balefire_variant (was true)
		* action_one.heavy_attack_right_up: Removed targets[1].dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_right_up: Removed targets[2].dot_balefire_variant (was true)
		* action_one.heavy_attack_right_up: Removed targets[2].dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.heavy_attack_right_up: Removed targets[3].dot_balefire_variant (was true)
		* action_one.heavy_attack_right_up: Removed targets[3].dot_template_name (was burning_dot_2tick_slow_unstackable)
		* action_one.light_attack_bopp: Added default_target.boost_curve_coefficient_headshot: 1.4
		* action_one.light_attack_bopp: Changed damage_profile to light_blunt_tank_wiz (from mace_1h_light_tank_horizontal)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[1] to 1.8 (from 1, +80%)
		* action_one.light_attack_bopp: Increased armor_modifier.attack[5] to 1.6 (from 1, +60%)
		* action_one.light_attack_bopp: Increased critical_strike.attack_armor_power_modifer[1] to 1.3 (from 1, +30%)
		* action_one.light_attack_bopp: Increased critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1, +20%)
		* action_one.light_attack_bopp: Increased range_mod to 1.5 (from 1.37, +9%)
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 1.2
		* action_one.light_attack_last: Added targets[2].armor_modifier: <table>
		* action_one.light_attack_last: Changed damage_profile to light_blunt_smiter_wiz (from mace_1h_light_smiter_vertical)
		* action_one.light_attack_last: Changed targets[2].attack_template to slashing_smiter (from light_blunt_tank)
		* action_one.light_attack_last: Changed targets[2].boost_curve_type to smiter_curve (from tank_curve)
		* action_one.light_attack_last: Increased armor_modifier.attack[1] to 1.5 (from 1.25, +20%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 1.1 (from 0.65, +69%)
		* action_one.light_attack_last: Increased armor_modifier.attack[5] to 1.4 (from 0.75, +87%)
		* action_one.light_attack_last: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.75, +20%)
		* action_one.light_attack_last: Increased critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1, +20%)
		* action_one.light_attack_last: Increased default_target.power_distribution.attack to 0.25 (from 0.2, +25%)
		* action_one.light_attack_last: Increased range_mod to 1.5 (from 1.25, +20%)
		* action_one.light_attack_last: Reduced critical_strike.attack_armor_power_modifer[1] to 1.2 (from 1.25, -4%)
		* action_one.light_attack_last: Reduced targets[2].power_distribution.attack to 0.075 (from 0.1, -25%)
		* action_one.light_attack_last: Reduced targets[2].power_distribution.impact to 0.075 (from 0.1, -25%)
		* action_one.light_attack_last: Removed default_target.dot_balefire_variant (was true)
		* action_one.light_attack_last: Removed default_target.dot_template_name (was burning_dot_1tick)
		* action_one.light_attack_left: Added default_target.boost_curve_coefficient_headshot: 1.4
		* action_one.light_attack_left: Changed damage_profile to light_blunt_tank_wiz (from light_blunt_tank)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 1.8 (from 1, +80%)
		* action_one.light_attack_left: Increased armor_modifier.attack[5] to 1.6 (from 1, +60%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[1] to 1.3 (from 1, +30%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1, +20%)
		* action_one.light_attack_left: Increased range_mod to 1.5 (from 1.37, +9%)
		* action_one.light_attack_right: Added default_target.boost_curve_coefficient_headshot: 1.4
		* action_one.light_attack_right: Changed damage_profile to light_blunt_tank_wiz (from light_blunt_tank)
		* action_one.light_attack_right: Increased armor_modifier.attack[1] to 1.8 (from 1, +80%)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1.6 (from 1, +60%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[1] to 1.3 (from 1, +30%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1, +20%)
		* action_one.light_attack_right: Increased range_mod to 1.5 (from 1.37, +9%)
		* action_one.light_attack_upper: Added default_target.boost_curve_coefficient_headshot: 1.2
		* action_one.light_attack_upper: Added targets[2].armor_modifier: <table>
		* action_one.light_attack_upper: Changed damage_profile to light_blunt_smiter_wiz (from mace_1h_light_smiter_vertical)
		* action_one.light_attack_upper: Changed targets[2].attack_template to slashing_smiter (from light_blunt_tank)
		* action_one.light_attack_upper: Changed targets[2].boost_curve_type to smiter_curve (from tank_curve)
		* action_one.light_attack_upper: Increased armor_modifier.attack[1] to 1.5 (from 1.25, +20%)
		* action_one.light_attack_upper: Increased armor_modifier.attack[2] to 1.1 (from 0.65, +69%)
		* action_one.light_attack_upper: Increased armor_modifier.attack[5] to 1.4 (from 0.75, +87%)
		* action_one.light_attack_upper: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.75, +20%)
		* action_one.light_attack_upper: Increased critical_strike.attack_armor_power_modifer[5] to 1.2 (from 1, +20%)
		* action_one.light_attack_upper: Increased default_target.power_distribution.attack to 0.25 (from 0.2, +25%)
		* action_one.light_attack_upper: Increased range_mod to 1.5 (from 1.37, +9%)
		* action_one.light_attack_upper: Reduced critical_strike.attack_armor_power_modifer[1] to 1.2 (from 1.25, -4%)
		* action_one.light_attack_upper: Reduced targets[2].power_distribution.attack to 0.075 (from 0.1, -25%)
		* action_one.light_attack_upper: Reduced targets[2].power_distribution.impact to 0.075 (from 0.1, -25%)
		* action_one.light_attack_upper: Removed default_target.dot_balefire_variant (was true)
		* action_one.light_attack_upper: Removed default_target.dot_template_name (was burning_dot_1tick)

	$END_TB
]]

Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.damage_profile = "medium_blunt_smiter_heavy_wiz" -- official: "mace_1h_heavy_smiter_vertical"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.range_mod = 1.5 -- official: 1.37
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.damage_profile = "medium_blunt_tank_upper_1h_wiz" -- official: "mace_1h_heavy_tank_diag"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.range_mod = 1.75 -- official: 1.37
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.damage_profile = "medium_blunt_tank_upper_1h_wiz" -- official: "mace_1h_heavy_tank_diag"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.range_mod = 1.75 -- official: 1.37
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.damage_profile = "light_blunt_tank_wiz" -- official: "mace_1h_light_tank_horizontal"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.range_mod = 1.5 -- official: 1.37
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.damage_profile = "light_blunt_smiter_wiz" -- official: "mace_1h_light_smiter_vertical"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.range_mod = 1.5 -- official: 1.25
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.damage_profile = "light_blunt_tank_wiz" -- official: "light_blunt_tank"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.range_mod = 1.5 -- official: 1.37
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.damage_profile = "light_blunt_tank_wiz" -- official: "light_blunt_tank"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.range_mod = 1.5 -- official: 1.37
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.damage_profile = "light_blunt_smiter_wiz" -- official: "mace_1h_light_smiter_vertical"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.range_mod = 1.5 -- official: 1.37

-- light_blunt_smiter_wiz: replaces the existing block
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.damage_profile
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.damage_profile
NewDamageProfileTemplates.light_blunt_smiter_wiz = { -- official: mace_1h_light_smiter_vertical
	armor_modifier = {
		attack = {
			1.5, -- official: 1.25
			1.1, -- official: 0.65
			2.5,
			1,
			1.4, -- official: 0.75
			0.6,
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.2, -- official: 1.25
			0.9, -- official: 0.75
			2.75,
			1,
			1.2, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	ignore_stagger_reduction = true,
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 1.2, -- official: none
		power_distribution = {
			attack = 0.25, -- official: 0.2
			impact = 0.175,
		},
		-- removed: dot_balefire_variant (official: true)
		-- removed: dot_template_name (official: "burning_dot_1tick")
	},
	targets = {
		[2] = {
			attack_template = "slashing_smiter", -- official: "light_blunt_tank"
			boost_curve_type = "smiter_curve", -- official: "tank_curve"
			armor_modifier = { -- official: none
				attack = {
					1,
					0.25,
					1,
					1,
					0.75,
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.075, -- official: 0.1
				impact = 0.075, -- official: 0.1
			},
		},
	},
}

-- light_blunt_tank_wiz: replaces the existing block
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.damage_profile
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.light_blunt_tank_wiz = { -- official: light_blunt_tank (comments compare against it; also replaces mace_1h_light_tank_horizontal)
	armor_modifier = {
		attack = {
			1.8, -- official: 1
			0,
			1,
			1,
			1.6, -- official: 1
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.3, -- official: 1
			0.25,
			1.5,
			1,
			1.2, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.25,
	cleave_distribution = {
		attack = 0.2,
		impact = 0.6,
	},
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient_headshot = 1.4, -- official: none
		power_distribution = {
			attack = 0.05,
			impact = 0.15,
		},
	},
	targets = {
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1.5,
			power_distribution = {
				attack = 0.175,
				impact = 0.25,
			},
		},
		{
			attack_template = "light_blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.175,
			},
		},
	},
}

-- medium_blunt_smiter_heavy_wiz: replaces the existing block
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.damage_profile
NewDamageProfileTemplates.medium_blunt_smiter_heavy_wiz = { -- official: mace_1h_heavy_smiter_vertical
	armor_modifier = {
		attack = {
			1,
			0.9, -- official: 0.8
			1.75, -- official: 2
			1,
			0.75,
			-- removed: [6] (official: 1)
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.7, -- official: 0.75
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1,
			-- removed: [6] (official: 1)
		},
		impact_armor_power_modifer = {
			1,
			0.8, -- official: 1
			1,
			1,
			1,
			0.5, -- official: none
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	shield_break = true,
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 1.1, -- official: none
		boost_curve_coefficient = 2,
		power_distribution = {
			attack = 0.4, -- official: 0.3
			impact = 0.25, -- official: 0.3
		},
		-- removed: dot_balefire_variant (official: true)
		-- removed: dot_template_name (official: "burning_dot_3tick")
	},
	targets = {
		[2] = {
			attack_template = "light_blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.1,
				impact = 0.1,
			},
		},
	},
	-- removed: stagger_duration_modifier (official: 1.5)
}

-- medium_blunt_tank_upper_1h_wiz: replaces the existing block
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.damage_profile
NewDamageProfileTemplates.medium_blunt_tank_upper_1h_wiz = { -- official: mace_1h_heavy_tank_diag
	armor_modifier = {
		attack = {
			1.5, -- official: 1
			0.8, -- official: 0
			1.3, -- official: 1.5
			1.3, -- official: 1
			1.6, -- official: 0.75
		},
		impact = {
			1,
			1,
			0.5, -- official: 1
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.2, -- official: 1.3
			1,
			1.3,
			1.3,
			1.2, -- official: 1.3
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.5,
	cleave_distribution = {
		attack = 0.6,
		impact = 0.65, -- official: 0.7
	},
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient_headshot = 1.4, -- official: none
		stagger_duration_modifier = 1.5,
		power_distribution = {
			attack = 0.05,
			impact = 0.05, -- official: 0.1
		},
		-- removed: dot_balefire_variant (official: true)
		-- removed: dot_template_name (official: "burning_dot_2tick_slow_unstackable")
	},
	targets = {
		{
			attack_template = "blunt_tank", -- official: "heavy_blunt_tank"
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			power_distribution = {
				attack = 0.3, -- official: 0.15
				impact = 0.3,
			},
			-- removed: armor_modifier (official: <table>)
			-- removed: dot_balefire_variant (official: true)
			-- removed: dot_template_name (official: "burning_dot_2tick_slow_unstackable")
		},
		{
			attack_template = "blunt_tank", -- official: "heavy_blunt_tank"
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			power_distribution = {
				attack = 0.15, -- official: 0.1
				impact = 0.15, -- official: 0.2
			},
			-- removed: dot_balefire_variant (official: true)
			-- removed: dot_template_name (official: "burning_dot_2tick_slow_unstackable")
		},
		{
			attack_template = "light_blunt_tank",
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			power_distribution = {
				attack = 0.075,
				impact = 0.1, -- official: 0.15
			},
			-- removed: dot_balefire_variant (official: true)
			-- removed: dot_template_name (official: "burning_dot_2tick_slow_unstackable")
		},
	},
}

-- ======== one_handed_spears_shield_template ========

--[[
	$BEGIN_TB
		## one_handed_spears_shield_template

		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_spears_shield_template.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- ======== one_handed_sword_shield_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_sword_shield_template_1

		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.heavy_attack: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_sword_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- uses shield_slam (exported under one_hand_axe_shield_template_1)

-- uses shield_slam_target (exported under one_hand_axe_shield_template_1)

-- ======== one_handed_sword_shield_template_2 ========

--[[
	$BEGIN_TB
		## one_handed_sword_shield_template_2

		* action_one.default: Added blocking_charge: true
		* action_one.default: Added blocking_charge_start_time: 0.3
		* action_one.default: Removed allowed_chain_actions[6] (was <table>)
		* action_one.default_left: Removed allowed_chain_actions[6] (was <table>)
		* action_one.default_left_heavy: Removed allowed_chain_actions[6] (was <table>)
		* action_one.default_stab_heavy: Added blocking_charge: true
		* action_one.default_stab_heavy: Added blocking_charge_start_time: 0.3
		* action_one.default_stab_heavy: Removed allowed_chain_actions[6] (was <table>)
		* action_one.heavy_attack_right: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.heavy_attack_right: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.light_attack_left: Changed damage_profile to tb_bretsword_shield_light_1 (from light_slashing_linesman)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 2 (from 1, +100%)
		* action_one.light_attack_right: Added shield_break: true
		* action_one.light_attack_right: Changed damage_profile to tb_bretsword_shield_light_2 (from light_slashing_smiter)
		* action_one.light_attack_right: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_right: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_right: Reduced allowed_chain_actions[1].start_time to 0.6 (from 0.75, -20%)
		* action_one.light_attack_shield: Added shield_break: true
		* action_one.light_attack_shield: Changed damage_profile_aoe to tb_bretsword_shield_light_shield_bash (from shield_slam_shotgun_aoe)
		* action_one.light_attack_shield: Increased critical_strike.impact_armor_power_modifer[5] to 2 (from 1, +100%)
		* action_one.light_attack_shield: Reduced allowed_chain_actions[1].start_time to 0.32 (from 0.65, -51%)
		* action_one.push: Changed damage_profile_inner to medium_push (from shield_push)

	$END_TB
]]

Weapons.one_handed_sword_shield_template_2.actions.action_one.default.allowed_chain_actions[6] = nil -- official: <table>
Weapons.one_handed_sword_shield_template_2.actions.action_one.default.blocking_charge = true -- official: none
Weapons.one_handed_sword_shield_template_2.actions.action_one.default.blocking_charge_start_time = 0.3 -- official: none
Weapons.one_handed_sword_shield_template_2.actions.action_one.default_left.allowed_chain_actions[6] = nil -- official: <table>
Weapons.one_handed_sword_shield_template_2.actions.action_one.default_left_heavy.allowed_chain_actions[6] = nil -- official: <table>
Weapons.one_handed_sword_shield_template_2.actions.action_one.default_stab_heavy.allowed_chain_actions[6] = nil -- official: <table>
Weapons.one_handed_sword_shield_template_2.actions.action_one.default_stab_heavy.blocking_charge = true -- official: none
Weapons.one_handed_sword_shield_template_2.actions.action_one.default_stab_heavy.blocking_charge_start_time = 0.3 -- official: none
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_left.damage_profile = "tb_bretsword_shield_light_1" -- official: "light_slashing_linesman"
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_right.allowed_chain_actions[1].start_time = 0.6 -- official: 0.75
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_right.damage_profile = "tb_bretsword_shield_light_2" -- official: "light_slashing_smiter"
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_shield.allowed_chain_actions[1].start_time = 0.32 -- official: 0.65
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_shield.damage_profile_aoe = "tb_bretsword_shield_light_shield_bash" -- official: "shield_slam_shotgun_aoe"
Weapons.one_handed_sword_shield_template_2.actions.action_one.push.damage_profile_inner = "medium_push" -- official: "shield_push"

-- uses shield_slam (exported under one_hand_axe_shield_template_1)

-- uses shield_slam_target (exported under one_hand_axe_shield_template_1)

-- tb_bretsword_shield_light_1: replaces the existing block
-- used by Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_left.damage_profile
NewDamageProfileTemplates.tb_bretsword_shield_light_1 = { -- official: light_slashing_linesman
	armor_modifier = {
		attack = {
			2, -- official: 1
			0,
			2,
			1,
			1,
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = "critical_strike_linesman_L",
	cleave_distribution = "cleave_distribution_linesman_L",
	default_target = "default_target_linesman_L",
	targets = "targets_linesman_L",
}

-- tb_bretsword_shield_light_2: replaces the existing block
-- used by Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.tb_bretsword_shield_light_2 = { -- official: light_slashing_smiter
	armor_modifier = "armor_modifier_smiter_L", -- preset values changed since official
	charge_value = "light_attack",
	critical_strike = "critical_strike_smiter_L",
	cleave_distribution = "cleave_distribution_smiter_default",
	ignore_stagger_reduction = true,
	shield_break = true, -- official: none
	default_target = "default_target_smiter_L",
	targets = "targets_smiter_L",
}

-- tb_bretsword_shield_light_shield_bash: replaces the existing block
-- used by Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_shield.damage_profile_aoe
NewDamageProfileTemplates.tb_bretsword_shield_light_shield_bash = { -- official: shield_slam_shotgun_aoe
	armor_modifier = "armor_modifier_slam_tank_L",
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_slam_tank_L",
	shield_break = true, -- official: none
	no_damage = true,
	default_target = "aoe_target_settings_slam_tank_L",
	targets = {
	},
}

-- ======== one_handed_swords_template_1 ========

--[[
	$BEGIN_TB
		## one_handed_swords_template_1

		* Reduced dodge_count to 4 (from 6, -33%)
		* action_one.heavy_attack_left: Changed targets[1].boost_curve_type to ninja_curve (from tank_curve)
		* action_one.heavy_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.5, +80%)
		* action_one.heavy_attack_left: Increased critical_strike.attack_armor_power_modifer[3] to 3 (from 1, +200%)
		* action_one.heavy_attack_left: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack_left: Increased range_mod to 1.4 (from 1.25, +12%)
		* action_one.heavy_attack_left: Increased targets[1].armor_modifier.attack[2] to 0.65 (from 0.6, +8%)
		* action_one.heavy_attack_left: Increased targets[1].armor_modifier.attack[3] to 2 (from 1.75, +14%)
		* action_one.heavy_attack_left: Increased targets[1].power_distribution.attack to 0.35 (from 0.32, +9%)
		* action_one.heavy_attack_left: Reduced cleave_distribution.attack to 0.2 (from 0.3, -33%)
		* action_one.heavy_attack_left: Reduced cleave_distribution.impact to 0.6 (from 0.8, -25%)
		* action_one.heavy_attack_left: Reduced targets[1].boost_curve_coefficient_headshot to 1.5 (from 2, -25%)
		* action_one.heavy_attack_left: Reduced targets[2].power_distribution.attack to 0.175 (from 0.18, -3%)
		* action_one.heavy_attack_left: Reduced targets[3].power_distribution.attack to 0.1 (from 0.15, -33%)
		* action_one.heavy_attack_right: Changed targets[1].boost_curve_type to ninja_curve (from tank_curve)
		* action_one.heavy_attack_right: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.5, +80%)
		* action_one.heavy_attack_right: Increased critical_strike.attack_armor_power_modifer[3] to 3 (from 1, +200%)
		* action_one.heavy_attack_right: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack_right: Increased range_mod to 1.4 (from 1.25, +12%)
		* action_one.heavy_attack_right: Increased targets[1].armor_modifier.attack[2] to 0.65 (from 0.6, +8%)
		* action_one.heavy_attack_right: Increased targets[1].armor_modifier.attack[3] to 2 (from 1.75, +14%)
		* action_one.heavy_attack_right: Increased targets[1].power_distribution.attack to 0.35 (from 0.32, +9%)
		* action_one.heavy_attack_right: Reduced cleave_distribution.attack to 0.2 (from 0.3, -33%)
		* action_one.heavy_attack_right: Reduced cleave_distribution.impact to 0.6 (from 0.8, -25%)
		* action_one.heavy_attack_right: Reduced targets[1].boost_curve_coefficient_headshot to 1.5 (from 2, -25%)
		* action_one.heavy_attack_right: Reduced targets[2].power_distribution.attack to 0.175 (from 0.18, -3%)
		* action_one.heavy_attack_right: Reduced targets[3].power_distribution.attack to 0.1 (from 0.15, -33%)
		* action_one.light_attack_last: Added shield_break: true
		* action_one.light_attack_last: Increased range_mod to 1.4 (from 1.2, +17%)
		* action_one.light_attack_left: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman_finesse)
		* action_one.light_attack_left: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_left: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_right: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman_finesse)
		* action_one.light_attack_right: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_right: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)

	$END_TB
]]

Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_left.range_mod = 1.4 -- official: 1.25
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_right.range_mod = 1.4 -- official: 1.25
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_last.range_mod = 1.4 -- official: 1.2
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman_finesse"
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman_finesse"
Weapons.one_handed_swords_template_1.dodge_count = 4 -- official: 6

-- medium_slashing_tank_1h_finesse (official profile, changed in place)
-- in shared preset cleave_distribution_tank_L: also changes light_blunt_tank, light_blunt_tank_diag, light_blunt_tank_upper (4 profiles)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.cleave_distribution.attack = 0.2 -- official: 0.3
-- in shared preset cleave_distribution_tank_L: also changes light_blunt_tank, light_blunt_tank_diag, light_blunt_tank_upper (4 profiles)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.cleave_distribution.impact = 0.6 -- official: 0.8
-- in shared preset critical_strike_stab_smiter_H.attack_armor_power_modifer: also changes heavy_slashing_smiter_stab (2 profiles)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.critical_strike.attack_armor_power_modifer[2] = 0.9 -- official: 0.5
-- in shared preset critical_strike_stab_smiter_H.attack_armor_power_modifer: also changes heavy_slashing_smiter_stab (2 profiles)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.critical_strike.attack_armor_power_modifer[3] = 3 -- official: 1
-- in shared preset critical_strike_stab_smiter_H.impact_armor_power_modifer: also changes heavy_slashing_smiter_stab (2 profiles)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.critical_strike.impact_armor_power_modifer[3] = 1 -- official: 0.5
-- in preset targets_tank_M_1h_finesse[1].armor_modifier.attack (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].armor_modifier.attack[2] = 0.65 -- official: 0.6
-- in preset targets_tank_M_1h_finesse[1].armor_modifier.attack (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].armor_modifier.attack[3] = 2 -- official: 1.75
-- in preset targets_tank_M_1h_finesse[1] (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_coefficient_headshot = 1.5 -- official: 2
-- in preset targets_tank_M_1h_finesse[1] (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_type = "ninja_curve" -- official: "tank_curve"
-- in preset targets_tank_M_1h_finesse[1].power_distribution (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].power_distribution.attack = 0.35 -- official: 0.32
-- in preset targets_tank_M_1h_finesse[2].power_distribution (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[2].power_distribution.attack = 0.175 -- official: 0.18
-- in preset targets_tank_M_1h_finesse[3].power_distribution (only this profile uses it)
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[3].power_distribution.attack = 0.1 -- official: 0.15

-- sword_1h_light_smiter_vertical (official profile, changed in place)
DamageProfileTemplates.sword_1h_light_smiter_vertical.shield_break = true -- official: none

-- uses tb_1h_sword_light_1_2 (exported under dual_wield_hammer_sword_template)

-- ======== staff_scythe ========

--[[
	$BEGIN_TB
		## staff_scythe

		* action_one.heavy_attack_01: Added hit_mass_count.beastmen_bestigor: 0.6
		* action_one.heavy_attack_01: Added hit_mass_count.chaos_warrior: 0.5
		* action_one.heavy_attack_01: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_one.heavy_attack_01: Added hit_mass_count.skaven_storm_vermin: 0.5
		* action_one.heavy_attack_01: Added hit_mass_count.skaven_storm_vermin_commander: 0.5
		* action_one.heavy_attack_01: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_one.heavy_attack_02: Added hit_mass_count.beastmen_bestigor: 0.6
		* action_one.heavy_attack_02: Added hit_mass_count.chaos_warrior: 0.5
		* action_one.heavy_attack_02: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_one.heavy_attack_02: Added hit_mass_count.skaven_storm_vermin: 0.5
		* action_one.heavy_attack_02: Added hit_mass_count.skaven_storm_vermin_commander: 0.5
		* action_one.heavy_attack_02: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_one.heavy_attack_03: Increased targets[1].power_distribution.attack to 0.55 (from 0.5, +10%)
		* action_one.light_attack_01: Changed weapon_mode_overrides.scythe.damage_profile to medium_slashing_smiter (from medium_slashing_smiter_2h)
		* action_one.light_attack_02: Added targets[1].boost_curve_coefficient: 2
		* action_one.light_attack_02: Changed weapon_mode_overrides.scythe.damage_profile to staff_scythe_L2_PA (from medium_slashing_axe_linesman_burning)
		* action_one.light_attack_02: Increased critical_strike.attack_armor_power_modifer[2] to 0.8 (from 0.5, +60%)
		* action_one.light_attack_02: Increased critical_strike.attack_armor_power_modifer[3] to 2.5 (from 1.5, +67%)
		* action_one.light_attack_02: Increased targets[1].armor_modifier.attack[2] to 0.8 (from 0.5, +60%)
		* action_one.light_attack_02: Increased targets[1].armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_02: Increased targets[1].power_distribution.attack to 0.4 (from 0.25, +60%)
		* action_one.light_attack_02: Increased targets[1].power_distribution.impact to 0.25 (from 0.2, +25%)
		* action_one.light_attack_02: Reduced targets[1].armor_modifier.attack[3] to 1.75 (from 1.8, -3%)
		* action_one.light_attack_02: Reduced targets[1].armor_modifier.impact[2] to 0.6 (from 0.75, -20%)
		* action_one.light_attack_02: Removed targets[1].boost_curve_coefficient_headshot (was 1.5)
		* action_one.light_attack_03: Added hit_mass_count: <table>
		* action_one.light_attack_04: Added hit_mass_count: <table>
		* action_one.light_attack_bopp: Added targets[1].boost_curve_coefficient: 2
		* action_one.light_attack_bopp: Changed weapon_mode_overrides.scythe.damage_profile to staff_scythe_L2_PA (from medium_slashing_axe_linesman_burning)
		* action_one.light_attack_bopp: Increased critical_strike.attack_armor_power_modifer[2] to 0.8 (from 0.5, +60%)
		* action_one.light_attack_bopp: Increased critical_strike.attack_armor_power_modifer[3] to 2.5 (from 1.5, +67%)
		* action_one.light_attack_bopp: Increased targets[1].armor_modifier.attack[2] to 0.8 (from 0.5, +60%)
		* action_one.light_attack_bopp: Increased targets[1].armor_modifier.impact[1] to 1 (from 0.9, +11%)
		* action_one.light_attack_bopp: Increased targets[1].power_distribution.attack to 0.4 (from 0.25, +60%)
		* action_one.light_attack_bopp: Increased targets[1].power_distribution.impact to 0.25 (from 0.2, +25%)
		* action_one.light_attack_bopp: Reduced targets[1].armor_modifier.attack[3] to 1.75 (from 1.8, -3%)
		* action_one.light_attack_bopp: Reduced targets[1].armor_modifier.impact[2] to 0.6 (from 0.75, -20%)
		* action_one.light_attack_bopp: Removed targets[1].boost_curve_coefficient_headshot (was 1.5)
		* action_three.special_action_attack: Added is_discharge: true
		* action_three.special_action_attack: Increased default_target.power_distribution.attack to 0.07 (from 0.015, +367%)
		* action_three.special_action_attack: Reduced default_target.power_distribution.impact to 0.3 (from 0.5, -40%)
		* action_three.special_action_attack: Removed default_target.dot_balefire_variant (was true)
		* action_three.special_action_attack: Removed default_target.dot_template_name (was burning_dot_scythe_special)

	$END_TB
]]

Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count.beastmen_bestigor = 0.6 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count.chaos_warrior = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count.skaven_storm_vermin = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count.skaven_storm_vermin_commander = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count.beastmen_bestigor = 0.6 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count.chaos_warrior = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count.skaven_storm_vermin = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count.skaven_storm_vermin_commander = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.staff_scythe.actions.action_one.light_attack_01.weapon_mode_overrides.scythe.damage_profile = "medium_slashing_smiter" -- official: "medium_slashing_smiter_2h"
Weapons.staff_scythe.actions.action_one.light_attack_02.weapon_mode_overrides.scythe.damage_profile = "staff_scythe_L2_PA" -- official: "medium_slashing_axe_linesman_burning"
Weapons.staff_scythe.actions.action_one.light_attack_03.hit_mass_count = { -- official: none
	beastmen_gor = 0.6,
	beastmen_ungor = 0.6,
	chaos_berzerker = 0.6,
	chaos_fanatic = 0.6,
	chaos_marauder = 0.6,
	chaos_marauder_with_shield = 0.6,
	chaos_raider = 0.6,
	skaven_clan_rat = 0.6,
	skaven_clan_rat_with_shield = 0.6,
	skaven_plague_monk = 0.6,
	skaven_slave = 0.6,
}
Weapons.staff_scythe.actions.action_one.light_attack_04.hit_mass_count = { -- official: none
	beastmen_gor = 0.6,
	beastmen_ungor = 0.6,
	chaos_berzerker = 0.6,
	chaos_fanatic = 0.6,
	chaos_marauder = 0.6,
	chaos_marauder_with_shield = 0.6,
	chaos_raider = 0.6,
	skaven_clan_rat = 0.6,
	skaven_clan_rat_with_shield = 0.6,
	skaven_plague_monk = 0.6,
	skaven_slave = 0.6,
}
Weapons.staff_scythe.actions.action_one.light_attack_bopp.weapon_mode_overrides.scythe.damage_profile = "staff_scythe_L2_PA" -- official: "medium_slashing_axe_linesman_burning"

-- heavy_slashing_linesman_scythe_diagonal (official profile, changed in place)
DamageProfileTemplates.heavy_slashing_linesman_scythe_diagonal.targets[1].power_distribution.attack = 0.55 -- official: 0.5

-- scythe_discharge (official profile, changed in place)
DamageProfileTemplates.scythe_discharge.default_target.dot_balefire_variant = nil -- official: true
DamageProfileTemplates.scythe_discharge.default_target.dot_template_name = nil -- official: "burning_dot_scythe_special"
DamageProfileTemplates.scythe_discharge.default_target.power_distribution.attack = 0.07 -- official: 0.015
DamageProfileTemplates.scythe_discharge.default_target.power_distribution.impact = 0.3 -- official: 0.5
DamageProfileTemplates.scythe_discharge.is_discharge = true -- official: none

-- staff_scythe_L2_PA: replaces the existing block
-- used by Weapons.staff_scythe.actions.action_one.light_attack_02.weapon_mode_overrides.scythe.damage_profile
-- used by Weapons.staff_scythe.actions.action_one.light_attack_bopp.weapon_mode_overrides.scythe.damage_profile
NewDamageProfileTemplates.staff_scythe_L2_PA = { -- official: medium_slashing_axe_linesman_burning
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.8,
			1,
			0.75,
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8, -- official: 0.5
			2.5, -- official: 1.5
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.275,
		impact = 0.25,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2, -- official: none
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			armor_modifier = {
				attack = {
					1,
					0.8, -- official: 0.5
					1.75, -- official: 1.8
					1,
					0.75,
				},
				impact = {
					1, -- official: 0.9
					0.6, -- official: 0.75
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.4, -- official: 0.25
				impact = 0.25, -- official: 0.2
			},
			-- removed: boost_curve_coefficient_headshot (official: 1.5)
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.15,
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.1,
				impact = 0.1,
			},
		},
	},
}

-- ======== two_handed_axes_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_axes_template_1

		* action_one.heavy_attack_left: Added hit_mass_count.beastmen_bestigor: 0.6
		* action_one.heavy_attack_left: Added hit_mass_count.chaos_warrior: 0.5
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_storm_vermin: 0.5
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_storm_vermin_commander: 0.5
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_one.heavy_attack_left: Added slide_armour_hit: true
		* action_one.heavy_attack_left: Changed damage_profile to heavy_2h_axe_tb (from heavy_slashing_axe_linesman)
		* action_one.heavy_attack_left: Increased cleave_distribution.attack to 0.6 (from 0.35, +71%)
		* action_one.heavy_attack_left: Increased targets[3].power_distribution.attack to 0.25 (from 0.125, +100%)
		* action_one.heavy_attack_left: Reduced critical_strike.attack_armor_power_modifer[2] to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_left: Reduced targets[1].armor_modifier.attack[2] to 0.5 (from 0.75, -33%)
		* action_one.heavy_attack_right: Added hit_mass_count.beastmen_bestigor: 0.6
		* action_one.heavy_attack_right: Added hit_mass_count.chaos_warrior: 0.5
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_storm_vermin: 0.5
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_storm_vermin_commander: 0.5
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_one.heavy_attack_right: Added slide_armour_hit: true
		* action_one.heavy_attack_right: Changed damage_profile to heavy_2h_axe_tb (from heavy_slashing_axe_linesman)
		* action_one.heavy_attack_right: Increased cleave_distribution.attack to 0.6 (from 0.35, +71%)
		* action_one.heavy_attack_right: Increased targets[3].power_distribution.attack to 0.25 (from 0.125, +100%)
		* action_one.heavy_attack_right: Reduced critical_strike.attack_armor_power_modifer[2] to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_right: Reduced targets[1].armor_modifier.attack[2] to 0.5 (from 0.75, -33%)
		* action_one.light_attack_bopp: Added additional_critical_strike_chance: 0.1
		* action_one.light_attack_bopp: Changed damage_profile to bopp_2h_axe_tb (from medium_slashing_axe_linesman)
		* action_one.light_attack_bopp: Increased cleave_distribution.impact to 0.6 (from 0.25, +140%)
		* action_one.light_attack_up: Increased anim_time_scale to 0.9 (from 0.81, +11%)

	$END_TB
]]

Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_2h_axe_tb" -- official: "heavy_slashing_axe_linesman"
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count.beastmen_bestigor = 0.6 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_warrior = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_storm_vermin = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_storm_vermin_commander = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.slide_armour_hit = true -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.damage_profile = "heavy_2h_axe_tb" -- official: "heavy_slashing_axe_linesman"
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count.beastmen_bestigor = 0.6 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_warrior = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_storm_vermin = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_storm_vermin_commander = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.slide_armour_hit = true -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.1 -- official: none
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.damage_profile = "bopp_2h_axe_tb" -- official: "medium_slashing_axe_linesman"
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_up.anim_time_scale = 0.9 -- official: 0.81

-- bopp_2h_axe_tb: replaces the existing block
-- used by Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.damage_profile
NewDamageProfileTemplates.bopp_2h_axe_tb = { -- official: medium_slashing_axe_linesman
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.5,
			1,
			0.75,
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.275,
		impact = 0.6, -- official: 0.25
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.5,
			armor_modifier = {
				attack = {
					1,
					0.3,
					1.5,
					1,
					0.75,
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.25,
				impact = 0.2,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15,
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.1,
				impact = 0.1,
			},
		},
	},
}

-- heavy_2h_axe_tb: replaces the existing block
-- used by Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.damage_profile
NewDamageProfileTemplates.heavy_2h_axe_tb = { -- official: heavy_slashing_axe_linesman
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.5,
			1,
			0.75,
			0,
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75,
			0.25,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.6, -- official: 0.75
			2,
			1,
			1,
			0.75,
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
	cleave_distribution = {
		attack = 0.6, -- official: 0.35
		impact = 0.35,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.75,
		power_distribution = {
			attack = 0.1,
			impact = 0.125,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			armor_modifier = {
				attack = {
					0.9,
					0.5, -- official: 0.75
					2,
					1,
					0.75,
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.5,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			power_distribution = {
				attack = 0.25,
				impact = 0.15,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			power_distribution = {
				attack = 0.25, -- official: 0.125
				impact = 0.125,
			},
		},
	},
}

-- ======== two_handed_axes_template_2 ========

--[[
	$BEGIN_TB
		## two_handed_axes_template_2

		* action_one.heavy_attack_down_first: Changed damage_profile to heavy_slashing_smiter_glaive (from medium_slashing_smiter_upper)
		* action_one.heavy_attack_down_first: Removed hit_mass_count (was <table>)
		* action_one.light_attack_bopp: Added hit_mass_count: <table>
		* action_one.light_attack_bopp: Increased anim_time_scale to 1.14 (from 1.0924999999999998, +4%)
		* action_one.light_attack_bopp: Increased cleave_distribution.attack to 0.36 (from 0.275, +31%)
		* action_one.light_attack_bopp: Increased cleave_distribution.impact to 0.36 (from 0.25, +44%)
		* action_one.light_attack_left: Increased anim_time_scale to 1.3299999999999998 (from 1.1875, +12%)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.36 (from 0.275, +31%)
		* action_one.light_attack_left: Increased cleave_distribution.impact to 0.36 (from 0.25, +44%)
		* action_one.light_attack_left_upward: Increased anim_time_scale to 1.0924999999999998 (from 0.95, +15%)
		* action_one.light_attack_left_upward: Increased cleave_distribution.attack to 0.36 (from 0.275, +31%)
		* action_one.light_attack_left_upward: Increased cleave_distribution.impact to 0.36 (from 0.25, +44%)
		* action_one.light_attack_right_upward: Increased cleave_distribution.attack to 0.36 (from 0.275, +31%)
		* action_one.light_attack_right_upward: Increased cleave_distribution.impact to 0.36 (from 0.25, +44%)

	$END_TB
]]

Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.damage_profile = "heavy_slashing_smiter_glaive" -- official: "medium_slashing_smiter_upper"
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.hit_mass_count = nil -- official: <table>
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.anim_time_scale = 1.14 -- official: 1.0924999999999998
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.hit_mass_count = { -- official: none
	beastmen_gor = 0.6,
	beastmen_ungor = 0.6,
	chaos_berzerker = 0.6,
	chaos_fanatic = 0.6,
	chaos_marauder = 0.6,
	chaos_marauder_with_shield = 0.6,
	chaos_raider = 0.6,
	skaven_clan_rat = 0.6,
	skaven_clan_rat_with_shield = 0.6,
	skaven_plague_monk = 0.6,
	skaven_slave = 0.6,
}
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_left.anim_time_scale = 1.3299999999999998 -- official: 1.1875
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_left_upward.anim_time_scale = 1.0924999999999998 -- official: 0.95

-- medium_slashing_axe_linesman (official profile, changed in place)
-- in shared preset cleave_distribution_axe_linesman_M: also changes medium_slashing_axe_linesman_1h, medium_slashing_axe_linesman_dual (3 profiles)
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.36 -- official: 0.275
-- in shared preset cleave_distribution_axe_linesman_M: also changes medium_slashing_axe_linesman_1h, medium_slashing_axe_linesman_dual (3 profiles)
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.impact = 0.36 -- official: 0.25

-- ======== two_handed_cog_hammers_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_cog_hammers_template_1

		* action_one.default: Added allowed_chain_actions[2].end_time: 1.2
		* action_one.default: Added allowed_chain_actions[5].blocker: true
		* action_one.default: Added allowed_chain_actions[5].end_time: 1.2
		* action_one.default: Added allowed_chain_actions[5].input: action_one_hold
		* action_one.default: Added allowed_chain_actions[6]: <table>
		* action_one.default: Reduced buff_data[1].external_multiplier to 0.6 (from 0.7, -14%)
		* action_one.default: Removed allowed_chain_actions[5].action (was action_one)
		* action_one.default: Removed allowed_chain_actions[5].auto_chain (was true)
		* action_one.default: Removed allowed_chain_actions[5].sub_action (was heavy_attack_left)
		* action_one.default_last: Added allowed_chain_actions[2].end_time: 1.2
		* action_one.default_last: Added allowed_chain_actions[5].blocker: true
		* action_one.default_last: Added allowed_chain_actions[5].end_time: 1.2
		* action_one.default_last: Added allowed_chain_actions[5].input: action_one_hold
		* action_one.default_last: Added allowed_chain_actions[6]: <table>
		* action_one.default_last: Reduced allowed_chain_actions[5].start_time to 0.6 (from 0.7, -14%)
		* action_one.default_last: Removed allowed_chain_actions[5].action (was action_one)
		* action_one.default_last: Removed allowed_chain_actions[5].auto_chain (was true)
		* action_one.default_last: Removed allowed_chain_actions[5].sub_action (was heavy_attack_right)
		* action_one.default_left: Added allowed_chain_actions[2].end_time: 1.2
		* action_one.default_left: Added allowed_chain_actions[5].blocker: true
		* action_one.default_left: Added allowed_chain_actions[5].end_time: 1.2
		* action_one.default_left: Added allowed_chain_actions[5].input: action_one_hold
		* action_one.default_left: Added allowed_chain_actions[6]: <table>
		* action_one.default_left: Reduced allowed_chain_actions[5].start_time to 0.6 (from 0.7, -14%)
		* action_one.default_left: Removed allowed_chain_actions[5].action (was action_one)
		* action_one.default_left: Removed allowed_chain_actions[5].auto_chain (was true)
		* action_one.default_left: Removed allowed_chain_actions[5].sub_action (was heavy_attack_right)
		* action_one.default_right: Added allowed_chain_actions[2].end_time: 1.2
		* action_one.default_right: Added allowed_chain_actions[5].blocker: true
		* action_one.default_right: Added allowed_chain_actions[5].end_time: 1.2
		* action_one.default_right: Added allowed_chain_actions[5].input: action_one_hold
		* action_one.default_right: Added allowed_chain_actions[6]: <table>
		* action_one.default_right: Reduced allowed_chain_actions[5].start_time to 0.6 (from 0.7, -14%)
		* action_one.default_right: Removed allowed_chain_actions[5].action (was action_one)
		* action_one.default_right: Removed allowed_chain_actions[5].auto_chain (was true)
		* action_one.default_right: Removed allowed_chain_actions[5].sub_action (was heavy_attack_left)
		* action_one.heavy_attack_left: Added allowed_chain_actions[2].release_required: action_one_hold
		* action_one.heavy_attack_left: Added allowed_chain_actions[5].end_time: 0.3
		* action_one.heavy_attack_left: Added allowed_chain_actions[6]: <table>
		* action_one.heavy_attack_left: Added allowed_chain_actions[7]: <table>
		* action_one.heavy_attack_left: Changed allowed_chain_actions[2].sub_action to default_left (from default)
		* action_one.heavy_attack_left: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.heavy_attack_left: Changed allowed_chain_actions[3].input to action_one (from action_two_hold)
		* action_one.heavy_attack_left: Changed allowed_chain_actions[4].action to action_one (from action_two)
		* action_one.heavy_attack_left: Changed allowed_chain_actions[4].input to action_one_hold (from action_two_hold)
		* action_one.heavy_attack_left: Changed allowed_chain_actions[5].action to action_two (from action_wield)
		* action_one.heavy_attack_left: Changed allowed_chain_actions[5].input to action_two_hold (from action_wield)
		* action_one.heavy_attack_left: Increased allowed_chain_actions[3].start_time to 2.2 (from 0)
		* action_one.heavy_attack_left: Increased allowed_chain_actions[4].start_time to 2.2 (from 0.75, +193%)
		* action_one.heavy_attack_left: Reduced allowed_chain_actions[2].start_time to 0.6 (from 2, -70%)
		* action_one.heavy_attack_left: Reduced allowed_chain_actions[5].start_time to 0 (from 0.5, -100%)
		* action_one.heavy_attack_left: Removed allowed_chain_actions[3].end_time (was 0.3)
		* action_one.heavy_attack_right: Added allowed_chain_actions[2].release_required: action_one_hold
		* action_one.heavy_attack_right: Added allowed_chain_actions[5].end_time: 0.3
		* action_one.heavy_attack_right: Added allowed_chain_actions[6]: <table>
		* action_one.heavy_attack_right: Added allowed_chain_actions[7]: <table>
		* action_one.heavy_attack_right: Changed allowed_chain_actions[2].sub_action to default_right (from default)
		* action_one.heavy_attack_right: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.heavy_attack_right: Changed allowed_chain_actions[3].input to action_one (from action_two_hold)
		* action_one.heavy_attack_right: Changed allowed_chain_actions[4].action to action_one (from action_two)
		* action_one.heavy_attack_right: Changed allowed_chain_actions[4].input to action_one_hold (from action_two_hold)
		* action_one.heavy_attack_right: Changed allowed_chain_actions[5].action to action_two (from action_wield)
		* action_one.heavy_attack_right: Changed allowed_chain_actions[5].input to action_two_hold (from action_wield)
		* action_one.heavy_attack_right: Increased allowed_chain_actions[3].start_time to 2 (from 0)
		* action_one.heavy_attack_right: Increased allowed_chain_actions[4].start_time to 2 (from 0.75, +167%)
		* action_one.heavy_attack_right: Reduced allowed_chain_actions[2].start_time to 0.6 (from 2.2, -73%)
		* action_one.heavy_attack_right: Reduced allowed_chain_actions[5].start_time to 0 (from 0.5, -100%)
		* action_one.heavy_attack_right: Removed allowed_chain_actions[3].end_time (was 0.3)
		* action_one.light_attack_bopp: Added allowed_chain_actions[5]: <table>
		* action_one.light_attack_bopp: Added allowed_chain_actions[6]: <table>
		* action_one.light_attack_bopp: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.light_attack_bopp: Changed allowed_chain_actions[3].input to action_one (from action_two_hold)
		* action_one.light_attack_bopp: Changed allowed_chain_actions[4].action to action_one (from action_wield)
		* action_one.light_attack_bopp: Changed allowed_chain_actions[4].input to action_one_hold (from action_wield)
		* action_one.light_attack_bopp: Increased allowed_chain_actions[3].start_time to 1.5 (from 0.65, +131%)
		* action_one.light_attack_bopp: Increased allowed_chain_actions[4].start_time to 1.5 (from 0.65, +131%)
		* action_one.light_attack_bopp: Removed allowed_chain_actions[1].release_required (was action_two_hold)
		* action_one.light_attack_bopp: Removed allowed_chain_actions[2].release_required (was action_two_hold)
		* action_one.light_attack_last: Added allowed_chain_actions[1].end_time: 1.2
		* action_one.light_attack_last: Added allowed_chain_actions[5]: <table>
		* action_one.light_attack_last: Added allowed_chain_actions[6]: <table>
		* action_one.light_attack_last: Added allowed_chain_actions[7]: <table>
		* action_one.light_attack_last: Changed allowed_chain_actions[2].action to action_one (from action_two)
		* action_one.light_attack_last: Changed allowed_chain_actions[2].input to action_one_hold (from action_two_hold)
		* action_one.light_attack_last: Changed allowed_chain_actions[2].sub_action to default_last (from default)
		* action_one.light_attack_last: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.light_attack_last: Changed allowed_chain_actions[3].input to action_one (from action_two_hold)
		* action_one.light_attack_last: Changed allowed_chain_actions[4].action to action_one (from action_wield)
		* action_one.light_attack_last: Changed allowed_chain_actions[4].input to action_one_hold (from action_wield)
		* action_one.light_attack_last: Increased allowed_chain_actions[2].end_time to 1.2 (from 0.3, +300%)
		* action_one.light_attack_last: Increased allowed_chain_actions[2].start_time to 0.65 (from 0)
		* action_one.light_attack_last: Increased allowed_chain_actions[3].start_time to 1.2 (from 0.6, +100%)
		* action_one.light_attack_last: Increased allowed_chain_actions[4].start_time to 1.2 (from 0.6, +100%)
		* action_one.light_attack_left: Added allowed_chain_actions[1].end_time: 1.2
		* action_one.light_attack_left: Added allowed_chain_actions[5]: <table>
		* action_one.light_attack_left: Added allowed_chain_actions[6]: <table>
		* action_one.light_attack_left: Added allowed_chain_actions[7]: <table>
		* action_one.light_attack_left: Changed allowed_chain_actions[2].action to action_one (from action_two)
		* action_one.light_attack_left: Changed allowed_chain_actions[2].input to action_one_hold (from action_two_hold)
		* action_one.light_attack_left: Changed allowed_chain_actions[2].sub_action to default_left (from default)
		* action_one.light_attack_left: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.light_attack_left: Changed allowed_chain_actions[3].input to action_one_hold (from action_two_hold)
		* action_one.light_attack_left: Changed allowed_chain_actions[4].action to action_one (from action_wield)
		* action_one.light_attack_left: Changed allowed_chain_actions[4].input to action_one (from action_wield)
		* action_one.light_attack_left: Changed anim_event to attack_swing_up_pose (from attack_swing_up)
		* action_one.light_attack_left: Increased allowed_chain_actions[2].end_time to 1.2 (from 0.3, +300%)
		* action_one.light_attack_left: Increased allowed_chain_actions[2].start_time to 0.65 (from 0)
		* action_one.light_attack_left: Increased allowed_chain_actions[3].start_time to 1.2 (from 0.6, +100%)
		* action_one.light_attack_left: Increased allowed_chain_actions[4].start_time to 1.2 (from 0.6, +100%)
		* action_one.light_attack_left: Increased baked_sweep[1][3] to 0.5904569625854492 (from 0.5812749862670898, +2%)
		* action_one.light_attack_left: Increased baked_sweep[1][6] to -0.29107052087783813 (from -0.37621578574180603, +23%)
		* action_one.light_attack_left: Increased baked_sweep[1][7] to 0.5494855046272278 (from 0.46924009919166565, +17%)
		* action_one.light_attack_left: Increased baked_sweep[1][8] to 0.302474707365036 (from 0.29052433371543884, +4%)
		* action_one.light_attack_left: Increased baked_sweep[2][3] to 0.6366815567016602 (from 0.6298847198486328, +1%)
		* action_one.light_attack_left: Increased baked_sweep[2][6] to -0.14280153810977936 (from -0.15851706266403198, +10%)
		* action_one.light_attack_left: Increased baked_sweep[2][7] to 0.5783776640892029 (from 0.5100840926170349, +13%)
		* action_one.light_attack_left: Increased baked_sweep[3][3] to 0.6041536331176758 (from 0.6009492874145508, +1%)
		* action_one.light_attack_left: Increased baked_sweep[3][7] to 0.5306860208511353 (from 0.4955514967441559, +7%)
		* action_one.light_attack_left: Increased baked_sweep[4][3] to 0.4566812515258789 (from 0.45558738708496094, +0%)
		* action_one.light_attack_left: Increased baked_sweep[4][5] to 0.6963638663291931 (from 0.667561411857605, +4%)
		* action_one.light_attack_left: Increased baked_sweep[4][7] to 0.41889646649360657 (from 0.40440067648887634, +4%)
		* action_one.light_attack_left: Increased baked_sweep[4][8] to -0.5502110719680786 (from -0.5860608220100403, +6%)
		* action_one.light_attack_left: Increased baked_sweep[5][5] to 0.37910813093185425 (from 0.3567037880420685, +6%)
		* action_one.light_attack_left: Increased baked_sweep[5][6] to 0.4430711269378662 (from 0.39477965235710144, +12%)
		* action_one.light_attack_left: Increased baked_sweep[5][7] to 0.2820264995098114 (from 0.23739518225193024, +19%)
		* action_one.light_attack_left: Increased baked_sweep[5][8] to -0.7618570327758789 (from -0.8127453327178955, +6%)
		* action_one.light_attack_left: Increased baked_sweep[6][5] to 0.17541848123073578 (from 0.14127856492996216, +24%)
		* action_one.light_attack_left: Increased baked_sweep[6][6] to 0.5380390882492065 (from 0.4720184803009033, +14%)
		* action_one.light_attack_left: Increased baked_sweep[6][7] to 0.08140674978494644 (from -0.024167919531464577, +437%)
		* action_one.light_attack_left: Increased baked_sweep[6][8] to -0.8204360008239746 (from -0.8698590993881226, +6%)
		* action_one.light_attack_left: Increased baked_sweep[7][2] to -0.13591063022613525 (from -0.14319682121276855, +5%)
		* action_one.light_attack_left: Increased baked_sweep[7][5] to 0.0605529323220253 (from 0.054749492555856705, +11%)
		* action_one.light_attack_left: Increased baked_sweep[7][6] to 0.579397976398468 (from 0.5002443790435791, +16%)
		* action_one.light_attack_left: Increased baked_sweep[7][7] to -0.1304379105567932 (from -0.249727264046669, +48%)
		* action_one.light_attack_left: Increased baked_sweep[7][8] to -0.8022575974464417 (from -0.8272812962532043, +3%)
		* action_one.light_attack_left: Reduced baked_sweep[1][2] to 0.3103722333908081 (from 0.37423861026763916, -17%)
		* action_one.light_attack_left: Reduced baked_sweep[1][4] to -0.2657968997955322 (from -0.20066529512405396, -32%)
		* action_one.light_attack_left: Reduced baked_sweep[1][5] to 0.7223937511444092 (from 0.7442251443862915, -3%)
		* action_one.light_attack_left: Reduced baked_sweep[2][2] to 0.1775137186050415 (from 0.22149372100830078, -20%)
		* action_one.light_attack_left: Reduced baked_sweep[2][4] to -0.19225668907165527 (from -0.15874451398849487, -21%)
		* action_one.light_attack_left: Reduced baked_sweep[2][5] to 0.7879757285118103 (from 0.8269151449203491, -5%)
		* action_one.light_attack_left: Reduced baked_sweep[2][8] to 0.1555033177137375 (from 0.1757780909538269, -12%)
		* action_one.light_attack_left: Reduced baked_sweep[3][2] to 0.051915526390075684 (from 0.07932281494140625, -35%)
		* action_one.light_attack_left: Reduced baked_sweep[3][4] to -0.08548450469970703 (from -0.05563300848007202, -54%)
		* action_one.light_attack_left: Reduced baked_sweep[3][5] to 0.8273890018463135 (from 0.8502056002616882, -3%)
		* action_one.light_attack_left: Reduced baked_sweep[3][6] to -0.0234444011002779 (from -0.0005969275953248143, -3828%)
		* action_one.light_attack_left: Reduced baked_sweep[3][8] to -0.18234620988368988 (from -0.17770417034626007, -3%)
		* action_one.light_attack_left: Reduced baked_sweep[4][2] to -0.12680041790008545 (from -0.10826826095581055, -17%)
		* action_one.light_attack_left: Reduced baked_sweep[4][4] to -0.04089641571044922 (from -0.00920182466506958, -344%)
		* action_one.light_attack_left: Reduced baked_sweep[4][6] to 0.19201868772506714 (from 0.2176109105348587, -12%)
		* action_one.light_attack_left: Reduced baked_sweep[5][2] to -0.26615601778030396 (from -0.23037469387054443, -16%)
		* action_one.light_attack_left: Reduced baked_sweep[5][3] to 0.21436119079589844 (from 0.24475574493408203, -12%)
		* action_one.light_attack_left: Reduced baked_sweep[5][4] to -0.12140655517578125 (from -0.05542820692062378, -119%)
		* action_one.light_attack_left: Reduced baked_sweep[6][2] to -0.1962783932685852 (from -0.17906928062438965, -10%)
		* action_one.light_attack_left: Reduced baked_sweep[6][3] to 0.1402301788330078 (from 0.17382431030273438, -19%)
		* action_one.light_attack_left: Reduced baked_sweep[6][4] to -0.22664093971252441 (from -0.17646974325180054, -28%)
		* action_one.light_attack_left: Reduced baked_sweep[7][3] to 0.1464986801147461 (from 0.17606163024902344, -17%)
		* action_one.light_attack_left: Reduced baked_sweep[7][4] to -0.29386401176452637 (from -0.2560728192329407, -15%)
		* action_one.light_attack_right: Added allowed_chain_actions[2].end_time: 1.2
		* action_one.light_attack_right: Added allowed_chain_actions[5].end_time: 0.3
		* action_one.light_attack_right: Added allowed_chain_actions[6]: <table>
		* action_one.light_attack_right: Added allowed_chain_actions[7]: <table>
		* action_one.light_attack_right: Changed allowed_chain_actions[2].input to action_one_hold (from action_one)
		* action_one.light_attack_right: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.light_attack_right: Changed allowed_chain_actions[3].input to action_one (from action_two_hold)
		* action_one.light_attack_right: Changed allowed_chain_actions[4].action to action_one (from action_two)
		* action_one.light_attack_right: Changed allowed_chain_actions[4].input to action_one_hold (from action_two_hold)
		* action_one.light_attack_right: Changed allowed_chain_actions[5].action to action_two (from action_wield)
		* action_one.light_attack_right: Changed allowed_chain_actions[5].input to action_two_hold (from action_wield)
		* action_one.light_attack_right: Increased allowed_chain_actions[3].start_time to 1.2 (from 0)
		* action_one.light_attack_right: Increased allowed_chain_actions[4].start_time to 1.2 (from 0.6, +100%)
		* action_one.light_attack_right: Reduced allowed_chain_actions[1].end_time to 1.2 (from 1.8, -33%)
		* action_one.light_attack_right: Reduced allowed_chain_actions[2].start_time to 0.6 (from 1.5, -60%)
		* action_one.light_attack_right: Reduced allowed_chain_actions[5].start_time to 0 (from 0.6, -100%)
		* action_one.light_attack_right: Removed allowed_chain_actions[3].end_time (was 0.3)
		* action_one.light_attack_up_right_last: Added allowed_chain_actions[1].end_time: 1.2
		* action_one.light_attack_up_right_last: Added allowed_chain_actions[5]: <table>
		* action_one.light_attack_up_right_last: Added allowed_chain_actions[6]: <table>
		* action_one.light_attack_up_right_last: Added allowed_chain_actions[7]: <table>
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[1].sub_action to default (from default_normal_pose)
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[2].action to action_one (from action_two)
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[2].input to action_one_hold (from action_two_hold)
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[3].action to action_one (from action_two)
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[3].input to action_one (from action_two_hold)
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[4].action to action_one (from action_wield)
		* action_one.light_attack_up_right_last: Changed allowed_chain_actions[4].input to action_one_hold (from action_wield)
		* action_one.light_attack_up_right_last: Increased allowed_chain_actions[2].end_time to 1.2 (from 0.3, +300%)
		* action_one.light_attack_up_right_last: Increased allowed_chain_actions[2].start_time to 0.65 (from 0)
		* action_one.light_attack_up_right_last: Increased allowed_chain_actions[3].start_time to 1.2 (from 0.6, +100%)
		* action_one.light_attack_up_right_last: Increased allowed_chain_actions[4].start_time to 1.2 (from 0.6, +100%)
		* action_one.push: Removed allowed_chain_actions[2].doubleclick_window (was 0)
		* action_one.push: Removed allowed_chain_actions[3].doubleclick_window (was 0)

	$END_TB
]]

Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[2].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[5].action = nil -- official: "action_one"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[5].auto_chain = nil -- official: true
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[5].blocker = true -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[5].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[5].input = "action_one_hold" -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[5].sub_action = nil -- official: "heavy_attack_left"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.allowed_chain_actions[6] = { -- official: none
	action = "action_one",
	auto_chain = true,
	start_time = 1,
	sub_action = "heavy_attack_left",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default.buff_data[1].external_multiplier = 0.6 -- official: 0.7
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[2].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].action = nil -- official: "action_one"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].auto_chain = nil -- official: true
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].blocker = true -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].input = "action_one_hold" -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].start_time = 0.6 -- official: 0.7
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[5].sub_action = nil -- official: "heavy_attack_right"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions[6] = { -- official: none
	action = "action_one",
	auto_chain = true,
	start_time = 1,
	sub_action = "heavy_attack_right",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[2].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].action = nil -- official: "action_one"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].auto_chain = nil -- official: true
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].blocker = true -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].input = "action_one_hold" -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].start_time = 0.6 -- official: 0.7
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[5].sub_action = nil -- official: "heavy_attack_right"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions[6] = { -- official: none
	action = "action_one",
	auto_chain = true,
	start_time = 1,
	sub_action = "heavy_attack_right",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[2].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].action = nil -- official: "action_one"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].auto_chain = nil -- official: true
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].blocker = true -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].input = "action_one_hold" -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].start_time = 0.6 -- official: 0.7
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[5].sub_action = nil -- official: "heavy_attack_left"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions[6] = { -- official: none
	action = "action_one",
	auto_chain = true,
	start_time = 1,
	sub_action = "heavy_attack_left",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[2].release_required = "action_one_hold" -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[2].start_time = 0.6 -- official: 2
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[2].sub_action = "default_left" -- official: "default"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[3].end_time = nil -- official: 0.3
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[3].input = "action_one" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[3].start_time = 2.2 -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[4].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[4].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[4].start_time = 2.2 -- official: 0.75
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[5].action = "action_two" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[5].end_time = 0.3 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[5].input = "action_two_hold" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[5].start_time = 0 -- official: 0.5
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[6] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.75,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[7] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.5,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[2].release_required = "action_one_hold" -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[2].start_time = 0.6 -- official: 2.2
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[2].sub_action = "default_right" -- official: "default"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[3].end_time = nil -- official: 0.3
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[3].input = "action_one" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[3].start_time = 2 -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[4].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[4].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[4].start_time = 2 -- official: 0.75
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[5].action = "action_two" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[5].end_time = 0.3 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[5].input = "action_two_hold" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[5].start_time = 0 -- official: 0.5
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[6] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.75,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions[7] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.5,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[1].release_required = nil -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[2].release_required = nil -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[3].input = "action_one" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[3].start_time = 1.5 -- official: 0.65
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[4].action = "action_one" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[4].input = "action_one_hold" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[4].start_time = 1.5 -- official: 0.65
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[5] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.65,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[6] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.65,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[1].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].end_time = 1.2 -- official: 0.3
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].start_time = 0.65 -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].sub_action = "default_last" -- official: "default"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].input = "action_one" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[4].action = "action_one" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[4].input = "action_one_hold" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[4].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[5] = { -- official: none
	action = "action_two",
	end_time = 0.3,
	input = "action_two_hold",
	start_time = 0,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[6] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions[7] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[1].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].end_time = 1.2 -- official: 0.3
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].start_time = 0.65 -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].sub_action = "default_left" -- official: "default"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[3].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[3].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[4].action = "action_one" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[4].input = "action_one" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[4].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[5] = { -- official: none
	action = "action_two",
	end_time = 0.3,
	input = "action_two_hold",
	start_time = 0,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[6] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions[7] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.anim_event = "attack_swing_up_pose" -- official: "attack_swing_up"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][2] = 0.3103722333908081 -- official: 0.37423861026763916
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][3] = 0.5904569625854492 -- official: 0.5812749862670898
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][4] = -0.2657968997955322 -- official: -0.20066529512405396
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][5] = 0.7223937511444092 -- official: 0.7442251443862915
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][6] = -0.29107052087783813 -- official: -0.37621578574180603
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][7] = 0.5494855046272278 -- official: 0.46924009919166565
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[1][8] = 0.302474707365036 -- official: 0.29052433371543884
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][2] = 0.1775137186050415 -- official: 0.22149372100830078
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][3] = 0.6366815567016602 -- official: 0.6298847198486328
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][4] = -0.19225668907165527 -- official: -0.15874451398849487
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][5] = 0.7879757285118103 -- official: 0.8269151449203491
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][6] = -0.14280153810977936 -- official: -0.15851706266403198
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][7] = 0.5783776640892029 -- official: 0.5100840926170349
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[2][8] = 0.1555033177137375 -- official: 0.1757780909538269
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][2] = 0.051915526390075684 -- official: 0.07932281494140625
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][3] = 0.6041536331176758 -- official: 0.6009492874145508
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][4] = -0.08548450469970703 -- official: -0.05563300848007202
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][5] = 0.8273890018463135 -- official: 0.8502056002616882
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][6] = -0.0234444011002779 -- official: -0.0005969275953248143
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][7] = 0.5306860208511353 -- official: 0.4955514967441559
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[3][8] = -0.18234620988368988 -- official: -0.17770417034626007
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][2] = -0.12680041790008545 -- official: -0.10826826095581055
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][3] = 0.4566812515258789 -- official: 0.45558738708496094
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][4] = -0.04089641571044922 -- official: -0.00920182466506958
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][5] = 0.6963638663291931 -- official: 0.667561411857605
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][6] = 0.19201868772506714 -- official: 0.2176109105348587
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][7] = 0.41889646649360657 -- official: 0.40440067648887634
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[4][8] = -0.5502110719680786 -- official: -0.5860608220100403
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][2] = -0.26615601778030396 -- official: -0.23037469387054443
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][3] = 0.21436119079589844 -- official: 0.24475574493408203
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][4] = -0.12140655517578125 -- official: -0.05542820692062378
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][5] = 0.37910813093185425 -- official: 0.3567037880420685
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][6] = 0.4430711269378662 -- official: 0.39477965235710144
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][7] = 0.2820264995098114 -- official: 0.23739518225193024
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[5][8] = -0.7618570327758789 -- official: -0.8127453327178955
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][2] = -0.1962783932685852 -- official: -0.17906928062438965
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][3] = 0.1402301788330078 -- official: 0.17382431030273438
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][4] = -0.22664093971252441 -- official: -0.17646974325180054
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][5] = 0.17541848123073578 -- official: 0.14127856492996216
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][6] = 0.5380390882492065 -- official: 0.4720184803009033
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][7] = 0.08140674978494644 -- official: -0.024167919531464577
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[6][8] = -0.8204360008239746 -- official: -0.8698590993881226
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][2] = -0.13591063022613525 -- official: -0.14319682121276855
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][3] = 0.1464986801147461 -- official: 0.17606163024902344
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][4] = -0.29386401176452637 -- official: -0.2560728192329407
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][5] = 0.0605529323220253 -- official: 0.054749492555856705
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][6] = 0.579397976398468 -- official: 0.5002443790435791
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][7] = -0.1304379105567932 -- official: -0.249727264046669
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep[7][8] = -0.8022575974464417 -- official: -0.8272812962532043
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[1].end_time = 1.2 -- official: 1.8
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[2].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[2].input = "action_one_hold" -- official: "action_one"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[2].start_time = 0.6 -- official: 1.5
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[3].end_time = nil -- official: 0.3
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[3].input = "action_one" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[3].start_time = 1.2 -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[4].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[4].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[4].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[5].action = "action_two" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[5].end_time = 0.3 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[5].input = "action_two_hold" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[5].start_time = 0 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[6] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions[7] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[1].end_time = 1.2 -- official: none
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[1].sub_action = "default" -- official: "default_normal_pose"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[2].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[2].end_time = 1.2 -- official: 0.3
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[2].input = "action_one_hold" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[2].start_time = 0.65 -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[3].action = "action_one" -- official: "action_two"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[3].input = "action_one" -- official: "action_two_hold"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[3].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[4].action = "action_one" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[4].input = "action_one_hold" -- official: "action_wield"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[4].start_time = 1.2 -- official: 0.6
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[5] = { -- official: none
	action = "action_two",
	end_time = 0.3,
	input = "action_two_hold",
	start_time = 0,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[6] = { -- official: none
	action = "action_two",
	input = "action_two_hold",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions[7] = { -- official: none
	action = "action_wield",
	input = "action_wield",
	start_time = 0.6,
	sub_action = "default",
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.push.allowed_chain_actions[2].doubleclick_window = nil -- official: 0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.push.allowed_chain_actions[3].doubleclick_window = nil -- official: 0

-- ======== two_handed_halberds_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_halberds_template_1

		* action_one.heavy_attack_left: Added targets[1].headshot_boost_boss: 0.154
		* action_one.heavy_attack_left: Added targets[2].headshot_boost_boss: 0.154
		* action_one.heavy_attack_left: Added targets[3].boost_curve_coefficient_headshot: 1.75
		* action_one.heavy_attack_left: Added targets[3].headshot_boost_boss: 0.154
		* action_one.heavy_attack_left: Added targets[4].boost_curve_coefficient_headshot: 1.75
		* action_one.heavy_attack_left: Added targets[4].headshot_boost_boss: 0.154
		* action_one.heavy_attack_left: Changed damage_profile to tb_halberd_heavy_slash (from heavy_slashing_linesman_polearm)
		* action_one.heavy_attack_left: Increased targets[1].armor_modifier.attack[1] to 1.15 (from 1, +15%)
		* action_one.heavy_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 1.75 (from 1, +75%)
		* action_one.heavy_attack_left: Increased targets[1].power_distribution.attack to 0.45 (from 0.325, +38%)
		* action_one.heavy_attack_left: Increased targets[2].boost_curve_coefficient_headshot to 1.75 (from 1, +75%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.attack to 0.35 (from 0.25, +40%)
		* action_one.heavy_attack_left: Increased targets[3].power_distribution.attack to 0.25 (from 0.15, +67%)
		* action_one.heavy_attack_left: Increased targets[4].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.heavy_attack_stab: Added targets[1].headshot_boost_boss: 0.175
		* action_one.heavy_attack_stab: Changed damage_profile to tb_halberd_heavy_stab (from heavy_slashing_smiter_stab_polearm)
		* action_one.heavy_attack_stab: Increased critical_strike.attack_armor_power_modifer[2] to 0.56 (from 0.5, +12%)
		* action_one.heavy_attack_stab: Increased targets[1].armor_modifier.attack[2] to 0.56 (from 0.45, +24%)
		* action_one.heavy_attack_stab: Increased targets[1].boost_curve_coefficient_headshot to 2.8 (from 2, +40%)
		* action_one.light_attack_down: Added default_target.boost_curve_coefficient: 1
		* action_one.light_attack_down: Added default_target.boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_down: Added melee_boost_override: 2.5
		* action_one.light_attack_down: Changed damage_profile to tb_halberd_light_chop (from medium_slashing_smiter_2h)
		* action_one.light_attack_down: Changed default_target.attack_template to stab_smiter (from slashing_smiter)
		* action_one.light_attack_down: Changed default_target.boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_down: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_down: Increased armor_modifier.attack[2] to 1.25 (from 0.8, +56%)
		* action_one.light_attack_down: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.light_attack_down: Increased armor_modifier.impact[2] to 0.8 (from 0.6, +33%)
		* action_one.light_attack_down: Increased critical_strike.attack_armor_power_modifer[2] to 1.25 (from 0.8, +56%)
		* action_one.light_attack_down: Removed default_target.armor_modifier (was <table>)
		* action_one.light_attack_down: Removed targets[2] (was <table>)
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient: 1
		* action_one.light_attack_last: Added default_target.boost_curve_coefficient_headshot: 1.5
		* action_one.light_attack_last: Added melee_boost_override: 2.5
		* action_one.light_attack_last: Changed damage_profile to tb_halberd_light_chop (from medium_slashing_smiter_2h)
		* action_one.light_attack_last: Changed default_target.attack_template to stab_smiter (from slashing_smiter)
		* action_one.light_attack_last: Changed default_target.boost_curve_type to ninja_curve (from smiter_curve)
		* action_one.light_attack_last: Increased armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 1.25 (from 0.8, +56%)
		* action_one.light_attack_last: Increased armor_modifier.attack[3] to 2.5 (from 1.75, +43%)
		* action_one.light_attack_last: Increased armor_modifier.impact[2] to 0.8 (from 0.6, +33%)
		* action_one.light_attack_last: Increased critical_strike.attack_armor_power_modifer[2] to 1.25 (from 0.8, +56%)
		* action_one.light_attack_last: Removed default_target.armor_modifier (was <table>)
		* action_one.light_attack_last: Removed targets[2] (was <table>)
		* action_one.light_attack_left: Changed damage_profile to tb_halberd_light_slash (from medium_slashing_axe_linesman)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.4 (from 0.275, +45%)
		* action_one.light_attack_left: Increased targets[1].armor_modifier.attack[1] to 1.25 (from 1, +25%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.225 (from 0.15, +50%)
		* action_one.light_attack_left: Increased targets[3].power_distribution.attack to 0.15 (from 0.1, +50%)
		* action_one.light_attack_stab: Changed damage_profile to tb_halberd_light_stab (from medium_slashing_smiter_stab)
		* action_one.light_attack_stab: Increased armor_modifier.attack[2] to 0.7 (from 0.25, +180%)
		* action_one.light_attack_stab: Increased critical_strike.attack_armor_power_modifer[2] to 0.8 (from 0.4, +100%)
		* action_one.light_attack_stab: Increased default_target.power_distribution.attack to 0.25 (from 0.2, +25%)

	$END_TB
]]

Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_halberd_heavy_slash" -- official: "heavy_slashing_linesman_polearm"
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile = "tb_halberd_heavy_stab" -- official: "heavy_slashing_smiter_stab_polearm"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_down.damage_profile = "tb_halberd_light_chop" -- official: "medium_slashing_smiter_2h"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_last.damage_profile = "tb_halberd_light_chop" -- official: "medium_slashing_smiter_2h"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.damage_profile = "tb_halberd_light_slash" -- official: "medium_slashing_axe_linesman"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile = "tb_halberd_light_stab" -- official: "medium_slashing_smiter_stab"

-- tb_halberd_heavy_slash: replaces the existing block
-- used by Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_left.damage_profile
NewDamageProfileTemplates.tb_halberd_heavy_slash = { -- official: heavy_slashing_linesman_polearm
	armor_modifier = "armor_modifier_linesman_H",
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_linesman_H",
	cleave_distribution = "cleave_distribution_linesman_executioner_H",
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		power_distribution = {
			attack = 0.1,
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: 1
			headshot_boost_boss = 0.154, -- official: none
			armor_modifier = {
				attack = {
					1.15, -- official: 1
					0.5,
					1.5,
					1,
					0.75,
				},
				impact = {
					0.9,
					0.5,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.45, -- official: 0.325
				impact = 0.25,
			},
		},
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: 1
			headshot_boost_boss = 0.154, -- official: none
			power_distribution = {
				attack = 0.35, -- official: 0.25
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: none
			headshot_boost_boss = 0.154, -- official: none
			power_distribution = {
				attack = 0.25, -- official: 0.15
				impact = 0.1,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.75, -- official: none
			headshot_boost_boss = 0.154, -- official: none
			power_distribution = {
				attack = 0.15, -- official: 0.125
				impact = 0.075,
			},
		},
	},
}

-- tb_halberd_heavy_stab: replaces the existing block
-- used by Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile
NewDamageProfileTemplates.tb_halberd_heavy_stab = { -- official: heavy_slashing_smiter_stab_polearm
	armor_modifier = {
		attack = {
			1,
			0.3,
			2,
			1,
			0.75,
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.56, -- official: 0.5
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5,
	default_target = {
		attack_template = "heavy_stab_smiter",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 0.75,
		power_distribution = {
			attack = 0.2,
			impact = 0.15,
		},
	},
	targets = {
		{
			attack_template = "heavy_stab_smiter",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2.8, -- official: 2
			boost_curve_coefficient = 0.75,
			headshot_boost_boss = 0.175, -- official: none
			armor_modifier = {
				attack = {
					1,
					0.56, -- official: 0.45
					2,
					1,
					0.75,
				},
				impact = {
					1,
					0.65,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.25,
			},
		},
	},
}

-- tb_halberd_light_chop: replaces the existing block
-- used by Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_down.damage_profile
-- used by Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_last.damage_profile
NewDamageProfileTemplates.tb_halberd_light_chop = { -- official: medium_slashing_smiter_2h
	armor_modifier = {
		attack = {
			1.25, -- official: 1
			1.25, -- official: 0.8
			2.5, -- official: 1.75
			1,
			0.75,
		},
		impact = {
			1,
			0.8, -- official: 0.6
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			1.25, -- official: 0.8
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5, -- official: none
	shield_break = true,
	default_target = {
		attack_template = "stab_smiter", -- official: "slashing_smiter"
		boost_curve_type = "ninja_curve", -- official: "smiter_curve"
		boost_curve_coefficient_headshot = 1.5, -- official: none
		boost_curve_coefficient = 1, -- official: none
		power_distribution = {
			attack = 0.325,
			impact = 0.2,
		},
		-- removed: armor_modifier (official: <table>)
	},
}

-- tb_halberd_light_slash: replaces the existing block
-- used by Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.damage_profile
NewDamageProfileTemplates.tb_halberd_light_slash = { -- official: medium_slashing_axe_linesman
	armor_modifier = "armor_modifier_axe_linesman_M",
	charge_value = "light_attack",
	critical_strike = "critical_strike_axe_linesman_M",
	cleave_distribution = {
		attack = 0.4, -- official: 0.275
		impact = 0.25,
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1.5,
			armor_modifier = {
				attack = {
					1.25, -- official: 1
					0.3,
					1.5,
					1,
					0.75,
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.25,
				impact = 0.2,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.225, -- official: 0.15
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15, -- official: 0.1
				impact = 0.1,
			},
		},
	},
}

-- tb_halberd_light_stab: replaces the existing block
-- used by Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile
NewDamageProfileTemplates.tb_halberd_light_stab = { -- official: medium_slashing_smiter_stab
	armor_modifier = {
		attack = {
			1,
			0.7, -- official: 0.25
			2.25,
			1,
			0.75,
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8, -- official: 0.4
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075,
	},
	melee_boost_override = 2.5,
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient_headshot = 2,
		boost_curve_coefficient = 1,
		power_distribution = {
			attack = 0.25, -- official: 0.2
			impact = 0.125,
		},
	},
}

-- ======== two_handed_hammer_priest_template ========

--[[
	$BEGIN_TB
		## two_handed_hammer_priest_template

		* action_one.heavy_attack_01: Reduced targets[2].power_distribution.attack to 0.1 (from 0.45, -78%)
		* action_one.heavy_attack_02: Changed damage_profile to tb_2h_hammer_heavy_2_priest (from heavy_blunt_tank)
		* action_one.heavy_attack_02: Increased cleave_distribution.attack to 0.4 (from 0.3, +33%)
		* action_one.heavy_attack_02: Increased targets[1].power_distribution.attack to 0.5 (from 0.275, +82%)
		* action_one.heavy_attack_02: Increased targets[2].power_distribution.attack to 0.2 (from 0.15, +33%)
		* action_one.heavy_attack_03: Increased armor_modifier.attack[2] to 2.025 (from 1, +102%)
		* action_one.heavy_attack_03: Increased armor_modifier.attack[6] to 1.2 (from 1, +20%)
		* action_one.heavy_attack_03: Increased critical_strike.attack_armor_power_modifer[2] to 1.8 (from 1.1, +64%)
		* action_one.light_attack_02: Changed damage_profile to holy_hammer_light_2 (from medium_blunt_smiter_2h_hammer)
		* action_one.light_attack_02: Changed default_target.attack_template to slashing_smiter (from blunt_smiter)
		* action_one.light_attack_02: Increased armor_modifier.attack[1] to 1.5 (from 1, +50%)
		* action_one.light_attack_02: Increased armor_modifier.attack[2] to 1.05 (from 0.8, +31%)
		* action_one.light_attack_02: Increased armor_modifier.attack[5] to 1.01 (from 0.75, +35%)
		* action_one.light_attack_02: Increased critical_strike.attack_armor_power_modifer[1] to 1.36 (from 1, +36%)
		* action_one.light_attack_02: Increased critical_strike.attack_armor_power_modifer[2] to 0.95 (from 0.8, +19%)
		* action_one.light_attack_03: Changed damage_profile to tb_2h_hammer_light_3_priest (from medium_blunt_tank)
		* action_one.light_attack_03: Increased targets[2].power_distribution.attack to 0.2 (from 0.1, +100%)

	$END_TB
]]

Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "tb_2h_hammer_heavy_2_priest" -- official: "heavy_blunt_tank"
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile = "holy_hammer_light_2" -- official: "medium_blunt_smiter_2h_hammer"
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "tb_2h_hammer_light_3_priest" -- official: "medium_blunt_tank"

-- holy_hammer_light_2: replaces the existing block
-- used by Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile
NewDamageProfileTemplates.holy_hammer_light_2 = { -- official: medium_blunt_smiter_2h_hammer
	armor_modifier = {
		attack = {
			1.5, -- official: 1
			1.05, -- official: 0.8
			2,
			1,
			1.01, -- official: 0.75
			1,
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.36, -- official: 1
			0.95, -- official: 0.8
			2.5,
			1,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	shield_break = true,
	default_target = {
		attack_template = "slashing_smiter", -- official: "blunt_smiter"
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		power_distribution = {
			attack = 0.4,
			impact = 0.25,
		},
	},
	targets = "targets_smiter_M",
}

-- priest_hammer_blunt_smiter (official profile, changed in place)
DamageProfileTemplates.priest_hammer_blunt_smiter.armor_modifier.attack[2] = 2.025 -- official: 1
DamageProfileTemplates.priest_hammer_blunt_smiter.armor_modifier.attack[6] = 1.2 -- official: 1
DamageProfileTemplates.priest_hammer_blunt_smiter.critical_strike.attack_armor_power_modifer[2] = 1.8 -- official: 1.1

-- priest_hammer_heavy_blunt_tank_upper (official profile, changed in place)
DamageProfileTemplates.priest_hammer_heavy_blunt_tank_upper.targets[2].power_distribution.attack = 0.1 -- official: 0.45

-- tb_2h_hammer_heavy_2_priest: replaces the existing block
-- used by Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile
NewDamageProfileTemplates.tb_2h_hammer_heavy_2_priest = { -- official: heavy_blunt_tank
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75,
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.6,
			2,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.8,
	cleave_distribution = {
		attack = 0.4, -- official: 0.3
		impact = 0.8,
	},
	default_target = {
		attack_template = "blunt_tank",
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.05,
			impact = 0.125,
		},
	},
	targets = {
		{
			attack_template = "heavy_blunt_tank",
			boost_curve_type = "tank_curve",
			armor_modifier = {
				attack = {
					1,
					0.5,
					2,
					1,
					0.75,
				},
				impact = {
					1.5,
					1,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.5, -- official: 0.275
				impact = 0.3,
			},
		},
		{
			attack_template = "heavy_blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.2, -- official: 0.15
				impact = 0.225,
			},
		},
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.2,
			},
		},
	},
}

-- tb_2h_hammer_light_3_priest: replaces the existing block
-- used by Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile
NewDamageProfileTemplates.tb_2h_hammer_light_3_priest = { -- official: medium_blunt_tank
	armor_modifier = {
		attack = {
			1,
			0.2,
			1,
			1,
			0.75,
		},
		impact = {
			1,
			1,
			0.5,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.5,
	cleave_distribution = {
		attack = 0.3,
		impact = 0.8,
	},
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.05,
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1,
			power_distribution = {
				attack = 0.2,
				impact = 0.2,
			},
		},
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.2, -- official: 0.1
				impact = 0.15,
			},
		},
		{
			attack_template = "light_blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.1,
			},
		},
	},
}

-- ======== two_handed_hammers_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_hammers_template_1

		* action_one.heavy_attack_left: Added anim_time_scale: 1.2
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_plague_monk: 0.6
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_one.heavy_attack_left: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_one.heavy_attack_left: Changed damage_profile to tb_2h_hammer_heavy (from heavy_blunt_tank)
		* action_one.heavy_attack_left: Increased critical_strike.attack_armor_power_modifer[1] to 1.3 (from 1, +30%)
		* action_one.heavy_attack_left: Increased hit_mass_count.beastmen_bestigor to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.beastmen_gor to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.chaos_berzerker to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.chaos_marauder to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.chaos_marauder_with_shield to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.chaos_raider to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.skaven_clan_rat to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased hit_mass_count.skaven_clan_rat_with_shield to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_left: Increased targets[1].armor_modifier.attack[1] to 1.5 (from 1, +50%)
		* action_one.heavy_attack_left: Reduced hit_mass_count.beastmen_ungor to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_left: Reduced hit_mass_count.chaos_fanatic to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_left: Reduced hit_mass_count.chaos_warrior to 0.5 (from 1e+01, -95%)
		* action_one.heavy_attack_left: Reduced hit_mass_count.skaven_slave to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_left: Removed hit_mass_count.skaven_storm_vermin_with_shield (was 0.5)
		* action_one.heavy_attack_right: Added anim_time_scale: 1.2
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_plague_monk: 0.6
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_ratling_gunner: 0.5
		* action_one.heavy_attack_right: Added hit_mass_count.skaven_warpfire_thrower: 0.5
		* action_one.heavy_attack_right: Changed damage_profile to tb_2h_hammer_heavy (from heavy_blunt_tank)
		* action_one.heavy_attack_right: Increased critical_strike.attack_armor_power_modifer[1] to 1.3 (from 1, +30%)
		* action_one.heavy_attack_right: Increased hit_mass_count.beastmen_bestigor to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.beastmen_gor to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.chaos_berzerker to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.chaos_marauder to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.chaos_marauder_with_shield to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.chaos_raider to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.skaven_clan_rat to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased hit_mass_count.skaven_clan_rat_with_shield to 0.6 (from 0.5, +20%)
		* action_one.heavy_attack_right: Increased targets[1].armor_modifier.attack[1] to 1.5 (from 1, +50%)
		* action_one.heavy_attack_right: Reduced hit_mass_count.beastmen_ungor to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_right: Reduced hit_mass_count.chaos_fanatic to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_right: Reduced hit_mass_count.chaos_warrior to 0.5 (from 1e+01, -95%)
		* action_one.heavy_attack_right: Reduced hit_mass_count.skaven_slave to 0.6 (from 0.75, -20%)
		* action_one.heavy_attack_right: Removed hit_mass_count.skaven_storm_vermin_with_shield (was 0.5)
		* action_one.light_attack_push_left_up: Changed damage_profile to tb_2h_hammer_heavy (from heavy_blunt_tank_light)
		* action_one.light_attack_push_left_up: Increased critical_strike.attack_armor_power_modifer[1] to 1.3 (from 1, +30%)
		* action_one.light_attack_push_left_up: Increased targets[1].armor_modifier.attack[1] to 1.5 (from 1, +50%)

	$END_TB
]]

Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.anim_time_scale = 1.2 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_2h_hammer_heavy" -- official: "heavy_blunt_tank"
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.beastmen_bestigor = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.beastmen_gor = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.beastmen_ungor = 0.6 -- official: 0.75
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_berzerker = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_fanatic = 0.6 -- official: 0.75
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_marauder = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_marauder_with_shield = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_raider = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.chaos_warrior = 0.5 -- official: 1e+01
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_clan_rat = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_clan_rat_with_shield = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_plague_monk = 0.6 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_slave = 0.6 -- official: 0.75
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_storm_vermin_with_shield = nil -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.anim_time_scale = 1.2 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_2h_hammer_heavy" -- official: "heavy_blunt_tank"
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.beastmen_bestigor = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.beastmen_gor = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.beastmen_ungor = 0.6 -- official: 0.75
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_berzerker = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_fanatic = 0.6 -- official: 0.75
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_marauder = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_marauder_with_shield = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_raider = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.chaos_warrior = 0.5 -- official: 1e+01
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_clan_rat = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_clan_rat_with_shield = 0.6 -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_plague_monk = 0.6 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_ratling_gunner = 0.5 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_slave = 0.6 -- official: 0.75
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_storm_vermin_with_shield = nil -- official: 0.5
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.hit_mass_count.skaven_warpfire_thrower = 0.5 -- official: none
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_push_left_up.damage_profile = "tb_2h_hammer_heavy" -- official: "heavy_blunt_tank_light"

-- tb_2h_hammer_heavy: replaces the existing block
-- used by Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.damage_profile
-- used by Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_push_left_up.damage_profile
NewDamageProfileTemplates.tb_2h_hammer_heavy = { -- official: heavy_blunt_tank (comments compare against it; also replaces heavy_blunt_tank_light)
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75,
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.3, -- official: 1
			0.6,
			2,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	stagger_duration_modifier = 1.8,
	cleave_distribution = {
		attack = 0.3,
		impact = 0.8,
	},
	default_target = {
		attack_template = "blunt_tank",
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.05,
			impact = 0.125,
		},
	},
	targets = {
		{
			attack_template = "heavy_blunt_tank",
			boost_curve_type = "tank_curve",
			armor_modifier = {
				attack = {
					1.5, -- official: 1
					0.5,
					2,
					1,
					0.75,
				},
				impact = {
					1.5,
					1,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.275,
				impact = 0.3,
			},
		},
		{
			attack_template = "heavy_blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.15,
				impact = 0.225,
			},
		},
		{
			attack_template = "blunt_tank",
			boost_curve_type = "tank_curve",
			power_distribution = {
				attack = 0.075,
				impact = 0.2,
			},
		},
	},
}

-- ======== two_handed_heavy_spears_template ========

--[[
	$BEGIN_TB
		## two_handed_heavy_spears_template

		* action_one.heavy_attack_left: Changed damage_profile to tusk_spear_heavy_1 (from heavy_slashing_smiter_stab_polearm)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[1] to 1.208 (from 1, +21%)
		* action_one.heavy_attack_left: Increased armor_modifier.attack[2] to 1.007 (from 0.3, +236%)
		* action_one.heavy_attack_left: Increased armor_modifier.impact[2] to 0.65 (from 0.5, +30%)
		* action_one.heavy_attack_left: Increased critical_strike.attack_armor_power_modifer[1] to 1.13 (from 1, +13%)
		* action_one.heavy_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.947 (from 0.5, +89%)
		* action_one.heavy_attack_left: Removed melee_boost_override (was 2.5)
		* action_one.heavy_attack_left: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_left: Changed charge_value to light_attack (from heavy_attack)
		* action_one.light_attack_left: Changed damage_profile to tusk_spear_light_1 (from medium_spear_smiter_stab)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.35 (from 0.25, +40%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.47 (from 0.4, +17%)
		* action_one.light_attack_left: Removed melee_boost_override (was 2.5)
		* action_one.light_attack_right: Added armor_modifier.attack[6]: 0.74
		* action_one.light_attack_right: Added critical_strike.attack_armor_power_modifer[6]: 0.6
		* action_one.light_attack_right: Changed damage_profile to tusk_spear_light_3 (from medium_slashing_linesman_spear)
		* action_one.light_attack_right: Increased armor_modifier.attack[5] to 1.16 (from 1, +16%)
		* action_one.light_attack_stab_1: Changed charge_value to light_attack (from heavy_attack)
		* action_one.light_attack_stab_1: Changed damage_profile to tusk_spear_light_2 (from medium_spear_smiter_stab)
		* action_one.light_attack_stab_1: Increased armor_modifier.attack[1] to 1.335 (from 1, +34%)
		* action_one.light_attack_stab_1: Increased armor_modifier.attack[2] to 0.45 (from 0.25, +80%)
		* action_one.light_attack_stab_1: Increased armor_modifier.attack[3] to 2.75 (from 2.25, +22%)
		* action_one.light_attack_stab_1: Increased armor_modifier.attack[5] to 1.05 (from 0.75, +40%)
		* action_one.light_attack_stab_1: Increased critical_strike.attack_armor_power_modifer[1] to 1.335 (from 1, +34%)
		* action_one.light_attack_stab_1: Increased critical_strike.attack_armor_power_modifer[2] to 0.45 (from 0.4, +12%)
		* action_one.light_attack_stab_1: Increased critical_strike.attack_armor_power_modifer[3] to 2.75 (from 2.5, +10%)
		* action_one.light_attack_stab_1: Removed melee_boost_override (was 2.5)
		* action_one.light_attack_stab_2: Added armor_modifier.attack[6]: 1.08
		* action_one.light_attack_stab_2: Added critical_strike.attack_armor_power_modifer[6]: 1.2
		* action_one.light_attack_stab_2: Changed charge_value to light_attack (from heavy_attack)
		* action_one.light_attack_stab_2: Changed damage_profile to tusk_spear_light_4 (from medium_spear_smiter_stab)
		* action_one.light_attack_stab_2: Increased armor_modifier.attack[1] to 2 (from 1, +100%)
		* action_one.light_attack_stab_2: Increased armor_modifier.attack[2] to 0.9 (from 0.25, +260%)
		* action_one.light_attack_stab_2: Increased armor_modifier.attack[5] to 1.65 (from 0.75, +120%)
		* action_one.light_attack_stab_2: Increased critical_strike.attack_armor_power_modifer[1] to 1.8 (from 1, +80%)
		* action_one.light_attack_stab_2: Increased critical_strike.attack_armor_power_modifer[2] to 0.8 (from 0.4, +100%)
		* action_one.light_attack_stab_2: Increased critical_strike.attack_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_one.light_attack_stab_2: Reduced default_target.boost_curve_coefficient_headshot to 0.7 (from 1.5, -53%)
		* action_one.light_attack_stab_2: Removed melee_boost_override (was 2.5)

	$END_TB
]]

Weapons.two_handed_heavy_spears_template.actions.action_one.heavy_attack_left.damage_profile = "tusk_spear_heavy_1" -- official: "heavy_slashing_smiter_stab_polearm"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_left.damage_profile = "tusk_spear_light_1" -- official: "medium_spear_smiter_stab"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_right.damage_profile = "tusk_spear_light_3" -- official: "medium_slashing_linesman_spear"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_1.damage_profile = "tusk_spear_light_2" -- official: "medium_spear_smiter_stab"
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_2.damage_profile = "tusk_spear_light_4" -- official: "medium_spear_smiter_stab"

-- tusk_spear_heavy_1: replaces the existing block
-- used by Weapons.two_handed_heavy_spears_template.actions.action_one.heavy_attack_left.damage_profile
NewDamageProfileTemplates.tusk_spear_heavy_1 = { -- official: heavy_slashing_smiter_stab_polearm
	armor_modifier = {
		attack = {
			1.208, -- official: 1
			1.007, -- official: 0.3
			2,
			1,
			0.75,
		},
		impact = {
			1,
			0.65, -- official: 0.5
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.13, -- official: 1
			0.947, -- official: 0.5
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_stab_smiter_H",
	targets = {
		{
			attack_template = "heavy_stab_smiter",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 0.75,
			power_distribution = {
				attack = 0.45,
				impact = 0.25,
			},
			-- removed: armor_modifier (official: <table>)
		},
	},
	-- removed: melee_boost_override (official: 2.5)
}

-- tusk_spear_light_1: replaces the existing block
-- used by Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_left.damage_profile
NewDamageProfileTemplates.tusk_spear_light_1 = { -- official: medium_spear_smiter_stab
	armor_modifier = {
		attack = {
			1,
			0.35, -- official: 0.25
			2.25,
			1,
			0.75,
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack", -- official: "heavy_attack"
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.47, -- official: 0.4
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_spear_stab_smiter_M",
	-- removed: melee_boost_override (official: 2.5)
}

-- tusk_spear_light_2: replaces the existing block
-- used by Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_1.damage_profile
NewDamageProfileTemplates.tusk_spear_light_2 = { -- official: medium_spear_smiter_stab
	armor_modifier = {
		attack = {
			1.335, -- official: 1
			0.45, -- official: 0.25
			2.75, -- official: 2.25
			1,
			1.05, -- official: 0.75
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack", -- official: "heavy_attack"
	critical_strike = {
		attack_armor_power_modifer = {
			1.335, -- official: 1
			0.45, -- official: 0.4
			2.75, -- official: 2.5
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_spear_stab_smiter_M",
	-- removed: melee_boost_override (official: 2.5)
}

-- tusk_spear_light_3: replaces the existing block
-- used by Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.tusk_spear_light_3 = { -- official: medium_slashing_linesman_spear
	armor_modifier = {
		attack = {
			1,
			0,
			2,
			1,
			1.16, -- official: 1
			0.74, -- official: none
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
			0.6, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_linesman_L",
	default_target = "default_target_linesman_L",
	targets = "targets_linesman_spear_M",
}

-- tusk_spear_light_4: replaces the existing block
-- used by Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_2.damage_profile
NewDamageProfileTemplates.tusk_spear_light_4 = { -- official: medium_spear_smiter_stab
	armor_modifier = {
		attack = {
			2, -- official: 1
			0.9, -- official: 0.25
			2.25,
			1,
			1.65, -- official: 0.75
			1.08, -- official: none
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack", -- official: "heavy_attack"
	critical_strike = {
		attack_armor_power_modifer = {
			1.8, -- official: 1
			0.8, -- official: 0.4
			2.5,
			1,
			1.5, -- official: 1
			1.2, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient_headshot = 0.7, -- official: 1.5
		boost_curve_coefficient = 1,
		power_distribution = {
			attack = 0.25,
			impact = 0.25,
		},
	},
	-- removed: melee_boost_override (official: 2.5)
}

-- ======== two_handed_picks_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_picks_template_1

		* Increased dodge_count to 3 (from 2, +50%)
		* action_one.heavy_attack_left: Changed damage_profile to pickaxe_uncharged_heavies (from pickaxe_heavy_smiter_vertical)
		* action_one.heavy_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.75, +20%)
		* action_one.heavy_attack_left: Removed critical_strike.attack_armor_power_modifer[6] (was 1)
		* action_one.heavy_attack_left_charged: Changed damage_profile to pickaxe_charged_heavies (from pickaxe_heavy_smiter_vertical_charged)
		* action_one.heavy_attack_left_charged: Increased critical_strike.attack_armor_power_modifer[2] to 0.785 (from 0.75, +5%)
		* action_one.heavy_attack_left_charged: Removed critical_strike.attack_armor_power_modifer[6] (was 0.85)
		* action_one.heavy_attack_right: Changed damage_profile to pickaxe_uncharged_heavies (from pickaxe_heavy_smiter_vertical)
		* action_one.heavy_attack_right: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.75, +20%)
		* action_one.heavy_attack_right: Removed critical_strike.attack_armor_power_modifer[6] (was 1)
		* action_one.heavy_attack_right_charged: Changed damage_profile to pickaxe_charged_heavies (from pickaxe_heavy_smiter_vertical_charged)
		* action_one.heavy_attack_right_charged: Increased critical_strike.attack_armor_power_modifer[2] to 0.785 (from 0.75, +5%)
		* action_one.heavy_attack_right_charged: Removed critical_strike.attack_armor_power_modifer[6] (was 0.85)
		* action_one.light_attack_left: Added targets[1].armor_modifier: <table>
		* action_one.light_attack_left: Changed damage_profile to tb_warpick_lights (from pickaxe_medium_tank_diag)
		* action_one.light_attack_left: Changed default_target.attack_template to light_slashing_linesman (from light_blunt_tank)
		* action_one.light_attack_left: Changed default_target.boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_left: Changed targets[1].attack_template to heavy_slashing_linesman (from blunt_tank)
		* action_one.light_attack_left: Changed targets[1].boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_left: Changed targets[2].attack_template to slashing_linesman (from blunt_tank)
		* action_one.light_attack_left: Changed targets[2].boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_left: Changed targets[3].attack_template to light_slashing_linesman (from light_blunt_tank)
		* action_one.light_attack_left: Changed targets[3].boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_left: Increased anim_time_scale to 1.125 (from 0.855, +32%)
		* action_one.light_attack_left: Increased armor_modifier.attack[3] to 1.5 (from 1, +50%)
		* action_one.light_attack_left: Increased armor_modifier.impact[3] to 1 (from 0.5, +100%)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.4 (from 0.3, +33%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[3] to 1.5 (from 1, +50%)
		* action_one.light_attack_left: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.075 (from 0.05, +50%)
		* action_one.light_attack_left: Increased default_target.power_distribution.impact to 0.075 (from 0.05, +50%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 1.5 (from 1, +50%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.225 (from 0.2, +12%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.21 (from 0.1, +110%)
		* action_one.light_attack_left: Increased targets[3].power_distribution.attack to 0.14 (from 0.075, +87%)
		* action_one.light_attack_left: Reduced armor_modifier.attack[1] to 0.9 (from 1, -10%)
		* action_one.light_attack_left: Reduced armor_modifier.attack[2] to 0 (from 0.6, -100%)
		* action_one.light_attack_left: Reduced armor_modifier.impact[1] to 0.9 (from 1, -10%)
		* action_one.light_attack_left: Reduced armor_modifier.impact[2] to 0.5 (from 1, -50%)
		* action_one.light_attack_left: Reduced cleave_distribution.impact to 0.4 (from 0.8, -50%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.impact to 0.125 (from 0.15, -17%)
		* action_one.light_attack_left: Removed stagger_duration_modifier (was 1.5)
		* action_one.light_attack_right: Added targets[1].armor_modifier: <table>
		* action_one.light_attack_right: Changed damage_profile to tb_warpick_lights (from pickaxe_medium_tank_diag)
		* action_one.light_attack_right: Changed default_target.attack_template to light_slashing_linesman (from light_blunt_tank)
		* action_one.light_attack_right: Changed default_target.boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_right: Changed targets[1].attack_template to heavy_slashing_linesman (from blunt_tank)
		* action_one.light_attack_right: Changed targets[1].boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_right: Changed targets[2].attack_template to slashing_linesman (from blunt_tank)
		* action_one.light_attack_right: Changed targets[2].boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_right: Changed targets[3].attack_template to light_slashing_linesman (from light_blunt_tank)
		* action_one.light_attack_right: Changed targets[3].boost_curve_type to linesman_curve (from tank_curve)
		* action_one.light_attack_right: Increased anim_time_scale to 1.125 (from 0.855, +32%)
		* action_one.light_attack_right: Increased armor_modifier.attack[3] to 1.5 (from 1, +50%)
		* action_one.light_attack_right: Increased armor_modifier.impact[3] to 1 (from 0.5, +100%)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.4 (from 0.3, +33%)
		* action_one.light_attack_right: Increased critical_strike.attack_armor_power_modifer[3] to 1.5 (from 1, +50%)
		* action_one.light_attack_right: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.075 (from 0.05, +50%)
		* action_one.light_attack_right: Increased default_target.power_distribution.impact to 0.075 (from 0.05, +50%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 1.5 (from 1, +50%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.225 (from 0.2, +12%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.21 (from 0.1, +110%)
		* action_one.light_attack_right: Increased targets[3].power_distribution.attack to 0.14 (from 0.075, +87%)
		* action_one.light_attack_right: Reduced armor_modifier.attack[1] to 0.9 (from 1, -10%)
		* action_one.light_attack_right: Reduced armor_modifier.attack[2] to 0 (from 0.6, -100%)
		* action_one.light_attack_right: Reduced armor_modifier.impact[1] to 0.9 (from 1, -10%)
		* action_one.light_attack_right: Reduced armor_modifier.impact[2] to 0.5 (from 1, -50%)
		* action_one.light_attack_right: Reduced cleave_distribution.impact to 0.4 (from 0.8, -50%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.impact to 0.125 (from 0.15, -17%)
		* action_one.light_attack_right: Removed stagger_duration_modifier (was 1.5)

	$END_TB
]]

Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left.damage_profile = "pickaxe_uncharged_heavies" -- official: "pickaxe_heavy_smiter_vertical"
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left_charged.damage_profile = "pickaxe_charged_heavies" -- official: "pickaxe_heavy_smiter_vertical_charged"
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right.damage_profile = "pickaxe_uncharged_heavies" -- official: "pickaxe_heavy_smiter_vertical"
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right_charged.damage_profile = "pickaxe_charged_heavies" -- official: "pickaxe_heavy_smiter_vertical_charged"
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.125 -- official: 0.855
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.damage_profile = "tb_warpick_lights" -- official: "pickaxe_medium_tank_diag"
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.125 -- official: 0.855
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.damage_profile = "tb_warpick_lights" -- official: "pickaxe_medium_tank_diag"
Weapons.two_handed_picks_template_1.dodge_count = 3 -- official: 2

-- pickaxe_charged_heavies: replaces the existing block
-- used by Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left_charged.damage_profile
-- used by Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right_charged.damage_profile
NewDamageProfileTemplates.pickaxe_charged_heavies = { -- official: pickaxe_heavy_smiter_vertical_charged
	armor_modifier = "pickaxe_heavy_smiter_vertical_charged_armor_modifier",
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.785, -- official: 0.75
			1.5,
			1,
			1,
			-- removed: [6] (official: 0.85)
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "pickaxe_heavy_smiter_vertical_charged_cleave_distribution",
	shield_break = true,
	default_target = "pickaxe_heavy_smiter_vertical_charged_default_target",
	targets = "pickaxe_heavy_smiter_vertical_charged_targets_smiter",
}

-- pickaxe_uncharged_heavies: replaces the existing block
-- used by Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right.damage_profile
NewDamageProfileTemplates.pickaxe_uncharged_heavies = { -- official: pickaxe_heavy_smiter_vertical
	armor_modifier = "pickaxe_heavy_smiter_vertical_armor_modifier",
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.9, -- official: 0.75
			1.5,
			1,
			1,
			-- removed: [6] (official: 1)
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "pickaxe_heavy_smiter_vertical_cleave_distribution",
	shield_break = true,
	default_target = "pickaxe_heavy_smiter_vertical_default_target",
	targets = "pickaxe_heavy_smiter_vertical_targets",
}

-- tb_warpick_lights: replaces the existing block
-- used by Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.tb_warpick_lights = { -- official: pickaxe_medium_tank_diag
	armor_modifier = "armor_modifier_axe_linesman_M", -- official: "pickaxe_medium_tank_diag_armor_modifier"
	charge_value = "light_attack",
	critical_strike = "critical_strike_axe_linesman_M", -- official: "pickaxe_medium_tank_diag_critical_strike"
	cleave_distribution = {
		attack = 0.4, -- official: 0.3
		impact = 0.4, -- official: 0.8
	},
	default_target = "default_target_axe_linesman_M", -- official: "pickaxe_medium_tank_diag_default_target"
	targets = {
		{
			attack_template = "heavy_slashing_linesman", -- official: "blunt_tank"
			boost_curve_type = "linesman_curve", -- official: "tank_curve"
			boost_curve_coefficient_headshot = 1.5, -- official: 1
			armor_modifier = { -- official: none
				attack = {
					1.25,
					0.3,
					1.5,
					1,
					0.75,
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75,
				},
			},
			power_distribution = {
				attack = 0.225, -- official: 0.2
				impact = 0.2,
			},
		},
		{
			attack_template = "slashing_linesman", -- official: "blunt_tank"
			boost_curve_type = "linesman_curve", -- official: "tank_curve"
			power_distribution = {
				attack = 0.21, -- official: 0.1
				impact = 0.125, -- official: 0.15
			},
		},
		{
			attack_template = "light_slashing_linesman", -- official: "light_blunt_tank"
			boost_curve_type = "linesman_curve", -- official: "tank_curve"
			power_distribution = {
				attack = 0.14, -- official: 0.075
				impact = 0.1,
			},
		},
	},
	-- removed: stagger_duration_modifier (official: 1.5)
}

-- ======== two_handed_spears_elf_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_spears_elf_template_1

		* action_one.heavy_attack_stab: Added armor_modifier.attack[6]: 0.6
		* action_one.heavy_attack_stab: Added critical_strike.attack_armor_power_modifer[6]: 0.6
		* action_one.heavy_attack_stab: Changed damage_profile to elven_spear_heavy_stab (from heavy_slashing_smiter_stab_polearm)
		* action_one.heavy_attack_stab: Increased armor_modifier.attack[2] to 0.45 (from 0.3, +50%)
		* action_one.heavy_attack_stab: Increased armor_modifier.impact[2] to 0.65 (from 0.5, +30%)
		* action_one.heavy_attack_stab: Removed melee_boost_override (was 2.5)
		* action_one.heavy_attack_stab: Removed targets[1].armor_modifier (was <table>)
		* action_one.light_attack_left: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_left: Changed damage_profile to elven_spear_light_thrusts (from medium_slashing_smiter_stab_elf)
		* action_one.light_attack_left: Increased armor_modifier.attack[1] to 1.22 (from 1, +22%)
		* action_one.light_attack_left: Increased armor_modifier.attack[2] to 0.35 (from 0.25, +40%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[1] to 1.22 (from 1, +22%)
		* action_one.light_attack_left: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.4, +25%)
		* action_one.light_attack_left: Increased damage_window_end to 0.39 (from 0.37, +5%)
		* action_one.light_attack_left: Reduced damage_window_start to 0.347 (from 0.35, -1%)
		* action_one.light_attack_left: Removed melee_boost_override (was 2.5)
		* action_one.light_attack_stab_1: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_stab_1: Changed damage_profile to elven_spear_light_thrusts (from medium_slashing_smiter_stab_elf)
		* action_one.light_attack_stab_1: Increased armor_modifier.attack[1] to 1.22 (from 1, +22%)
		* action_one.light_attack_stab_1: Increased armor_modifier.attack[2] to 0.35 (from 0.25, +40%)
		* action_one.light_attack_stab_1: Increased critical_strike.attack_armor_power_modifer[1] to 1.22 (from 1, +22%)
		* action_one.light_attack_stab_1: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.4, +25%)
		* action_one.light_attack_stab_1: Reduced damage_window_start to 0.223 (from 0.25, -11%)
		* action_one.light_attack_stab_1: Removed melee_boost_override (was 2.5)
		* action_one.light_attack_stab_2: Added armor_modifier.attack[6]: 0.45
		* action_one.light_attack_stab_2: Changed damage_profile to elven_spear_light_thrusts (from medium_slashing_smiter_stab_elf)
		* action_one.light_attack_stab_2: Increased armor_modifier.attack[1] to 1.22 (from 1, +22%)
		* action_one.light_attack_stab_2: Increased armor_modifier.attack[2] to 0.35 (from 0.25, +40%)
		* action_one.light_attack_stab_2: Increased critical_strike.attack_armor_power_modifer[1] to 1.22 (from 1, +22%)
		* action_one.light_attack_stab_2: Increased critical_strike.attack_armor_power_modifer[2] to 0.5 (from 0.4, +25%)
		* action_one.light_attack_stab_2: Increased damage_window_end to 0.33 (from 0.3, +10%)
		* action_one.light_attack_stab_2: Reduced damage_window_start to 0.19 (from 0.2, -5%)
		* action_one.light_attack_stab_2: Removed melee_boost_override (was 2.5)

	$END_TB
]]

Weapons.two_handed_spears_elf_template_1.actions.action_one.heavy_attack_stab.damage_profile = "elven_spear_heavy_stab" -- official: "heavy_slashing_smiter_stab_polearm"
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_profile = "elven_spear_light_thrusts" -- official: "medium_slashing_smiter_stab_elf"
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_end = 0.39 -- official: 0.37
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_start = 0.347 -- official: 0.35
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_profile = "elven_spear_light_thrusts" -- official: "medium_slashing_smiter_stab_elf"
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_start = 0.223 -- official: 0.25
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_profile = "elven_spear_light_thrusts" -- official: "medium_slashing_smiter_stab_elf"
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_end = 0.33 -- official: 0.3
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_start = 0.19 -- official: 0.2

-- elven_spear_heavy_stab: replaces the existing block
-- used by Weapons.two_handed_spears_elf_template_1.actions.action_one.heavy_attack_stab.damage_profile
NewDamageProfileTemplates.elven_spear_heavy_stab = { -- official: heavy_slashing_smiter_stab_polearm
	armor_modifier = {
		attack = {
			1,
			0.45, -- official: 0.3
			2,
			1,
			0.75,
			0.6, -- official: none
		},
		impact = {
			1,
			0.65, -- official: 0.5
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
			0.6, -- official: none
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_stab_smiter_H",
	targets = {
		{
			attack_template = "heavy_stab_smiter",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2,
			boost_curve_coefficient = 0.75,
			power_distribution = {
				attack = 0.45,
				impact = 0.25,
			},
			-- removed: armor_modifier (official: <table>)
		},
	},
	-- removed: melee_boost_override (official: 2.5)
}

-- elven_spear_light_thrusts: replaces the existing block
-- used by Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_profile
-- used by Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_profile
NewDamageProfileTemplates.elven_spear_light_thrusts = { -- official: medium_slashing_smiter_stab_elf
	armor_modifier = {
		attack = {
			1.22, -- official: 1
			0.35, -- official: 0.25
			2.25,
			1,
			0.75,
			0.45, -- official: none
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1.22, -- official: 1
			0.5, -- official: 0.4
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_stab_smiter_M_elf",
	-- removed: melee_boost_override (official: 2.5)
}

-- ======== two_handed_swords_template_1 ========

--[[
	$BEGIN_TB
		## two_handed_swords_template_1

		* action_one.heavy_attack_left: Added targets[2].armor_modifier: <table>
		* action_one.heavy_attack_left: Changed damage_profile to tb_two_handed_sword_heavy (from heavy_slashing_linesman)
		* action_one.heavy_attack_left: Increased default_target.power_distribution.attack to 0.14 (from 0.1, +40%)
		* action_one.heavy_attack_left: Increased targets[2].power_distribution.attack to 0.4 (from 0.35, +14%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[2] to 0.25 (from 0.3, -17%)
		* action_one.heavy_attack_left: Reduced armor_modifier.attack[5] to 0.6 (from 1, -40%)
		* action_one.heavy_attack_left: Reduced targets[1].power_distribution.attack to 0.45 (from 0.5, -10%)
		* action_one.heavy_attack_left: Reduced targets[4].power_distribution.attack to 0.15 (from 0.18, -17%)
		* action_one.heavy_attack_right: Added targets[2].armor_modifier: <table>
		* action_one.heavy_attack_right: Changed damage_profile to tb_two_handed_sword_heavy (from heavy_slashing_linesman)
		* action_one.heavy_attack_right: Increased default_target.power_distribution.attack to 0.14 (from 0.1, +40%)
		* action_one.heavy_attack_right: Increased targets[2].power_distribution.attack to 0.4 (from 0.35, +14%)
		* action_one.heavy_attack_right: Reduced armor_modifier.attack[2] to 0.25 (from 0.3, -17%)
		* action_one.heavy_attack_right: Reduced armor_modifier.attack[5] to 0.6 (from 1, -40%)
		* action_one.heavy_attack_right: Reduced targets[1].power_distribution.attack to 0.45 (from 0.5, -10%)
		* action_one.heavy_attack_right: Reduced targets[4].power_distribution.attack to 0.15 (from 0.18, -17%)
		* action_one.light_attack_bopp: Changed damage_profile to medium_slashing_smiter_2h (from heavy_slashing_smiter)
		* action_one.light_attack_bopp: Increased anim_time_scale to 1.35 (from 1.215, +11%)
		* action_one.light_attack_left: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Added targets[3].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_left: Changed damage_profile to tb_two_handed_sword_light (from medium_slashing_linesman_2h)
		* action_one.light_attack_left: Increased cleave_distribution.attack to 0.4 (from 0.35, +14%)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.1 (from 0.075, +33%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.275 (from 0.25, +10%)
		* action_one.light_attack_left: Reduced targets[2].power_distribution.attack to 0.2 (from 0.22, -9%)
		* action_one.light_attack_left: Reduced targets[3].power_distribution.attack to 0.15 (from 0.18, -17%)
		* action_one.light_attack_right: Added targets[2].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Added targets[3].boost_curve_coefficient_headshot: 2
		* action_one.light_attack_right: Changed damage_profile to tb_two_handed_sword_light (from medium_slashing_linesman_2h)
		* action_one.light_attack_right: Increased cleave_distribution.attack to 0.4 (from 0.35, +14%)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.1 (from 0.075, +33%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.275 (from 0.25, +10%)
		* action_one.light_attack_right: Reduced targets[2].power_distribution.attack to 0.2 (from 0.22, -9%)
		* action_one.light_attack_right: Reduced targets[3].power_distribution.attack to 0.15 (from 0.18, -17%)

	$END_TB
]]

Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_two_handed_sword_heavy" -- official: "heavy_slashing_linesman"
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_two_handed_sword_heavy" -- official: "heavy_slashing_linesman"
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.35 -- official: 1.215
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.damage_profile = "medium_slashing_smiter_2h" -- official: "heavy_slashing_smiter"
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_two_handed_sword_light" -- official: "medium_slashing_linesman_2h"
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_two_handed_sword_light" -- official: "medium_slashing_linesman_2h"

-- tb_two_handed_sword_heavy: replaces the existing block
-- used by Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_left.damage_profile
-- used by Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_right.damage_profile
NewDamageProfileTemplates.tb_two_handed_sword_heavy = { -- official: heavy_slashing_linesman
	armor_modifier = {
		attack = {
			1,
			0.25, -- official: 0.3
			2,
			1,
			0.6, -- official: 1
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	charge_value = "heavy_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.75,
		impact = 0.4,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		power_distribution = {
			attack = 0.14, -- official: 0.1
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.45, -- official: 0.5
				impact = 0.275,
			},
		},
		{
			attack_template = "heavy_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			armor_modifier = { -- official: none
				attack = {
					1,
					0.2,
					2,
					1,
					0.6,
				},
				impact = {
					1,
					0.5,
					0.5,
					1,
					1,
				},
			},
			power_distribution = {
				attack = 0.4, -- official: 0.35
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.25,
				impact = 0.1,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15, -- official: 0.18
				impact = 0.075,
			},
		},
	},
}

-- tb_two_handed_sword_light: replaces the existing block
-- used by Weapons.two_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile
-- used by Weapons.two_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile
NewDamageProfileTemplates.tb_two_handed_sword_light = { -- official: medium_slashing_linesman_2h
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			1,
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1,
		},
	},
	cleave_distribution = {
		attack = 0.4, -- official: 0.35
		impact = 0.3,
	},
	default_target = {
		attack_template = "light_slashing_linesman",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 1.5,
		power_distribution = {
			attack = 0.1, -- official: 0.075
			impact = 0.05,
		},
	},
	targets = {
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 2, -- official: 1.5
			boost_curve_coefficient = 2,
			power_distribution = {
				attack = 0.275, -- official: 0.25
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 2, -- official: none
			power_distribution = {
				attack = 0.2, -- official: 0.22
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 2, -- official: none
			power_distribution = {
				attack = 0.15, -- official: 0.18
				impact = 0.1,
			},
		},
	},
}

-- ======== two_handed_swords_wood_elf_template ========

--[[
	$BEGIN_TB
		## two_handed_swords_wood_elf_template

		* action_one.heavy_attack_down_first: Increased anim_time_scale to 1.62 (from 1.35, +20%)
		* action_one.heavy_attack_down_first: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.65, +38%)
		* action_one.heavy_attack_down_first: Increased critical_strike.attack_armor_power_modifer[3] to 3 (from 2.5, +20%)
		* action_one.heavy_attack_down_first: Increased targets[1].armor_modifier.attack[2] to 0.9 (from 0.65, +38%)
		* action_one.heavy_attack_down_first: Increased targets[1].armor_modifier.attack[3] to 2.5 (from 2, +25%)
		* action_one.heavy_attack_down_first: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.heavy_attack_down_first: Reduced buff_data[1].external_multiplier to 1.5 (from 1.7, -12%)
		* action_one.heavy_attack_down_first: Reduced buff_data[2].external_multiplier to 0.5 (from 1.3, -62%)
		* action_one.heavy_attack_down_second: Increased anim_time_scale to 1.35 (from 1.08, +25%)
		* action_one.light_attack_bopp: Reduced anim_time_scale to 0.95 (from 1.35, -30%)
		* action_one.light_attack_left_upward: Increased anim_time_scale to 1.25 (from 1.1340000000000001, +10%)
		* action_one.light_attack_right_upward: Increased anim_time_scale to 1.25 (from 1.1340000000000001, +10%)

	$END_TB
]]

Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.anim_time_scale = 1.62 -- official: 1.35
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[1].external_multiplier = 1.5 -- official: 1.7
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[2].external_multiplier = 0.5 -- official: 1.3
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_second.anim_time_scale = 1.35 -- official: 1.08
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_bopp.anim_time_scale = 0.95 -- official: 1.35
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_left_upward.anim_time_scale = 1.25 -- official: 1.1340000000000001
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_right_upward.anim_time_scale = 1.25 -- official: 1.1340000000000001

-- heavy_slashing_smiter_stab (official profile, changed in place)
-- in shared preset critical_strike_stab_smiter_H.attack_armor_power_modifer: also changes medium_slashing_tank_1h_finesse (2 profiles)
DamageProfileTemplates.heavy_slashing_smiter_stab.critical_strike.attack_armor_power_modifer[2] = 0.9 -- official: 0.65
-- in shared preset critical_strike_stab_smiter_H.attack_armor_power_modifer: also changes medium_slashing_tank_1h_finesse (2 profiles)
DamageProfileTemplates.heavy_slashing_smiter_stab.critical_strike.attack_armor_power_modifer[3] = 3 -- official: 2.5
-- in preset targets_stab_smiter_H[1].armor_modifier.attack (only this profile uses it)
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].armor_modifier.attack[2] = 0.9 -- official: 0.65
-- in preset targets_stab_smiter_H[1].armor_modifier.attack (only this profile uses it)
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].armor_modifier.attack[3] = 2.5 -- official: 2
-- in preset targets_stab_smiter_H[1] (only this profile uses it)
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].boost_curve_coefficient_headshot = 2 -- official: 1.5

-- ======== we_one_hand_sword_template_1 ========

--[[
	$BEGIN_TB
		## we_one_hand_sword_template_1

		* Reduced dodge_count to 4 (from 1e+02, -96%)
		* action_one.heavy_attack_up: Changed targets[1].boost_curve_type to ninja_curve (from tank_curve)
		* action_one.heavy_attack_up: Increased critical_strike.attack_armor_power_modifer[2] to 0.9 (from 0.5, +80%)
		* action_one.heavy_attack_up: Increased critical_strike.attack_armor_power_modifer[3] to 3 (from 1, +200%)
		* action_one.heavy_attack_up: Increased critical_strike.impact_armor_power_modifer[3] to 1 (from 0.5, +100%)
		* action_one.heavy_attack_up: Increased targets[1].armor_modifier.attack[2] to 0.65 (from 0.6, +8%)
		* action_one.heavy_attack_up: Increased targets[1].armor_modifier.attack[3] to 2 (from 1.75, +14%)
		* action_one.heavy_attack_up: Increased targets[1].power_distribution.attack to 0.35 (from 0.32, +9%)
		* action_one.heavy_attack_up: Reduced cleave_distribution.attack to 0.2 (from 0.3, -33%)
		* action_one.heavy_attack_up: Reduced cleave_distribution.impact to 0.6 (from 0.8, -25%)
		* action_one.heavy_attack_up: Reduced targets[1].boost_curve_coefficient_headshot to 1.5 (from 2, -25%)
		* action_one.heavy_attack_up: Reduced targets[2].power_distribution.attack to 0.175 (from 0.18, -3%)
		* action_one.heavy_attack_up: Reduced targets[3].power_distribution.attack to 0.1 (from 0.15, -33%)
		* action_one.light_attack_bopp: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman_elf)
		* action_one.light_attack_bopp: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_bopp: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_bopp: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_bopp: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_bopp: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_bopp: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_bopp: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_bopp: Reduced anim_time_scale to 1.08 (from 1.305, -17%)
		* action_one.light_attack_last: Changed damage_profile to light_slashing_smiter_finesse (from light_slashing_smiter_stab_swords)
		* action_one.light_attack_last: Increased armor_modifier.attack[2] to 0.82 (from 0.65, +26%)
		* action_one.light_attack_last: Increased armor_modifier.attack[6] to 0.82 (from 0.6, +37%)
		* action_one.light_attack_last: Increased range_mod to 1.4 (from 1.2, +17%)
		* action_one.light_attack_last: Reduced allowed_chain_actions[1].start_time to 0.5 (from 0.65, -23%)
		* action_one.light_attack_last: Reduced allowed_chain_actions[2].start_time to 0.5 (from 0.65, -23%)
		* action_one.light_attack_last: Reduced allowed_chain_actions[3].start_time to 0.5 (from 0.65, -23%)
		* action_one.light_attack_last: Reduced anim_time_scale to 0.81 (from 1.215, -33%)
		* action_one.light_attack_left: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman_elf)
		* action_one.light_attack_left: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_left: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_left: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_left: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_left: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_left: Reduced anim_time_scale to 1.08 (from 1.215, -11%)
		* action_one.light_attack_right: Changed damage_profile to tb_1h_sword_light_1_2 (from light_slashing_linesman_elf)
		* action_one.light_attack_right: Changed targets[1].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Changed targets[2].boost_curve_type to ninja_curve (from linesman_curve)
		* action_one.light_attack_right: Increased default_target.power_distribution.attack to 0.125 (from 0.075, +67%)
		* action_one.light_attack_right: Increased range_mod to 1.3 (from 1.2, +8%)
		* action_one.light_attack_right: Increased targets[1].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[1].power_distribution.attack to 0.2 (from 0.175, +14%)
		* action_one.light_attack_right: Increased targets[2].boost_curve_coefficient_headshot to 2 (from 1.5, +33%)
		* action_one.light_attack_right: Increased targets[2].power_distribution.attack to 0.15 (from 0.125, +20%)
		* action_one.light_attack_right: Reduced anim_time_scale to 1.08 (from 1.125, -4%)

	$END_TB
]]

Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.08 -- official: 1.305
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman_elf"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[1].start_time = 0.5 -- official: 0.65
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].start_time = 0.5 -- official: 0.65
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].start_time = 0.5 -- official: 0.65
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.anim_time_scale = 0.81 -- official: 1.215
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.damage_profile = "light_slashing_smiter_finesse" -- official: "light_slashing_smiter_stab_swords"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.range_mod = 1.4 -- official: 1.2
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.08 -- official: 1.215
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman_elf"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.08 -- official: 1.125
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_sword_light_1_2" -- official: "light_slashing_linesman_elf"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.range_mod = 1.3 -- official: 1.2
Weapons.we_one_hand_sword_template_1.dodge_count = 4 -- official: 1e+02

-- light_slashing_smiter_finesse (official profile, changed in place)
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter_finesse.armor_modifier.attack[2] = 0.82 -- official: 0.65
-- in shared preset armor_modifier_smiter_L.attack: also changes light_blunt_smiter, light_blunt_smiter_dual, light_blunt_smiter_dual_diag, light_blunt_smiter_dual_flat, light_slashing_smiter, light_slashing_smiter_diag and 7 more (14 profiles)
DamageProfileTemplates.light_slashing_smiter_finesse.armor_modifier.attack[6] = 0.82 -- official: 0.6

-- uses medium_slashing_tank_1h_finesse (exported under one_handed_swords_template_1)

-- uses tb_1h_sword_light_1_2 (exported under dual_wield_hammer_sword_template)

-- ################ ranged ################

-- ======== bardin_engineer_career_skill_weapon ========

--[[
	$BEGIN_TB
		## bardin_engineer_career_skill_weapon

		* Increased dodge_count to 3 (from 1, +200%)

	$END_TB
]]

Weapons.bardin_engineer_career_skill_weapon.dodge_count = 3 -- official: 1

-- ======== bardin_engineer_career_skill_weapon_special ========

--[[
	$BEGIN_TB
		## bardin_engineer_career_skill_weapon_special

		* Increased dodge_count to 3 (from 1, +200%)

	$END_TB
]]

Weapons.bardin_engineer_career_skill_weapon_special.dodge_count = 3 -- official: 1

-- ======== blunderbuss_template_1 ========

--[[
	$BEGIN_TB
		## blunderbuss_template_1

		* Added max_fatigue_points: 6
		* action_two.default: Added add_fatigue_on_hit: true

	$END_TB
]]

Weapons.blunderbuss_template_1.actions.action_two.default.add_fatigue_on_hit = true -- official: none
Weapons.blunderbuss_template_1.max_fatigue_points = 6 -- official: none

-- ======== brace_of_pistols_template_1 ========

--[[
	$BEGIN_TB
		## brace_of_pistols_template_1

		* Increased ammo_data.max_ammo to 5e+01 (from 3e+01, +67%)
		* Reduced ammo_data.reload_time to 0.8 (from 1, -20%)

	$END_TB
]]

Weapons.brace_of_pistols_template_1.ammo_data.max_ammo = 5e+01 -- official: 3e+01
Weapons.brace_of_pistols_template_1.ammo_data.reload_time = 0.8 -- official: 1

-- ======== bw_deus_01_template_1 ========

--[[
	$BEGIN_TB
		## bw_deus_01_template_1

		* action_one.default: Increased allowed_chain_actions[1].start_time to 0.5 (from 0.4, +25%)
		* action_one.default: Increased shot_count to 15 (from 9, +67%)
		* action_one.default: Reduced default_target.power_distribution_far.attack to 0.06 (from 0.07, -14%)
		* action_one.default: Reduced default_target.power_distribution_near.attack to 0.12 (from 0.16, -25%)
		* action_one.default: Reduced total_time to 0.65 (from 1, -35%)
		* action_two.default: Reduced allowed_chain_actions[1].start_time to 0 (from 0.5, -100%)

		**DoT burning_magma_dot**

		* Added buffs[1].death_flow_event: burn_death
		* Added buffs[1].end_flow_event: smoke
		* Added buffs[1].reapply_start_flow_event: true
		* Added buffs[1].start_flow_event: burn
		* Increased buffs[1].duration to 3 (from 2, +50%)
		* Increased buffs[1].max_stacks to 15 (from 5, +200%)
		* Increased buffs[1].time_between_dot_damages to 1.5 (from 0.5, +200%)
		* Increased buffs[1].update_start_delay to 0.75 (from 0.5, +50%)

		**Explosion magma**

		* Increased aoe.damage_interval to 1 (from 0.5, +100%)
		* Reduced aoe.duration to 3 (from 6, -50%)

	$END_TB
]]

Weapons.bw_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.5 -- official: 0.4
Weapons.bw_deus_01_template_1.actions.action_one.default.shot_count = 15 -- official: 9
Weapons.bw_deus_01_template_1.actions.action_one.default.total_time = 0.65 -- official: 1
Weapons.bw_deus_01_template_1.actions.action_two.default.allowed_chain_actions[1].start_time = 0 -- official: 0.5

-- staff_magma (official profile, changed in place)
DamageProfileTemplates.staff_magma.default_target.power_distribution_far.attack = 0.06 -- official: 0.07
DamageProfileTemplates.staff_magma.default_target.power_distribution_near.attack = 0.12 -- official: 0.16

-- BuffTemplates.burning_magma_dot
BuffTemplates.burning_magma_dot.buffs[1].death_flow_event = "burn_death" -- official: none
BuffTemplates.burning_magma_dot.buffs[1].duration = 3 -- official: 2
BuffTemplates.burning_magma_dot.buffs[1].end_flow_event = "smoke" -- official: none
BuffTemplates.burning_magma_dot.buffs[1].max_stacks = 15 -- official: 5
BuffTemplates.burning_magma_dot.buffs[1].reapply_start_flow_event = true -- official: none
BuffTemplates.burning_magma_dot.buffs[1].start_flow_event = "burn" -- official: none
BuffTemplates.burning_magma_dot.buffs[1].time_between_dot_damages = 1.5 -- official: 0.5
BuffTemplates.burning_magma_dot.buffs[1].update_start_delay = 0.75 -- official: 0.5

-- ExplosionTemplates.magma
ExplosionTemplates.magma.aoe.damage_interval = 1 -- official: 0.5
ExplosionTemplates.magma.aoe.duration = 3 -- official: 6

-- ======== crossbow_template_1 ========

--[[
	$BEGIN_TB
		## crossbow_template_1

		* action_one.default: Reduced total_time to 0 (from 0.42, -100%)
		* action_one.zoomed_shot: Reduced total_time to 0.37 (from 0.8, -54%)

	$END_TB
]]

Weapons.crossbow_template_1.actions.action_one.default.total_time = 0 -- official: 0.42
Weapons.crossbow_template_1.actions.action_one.zoomed_shot.total_time = 0.37 -- official: 0.8

-- ======== dr_deus_01_template_1 ========

--[[
	$BEGIN_TB
		## dr_deus_01_template_1

		* Increased ammo_data.reload_time to 4 (from 3, +33%)
		* action_one.default: Reduced default_target.boost_curve_coefficient to 0.5 (from 1, -50%)

		**Damage profile dr_deus_01_explosion**

		* Added default_target.boost_curve_coefficient: 0.5
		* Added default_target.boost_curve_type: tank_curve
		* Reduced armor_modifier.attack[2] to 0.5 (from 1, -50%)
		* Reduced armor_modifier.attack[5] to 0.25 (from 0.5, -50%)

		**Damage profile dr_deus_01_glance**

		* Added armor_modifier.attack[6]: 0.6
		* Added default_target.boost_curve_coefficient: 0.5
		* Added default_target.boost_curve_type: tank_curve
		* Reduced armor_modifier.attack[1] to 0.6 (from 1, -40%)
		* Reduced armor_modifier.attack[2] to 0.6 (from 1, -40%)

	$END_TB
]]

Weapons.dr_deus_01_template_1.ammo_data.reload_time = 4 -- official: 3

-- dr_deus_01 (official profile, changed in place)
DamageProfileTemplates.dr_deus_01.default_target.boost_curve_coefficient = 0.5 -- official: 1

-- dr_deus_01_explosion (official profile, changed in place)
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack[2] = 0.5 -- official: 1
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack[5] = 0.25 -- official: 0.5
DamageProfileTemplates.dr_deus_01_explosion.default_target.boost_curve_coefficient = 0.5 -- official: none
DamageProfileTemplates.dr_deus_01_explosion.default_target.boost_curve_type = "tank_curve" -- official: none

-- dr_deus_01_glance (official profile, changed in place)
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[1] = 0.6 -- official: 1
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[2] = 0.6 -- official: 1
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[6] = 0.6 -- official: none
DamageProfileTemplates.dr_deus_01_glance.default_target.boost_curve_coefficient = 0.5 -- official: none
DamageProfileTemplates.dr_deus_01_glance.default_target.boost_curve_type = "tank_curve" -- official: none

-- ======== dr_deus_01_template_1_vs ========

--[[
	$BEGIN_TB
		**Damage profile dr_deus_01**

		* Reduced default_target.boost_curve_coefficient to 0.5 (from 1, -50%)

		**Damage profile dr_deus_01_explosion**

		* Added default_target.boost_curve_coefficient: 0.5
		* Added default_target.boost_curve_type: tank_curve
		* Reduced armor_modifier.attack[2] to 0.5 (from 1, -50%)
		* Reduced armor_modifier.attack[5] to 0.25 (from 0.5, -50%)

		**Damage profile dr_deus_01_glance**

		* Added armor_modifier.attack[6]: 0.6
		* Added default_target.boost_curve_coefficient: 0.5
		* Added default_target.boost_curve_type: tank_curve
		* Reduced armor_modifier.attack[1] to 0.6 (from 1, -40%)
		* Reduced armor_modifier.attack[2] to 0.6 (from 1, -40%)

	$END_TB
]]

-- uses dr_deus_01 (exported under dr_deus_01_template_1)

-- uses dr_deus_01_explosion (exported under dr_deus_01_template_1)

-- uses dr_deus_01_glance (exported under dr_deus_01_template_1)

-- ======== drakegun_template_1 ========

--[[
	$BEGIN_TB
		## drakegun_template_1

		* action_one.shoot_charged: Increased damage_interval to 0.3 (from 0.25, +20%)

	$END_TB
]]

Weapons.drakegun_template_1.actions.action_one.shoot_charged.damage_interval = 0.3 -- official: 0.25

-- ======== grudge_raker_template_1 ========

--[[
	$BEGIN_TB
		## grudge_raker_template_1

		* Added max_fatigue_points: 6
		* action_two.default: Added add_fatigue_on_hit: true

	$END_TB
]]

Weapons.grudge_raker_template_1.actions.action_two.default.add_fatigue_on_hit = true -- official: none
Weapons.grudge_raker_template_1.max_fatigue_points = 6 -- official: none

-- ======== handgun_template_1 ========

--[[
	$BEGIN_TB
		## handgun_template_1

		* action_one.default: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.default: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)

	$END_TB
]]

-- shot_sniper (official profile, changed in place)
DamageProfileTemplates.shot_sniper.default_target.range_modifier_settings.dropoff_end = 1e+02 -- official: 5e+01
DamageProfileTemplates.shot_sniper.default_target.range_modifier_settings.dropoff_start = 5e+01 -- official: 3e+01

-- ======== handgun_template_1_vs ========

--[[
	$BEGIN_TB
		## handgun_template_1_vs

		* action_one.default: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.default: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)

	$END_TB
]]

-- uses shot_sniper (exported under handgun_template_1)

-- ======== handgun_template_2 ========

--[[
	$BEGIN_TB
		## handgun_template_2

		* action_one.default: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.default: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)

	$END_TB
]]

-- uses shot_sniper (exported under handgun_template_1)

-- ======== handgun_template_2_vs ========

--[[
	$BEGIN_TB
		## handgun_template_2_vs

		* action_one.default: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.default: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_end to 1e+02 (from 5e+01, +100%)
		* action_one.zoomed_shot: Increased default_target.range_modifier_settings.dropoff_start to 5e+01 (from 3e+01, +67%)

	$END_TB
]]

-- uses shot_sniper (exported under handgun_template_1)

-- ======== heavy_steam_pistol_template_1 ========

--[[
	$BEGIN_TB
		## heavy_steam_pistol_template_1

		* action_one.default: Changed impact_data.damage_profile to masterwork_pistol_shot (from shot_sniper_pistol)
		* action_one.default: Reduced armor_modifier_near.attack[1] to 0.91 (from 1, -9%)
		* action_one.fast_shot: Changed impact_data.damage_profile to masterwork_pistol_shot (from shot_sniper_pistol)
		* action_one.fast_shot: Reduced armor_modifier_near.attack[1] to 0.91 (from 1, -9%)
		* action_one.shoot: Changed impact_data.damage_profile to masterwork_pistol_shot (from shot_sniper_pistol)
		* action_one.shoot: Reduced allowed_chain_actions[1].start_time to 0.3 (from 0.4, -25%)
		* action_one.shoot: Reduced armor_modifier_near.attack[1] to 0.91 (from 1, -9%)
		* action_one.shoot: Reduced total_time to 0.3 (from 0.5, -40%)

	$END_TB
]]

Weapons.heavy_steam_pistol_template_1.actions.action_one.default.impact_data.damage_profile = "masterwork_pistol_shot" -- official: "shot_sniper_pistol"
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.impact_data.damage_profile = "masterwork_pistol_shot" -- official: "shot_sniper_pistol"
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.allowed_chain_actions[1].start_time = 0.3 -- official: 0.4
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.impact_data.damage_profile = "masterwork_pistol_shot" -- official: "shot_sniper_pistol"
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.total_time = 0.3 -- official: 0.5

-- masterwork_pistol_shot: replaces the existing block
-- used by Weapons.heavy_steam_pistol_template_1.actions.action_one.default.impact_data.damage_profile
-- used by Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.impact_data.damage_profile
-- used by Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.impact_data.damage_profile
NewDamageProfileTemplates.masterwork_pistol_shot = { -- official: shot_sniper_pistol
	charge_value = "instant_projectile",
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
	no_stagger_damage_reduction_ranged = true,
	armor_modifier_near = {
		attack = {
			0.91, -- official: 1
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
	shield_break = true,
	default_target = {
		attack_template = "shot_sniper",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 1,
		headshot_boost_boss = 0.5,
		power_distribution_near = {
			attack = 1,
			impact = 0.5,
		},
		power_distribution_far = {
			attack = 0.5,
			impact = 0.5,
		},
		range_modifier_settings = {
			dropoff_end = 15,
			dropoff_start = 8,
		},
	},
}

-- ======== javelin_template ========

--[[
	$BEGIN_TB
		## javelin_template

		* action_one.chain_stab_03: Reduced allowed_chain_actions[2].start_time to 0.45 (from 0.6, -25%)
		* action_one.default: Reduced allowed_chain_actions[2].start_time to 0.4 (from 0.6, -33%)
		* action_one.default_chain_01: Reduced allowed_chain_actions[2].start_time to 0.45 (from 0.6, -25%)
		* action_one.default_chain_02: Reduced allowed_chain_actions[2].start_time to 0.45 (from 0.6, -25%)
		* action_one.default_chain_03: Reduced allowed_chain_actions[2].start_time to 0.45 (from 0.6, -25%)
		* action_one.default_left: Reduced allowed_chain_actions[2].start_time to 0.4 (from 0.6, -33%)
		* action_one.heavy_stab: Reduced allowed_chain_actions[2].start_time to 0.45 (from 0.5, -10%)
		* action_one.stab_01: Reduced allowed_chain_actions[2].start_time to 0.4 (from 0.6, -33%)
		* action_one.stab_02: Reduced allowed_chain_actions[2].start_time to 0.4 (from 0.6, -33%)
		* action_one.throw_charged: Increased armor_modifier_far.attack[2] to 0.7 (from 0.63, +11%)
		* action_one.throw_charged: Increased armor_modifier_far.attack[6] to 0.25 (from 0.2, +25%)
		* action_one.throw_charged: Increased armor_modifier_near.attack[2] to 0.7 (from 0.63, +11%)
		* action_one.throw_charged: Increased armor_modifier_near.attack[6] to 0.25 (from 0.2, +25%)
		* action_one.throw_charged: Increased cleave_distribution.attack to 0.8 (from 0.15, +433%)
		* action_one.throw_charged: Increased cleave_distribution.impact to 0.8 (from 0.15, +433%)
		* action_one.throw_charged: Increased default_target.boost_curve_coefficient_headshot to 1.6 (from 1.5, +7%)
		* action_one.throw_charged: Increased default_target.power_distribution_far.attack to 0.8 (from 0.55, +45%)
		* action_one.throw_charged: Increased default_target.power_distribution_far.impact to 0.85 (from 0.4, +112%)
		* action_one.throw_charged: Increased default_target.power_distribution_near.attack to 0.8 (from 0.76, +5%)
		* action_one.throw_charged: Increased default_target.range_modifier_settings.dropoff_end to 5e+01 (from 3e+01, +67%)
		* action_one.throw_charged: Increased default_target.range_modifier_settings.dropoff_start to 3e+01 (from 15, +100%)
		* action_one.throw_charged: Reduced allowed_chain_actions[2].start_time to 0.3 (from 0.5, -40%)

	$END_TB
]]

Weapons.javelin_template.actions.action_one.chain_stab_03.allowed_chain_actions[2].start_time = 0.45 -- official: 0.6
Weapons.javelin_template.actions.action_one.default.allowed_chain_actions[2].start_time = 0.4 -- official: 0.6
Weapons.javelin_template.actions.action_one.default_chain_01.allowed_chain_actions[2].start_time = 0.45 -- official: 0.6
Weapons.javelin_template.actions.action_one.default_chain_02.allowed_chain_actions[2].start_time = 0.45 -- official: 0.6
Weapons.javelin_template.actions.action_one.default_chain_03.allowed_chain_actions[2].start_time = 0.45 -- official: 0.6
Weapons.javelin_template.actions.action_one.default_left.allowed_chain_actions[2].start_time = 0.4 -- official: 0.6
Weapons.javelin_template.actions.action_one.heavy_stab.allowed_chain_actions[2].start_time = 0.45 -- official: 0.5
Weapons.javelin_template.actions.action_one.stab_01.allowed_chain_actions[2].start_time = 0.4 -- official: 0.6
Weapons.javelin_template.actions.action_one.stab_02.allowed_chain_actions[2].start_time = 0.4 -- official: 0.6
Weapons.javelin_template.actions.action_one.throw_charged.allowed_chain_actions[2].start_time = 0.3 -- official: 0.5

-- thrown_javelin (official profile, changed in place)
DamageProfileTemplates.thrown_javelin.armor_modifier_far.attack[2] = 0.7 -- official: 0.63
DamageProfileTemplates.thrown_javelin.armor_modifier_far.attack[6] = 0.25 -- official: 0.2
DamageProfileTemplates.thrown_javelin.armor_modifier_near.attack[2] = 0.7 -- official: 0.63
DamageProfileTemplates.thrown_javelin.armor_modifier_near.attack[6] = 0.25 -- official: 0.2
DamageProfileTemplates.thrown_javelin.cleave_distribution.attack = 0.8 -- official: 0.15
DamageProfileTemplates.thrown_javelin.cleave_distribution.impact = 0.8 -- official: 0.15
DamageProfileTemplates.thrown_javelin.default_target.boost_curve_coefficient_headshot = 1.6 -- official: 1.5
DamageProfileTemplates.thrown_javelin.default_target.power_distribution_far.attack = 0.8 -- official: 0.55
DamageProfileTemplates.thrown_javelin.default_target.power_distribution_far.impact = 0.85 -- official: 0.4
DamageProfileTemplates.thrown_javelin.default_target.power_distribution_near.attack = 0.8 -- official: 0.76
DamageProfileTemplates.thrown_javelin.default_target.range_modifier_settings.dropoff_end = 5e+01 -- official: 3e+01
DamageProfileTemplates.thrown_javelin.default_target.range_modifier_settings.dropoff_start = 3e+01 -- official: 15

-- ======== kerillian_waywatcher_career_skill_weapon ========

--[[
	$BEGIN_TB
		## kerillian_waywatcher_career_skill_weapon

		* action_career_hold.prioritized_breeds: Added prioritized_breeds: <table>
		* action_career_release.default: Added friendly_fire_multiplier: 0.25
		* action_career_release.default: Increased armor_modifier_far.attack[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_far.attack[6] to 0.6 (from 0.25, +140%)
		* action_career_release.default: Increased armor_modifier_near.attack[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_near.attack[6] to 0.6 (from 0.25, +140%)
		* action_career_release.default: Increased cleave_distribution.attack to 0.375 (from 0.25, +50%)
		* action_career_release.default: Increased cleave_distribution.impact to 0.375 (from 0.25, +50%)
		* action_career_release.default: Increased critical_strike.attack_armor_power_modifer[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased critical_strike.attack_armor_power_modifer[6] to 0.6 (from 0.25, +140%)
		* action_career_release.default: Reduced critical_strike.attack_armor_power_modifer[4] to 0.25 (from 1, -75%)
		* action_career_release.default: Removed default_target.range_modifier_settings (was <table>)

	$END_TB
]]

Weapons.kerillian_waywatcher_career_skill_weapon.actions.action_career_hold.prioritized_breeds = { -- official: none
	beastmen_standard_bearer = 1,
	chaos_corruptor_sorcerer = 1,
	chaos_vortex_sorcerer = 1,
	skaven_gutter_runner = 1,
	skaven_pack_master = 1,
	skaven_poison_wind_globadier = 1,
	skaven_ratling_gunner = 1,
	skaven_warpfire_thrower = 1,
}

-- arrow_sniper_trueflight (official profile, changed in place)
DamageProfileTemplates.arrow_sniper_trueflight.armor_modifier_far.attack[1] = 1.5 -- official: 1
DamageProfileTemplates.arrow_sniper_trueflight.armor_modifier_far.attack[6] = 0.6 -- official: 0.25
DamageProfileTemplates.arrow_sniper_trueflight.armor_modifier_near.attack[1] = 1.5 -- official: 1
DamageProfileTemplates.arrow_sniper_trueflight.armor_modifier_near.attack[6] = 0.6 -- official: 0.25
DamageProfileTemplates.arrow_sniper_trueflight.cleave_distribution.attack = 0.375 -- official: 0.25
DamageProfileTemplates.arrow_sniper_trueflight.cleave_distribution.impact = 0.375 -- official: 0.25
DamageProfileTemplates.arrow_sniper_trueflight.critical_strike.attack_armor_power_modifer[1] = 1.5 -- official: 1
DamageProfileTemplates.arrow_sniper_trueflight.critical_strike.attack_armor_power_modifer[4] = 0.25 -- official: 1
DamageProfileTemplates.arrow_sniper_trueflight.critical_strike.attack_armor_power_modifer[6] = 0.6 -- official: 0.25
DamageProfileTemplates.arrow_sniper_trueflight.default_target.range_modifier_settings = nil -- official: <table>
DamageProfileTemplates.arrow_sniper_trueflight.friendly_fire_multiplier = 0.25 -- official: none

-- ======== kerillian_waywatcher_career_skill_weapon_piercing_shot ========

--[[
	$BEGIN_TB
		## kerillian_waywatcher_career_skill_weapon_piercing_shot

		* action_career_release.default: Added friendly_fire_multiplier: 0.25

	$END_TB
]]

-- arrow_sniper_ability_piercing (official profile, changed in place)
DamageProfileTemplates.arrow_sniper_ability_piercing.friendly_fire_multiplier = 0.25 -- official: none

-- ======== longbow_empire_template ========

--[[
	$BEGIN_TB
		## longbow_empire_template

		* Reduced ammo_data.reload_time to 0 (from 0.65, -100%)
		* action_one.default: Reduced allowed_chain_actions[2].start_time to 0.4 (from 0.6, -33%)
		* action_one.default: Reduced default_target.boost_curve_coefficient to 0.6 (from 1.25, -52%)
		* action_one.default: Reduced default_target.boost_curve_coefficient_headshot to 0.8 (from 1, -20%)
		* action_one.default: Reduced override_reload_time to 0.15 (from 0.25, -40%)
		* action_one.shoot_charged: Added allowed_chain_actions[4]: <table>
		* action_one.shoot_charged: Increased speed to 1.1e+04 (from 1e+04, +10%)
		* action_one.shoot_charged: Reduced allowed_chain_actions[2].start_time to 0.7 (from 0.75, -7%)
		* action_one.shoot_charged: Reduced reload_event_delay_time to 0.15 (from 0.3, -50%)
		* action_one.shoot_charged: Removed override_reload_time (was 0.5)
		* action_one.shoot_charged_heavy: Added allowed_chain_actions[4]: <table>
		* action_one.shoot_charged_heavy: Increased armor_modifier_near.attack[2] to 1.25 (from 1, +25%)
		* action_one.shoot_charged_heavy: Reduced allowed_chain_actions[2].start_time to 0.68 (from 0.85, -20%)
		* action_one.shoot_charged_heavy: Reduced critical_strike.attack_armor_power_modifer[3] to 1 (from 1.5, -33%)
		* action_one.shoot_charged_heavy: Reduced reload_event_delay_time to 0.1 (from 0.3, -67%)
		* action_one.shoot_charged_heavy: Removed override_reload_time (was 0.5)
		* action_two.default: Reduced aim_zoom_delay to 0.01 (from 0.22, -95%)

		**Spread empire_longbow**

		* Reduced continuous.crouch_still.max_pitch to 0.75 (from 1.25, -40%)
		* Reduced continuous.crouch_still.max_yaw to 0.75 (from 1.25, -40%)
		* Reduced continuous.moving.max_pitch to 0.4 (from 0.75, -47%)
		* Reduced continuous.moving.max_yaw to 0.4 (from 0.75, -47%)
		* Reduced continuous.still.max_pitch to 0.25 (from 0.5, -50%)
		* Reduced continuous.still.max_yaw to 0.25 (from 0.5, -50%)
		* Reduced continuous.zoomed_crouch_moving.max_pitch to 0.4 (from 2, -80%)
		* Reduced continuous.zoomed_crouch_moving.max_yaw to 0.4 (from 2, -80%)
		* Reduced continuous.zoomed_crouch_still.max_pitch to 0 (from 1.5, -100%)
		* Reduced continuous.zoomed_crouch_still.max_yaw to 0 (from 1.5, -100%)
		* Reduced continuous.zoomed_moving.max_pitch to 0.4 (from 0.75, -47%)
		* Reduced continuous.zoomed_moving.max_yaw to 0.4 (from 0.75, -47%)
		* Reduced continuous.zoomed_still.max_pitch to 0 (from 0.25, -100%)
		* Reduced continuous.zoomed_still.max_yaw to 0 (from 0.25, -100%)

	$END_TB
]]

Weapons.longbow_empire_template.actions.action_one.default.allowed_chain_actions[2].start_time = 0.4 -- official: 0.6
Weapons.longbow_empire_template.actions.action_one.default.override_reload_time = 0.15 -- official: 0.25
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[2].start_time = 0.7 -- official: 0.75
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4] = { -- official: none
	action = "action_one",
	end_time = math.huge,
	input = "action_one",
	release_required = "action_two_hold",
	start_time = 0.4,
	sub_action = "default",
}
Weapons.longbow_empire_template.actions.action_one.shoot_charged.override_reload_time = nil -- official: 0.5
Weapons.longbow_empire_template.actions.action_one.shoot_charged.reload_event_delay_time = 0.15 -- official: 0.3
Weapons.longbow_empire_template.actions.action_one.shoot_charged.speed = 1.1e+04 -- official: 1e+04
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[2].start_time = 0.68 -- official: 0.85
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4] = { -- official: none
	action = "action_one",
	end_time = math.huge,
	input = "action_one",
	release_required = "action_two_hold",
	start_time = 0.25,
	sub_action = "default",
}
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.override_reload_time = nil -- official: 0.5
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.reload_event_delay_time = 0.1 -- official: 0.3
Weapons.longbow_empire_template.actions.action_two.default.aim_zoom_delay = 0.01 -- official: 0.22
Weapons.longbow_empire_template.ammo_data.reload_time = 0 -- official: 0.65

-- arrow_carbine (official profile, changed in place)
DamageProfileTemplates.arrow_carbine.default_target.boost_curve_coefficient = 0.6 -- official: 1.25
DamageProfileTemplates.arrow_carbine.default_target.boost_curve_coefficient_headshot = 0.8 -- official: 1

-- arrow_sniper_kruber (official profile, changed in place)
DamageProfileTemplates.arrow_sniper_kruber.armor_modifier_near.attack[2] = 1.25 -- official: 1
DamageProfileTemplates.arrow_sniper_kruber.critical_strike.attack_armor_power_modifer[3] = 1 -- official: 1.5

-- SpreadTemplates.empire_longbow
SpreadTemplates.empire_longbow.continuous.crouch_still.max_pitch = 0.75 -- official: 1.25
SpreadTemplates.empire_longbow.continuous.crouch_still.max_yaw = 0.75 -- official: 1.25
SpreadTemplates.empire_longbow.continuous.moving.max_pitch = 0.4 -- official: 0.75
SpreadTemplates.empire_longbow.continuous.moving.max_yaw = 0.4 -- official: 0.75
SpreadTemplates.empire_longbow.continuous.still.max_pitch = 0.25 -- official: 0.5
SpreadTemplates.empire_longbow.continuous.still.max_yaw = 0.25 -- official: 0.5
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_moving.max_pitch = 0.4 -- official: 2
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_moving.max_yaw = 0.4 -- official: 2
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_still.max_pitch = 0 -- official: 1.5
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_still.max_yaw = 0 -- official: 1.5
SpreadTemplates.empire_longbow.continuous.zoomed_moving.max_pitch = 0.4 -- official: 0.75
SpreadTemplates.empire_longbow.continuous.zoomed_moving.max_yaw = 0.4 -- official: 0.75
SpreadTemplates.empire_longbow.continuous.zoomed_still.max_pitch = 0 -- official: 0.25
SpreadTemplates.empire_longbow.continuous.zoomed_still.max_yaw = 0 -- official: 0.25

-- ======== longbow_empire_tutorial_template ========

--[[
	$BEGIN_TB
		**Damage profile arrow_carbine**

		* Reduced default_target.boost_curve_coefficient to 0.6 (from 1.25, -52%)
		* Reduced default_target.boost_curve_coefficient_headshot to 0.8 (from 1, -20%)

		**Spread empire_longbow**

		* Reduced continuous.crouch_still.max_pitch to 0.75 (from 1.25, -40%)
		* Reduced continuous.crouch_still.max_yaw to 0.75 (from 1.25, -40%)
		* Reduced continuous.moving.max_pitch to 0.4 (from 0.75, -47%)
		* Reduced continuous.moving.max_yaw to 0.4 (from 0.75, -47%)
		* Reduced continuous.still.max_pitch to 0.25 (from 0.5, -50%)
		* Reduced continuous.still.max_yaw to 0.25 (from 0.5, -50%)
		* Reduced continuous.zoomed_crouch_moving.max_pitch to 0.4 (from 2, -80%)
		* Reduced continuous.zoomed_crouch_moving.max_yaw to 0.4 (from 2, -80%)
		* Reduced continuous.zoomed_crouch_still.max_pitch to 0 (from 1.5, -100%)
		* Reduced continuous.zoomed_crouch_still.max_yaw to 0 (from 1.5, -100%)
		* Reduced continuous.zoomed_moving.max_pitch to 0.4 (from 0.75, -47%)
		* Reduced continuous.zoomed_moving.max_yaw to 0.4 (from 0.75, -47%)
		* Reduced continuous.zoomed_still.max_pitch to 0 (from 0.25, -100%)
		* Reduced continuous.zoomed_still.max_yaw to 0 (from 0.25, -100%)

	$END_TB
]]

-- uses arrow_carbine (exported under longbow_empire_template)

-- uses SpreadTemplates.empire_longbow (exported under longbow_empire_template)

-- ======== longbow_template_1 ========

--[[
	$BEGIN_TB
		## longbow_template_1

		* action_one.default: Reduced default_target.boost_curve_coefficient to 0.6 (from 1.25, -52%)
		* action_one.default: Reduced default_target.boost_curve_coefficient_headshot to 0.8 (from 1, -20%)

	$END_TB
]]

-- uses arrow_carbine (exported under longbow_empire_template)

-- ======== shortbow_hagbane_template_1 ========

--[[
	$BEGIN_TB
		**Damage profile poison**

		* Increased armor_modifier.attack[1] to 1.6 (from 1.25, +28%)

		**Damage profile poison_aoe**

		* Reduced armor_modifier.attack[2] to 0 (from 0.1, -100%)

	$END_TB
]]

-- poison (official profile, changed in place)
DamageProfileTemplates.poison.armor_modifier.attack[1] = 1.6 -- official: 1.25

-- poison_aoe (official profile, changed in place)
DamageProfileTemplates.poison_aoe.armor_modifier.attack[2] = 0 -- official: 0.1

-- ======== shortbow_template_1 ========

--[[
	$BEGIN_TB
		## shortbow_template_1

		* action_one.default: Added friendly_fire_multiplier: 0.15
		* action_one.default: Added shield_break: false
		* action_one.default: Changed default_target.boost_curve_type to linesman_curve (from ninja_curve)
		* action_one.default: Increased armor_modifier_far.attack[2] to 0.1 (from 0)
		* action_one.default: Increased armor_modifier_near.attack[2] to 0.1 (from 0)
		* action_one.default: Increased cleave_distribution.attack to 0.25 (from 0.205, +22%)
		* action_one.default: Increased cleave_distribution.impact to 0.25 (from 0.205, +22%)
		* action_one.default: Increased default_target.power_distribution_far.attack to 0.25 (from 0.125, +100%)
		* action_one.default: Increased default_target.power_distribution_near.attack to 0.3 (from 0.25, +20%)
		* action_one.default: Reduced armor_modifier_far.attack[5] to 0.5 (from 1, -50%)
		* action_one.default: Reduced armor_modifier_near.attack[5] to 0.5 (from 1, -50%)
		* action_one.default: Reduced default_target.boost_curve_coefficient to 0.6 (from 0.75, -20%)
		* action_one.shoot_charged: Added default_target.power_distribution_near.far: 0.35
		* action_one.shoot_charged: Increased default_target.power_distribution_near.attack to 0.44 (from 0.4, +10%)
		* action_one.shoot_charged: Reduced cleave_distribution.attack to 0.25 (from 0.3, -17%)
		* action_one.shoot_charged: Reduced cleave_distribution.impact to 0.25 (from 0.3, -17%)
		* action_one.shoot_special_charged: Reduced default_target.boost_curve_coefficient to 0.6 (from 1.25, -52%)
		* action_one.shoot_special_charged: Reduced default_target.boost_curve_coefficient_headshot to 0.8 (from 1, -20%)

	$END_TB
]]

-- uses arrow_carbine (exported under longbow_empire_template)

-- arrow_carbine_shortbow (official profile, changed in place)
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.attack = 0.25 -- official: 0.3
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.impact = 0.25 -- official: 0.3
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.attack = 0.44 -- official: 0.4
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.far = 0.35 -- official: none

-- arrow_machinegun (official profile, changed in place)
DamageProfileTemplates.arrow_machinegun.armor_modifier_far.attack[2] = 0.1 -- official: 0
DamageProfileTemplates.arrow_machinegun.armor_modifier_far.attack[5] = 0.5 -- official: 1
DamageProfileTemplates.arrow_machinegun.armor_modifier_near.attack[2] = 0.1 -- official: 0
DamageProfileTemplates.arrow_machinegun.armor_modifier_near.attack[5] = 0.5 -- official: 1
DamageProfileTemplates.arrow_machinegun.cleave_distribution.attack = 0.25 -- official: 0.205
DamageProfileTemplates.arrow_machinegun.cleave_distribution.impact = 0.25 -- official: 0.205
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_coefficient = 0.6 -- official: 0.75
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_type = "linesman_curve" -- official: "ninja_curve"
DamageProfileTemplates.arrow_machinegun.default_target.power_distribution_far.attack = 0.25 -- official: 0.125
DamageProfileTemplates.arrow_machinegun.default_target.power_distribution_near.attack = 0.3 -- official: 0.25
DamageProfileTemplates.arrow_machinegun.friendly_fire_multiplier = 0.15 -- official: none
DamageProfileTemplates.arrow_machinegun.shield_break = false -- official: none

-- ======== sienna_scholar_career_skill_weapon ========

--[[
	$BEGIN_TB
		## sienna_scholar_career_skill_weapon

		* action_career_hold.prioritized_breeds: Added prioritized_breeds: <table>
		* action_career_release.default: Added friendly_fire_multiplier: 0
		* action_career_release.default: Increased armor_modifier_far.attack[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_far.attack[5] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_far.impact[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_far.impact[4] to 0.25 (from 0)
		* action_career_release.default: Increased armor_modifier_far.impact[5] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_near.attack[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_near.attack[5] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_near.impact[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased armor_modifier_near.impact[4] to 0.25 (from 0)
		* action_career_release.default: Increased armor_modifier_near.impact[5] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased cleave_distribution.attack to 0.5 (from 0.4, +25%)
		* action_career_release.default: Increased cleave_distribution.impact to 0.5 (from 0.4, +25%)
		* action_career_release.default: Increased critical_strike.attack_armor_power_modifer[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased critical_strike.attack_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased critical_strike.impact_armor_power_modifer[1] to 1.5 (from 1, +50%)
		* action_career_release.default: Increased critical_strike.impact_armor_power_modifer[5] to 1.5 (from 1, +50%)
		* action_career_release.default: Reduced armor_modifier_far.impact[3] to 2.5 (from 1e+02, -98%)
		* action_career_release.default: Reduced armor_modifier_near.impact[3] to 2.5 (from 1e+02, -98%)
		* action_career_release.default: Reduced critical_strike.impact_armor_power_modifer[3] to 2.5 (from 1e+02, -98%)
		* action_career_release.default: Reduced total_time to 0.3 (from 1, -70%)

	$END_TB
]]

Weapons.sienna_scholar_career_skill_weapon.actions.action_career_hold.prioritized_breeds = { -- official: none
	beastmen_standard_bearer = 1,
	chaos_corruptor_sorcerer = 1,
	chaos_vortex_sorcerer = 1,
	skaven_gutter_runner = 1,
	skaven_pack_master = 1,
	skaven_poison_wind_globadier = 1,
	skaven_ratling_gunner = 1,
	skaven_warpfire_thrower = 1,
}
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_release.default.total_time = 0.3 -- official: 1

-- fire_spear_trueflight (official profile, changed in place)
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.attack[1] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.attack[5] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact[1] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact[3] = 2.5 -- official: 1e+02
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact[4] = 0.25 -- official: 0
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact[5] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.attack[1] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.attack[5] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact[1] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact[3] = 2.5 -- official: 1e+02
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact[4] = 0.25 -- official: 0
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact[5] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.attack = 0.5 -- official: 0.4
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.impact = 0.5 -- official: 0.4
DamageProfileTemplates.fire_spear_trueflight.critical_strike.attack_armor_power_modifer[1] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.critical_strike.attack_armor_power_modifer[5] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer[1] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer[3] = 2.5 -- official: 1e+02
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer[5] = 1.5 -- official: 1
DamageProfileTemplates.fire_spear_trueflight.friendly_fire_multiplier = 0 -- official: none

-- ======== staff_blast_beam_template_1 ========

--[[
	$BEGIN_TB
		## staff_blast_beam_template_1

		* action_one.default: Added default_zoom: zoom_in
		* action_one.default: Added zoom_thresholds: <table>
		* action_one.shoot_charged: Changed damage_profile to beam_blast (from blast)
		* action_one.shoot_charged: Reduced armor_modifier.attack[5] to 0.6 (from 1, -40%)
		* action_one.shoot_charged: Reduced critical_strike.attack_armor_power_modifer[5] to 0.7 (from 1, -30%)
		* action_one.shoot_charged: Reduced critical_strike.attack_armor_power_modifer[6] to 0.15 (from 0.25, -40%)
		* action_two.charged_beam: Changed spread_template_override to spear (from handgun)
		* action_two.charged_beam: Increased default_target.power_distribution_near.attack to 0.85 (from 0.7, +21%)
		* action_two.charged_beam: Reduced damage_window_start to 0.01 (from 0.1, -90%)
		* action_two.default: Added aim_zoom_delay: 0.01

	$END_TB
]]

Weapons.staff_blast_beam_template_1.actions.action_one.default.default_zoom = "zoom_in" -- official: none
Weapons.staff_blast_beam_template_1.actions.action_one.default.zoom_thresholds = { -- official: none
	"zoom_in_trueflight",
	"zoom_in",
}
Weapons.staff_blast_beam_template_1.actions.action_one.shoot_charged.damage_profile = "beam_blast" -- official: "blast"
Weapons.staff_blast_beam_template_1.actions.action_two.charged_beam.damage_window_start = 0.01 -- official: 0.1
Weapons.staff_blast_beam_template_1.actions.action_two.charged_beam.spread_template_override = "spear" -- official: "handgun"
Weapons.staff_blast_beam_template_1.actions.action_two.default.aim_zoom_delay = 0.01 -- official: none

-- beam_blast: replaces the existing block
-- used by Weapons.staff_blast_beam_template_1.actions.action_one.shoot_charged.damage_profile
NewDamageProfileTemplates.beam_blast = { -- official: blast
	armor_modifier = {
		attack = {
			1,
			0,
			1,
			1,
			0.6, -- official: 1
			0,
		},
		impact = {
			1,
			0.25,
			1,
			1,
			1,
			0,
		},
	},
	charge_value = "projectile",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.2,
			1,
			1,
			0.7, -- official: 1
			0.15, -- official: 0.25
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.25,
		},
	},
	no_stagger_damage_reduction_ranged = true,
	dot_balefire_variant = true,
	dot_template_name = "burning_dot_1tick",
	cleave_distribution = {
		attack = 0.05,
		impact = 0.05,
	},
	default_target = {
		attack_template = "flame_blast",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 2,
		boost_curve_coefficient = 0.5,
		power_distribution_near = {
			attack = 0.1,
			impact = 0.275,
		},
		power_distribution_far = {
			attack = 0.05,
			impact = 0.15,
		},
		range_modifier_settings = {
			dropoff_end = 3e+01,
			dropoff_start = 15,
		},
	},
}

-- beam_shot (official profile, changed in place)
DamageProfileTemplates.beam_shot.default_target.power_distribution_near.attack = 0.85 -- official: 0.7

-- ======== staff_death ========

--[[
	$BEGIN_TB
		## staff_death

		* action_one.default: Changed chain_hit_settings.damage_profile to soulstealer_left_click (from death_staff_curse)
		* action_one.default: Changed impact_data.damage_profile to soulstealer_left_click (from death_staff_curse)
		* action_one.default: Reduced armor_modifier.attack[5] to 0.75 (from 0.8, -6%)
		* action_one.default: Reduced critical_strike.attack_armor_power_modifer[2] to 0.13 (from 0.35, -63%)
		* action_one.default: Reduced critical_strike.attack_armor_power_modifer[5] to 0.64 (from 1, -36%)
		* action_one.default_02: Changed chain_hit_settings.damage_profile to soulstealer_left_click (from death_staff_curse)
		* action_one.default_02: Changed impact_data.damage_profile to soulstealer_left_click (from death_staff_curse)
		* action_one.default_02: Reduced armor_modifier.attack[5] to 0.75 (from 0.8, -6%)
		* action_one.default_02: Reduced critical_strike.attack_armor_power_modifer[2] to 0.13 (from 0.35, -63%)
		* action_one.default_02: Reduced critical_strike.attack_armor_power_modifer[5] to 0.64 (from 1, -36%)
		* action_one.soul_rip: Changed damage_steps[2].damage_profile to soulstealer_soul_rip_aka_da_suck (from soul_rip)
		* action_one.soul_rip: Increased armor_modifier_far.attack[1] to 1.295 (from 1, +29%)
		* action_one.soul_rip: Increased armor_modifier_near.attack[1] to 1.295 (from 1, +29%)
		* action_one.soul_rip: Reduced armor_modifier_far.attack[2] to 0.72 (from 1, -28%)
		* action_one.soul_rip: Reduced armor_modifier_far.attack[3] to 1.5 (from 2.5, -40%)
		* action_one.soul_rip: Reduced armor_modifier_far.attack[5] to 0.36 (from 0.75, -52%)
		* action_one.soul_rip: Reduced armor_modifier_far.attack[6] to 0.63 (from 0.7, -10%)
		* action_one.soul_rip: Reduced armor_modifier_far.impact[2] to 0 (from 1, -100%)
		* action_one.soul_rip: Reduced armor_modifier_far.impact[6] to 0 (from 0.75, -100%)
		* action_one.soul_rip: Reduced armor_modifier_near.attack[2] to 0.806 (from 1.2, -33%)
		* action_one.soul_rip: Reduced armor_modifier_near.attack[3] to 2.1 (from 2.5, -16%)
		* action_one.soul_rip: Reduced armor_modifier_near.attack[5] to 0.4 (from 0.75, -47%)
		* action_one.soul_rip: Reduced armor_modifier_near.impact[2] to 0 (from 1, -100%)
		* action_one.soul_rip: Reduced armor_modifier_near.impact[6] to 0 (from 1, -100%)
		* action_one.soul_rip: Reduced critical_strike.attack_armor_power_modifer[1] to 0.95 (from 1, -5%)
		* action_one.soul_rip: Reduced critical_strike.attack_armor_power_modifer[2] to 0.637 (from 1.4, -54%)
		* action_one.soul_rip: Reduced critical_strike.attack_armor_power_modifer[3] to 1.6 (from 3, -47%)
		* action_one.soul_rip: Reduced critical_strike.attack_armor_power_modifer[5] to 0.23 (from 1, -77%)
		* action_one.soul_rip: Reduced critical_strike.attack_armor_power_modifer[6] to 0.54 (from 1, -46%)
		* action_one.soul_rip: Reduced critical_strike.impact_armor_power_modifer[2] to 0 (from 1, -100%)
		* action_one.soul_rip: Reduced critical_strike.impact_armor_power_modifer[6] to 0 (from 1, -100%)
		* action_two.default: Added prioritized_breeds.chaos_bulwark: 0.75
		* action_two.default: Added prioritized_breeds.skaven_loot_rat: 1
		* action_two.default: Added prioritized_breeds.skaven_storm_vermin_champion: 0.75
		* action_two.default: Reduced prioritized_breeds.beastmen_bestigor to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.chaos_berzerker to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.chaos_raider to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.chaos_warrior to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.skaven_plague_monk to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.skaven_storm_vermin to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.skaven_storm_vermin_commander to 0.75 (from 1, -25%)
		* action_two.default: Reduced prioritized_breeds.skaven_storm_vermin_with_shield to 0.75 (from 1, -25%)
		* action_two.default: Removed prioritized_breeds.chaos_tether_sorcerer (was 1)

	$END_TB
]]

Weapons.staff_death.actions.action_one.default.chain_hit_settings.damage_profile = "soulstealer_left_click" -- official: "death_staff_curse"
Weapons.staff_death.actions.action_one.default.impact_data.damage_profile = "soulstealer_left_click" -- official: "death_staff_curse"
Weapons.staff_death.actions.action_one.default_02.chain_hit_settings.damage_profile = "soulstealer_left_click" -- official: "death_staff_curse"
Weapons.staff_death.actions.action_one.default_02.impact_data.damage_profile = "soulstealer_left_click" -- official: "death_staff_curse"
Weapons.staff_death.actions.action_one.soul_rip.damage_steps[2].damage_profile = "soulstealer_soul_rip_aka_da_suck" -- official: "soul_rip"
Weapons.staff_death.actions.action_two.default.prioritized_breeds.beastmen_bestigor = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.chaos_berzerker = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.chaos_bulwark = 0.75 -- official: none
Weapons.staff_death.actions.action_two.default.prioritized_breeds.chaos_raider = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.chaos_tether_sorcerer = nil -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.chaos_warrior = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.skaven_loot_rat = 1 -- official: none
Weapons.staff_death.actions.action_two.default.prioritized_breeds.skaven_plague_monk = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.skaven_storm_vermin = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.skaven_storm_vermin_champion = 0.75 -- official: none
Weapons.staff_death.actions.action_two.default.prioritized_breeds.skaven_storm_vermin_commander = 0.75 -- official: 1
Weapons.staff_death.actions.action_two.default.prioritized_breeds.skaven_storm_vermin_with_shield = 0.75 -- official: 1

-- soulstealer_left_click: replaces the existing block
-- used by Weapons.staff_death.actions.action_one.default.chain_hit_settings.damage_profile
-- used by Weapons.staff_death.actions.action_one.default.impact_data.damage_profile
-- used by Weapons.staff_death.actions.action_one.default_02.chain_hit_settings.damage_profile
-- used by Weapons.staff_death.actions.action_one.default_02.impact_data.damage_profile
NewDamageProfileTemplates.soulstealer_left_click = { -- official: death_staff_curse
	armor_modifier = {
		attack = {
			0.8,
			0.32,
			1,
			1,
			0.75, -- official: 0.8
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
	charge_value = "projectile",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.13, -- official: 0.35
			1.2,
			1,
			0.64, -- official: 1
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
	no_stagger_damage_reduction_ranged = true,
	no_friendly_fire = true,
	require_damage_for_dot = false,
	cleave_distribution = {
		attack = 0,
		impact = 0,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 0.75,
		dot_balefire_variant = true,
		dot_template_name = "death_staff_dot",
		power_distribution = {
			attack = 0.24,
			impact = 0.25,
		},
	},
	targets = {
		{
			attack_template = "fireball",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.16,
				impact = 0.25,
			},
		},
		{
			attack_template = "fireball",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.08,
				impact = 0.25,
			},
		},
		{
			attack_template = "fireball",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.06,
				impact = 0.22,
			},
		},
		{
			attack_template = "fireball",
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			boost_curve_coefficient = 0.75,
			dot_balefire_variant = true,
			dot_template_name = "death_staff_dot",
			power_distribution = {
				attack = 0.08,
				impact = 0.18,
			},
		},
	},
}

-- soulstealer_soul_rip_aka_da_suck: replaces the existing block
-- used by Weapons.staff_death.actions.action_one.soul_rip.damage_steps[2].damage_profile
NewDamageProfileTemplates.soulstealer_soul_rip_aka_da_suck = { -- official: soul_rip
	charge_value = "heavy_instant_projectile",
	critical_strike = {
		attack_armor_power_modifer = {
			0.95, -- official: 1
			0.637, -- official: 1.4
			1.6, -- official: 3
			1,
			0.23, -- official: 1
			0.54, -- official: 1
		},
		impact_armor_power_modifer = {
			1,
			0, -- official: 1
			1,
			1,
			1,
			0, -- official: 1
		},
	},
	no_stagger_damage_reduction_ranged = true,
	armor_modifier_near = {
		attack = {
			1.295, -- official: 1
			0.806, -- official: 1.2
			2.1, -- official: 2.5
			1,
			0.4, -- official: 0.75
			0.7,
		},
		impact = {
			1,
			0, -- official: 1
			1,
			1,
			1,
			0, -- official: 1
		},
	},
	armor_modifier_far = {
		attack = {
			1.295, -- official: 1
			0.72, -- official: 1
			1.5, -- official: 2.5
			1,
			0.36, -- official: 0.75
			0.63, -- official: 0.7
		},
		impact = {
			1,
			0, -- official: 1
			1,
			1,
			1,
			0, -- official: 0.75
		},
	},
	cleave_distribution = {
		attack = 0.35,
		impact = 0.3,
	},
	shield_break = true,
	default_target = {
		attack_template = "shot_sniper",
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 1,
		headshot_boost_boss = 0.5,
		power_distribution_near = {
			attack = 1.1,
			impact = 0.5,
		},
		power_distribution_far = {
			attack = 0.9,
			impact = 0.5,
		},
	},
}

-- ======== staff_fireball_fireball_template_1 ========

--[[
	$BEGIN_TB
		## staff_fireball_fireball_template_1

		* action_one.default: Changed impact_data.damage_profile to staff_fireball_tourney (from staff_fireball)
		* action_one.default: Increased default_target.power_distribution_far.attack to 0.3 (from 0.15, +100%)
		* action_one.default: Increased default_target.power_distribution_near.attack to 0.44 (from 0.35, +26%)
		* action_one.default: Removed default_target.range_modifier_settings (was <table>)
		* action_one.shoot_charged: Added ignore_shield_hit: true
		* action_one.shoot_charged: Changed impact_data.aoe.explosion.effect_name to fx/wpnfx_drake_pistols_projectile_impact (from fx/wpnfx_fireball_charged_impact_remap)
		* action_one.shoot_charged: Changed impact_data.aoe.explosion.sound_event_name to drakepistol_hit (from fireball_big_hit)
		* action_one.shoot_charged: Increased armor_modifier.attack[5] to 1.3 (from 1, +30%)
		* action_one.shoot_charged: Increased cleave_distribution.attack to 1.2 (from 1, +20%)
		* action_one.shoot_charged: Increased cleave_distribution.impact to 1.2 (from 1, +20%)
		* action_one.shoot_charged: Increased default_target.power_distribution_far.attack to 0.375 (from 0.3, +25%)
		* action_one.shoot_charged: Increased default_target.power_distribution_near.attack to 0.375 (from 0.3, +25%)

		**Explosion fireball_charged**

		* Changed explosion.effect_name to fx/wpnfx_drake_pistols_projectile_impact (from fx/wpnfx_fireball_charged_impact_remap)
		* Changed explosion.sound_event_name to drakepistol_hit (from fireball_big_hit)

	$END_TB
]]

Weapons.staff_fireball_fireball_template_1.actions.action_one.default.impact_data.damage_profile = "staff_fireball_tourney" -- official: "staff_fireball"
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.ignore_shield_hit = true -- official: none
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.impact_data.aoe.explosion.effect_name = "fx/wpnfx_drake_pistols_projectile_impact" -- official: "fx/wpnfx_fireball_charged_impact_remap"
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.impact_data.aoe.explosion.sound_event_name = "drakepistol_hit" -- official: "fireball_big_hit"

-- staff_fireball_charged (official profile, changed in place)
DamageProfileTemplates.staff_fireball_charged.armor_modifier.attack[5] = 1.3 -- official: 1
DamageProfileTemplates.staff_fireball_charged.cleave_distribution.attack = 1.2 -- official: 1
DamageProfileTemplates.staff_fireball_charged.cleave_distribution.impact = 1.2 -- official: 1
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_far.attack = 0.375 -- official: 0.3
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_near.attack = 0.375 -- official: 0.3

-- staff_fireball_tourney: replaces the existing block
-- used by Weapons.staff_fireball_fireball_template_1.actions.action_one.default.impact_data.damage_profile
NewDamageProfileTemplates.staff_fireball_tourney = { -- official: staff_fireball
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
	charge_value = "projectile",
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
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	cleave_distribution = {
		attack = 0.1,
		impact = 0.1,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 0.75,
		power_distribution_near = {
			attack = 0.44, -- official: 0.35
			impact = 0.3,
		},
		power_distribution_far = {
			attack = 0.3, -- official: 0.15
			impact = 0.15,
		},
		-- removed: range_modifier_settings (official: <table>)
	},
}

-- ExplosionTemplates.fireball_charged
ExplosionTemplates.fireball_charged.explosion.effect_name = "fx/wpnfx_drake_pistols_projectile_impact" -- official: "fx/wpnfx_fireball_charged_impact_remap"
ExplosionTemplates.fireball_charged.explosion.sound_event_name = "drakepistol_hit" -- official: "fireball_big_hit"

-- ======== staff_fireball_fireball_template_1_vs ========

--[[
	$BEGIN_TB
		**Explosion fireball_charged**

		* Changed explosion.effect_name to fx/wpnfx_drake_pistols_projectile_impact (from fx/wpnfx_fireball_charged_impact_remap)
		* Changed explosion.sound_event_name to drakepistol_hit (from fireball_big_hit)

	$END_TB
]]

-- uses ExplosionTemplates.fireball_charged (exported under staff_fireball_fireball_template_1)

-- ======== staff_fireball_geiser_template_1 ========

--[[
	$BEGIN_TB
		## staff_fireball_geiser_template_1

		* action_one.default: Changed impact_data.damage_profile to staff_conflag_tourney (from staff_fireball)
		* action_one.default: Increased default_target.power_distribution_far.attack to 0.3 (from 0.15, +100%)
		* action_one.default: Increased default_target.power_distribution_near.attack to 0.44 (from 0.35, +26%)
		* action_one.default: Removed default_target.range_modifier_settings (was <table>)
		* action_one.geiser_launch: Increased targets[1].power_distribution.attack to 0.5 (from 0.3, +67%)

		**Explosion conflag**

		* Increased aoe.damage_interval to 2 (from 1, +100%)
		* Increased aoe.duration to 1e+01 (from 2, +400%)

	$END_TB
]]

Weapons.staff_fireball_geiser_template_1.actions.action_one.default.impact_data.damage_profile = "staff_conflag_tourney" -- official: "staff_fireball"

-- geiser (official profile, changed in place)
DamageProfileTemplates.geiser.targets[1].power_distribution.attack = 0.5 -- official: 0.3

-- staff_conflag_tourney: replaces the existing block
-- used by Weapons.staff_fireball_geiser_template_1.actions.action_one.default.impact_data.damage_profile
NewDamageProfileTemplates.staff_conflag_tourney = { -- official: staff_fireball
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
	charge_value = "projectile",
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
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	cleave_distribution = {
		attack = 0.1,
		impact = 0.1,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 1,
		boost_curve_coefficient = 0.75,
		power_distribution_near = {
			attack = 0.44, -- official: 0.35
			impact = 0.3,
		},
		power_distribution_far = {
			attack = 0.3, -- official: 0.15
			impact = 0.15,
		},
		-- removed: range_modifier_settings (official: <table>)
	},
}

-- ExplosionTemplates.conflag
ExplosionTemplates.conflag.aoe.damage_interval = 2 -- official: 1
ExplosionTemplates.conflag.aoe.duration = 1e+01 -- official: 2

-- ======== staff_flamethrower_template ========

--[[
	$BEGIN_TB
		## staff_flamethrower_template

		* action_one.shoot_charged: Increased damage_interval to 0.3 (from 0.25, +20%)

	$END_TB
]]

Weapons.staff_flamethrower_template.actions.action_one.shoot_charged.damage_interval = 0.3 -- official: 0.25

-- ======== staff_spark_spear_template_1 ========

--[[
	$BEGIN_TB
		## staff_spark_spear_template_1

		* action_one.shoot_charged: Increased timed_data.life_time to 3 (from 1.5, +100%)
		* action_one.shoot_charged_2: Increased timed_data.life_time to 3 (from 1.5, +100%)
		* action_one.shoot_charged_3: Increased armor_modifier_far.attack[1] to 1.01 (from 1, +1%)
		* action_one.shoot_charged_3: Increased armor_modifier_far.attack[2] to 0.8 (from 0.75, +7%)
		* action_one.shoot_charged_3: Increased armor_modifier_near.attack[1] to 1.01 (from 1, +1%)
		* action_one.shoot_charged_3: Increased armor_modifier_near.attack[2] to 0.8 (from 0.75, +7%)
		* action_one.shoot_charged_3: Increased timed_data.life_time to 3 (from 1.5, +100%)
		* action_two.default: Added buffed_zoom_thresholds: <table>
		* action_two.default: Added default_zoom: zoom_in_trueflight
		* action_two.default: Reduced aim_zoom_delay to 0.01 (from 1.25, -99%)

	$END_TB
]]

Weapons.staff_spark_spear_template_1.actions.action_one.shoot_charged.timed_data.life_time = 3 -- official: 1.5
Weapons.staff_spark_spear_template_1.actions.action_one.shoot_charged_2.timed_data.life_time = 3 -- official: 1.5
Weapons.staff_spark_spear_template_1.actions.action_one.shoot_charged_3.timed_data.life_time = 3 -- official: 1.5
Weapons.staff_spark_spear_template_1.actions.action_two.default.aim_zoom_delay = 0.01 -- official: 1.25
Weapons.staff_spark_spear_template_1.actions.action_two.default.buffed_zoom_thresholds = { -- official: none
	"zoom_in_trueflight",
	"zoom_in",
}
Weapons.staff_spark_spear_template_1.actions.action_two.default.default_zoom = "zoom_in_trueflight" -- official: none

-- fire_spear_3 (official profile, changed in place)
DamageProfileTemplates.fire_spear_3.armor_modifier_far.attack[1] = 1.01 -- official: 1
DamageProfileTemplates.fire_spear_3.armor_modifier_far.attack[2] = 0.8 -- official: 0.75
DamageProfileTemplates.fire_spear_3.armor_modifier_near.attack[1] = 1.01 -- official: 1
DamageProfileTemplates.fire_spear_3.armor_modifier_near.attack[2] = 0.8 -- official: 0.75

-- ======== staff_spark_spear_template_1_vs ========

--[[
	$BEGIN_TB
		## staff_spark_spear_template_1_vs

		* action_one.shoot_charged_3: Increased armor_modifier_far.attack[1] to 1.01 (from 1, +1%)
		* action_one.shoot_charged_3: Increased armor_modifier_far.attack[2] to 0.8 (from 0.75, +7%)
		* action_one.shoot_charged_3: Increased armor_modifier_near.attack[1] to 1.01 (from 1, +1%)
		* action_one.shoot_charged_3: Increased armor_modifier_near.attack[2] to 0.8 (from 0.75, +7%)

	$END_TB
]]

-- uses fire_spear_3 (exported under staff_spark_spear_template_1)

-- ======== victor_bountyhunter_career_skill_weapon ========

--[[
	$BEGIN_TB
		## victor_bountyhunter_career_skill_weapon

		* action_career_release.default: Increased armor_modifier_near.impact[3] to 2e+02 (from 1e+02, +100%)
		* action_career_release.default: Reduced armor_modifier_far.attack[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced armor_modifier_far.impact[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced armor_modifier_near.attack[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced armor_modifier_near.impact[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced critical_strike.attack_armor_power_modifer[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced critical_strike.impact_armor_power_modifer[4] to 0 (from 0.25, -100%)

	$END_TB
]]

-- shot_shotgun_ability (official profile, changed in place)
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.attack[4] = 0 -- official: 0.25
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.impact[4] = 0 -- official: 0.25
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.attack[4] = 0 -- official: 0.25
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.impact[3] = 2e+02 -- official: 1e+02
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.impact[4] = 0 -- official: 0.25
DamageProfileTemplates.shot_shotgun_ability.critical_strike.attack_armor_power_modifer[4] = 0 -- official: 0.25
DamageProfileTemplates.shot_shotgun_ability.critical_strike.impact_armor_power_modifer[4] = 0 -- official: 0.25

-- ======== victor_bountyhunter_career_skill_weapon_vs ========

--[[
	$BEGIN_TB
		## victor_bountyhunter_career_skill_weapon_vs

		* action_career_release.default: Increased armor_modifier_near.impact[3] to 2e+02 (from 1e+02, +100%)
		* action_career_release.default: Reduced armor_modifier_far.attack[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced armor_modifier_far.impact[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced armor_modifier_near.attack[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced armor_modifier_near.impact[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced critical_strike.attack_armor_power_modifer[4] to 0 (from 0.25, -100%)
		* action_career_release.default: Reduced critical_strike.impact_armor_power_modifer[4] to 0 (from 0.25, -100%)

	$END_TB
]]

-- uses shot_shotgun_ability (exported under victor_bountyhunter_career_skill_weapon)

-- ======== we_deus_01_template_1 ========

--[[
	$BEGIN_TB
		## we_deus_01_template_1

		* action_one.default: Reduced allowed_chain_actions[1].start_time to 0.4 (from 0.6, -33%)
		* action_one.default: Reduced total_time to 0.7 (from 0.83, -16%)
		* action_one.shoot_charged: Increased armor_modifier.attack[1] to 1.2 (from 0.6, +100%)
		* action_one.shoot_charged: Increased armor_modifier.attack[2] to 0.8 (from 0.4, +100%)
		* action_one.shoot_charged: Increased armor_modifier.attack[3] to 1.5 (from 0.75, +100%)
		* action_one.shoot_charged: Increased armor_modifier.attack[5] to 1.5 (from 0.75, +100%)
		* action_one.shoot_charged: Increased armor_modifier_far.attack[1] to 1.2 (from 0.6, +100%)
		* action_one.shoot_charged: Increased armor_modifier_far.attack[2] to 0.8 (from 0.4, +100%)
		* action_one.shoot_charged: Increased armor_modifier_far.attack[3] to 1.5 (from 0.75, +100%)
		* action_one.shoot_charged: Increased armor_modifier_far.attack[5] to 1.5 (from 0.75, +100%)
		* action_one.shoot_charged: Increased default_target.boost_curve_coefficient_headshot to 1.75 (from 1, +75%)
		* action_one.shoot_charged: Increased default_target.power_distribution_far.attack to 0.75 (from 0.3, +150%)
		* action_one.shoot_charged: Increased default_target.power_distribution_near.attack to 0.75 (from 0.41, +83%)
		* action_one.shoot_charged: Reduced allowed_chain_actions[1].start_time to 0.45 (from 0.5, -10%)
		* action_one.shoot_charged: Reduced total_time to 0.55 (from 0.6, -8%)
		* action_one.shoot_special_charged: Reduced allowed_chain_actions[1].start_time to 0.4 (from 0.5, -20%)
		* action_one.shoot_special_charged: Reduced total_time to 0.5 (from 0.6, -17%)

		**DoT we_deus_01_dot_charged**

		* Reduced buffs[1].ticks to 1 (from 6, -83%)

	$END_TB
]]

Weapons.we_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.4 -- official: 0.6
Weapons.we_deus_01_template_1.actions.action_one.default.total_time = 0.7 -- official: 0.83
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.allowed_chain_actions[1].start_time = 0.45 -- official: 0.5
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.total_time = 0.55 -- official: 0.6
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.allowed_chain_actions[1].start_time = 0.4 -- official: 0.5
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.total_time = 0.5 -- official: 0.6

-- we_deus_01_charged (official profile, changed in place)
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[1] = 1.2 -- official: 0.6
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[2] = 0.8 -- official: 0.4
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[3] = 1.5 -- official: 0.75
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[5] = 1.5 -- official: 0.75
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[1] = 1.2 -- official: 0.6
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[2] = 0.8 -- official: 0.4
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[3] = 1.5 -- official: 0.75
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[5] = 1.5 -- official: 0.75
DamageProfileTemplates.we_deus_01_charged.default_target.boost_curve_coefficient_headshot = 1.75 -- official: 1
DamageProfileTemplates.we_deus_01_charged.default_target.power_distribution_far.attack = 0.75 -- official: 0.3
DamageProfileTemplates.we_deus_01_charged.default_target.power_distribution_near.attack = 0.75 -- official: 0.41

-- BuffTemplates.we_deus_01_dot_charged
BuffTemplates.we_deus_01_dot_charged.buffs[1].ticks = 1 -- official: 6

-- ======== wh_deus_01_template_1 ========

--[[
	$BEGIN_TB
		## wh_deus_01_template_1

		* Added max_fatigue_points: 6
		* action_one.default: Increased barrels[1].yaw to -1 (from -8, +88%)
		* action_one.default: Increased barrels[2].yaw to -0.5 (from -4, +88%)
		* action_one.default: Reduced barrels[1].shot_count to 2 (from 3, -33%)
		* action_one.default: Reduced barrels[2].shot_count to 2 (from 3, -33%)
		* action_one.default: Reduced barrels[3].shot_count to 4 (from 6, -33%)
		* action_one.default: Reduced barrels[4].shot_count to 2 (from 3, -33%)
		* action_one.default: Reduced barrels[4].yaw to 0.5 (from 4, -88%)
		* action_one.default: Reduced barrels[5].shot_count to 2 (from 3, -33%)
		* action_one.default: Reduced barrels[5].yaw to 1 (from 8, -88%)
		* action_one.default: Reduced cleave_distribution.attack to 0.05 (from 0.1, -50%)
		* action_one.default: Reduced cleave_distribution.impact to 0.05 (from 0.1, -50%)
		* action_two.default: Added add_fatigue_on_hit: true

	$END_TB
]]

Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[1].shot_count = 2 -- official: 3
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[1].yaw = -1 -- official: -8
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[2].shot_count = 2 -- official: 3
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[2].yaw = -0.5 -- official: -4
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[3].shot_count = 4 -- official: 6
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[4].shot_count = 2 -- official: 3
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[4].yaw = 0.5 -- official: 4
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[5].shot_count = 2 -- official: 3
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels[5].yaw = 1 -- official: 8
Weapons.wh_deus_01_template_1.actions.action_two.default.add_fatigue_on_hit = true -- official: none
Weapons.wh_deus_01_template_1.max_fatigue_points = 6 -- official: none

-- shot_duckfoot (official profile, changed in place)
DamageProfileTemplates.shot_duckfoot.cleave_distribution.attack = 0.05 -- official: 0.1
DamageProfileTemplates.shot_duckfoot.cleave_distribution.impact = 0.05 -- official: 0.1

-- ################ other ################

-- ======== bardin_survival_ale ========

--[[
	$BEGIN_TB
		## bardin_survival_ale

		* action_one.default: Reduced total_time to 0.8 (from 1.9, -58%)

	$END_TB
]]

Weapons.bardin_survival_ale.actions.action_one.default.total_time = 0.8 -- official: 1.9

-- ======== deus_relic ========

--[[
	$BEGIN_TB
		## deus_relic

		* action_one.light_attack_bopp: Increased cleave_distribution.impact to 0.5 (from 0.25, +100%)

	$END_TB
]]

-- uses light_blunt_tank_spiked (exported under one_handed_flail_shield_template)

-- ======== fire_grenade_t1 ========

--[[
	$BEGIN_TB
		**Damage profile burning_dot_firegrenade**

		* Reduced default_target.armor_modifier.attack[6] to 0.25 (from 0.5, -50%)

		**DoT burning_dot_fire_grenade**

		* Reduced buffs[1].update_start_delay to 0.75 (from 1, -25%)

	$END_TB
]]

-- burning_dot_firegrenade (official profile, changed in place)
DamageProfileTemplates.burning_dot_firegrenade.default_target.armor_modifier.attack[6] = 0.25 -- official: 0.5

-- BuffTemplates.burning_dot_fire_grenade
BuffTemplates.burning_dot_fire_grenade.buffs[1].update_start_delay = 0.75 -- official: 1

-- ======== fire_grenade_t2 ========

--[[
	$BEGIN_TB
		**Damage profile burning_dot_firegrenade**

		* Reduced default_target.armor_modifier.attack[6] to 0.25 (from 0.5, -50%)

		**DoT burning_dot_fire_grenade**

		* Reduced buffs[1].update_start_delay to 0.75 (from 1, -25%)

	$END_TB
]]

-- uses burning_dot_firegrenade (exported under fire_grenade_t1)

-- uses BuffTemplates.burning_dot_fire_grenade (exported under fire_grenade_t1)