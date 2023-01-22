local mod = get_mod("TourneyBalance")

-- Passive Changes
-- Footknight
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive", {
    range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura", {
    multiplier = -0.1
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_range", {
    buff_to_add = "markus_knight_passive_defence_aura_range",
	update_func = "activate_buff_on_distance",
	remove_buff_func = "remove_aura_buff",
	range = 40
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura_range", {
    multiplier = -0.1
})
mod:add_text("career_passive_desc_es_2a_2", "Aura that reduces damage taken by 10%")
mod:modify_talent_buff_template("empire_soldier", "markus_knight_guard_defence", {
	buff_to_add = "markus_knight_guard_defence_buff",
	stat_buff = "damage_taken",
	update_func = "activate_buff_on_closest_distance",
	remove_buff_func = "remove_aura_buff",
	range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_guard", {
	buff_to_add = "markus_knight_passive_power_increase_buff",
	stat_buff = "power_level",
	remove_buff_func = "remove_aura_buff",
	icon = "markus_knight_passive_power_increase",
	update_func = "activate_buff_on_closest_distance",
	range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity", {
	buff_to_add = "markus_knight_damage_taken_ally_proximity_buff",
	range = 20,
	update_func = "activate_party_buff_stacks_on_ally_proximity",
	chunk_size = 1,
	max_stacks = 3,
	remove_buff_func = "remove_party_buff_stacks"
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity_buff", {
	multiplier = -0.033
})
mod:add_text("markus_knight_damage_taken_ally_proximity_desc_2", "Increases damage protection from Protective Presence by 3.33%% for each nearby ally")

-- Engineer
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_remove_pump_stacks_fire", {
    remove_buff_stack_data = {
        {
            buff_to_remove = "bardin_engineer_pump_buff",
            num_stacks = 1
        },
        {
            buff_to_remove = "bardin_engineer_pump_buff_long",
            num_stacks = 1
        }
    }
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_remove_pump_stacks", {
    remove_buff_stack_data = {
        {
            buff_to_remove = "bardin_engineer_pump_buff",
            num_stacks = 1
        },
        {
            buff_to_remove = "bardin_engineer_pump_buff_long",
            num_stacks = 1
        }
    }
})
mod:hook_origin(ActionCareerDREngineer, "_fake_activate_ability", function(self, t)
	local buff_extension = self.buff_extension

	if buff_extension then
		self._ammo_expended = self._ammo_expended + self._shot_cost * self._num_projectiles_per_shot

		if buff_extension:has_buff_perk("free_ability") then
			buff_extension:trigger_procs("on_ability_activated", self.owner_unit, 1)
			buff_extension:trigger_procs("on_ability_cooldown_started")

			self._free_ammo_t = t + 4
		elseif self._ammo_expended > self.career_extension:get_max_ability_cooldown() / 2 then
			buff_extension:trigger_procs("on_ability_activated", self.owner_unit, 1)
			buff_extension:trigger_procs("on_ability_cooldown_started")

			self._ammo_expended = 0
		end
	end
end)

-- Bounty Hunter
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")

-- Pyro
table.insert(PassiveAbilitySettings.bw_1.buffs, "sienna_scholar_overcharge_no_slow")

-- Ultimate Changes

