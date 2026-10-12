local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Warrior Priest
		### Career Ability
		- Reworded tooltip.
		- Shield explosion damage reduced to 0.1 (from 0.25). Burn now deals 1 tick of damage instead of 7.

		### Talents
		**Prayer of Flight**
		- Grants the party 10% increased movement speed (instead of 25% stagger power).

		**Unyielding Blessing**
		- Duration reduced to 7s (from 10s).
	$END_TB
]]

--[[

	Ultimate

]]
-- Reworded - base game's own wording here was hard to parse
mod_api.insert_text("career_active_desc_wh_priest", "Saltzpyre imbues himself or an ally with a shield, rendering them immune to damage for 5 seconds. Upon expiring, the shield explodes, inflicting damage on nearby enemies. Hold to target allies.")

-- Shield explosion burn cut to a single tick (from 7).
local nuke_dot = BuffTemplates.victor_priest_nuke_dot.buffs[1]
nuke_dot.duration = 5 -- 5, how long the enemy counts as burning
nuke_dot.time_between_dot_damages = 5 -- 0.7, second tick lands after the burn ends
-- Initial explosion damage
DamageProfileTemplates.victor_priest_activated_ability_nuke_explosion.default_target.power_distribution.attack = 0.1 -- 0.25

--[[

	Talents

]]
--[[
	Prayer of Flight
]]
-- Swaps buff out with movement speed
mod_api.update_talent_buff_template("witch_hunter", "victor_priest_5_2", {
	buff_to_add = "tb_victor_priest_5_2_speed_buff",
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_priest_5_2_speed_buff", {
	multiplier = 1.1,
	apply_buff_func = "apply_movement_buff",
	max_stacks = 1,
	remove_buff_func = "remove_movement_buff",
	path_to_movement_setting_to_modify = {
		"move_speed",
	},
})
mod_api.insert_talent_text("victor_priest_5_2", "Prayer of Flight", "Bless the party with 10%% increased movement speed. Fly you fools.")


