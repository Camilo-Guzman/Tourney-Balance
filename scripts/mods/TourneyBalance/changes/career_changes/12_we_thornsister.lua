local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Sister of the Thorn
		### Career Ability
		- Increased ultimate cooldown to 70s (from 40s).

		### Passives
		**A Cluster of Radiants**
		- Increased passive ultimate cooldown to 70s (from 60s).

		**A Sustenance of Leechlings**
		- Decreased temp health siphon from team to 10% (from 100%).

		### Talents
		**Surge of Malice**
		- Lowered required health threshold to 70% (from 90%).

		**Atharti's Delight**
		- Bleed is limited to 1 stack (from 3).

		**Briar's Malice**
		- Crit stacks granted increased to 3 (from 2)
		- Only consume crit stacks on hit, and at most 1 stack per attack (even against multiple enemies).

		**Bonded Spirit**
		- Updated description: Internal CD of losing cooldown is  1s.

		**Radiant Inheritance**
		- Can be activated with Thornwake (regular ult).
		- Recasting refreshes the and extends the duration to 20s.
		- Allies now also see a depleting-icon timer for the buff (previously a static icon).

		**Repel**
		- Additionally grants passive 100% increased stamina recovery.

		**Blackvenom Thicket**
		- Added 40% cooldown reduction.
	$END_TB
]]

--[[

	Ultimate

]]
mod_api.update_career_ability_cooldown("we_thornsister", 70) -- 40


--[[
	Passive
]]
--[[
	A Cluster of Radiants
]]
PassiveAbilitySettings.we_thornsister.passive_ability_classes[1].init_data.cooldown = 70 -- 60
mod_api.insert_text("career_passive_desc_we_thornsister", "Kerillian is granted Radiance (a free use of her career skill) every 70 seconds.")

--[[
	A Sustenance of Leechlings
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_temp_health_funnel_aura_buff", {
	multiplier = 0.10
})

--[[

	Talents

]]
--[[
	Surge of Malice
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_attack_speed_on_full", {
	health_threshold = 0.7, -- 0.9
})
mod_api.update_talent("we_thornsister", 2, 1, {
	description_values = {},
})
mod_api.insert_text("kerillian_thorn_sister_attack_speed_on_full_desc", "Increases attack speed by 15% while above 70% health.")

--[[
	Atharti's Delight
]]
-- Vanilla proc (any melee hit on a poisoned enemy), but the bleed only stacks once
BuffTemplates.thorn_sister_big_bleed.buffs[1].max_stacks = 2 -- 3
mod_api.insert_text("kerillian_thorn_sister_crit_big_bleed_desc_2", "Melee attacks against poisoned enemies inflict a heavy bleed for 5 seconds. Does not stack.")


--[[
	Briar's Malice
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
	amount_to_add = 3, -- 2
})
mod_api.update_talent("we_thornsister", 2, 3, {
	description_values = {
		{
			value = 3, -- 2
		},
	},
})
-- consume 1 stack only on hit
-- Explosions can't rely on target_number: remote clients receive every explosion hit via rpc_buff_on_attack with
-- target_number hardcoded to 1, and the hits are spread over several frames (aoe damage ring buffer + network).
-- So an explosion consumes one stack, then further explosion hits are ignored for a short window.
local TB_CRIT_STACK_AOE_WINDOW = 0.5
local tb_crit_stack_last_aoe_consume_t = setmetatable({}, { __mode = "k" })
mod_api.insert_proc_function("tb_thorn_sister_remove_crit_stack_on_first_hit", function (owner_unit, buff, params)
	local attack_type = params[2]
	local target_number = params[4]

	if target_number and target_number > 1 then
		return
	end

	if attack_type == "aoe" or attack_type == "grenade" then
		local t = Managers.time:time("game")
		local last_consume_t = tb_crit_stack_last_aoe_consume_t[owner_unit]

		if last_consume_t and t - last_consume_t < TB_CRIT_STACK_AOE_WINDOW then
			return
		end

		tb_crit_stack_last_aoe_consume_t[owner_unit] = t
	end

	return ProcFunctions.remove_ref_buff_stack_woods(owner_unit, buff, params)
end)
-- Deepwood Staff's Lift consumes crit stack
mod_api.insert_proc_function("tb_thorn_sister_remove_crit_stack_on_lift", function (owner_unit, buff, params)
	local action_kind = params[1]

	if action_kind ~= "spirit_storm" then
		return
	end

	return ProcFunctions.remove_ref_buff_stack_woods(owner_unit, buff, params)
end)
mod_api.insert_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability_handler", {
	{
		name = "kerillian_thorn_sister_crit_on_any_ability_handler",
		buff_func = "tb_thorn_sister_remove_crit_stack_on_first_hit",
		buff_to_remove = "kerillian_thorn_sister_crit_on_any_ability_buff",
		event = "on_hit",
		max_stacks = 1,
	},
	{
		name = "kerillian_thorn_sister_crit_on_any_ability_handler_lift",
		buff_func = "tb_thorn_sister_remove_crit_stack_on_lift",
		buff_to_remove = "kerillian_thorn_sister_crit_on_any_ability_buff",
		event = "on_critical_action",
		max_stacks = 1,
	},
})

--[[
	Bonded Spirit
]]
mod_api.insert_text("kerillian_thorn_sister_faster_passive_desc", "Reduce the cooldown of Radiance by 50%%, taking damage increases the cooldown by 2 seconds (1 second internal cooldown).")

--[[
	Radiant Inheritance
]]
-- longer duration for radiant inheritance
local radiant_thorn_stack_count = {}

