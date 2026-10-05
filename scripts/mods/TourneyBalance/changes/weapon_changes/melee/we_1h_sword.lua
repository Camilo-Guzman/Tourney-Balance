local mod = get_mod("TourneyBalance")

--[[
	Elf 1h Sword
]]
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.damage_profile = "light_slashing_smiter_finesse"
Weapons.we_one_hand_sword_template_1.dodge_count = 4
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.range_mod = 1.3
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.range_mod = 1.4
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.anim_time_scale = 0.81
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[1].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].start_time = 0.5

