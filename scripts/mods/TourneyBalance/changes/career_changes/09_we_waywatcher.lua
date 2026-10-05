local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	$BEGIN_TB
		---
		## Waystalker
		### Career Ability
		- Damage cleave buff.
		- Prioritizes specials now.
		- Does not consume Bloodshot anymore.

		### Passives
		**Amaranthe**
		- Additionally regen 2 ammo every tick.
		- Heath regen no longer replaces temp health.

		### Talents
		**Drakira's Alacrity**
		- Increased duration to 10s (from 5s).

		**Isha's Embrace**
		- Increased health regen cap to 75% max health (from 50%).

		**Spirit Arrows**
		- Increased cooldown reduction to 10% (from 5%).

		**Ricochet**
		- Holding a shot for 1 second (counted from the start of the draw) grants ricochet projectiles true-flight.
		- Applying true-flight costs 10% ult cooldown drained over 10 seconds and disables your ultimate.
		- Fixed ricocheting after enemy cleave.

		**Asrai Focus**
		- Now grants 20% cooldown regeneration rate (from 20% cooldown reduction).

		**Piercing Shot**
		- Cooldown refund when headshotting enemy works when piercing through team mate first.

		**Loaded Bow**
		- Increased additional Trueshot Volley arrows to +2 (from +1).

		**Kurnous Reward**
		- Reduced ammo regen to 20% (from 30%) per kill.
	$END_TB
]]

--[[
	
	Ultimate

]]
-- Damage cleave buffs
local sniper_dropoff_ranges = {
	dropoff_start = 30,
	dropoff_end = 50
}
DamageProfileTemplates.arrow_sniper_trueflight = {
    charge_value = "projectile",
    no_stagger_damage_reduction_ranged = true,
    critical_strike = {
        attack_armor_power_modifer = {
            1.5, -- 1
            1,
            1,
            0.25, -- 1
            1,
            0.6 -- 0.25
        },
        impact_armor_power_modifer = {
            1,
            1,
            0,
            1,
            1,
            1
        }
    },
    armor_modifier_near = {
        attack = {
            1.5, -- 1
            1,
            1,
            0.25,
            1,
            0.6 -- 0.25
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            1
        }
    },
    armor_modifier_far = {
        attack = {
            1.5, -- 1
            1,
            2,
            0.25,
            1,
            0.6 -- 0.25
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            0
        }
    },
    cleave_distribution = {
        attack = 0.375, -- 0.25
        impact = 0.375 -- 0.25
    },
    default_target = {
        boost_curve_coefficient_headshot = 2.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 0.75,
        attack_template = "arrow_sniper",
        power_distribution_near = {
            attack = 0.5,
            impact = 0.3
        },
        power_distribution_far = {
            attack = 0.5,
            impact = 0.25
        },
        range_dropoff_settings = sniper_dropoff_ranges
    },
	max_friendly_damage = 0 -- Added
}

-- Add Conservative Shooter to Trueshot Volley/Piercing Shot (disabled: its call in the Ricochet hit_enemy hook is commented out)
--[==[
local TB_CONSERVATIVE_SHOOTER_ULT_ITEMS = {
	kerillian_waywatcher_career_skill_weapon = true,
	kerillian_waywatcher_career_skill_weapon_piercing_shot = true,
}

local function tb_conservative_shooter_has_trait(owner_unit)
	local inventory_extension = ScriptUnit.has_extension(owner_unit, "inventory_system")
	local slot_data = inventory_extension and inventory_extension:get_slot_data("slot_ranged")
	local backend_id = slot_data and slot_data.item_data and slot_data.item_data.backend_id
	local backend_item = backend_id and Managers.backend:get_interface("items"):get_item_from_id(backend_id)
	local traits = backend_item and backend_item.traits

	return not not (traits and table.find(traits, "ranged_replenish_ammo_headshot"))
end

local function tb_conservative_shooter_grant_ult_ammo(self, owner_unit, hit_unit, hit_actor)
	if self._tb_conservative_shooter_ammo_granted or not TB_CONSERVATIVE_SHOOTER_ULT_ITEMS[self.item_name] then
		return
	end

	local has_trait = tb_conservative_shooter_has_trait(owner_unit)

	if not has_trait then
		return
	end

	local career_extension = ScriptUnit.has_extension(owner_unit, "career_system")
	local career_name = career_extension and career_extension:career_name()

	if career_name ~= "we_waywatcher" then
		return
	end

	local breed = AiUtils.unit_breed(hit_unit)
	local hit_zone = breed and breed.hit_zones_lookup[Actor.node(hit_actor)]
	local hit_zone_name = hit_zone and hit_zone.name

	if hit_zone_name ~= "head" then
		return
	end

	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local slot_data = inventory_extension:get_slot_data("slot_ranged")
	local ammo_extension = GearUtils.get_ammo_extension(slot_data.right_unit_1p, slot_data.left_unit_1p)

	if ammo_extension then
		ammo_extension:add_ammo_to_reserve(1)
	end

	self._tb_conservative_shooter_ammo_granted = true
end
]==]

