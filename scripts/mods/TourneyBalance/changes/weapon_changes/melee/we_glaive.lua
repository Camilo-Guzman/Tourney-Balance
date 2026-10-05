local mod = get_mod("TourneyBalance")

--[[
	Glaive
]]	
-- Buffs to push attack chain attack speed and linesman on bopp, removes linesman from heavy attack, makes both heavy attacks have the Heavy 2 profile--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.hit_mass_count = LINESMAN_HIT_MASS_COUNT	--no modifier on live--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_left_upward.anim_time_scale = 0.95*1.15		-- 1.0--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_left.anim_time_scale = 0.95*1.4			-- 1.25--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.anim_time_scale = 0.95*1.2			-- 1.15--
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.damage_profile = "heavy_slashing_smiter_glaive"
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.hit_mass_count = NONE

--buffs cleave and stagger cleave from 8.21 and 7.46 respectively to 10.74 each --
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.36
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.impact = 0.36

