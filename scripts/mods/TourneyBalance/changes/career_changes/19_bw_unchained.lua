local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	$BEGIN_TB
		---
		## Unchained
		### Passives
		**Unchained (new)**
		- No longer explodes from overcharge, and enters the Unchained state instead for 10 seconds.
		- Can't use the ranged weapon for the duration.
		- Burns for 20 health per second (non-lethal).
		- Gains 30% attack speed, 10% melee power and 10% critical strike chance.
		- Using Living Bomb immediately ends the Unchained state.

		### Talents
		**Dissipate**
		- Reduced overcharge vented from blocking to 20% (from 100%).
	$END_TB
]]

--[[

	Passives

]]
--[[
	Unchained
]]
local UNCHAINED_STATE_BUFF = "tb_sienna_unchained_unchained_state"
local UNCHAINED_DURATION = 10
local UNCHAINED_BURN_PER_SECOND = 20
-- life_tap skips damage reduction and damage to overcharge conversion, wounded_dot does not interrupt interaction
local UNCHAINED_BURN_SOURCE = "life_tap"
local UNCHAINED_BURN_TYPE = "wounded_dot"

mod_api.insert_buff_function("tb_unchained_state_burn_tick", function (unit, buff, params)
	if not Managers.state.network.is_server or not HEALTH_ALIVE[unit] then
		return
	end

	local status_extension = ScriptUnit.has_extension(unit, "status_system")

	if status_extension and status_extension:is_knocked_down() then
		return
	end

	-- Non-lethal: never tick below 1 health
	local health_extension = ScriptUnit.has_extension(unit, "health_system")
	local current_health = health_extension and health_extension:current_health() or 0
	local damage = math.min(UNCHAINED_BURN_PER_SECOND, current_health - 1)

	if damage <= 0 then
		return
	end

	DamageUtils.add_damage_network(unit, unit, damage, "full", UNCHAINED_BURN_TYPE, nil, Vector3(0, 0, 0), UNCHAINED_BURN_SOURCE, nil, unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)
end)
-- on_ability_activated procs on every local player's buffs whenever anyone ults (params[1] is the activating unit).
-- Returning true lets remove_on_proc end the whole state (all sub-buffs share the buff id).
mod_api.insert_proc_function("tb_unchained_state_end_on_own_ability", function (owner_unit, buff, params)
	return params[1] == owner_unit
end)
-- no_overcharge_explosion: overcharging again during the state vents instead of exploding or re-entering the state
mod_api.insert_talent_buff_template("bright_wizard", UNCHAINED_STATE_BUFF, {
	{
		icon = "sienna_unchained_passive",
		duration = UNCHAINED_DURATION,
		debuff = true,
		max_stacks = 1,
		update_frequency = 1,
		update_func = "tb_unchained_state_burn_tick",
		event = "on_ability_activated",
		buff_func = "tb_unchained_state_end_on_own_ability",
		remove_on_proc = true,
		perks = {
			buff_perks.no_overcharge_explosion,
		},
	},
	{
		name = "tb_sienna_unchained_unchained_state_attack_speed",
		duration = UNCHAINED_DURATION,
		max_stacks = 1,
		stat_buff = "attack_speed",
		multiplier = 0.3,
	},
	{
		name = "tb_sienna_unchained_unchained_state_power",
		duration = UNCHAINED_DURATION,
		max_stacks = 1,
		stat_buff = "power_level_melee",
		multiplier = 0.1,
	},
	{
		name = "tb_sienna_unchained_unchained_state_crit",
		duration = UNCHAINED_DURATION,
		max_stacks = 1,
		stat_buff = "critical_strike_chance",
		bonus = 0.1,
	},
})
mod_api.insert_text(UNCHAINED_STATE_BUFF, "Unchained")
mod_api.insert_perk_text("tb_bw_3_unchained", "Unchained", "Instead of exploding from overcharge, Sienna can't use her ranged weapon for 10 seconds, gaining 30% attack speed, 10% melee power and 10% critical strike chance, while burning for 20 health per second (non-lethal). Using Living Bomb ends this state.")
mod_api.insert_career_perk_descriptions("bw_3", "tb_bw_3_unchained")

-- Units whose ranged action still needs to be stopped. Deferred to the next frame, since the state starts from inside
-- the ranged weapon's own action update (add_charge), where stopping that action is not safe.
local tb_unchained_pending_ranged_stop = {}

-- Runs on the owner, where overcharge lives. The state buff goes on locally first, so the vanilla threshold check
-- right after sees its no_overcharge_explosion perk and vents instead of exploding.
mod:hook(PlayerUnitOverchargeExtension, "_check_overcharge_level_thresholds", function (func, self, new_overcharge_value)
	if self.max_value <= new_overcharge_value and not self._buff_extension:has_buff_perk("no_overcharge_explosion") then
		local unit = self.unit
		local career_extension = ScriptUnit.has_extension(unit, "career_system")

		if career_extension and career_extension:career_name() == "bw_unchained" then
			Managers.state.entity:system("buff_system"):add_buff_synced(unit, UNCHAINED_STATE_BUFF, BuffSyncType.LocalAndServer)

			tb_unchained_pending_ranged_stop[unit] = true
		end
	end

	return func(self, new_overcharge_value)
end)

