local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local is_local = require("scripts/mods/TourneyBalance/_api/shared_utils").is_local

--[[
	$BEGIN_TB
		---
		## Mercenary
		
		### Passives
		**Paced Strikes**
		- Paced Strikes applies to the team.
		- Paced Strikes also grants Kruber (only) 10% damage reduction for 6 seconds.

		### Talents
		**Helborg's Tutelage**
		- Added random crits.

		**Enhanced Training**
		- Decreased required enemies to activate Paced Strikes to 3 (from 4)
		
		**Strike Together**
		- Changed to Paced Strikes activates on hitting 1 enemy.

		**Blade Barrier**
		- Lowered damage reduction to 15% (from 25%).

		**Black Market Supplies**
		- Increased ammo bonus to 50% (from 30%).

		**On Yer Feet, Mates!**
		- Ultimate cooldown is instantly refunded when an ally is knocked down.
		- Doubled revive range to 30 (from 15). Healing range unchanged.
		- Players can be revived while disabled.
	$END_TB
]]

--[[

	Passives

]]
--[[
	Paced Strikes
	Enhanced Trainig
	Strike Together
]]
-- Give Paced Strikes to team Passive
local function add_buff_to_team(owner_unit, buff_name)
	local buff_system = Managers.state.entity:system("buff_system")
	local side = Managers.state.side.side_by_unit[owner_unit]
	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

	for i = 1, #player_and_bot_units do
		local unit = player_and_bot_units[i]

		if HEALTH_ALIVE[unit] then
			buff_system:add_buff(unit, buff_name, owner_unit, false)
		end
	end
end
-- Refactored proc function
mod_api.insert_proc_function("gain_markus_mercenary_passive_proc", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local attack_type = params[2]
	if not (ALIVE[owner_unit] and (attack_type == "light_attack" or attack_type == "heavy_attack")) then
		return
	end

	local buff_template = buff.template
	local target_number = params[4]
	local buff_to_add = buff_template.buff_to_add
	local buff_system = Managers.state.entity:system("buff_system")
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local passive_triggered = false

	if target_number and target_number >= 3 then
		-- Base Paced Strikes/Strike Together
		add_buff_to_team(owner_unit, buff_to_add)
		passive_triggered = true

		 -- Enhanced Training
		if talent_extension:has_talent("markus_mercenary_passive_improved") then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_improved", owner_unit, false)
		 -- Reikland Reaper
		elseif talent_extension:has_talent("markus_mercenary_passive_power_level_on_proc") then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_power_level", owner_unit, false)
		end

	-- Paced Strikes on hit
	elseif target_number and target_number >= 1 and talent_extension:has_talent("markus_mercenary_passive_group_proc") then
		add_buff_to_team(owner_unit, buff_to_add)
		passive_triggered = true
	end

	if passive_triggered then
		-- Paced Strikes: damage reduction for Kruber only
		buff_system:add_buff(owner_unit, "tb_markus_mercenary_passive_defence", owner_unit, false)

		-- Blade Barrier correctly procs when Paced Strike is active
		if talent_extension:has_talent("markus_mercenary_passive_defence_on_proc") then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_defence", owner_unit, false)
		end
	end
end)
-- Same duration as Paced Strikes' attack speed (markus_mercenary_passive_proc); damage taken is resolved on the server
mod_api.insert_talent_buff_template("empire_soldier", "tb_markus_mercenary_passive_defence", {
	stat_buff = "damage_taken",
	multiplier = -0.1,
	duration = 6,
	max_stacks = 1,
	refresh_durations = true,
})
-- Enhanced Training adjustement, because Strike Together is passive
mod_api.update_talent_buff_template("empire_soldier", "markus_mercenary_passive_improved", {
    multiplier = 0.1 -- 0.2
})
mod_api.insert_text("career_passive_desc_es_3a", "Hitting 3 enemies in one swing grants 10% increased attack speed for 6 seconds to allies. Kruber also takes 10% less damage for the duration.")
mod_api.insert_text("markus_mercenary_passive_improved_desc", "Paced Strikes now increases attack speed by 20.0%%")
mod_api.insert_text("markus_mercenary_passive_group_proc_desc", "Paced Strikes activates when hitting 1 enemy.")

--[[

	Talents

]]
--[[
	Helborg's Tutelage
]]
-- Added Random Crits: clears the vanilla "no_random_crits" talent perk
Talents.empire_soldier[52].perks = nil -- talent_settings_markus.lua:2503
-- on_hit only consumes the stack when an enemy is hit (not on whiffs), and only if that hit was critical, so cleave/dual-weapon follow-up
mod_api.insert_proc_function("tb_remove_crit_count_buff_on_crit_hit_helborg", function (owner_unit, buff, params)
	local is_critical = params[6]

	return is_critical and true or false
end)
mod_api.update_talent_buff_template("empire_soldier", "markus_mercenary_crit_count_buff", {
	event = "on_hit", -- "on_critical_action"
	buff_func = "tb_remove_crit_count_buff_on_crit_hit_helborg" -- "dummy_function"
})
mod_api.insert_talent_text("markus_mercenary_crit_count", "Hellborg's Tutelage", "Every 5 hits grant a guaranteed critical strike. Random Crits can still occur.")
-- (FIX) Clients get 2 stack counts per hit
local add_buff_on_first_target_hit = ProcFunctions.add_buff_on_first_target_hit
mod_api.insert_proc_function("tb_add_buff_on_first_target_hit_helborg", function (owner_unit, buff, params)
	if is_local(owner_unit) then 
		add_buff_on_first_target_hit(owner_unit, buff, params)
	end
end)
mod_api.update_talent_buff_template("empire_soldier", "markus_mercenary_crit_count", {
	buff_func = "tb_add_buff_on_first_target_hit_helborg" --"add_buff_on_first_target_hit"
})

