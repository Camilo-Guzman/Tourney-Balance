local mod = get_mod("TourneyBalance")

--[[
    Bardin/Saltzpyre Crossbows
]]
-- Remove active reload
Weapons.crossbow_template_1.actions.action_one.default.total_time = 0 -- 0.42
Weapons.crossbow_template_1.actions.action_one.zoomed_shot.total_time = 0.37 -- 0.8