local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Necromancer
		### Career Ability
		- Reduced stagger from regular ult to 0 (from 1). Excludes Barrow Blades ult, which has improved stagger.

		### Talents
		**Death Ascendant**
		- Changed buff to ranged weapon damage (from ranged power).

		**Reaping**
		- Removed power bonus (from 25%).

		**Cursed Blood**
		- Reduced explosion damage to 10% (from 25%) of the crit attack triggering the explosion.
		- Added internal cooldown of 0.3s.
		- Removed stagger from the blood explosion (from 0.08) and crit burst from (0.7).

		**Lost Souls**
		- Removed stagger from unleashed souls (from 0.25).
	$END_TB
]]
--[[
	Ultimate
]]
-- Remove stagger from ult
DamageProfileTemplates.sienna_necromancer_ability_stagger.default_target.power_distribution.impact = 0 -- 1

--[[

	Talents

]]
--[[
	Death Ascendant
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_necromancer_2_2_buff", {
    stat_buff = "increased_weapon_damage_ranged" -- "power_level_ranged"
})
mod_api.update_talent("bw_necromancer", 2, 2, {
    description = "sienna_necromancer_2_2_desc",
    description_values = {},
})
mod_api.insert_text("sienna_necromancer_2_2_desc", "Casting spells grants 5% ranged damage for 6 seconds. Max stacks 5.")

--[[
	Reaping
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_necromancer_2_3", {
	multiplier = 0 -- 0.25
})
mod_api.insert_text("sienna_necromancer_2_3_desc", "Critical attacks have unlimited cleave.")

--[[
	Cursed Blood
]]
-- Direct hit stagger
DamageProfileTemplates.sienna_necromancer_blood_explosion.default_target.power_distribution.impact = 0 -- 0.08
-- Crit burst stagger
DamageProfileTemplates.necromancer_crit_burst_stagger.default_target.power_distribution.impact = 0 -- 0.7
-- Prevent chain bursts
mod_api.insert_proc_function("necromancer_crit_burst", function (owner_unit, buff, params, world, param_order)
	local is_crit = params [param_order.is_critical_strike]
	if not is_crit then
		return
	end

	local is_first_hit = params [param_order.first_hit]
	if not is_first_hit then
		return
	end

	-- Check explosion
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local exploded_already = false
	if buff_extension then
		exploded_already = buff_extension:has_buff_type("tb_bw_necromancer_cursed_blood_icd")
	end
	if exploded_already then
		return
	end

	local hit_unit = params [param_order.attacked_unit]
	local is_burning, applied_this_frame = Managers.state.status_effect:has_status(hit_unit, StatusEffectNames.burning_balefire)
	if not is_burning or applied_this_frame then
		return
	end

	local damage_dealt = params [param_order.damage_amount]
	if damage_dealt <= 0 then
		return
	end

	local template = buff.template
	local side = Managers.state.side.side_by_unit [owner_unit]
	local hit_pos = POSITION_LOOKUP [hit_unit]
	if not hit_pos then

		return
	end

	local unit_storage = Managers.state.unit_storage
	local hit_go_id = unit_storage:go_id(hit_unit)
	local node_id = 0
	if Unit.has_node(hit_unit, "j_spine") then
		node_id = Unit.node(hit_unit, "j_spine")
	end

	local network_manager = Managers.state.network
	network_manager.network_transmit:send_rpc_server("rpc_play_particle_effect", NetworkLookup.effects ["fx/necromancer_cursed_explosion_blood"], hit_go_id, node_id, Vector3.zero(), Quaternion.identity(), false)
	network_manager.network_transmit:send_rpc_server("rpc_play_particle_effect", NetworkLookup.effects ["fx/necromancer_cursed_explosion_blue"], hit_go_id, node_id, Vector3(0.5, 0, 0), Quaternion.identity(), false)

	local audio_system = Managers.state.entity:system("audio_system")
	audio_system:play_audio_unit_event("Play_career_necro_ability_cursed_blood", hit_unit, "j_spine")

	local broadphase_categories = side.enemy_broadphase_categories
	local nearby_units = FrameTable.alloc_table()
	local num_nearby = AiUtils.broadphase_query(hit_pos, template.radius, nearby_units, broadphase_categories)

	if num_nearby == 0 then
		return
	end

	local t = Managers.time:time("game")
	local propagated_damage = damage_dealt * template.propagation_multiplier
	local career_extension = ScriptUnit.extension(owner_unit, "career_system")
	local power_level = career_extension:get_career_power_level()
	for i = 1, num_nearby do
		local target_unit = nearby_units [i]
		if target_unit ~= hit_unit then
			local damage_direction = Vector3.normalize(POSITION_LOOKUP [target_unit] - hit_pos)
			DamageUtils.add_damage_network(target_unit, owner_unit, propagated_damage, "torso", "buff", nil, damage_direction, "buff", nil, owner_unit, nil, nil, false, nil, nil, nil, nil, true, i)
			DamageUtils.stagger_ai(t, DamageProfileTemplates.necromancer_crit_burst_stagger, i + 1, power_level, target_unit, owner_unit, "torso", damage_direction, nil, nil, false, "buff", owner_unit)
		end
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local buff_to_add = "tb_bw_necromancer_cursed_blood_icd"
	buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
end)
-- Added Internal cooldown to prevent chain procs
mod_api.insert_talent_buff_template("bright_wizard", "tb_bw_necromancer_cursed_blood_icd", {
	duration = 0.3
})
-- Cursed blood explosion damage
mod_api.update_talent_buff_template("bright_wizard", "sienna_necromancer_4_1_cursed_blood", {
	propagation_multiplier = 0.10 -- 0.25 
})
mod_api.insert_text("sienna_necromancer_4_1_desc", "Critical attacks against enemies afflicted by the Malediction of Nagash cause them to burst, damaging nearby enemies for 10% of the attack. Cannot trigger more than once every 0.3 seconds.")

--[[
	Lost Souls
]]
-- Remove lost soul stagger
DamageProfileTemplates.trapped_soul.default_target.power_distribution_near.impact = 0 -- 0.25
DamageProfileTemplates.trapped_soul.default_target.power_distribution_far.impact = 0 -- 0.25


