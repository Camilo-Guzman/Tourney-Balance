local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local reduce_cooldown_percent_on_owner = require("scripts/mods/TourneyBalance/_api/shared_utils").reduce_cooldown_percent_on_owner
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	$BEGIN_TB
		---
		## Unchained
		### Career Ability
		**Living Bomb**
		- Added an AoE stagger (same as Witch Hunter Captain's Animosity shout).

		### Passives
		**Aqshy's Blaze (new)**
		- No longer explodes from overcharge, and enters the Unchained state instead for 10 seconds.
		- Can't attack with the ranged weapon for the duration.
		- Loses 10% of maximum health per second (non-lethal). Each tick that can be paid in full also grants 10% ult cooldown.
		- Using Living Bomb immediately ends the Unchained state.

		### Talents
		**Outburst**
		- Removed: Pushes no longer ignite enemies (moved to Enfeebling Flames).
		- Added: Increases stagger power by 20%.
		- Added: After a charged attack, the next push also costs half stamina.

		**Chain Reaction**
		- Reworked: Burning enemies hit as the first target of a charged attack explode for 40 damage, applying a weak burn to surrounding enemies (from 40% chance to explode burning enemies on kill).

		**Dissipate**
		- Reduced overcharge vented from blocking to 50% (from 100%).

		**Numb to Pain**
		- Now also grants a stack on any damage taken (from only venting).

		**Enfeebling Flames**
		- Added: Pushes ignite enemies (moved from Outburst).
		- Added: All of Sienna's attacks apply a weak, long lasting burn.

		**Abandon**
		- Reworked: The Unchained state lasts 2.5 seconds, but converts 5% of maximum health into 10% ult cooldown 4 times per second (replaces health to ult at high overcharge).

		**Natural Talent**
		- Added: Grants 40% attack speed and 40% increased healing received during the Unchained state.

		**Fuel for the Fire**
		- Added: Blood Magic generates no overcharge for 15 seconds after using Living Bomb.
		- Living Bomb no longer clears overcharge (still ends the Unchained state).

		**Bomb Balm**
		- Only grants temporary health to nearby allies, no longer to Sienna.

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
local UNCHAINED_MAX_HEALTH_COST = 0.1 -- per second, share of max health
local UNCHAINED_COOLDOWN_PER_SECOND = 0.1
-- life_tap skips damage reduction and damage to overcharge conversion, wounded_dot does not interrupt interaction
local UNCHAINED_BURN_SOURCE = "life_tap"
local UNCHAINED_BURN_TYPE = "wounded_dot"

-- Row 5 col 2 talent (vanilla health to ult at high overcharge) now speeds up the state instead:
-- shorter state, converting a % of max health 4 times per second
local HEALTH_TO_ULT_TALENT = "sienna_unchained_health_to_ult"
local HEALTH_TO_ULT_DURATION = 2.5
local HEALTH_TO_ULT_TICKS_PER_SECOND = 4
local HEALTH_TO_ULT_MAX_HEALTH_COST = 0.05
local HEALTH_TO_ULT_COOLDOWN = 0.1

local function tb_unchained_has_health_to_ult(unit)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	return talent_extension and talent_extension:has_talent(HEALTH_TO_ULT_TALENT) or false
end

-- duration_modifier_func for every sub-buff tied to the state's length
local function tb_unchained_state_duration(unit, sub_buff_template, duration)
	return tb_unchained_has_health_to_ult(unit) and HEALTH_TO_ULT_DURATION or duration
end

-- Ticks 4 times per second (update_frequency), the base passive only acts on every 4th tick.
-- Health goes on the server, the cooldown to the owner (CareerExtension doesn't sync)
mod_api.insert_buff_function("tb_unchained_state_health_to_cooldown_tick", function (unit, buff, params)
	if not Managers.state.network.is_server or not HEALTH_ALIVE[unit] then
		return
	end

	local health_to_ult = tb_unchained_has_health_to_ult(unit)

	buff.tb_tick_count = (buff.tb_tick_count or 0) + 1

	if not health_to_ult and buff.tb_tick_count % HEALTH_TO_ULT_TICKS_PER_SECOND ~= 0 then
		return
	end

	local status_extension = ScriptUnit.has_extension(unit, "status_system")

	if status_extension and status_extension:is_knocked_down() then
		return
	end

	local health_extension = ScriptUnit.has_extension(unit, "health_system")

	if not health_extension then
		return
	end

	local cost = health_extension:get_max_health() * UNCHAINED_MAX_HEALTH_COST
	local cooldown = UNCHAINED_COOLDOWN_PER_SECOND

	if health_to_ult then
		cost = health_extension:get_max_health() * HEALTH_TO_ULT_MAX_HEALTH_COST
		cooldown = HEALTH_TO_ULT_COOLDOWN
	end

	-- Non-lethal: never tick below 1 health. Only a tick paid in full converts into cooldown
	local damage = math.min(cost, health_extension:current_health() - 1)

	if damage <= 0 then
		return
	end

	DamageUtils.add_damage_network(unit, unit, damage, "full", UNCHAINED_BURN_TYPE, nil, Vector3(0, 0, 0), UNCHAINED_BURN_SOURCE, nil, unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)

	if damage >= cost then
		reduce_cooldown_percent_on_owner(unit, cooldown)
	end
end)
-- on_ability_activated procs on every local player's buffs whenever anyone ults (params[1] is the activating unit).
-- Returning true lets remove_on_proc end the whole template (all sub-buffs share the buff id).
mod_api.insert_proc_function("tb_unchained_state_end_on_own_ability", function (owner_unit, buff, params)
	return params[1] == owner_unit
end)
-- no_overcharge_explosion: overcharging again during the state vents instead of exploding or re-entering the state
mod_api.insert_talent_buff_template("bright_wizard", UNCHAINED_STATE_BUFF, {
	icon = "sienna_unchained_passive",
	duration = UNCHAINED_DURATION,
	duration_modifier_func = tb_unchained_state_duration,
	debuff = true,
	max_stacks = 1,
	update_frequency = 1 / HEALTH_TO_ULT_TICKS_PER_SECOND,
	update_func = "tb_unchained_state_health_to_cooldown_tick",
	event = "on_ability_activated",
	buff_func = "tb_unchained_state_end_on_own_ability",
	remove_on_proc = true,
	perks = {
		buff_perks.no_overcharge_explosion,
	},
})
mod_api.insert_text(UNCHAINED_STATE_BUFF, "Aqshy's Blaze")
mod_api.insert_perk_text("tb_bw_3_unchained", "Aqshy's Blaze", string.format("Instead of exploding from overcharge, Sienna can't attack with her ranged weapon for %d seconds, while converting %d%% of maximum health into %d%% ult cooldown per second (non-lethal, only while she has the health to spare). Using Living Bomb ends this state.", UNCHAINED_DURATION, UNCHAINED_MAX_HEALTH_COST * 100, UNCHAINED_COOLDOWN_PER_SECOND * 100))
mod_api.insert_career_perk_descriptions("bw_3", "tb_bw_3_unchained")

-- Natural Talent's stat buffs, entered together with the state (defined here, used by the overcharge hook below)
local NATURAL_TALENT_TALENT = "sienna_unchained_reduced_overcharge"
local NATURAL_TALENT_STATE_BUFF = "tb_sienna_unchained_natural_talent_state"
local NATURAL_TALENT_ATTACK_SPEED = 0.4
local NATURAL_TALENT_HEALING_RECEIVED = 0.4

mod_api.insert_talent_buff_template("bright_wizard", NATURAL_TALENT_STATE_BUFF, {
	{
		duration = UNCHAINED_DURATION,
		duration_modifier_func = tb_unchained_state_duration,
		max_stacks = 1,
		stat_buff = "attack_speed",
		multiplier = NATURAL_TALENT_ATTACK_SPEED,
		event = "on_ability_activated",
		buff_func = "tb_unchained_state_end_on_own_ability",
		remove_on_proc = true,
	},
	-- Read where the heal is applied (server), the state buff is LocalAndServer
	{
		name = "tb_sienna_unchained_natural_talent_state_healing",
		duration = UNCHAINED_DURATION,
		duration_modifier_func = tb_unchained_state_duration,
		max_stacks = 1,
		stat_buff = "healing_received",
		multiplier = NATURAL_TALENT_HEALING_RECEIVED,
	},
})

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
			local buff_system = Managers.state.entity:system("buff_system")
			local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

			buff_system:add_buff_synced(unit, UNCHAINED_STATE_BUFF, BuffSyncType.LocalAndServer)

			if talent_extension and talent_extension:has_talent(NATURAL_TALENT_TALENT) then
				buff_system:add_buff_synced(unit, NATURAL_TALENT_STATE_BUFF, BuffSyncType.LocalAndServer)
			end

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

	Ultimate

]]
local LIVING_BOMB_EXPLOSION = "explosion_bw_unchained_ability"
-- Witch Hunter Captain's Animosity shout (ability_push, radius 10), already in NetworkLookup.explosion_templates
local LIVING_BOMB_STAGGER_EXPLOSION = "victor_captain_activated_ability_stagger"
local FUEL_FOR_THE_FIRE_NO_BLOOD_MAGIC_BUFF = "tb_sienna_unchained_fuel_for_the_fire_no_blood_magic"

