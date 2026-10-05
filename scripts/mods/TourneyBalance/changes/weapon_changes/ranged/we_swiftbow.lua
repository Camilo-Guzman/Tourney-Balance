local mod = get_mod("TourneyBalance")

--[[
    Swiftbow
]]
DamageProfileTemplates.arrow_machinegun.cleave_distribution.attack = 0.25
DamageProfileTemplates.arrow_machinegun.cleave_distribution.impact = 0.25
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.attack = 0.25
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.impact = 0.25
DamageProfileTemplates.arrow_machinegun.critical_strike.attack_armor_power_modifer = {
								1,
								0.25,
								1,
								1,
								1,
								0.25,
							}
DamageProfileTemplates.arrow_machinegun.armor_modifier_near.attack = {
								1,
								0.1,
								1,
								1,
								0.5,
								0,
							}
DamageProfileTemplates.arrow_machinegun.armor_modifier_far.attack = {
								1,
								0.1,
								1,
								1,
								0.5,
								0,
							}
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_coefficient = 0.6
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_coefficient_headshot = 1
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_type = "linesman_curve"
DamageProfileTemplates.arrow_machinegun.default_target.power_distribution_near.attack = 0.3 	
DamageProfileTemplates.arrow_machinegun.default_target.power_distribution_far.attack = 0.25	
DamageProfileTemplates.arrow_machinegun.friendly_fire_multiplier = 0.15
DamageProfileTemplates.arrow_machinegun.shield_break = false

--Charged Shots
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.attack = 0.44 -- 0.5
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.far = 0.35	--0.4

