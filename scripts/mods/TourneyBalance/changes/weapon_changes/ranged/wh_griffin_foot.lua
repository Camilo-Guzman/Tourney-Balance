local mod = get_mod("TourneyBalance")

--[[
    Duck foot
]]
local balanced_barrels =  { {	yaw = -1, pitch = 0, shot_count = 2 }, { yaw = -0.5, pitch = 0, shot_count = 2 },	{ yaw = 0, pitch = 0, shot_count = 4 }, { yaw = 0.5,  pitch = 0, shot_count = 2 }, { yaw = 1, pitch = 0, shot_count = 2 } }
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels = balanced_barrels
DamageProfileTemplates.shot_duckfoot.cleave_distribution.attack = 0.05
DamageProfileTemplates.shot_duckfoot.cleave_distribution.impact = 0.05