--[[

	Passives

]]
--[[
	Amaranthe
	Isha's Embrace
	Spirit Arrows
	Rejuvenating Locus
]]
mod_api.insert_text("career_passive_desc_we_3a_2", "Kerillian regenerates 3 health when below 50.0% health and 2 ammo every 10 seconds. This does not replace temp health.")
mod_api.insert_text("kerillian_waywatcher_improved_regen_desc_2", "Increases Kerillian's health regenerated from Amaranthe by 50%%. Health regeneration caps at 75%%.")
mod_api.insert_text("kerillian_waywatcher_passive_cooldown_restore_desc", "Amaranthe reduces the cooldown of Trueflight Volley by 10.0%%. No longer restores health.")
mod_api.insert_buff_function("update_kerillian_waywatcher_regen", function (unit, buff, params)
    local t = params.t
    local buff_template = buff.template
    local next_heal_tick = buff.next_heal_tick or 0
    local regen_cap = 0.5
    local time_between_heals = buff_template.time_between_heals

    if next_heal_tick < t and Unit.alive(unit) then
        local talent_extension = ScriptUnit.extension(unit, "talent_system")
		
        local cooldown_talent = talent_extension:has_talent("kerillian_waywatcher_passive_cooldown_restore", "wood_elf", true)
		if cooldown_talent then
			local cooldown_reduction = 0.1
			local career_extension = ScriptUnit.extension(unit, "career_system")

			career_extension:reduce_activated_ability_cooldown_percent(cooldown_reduction)
		end

		-- Passive Ammo Regen
		local weapon_slot = "slot_ranged"
		local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
		local slot_data = inventory_extension:get_slot_data(weapon_slot)

		if slot_data then
			local right_unit_1p = slot_data.right_unit_1p
			local left_unit_1p = slot_data.left_unit_1p
			local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
			local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
			local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension

			if ammo_extension then
				local ammo_amount = 2
				ammo_extension:add_ammo_to_reserve(ammo_amount)
			end
		end


        if Managers.state.network.is_server and not cooldown_talent then
            local health_extension = ScriptUnit.extension(unit, "health_system")
            local status_extension = ScriptUnit.extension(unit, "status_system")
            local heal_amount = buff_template.heal_amount

            if talent_extension:has_talent("kerillian_waywatcher_improved_regen", "wood_elf", true) then
                regen_cap = regen_cap * 1.5
                heal_amount = heal_amount * 1.5
            end

            if health_extension:is_alive() and not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() then
                if talent_extension:has_talent("kerillian_waywatcher_group_regen", "wood_elf", true) then
                    local side = Managers.state.side.side_by_unit[unit]

                    if not side then
                        return
                    end

                    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

                    for i = 1, #player_and_bot_units, 1 do
                        if Unit.alive(player_and_bot_units[i]) then
                            local health_extension = ScriptUnit.extension(player_and_bot_units[i], "health_system")
                            local status_extension = ScriptUnit.extension(player_and_bot_units[i], "status_system")

							-- Corrected <= to < check.
                            if health_extension:current_permanent_health_percent() < regen_cap and not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() and health_extension:is_alive() then
								-- Give THP first so it doesn't grant GHP + THP resulting in double regen
								DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "heal_from_proc")
								DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "career_passive")
                            end
                        end
                    end
                elseif health_extension:current_permanent_health_percent() <= regen_cap then
					-- Give THP first so it doesn't grant GHP + THP resulting in double regen
					DamageUtils.heal_network(unit, unit, heal_amount, "heal_from_proc")
					DamageUtils.heal_network(unit, unit, heal_amount, "career_passive")
                end
            end
        end

        buff.next_heal_tick = t + time_between_heals
    end