local function tb_unchained_ranged_locked(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not buff_extension or not buff_extension:has_buff_type(UNCHAINED_STATE_BUFF) then
		return false
	end

	local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")

	return inventory_extension and inventory_extension:get_wielded_slot_name() == "slot_ranged"
end

-- Ends a ranged action already running when the state starts (charging, beam or flamethrower channels would keep going)
mod:add_update_function(function (dt)
	if next(tb_unchained_pending_ranged_stop) == nil then
		return
	end

	for unit in pairs(tb_unchained_pending_ranged_stop) do
		tb_unchained_pending_ranged_stop[unit] = nil

		if ALIVE[unit] and tb_unchained_ranged_locked(unit) then
			CharacterStateHelper.stop_weapon_actions(ScriptUnit.extension(unit, "inventory_system"), "interrupted")
		end
	end
end)

-- Every weapon action (attacks, chains, venting) starts through start_action, while swapping weapons is its own
-- action_wield. Refusing everything but action_wield on the ranged weapon leaves it unusable, but still swappable.
mod:hook(WeaponUnitExtension, "start_action", function (func, self, action_name, ...)
	if action_name and action_name ~= "action_wield" and tb_unchained_ranged_locked(self.owner_unit) then
		return
	end

	return func(self, action_name, ...)
end)

--[[

	Talents

]]
--[[
	Dissipate Nerf
]]
-- Overcharge dissipation reduce to 20% or vanilla
--[[
local block_breaking_fatigue_types = {
	blocked_attack = true,
	blocked_attack_2 = true,
	blocked_attack_3 = true,
	blocked_berzerker = true,
	blocked_charge = true,
	blocked_headbutt = true,
	blocked_ranged = true,
	blocked_running = true,
	blocked_slam = true,
	blocked_sv_cleave = true,
	blocked_sv_sweep = true,
	blocked_sv_sweep_2 = true,
	chaos_cleave = true,
	chaos_spawn_combo = true,
	complete = true,
	ogre_shove = true,
	shield_blocked_slam = true,
	sv_push = true,
	sv_shove = true,
}
mod:hook_origin(GenericStatusExtension, "add_fatigue_points", function (self, fatigue_type, attacking_unit, blocking_weapon_unit, fatigue_point_costs_multiplier, is_timed_block)
	local buff_extension = self.buff_extension

	if Development.parameter("disable_fatigue_system") then
		return
	end

	local player = self.player

	if player and player.remote then
		Crashify.print_exception("[GenericStatusExtension]", "Tried adding fatigue points to a remote player.")

		return
	end

	local amount = PlayerUnitStatusSettings.fatigue_point_costs[fatigue_type]
	local t = Managers.time:time("game")
	local max_fatigue = PlayerUnitStatusSettings.MAX_FATIGUE
	local max_fatigue_points = self.max_fatigue_points
	local fatigue_cost = amount * (max_fatigue / max_fatigue_points) * (fatigue_point_costs_multiplier or 1)

	if is_timed_block then
		fatigue_cost = buff_extension:apply_buffs_to_value(fatigue_cost, "timed_block_cost")
	end

	if amount and fatigue_point_costs_multiplier and amount < 2 and fatigue_point_costs_multiplier < 1 and buff_extension:has_buff_perk("in_arc_block_cost_reduction") then
		fatigue_cost = 0
	end

	if blocking_weapon_unit then
		fatigue_cost = buff_extension:apply_buffs_to_value(fatigue_cost, "block_cost")

		if buff_extension:has_buff_perk("overcharged_block") then
			local overcharge_extension = ScriptUnit.has_extension(self.unit, "overcharge_system")

			if overcharge_extension and overcharge_extension:above_overcharge_threshold() then
				fatigue_cost = fatigue_cost * 0.5

				amount = amount * 0.2 -- 1 -- Dissipate Nerf

				overcharge_extension:remove_charge(amount)
			end
		end
	end

	local fatigue = math.clamp(self.fatigue + fatigue_cost, 0, max_fatigue)

	self:set_fatigue_points(fatigue, fatigue_type)

	if blocking_weapon_unit then
		buff_extension:trigger_procs("on_block", attacking_unit, fatigue_type, blocking_weapon_unit)
	end

	if max_fatigue <= fatigue and block_breaking_fatigue_types[fatigue_type] then
		self:set_block_broken(true, t, attacking_unit)
	end

	if fatigue_cost > 0 then
		self.last_fatigue_gain_time = t
		self.show_fatigue_gui = true
	end

	if fatigue_type == "action_stun_push" then
		self.action_stun_push = true
	end

	local first_person_extension = self.first_person_extension

	if amount > PlayerUnitStatusSettings.fatigue_points_to_play_heavy_block_sfx and first_person_extension then
		first_person_extension:play_hud_sound_event("Play_player_combat_heavy_block_sweetner", nil, false)
	end
end)
]]