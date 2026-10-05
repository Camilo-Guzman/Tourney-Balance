local mod = get_mod("TourneyBalance")

--[[
	Axe and Falchion
]]
-- Buff to Super Armor
DamageProfileTemplates.light_slashing_smiter_dual.armor_modifier.attack[6] = 0.82
-- buff to Armor to give 2SHS w/ 50% hs rate, assassin and 10% on charm
DamageProfileTemplates.light_slashing_smiter_dual.armor_modifier.attack[2] = 0.82
-- Linesman added to falchion lights (not PA).
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_right_diagonal.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = LINESMAN_HIT_MASS_COUNT
-- Linesman removed from push attack
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_bopp.hit_mass_count = NONE