-- Footknight
-- Made Widecharge the standard Footknight ult
ActivatedAbilitySettings.es_2[1].cooldown = 40
mod:hook_origin(CareerAbilityESKnight, "_run_ability", function(self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local status_extension = self._status_extension
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
	local buff_name = "markus_knight_activated_ability"

	buff_extension:add_buff(buff_name, {
		attacker_unit = owner_unit
	})

	if talent_extension:has_talent("markus_knight_ability_invulnerability", "empire_soldier", true) then
		buff_name = "markus_knight_ability_invulnerability_buff"

		buff_extension:add_buff(buff_name, {
			attacker_unit = owner_unit
		})

		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if is_server then
			network_transmit:send_rpc_clients("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		end
	end
	
	if talent_extension:has_talent("markus_knight_wide_charge", "empire_soldier", true) then
		buff_name = "markus_knight_heavy_buff"

		buff_extension:add_buff(buff_name, {
			attacker_unit = owner_unit
		})

		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if is_server then
			network_transmit:send_rpc_clients("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		end
	end

	status_extension:set_noclip(true)

	local hold_duration = 0.03
	local windup_duration = 0.15
	status_extension.do_lunge = {
		animation_end_event = "foot_knight_ability_charge_hit",
		allow_rotation = false,
		falloff_to_speed = 5,
		first_person_animation_end_event = "foot_knight_ability_charge_hit",
		dodge = true,
		first_person_animation_event = "foot_knight_ability_charge_start",
		first_person_hit_animation_event = "charge_react",
		damage_start_time = 0.3,
		duration = 1.5,
		initial_speed = 20,
		animation_event = "foot_knight_ability_charge_start",
		lunge_events = self._lunge_events,
		speed_function = function (lunge_time, duration)
			local end_duration = 0.25
			local rush_time = lunge_time - hold_duration - windup_duration
			local rush_duration = duration - hold_duration - windup_duration - end_duration
			local start_speed = 0
			local windup_speed = -3
			local end_speed = 20
			local rush_speed = 15
			local normal_move_speed = 2

			if rush_time <= 0 and hold_duration > 0 then
				local t = -rush_time / (hold_duration + windup_duration)

				return math.lerp(0, -1, t)
			elseif rush_time < windup_duration then
				local t_value = rush_time / windup_duration
				local interpolation_value = math.cos((t_value + 1) * math.pi * 0.5)

				return math.min(math.lerp(windup_speed, start_speed, interpolation_value), rush_speed)
			elseif rush_time < rush_duration then
				local t_value = rush_time / rush_duration
				local acceleration = math.min(rush_time / (rush_duration / 3), 1)
				local interpolation_value = math.cos(t_value * math.pi * 0.5)
				local offset = nil
				local step_time = 0.25

				if rush_time > 8 * step_time then
					offset = 0
				elseif rush_time > 7 * step_time then
					offset = (rush_time - 1.4) / step_time
				elseif rush_time > 6 * step_time then
					offset = (rush_time - 6 * step_time) / step_time
				elseif rush_time > 5 * step_time then
					offset = (rush_time - 5 * step_time) / step_time
				elseif rush_time > 4 * step_time then
					offset = (rush_time - 4 * step_time) / step_time
				elseif rush_time > 3 * step_time then
					offset = (rush_time - 3 * step_time) / step_time
				elseif rush_time > 2 * step_time then
					offset = (rush_time - 2 * step_time) / step_time
				elseif step_time < rush_time then
					offset = (rush_time - step_time) / step_time
				else
					offset = rush_time / step_time
				end

				local offset_multiplier = 1 - offset * 0.4
				local speed = offset_multiplier * acceleration * acceleration * math.lerp(end_speed, rush_speed, interpolation_value)

				return speed
			else
				local t_value = (rush_time - rush_duration) / end_duration
				local interpolation_value = 1 + math.cos((t_value + 1) * math.pi * 0.5)

				return math.lerp(normal_move_speed, end_speed, interpolation_value)
			end
		end,
		damage = {
			offset_forward = 2.4,
			height = 1.8,
			depth_padding = 0.6,
			hit_zone_hit_name = "full",
			ignore_shield = false,
			collision_filter = "filter_explosion_overlap_no_player",
			interrupt_on_max_hit_mass = true,
			power_level_multiplier = 1,
			interrupt_on_first_hit = false,
			damage_profile = "markus_knight_charge",
			width = 2,
			allow_backstab = false,
			stagger_angles = {
				max = 80,
				min = 25
			},
			on_interrupt_blast = {
				allow_backstab = false,
				radius = 3,
				power_level_multiplier = 1,
				hit_zone_hit_name = "full",
				damage_profile = "markus_knight_charge_blast",
				ignore_shield = false,
				collision_filter = "filter_explosion_overlap_no_player"
			}
		}
	}

	status_extension.do_lunge.damage.width = 5
	status_extension.do_lunge.damage.interrupt_on_max_hit_mass = false


	career_extension:start_activated_ability_cooldown()
	self:_play_vo()
end)
--Fix Hero Time not proccing if ally already disabled
mod:add_buff_function("markus_knight_movespeed_on_incapacitated_ally", function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    local side = Managers.state.side.side_by_unit[owner_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local num_units = #player_and_bot_units
    local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
    local buff_system = Managers.state.entity:system("buff_system")
    local template = buff.template
    local buff_to_add = template.buff_to_add
    local disabled_allies = 0

    for i = 1, num_units, 1 do
        local unit = player_and_bot_units[i]
        local status_extension = ScriptUnit.extension(unit, "status_system")
        local is_disabled = status_extension:is_disabled()

        if is_disabled then
            disabled_allies = disabled_allies + 1
        end
    end

	if not buff.disabled_allies then
		buff.disabled_allies = 0
	end

    if buff_extension:has_buff_type(buff_to_add) then
        if disabled_allies <= buff.disabled_allies then
            local buff_id = buff.buff_id

            if buff_id then
                buff_system:remove_server_controlled_buff(owner_unit, buff_id)

                buff.buff_id = nil
            end
        end
    elseif disabled_allies > 0 and disabled_allies > buff.disabled_allies then
        buff.buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
    end

	buff.disabled_allies = disabled_allies
end)



-- Grail Knight Changes
ActivatedAbilitySettings.es_4[1].cooldown = 60

-- Engineer
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_remove_pump_stacks_fire", {
	event = "on_kill",
    remove_buff_stack_data = {
        {
            buff_to_remove = "bardin_engineer_pump_buff",
            num_stacks = 1
        },
        {
            buff_to_remove = "bardin_engineer_pump_buff_long",
            num_stacks = 1
        }
    }
})
mod:add_proc_function("bardin_engineer_remove_pump_stacks_on_fire", function(player, buff, params)
    local player_unit = player.player_unit

    local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
    local wielded_slot = inventory_extension:get_wielded_slot_name()
    if wielded_slot == "slot_career_skill_weapon" then
		ProcFunctions.bardin_engineer_remove_pump_stacks(player, buff, params)
  	end
end)
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_remove_pump_stacks", {
    remove_buff_stack_data = {
        {
            buff_to_remove = "bardin_engineer_pump_buff",
            num_stacks = 0
        },
        {
            buff_to_remove = "bardin_engineer_pump_buff_long",
            num_stacks = 0
        }
    }
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff", {
	on_remove_stack_down = true,
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff_long", {
	on_remove_stack_down = true,
})
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.condition_func = function (action_user, input_extension)
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.chain_condition_func = function (action_user, input_extension)
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.condition_func = function (action_user, input_extension)
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.chain_condition_func = function (action_user, input_extension)
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
mod:hook_origin(ActionCareerDREngineerCharge, "client_owner_post_update", function (self, dt, t, world, can_damage)
	local buff_extension = self.buff_extension
	local current_action = self.current_action
	local interval = current_action.ability_charge_interval
	local charge_timer = self.ability_charge_timer + dt

	if interval <= charge_timer then
		local recharge_instances = math.floor(charge_timer / interval)
		charge_timer = charge_timer - recharge_instances * interval
		local wwise_world = self.wwise_world
		local buff_to_add = self._buff_to_add
		local num_stacks = buff_extension:num_buff_type(buff_to_add)
		local buff_type = buff_extension:get_buff_type(buff_to_add)

		if buff_type then
			if not self.last_pump_time then
				self.last_pump_time = t
			end

			local buff_template = buff_type.template

			if t - self.last_pump_time > 10 and buff_template.max_stacks <= num_stacks then
				Managers.state.achievement:trigger_event("clutch_pump", self.owner_unit)
			end

			self.last_pump_time = t
		end

		WwiseWorld.set_global_parameter(wwise_world, "engineer_charge", num_stacks + recharge_instances)

		for i = 1, recharge_instances, 1 do
			buff_extension:add_buff(buff_to_add)
		end
	end

	self.ability_charge_timer = charge_timer
end)

