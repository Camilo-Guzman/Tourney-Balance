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
		- Never deals friendly fire.

		### Passives
		**Blood Magic / Abandon**
		- Vanilla Abandon is now part of the passive (listed in the passive description next to Blood Magic): at high overcharge, health is drained into ult cooldown (can be lethal).
		- Only grants ult cooldown when health is actually lost (none while invulnerable, e.g. inside Warrior Priest's bubble).
		- The overcharge explosion deals no friendly fire.

		### Talents

		**Dissipate**
		- Reduced overcharge vented from blocking to 50% (from 100%).

		**Numb to Flames** (renamed from Numb to Pain)
		- Now also grants a stack on any damage taken (from only venting).

		**Enfeebling Flames**
		- Reduced damage reduction against burning enemies to 10% (from 30%).
		
		**Abandon (reworked)**
		- Overcharge explosion is near instant (0.1s), deals no damage to Sienna and keeps her overcharge. She then enters Aqshy's Blaze for 2.5 seconds.
		- Converts 5% of maximum health into 10% ult cooldown 4 times per second (lethal; only full ticks of health actually lost grant cooldown, so none while invulnerable, e.g. inside Warrior Priest's bubble). Replaces the passive's lethal drain.
		- Weapons can be swapped during the explosion.
		- Can't attack with the ranged weapon for the duration.
		- Using Living Bomb immediately ends Aqshy's Blaze.

		**Natural Talent**
		- Increased overcharge reduction to 20% (from 10%).

		**Fuel for the Fire**
		- Reduced power per stack to 3% (from 5%).

		**Bomb Balm**
		- Reduced temporary health restored to allies to 15 (from 30).

	$END_TB
]]

--[[

	Passives

]]
--[[
	Abandon (passive, vanilla talent effect)
]]
-- Vanilla Abandon as part of the passive: at high overcharge, drains 5% max health per 0.25s into 10% ult cooldown
-- (lethal). Overcharging explodes as in vanilla. Replaced by the reworked Abandon talent (Aqshy's Blaze state).
local AQSHYS_BLAZE_TALENT = "sienna_unchained_health_to_ult" -- row 5 col 2, vanilla Abandon's slot

local function tb_has_aqshys_blaze(unit)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	return talent_extension and talent_extension:has_talent(AQSHYS_BLAZE_TALENT) or false
end

local ABANDON_TICK_INTERVAL = 0.25
local ABANDON_MAX_HEALTH_COST = 0.05 -- of max health, per tick
local ABANDON_COOLDOWN = 0.1 -- of ult, per tick

-- Vanilla activate_buff_stacks_based_on_overcharge_chunks (owner side), but the drain stack is synced to the server,
-- where health is. Aqshy's Blaze taken: no lethal drain, drop a stack that was already up
mod_api.insert_buff_function("tb_abandon_activate_stacks", function (unit, buff, params)
	local owner_player = Managers.player:owner(unit)

	if not owner_player or owner_player.remote then
		return
	end

	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local template = buff.template
	local buff_to_add = template.buff_to_add
	local num_chunks = 0

	if not tb_has_aqshys_blaze(unit) then
		local overcharge = ScriptUnit.extension(unit, "overcharge_system"):current_overcharge_status()

		num_chunks = math.min(math.floor(overcharge / template.chunk_size), template.max_stacks)
	end

	local stack_ids = buff.stack_ids

	if not stack_ids then
		stack_ids = {}
		buff.stack_ids = stack_ids
	end

	local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

	if num_buff_stacks < num_chunks then
		local buff_system = Managers.state.entity:system("buff_system")

		for i = 1, num_chunks - num_buff_stacks do
			stack_ids[#stack_ids + 1] = buff_system:add_buff_synced(unit, buff_to_add, BuffSyncType.LocalAndServer)
		end
	elseif num_chunks < num_buff_stacks then
		for i = 1, num_buff_stacks - num_chunks do
			buff_extension:remove_buff(table.remove(stack_ids, 1))
		end
	end
end)
mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_health_to_ult", {
	update_func = "tb_abandon_activate_stacks", -- "activate_buff_stacks_based_on_overcharge_chunks"
})

