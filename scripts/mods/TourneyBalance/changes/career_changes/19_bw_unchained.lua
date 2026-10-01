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
		- Grants Sienna 30 temporary health (Bomb Balm's self heal, now baseline).

		### Passives
		**Unstable Strength**
		- Added: All attacks apply a weak, long lasting burn above 50% overcharge.

		**Aqshy's Blaze (new)**
		- Overcharge explosion is near instant (0.1s), deals no damage to Sienna and keeps her overcharge. She then enters Aqshy's Blaze for 10 seconds.
		- Weapons can be swapped during the explosion.
		- Can't attack with the ranged weapon for the duration.
		- Loses 10% of maximum health per second (non-lethal). Each tick that can be paid in full also grants 10% ult cooldown.
		- Using Living Bomb immediately ends Aqshy's Blaze.

		### Talents
		**Outburst**
		- Push ignite now applies a weak, long lasting burn.
		- Added: Increases stagger power by 20%.
		- Added: After a charged attack, the next push also costs half stamina.

		**Chain Reaction**
		- Reworked: Burning specials explode when headshot, burning elites when killed by a headshot (from 40% chance for any burning enemy on death).
		- Explosion now uses the overcharge explosion's damage, scaled by Sienna's power (no friendly fire).

		**Dissipate**
		- Reduced overcharge vented from blocking to 50% (from 100%).

		**Numb to Pain**
		- Now also grants a stack on any damage taken (from only venting).

		**Abandon**
		- Reworked: Aqshy's Blaze lasts 2.5 seconds, but converts 5% of maximum health into 10% ult cooldown 4 times per second (replaces health to ult at high overcharge).

		**Natural Talent**
		- Added: Grants 40% attack speed and 40% increased healing received during Aqshy's Blaze.

		**Fuel for the Fire**
		- Added: Blood Magic generates no overcharge for 15 seconds after using Living Bomb.
		- Living Bomb no longer clears overcharge (still ends Aqshy's Blaze).

		**Bomb Balm**
		- Sienna's own temporary health is now baseline on Living Bomb, so Bomb Balm only adds the heal for nearby allies.

	$END_TB
]]

--[[

	Passives

]]
--[[
	Unstable Strength
]]
-- Weak burn, like Sister of the Thorn's poison. Comments: vanilla push ignite (burning_dot_unchained_push) values
local WEAK_BURN_BUFF = "tb_sienna_unchained_weak_burn"

NewDamageProfileTemplates.tb_sienna_unchained_weak_burn = table.clone(DamageProfileTemplates.burning_dot)
NewDamageProfileTemplates.tb_sienna_unchained_weak_burn.default_target.power_distribution = {
	attack = 0.03, -- 0.07 (burning_dot)
	impact = 0, -- 0.05 (burning_dot has no_stagger)
}

mod_api.insert_buff_template(WEAK_BURN_BUFF, {
	apply_buff_func = "start_dot_damage",
	damage_profile = "tb_sienna_unchained_weak_burn", -- "burning_dot"
	damage_type = "burninating",
	duration = 10, -- 6
	max_stacks = 1,
	refresh_durations = true,
	time_between_dot_damages = 1, -- 2
	update_func = "apply_dot_damage",
	update_start_delay = 1, -- 2
	perks = {
		buff_perks.burning,
	},
})

-- All attacks apply the weak burn above 50% overcharge. Owner side, where overcharge lives
local UNSTABLE_STRENGTH_BURN_OVERCHARGE = 0.5
local weak_burn_params = {}

mod_api.insert_proc_function("tb_sienna_unchained_unstable_strength_burn", function (owner_unit, buff, params)
	local hit_unit = params[1]
	local owner_player = Managers.player:owner(owner_unit)

	if not owner_player or owner_player.remote or not HEALTH_ALIVE[hit_unit] then
		return
	end

	local overcharge_extension = ScriptUnit.has_extension(owner_unit, "overcharge_system")

	if not overcharge_extension or overcharge_extension:overcharge_fraction() <= UNSTABLE_STRENGTH_BURN_OVERCHARGE then
		return
	end

	table.clear(weak_burn_params)

	weak_burn_params.attacker_unit = owner_unit
	weak_burn_params.source_attacker_unit = owner_unit
	weak_burn_params.power_level = ScriptUnit.extension(owner_unit, "career_system"):get_career_power_level()

	Managers.state.entity:system("buff_system"):add_buff_synced(hit_unit, WEAK_BURN_BUFF, BuffSyncType.All, weak_burn_params)
end)
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_unstable_strength_burn", {
	event = "on_hit",
	buff_func = "tb_sienna_unchained_unstable_strength_burn",
})
mod_api.insert_career_passives("bw_3", {
	"tb_sienna_unchained_unstable_strength_burn",
})
mod_api.insert_text("career_passive_desc_bw_3b", string.format("Increased melee power on high Overcharge by up to 60%%. All attacks apply a weak burn above %d%% Overcharge.", UNSTABLE_STRENGTH_BURN_OVERCHARGE * 100))