mod_api.insert_text("career_active_desc_bw_3", "Sienna vents all overcharge, dealing damage and staggering nearby enemies.")

local function tb_living_bomb_create_explosion(self, explosion_template_name, position, rotation, career_power_level)
	local owner_unit = self._owner_unit
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local explosion_template = ExplosionUtils.get_template(explosion_template_name)
	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
	local damage_source = "career_ability"
	local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
	local damage_source_id = NetworkLookup.damage_sources[damage_source]
	local is_server = self._is_server
	local scale = 1

	if is_server then
		network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	else
		network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	end

	DamageUtils.create_explosion(self._world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, false, owner_unit, career_power_level, false, owner_unit)
end

-- Vanilla career_ability_bw_unchained.lua _run_ability, with:
-- baseline Witch Hunter Captain shout stagger, Bomb Balm allies only,
-- Fuel for the Fire keeps overcharge and stops Blood Magic overcharge
mod:hook_origin(CareerAbilityBWUnchained, "_run_ability", function (self, new_initial_speed)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local position = POSITION_LOOKUP[owner_unit]
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local buff_name = "sienna_unchained_activated_ability"

	buff_extension:add_buff(buff_name, {
		attacker_unit = owner_unit,
	})

	if is_server and bot_player or local_player then
		-- Fuel for the Fire keeps overcharge. The Unchained state still ends: it's removed by on_ability_activated
		-- (start_activated_ability_cooldown below), not by this reset
		if not talent_extension:has_talent("sienna_unchained_activated_ability_power_on_enemies_hit") then
			local overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")

			overcharge_extension:reset()
		end

		career_extension:set_state("sienna_activate_unchained")
	end

	local rotation = Unit.local_rotation(owner_unit, 0)
	local explosion_template_name = LIVING_BOMB_EXPLOSION

	if talent_extension:has_talent("sienna_unchained_activated_ability_fire_aura") then
		explosion_template_name = "explosion_bw_unchained_ability_increased_radius"
	end

	local career_power_level = career_extension:get_career_power_level()
	local heal_type_id = NetworkLookup.heal_types.career_skill

	-- Bomb Balm: heals allies only, not Sienna herself (vanilla heals her too)
	if talent_extension:has_talent("sienna_unchained_activated_ability_temp_health") then
		local radius = 10
		local nearby_player_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.player_units_broadphase

		Broadphase.query(broadphase, POSITION_LOOKUP[owner_unit], radius, nearby_player_units)

		local side_manager = Managers.state.side
		local heal_amount = TalentUtils.get_talent_attribute("sienna_unchained_activated_ability_temp_health", "heal_amount")

		for _, player_unit in pairs(nearby_player_units) do
			if player_unit ~= owner_unit and not side_manager:is_enemy(owner_unit, player_unit) then
				local unit_go_id = network_manager:unit_game_object_id(player_unit)

				if unit_go_id then
					network_transmit:send_rpc_server("rpc_request_heal", unit_go_id, heal_amount, heal_type_id)
				end
			end
		end
	end

	local damage_source_id = NetworkLookup.damage_sources.career_ability

	tb_living_bomb_create_explosion(self, explosion_template_name, position, rotation, career_power_level)
	tb_living_bomb_create_explosion(self, LIVING_BOMB_STAGGER_EXPLOSION, position, rotation, career_power_level)
	career_extension:start_activated_ability_cooldown()

	if talent_extension:has_talent("sienna_unchained_activated_ability_fire_aura") then
		local buffs = {
			"sienna_unchained_activated_ability_pulse",
		}
		local unit_object_id = network_manager:unit_game_object_id(owner_unit)

		if is_server then
			local buff_extension = self._buff_extension

			for i = 1, #buffs do
				local buff_name = buffs[i]
				local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

				buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit,
				})
				network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
			end
		else
			for i = 1, #buffs do
				local buff_name = buffs[i]
				local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

				network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
			end
		end
	end

	if talent_extension:has_talent("sienna_unchained_activated_ability_power_on_enemies_hit") then
		-- Fuel for the Fire: Blood Magic stops generating overcharge. Read server side (apply_buffs_to_damage)
		Managers.state.entity:system("buff_system"):add_buff_synced(owner_unit, FUEL_FOR_THE_FIRE_NO_BLOOD_MAGIC_BUFF, BuffSyncType.LocalAndServer)

		local attack_type_id = NetworkLookup.buff_attack_types.ability
		local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
		local buff_weapon_type_id = NetworkLookup.buff_weapon_types["n/a"]
		local hit_zone_id = NetworkLookup.hit_zones.torso
		local radius = 10
		local nearby_enemy_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.enemy_broadphase

		Broadphase.query(broadphase, position, radius, nearby_enemy_units)

		local target_number = 1
		local side_manager = Managers.state.side

		for _, enemy_unit in pairs(nearby_enemy_units) do
			if Unit.alive(enemy_unit) then
				local hit_unit_id = network_manager:unit_game_object_id(enemy_unit)

				if side_manager:is_enemy(owner_unit, enemy_unit) then
					network_transmit:send_rpc_server("rpc_buff_on_attack", attacker_unit_id, hit_unit_id, attack_type_id, false, hit_zone_id, target_number, buff_weapon_type_id, damage_source_id)
				end
			end
		end
	end

	local inventory_extension = ScriptUnit.has_extension(owner_unit, "inventory_system")
	local lh_weapon_unit, rh_weapon_unit = inventory_extension:get_all_weapon_unit()
	local lh_weapon_extension = lh_weapon_unit and ScriptUnit.has_extension(lh_weapon_unit, "weapon_system")
	local rh_weapon_extension = rh_weapon_unit and ScriptUnit.has_extension(rh_weapon_unit, "weapon_system")
	local has_action = lh_weapon_extension and lh_weapon_extension:has_current_action()

	has_action = has_action or rh_weapon_extension and rh_weapon_extension:has_current_action()

	if not has_action then
		CharacterStateHelper.play_animation_event(owner_unit, "unchained_ability_explosion")
	end

	if is_server and bot_player or local_player then
		local first_person_extension = self._first_person_extension

		if not has_action then
			first_person_extension:animation_event("unchained_ability_explosion")
		end

		first_person_extension:play_hud_sound_event("Play_career_ability_unchained_fire")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_unchained_fire", owner_unit, 0)
	end

	self:_play_vo()
