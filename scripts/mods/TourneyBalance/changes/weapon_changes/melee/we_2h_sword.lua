local mod = get_mod("TourneyBalance")

--[[
	2h sword elf
]]
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_bopp.anim_time_scale = 0.95
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_right_upward.anim_time_scale = 1.25
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_left_upward.anim_time_scale = 1.25
-- Heavy attack speed reverted to vanilla
--Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.anim_time_scale = 1.6 --1.35
--Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_second.anim_time_scale = 1.6 --1.08
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[1].external_multiplier = 1.5
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[2].external_multiplier = 0.5
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].armor_modifier.attack = { 1, 0.9, 2.5, 1, 0.75 }
DamageProfileTemplates.heavy_slashing_smiter_stab.critical_strike.attack_armor_power_modifer = { 1, 0.9, 3, 1, 1 }
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[1].power_distribution.attack = 0.325
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[2].power_distribution.attack = 0.25
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[3].power_distribution.attack = 0.15


