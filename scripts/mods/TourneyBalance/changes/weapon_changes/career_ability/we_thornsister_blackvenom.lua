local mod = get_mod("TourneyBalance")

--[[
    Blackvenom Thicket
]]
-- formerly Bloodrazor Thicket
DamageProfileTemplates.thorn_wall_explosion_improved_damage.armor_modifier.attack = {
	0.5,
	0.1,
	2,
	0.75,
	0.3,
	0.25
}
BuffTemplates.thorn_sister_wall_bleed.buffs[1].duration = 3