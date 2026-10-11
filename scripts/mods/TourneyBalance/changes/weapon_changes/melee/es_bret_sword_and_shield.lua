local mod = get_mod("TourneyBalance")

--Bretonnian Longsword and Shield
local action_one = Weapons.one_handed_sword_shield_template_2.actions.action_one

-- Heavy Overhead (default) and Heavy Poke (default_stab_heavy) can be held indefinitely
for _, sub_action_name in ipairs({ "default", "default_left", "default_left_heavy","default_stab_heavy" }) do
	local chain_actions = action_one[sub_action_name].allowed_chain_actions

	for i = #chain_actions, 1, -1 do
		if chain_actions[i].auto_chain then
			table.remove(chain_actions, i)
		end
	end
end

-- Charging the Heavy Overhead and Heavy Poke puts up the guard (Heavy Shield Bash excluded)
for _, sub_action_name in ipairs({ "default", "default_stab_heavy" }) do
	action_one[sub_action_name].blocking_charge = true
	action_one[sub_action_name].blocking_charge_start_time = 0.3
end

Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_left.damage_profile = "tb_bretsword_shield_light_1" -- vanilla: "light_slashing_linesman"
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_right.damage_profile = "tb_bretsword_shield_light_2" -- vanilla: "light_slashing_smiter"
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_shield.damage_profile_aoe = "tb_bretsword_shield_light_shield_bash" -- vanilla: "shield_slam_shotgun_aoe"

Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_right.allowed_chain_actions[1].start_time = 0.6 -- vanilla: 0.75
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_shield.allowed_chain_actions[1].start_time = 0.32 -- vanilla: 0.65

NewDamageProfileTemplates.tb_bretsword_shield_light_1 = { -- vanilla: light_slashing_linesman
	armor_modifier = {
		attack = {
			2, -- vanilla: 1
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
	name = "light_slashing_linesman",
	default_target = "default_target_linesman_L",
	targets = "targets_linesman_L",
}

NewDamageProfileTemplates.tb_bretsword_shield_light_2 = { -- vanilla: light_slashing_smiter
	armor_modifier = "armor_modifier_smiter_L",
	charge_value = "light_attack",
	critical_strike = "critical_strike_smiter_L",
	cleave_distribution = "cleave_distribution_smiter_default",
	ignore_stagger_reduction = true,
	shield_break = true, -- vanilla: none
	name = "light_slashing_smiter",
	default_target = "default_target_smiter_L",
	targets = "targets_smiter_L",
}

NewDamageProfileTemplates.tb_bretsword_shield_light_shield_bash = { -- vanilla: shield_slam_shotgun_aoe
	armor_modifier = "armor_modifier_slam_tank_L",
	charge_value = "heavy_attack",
	critical_strike = "critical_strike_slam_tank_L",
	shield_break = true, -- vanilla: none
	name = "shield_slam_shotgun_aoe",
	no_damage = true,
	default_target = "aoe_target_settings_slam_tank_L",
	targets = {
	},
}