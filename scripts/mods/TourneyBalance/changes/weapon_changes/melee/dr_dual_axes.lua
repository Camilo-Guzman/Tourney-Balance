local mod = get_mod("TourneyBalance")

--[[
	Dual Axes
]]
--Heavies
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack.anim_time_scale = 0.925  --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_2.anim_time_scale = 1.1 --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_3.additional_critical_strike_chance = 0.2 --0
--push
Weapons.dual_wield_axes_template_1.actions.action_one.push.damage_profile_inner = "light_push"
Weapons.dual_wield_axes_template_1.actions.action_one.push.fatigue_cost = "action_stun_push"


-- Warpick
-- Animation Time for Lights reduced by 20%
-- Damage for lights reduced by approx 10%
-- Stagger Cleave set to same as damage cleave
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.anim_time_scale = 0.9 * 1.25
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.anim_time_scale = 0.9 * 1.25
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.damage_profile = "tb_warpick_lights"
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.damage_profile = "tb_warpick_lights"
Weapons.two_handed_picks_template_1.dodge_count = 3

--Heavies
--DamageProfileTemplates.heavy_blunt_smiter_charged.armor_modifier.attack[3] = 2.25
PowerLevelTemplates.armor_modifier_smiter_pick_H_charged.attack[3] = 2.25
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left.damage_profile 						= "pickaxe_uncharged_heavies"
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left_charged.damage_profile 				= "pickaxe_charged_heavies"
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right.damage_profile 						= "pickaxe_uncharged_heavies"
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right_charged.damage_profile 				= "pickaxe_charged_heavies"

--Lights
NewDamageProfileTemplates.tb_warpick_lights = {
	armor_modifier = "armor_modifier_axe_linesman_M",
	critical_strike = "critical_strike_axe_linesman_M",
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.4
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.225,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1.25,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.21,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.14,
				impact = 0.1
			}
		}
	}
}

NewDamageProfileTemplates.pickaxe_uncharged_heavies = {
	armor_modifier = "pickaxe_heavy_smiter_vertical_armor_modifier",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.9, -- 0.5
			1.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = "pickaxe_heavy_smiter_vertical_cleave_distribution",
	default_target = "pickaxe_heavy_smiter_vertical_default_target",
	targets = "pickaxe_heavy_smiter_vertical_targets",
	shield_break = true
}

NewDamageProfileTemplates.pickaxe_charged_heavies = {
	armor_modifier = "pickaxe_heavy_smiter_vertical_charged_armor_modifier",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.785, -- 0.5
			1.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = "pickaxe_heavy_smiter_vertical_charged_cleave_distribution",
	default_target = "pickaxe_heavy_smiter_vertical_charged_default_target",
	targets = "pickaxe_heavy_smiter_vertical_charged_targets_smiter",
	shield_break = true
}