-- Vanilla sienna_unchained_health_to_cooldown_update, moved to the server: cooldown only for health actually lost
-- (none while invulnerable, e.g. Warrior Priest's bubble)
mod_api.insert_buff_function("tb_abandon_health_to_cooldown_update", function (unit, buff, params)
	if not Managers.state.network.is_server or not HEALTH_ALIVE[unit] then
		return
	end

	local t = params.t

	if buff.timer and t < buff.timer then
		return
	end

	buff.timer = t + ABANDON_TICK_INTERVAL

	local career_extension = ScriptUnit.has_extension(unit, "career_system")
	local health_extension = ScriptUnit.has_extension(unit, "health_system")

	if not career_extension or not health_extension or career_extension:current_ability_cooldown_percentage() <= 0 then
		return
	end

	local health_before = health_extension:current_health()
	local damage = health_extension:get_max_health() * ABANDON_MAX_HEALTH_COST

	DamageUtils.add_damage_network(unit, unit, damage, "torso", "life_tap", nil, Vector3(0, 0, 0), "life_tap", nil, unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)

	if health_extension:current_health() < health_before then
		reduce_cooldown_percent_on_owner(unit, ABANDON_COOLDOWN)
	end
end)
mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_health_to_cooldown_buff", {
	update_func = "tb_abandon_health_to_cooldown_update", -- "sienna_unchained_health_to_cooldown_update"
})
mod_api.insert_career_passives("bw_3", {
	"sienna_unchained_health_to_ult",
})
mod_api.insert_text("career_passive_desc_bw_3a", "50% damage taken transferred to Overcharge. When overcharging, Sienna drains 5% health for 10% cooldown reduction every 0.25 seconds.")

--[[
	Abandon: Aqshy's Blaze state
]]
local AQSHYS_BLAZE_BUFF = "tb_sienna_unchained_unchained_state"
local AQSHYS_BLAZE_DURATION = 2.5
local AQSHYS_BLAZE_TICKS_PER_SECOND = 4
local AQSHYS_BLAZE_MAX_HEALTH_COST = 0.05 -- of max health, per tick
local AQSHYS_BLAZE_COOLDOWN = 0.1 -- of ult, per tick
-- life_tap: no damage reduction or Blood Magic. wounded_dot: doesn't interrupt
local AQSHYS_BLAZE_DAMAGE_SOURCE = "life_tap"
local AQSHYS_BLAZE_DAMAGE_TYPE = "wounded_dot"

-- Health on the server, cooldown on the owner
mod_api.insert_buff_function("tb_aqshys_blaze_health_to_cooldown_tick", function (unit, buff, params)
	if not Managers.state.network.is_server or not HEALTH_ALIVE[unit] then
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

	-- Lethal, only full ticks of health actually lost give cooldown (none while invulnerable, e.g. Warrior Priest's bubble)
	local health_before = health_extension:current_health()

	DamageUtils.add_damage_network(unit, unit, cost, "full", AQSHYS_BLAZE_DAMAGE_TYPE, nil, Vector3(0, 0, 0), AQSHYS_BLAZE_DAMAGE_SOURCE, nil, unit, nil, nil, nil, nil, nil, nil, nil, nil, 1)

	-- Damage and health are networkified (quarter steps)
	if health_before - health_extension:current_health() >= DamageUtils.networkify_damage(cost) then
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
	debuff = true,
	max_stacks = 1,
	update_frequency = 1 / AQSHYS_BLAZE_TICKS_PER_SECOND,
	update_func = "tb_aqshys_blaze_health_to_cooldown_tick",
	event = "on_ability_activated",
	buff_func = "tb_aqshys_blaze_end_on_own_ability",
	remove_on_proc = true,
	perks = {
		buff_perks.no_overcharge_explosion,
	},
})
mod_api.insert_text(AQSHYS_BLAZE_BUFF, "Aqshy's Blaze")
-- Takes over vanilla Abandon's talent slot; its effect lives in the state buff above and the explode hook below
mod_api.update_talent("bw_unchained", 5, 2, {
	description_values = {},
	buffs = {},
})
mod_api.insert_text(AQSHYS_BLAZE_TALENT, "Abandon")
mod_api.insert_text("sienna_unchained_health_to_ult_desc", "When overcharging, Sienna explodes immediately and can continue combat without her staff until overcharging ends. Overcharging ends after 2.5 seconds.")

-- Overcharge explosion with Aqshy's Blaze: vanilla state, shortened, then enters Aqshy's Blaze instead of damaging her.
-- Without the talent the explosion is vanilla.
local AQSHYS_BLAZE_EXPLOSION_TIME = 0.1 -- 3