--[[
	Aqshy's Blaze
]]
local AQSHYS_BLAZE_BUFF = "tb_sienna_unchained_unchained_state"
local AQSHYS_BLAZE_DURATION = 10
local AQSHYS_BLAZE_MAX_HEALTH_COST = 0.1 -- of max health, per second
local AQSHYS_BLAZE_COOLDOWN = 0.1 -- of ult, per second
-- life_tap: no damage reduction or Blood Magic. wounded_dot: doesn't interrupt
local AQSHYS_BLAZE_DAMAGE_SOURCE = "life_tap"
local AQSHYS_BLAZE_DAMAGE_TYPE = "wounded_dot"

-- Abandon (row 5 col 2)
local ABANDON_TALENT = "sienna_unchained_health_to_ult"
local ABANDON_DURATION = 2.5
local ABANDON_TICKS_PER_SECOND = 4
local ABANDON_MAX_HEALTH_COST = 0.05 -- per tick
local ABANDON_COOLDOWN = 0.1 -- per tick

local function tb_has_abandon(unit)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	return talent_extension and talent_extension:has_talent(ABANDON_TALENT) or false
end

local function tb_aqshys_blaze_duration(unit, sub_buff_template, duration)
	return tb_has_abandon(unit) and ABANDON_DURATION or duration
end

-- Every 4th tick without Abandon. Health on the server, cooldown on the owner
mod_api.insert_buff_function("tb_aqshys_blaze_health_to_cooldown_tick", function (unit, buff, params)
	if not Managers.state.network.is_server or not HEALTH_ALIVE[unit] then
		return
	end

	local has_abandon = tb_has_abandon(unit)

	buff.tb_tick_count = (buff.tb_tick_count or 0) + 1

	if not has_abandon and buff.tb_tick_count % ABANDON_TICKS_PER_SECOND ~= 0 then
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

	local cost = health_extension:get_max_health() * AQSHYS_BLAZE_MAX_HEALTH_COST
	local cooldown = AQSHYS_BLAZE_COOLDOWN

	if has_abandon then
		cost = health_extension:get_max_health() * ABANDON_MAX_HEALTH_COST
		cooldown = ABANDON_COOLDOWN
	end

	-- Non-lethal, only full ticks give cooldown
	local damage = math.min(cost, health_extension:current_health() - 1)

	if damage <= 0 then
		return
	end

	DamageUtils.add_damage_network(unit, unit, damage, "full", AQSHYS_BLAZE_DAMAGE_TYPE, nil, Vector3(0, 0, 0), AQSHYS_BLAZE_DAMAGE_SOURCE, nil, unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)

	if damage >= cost then
		reduce_cooldown_percent_on_owner(unit, cooldown)
	end
end)

-- Ends on own ult (remove_on_proc)
mod_api.insert_proc_function("tb_aqshys_blaze_end_on_own_ability", function (owner_unit, buff, params)
	return params[1] == owner_unit
end)

-- no_overcharge_explosion: further overcharge vents
mod_api.insert_talent_buff_template("bright_wizard", AQSHYS_BLAZE_BUFF, {
	icon = "sienna_unchained_passive",
	duration = AQSHYS_BLAZE_DURATION,
	duration_modifier_func = tb_aqshys_blaze_duration,
	debuff = true,
	max_stacks = 1,
	update_frequency = 1 / ABANDON_TICKS_PER_SECOND,
	update_func = "tb_aqshys_blaze_health_to_cooldown_tick",
	event = "on_ability_activated",
	buff_func = "tb_aqshys_blaze_end_on_own_ability",
	remove_on_proc = true,
	perks = {
		buff_perks.no_overcharge_explosion,
	},
})
mod_api.insert_text(AQSHYS_BLAZE_BUFF, "Aqshy's Blaze")
mod_api.insert_perk_text("tb_bw_3_unchained", "Aqshy's Blaze", string.format("Overcharging causes Sienna to immediately explode and lose the ability to cast spells for %d seconds. During this time, she drains %d%% health every second to restore %d%% ability cooldown (non-lethal). Using Living Bomb ends this state.", AQSHYS_BLAZE_DURATION, AQSHYS_BLAZE_MAX_HEALTH_COST * 100, AQSHYS_BLAZE_COOLDOWN * 100))
mod_api.insert_career_perk_descriptions("bw_3", "tb_bw_3_unchained")

