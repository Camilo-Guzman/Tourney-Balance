local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Outcast Engineer
		### Career Skill
		**Crank Gun**
		- The Crank Gun now always starts at full rotation speed. Previously this required Linked Compression Chamber.
		- Dodge count increased to 3 (from 1).

		### Talents
		**Linked Compression Chamber**
		- Full starting fire rate is now baseline (see above).
		- Still increases the Crank Gun's maximum fire rate by 30%.
		- Reduces the Crank Gun's spin-up time before firing to 0.2s (from 0.5s).
	$END_TB
]]

--[[

	Ultimate

]]
-- Linked Compression Chamber's instant windup is baseline for every crank gun variant.
-- Mirrors the talent branch in ActionCareerDREngineerSpin / ActionCareerDREngineer; the talent's
-- 30% max_rps boost is applied before this runs, so talented players keep their higher cap.
local function starting_windup()
	if Managers.mechanism:current_mechanism_name() == "versus" then
		return CareerConstants.dr_engineer.talent_6_2_starting_rps_vs
	end

	return CareerConstants.dr_engineer.talent_6_2_starting_rps
end

mod:hook_safe(ActionCareerDREngineerSpin, "client_owner_start_action", function (self, new_action, t)
	self._current_windup = starting_windup()
end)

mod:hook_safe(ActionCareerDREngineer, "client_owner_start_action", function (self, new_action, t)
	self._current_rps = math.max(self._current_rps, self._max_rps * starting_windup())
end)

Weapons.bardin_engineer_career_skill_weapon.dodge_count = 3 -- 1
Weapons.bardin_engineer_career_skill_weapon_special.dodge_count = 3 -- 1

--[[

	Talents

]]
--[[
	Linked Compression Chamber
]]
-- Reduce the 0.5s spin-up to 0.1s, so the spin action chains into fire sooner.
local TB_LINKED_COMPRESSION_SPIN_UP = 0.2 -- 0.5
local reduced_spin_up_chain_actions = setmetatable({}, { __mode = "k" })

mod:hook(WeaponUnitExtension, "is_chain_action_available", function (func, self, next_chain_action, t, time_offset)
	local current_action_settings = self.current_action_settings

	if current_action_settings and current_action_settings.kind == "career_dr_four_spin" and next_chain_action.sub_action == "fire" then
		local lookup_data = current_action_settings.lookup_data
		local talent_extension = self._talent_extension

		if lookup_data and lookup_data.sub_action_name == "spin" and talent_extension and talent_extension:has_talent("bardin_engineer_reduced_ability_fire_slowdown") then
			local reduced_chain_action = reduced_spin_up_chain_actions[next_chain_action]

			if not reduced_chain_action then
				reduced_chain_action = table.shallow_copy(next_chain_action)
				reduced_chain_action.start_time = math.min(next_chain_action.start_time or TB_LINKED_COMPRESSION_SPIN_UP, TB_LINKED_COMPRESSION_SPIN_UP)
				reduced_spin_up_chain_actions[next_chain_action] = reduced_chain_action
			end

			next_chain_action = reduced_chain_action
		end
	end

	return func(self, next_chain_action, t, time_offset)
end)

mod_api.insert_text("bardin_engineer_reduced_ability_fire_slowdown_desc_2", "Increases the Crank Gun's maximum fire rate by 30%% and reduces its spin-up time before firing to 0.2 seconds.")


--[[

	NOT REFACTORED

]]
--[[ Removed due to new Balance Patch of the official Game (6.0.0)
mod_api.insert_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_count", {
	buff_to_add = "bardin_engineer_ranged_crit_counter_buff",
	max_stacks = 1,
	stat_buff = "critical_strike_chance_ranged",
	buff_func = "add_buff_on_first_target_hit",
	event = "on_hit",
	client_side = true,
	valid_attack_types = {
		instant_projectile = true,
		heavy_instant_projectile = true,
		projectile = true
	}
})
mod_api.insert_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_counter_buff", {
	reset_on_max_stacks = true,
	on_max_stacks_func = "add_remove_buffs",
    max_stacks = 4,     -- 5
	is_cooldown = true,
	icon = "bardin_engineer_ranged_crit_count",
	max_stack_data = {
		buffs_to_add = {
			"bardin_engineer_ranged_crit_count_buff"
		}
	}
})
mod_api.insert_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_count_buff", {
    event = "on_critical_shot",
    max_stacks = 1,
    stat_buff = "critical_strike_chance_ranged",
    buff_func = "dummy_function",
    remove_on_proc = true,
    icon = "bardin_engineer_ranged_crit_count",
    priority_buff = true,
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_count_buff", {
    bonus = 1
})
mod_api.update_talent("dr_engineer", 2,1, {
	icon = "bardin_engineer_ranged_crit_count",
	buffs = {
		"bardin_engineer_ranged_crit_count"
	}
})

mod_api.insert_text("bardin_engineer_improved_explosives_desc", "Every 4th Ranged Attack is a guaranteed Critical Hit.")
mod_api.insert_text("bardin_engineer_melee_power_ranged_power_desc", "Melee Power is increased by 10%%. Every 5 Melee Strikes makes Bardin's next Ranged Attack grant 15%% Ranged Power for 10 seconds.")
]]