local function tb_keep_overcharge() end

mod:hook_safe(PlayerCharacterStateOverchargeExploding, "on_enter", function (self, unit, input, dt, context, t)
	local career_extension = ScriptUnit.has_extension(unit, "career_system")

	self.tb_aqshys_blaze = career_extension and career_extension:career_name() == "bw_unchained" and tb_has_aqshys_blaze(unit)

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

	buff_system:add_buff_synced(unit, AQSHYS_BLAZE_BUFF, BuffSyncType.LocalAndServer)

	-- Just below max, like a vent
	overcharge_extension:remove_charge(1)
end)

-- No friendly fire from Unchained's overcharge explosion or Living Bomb.
local TB_UNCHAINED_NO_FRIENDLY_FIRE_SOURCES = {
	overcharge = true,
	career_ability = true,
}
local tb_no_friendly_fire_templates = setmetatable({}, { __mode = "k" })

mod:add_create_explosion_wrapper(function (func, world, attacker_unit, impact_position, rotation, explosion_template, scale, damage_source, ...)
	local explosion_data = explosion_template and explosion_template.explosion

	if explosion_data and not explosion_data.no_friendly_fire and TB_UNCHAINED_NO_FRIENDLY_FIRE_SOURCES[damage_source] and ALIVE[attacker_unit] then
		local career_extension = ScriptUnit.has_extension(attacker_unit, "career_system")

		if career_extension and career_extension:career_name() == "bw_unchained" then
			local no_friendly_fire_template = tb_no_friendly_fire_templates[explosion_template]

			if not no_friendly_fire_template then
				no_friendly_fire_template = table.clone(explosion_template)
				no_friendly_fire_template.explosion.no_friendly_fire = true
				tb_no_friendly_fire_templates[explosion_template] = no_friendly_fire_template
			end

			explosion_template = no_friendly_fire_template
		end
	end

	return func(world, attacker_unit, impact_position, rotation, explosion_template, scale, damage_source, ...)
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

	Talents

]]
--[[
	Dissipate
]]
-- Vanilla add_fatigue_points, plus Dissipate 50% vent (Outburst half stamina push disabled)
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
	Numb to Flames (renamed from Numb to Pain)
]]
mod_api.insert_text("sienna_unchained_reduced_damage_taken_after_venting_2", "Numb to Flames")
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
	Enfeebling Flames
]]
-- Burning enemies deal 10% less damage (from 30%). The multiplier is read straight from the buff template in
-- thp_stagger_damage_changes/02_damage_taken_changes.lua
mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_burning_enemies_reduced_damage", {
	multiplier = -0.1, -- -0.3
})
mod_api.update_talent("bw_unchained", 5, 1, { -- update description
	description_values = {
		{
			value_type = "percent",
			value = -0.1, -- buff_tweak_data.sienna_unchained_burning_enemies_reduced_damage.multiplier
		},
	},
})

--[[
	Natural Talent
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_reduced_overcharge", {
	multiplier = -0.2, -- -0.1
})
mod_api.update_talent("bw_unchained", 5, 3, { -- update description
	description_values = {
		{
			value_type = "percent",
			value = -0.2, -- buff_tweak_data.sienna_unchained_reduced_overcharge.multiplier
		},
	},
})

--[[
	Fuel for the Fire
]]
mod_api.update_talent_buff_template("bright_wizard", "sienna_unchained_activated_ability_power_on_enemies_hit_buff", {
	multiplier = 0.03, -- 0.05
})
mod_api.update_talent("bw_unchained", 6, 1, { -- update description
	description_values = {
		{
			value_type = "percent",
			value = 0.03, -- buff_tweak_data.sienna_unchained_activated_ability_power_on_enemies_hit_buff.multiplier
		},
		{
			value = 15, -- buff_tweak_data.sienna_unchained_activated_ability_power_on_enemies_hit_buff.duration
		},
		{
			value = 5, -- buff_tweak_data.sienna_unchained_activated_ability_power_on_enemies_hit_buff.max_stacks
		},
	},
})

--[[
	Bomb Balm
]]
-- Temp health restored to everyone in range on Living Bomb, read through TalentUtils.get_talent_attribute
mod_api.update_talent("bw_unchained", 6, 3, {
	description_values = {
		{
			value = 15, -- 30
		},
	},
	attributes = {
		heal_amount = 15, -- 30
	},
})