end)

--[[

	Talents

]]
--[[
	Weak burn (Enfeebling Flames, Chain Reaction)
]]
-- Weak, long lasting burn, the burn version of Sister of the Thorn's poison
local WEAK_BURN_BUFF = "tb_sienna_unchained_enfeebling_burn"

NewDamageProfileTemplates.tb_sienna_unchained_enfeebling_burn = table.clone(DamageProfileTemplates.burning_dot)
NewDamageProfileTemplates.tb_sienna_unchained_enfeebling_burn.default_target.power_distribution = {
	attack = 0.03, -- burning_dot 0.07
	impact = 0,
}

mod_api.insert_buff_template(WEAK_BURN_BUFF, {
	apply_buff_func = "start_dot_damage",
	damage_profile = "tb_sienna_unchained_enfeebling_burn",
	damage_type = "burninating",
	duration = 10,
	max_stacks = 1,
	refresh_durations = true,
	time_between_dot_damages = 1,
	update_func = "apply_dot_damage",
	update_start_delay = 1,
	perks = {
		buff_perks.burning,
	},
})

-- Server only
local function tb_apply_weak_burn(owner_unit, target_unit)
	local career_extension = ScriptUnit.extension(owner_unit, "career_system")

	Managers.state.entity:system("buff_system"):add_buff(target_unit, WEAK_BURN_BUFF, owner_unit, false, career_extension:get_career_power_level(), owner_unit)