-- Natural Talent (row 5 col 3), added with the state
local NATURAL_TALENT_TALENT = "sienna_unchained_reduced_overcharge"
local NATURAL_TALENT_STATE_BUFF = "tb_sienna_unchained_natural_talent_state"
local NATURAL_TALENT_ATTACK_SPEED = 0.4
local NATURAL_TALENT_HEALING_RECEIVED = 0.4

mod_api.insert_talent_buff_template("bright_wizard", NATURAL_TALENT_STATE_BUFF, {
	{
		duration = AQSHYS_BLAZE_DURATION,
		duration_modifier_func = tb_aqshys_blaze_duration,
		max_stacks = 1,
		stat_buff = "attack_speed",
		multiplier = NATURAL_TALENT_ATTACK_SPEED,
		event = "on_ability_activated",
		buff_func = "tb_aqshys_blaze_end_on_own_ability",
		remove_on_proc = true,
	},
	{
		name = "tb_sienna_unchained_natural_talent_state_healing",
		duration = AQSHYS_BLAZE_DURATION,
		duration_modifier_func = tb_aqshys_blaze_duration,
		max_stacks = 1,
		stat_buff = "healing_received",
		multiplier = NATURAL_TALENT_HEALING_RECEIVED,
	},
})

-- Overcharge explosion: vanilla state, shortened for Unchained, then enters Aqshy's Blaze instead of damaging her
local AQSHYS_BLAZE_EXPLOSION_TIME = 0.1 -- 3

local function tb_keep_overcharge() end

mod:hook_safe(PlayerCharacterStateOverchargeExploding, "on_enter", function (self, unit, input, dt, context, t)
	local career_extension = ScriptUnit.has_extension(unit, "career_system")

	self.tb_aqshys_blaze = career_extension and career_extension:career_name() == "bw_unchained"

	if self.tb_aqshys_blaze then
		self.explosion_time = t + AQSHYS_BLAZE_EXPLOSION_TIME
	end
end)

-- Weapon swapping (other weapon actions are blocked in start_action below)
mod:hook(PlayerCharacterStateOverchargeExploding, "update", function (func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)

	if self.tb_aqshys_blaze and not self.csm.state_next then
		CharacterStateHelper.update_weapon_actions(t, unit, self.input_extension, self.inventory_extension, self.health_extension)
	end
end)

mod:hook(PlayerCharacterStateOverchargeExploding, "explode", function (func, self)
	if not self.tb_aqshys_blaze then
		return func(self)
	end

	-- inside_inn skips the self damage, a no-op reset keeps overcharge
	local unit = self.unit
	local overcharge_extension = ScriptUnit.extension(unit, "overcharge_system")
	local inside_inn = self.inside_inn

	self.inside_inn = true
	overcharge_extension.reset = tb_keep_overcharge

	func(self)

	self.inside_inn = inside_inn
	overcharge_extension.reset = nil
	overcharge_extension.is_exploding = false

	local buff_system = Managers.state.entity:system("buff_system")
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	buff_system:add_buff_synced(unit, AQSHYS_BLAZE_BUFF, BuffSyncType.LocalAndServer)

	if talent_extension and talent_extension:has_talent(NATURAL_TALENT_TALENT) then
		buff_system:add_buff_synced(unit, NATURAL_TALENT_STATE_BUFF, BuffSyncType.LocalAndServer)
	end

	-- Just below max, like a vent
	overcharge_extension:remove_charge(1)
end)

-- Only wielding is allowed while overcharge is exploding, and on the ranged weapon during Aqshy's Blaze
local function tb_aqshys_blaze_weapon_locked(unit)
	local status_extension = ScriptUnit.has_extension(unit, "status_system")

	if status_extension and status_extension:is_overcharge_exploding() then
		return true
	end

	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not buff_extension or not buff_extension:has_buff_type(AQSHYS_BLAZE_BUFF) then
		return false
	end

	local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")

	return inventory_extension and inventory_extension:get_wielded_slot_name() == "slot_ranged"
end

mod:hook(WeaponUnitExtension, "start_action", function (func, self, action_name, ...)
	if action_name and action_name ~= "action_wield" and tb_aqshys_blaze_weapon_locked(self.owner_unit) then
		return
	end

	return func(self, action_name, ...)
end)