--[[
	Blade Barrier
]]
mod_api.update_talent_buff_template("empire_soldier", "markus_mercenary_passive_defence", {
	multiplier = -0.15, -- -0.25
})
mod_api.update_talent("es_mercenary", 5, 2, { -- update description
	description_values = {
		{
			value_type = "percent",
			value = -0.15, -- buff_tweak_data.markus_mercenary_passive_defence.multiplier
		},
	},
})

--[[
	Black Market Supplies
]]
mod_api.update_talent_buff_template("empire_soldier", "markus_mercenary_max_ammo", {
	multiplier = 0.5, -- 0.3
})
mod_api.update_talent("es_mercenary", 5, 3, { -- update description
	description_values = {
		{
			value_type = "percent",
			value = 0.5, -- buff_tweak_data.markus_mercenary_max_ammo.multiplier
		},
	},
})

--[[
	On Yer Feet, Mates!
]]
-- Ult cooldown refunds when an ally gets knocked down. The cooldown lives on the owner, so this polls ally status
-- on the owning peer (local player, or server for bots) and fires on the not-downed -> downed transition.
-- Ally status flags are synced to every peer. Registered through the CareerExtension.update dispatcher in TourneyBalance.lua.
mod:add_career_update_function(function (self, unit, input, dt, context, t)
	if self._career_name ~= "es_mercenary" then
		return
	end

	local player = self.player

	if not player or not (player.local_player or (self.is_server and player.bot_player)) then
		return
	end

	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	if not (talent_extension and talent_extension:has_talent("markus_mercenary_activated_ability_revive")) then
		self._tb_ally_knocked_down = nil
		return
	end

	local side = Managers.state.side.side_by_unit[unit]
	local player_and_bot_units = side and side.PLAYER_AND_BOT_UNITS

	if not player_and_bot_units then
		return
	end

	local ally_knocked_down = self._tb_ally_knocked_down

	if not ally_knocked_down then
		ally_knocked_down = {}
		self._tb_ally_knocked_down = ally_knocked_down
	end

	local refund = false

	for i = 1, #player_and_bot_units do
		local ally_unit = player_and_bot_units[i]

		if ally_unit ~= unit and ALIVE[ally_unit] then
			local ally_status_extension = ScriptUnit.has_extension(ally_unit, "status_system")
			local knocked_down = ally_status_extension and ally_status_extension:is_knocked_down() or false
			local was_knocked_down = ally_knocked_down[ally_unit]

			-- First sighting (nil) only records the state, so picking the talent/joining next to a downed ally doesn't refund
			if knocked_down and was_knocked_down == false then
				refund = true
			end

			ally_knocked_down[ally_unit] = knocked_down
		end
	end

	if refund then
		self:reduce_activated_ability_cooldown_percent(1)
	end
end)
-- Revive range doubled to 30 (from 15). Revives ignore disblaed status
local ON_YER_FEET_VANILLA_RADIUS = 15
local ON_YER_FEET_REVIVE_RADIUS = 30

mod:hook_safe(CareerAbilityESMercenary, "_run_ability", function (self)
	local owner_unit = self._owner_unit
	local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

	if not talent_extension or not talent_extension:has_talent("markus_mercenary_activated_ability_revive") then
		return
	end

	local position = POSITION_LOOKUP[owner_unit]
	local broadphase = Managers.state.entity:system("proximity_system").player_units_broadphase
	local vanilla_units = FrameTable.alloc_table()
	local nearby_units = FrameTable.alloc_table()

	Broadphase.query(broadphase, position, ON_YER_FEET_VANILLA_RADIUS, vanilla_units)
	Broadphase.query(broadphase, position, ON_YER_FEET_REVIVE_RADIUS, nearby_units)

	local already_handled = FrameTable.alloc_table()

	for _, unit in pairs(vanilla_units) do
		already_handled[unit] = true
	end

	local side_manager = Managers.state.side
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)

	for _, friendly_unit in pairs(nearby_units) do
		local status_extension = not side_manager:is_enemy(owner_unit, friendly_unit) and ScriptUnit.has_extension(friendly_unit, "status_system")

		if status_extension and status_extension:is_knocked_down() and not status_extension:is_grabbed_by_tentacle() and not status_extension:is_grabbed_by_chaos_spawn() then
			local is_free = status_extension:is_available_for_career_revive()

			-- Free allies within 15 were already revived by vanilla
			if not is_free or not already_handled[friendly_unit] then
				network_transmit:send_rpc_server("rpc_request_revive", network_manager:unit_game_object_id(friendly_unit), owner_unit_go_id)

				-- No get-up animation while still pinned or grabbed
				if is_free then
					CharacterStateHelper.play_animation_event(friendly_unit, "revive_complete")
				end
			end
		end
	end
end)
mod_api.insert_text("markus_mercenary_activated_ability_revive_desc", "Morale Boost also revives knocked down allies within 30 metres. Resets cooldown on Moral Boost when an ally is knocked down.")