end

local function tb_is_burning(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	return buff_extension and (buff_extension:has_buff_perk(buff_perks.burning) or buff_extension:has_buff_perk(buff_perks.burning_balefire) or buff_extension:has_buff_perk(buff_perks.burning_elven_magic))
end

--[[
	Outburst
]]
-- Push ignite (sienna_unchained_burn_push perk) moved to Enfeebling Flames. Keeps the push arc after heavy attacks,
-- and adds stagger power plus a half stamina push after heavy attacks.
local OUTBURST_HALF_PUSH_BUFF = "tb_sienna_unchained_outburst_half_push"
local OUTBURST_PUSH_COST_MULTIPLIER = 0.5

mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_burn_push", {
	perks = {},
})
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_outburst_stagger_power", {
	stat_buff = "power_level_impact",
	multiplier = 0.2,
})
mod_api.insert_talent_buff_template("bright_wizard", OUTBURST_HALF_PUSH_BUFF, {
	max_stacks = 1,
})
-- Local only: stamina is spent on the owner, so the server never needs (or consumes) this buff
mod_api.insert_proc_function("tb_sienna_unchained_outburst_half_push_on_heavy", function (owner_unit, buff, params)
	if params[2] ~= "heavy_attack" or not ALIVE[owner_unit] then
		return
	end

	local owner_player = Managers.player:owner(owner_unit)

	if not owner_player or owner_player.remote then
		return
	end

	ScriptUnit.extension(owner_unit, "buff_system"):add_buff(OUTBURST_HALF_PUSH_BUFF)
end)
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_outburst_half_push_on_heavy", {
	event = "on_hit",
	buff_func = "tb_sienna_unchained_outburst_half_push_on_heavy",
})
mod_api.update_talent("bw_unchained", 2, 2, {
	description_values = {},
	buffs = {
		"sienna_unchained_burn_push",
		"tb_sienna_unchained_outburst_stagger_power",
		"tb_sienna_unchained_outburst_half_push_on_heavy",
	},
})
mod_api.insert_text("sienna_unchained_burn_push_desc_2", "Increases stagger power by 20%. After a charged attack, Sienna's next push has 70% increased arc and costs half stamina.")