end)

--[[

	Talents

]]
--[[
	Drakira's Alacrity
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_waywatcher_attack_speed_on_ranged_headshot_buff", {
    duration = 10, -- 5
	multiplier = 0.15
})
mod_api.update_talent("we_waywatcher", 2, 3, {
    description_values = {
        {
            value_type = "baked_percent",
            value = 1.15
        },
        {
            value = 10 -- 5
        }
    }
})

--[[
	Richochet
]]
mod_api.insert_text("kerillian_waywatcher_projectile_ricochet_desc", "Projectiles can ricochet up to 3 times before hitting an enemy. Charging a shot for 1 second causes ricochets to seek out enemies consuming 10%% ability bar.")

-- while this debuff is up the ultimate can't be activated at all
mod_api.insert_buff_template("tb_ricochet_true_flight_cooldown_debuff", {
	stat_buff = "cooldown_regen",
	multiplier = -1.8,
	duration = 10,
	max_stacks = 99,
	debuff = true,
	icon = "kerillian_waywatcher_projectile_ricochet",
	perks = {
		buff_perks.disable_career_ability,
	},
})

-- Ricochet conversion additionally requires the shot to have been held (charged) for >= 0.5 real second before firing.
local TB_RICOCHET_HOLD_TIME_REQUIRED = 1
local tb_ricochet_pending_held_1s = false

-- Center-screen popup + persistent icon while trueflight is imbued
mod_api.insert_buff_template("tb_ricochet_charged_shot_ready", {
	max_stacks = 1,
	duration = 0.5, -- refreshed every frame while charged, so it vanishes right after release
	refresh_durations = true,
	priority_buff = true,
	icon = "kerillian_waywatcher_projectile_ricochet",
})

-- The tension/ready sounds below belong to the Moonfire Bow (we_deus_01) and its SoundBank is normally only loaded while that specific weapon is equipped
local TB_RICOCHET_WWISE_PACKAGE = "wwise/we_deus_01"
local TB_RICOCHET_WWISE_PACKAGE_REFERENCE = "TourneyBalance_ricochet"
local tb_ricochet_wwise_package_loaded = false

local function tb_ricochet_ensure_wwise_package()
	if tb_ricochet_wwise_package_loaded then
		return
	end

	local package_manager = Managers.package

	if package_manager:has_loaded(TB_RICOCHET_WWISE_PACKAGE, TB_RICOCHET_WWISE_PACKAGE_REFERENCE) then
		tb_ricochet_wwise_package_loaded = true

		return
	end

	if not package_manager:is_loading(TB_RICOCHET_WWISE_PACKAGE) then
		local async = true

		package_manager:load(TB_RICOCHET_WWISE_PACKAGE, TB_RICOCHET_WWISE_PACKAGE_REFERENCE, function ()
			tb_ricochet_wwise_package_loaded = true
		end, async)
	end
end

local function tb_ricochet_has_talent(owner_unit)
	local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")
	local has_talent = not not (talent_extension and talent_extension:has_talent("kerillian_waywatcher_projectile_ricochet"))

	if has_talent then
		-- Lazily kicks off the load the first time it's needed; async, so the very first charge in a
		-- session may still miss the sound if the package hasn't finished loading yet.
		tb_ricochet_ensure_wwise_package()
	end

	return has_talent