--[[

	Ultimate

]]
-- Witch Hunter Captain's shout
local LIVING_BOMB_STAGGER_EXPLOSION = "victor_captain_activated_ability_stagger"
local FUEL_FOR_THE_FIRE_NO_BLOOD_MAGIC_BUFF = "tb_sienna_unchained_fuel_for_the_fire_no_blood_magic"

mod_api.insert_text("career_active_desc_bw_3", "Sienna vents all overcharge, dealing damage and staggering nearby enemies, and gains 30 temporary health.")

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

-- Vanilla _run_ability, plus WHC shout, baseline self heal, Bomb Balm allies only, Fuel for the Fire changes
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
		-- Fuel for the Fire keeps overcharge
		if not talent_extension:has_talent("sienna_unchained_activated_ability_power_on_enemies_hit") then
			local overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")

			overcharge_extension:reset()
		end

		career_extension:set_state("sienna_activate_unchained")
	end

	local rotation = Unit.local_rotation(owner_unit, 0)
	local explosion_template_name = "explosion_bw_unchained_ability"

	if talent_extension:has_talent("sienna_unchained_activated_ability_fire_aura") then
		explosion_template_name = "explosion_bw_unchained_ability_increased_radius"
	end

	local career_power_level = career_extension:get_career_power_level()
	local heal_type_id = NetworkLookup.heal_types.career_skill
	local heal_amount = TalentUtils.get_talent_attribute("sienna_unchained_activated_ability_temp_health", "heal_amount")
	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)

	-- Bomb Balm's self heal, baseline
	if owner_unit_go_id then
		network_transmit:send_rpc_server("rpc_request_heal", owner_unit_go_id, heal_amount, heal_type_id)
	end

	-- Bomb Balm: allies only
	if talent_extension:has_talent("sienna_unchained_activated_ability_temp_health") then
		local radius = 10
		local nearby_player_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.player_units_broadphase

		Broadphase.query(broadphase, POSITION_LOOKUP[owner_unit], radius, nearby_player_units)

		local side_manager = Managers.state.side

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
		-- Fuel for the Fire: no Blood Magic overcharge
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
	Outburst
]]
local OUTBURST_HALF_PUSH_BUFF = "tb_sienna_unchained_outburst_half_push"
local OUTBURST_PUSH_COST_MULTIPLIER = 0.5

-- Push ignite uses the weak burn (passive section)
BuffTemplates.burning_dot_unchained_push = BuffTemplates[WEAK_BURN_BUFF]

mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_outburst_stagger_power", {
	stat_buff = "power_level_impact",
	multiplier = 0.2,
})
mod_api.insert_talent_buff_template("bright_wizard", OUTBURST_HALF_PUSH_BUFF, {
	max_stacks = 1,
})

-- Owner only
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
mod_api.insert_text("sienna_unchained_burn_push_desc_2", "Increases stagger power by 20%. Pushing ignites enemies for 10 seconds. After a charged attack, Sienna's next push has 70% increased arc and costs half stamina.")

-- Read by add_fatigue_points (Dissipate) to spot push costs
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
-- Explosion: clone of the overcharge explosion (overcharge_explosion_brw) at career power, replacing vanilla's stagger only one
NewDamageProfileTemplates.tb_sienna_unchained_chain_reaction_explosion = table.clone(DamageProfileTemplates.overcharge_explosion)

local chain_reaction_explosion = table.clone(ExplosionTemplates.overcharge_explosion_brw)
local vanilla_chain_reaction_explosion = ExplosionTemplates.sienna_unchained_burning_enemies_explosion.explosion

chain_reaction_explosion.name = "sienna_unchained_burning_enemies_explosion"
chain_reaction_explosion.explosion.effect_name = vanilla_chain_reaction_explosion.effect_name -- vanilla Chain Reaction visual and sound
chain_reaction_explosion.explosion.sound_event_name = vanilla_chain_reaction_explosion.sound_event_name
chain_reaction_explosion.explosion.damage_profile = "tb_sienna_unchained_chain_reaction_explosion"
chain_reaction_explosion.explosion.damage_profile_glance = "tb_sienna_unchained_chain_reaction_explosion" -- vanilla glance is identical
chain_reaction_explosion.explosion.no_friendly_fire = true
chain_reaction_explosion.explosion.power_level = nil -- 500
chain_reaction_explosion.explosion.use_attacker_power_level = true -- career power, passed by tb_chain_reaction_explode
chain_reaction_explosion.explosion.radius = 0.25 -- 5
chain_reaction_explosion.explosion.max_damage_radius = 0.25 -- 4
ExplosionTemplates.sienna_unchained_burning_enemies_explosion = chain_reaction_explosion