-- The push start pays its stamina through add_fatigue_points (hooked in Dissipate below), which reads this
-- to tell a push apart from other stamina costs
local tb_outburst_pushing_unit = nil

mod:hook(ActionPushStagger, "client_owner_start_action", function (func, self, ...)
	tb_outburst_pushing_unit = self.owner_unit

	local result = func(self, ...)

	tb_outburst_pushing_unit = nil

	return result
end)

--[[
	Chain Reaction
]]
-- Replaces vanilla's chance to explode burning enemies on kill: a charged attack's first target, if burning, explodes
-- for flat damage and spreads the weak burn. The explosion itself is vanilla's (visuals and stagger, negligible damage).
local CHAIN_REACTION_DAMAGE = 40
local CHAIN_REACTION_RADIUS = 2
local chain_reaction_broadphase_results = {}

-- on_hit procs on the server for every attack type; the talent buffer is "server"
mod_api.insert_proc_function("tb_sienna_unchained_chain_reaction", function (owner_unit, buff, params)
	local hit_unit = params[1]

	if not Managers.state.network.is_server or params[2] ~= "heavy_attack" or params[4] ~= 1 then
		return
	end

	if not ALIVE[owner_unit] or not ALIVE[hit_unit] or not tb_is_burning(hit_unit) then
		return
	end

	local position = POSITION_LOOKUP[hit_unit]
	local career_power_level = ScriptUnit.extension(owner_unit, "career_system"):get_career_power_level()

	Managers.state.entity:system("area_damage_system"):create_explosion(owner_unit, position, Quaternion.identity(), "sienna_unchained_burning_enemies_explosion", 1, "buff", career_power_level, false)

	local side_manager = Managers.state.side
	local ai_broadphase = Managers.state.entity:system("ai_system").broadphase

	table.clear(chain_reaction_broadphase_results)

	local num_nearby_enemies = Broadphase.query(ai_broadphase, position, CHAIN_REACTION_RADIUS, chain_reaction_broadphase_results)

	for i = 1, num_nearby_enemies do
		local enemy_unit = chain_reaction_broadphase_results[i]

		if HEALTH_ALIVE[enemy_unit] and side_manager:is_enemy(owner_unit, enemy_unit) then
			DamageUtils.add_damage_network(enemy_unit, owner_unit, CHAIN_REACTION_DAMAGE, "torso", "burn_shotgun", nil, Vector3(0, 0, 0), "buff", nil, owner_unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)

			if HEALTH_ALIVE[enemy_unit] then
				tb_apply_weak_burn(owner_unit, enemy_unit)
			end
		end
	end
end)
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_chain_reaction", {
	event = "on_hit",
	buff_func = "tb_sienna_unchained_chain_reaction",
})
mod_api.update_talent("bw_unchained", 2, 3, {
	buffs = {
		"tb_sienna_unchained_chain_reaction",
	},
})
mod_api.insert_text("sienna_unchained_exploding_burning_enemies_desc", string.format("Burning enemies hit by the first target of a charged attack explode for %d damage, applying a weak burn to surrounding enemies.", CHAIN_REACTION_DAMAGE))