end

-- Charge-hold audio feedback, reusing Moonfire Bow's own tension loop.
local TB_RICOCHET_TIGHTEN_GRIP_LOOP = "player_combat_weapon_we_deus_01_tighten_grip_loop"
local TB_RICOCHET_TIGHTEN_GRIP_LOOP_STOP = "stop_player_combat_weapon_we_deus_01_tighten_grip_loop"

local function tb_ricochet_start_charge(self, t)
	self._tb_charge_start_t = t
	self._tb_ricochet_tighten_grip_playing = false
end

-- Stops the tension loop unconditionally on finish.
local function tb_ricochet_stop_tighten_grip(self)
	if self._tb_ricochet_tighten_grip_playing then
		self._tb_ricochet_tighten_grip_playing = false

		WwiseWorld.trigger_event(self.wwise_world, TB_RICOCHET_TIGHTEN_GRIP_LOOP_STOP)
		WwiseWorld.trigger_event(self.wwise_world, TB_RICOCHET_TIGHTEN_GRIP_LOOP_STOP)
		WwiseWorld.trigger_event(self.wwise_world, TB_RICOCHET_TIGHTEN_GRIP_LOOP_STOP)
	end
end

-- Show popup buff and buff icon, and start the tension loop, once trueflight is ready
local function tb_ricochet_show_charged_popup(self, t)
	if not self._tb_charge_start_t or t - self._tb_charge_start_t < TB_RICOCHET_HOLD_TIME_REQUIRED then
		return
	end

	local owner_unit = self.owner_unit

	if not tb_ricochet_has_talent(owner_unit) then
		return
	end

	local owner_buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

	if owner_buff_extension then
		owner_buff_extension:add_buff("tb_ricochet_charged_shot_ready")
	end

	if not self._tb_ricochet_tighten_grip_playing then
		self._tb_ricochet_tighten_grip_playing = true

		WwiseWorld.trigger_event(self.wwise_world, TB_RICOCHET_TIGHTEN_GRIP_LOOP)
	end
end

mod:hook_safe(ActionAim, "client_owner_start_action", function (self, new_action, t)
	tb_ricochet_start_charge(self, t)
end)
mod:hook_safe(ActionAim, "client_owner_post_update", function (self, dt, t, world, can_damage)
	tb_ricochet_show_charged_popup(self, t)
end)
-- Longbow/Hagbane/Swiftbow
mod:hook(ActionAim, "finish", function (func, self, reason)
	func(self, reason)

	tb_ricochet_stop_tighten_grip(self)

	return {
		_tb_charge_start_t = self._tb_charge_start_t,
	}
end)
mod:hook_safe(ActionBow, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	self._tb_ricochet_held_1s = not not (chain_action_data and chain_action_data._tb_charge_start_t and (t - chain_action_data._tb_charge_start_t) >= TB_RICOCHET_HOLD_TIME_REQUIRED)
end)
mod:hook(ActionBow, "fire", function (func, self, current_action, add_spread)
	tb_ricochet_pending_held_1s = self._tb_ricochet_held_1s or false

	func(self, current_action, add_spread)

	tb_ricochet_pending_held_1s = false
end)
mod:hook_safe(PlayerProjectileUnitExtension, "init", function (self, extension_init_context, unit, extension_init_data)
	self._tb_ricochet_held_1s = tb_ricochet_pending_held_1s
end)

-- Moonfire Bow (client_owner_start_action/post_update are inherited from ActionAim, so the hooks above
-- already cover its charge; only finish() is overridden and needs its own hook)
mod:hook(ActionAimEnergy, "finish", function (func, self, reason)
	func(self, reason)

	tb_ricochet_stop_tighten_grip(self)

	return {
		_tb_charge_start_t = self._tb_charge_start_t,
	}
end)
mod:hook_safe(ActionBowEnergy, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	self._tb_ricochet_held_1s = not not (chain_action_data and chain_action_data._tb_charge_start_t and (t - chain_action_data._tb_charge_start_t) >= TB_RICOCHET_HOLD_TIME_REQUIRED)
end)