-- Replaces vanilla's 40% chance on death: burning specials explode when headshot, burning elites when killed by a headshot.
-- Server only (talent buffer "server")
local function tb_is_headshot(hit_zone)
	return hit_zone == "head" or hit_zone == "neck"
end

local function tb_chain_reaction_explode(owner_unit, unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not ALIVE[owner_unit] or not buff_extension then
		return
	end

	if buff_extension:has_buff_perk(buff_perks.burning) or buff_extension:has_buff_perk(buff_perks.burning_balefire) or buff_extension:has_buff_perk(buff_perks.burning_elven_magic) then
		local career_power_level = ScriptUnit.extension(owner_unit, "career_system"):get_career_power_level()

		Managers.state.entity:system("area_damage_system"):create_explosion(owner_unit, POSITION_LOOKUP[unit], Quaternion.identity(), "sienna_unchained_burning_enemies_explosion", 1, "buff", career_power_level, false)
	end
end

-- params: hit_unit, attack_type, hit_zone
mod_api.insert_proc_function("tb_sienna_unchained_chain_reaction_special", function (owner_unit, buff, params)
	local breed = AiUtils.unit_breed(params[1])

	if Managers.state.network.is_server and breed and breed.special and tb_is_headshot(params[3]) then
		tb_chain_reaction_explode(owner_unit, params[1])
	end
end)
-- params: killing_blow, breed_killed, killed_unit
mod_api.insert_proc_function("tb_sienna_unchained_chain_reaction_elite", function (owner_unit, buff, params)
	if Managers.state.network.is_server and params[2].elite and tb_is_headshot(params[1][DamageDataIndex.HIT_ZONE]) then
		tb_chain_reaction_explode(owner_unit, params[3])
	end
end)
mod_api.insert_talent_buff_template("bright_wizard", "tb_sienna_unchained_chain_reaction", {
	{
		event = "on_hit",
		buff_func = "tb_sienna_unchained_chain_reaction_special",
	},
	{
		name = "tb_sienna_unchained_chain_reaction_elite",
		event = "on_kill",
		buff_func = "tb_sienna_unchained_chain_reaction_elite",
	},
})
mod_api.update_talent("bw_unchained", 2, 3, {
	buffs = {
		"tb_sienna_unchained_chain_reaction",
	},
})
mod_api.insert_text("sienna_unchained_exploding_burning_enemies_desc", "Headshotting a burning special or killing a burning elite with a headshot makes it explode.")

--[[
	Dissipate
]]
-- Vanilla add_fatigue_points, plus Dissipate 50% vent and Outburst half stamina push
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

	-- Outburst
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

				amount = amount * 0.5 -- 1

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
-- Any damage taken, not only venting (server)
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
	Abandon
]]
-- Effect lives in Aqshy's Blaze (ABANDON_*)
mod_api.update_talent("bw_unchained", 5, 2, {
	description_values = {},
	buffs = {},
})
mod_api.insert_text("sienna_unchained_health_to_ult_desc", string.format("Aqshy's Blaze lasts %g seconds, but converts %d%% of maximum health into %d%% ult cooldown %d times per second instead (non-lethal, only while she has the health to spare).", ABANDON_DURATION, ABANDON_MAX_HEALTH_COST * 100, ABANDON_COOLDOWN * 100, ABANDON_TICKS_PER_SECOND))

--[[
	Natural Talent
]]
mod_api.update_talent("bw_unchained", 5, 3, {
	description_values = {},
})
mod_api.insert_text("sienna_unchained_reduced_overcharge_desc", string.format("Reduces overcharge generated by 10%%. During Aqshy's Blaze, Sienna gains %d%% attack speed and %d%% increased healing received.", NATURAL_TALENT_ATTACK_SPEED * 100, NATURAL_TALENT_HEALING_RECEIVED * 100))

--[[
	Fuel for the Fire
]]
-- Added on Living Bomb, clamped at 0 in apply_buffs_to_damage
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
-- See _run_ability
mod_api.update_talent("bw_unchained", 6, 3, {
	description_values = {},
})
mod_api.insert_text("sienna_unchained_activated_ability_temp_health_desc", "Living Bomb also grants 30 temporary health to nearby allies.")
