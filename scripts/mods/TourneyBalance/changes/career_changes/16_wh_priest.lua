local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Warrior Priest
		### Career Ability
		- Reworded tooltip.
		- Shield explosion burn now lasts 1s (from 5s), dealing 1 tick of damage instead of 7.

		### Talents
		**Prayer of Flight**
		- Grants the party 10% increased movement speed (instead of 25% stagger power).

		**Unyielding Blessing**
		- Duration reduced to 7s (from 10s).

		**United in Prayer**
		- Duration reduced to 3s (from 5s).
	$END_TB
]]

--[[

	Ultimate

]]
-- Reworded - base game's own wording here was hard to parse
mod_api.insert_text("career_active_desc_wh_priest", "Saltzpyre imbues himself or an ally with a shield, rendering them immune to damage for 5 seconds. Upon expiring, the shield explodes, inflicting damage on nearby enemies. Hold to target allies.")

-- Shield explosion burn cut to a single tick (from 7).
local nuke_dot = BuffTemplates.victor_priest_nuke_dot.buffs[1]
nuke_dot.duration = 10 -- 5, how long the enemy counts as burning
nuke_dot.time_between_dot_damages = 10 -- 0.7, second tick lands after the burn ends
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

--[[
	Unyielding Blessing
	United In Prayer
]]

local spell_params = {}
local spell_params_improved = {
	external_optional_duration = 7, -- 10
}
local spell_params_self_cast = {
	external_optional_duration = 3, -- 5
}
local spell_buffs = {
	"victor_priest_activated_ability_invincibility",
	"victor_priest_activated_ability_nuke",
}
mod:hook_origin(ActionCareerWHPriestUtility, "_add_buffs_to_target", function (target_unit, warrior_priest_unit)
	local spell_buffs = spell_buffs
	local params = spell_params
	local talent_extension = ScriptUnit.extension(warrior_priest_unit, "talent_system")

	if talent_extension:has_talent("victor_priest_6_1") then
		params = spell_params_improved
	elseif talent_extension:has_talent("victor_priest_6_2") then
		params = spell_params_self_cast
	end

	params.attacker_unit = warrior_priest_unit

	if ALIVE[target_unit] then
		local buff_system = Managers.state.entity:system("buff_system")

		for i = 1, #spell_buffs do
			local buff_name = spell_buffs[i]

			buff_system:add_buff_synced(target_unit, buff_name, BuffSyncType.All, params)
		end
	end
end)
mod_api.insert_text("victor_priest_6_1_desc_new", "Shield of Faith now lasts 7 seconds. The shielded hero's attacks cause the shield to pulse, staggering nearby enemies.")
mod_api.insert_text("victor_priest_6_2_desc", "Shield of Faith always affects Victor as well. Shield of Faith now lasts 3 seconds.")