-- Javelin
mod:hook_safe(ActionMeleeStart, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	tb_ricochet_start_charge(self, t)
end)
-- Registered through the dispatcher in TourneyBalance.lua (Timed Block Long also needs this function)
mod:add_melee_start_post_update_function(function (self, dt, t, world)
	tb_ricochet_show_charged_popup(self, t)
end)
mod:hook(ActionMeleeStart, "finish", function (func, self, reason, data)
	func(self, reason, data)

	tb_ricochet_stop_tighten_grip(self)

	return {
		_tb_charge_start_t = self._tb_charge_start_t,
	}
end)
mod:hook_safe(ActionThrownProjectile, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level)
	self._tb_ricochet_held_1s = not not (chain_action_data and chain_action_data._tb_charge_start_t and (t - chain_action_data._tb_charge_start_t) >= TB_RICOCHET_HOLD_TIME_REQUIRED)
end)
mod:hook(ActionThrownProjectile, "_fire", function (func, self, add_spread)
	tb_ricochet_pending_held_1s = self._tb_ricochet_held_1s or false

	func(self, add_spread)

	tb_ricochet_pending_held_1s = false
end)

-- On first ricochet bounce of projectile, convert it into Trueshot Volley (true-flight/homing) arrow:
-- Despawn the original (now-bounced, non-homing) projectile and spawn a trueflight one in its place
local TB_RICOCHET_SPAWN_ITEM = "kerillian_waywatcher_career_skill_weapon"
local TB_RICOCHET_SPAWN_ACTION = "action_career_release"
local TB_RICOCHET_SPAWN_SUB_ACTION = "default"
local tb_ricochet_spawn_speed
local tb_ricochet_spawn_true_flight_template_id

local function tb_ricochet_ensure_spawn_data()
	if tb_ricochet_spawn_speed then
		return
	end

	local weapon_action = WeaponUtils.get_weapon_template(TB_RICOCHET_SPAWN_ITEM).actions[TB_RICOCHET_SPAWN_ACTION][TB_RICOCHET_SPAWN_SUB_ACTION]

	tb_ricochet_spawn_speed = weapon_action.speed
	tb_ricochet_spawn_true_flight_template_id = TrueFlightTemplates[weapon_action.true_flight_template].lookup_id
end

-- Give the spawned trueflight arrow the original bouncing arrow's own damage_profile/aoe (hagbane explosion)
-- Mutating shared table would corrupt every future use of the career skill for the rest of the session.
local tb_ricochet_impact_data_override

mod:hook(PlayerProjectileUnitExtension, "initialize_projectile", function (func, self, projectile_info, impact_data)
	if tb_ricochet_impact_data_override and impact_data then
		self._tb_ricochet_converted = true
		impact_data = table.shallow_copy(impact_data)

		for key, value in pairs(tb_ricochet_impact_data_override) do
			impact_data[key] = value
		end

		self._impact_data = impact_data
		self._impact_damage_profile_id = NetworkLookup.damage_profiles[impact_data.damage_profile or "default"]
	end

	func(self, projectile_info, impact_data)
end)

-- Marks the spawned arrow as ricochet-converted
local tb_ricochet_last_hit_was_converted = false
mod:hook(PlayerProjectileUnitExtension, "hit_enemy", function (func, self, impact_data, hit_unit, hit_position, hit_direction, hit_normal, hit_actor, breed, has_ranged_boost, ranged_boost_curve_multiplier)
	tb_ricochet_last_hit_was_converted = not not self._tb_ricochet_converted

	-- Prevent further ricochets after cleaving enemy
	if not impact_data.bounce_on_level_units then
		self._num_bounces = math.huge
	end

	local owner_unit = self._owner_unit

	-- Conservative shooter on Ult
	--[[
	if owner_unit and ALIVE[owner_unit] and HEALTH_ALIVE[hit_unit] then
		tb_conservative_shooter_grant_ult_ammo(self, owner_unit, hit_unit, hit_actor)
	end
	]]

	-- Note: intentionally not reset back to false after this call
	func(self, impact_data, hit_unit, hit_position, hit_direction, hit_normal, hit_actor, breed, has_ranged_boost, ranged_boost_curve_multiplier)
end)