local function add_item(is_server, player_unit, pickup_type)
	local player_manager = Managers.player
	local player = player_manager:owner(player_unit)

	if player then
		local local_bot_or_human = not player.remote

		if local_bot_or_human then
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
			local career_extension = ScriptUnit.extension(player_unit, "career_system")
			local pickup_settings = AllPickups[pickup_type]
			local slot_name = pickup_settings.slot_name
			local item_name = pickup_settings.item_name
			local slot_data = inventory_extension:get_slot_data(slot_name)
			local can_store_additional_item = inventory_extension:can_store_additional_item(slot_name)

			if slot_data and not can_store_additional_item then
				local item_data = slot_data.item_data
				local item_template = BackendUtils.get_item_template(item_data)
				local pickup_item_to_spawn = nil

				if item_template.name == "wpn_side_objective_tome_01" then
					pickup_item_to_spawn = "tome"
				elseif item_template.name == "wpn_grimoire_01" then
					pickup_item_to_spawn = "grimoire"
				end

				if pickup_item_to_spawn then
					local pickup_spawn_type = "dropped"
					local pickup_name_id = NetworkLookup.pickup_names[pickup_item_to_spawn]
					local pickup_spawn_type_id = NetworkLookup.pickup_spawn_types[pickup_spawn_type]
					local position = POSITION_LOOKUP[player_unit]
					local rotation = Unit.local_rotation(player_unit, 0)

					network_transmit:send_rpc_server("rpc_spawn_pickup", pickup_name_id, position, rotation, pickup_spawn_type_id)
				end
			end

			local item_data = ItemMasterList[item_name]
			local unit_template = nil
			local extra_extension_init_data = {}

			if can_store_additional_item and slot_data then
				inventory_extension:store_additional_item(slot_name, item_data)
			else
				inventory_extension:destroy_slot(slot_name)
				inventory_extension:add_equipment(slot_name, item_data, unit_template, extra_extension_init_data)
			end

			local go_id = Managers.state.unit_storage:go_id(player_unit)
			local slot_id = NetworkLookup.equipment_slots[slot_name]
			local item_id = NetworkLookup.item_names[item_name]
			local weapon_skin_id = NetworkLookup.weapon_skins["n/a"]

			if is_server then
				network_transmit:send_rpc_clients("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
			else
				network_transmit:send_rpc_server("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
			end

			local wielded_slot_name = inventory_extension:get_wielded_slot_name()

			if wielded_slot_name == slot_name then
				CharacterStateHelper.stop_weapon_actions(inventory_extension, "picked_up_object")
				CharacterStateHelper.stop_career_abilities(career_extension, "picked_up_object")
				inventory_extension:wield(slot_name)
			end
		end
	end
end

mod:hook(BulldozerPlayer, "spawn", function (func, self, optional_position, optional_rotation, is_initial_spawn, ammo_melee, ammo_ranged, healthkit, potion, grenade, ability_cooldown_percent_int, additional_items, initial_buff_names)
	local unit = func(self, optional_position, optional_rotation, is_initial_spawn, ammo_melee, ammo_ranged, healthkit, potion, grenade, ability_cooldown_percent_int, additional_items, initial_buff_names)
	
	local is_server = self.is_server
	local buff_extension = 	ScriptUnit.has_extension(unit, "buff_system")
	local has_bombardier = buff_extension:has_buff_type("bardin_engineer_upgraded_grenades")
	if has_bombardier then
		add_item(is_server, unit, "frag_grenade_t2")
		add_item(is_server, unit, "fire_grenade_t2")
	end
	return unit
end)
--Sister of the Thorn
--ActivatedAbilitySettings.we_thornsister[1].cooldown = 60
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_temp_health_funnel_aura_buff", {
	multiplier = 0.25
})


