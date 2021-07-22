local mod = get_mod("TourneyBalance")

-- Passive Changes
-- Footknight
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive", {
    range = 20
})

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
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff", {
    duration = 20
})

-- Bounty Hunter
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")

-- Pyro
table.insert(PassiveAbilitySettings.bw_1.buffs, "sienna_scholar_overcharge_no_slow")

-- Ultimate Changes

-- Footknight
-- Made Widecharge the standard Footknight ult
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
            num_stacks = 1
        },
        {
            buff_to_remove = "bardin_engineer_pump_buff_long",
            num_stacks = 1
        }
    }
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff", {
    duration = 20,
	remove_buff_func = "bardin_engineer_pump_buff_remove",
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff_long", {
	remove_buff_func = "bardin_engineer_pump_buff_remove",
})
mod:add_buff_function("bardin_engineer_pump_buff_apply", function (unit, buff, params)
	local buff_name = "bardin_engineer_pump_buff"
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
	if talent_extension:has_talent("bardin_engineer_pump_buff_long") then
		buff_name = "bardin_engineer_pump_buff_long"
	end
	local current_stacks = buff_extension:num_buff_type(buff_name)

	if current_stacks then
		buff.current_stacks = current_stacks
	end
end)
mod:add_buff_function("bardin_engineer_pump_buff_remove", function (unit, buff, params)
	local buff_name = "bardin_engineer_pump_buff"
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
	if talent_extension:has_talent("bardin_engineer_pump_buff_long") then
		buff_name = "bardin_engineer_pump_buff_long"
	end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local current_stacks = buff_extension:num_buff_type(buff_name)
	if current_stacks then
		
		for i=1, current_stacks-1 do
			mod:add_buff(unit, buff_name)
		end
	end
end)
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
--mod:hook(SimpleInventoryExtension, "extensions_ready", function (self, world, unit)
--    local additional_inventory = self.initial_inventory.additional_items
--
--    local has_bombardier = self.buff_extension:has_buff_type("bardin_engineer_upgraded_grenades")
--	additional_inventory = additional_inventory or {}
--    if has_bombardier and additional_inventory then
--        table.append(self.initial_inventory.additional_items, {
--            slot_name = "slot_grenade",
--            item_name = "grenade_frag_02"
--        })
--		table.append(self.initial_inventory.additional_items, {
--            slot_name = "slot_grenade",
--            item_name = "grenade_fire_02"
--        })
--	end
--end)


-- Bounty Hunter
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")


-- Battle Wizard Changes
ActivatedAbilitySettings.bw_2[1].cooldown = 60


-- Pyro
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
			local owner_unit = self.owner_unit
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
				network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
			end
		end
	end

	if talent_extension:has_talent("sienna_scholar_activated_ability_heal", "bright_wizard", true) then
		local network_manager = Managers.state.network
		local network_transmit = network_manager.network_transmit
		local unit_id = network_manager:unit_game_object_id(owner_unit)
		local heal_type_id = NetworkLookup.heal_types.career_skill

		network_transmit:send_rpc_server("rpc_request_heal", unit_id, 35, heal_type_id)
	end

	self:_play_vo()
	self.career_extension:start_activated_ability_cooldown()

	local inventory_extension = self.inventory_extension

	inventory_extension:check_and_drop_pickups("career_ability")
end)