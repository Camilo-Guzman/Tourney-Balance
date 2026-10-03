local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local random_utils = require("scripts/mods/TourneyBalance/_api/random_utils")

--[[
	$BEGIN_TB
		---
		## Ranger Veteran
		### Passives
		**Fast Hands**
		- Added double effective range for ranged weapons.
		- Added 10% increased ranged power.

		### Talents
		**Last Resort**
		- Now triggers when the weapon's clip is empty, instead of when totally out of ammo.
		- Fixed a bug where the buff would never trigger for non-host players.

		**Foe-Feller**
		- Attack speed increased to 15% (from 5%).

		**Drunken Brawler**
		- Lowered drinking time to 0.8s (from 1.9s).
		- Pseudo-random 50% (bag size 20 with 10 winning tickets).

		**Scavenger**
		- Removed bomb drops and reduced drop chance to pseudo-random 6% (from real-random 20%) (bag size 50 with 3 winning tickets).
		- Potions drop pseudo-random from bag size 6 with 2 of each potion (speed, strength, cooldown reduction).

		**Grungni's Cunning**
		- Excess ammo from picking up a large Survivalist pouch is converted into temporary health for Bardin (1 per ammo, max 5).

		**No Dawdling**
		- Additionally removes the limit on dodging efficiently.

		**Exuberance**
		- Reduced damage reduction to 20% (from 30%).

		**Firing Fury**
		- Also procs on picking up large Survivalist pouches (30% ammo).

		**Exhilarating Vapours**
		- Fixed a bug where repeatedly stepping in and out of the smoke cloud granted extra temp health.

		**Surprise Guest**
		- Added 30% cooldown reduction.

		**Ranger's Parting Gift**
		- Free bomb only applies to engineer bombs.
		- Added pseudo-random 5% chance to drop engineer bombs with every Survivalist drop (bag size 100 with 5 winning tickets).
	$END_TB
]]

--[[

	Passives

]]
--[[
	Scavenger
]]
-- State variables for pseudo-random drop chance
local ale_bag_state = {}
local bomb_bag_state = {}
local potion_spawn_bag_state = {}
local draw_ranger_potion = random_utils.shuffle_bag({
	"damage_boost_potion",
	"damage_boost_potion",
	"speed_boost_potion",
	"speed_boost_potion",
	"cooldown_reduction_potion",
	"cooldown_reduction_potion",
})
-- Pseudo-random surivalist drops
mod_api.insert_proc_function("bardin_ranger_scavenge_proc", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local offset_position_1 = Vector3(0, 0.25, 0)
	local offset_position_2 = Vector3(0, -0.25, 0)
	local offset_position_3 = Vector3(0.25, 0, 0)

	if ALIVE[owner_unit] then
		local drop_chance = buff.template.drop_chance
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
		local result = math.random(1, 100)

		if result < drop_chance * 100 then
			local player_pos = POSITION_LOOKUP[owner_unit] + Vector3.up() * 0.1
			local raycast_down = true
			local pickup_system = Managers.state.entity:system("pickup_system")

			-- Ranger's Parting Gift: 5% chance for engineer bomb
			if talent_extension:has_talent("bardin_ranger_ability_free_grenade") and random_utils.roll_virtual_bag(bomb_bag_state, 100, 5) then
				pickup_system:buff_spawn_pickup("engineer_grenade_t1", player_pos + offset_position_3, raycast_down)
			end

			if talent_extension:has_talent("bardin_ranger_passive_spawn_potions_or_bombs") then
				-- 6% chance for random potion
				if random_utils.roll_virtual_bag(potion_spawn_bag_state, 50, 3) then
					pickup_system:buff_spawn_pickup(draw_ranger_potion(), player_pos, raycast_down)
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
				end
			elseif talent_extension:has_talent("bardin_ranger_passive_improved_ammo") then
				pickup_system:buff_spawn_pickup("ammo_ranger_improved", player_pos, raycast_down)
			elseif talent_extension:has_talent("bardin_ranger_passive_ale") then
				if random_utils.roll_virtual_bag(ale_bag_state, 20, 10) then
					pickup_system:buff_spawn_pickup("bardin_survival_ale", player_pos + offset_position_1, raycast_down)
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos + offset_position_2, raycast_down)
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
				end
			else
				pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
			end
		end
	end
end)
-- Engineer bomb pickup prompt reuses the frag bomb's text ("Bomb") in vanilla
-- AllPickups holds the same table reference, so the interaction prompt picks this up
Pickups.grenades.engineer_grenade_t1.hud_description = "tb_engineer_grenade_pickup"
mod_api.insert_text("tb_engineer_grenade_pickup", "Engineer Bomb")
mod_api.insert_text("bardin_ranger_passive_spawn_potions_or_bombs_desc", "Killing a special has a 6%% chance to drop a potion instead of a Survivalist cache.")


