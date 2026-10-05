local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Pyromancer
		### Talents
		**Martial Study**
		- Increased attack speed to 10% (from 5%).

		**Spirit Casting**
		- Additionally gives 5% crit, while above 65% health.

		**Blaze Away**
		- Fixed no refund on crit when the fireball first hits a teammate.
	$END_TB
]]

--[[

	Talents

]]
--[[
	Martial Study
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_scholar_increased_attack_speed", {
	multiplier = 0.1 -- 0.05
})
mod_api.update_talent("bw_scholar", 2, 2, {
	description_values = {
		{
			value_type = "percent",
			value = 0.1, --buff_tweak_data.sienna_scholar_increased_attack_speed.multiplier,
		},
	},
})

--[[
	Spirit Casting
]]
-- Update crit stack based on hp thresh
mod_api.insert_buff_function("tb_activate_buff_stacks_on_health_threshold", function (unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local health_percentage = health_extension:current_health() / health_extension:get_max_health()
	local stacks_to_add = 0

	if health_percentage >= 0.8 then
		stacks_to_add = 2
	elseif health_percentage >= 0.65 then
		stacks_to_add = 1
	end

	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_to_add = buff.template.buff_to_add
	local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)
	local stack_ids = buff.stack_ids

	if not stack_ids then
		stack_ids = {}
		buff.stack_ids = stack_ids
	end

	if num_buff_stacks < stacks_to_add then
		for _ = 1, stacks_to_add - num_buff_stacks do
			stack_ids[#stack_ids + 1] = buff_system:add_buff(unit, buff_to_add, unit, true)
		end
	elseif stacks_to_add < num_buff_stacks then
		for _ = 1, num_buff_stacks - stacks_to_add do
			buff_system:remove_server_controlled_buff(unit, table.remove(stack_ids, 1))
		end
	end
end)
-- Buff that updates how many stacks of crit
mod_api.update_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold", {
	buff_to_add = "sienna_scholar_crit_chance_above_health_threshold_buff", -- copied for clarity
	update_func = "tb_activate_buff_stacks_on_health_threshold", -- "activate_buff_on_health_percent"
	update_frequency = 0.5,
})
-- Buff that gives crit
mod_api.update_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_buff", {
	max_stacks = 2, -- 1
	bonus = 0.05, -- 0.1
})
mod_api.update_talent("bw_scholar", 2, 3, {
    description = "sienna_scholar_crit_chance_above_health_threshold_desc",
    description_values = {},
})
mod_api.insert_text("sienna_scholar_crit_chance_above_health_threshold_desc", "Critical strike chance is increased by 5.0% while above 65.0% health and increased by 10.0% while above 80.0% health.")

--[[
	Blaze Away
]]
-- Fix no refund on crit when the fireball cleaves through a teammate first (target_number > 1)
mod_api.insert_proc_function("sienna_scholar_refund_activated_ability_cooldown", function (owner_unit, buff, params)
	if ALIVE[owner_unit] then
		local buff_type = params[5]
		local is_critical = params[6]

		if buff_type == "RANGED_ABILITY" and is_critical then
			local career_extension = ScriptUnit.extension(owner_unit, "career_system")

			career_extension:reduce_activated_ability_cooldown_percent(1)
		end
	end
end)



