local mod = get_mod("TourneyBalance")

--[[
	Flaming Flail
]]
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_left.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
--Weapons.one_handed_flails_flaming_template.actions.action_one.heavy_attack.anim_time_scale = 1
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.impact = 0.375
--DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.attack = 0.06
DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.impact = 0.25
--DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.attack = 0.25