--[[
	Fast Hands
]]
mod_api.insert_talent_buff_template("dwarf_ranger", "dwarf_ranger_ranged_power", {
	max_stacks = 1,
	multiplier = 0.1,
	stat_buff = "power_level_ranged",
})
mod_api.insert_career_passives("dr_3", {
	"dwarf_ranger_ranged_power",
	"markus_huntsman_passive_no_damage_dropoff",
})
mod_api.insert_text("career_passive_desc_dr_3c_2", "Double effective range for ranged weapons, 10% increased ranged power, and 15% increased reload speed.")

--[[

	Talents

]]
--[[
	Last Resort
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ranger_increased_melee_damage_on_no_ammo_add", {
	event = "on_ammo_clip_used", -- on_last_ammo_used
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ranger_increased_melee_damage_on_no_ammo_remove", {
	event = "on_reload", -- on_gained_ammo_from_no_ammo
})
mod_api.insert_text("bardin_ranger_increased_melee_damage_on_no_ammo_desc", "Increases power by 25%% while the weapon's clip is empty.")

-- buff is handled server-side
-- explicitly forwards to the server via rpc_proc_event
-- fixed index (not #NetworkLookup.proc_events + 1): vanilla ships exactly 7 entries, so this
-- always claims slot 8 regardless of what other mods append to the table on either peer -
-- a dynamic index desyncs host/client if the table's length differs between them at load time
local event_index = 8

NetworkLookup.proc_events[event_index] = "on_ammo_clip_used"
NetworkLookup.proc_events.on_ammo_clip_used = event_index

mod:hook(GenericAmmoUserExtension, "_check_ammo", function (func, self, ...)
	local will_empty_clip = self._shots_fired > 0 and self._current_ammo - self._shots_fired == 0

	func(self, ...)

	if not will_empty_clip or self._is_server or LEVEL_EDITOR_TEST then
		return
	end

	local owner_player = Managers.player:owner(self.owner_unit)

	if not owner_player or owner_player.bot_player then
		return
	end

	local peer_id = owner_player:network_id()
	local local_player_id = owner_player:local_player_id()
	local event_id = NetworkLookup.proc_events.on_ammo_clip_used

	Managers.state.network.network_transmit:send_rpc_server("rpc_proc_event", peer_id, local_player_id, event_id)
end)

--[[
	Foe Feller
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ranger_attack_speed", {
	multiplier = 0.15 --0.05
})
mod_api.update_talent("dr_ranger", 2, 3, {
	description_values = { -- update description
		{
			value_type = "percent",
			value = 0.15, -- buff_tweak_data.bardin_ranger_attack_speed.multiplie
		}
	},
})

--[[
	Drunken Brawler
]]
Weapons.bardin_survival_ale.actions.action_one.default.total_time = 0.8 -- 1.9

--[[
	No Dawdling
]]
mod_api.insert_text("bardin_ranger_movement_speed_desc", "Increases movement speed by 10%%. Removes the limit on dodging efficiently.")

-- Grants 99 dodge count regardless of the wielded weapon's own dodge_count value
mod:hook(GenericStatusExtension, "get_dodge_item_data", function (func, self, ...)
	func(self, ...)

	local talent_extension = ScriptUnit.has_extension(self.unit, "talent_system")

	if talent_extension and talent_extension:has_talent("bardin_ranger_movement_speed") then
		self.dodge_count = 99
	end
end)

--[[
	Exuberance
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ranger_reduced_damage_taken_headshot_buff", {
	multiplier = -0.2, -- -0.3
})
mod_api.update_talent("dr_ranger", 5, 2, {
    description_values = {},
})
mod_api.insert_text("bardin_ranger_reduced_damage_taken_headshot_desc_2", "Bardin takes 20.0% less damage from behind. Whenever he scores a headshots, this bonus applies to all damage taken for 7 seconds.")


--[[
	Firing Fury
	Grungni's Cunning
]]
local GRUNGNIS_CUNNING_MAX_TEMP_HEALTH = 5

local function tb_ranged_ammo_extension(inventory_extension)
	local slot_data = inventory_extension._equipment.slots.slot_ranged

	if not slot_data then
		return nil
	end

	local right_unit = slot_data.right_unit_1p
	local left_unit = slot_data.left_unit_1p

	return right_unit and ScriptUnit.has_extension(right_unit, "ammo_system") or left_unit and ScriptUnit.has_extension(left_unit, "ammo_system") or nil
end

-- Grungni's Cunning: excess ammo (1 per ammo, max 5) becomes temp health. Runs on the picker's own peer, so the heal
-- is requested from the server unless this is the server (host or bot).
local function tb_grungnis_cunning_temp_health(owner_unit, excess_ammo)
	local heal_amount = math.min(excess_ammo, GRUNGNIS_CUNNING_MAX_TEMP_HEALTH)

	if heal_amount <= 0 then
		return
	end

	if Managers.state.network.is_server then
		DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
	else
		local network_manager = Managers.state.network
		local unit_go_id = network_manager:unit_game_object_id(owner_unit)

		if unit_go_id then
			network_manager.network_transmit:send_rpc_server("rpc_request_heal", unit_go_id, heal_amount, NetworkLookup.heal_types.heal_from_proc)
		end
	end
end

mod:hook(SimpleInventoryExtension, "add_ammo_from_pickup", function (func, self, pickup_settings, ...)
	-- Only the big Survivalist pouch (30% ammo)
	if pickup_settings.pickup_name ~= "ammo_ranger_improved" then
		return func(self, pickup_settings, ...)
	end

	local owner_unit = self._unit
	local talent_extension = Unit.alive(owner_unit) and ScriptUnit.has_extension(owner_unit, "talent_system")
	local has_grungnis_cunning = talent_extension and talent_extension:has_talent("bardin_ranger_passive_improved_ammo")
	local ammo_extension = has_grungnis_cunning and tb_ranged_ammo_extension(self)
	local ammo_before = ammo_extension and ammo_extension:total_remaining_ammo()

	func(self, pickup_settings, ...)

	if not talent_extension then
		return
	end

	-- Grungni's Cunning
	if ammo_before then
		local refill_amount = math.floor(ammo_extension:max_ammo() * (pickup_settings.refill_percentage or 0))
		local gained = ammo_extension:total_remaining_ammo() - ammo_before

		tb_grungnis_cunning_temp_health(owner_unit, refill_amount - gained)
	end

	-- Firing Fury
	if talent_extension:has_talent("bardin_ranger_reload_speed_on_multi_hit") then
		ScriptUnit.extension(owner_unit, "buff_system"):add_buff("bardin_ranger_reload_speed_on_multi_hit_buff")
	end
end)
mod_api.insert_text("bardin_ranger_reload_speed_on_multi_hit_desc", "Hitting 2 enemies with one ranged attack or picking up a large Survivalist pouch increases Bardin's reload speed by 35.0%% for 2 seconds.")
mod_api.update_talent("dr_ranger", 4, 2, { -- update description
	description_values = {},
})
mod_api.insert_text("bardin_ranger_passive_improved_ammo_desc_2", string.format("Survivalist pickups restore 30%% ammo. Excess ammo from Survivalist pouches grant up to %d temporary health for Bardin.", GRUNGNIS_CUNNING_MAX_TEMP_HEALTH))

--[[
	Parting Gift
]]
-- Remove free grenade perk
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ranger_ability_free_grenade_buff", {
	perks = {},
})
-- Free engineer grenade
mod:hook(ActionChargedProjectileUtility, "fire_charged_projectile", function (func, projectile_context, ...)
	if not (projectile_context.is_grenade and not projectile_context.grenade_thrown) then
		return func(projectile_context, ...)
	end

	local buff_extension = projectile_context.buff_extension

	if not buff_extension:get_non_stacking_buff("bardin_ranger_ability_free_grenade_buff") then
		return func(projectile_context, ...)
	end

	-- item_name is the ItemMasterList key ("grenade_engineer")
	-- not the pickup/weapon template name ("engineer_grenade_t1")
	local is_engineer_bomb = projectile_context.item_name == "grenade_engineer"
	local real_has_buff_perk = buff_extension.has_buff_perk

	buff_extension.has_buff_perk = function (self, perk_name)
		if perk_name == "free_grenade" and is_engineer_bomb then
			return true
		end

		return real_has_buff_perk(self, perk_name)
	end

	-- Forwards errors in hooked function, and its return value (trigger_wield) - dropping
	-- the latter was why the weapon never rewielded after a free throw.
	local ok, result = pcall(func, projectile_context, ...)

	buff_extension.has_buff_perk = real_has_buff_perk

	if not ok then
		error(result, 0)
	end

	return result
end)
-- 5% engineer bomb drop on Survivalist drops: see bardin_ranger_scavenge_proc above
mod_api.insert_text("bardin_ranger_ability_free_grenade_desc", "Activating Disengage causes the next engineer bomb Bardin throws to not be consumed. Does not stack. Survivalist gains a 5%% chance to drop an engineer bomb.")

--[[
	Exhilarating Vapours
]]
-- Fix: Increased thp gain by stepping in and out of the smoke repeatedly.
local smoke_heal_next_tick = setmetatable({}, { __mode = "k" })

mod_api.insert_buff_function("bardin_ranger_heal_smoke", function (unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local t = params.t
	local buff_template = buff.template
	local next_heal_tick = smoke_heal_next_tick[unit] or 0

	if next_heal_tick < t and HEALTH_ALIVE[unit] then
		local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

		if talent_extension then
			local status_extension = ScriptUnit.has_extension(unit, "status_system")

			if not status_extension then
				return
			end

			local heal_amount = buff_template.heal_amount

			if not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() then
				DamageUtils.heal_network(unit, unit, heal_amount, "heal_from_proc")
			end
		end

		smoke_heal_next_tick[unit] = t + buff_template.time_between_heals
	end
end)

--[[
	Surprise Guest
]]
-- Added 30% CDR
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ranger_activated_ability_stealth_outside_of_smoke", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3,
	max_stacks = 1
})
mod_api.insert_text("bardin_ranger_activated_ability_stealth_outside_of_smoke_desc", "Disengage's stealth does not break on moving beyond the smoke cloud. Reduces the cooldown of Disengage by 30%.")