--[[
	Dissipate Nerf
]]
-- Overcharge dissipation reduce to 50% of vanilla
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

	-- Outburst: half stamina push after a charged attack, consumed by the push
	if tb_outburst_pushing_unit == self.unit and not blocking_weapon_unit then
		local half_push_buff = buff_extension:get_buff_type(OUTBURST_HALF_PUSH_BUFF)

		if half_push_buff then
			fatigue_cost = fatigue_cost * OUTBURST_PUSH_COST_MULTIPLIER

			buff_extension:remove_buff(half_push_buff.id)
		end
	end

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

				amount = amount * 0.5 -- 1 -- Dissipate Nerf

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

--[[
	Numb to Pain
]]
-- Stacks on any damage taken, not only venting damage (vanilla sienna_unchained_add_buff_on_vent_damage).
mod_api.insert_proc_function("tb_sienna_unchained_add_buffs_on_damage_taken", function (owner_unit, buff, params)
	if not ALIVE[owner_unit] then
		return
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local buff_list = buff.template.buffs_to_add

	for i = 1, #buff_list do
		buff_system:add_buff(owner_unit, buff_list[i], owner_unit, false)
	end
end)
mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_reduced_damage_taken_after_venting", {
	buff_func = "tb_sienna_unchained_add_buffs_on_damage_taken",
})
mod_api.update_talent("bw_unchained", 4, 3, {
	description_values = {},
})
mod_api.insert_text("sienna_unchained_reduced_damage_taken_after_venting_desc_2", "Reduces damage taken by 5.0% and overcharge generated by Blood Magic by 16.6% for 15 seconds after venting or taking damage. Stacks 3 times.")