mod:hook(PlayerProjectileUnitExtension, "hit_level_unit", function (func, self, impact_data, hit_unit, hit_position, hit_direction, hit_normal, hit_actor, level_index, has_ranged_boost, ranged_boost_curve_multiplier)
	local num_bounces_before = self._num_bounces

	func(self, impact_data, hit_unit, hit_position, hit_direction, hit_normal, hit_actor, level_index, has_ranged_boost, ranged_boost_curve_multiplier)

	-- Must run on the owning player's own machine (not "is this the host")
	local owner_player = self._owner_player

	-- impact_data.bounce_on_level_units to prevent career ability bounces (piercing shot) to spawn converted arrow
	if not (owner_player and owner_player.local_player) or impact_data.bounce_on_level_units or self._num_bounces <= num_bounces_before then
		return
	end

	-- Only a shot held (charged) for >= 1s is eligible to convert - see the ActionAim/ActionBow hooks above.
	if not self._tb_ricochet_held_1s then
		return
	end

	local owner_unit = self._owner_unit

	if not owner_unit or not ALIVE[owner_unit] then
		return
	end

	local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

	if not talent_extension or not talent_extension:has_talent("kerillian_waywatcher_projectile_ricochet") then
		return
	end

	-- True-flight imbue requires at least 10% ult cd
	local career_extension = ScriptUnit.extension(owner_unit, "career_system")
	local ability_bar_fill = 1 - career_extension:current_ability_cooldown_percentage(1)

	if ability_bar_fill < 0.1 then
		return
	end

	local locomotion_extension = self.locomotion_extension

	if not locomotion_extension.target_vector_boxed then
		return
	end

	local bounce_dir = Vector3Box.unbox(locomotion_extension.target_vector_boxed)
	local bounce_pos = Vector3Box.unbox(locomotion_extension.initial_position_boxed)
	local rotation = Quaternion.look(bounce_dir)
	local angle = ActionUtils.pitch_from_rotation(rotation)
	local target_unit = nil
	local scale = 1
	local is_critical_strike = self._is_critical_strike
	local power_level = self.power_level
	local impact_data_override = {
		damage_profile = impact_data.damage_profile_prop or impact_data.damage_profile or "default",
		aoe = impact_data.aoe,
		aoe_on_bounce = impact_data.aoe_on_bounce,
	}

	-- Prevent spawning second trueflight arrow.
	self._stop_impacts = true

	Managers.state.unit_spawner:mark_for_deletion(self._projectile_unit)

	local owner_buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

	if owner_buff_extension then
		owner_buff_extension:add_buff("tb_ricochet_true_flight_cooldown_debuff")
	end

	tb_ricochet_ensure_spawn_data()

	-- pcall guarantees the flag always gets cleared, even if the spawn call errors
	tb_ricochet_impact_data_override = impact_data_override

	local success, err = pcall(ActionUtils.spawn_true_flight_projectile, owner_unit, target_unit, tb_ricochet_spawn_true_flight_template_id, bounce_pos, rotation, angle, bounce_dir, tb_ricochet_spawn_speed, TB_RICOCHET_SPAWN_ITEM, TB_RICOCHET_SPAWN_ITEM, TB_RICOCHET_SPAWN_ACTION, TB_RICOCHET_SPAWN_SUB_ACTION, scale, is_critical_strike, power_level)

	tb_ricochet_impact_data_override = nil

	if not success then
		mod:echo("[TourneyBalance] Ricochet true-flight spawn failed: " .. tostring(err))
	end
end)

