local mod = get_mod("TourneyBalance")

--[[
    Bounty Shotgun ability FF reduction
]]
DamageProfileTemplates.shot_shotgun_ability.critical_strike.attack_armor_power_modifer = { 1, 0.1, 0.2, 0, 1, 0.025 }
DamageProfileTemplates.shot_shotgun_ability.critical_strike.impact_armor_power_modifer = { 1, 0.5, 200, 0, 1, 0.05 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.attack = { 1, 0.1, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.impact = { 1, 0.5, 200, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.attack = { 1, 0, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.impact = { 1, 0.5, 200, 0, 1, 0 }

--[[
    Indiscriminate Blast pellets: massive (explosion) stagger on every pellet
]]
NewDamageProfileTemplates.tb_shot_shotgun_ability_blast = table.clone(DamageProfileTemplates.shot_shotgun_ability)

local blast_pellets = NewDamageProfileTemplates.tb_shot_shotgun_ability_blast

blast_pellets.critical_strike.impact_armor_power_modifer = { 100, 100, 200, 0, 100, 100 } -- { 1, 0.5, 200, 0, 1, 0.05 }
blast_pellets.armor_modifier_near.impact = { 100, 100, 200, 0, 100, 100 } -- { 1, 0.5, 200, 0, 1, 0 }
blast_pellets.armor_modifier_far.impact = { 100, 100, 200, 0, 100, 100 } -- { 1, 0.5, 200, 0, 1, 0 }
blast_pellets.default_target.power_distribution_near.impact = 100 -- 0.5
blast_pellets.default_target.power_distribution_far.impact = 100 -- 0.25
-- Infinite cleave: pellets pass through every enemy in line (armored and shield-blocked hits still stop them)
blast_pellets.cleave_distribution = { attack = 200, impact = 200 } -- { attack = 0.3, impact = 0.3 }

