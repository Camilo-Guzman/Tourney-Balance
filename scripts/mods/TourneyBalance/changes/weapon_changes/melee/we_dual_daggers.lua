local mod = get_mod("TourneyBalance")

--[[
	Dual Daggers
]]
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_left.additional_critical_strike_chance = 0.1
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_right.additional_critical_strike_chance = 0.1
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.allowed_chain_actions[5].start_time = 0.35
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.allowed_chain_actions[5].start_time = 0.35
Weapons.dual_wield_daggers_template_1.max_fatigue_points = 6