--Shade
--Revert Crit removal from ult
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown", {
--	perk = "guaranteed_crit",
--})
--Waystalker
ActivatedAbilitySettings.we_3[1].cooldown = 50
local sniper_dropoff_ranges = {
	dropoff_start = 30,
	dropoff_end = 50
}
DamageProfileTemplates.arrow_sniper_ability_piercing.max_friendly_damage = 30
DamageProfileTemplates.arrow_sniper_trueflight = {
    charge_value = "projectile",
    no_stagger_damage_reduction_ranged = true,
    critical_strike = {
        attack_armor_power_modifer = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
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
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
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
            1.5,
            1,
            2,
            0.25,
            1,
            0.6
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
        attack = 0.375,
        impact = 0.375
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
	max_friendly_damage = 0
}
Weapons.kerillian_waywatcher_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}


--Removed bloodshot and ult interaction
mod:hook_origin(ActionCareerWEWaywatcher, "client_owner_post_update", function (self, dt, t, world, can_damage)
    local current_action = self.current_action

	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
		self.state = "shooting"
	end

	if self.state == "shooting" then
		local has_extra_shots = self:_update_extra_shots(self.owner_buff_extension, 1)
		local add_spread = not self.extra_buff_shot

		self:fire(current_action, add_spread)

		if has_extra_shots and has_extra_shots > 1 then
			self.state = "waiting_to_shoot"
			self.time_to_shoot = t + 0.1
			self.extra_buff_shot = true
		else
			self.state = "shot"
		end

		local first_person_extension = self.first_person_extension

		if self.current_action.reset_aim_on_attack then
			first_person_extension:reset_aim_assist_multiplier()
		end

		local fire_sound_event = self.current_action.fire_sound_event

		if fire_sound_event then
			local play_on_husk = self.current_action.fire_sound_on_husk

			first_person_extension:play_hud_sound_event(fire_sound_event, nil, play_on_husk)
		end

		if self.current_action.extra_fire_sound_event then
			local position = POSITION_LOOKUP[self.owner_unit]

			WwiseUtils.trigger_position_event(self.world, self.current_action.extra_fire_sound_event, position)
		end
	end
end)