-- Give allies a depleting-icon timer matching Kerillian's own
local radiant_thorn_ally_timer_ids = setmetatable({}, { __mode = "k" })
mod_api.insert_talent_buff_template("wood_elf", "tb_radiant_inheritance_ally_timer", {
	icon = "kerillian_thornsister_avatar",
	max_stacks = 1,
	refresh_durations = true,
})
local function tb_radiant_thorn_refresh_ally_timer(ally_unit, remaining_duration)
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_id = buff_system:add_buff_synced(ally_unit, "tb_radiant_inheritance_ally_timer", BuffSyncType.All, {
		external_optional_duration = remaining_duration,
	})

	-- A refresh of an already-tracked timer returns -1 (no new instance was created), so only
	-- overwrite the tracked id on a genuine first add - otherwise we'd lose the id needed to
	-- remove it later
	if buff_id and buff_id ~= -1 then
		radiant_thorn_ally_timer_ids[ally_unit] = buff_id
	end
end
local function tb_radiant_thorn_duration_modifier(unit, sub_buff_template, duration, buff_extension, params)
	local is_active = buff_extension:has_buff_type("kerillian_thorn_sister_team_buff_aura")
	local current_count = radiant_thorn_stack_count[unit] or 0
	local new_count = math.min(is_active and current_count + 1 or 1, 2)

	radiant_thorn_stack_count[unit] = new_count

	local final_duration = duration * new_count

	-- Push the freshly (re)cast duration to every ally currently in range
	if Managers.state.network.is_server then
		local side = Managers.state.side.side_by_unit[unit]

		if side then
			local range = sub_buff_template.range
			local range_squared = range * range
			local caster_position = POSITION_LOOKUP[unit]
			local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

			for i = 1, #player_and_bot_units do
				local ally_unit = player_and_bot_units[i]

				if ally_unit ~= unit and HEALTH_ALIVE[ally_unit] and Vector3.distance_squared(caster_position, POSITION_LOOKUP[ally_unit]) < range_squared then
					tb_radiant_thorn_refresh_ally_timer(ally_unit, final_duration)
				end
			end
		end
	end

	return final_duration
end
-- Piggybacks on the same per-tick range check the real aura buff already uses
local tb_radiant_thorn_vanilla_activate_buff_on_distance = BuffFunctionTemplates.functions.activate_buff_on_distance
mod_api.insert_buff_function("tb_radiant_thorn_activate_buff_on_distance", function (owner_unit, buff, params)
	tb_radiant_thorn_vanilla_activate_buff_on_distance(owner_unit, buff, params)

	if not Managers.state.network.is_server then
		return
	end

	local side = Managers.state.side.side_by_unit[owner_unit]

	if not side then
		return
	end

	local remaining_duration = buff.duration and buff.start_time + buff.duration - Managers.time:time("game")
	local range = buff.range
	local range_squared = range * range
	local caster_position = POSITION_LOOKUP[owner_unit]
	local buff_system = Managers.state.entity:system("buff_system")
	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

	for i = 1, #player_and_bot_units do
		local ally_unit = player_and_bot_units[i]

		if ally_unit ~= owner_unit and HEALTH_ALIVE[ally_unit] then
			local inside = Vector3.distance_squared(caster_position, POSITION_LOOKUP[ally_unit]) < range_squared
			local timer_id = radiant_thorn_ally_timer_ids[ally_unit]

			if inside and not timer_id and remaining_duration and remaining_duration > 0 then
				tb_radiant_thorn_refresh_ally_timer(ally_unit, remaining_duration)
			elseif not inside and timer_id then
				buff_system:remove_buff_synced(ally_unit, timer_id)
				radiant_thorn_ally_timer_ids[ally_unit] = nil
			end
		end
	end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_team_buff_aura", {
	duration = 10,
	max_stacks = 2,
	refresh_durations = true,
	duration_modifier_func = tb_radiant_thorn_duration_modifier,
	update_func = "tb_radiant_thorn_activate_buff_on_distance",
})
-- trigger radiant inheritance on regular ult too, not just extra-charge uses
mod_api.update_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_team_buff", {
	event = "on_ability_cooldown_started",
})
mod_api.insert_text("kerillian_thorn_sister_passive_team_buff_desc", "Consuming Radiance or Thornwake grants Kerillian and nearby allies 15.0%% power and 5.0%% critical strike chance for 10 seconds. Duration can stack 2 times.")

--[[
	Repel
]]
mod_api.insert_talent_buff_template("wood_elf", "tb_repel_stamina_recovery", {
	stat_buff = "fatigue_regen",
	multiplier = 1.0,
})
mod_api.update_talent("we_thornsister", 5, 3, {
	description = "kerillian_thorn_sister_big_push_desc",
	description_values = {},
	buffs = {
		"kerillian_thorn_sister_big_push",
		"tb_repel_stamina_recovery",
	},
})
mod_api.insert_text("kerillian_thorn_sister_big_push_desc", "Pushing at full stamina increases the strength and range of the push by 100%. Increases stamina recovery by 100%.")

--[[
	Blackvenom Thicket
]]
mod_api.update_talent("we_thornsister", 6, 3, {
    buffs = {
        "tb_blackvenom_cdr"
    }
})
mod_api.insert_talent_buff_template("wood_elf", "tb_blackvenom_cdr", {
	stat_buff = "activated_cooldown",
	multiplier = -0.4,
	max_stacks = 1
})
mod_api.insert_text("kerillian_thorn_sister_debuff_wall_desc_2", "Thornwake instead causes roots to burst from the ground, staggering enemies and applying Blackvenom to them. Reduces cooldown by 40%%.")