--[[
	Asrai Focus
]]
-- 20% cooldown regeneration rate instead of 20% cooldown reduction
mod_api.update_talent_buff_template("wood_elf", "kerillian_waywatcher_activated_ability_cooldown", {
	stat_buff = "cooldown_regen", -- activated_cooldown
	multiplier = 0.2, -- -0.2
})
mod_api.update_talent("we_waywatcher", 5, 3, {
	description_values = {},
})
mod_api.insert_text("kerillian_waywatcher_activated_ability_cooldown_desc", "20% cooldown regeneration")

--[[
	Piercing Shot
]]
-- Fix no refund on headshot through teammate
mod_api.insert_proc_function("kerillian_waywatcher_reduce_activated_ability_cooldown", function (owner_unit, buff, params)
    if ALIVE[owner_unit] then
        local hit_zone = params[3]
        local buff_type = params[5]

        -- Prevent ricochet-converted arrows refunding Piercing Shot.
        if buff_type == "RANGED_ABILITY" and (hit_zone == "head" or hit_zone == "neck" or hit_zone == "weakspot") and not tb_ricochet_last_hit_was_converted then
            local career_extension = ScriptUnit.extension(owner_unit, "career_system")

            career_extension:reduce_activated_ability_cooldown_percent(buff.multiplier)
        end
    end
end)

--[[
	Loaded Bow
]]
mod:hook(ActionTrueFlightBow, "client_owner_start_action", function (func, self, new_action, t, chain_action_data, power_level, action_init_data)
	func(self, new_action, t, chain_action_data, power_level, action_init_data)

	local talent_extension = ScriptUnit.has_extension(self.owner_unit, "talent_system")

	if talent_extension:has_talent("kerillian_waywatcher_activated_ability_additional_projectile") then
		self.num_projectiles = self.num_projectiles + 1 -- stacks with original +1; total of +2
	end
end)
mod_api.insert_text("kerillian_waywatcher_activated_ability_additional_projectile_desc", "Trueflight Volley fires 5 arrows.")


--[[
	Kurnous' Reward
]]
-- Fix ricochet-converted trueflight arrows proccing ammo refund on special/elite kill
mod_api.insert_proc_function("kerillian_waywatcher_restore_ammo_on_career_skill_special_kill", function (owner_unit, buff, params)
	local killing_blow_table = params[1]
	local killer_unit = killing_blow_table[DamageDataIndex.ATTACKER]
	local damage_source = killing_blow_table[DamageDataIndex.DAMAGE_SOURCE_NAME]
	local breed_data = params[2]
	local can_trigger

	if breed_data then
		can_trigger = breed_data.elite or breed_data.special
	end

	-- Prevent ricochet refunding Kurnous' Reward.
	if ALIVE[owner_unit] and can_trigger and owner_unit == killer_unit and damage_source == "kerillian_waywatcher_career_skill_weapon" and not tb_ricochet_last_hit_was_converted then
		local buff_template = buff.template
		local weapon_slot = "slot_ranged"
		local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
		local slot_data = inventory_extension:get_slot_data(weapon_slot)
		local right_unit_1p = slot_data.right_unit_1p
		local left_unit_1p = slot_data.left_unit_1p
		local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
		local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
		local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
		local ammo_bonus_fraction = buff_template.ammo_bonus_fraction

		if ammo_extension then
			local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

			ammo_extension:add_ammo_to_reserve(ammo_amount)
		end

		local energy_extension = ScriptUnit.has_extension(owner_unit, "energy_system")

		if energy_extension then
			local max_energy = energy_extension:get_max()
			local energy_amount = ammo_bonus_fraction * max_energy

			energy_extension:add_energy(energy_amount)
		end
	end
end)

mod_api.update_talent_buff_template("wood_elf", "kerillian_waywatcher_activated_ability_restore_ammo_on_career_skill_special_kill", {
	ammo_bonus_fraction = 0.2, -- 0.3
})
mod_api.update_talent("we_waywatcher", 6, 3, {
	description_values = {
		{
			value_type = "percent",
			value = 0.2, -- 0.3
		},
	},
})