mod:add_proc_function("kerillian_waywatcher_consume_extra_shot_buff", function (player, buff, params)
    local is_career_skill = params[5]
    local should_consume_shot = nil

    if is_career_skill == "RANGED_ABILITY" or is_career_skill == nil then
        should_consume_shot = false
    else
        should_consume_shot = true
    end

    return should_consume_shot
end)

-- Bounty Hunter
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")

--Zealot
--Turn green hp into white hp on ult
mod:hook_safe(CareerAbilityWHZealot, "_run_ability", function(self)
    local player_unit = Managers.player:local_player().player_unit
    local health_extension = ScriptUnit.extension(player_unit, "health_system")
    local perm_health = health_extension:current_permanent_health()
    health_extension:convert_to_temp(perm_health)
end)

-- Battle Wizard Changes
ActivatedAbilitySettings.bw_2[1].cooldown = 60

--Firetrail nerf (Fatshark please)
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod:add_buff_template("sienna_adept_ability_trail", {
    leave_linger_time = 1.5,
    name = "sienna_adept_ability_trail",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    on_max_stacks_overflow_func = "reapply_buff",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    update_start_delay = 0.25,
    death_flow_event = "burn_death",
    time_between_dot_damages = 0.75,
    damage_type = "burninating",
    damage_profile = "burning_dot",
    update_func = "apply_dot_damage",
    max_stacks = 1,
    perk = buff_perks.burning
})
--Firebomb fix
mod:add_buff_template("burning_dot_fire_grenade", {
	duration = 6,
	name = "burning dot",
	end_flow_event = "smoke",
	start_flow_event = "burn",
	death_flow_event = "burn_death",
	 update_start_delay = 0.75,
	remove_buff_func = "remove_dot_damage",
	apply_buff_func = "start_dot_damage",
	time_between_dot_damages = 1,
	damage_type = "burninating",
	damage_profile = "burning_dot_firegrenade",
	update_func = "apply_dot_damage",
	perk = buff_perks.burning
})

DamageProfileTemplates.burning_dot_firegrenade.default_target.armor_modifier.attack[6] = 0.25

-- Pyro
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_release.default.total_time = 0.5
ActivatedAbilitySettings.bw_1[1].cooldown = 40
table.insert(PassiveAbilitySettings.bw_1.buffs, "sienna_scholar_overcharge_no_slow")
mod:hook_origin(ActionCareerBWScholar, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	ActionCareerBWScholar.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	local talent_extension = self.talent_extension
	local owner_unit = self.owner_unit

	if talent_extension:has_talent("sienna_scholar_activated_ability_dump_overcharge", "bright_wizard", true) then
		local player = Managers.player:owner(owner_unit)

		if player.local_player or (self.is_server and player.bot_player) then
			local overcharge_extension = self.overcharge_extension

			overcharge_extension:reset()

			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
			local buff_name = "sienna_scholar_activated_ability_dump_overcharge_buff"
			local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})

			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			if self.is_server then
				network_transmit:send_rpc_clients("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, true)
			end
		end
	end

	if talent_extension:has_talent("sienna_scholar_activated_ability_heal", "bright_wizard", true) then
		local network_manager = Managers.state.network
		local network_transmit = network_manager.network_transmit
		local unit_id = network_manager:unit_game_object_id(owner_unit)
		local heal_type_id = NetworkLookup.heal_types.career_skill

		network_transmit:send_rpc_server("rpc_request_heal", unit_id, 20, heal_type_id)
	end

	self:_play_vo()
	self.career_extension:start_activated_ability_cooldown()

	local inventory_extension = self.inventory_extension

	inventory_extension:check_and_drop_pickups("career_ability")
end)

--Explosion kill credit fix
mod:hook_safe(PlayerProjectileHuskExtension, "init", function(self, extension_init_data)
    self.owner_unit = extension_init_data.owner_unit
end)