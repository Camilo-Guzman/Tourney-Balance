local mod = get_mod("TourneyBalance")

--[[
    Trollhammer
]]
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack = {
	1,
	0.5,
	3,
	1,
	0.25
}
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[1] = 0.6
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[2] = 0.6
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[6] = 0.6
Weapons.dr_deus_01_template_1.ammo_data.reload_time = 4

--Strength boost reduction
DamageProfileTemplates.dr_deus_01_explosion.default_target.boost_curve_coefficient = 0.5
DamageProfileTemplates.dr_deus_01_glance.default_target.boost_curve_coefficient = 0.5
DamageProfileTemplates.dr_deus_01_explosion.default_target.boost_curve_type = "tank_curve"
DamageProfileTemplates.dr_deus_01_glance.default_target.boost_curve_type = "tank_curve"
DamageProfileTemplates.dr_deus_01.default_target.boost_curve_coefficient = 0.5