--[[
	Enfeebling Flames
]]
-- Weak burn on every attack, the same one Chain Reaction spreads (tb_apply_weak_burn, defined above).
-- on_hit procs on the server for every attack type; the talent buffer is "server"
mod_api.insert_proc_function("tb_sienna_unchained_enfeebling_burn_on_hit", function (owner_unit, buff, params)
	local hit_unit = params[1]

	if not Managers.state.network.is_server or not ALIVE[owner_unit] or not HEALTH_ALIVE[hit_unit] or not Managers.state.side:is_enemy(owner_unit, hit_unit) then
		return
	end

	tb_apply_weak_burn(owner_unit, hit_unit)
end)
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_enfeebling_burn_on_hit", {
	event = "on_hit",
	buff_func = "tb_sienna_unchained_enfeebling_burn_on_hit",
})
-- Push ignite moved from Outburst, always active. The perk is read in the server's damage calculation
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_enfeebling_burn_push", {
	perks = {
		buff_perks.sienna_unchained_burn_push,
	},
})
mod_api.update_talent("bw_unchained", 5, 1, {
	description_values = {},
	buffs = {
		"tb_sienna_unchained_enfeebling_burn_on_hit",
		"tb_sienna_unchained_enfeebling_burn_push",
	},
})
mod_api.insert_text("sienna_unchained_burning_enemies_reduced_damage_desc", "Burning enemies deal 30% less damage. Pushes ignite enemies. All of Sienna's attacks apply a weak burn lasting 10 seconds.")

--[[
	Abandon
]]
-- Vanilla effect (health to cooldown at high overcharge) removed; the talent now changes the Unchained state
-- (see tb_unchained_has_health_to_ult in the passive section)
mod_api.update_talent("bw_unchained", 5, 2, {
	description_values = {},
	buffs = {},
})
mod_api.insert_text("sienna_unchained_health_to_ult_desc", string.format("The Unchained state lasts %g seconds, but converts %d%% of maximum health into %d%% ult cooldown %d times per second instead (non-lethal, only while she has the health to spare).", HEALTH_TO_ULT_DURATION, HEALTH_TO_ULT_MAX_HEALTH_COST * 100, HEALTH_TO_ULT_COOLDOWN * 100, HEALTH_TO_ULT_TICKS_PER_SECOND))

--[[
	Natural Talent
]]
-- State buffs are added by the overcharge hook in the Unchained passive section
mod_api.update_talent("bw_unchained", 5, 3, {
	description_values = {},
})
mod_api.insert_text("sienna_unchained_reduced_overcharge_desc", string.format("Reduces overcharge generated by 10%%. During the Unchained state, Sienna gains %d%% attack speed and %d%% increased healing received.", NATURAL_TALENT_ATTACK_SPEED * 100, NATURAL_TALENT_HEALING_RECEIVED * 100))

--[[
	Fuel for the Fire
]]
-- Added on Living Bomb (see _run_ability above). -100% overcharge from Blood Magic, clamped at 0 in apply_buffs_to_damage
mod_api.insert_talent_buff_template("bright_wizard", FUEL_FOR_THE_FIRE_NO_BLOOD_MAGIC_BUFF, {
	icon = "sienna_unchained_reduced_overcharge",
	duration = 15,
	max_stacks = 1,
	refresh_durations = true,
	stat_buff = "reduced_overcharge_from_passive",
	multiplier = -1,
})
mod_api.update_talent("bw_unchained", 6, 1, {
	description_values = {},
})
mod_api.insert_text("sienna_unchained_activated_ability_power_on_enemies_hit_desc", "Each enemy hit by Living Bomb increases power by 5% for 15 seconds. Stacking up to 5 times. Blood Magic generates no overcharge for the duration. Living Bomb no longer clears overcharge.")

--[[
	Bomb Balm
]]
-- Allies only, see _run_ability above
mod_api.update_talent("bw_unchained", 6, 3, {
	description_values = {},
})
mod_api.insert_text("sienna_unchained_activated_ability_temp_health_desc", "Living Bomb grants 30 temporary health to nearby allies (not Sienna).")
