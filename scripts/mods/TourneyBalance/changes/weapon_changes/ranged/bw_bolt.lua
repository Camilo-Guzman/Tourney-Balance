local mod = get_mod("TourneyBalance")

--[[
	Bolt
]]
DamageProfileTemplates.fire_spear_3.armor_modifier_near.attack = { 1.01, 0.8, 1.5, 1, 1, 0.4 }
DamageProfileTemplates.fire_spear_3.armor_modifier_far.attack = { 1.01, 0.8, 1.5, 1, 1, 0.4 }
-- Weapon Zoom Bolt
table.insert(PassiveAbilitySettings.bw_1.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.bw_2.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.bw_3.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.bw_necromancer.buffs, "kerillian_waywatcher_passive_increased_zoom")

Weapons.staff_spark_spear_template_1.actions.action_two.default.aim_zoom_delay = 0.01
Weapons.staff_spark_spear_template_1.actions.action_two.default.default_zoom = "zoom_in_trueflight"
Weapons.staff_spark_spear_template_1.actions.action_two.default.buffed_zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }

Weapons.staff_spark_spear_template_1.actions.action_two.default.zoom_condition_function = function ()
    return true
end

-- Increased Right-click projectile life time from 1.5 seconds to 3 seconds for all three charge stages.
Weapons.staff_spark_spear_template_1.actions.action_one.shoot_charged.timed_data.life_time = 3 -- 1.5
Weapons.staff_spark_spear_template_1.actions.action_one.shoot_charged_2.timed_data.life_time = 3 -- 1.5
Weapons.staff_spark_spear_template_1.actions.action_one.shoot_charged_3.timed_data.life_time = 3 -- 1.5

