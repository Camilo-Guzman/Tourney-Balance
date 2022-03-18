local mod = get_mod("TourneyBalance")

-- Buff and Talent Functions
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.modify_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end

    local original_buff = TalentBuffTemplates[hero_name][buff_name]
    local merged_buff = original_buff
    for i=1, #original_buff.buffs do
        if new_talent_buff.buffs[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs[i])
        elseif original_buff[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs)
        else
            merged_buff.buffs = merge(original_buff.buffs, new_talent_buff.buffs)
        end
    end

    TalentBuffTemplates[hero_name][buff_name] = merged_buff
    BuffTemplates[buff_name] = merged_buff
end
function mod.add_buff_template(self, buff_name, buff_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.add_proc_function(self, name, func)
    ProcFunctions[name] = func
end
function mod.add_buff_function(self, name, func)
    BuffFunctionTemplates.functions[name] = func
end
function mod.modify_talent(self, career_name, tier, index, new_talent_data)
	local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
	local talent_tree_index = career_settings.talent_tree_index

	local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
	local old_talent_id_lookup = TalentIDLookup[old_talent_name]
	local old_talent_id = old_talent_id_lookup.talent_id
	local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = merge(old_talent_data, new_talent_data)
end
function mod.add_buff(self, owner_unit, buff_name)
    if Managers.state.network ~= nil then
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit

        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
        local is_server = Managers.player.is_server

        if is_server then
            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

            buff_extension:add_buff(buff_name)
            network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end
    end
end
function mod.add_talent(self, career_name, tier, index, new_talent_name, new_talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index

    local new_talent_index = #Talents[hero_name] + 1

    Talents[hero_name][new_talent_index] = merge({
        name = new_talent_name,
        description = new_talent_name .. "_desc",
        icon = "icons_placeholder",
        num_ranks = 1,
        buffer = "both",
        requirements = {},
        description_values = {},
        buffs = {},
        buff_data = {},
    }, new_talent_data)

    TalentTrees[hero_name][talent_tree_index][tier][index] = new_talent_name
    TalentIDLookup[new_talent_name] = {
        talent_id = new_talent_index,
        hero_name = hero_name
    }
end

--Fix clients getting too much ult recharge on explosions
mod:add_proc_function("reduce_activated_ability_cooldown", function (player, buff, params)
	local player_unit = player.player_unit

	if Unit.alive(player_unit) then
		local attack_type = params[2]
		local target_number = params[4]
		local career_extension = ScriptUnit.extension(player_unit, "career_system")

		if not attack_type or attack_type == "heavy_attack" or attack_type == "light_attack" then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		elseif attack_type == "aoe" then
            return
		elseif target_number and target_number == 1 then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		end
	end
end)

--Mecenary Talents
mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_ability_cooldown_on_damage_taken", {
    bonus = 0.25
})


-- Footknight Talents
mod:modify_talent_buff_template("empire_soldier", "markus_knight_ability_cooldown_on_damage_taken", {
   bonus = 0.35
})

mod:modify_talent_buff_template("empire_soldier", "markus_knight_power_level_on_stagger_elite_buff", {
    duration = 15
})
mod:modify_talent("es_knight", 2, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.15 --BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.multiplier
        },
        {
            value = 15 --BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.duration
        }
    },
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_attack_speed_on_push_buff", {
    duration = 5
})
mod:modify_talent("es_knight", 2, 3, {
    description_values = {
        {
            value_type = "percent",
            value = 0.15 --BuffTemplates.markus_knight_attack_speed_on_push_buff.multiplier
        },
        {
            value = 5 --BuffTemplates.markus_knight_attack_speed_on_push_buff.duration
        }
    },
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_buff", {
    duration = 0.75,
    multiplier = 3,
	icon = "markus_knight_improved_passive_defence_aura"
})
mod:modify_talent("es_knight", 5, 3, {
    description_values = {
        {
            value_type = "baked_percent",
            value = 3 --BuffTemplates.markus_knight_cooldown_buff.multiplier
        },
        {
            value = 0.75 --BuffTemplates.markus_knight_cooldown_buff.duration
        }
    },
})
--mod:add_buff_function("markus_knight_movespeed_on_incapacitated_ally", function (owner_unit, buff, params)
--    if not Managers.state.network.is_server then
--        return
--    end
--
--    local side = Managers.state.side.side_by_unit[owner_unit]
--    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
--    local num_units = #player_and_bot_units
--    local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
--    local buff_system = Managers.state.entity:system("buff_system")
--    local template = buff.template
--    local buff_to_add = template.buff_to_add
--    local disabled_allies = 0
--    local previous_disabled_allies = buff.previous_disabled_allies
--
--    if not buff.previous_disabled_allies then
--        buff.previous_disabled_allies = 0
--        previous_disabled_allies = 0
--    end
--
--    for i = 1, num_units, 1 do
--        local unit = player_and_bot_units[i]
--        local status_extension = ScriptUnit.extension(unit, "status_system")
--        local is_disabled = status_extension:is_disabled()
--
--        if is_disabled then
--            disabled_allies = disabled_allies + 1
--        end
--    end
--
--    if buff_extension:has_buff_type(buff_to_add) then
--        if disabled_allies < previous_disabled_allies then
--            local buff_id = buff.buff_id
--
--            if buff_id then
--                buff_system:remove_controlled_buff(owner_unit, buff_id)
--
--                buff.buff_id = nil
--            end
--        end
--    elseif disabled_allies > 0 and disabled_allies > previous_disabled_allies then
--        buff.buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
--    end
--end)

mod:add_talent_buff_template("empire_soldier", "markus_knight_heavy_buff", {
    max_stacks = 1,
    stat_buff = "power_level_melee",
    icon = "markus_knight_ability_hit_target_damage_taken",
    multiplier = 0.5,
    duration = 6,
    refresh_durations = true,
})
mod:modify_talent("es_knight", 6, 2, {
    buffs = {
        "markus_knight_heavy_buff",
    },
    description = "rebaltourn_markus_knight_heavy_buff_desc",
    description_values = {},
})
mod:add_text("rebaltourn_markus_knight_heavy_buff_desc", "Valiant Charge increases Melee Power by 50.0%% for 6 seconds.")

--RV
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_passive", {
	buff_func = "gs_bardin_ranger_scavenge_proc"
})

mod:add_proc_function("gs_bardin_ranger_scavenge_proc", function (player, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local player_unit = player.player_unit
	local offset_position_1 = Vector3(0, 0.25, 0)
	local offset_position_2 = Vector3(0, -0.25, 0)

	if Unit.alive(player_unit) then
		local drop_chance = buff.template.drop_chance
		local talent_extension = ScriptUnit.extension(player_unit, "talent_system")
		local result = math.random(1, 100)

		if result < drop_chance * 100 then
			local player_pos = POSITION_LOOKUP[player_unit] + Vector3.up() * 0.1
			local raycast_down = true
			local pickup_system = Managers.state.entity:system("pickup_system")

			if talent_extension:has_talent("bardin_ranger_passive_spawn_potions_or_bombs", "dwarf_ranger", true) then
				local counter = buff.counter
				local spawn_requirement = 9
				if counter == 5 then
					local randomness = math.random(1, 4)
					buff.counter = buff.counter + randomness
				end

				if not counter or counter >= spawn_requirement then
					local potion_result = math.random(1, 5)

					if potion_result >= 1 and potion_result <= 3 then
						local game_mode_key = Managers.state.game_mode:game_mode_key()
						local custom_potions = BardinScavengerCustomPotions[game_mode_key]
						local damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown
						local speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown
						local cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown

						if custom_potions then
							local custom_potion_result = math.random(1, #custom_potions)

							pickup_system:buff_spawn_pickup(custom_potions[custom_potion_result], player_pos, raycast_down)
						elseif (potion_result == 1 and not damage_boost_potion_cooldown) or (damage_boost_potion_cooldown and damage_boost_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("damage_boost_potion", player_pos, raycast_down)
							buff.damage_boost_potion_cooldown = 0
							if speed_boost_potion_cooldown then
								buff.speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown + 1
							else
								buff.speed_boost_potion_cooldown = math.random(1, 2)
							end
							if cooldown_reduction_potion_cooldown then
								buff.cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown + 1
							else
								buff.cooldown_reduction_potion_cooldown = 2
							end
						elseif (potion_result == 2 and not speed_boost_potion_cooldown) or (speed_boost_potion_cooldown and speed_boost_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("speed_boost_potion", player_pos, raycast_down)
							buff.speed_boost_potion_cooldown = 0
							if damage_boost_potion_cooldown then
								buff.damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown + 1
							else
								buff.damage_boost_potion_cooldown = math.random(1, 2)
							end
							if cooldown_reduction_potion_cooldown then
								buff.cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown + 1
							else
								buff.cooldown_reduction_potion_cooldown = 2
							end
						elseif (potion_result == 3 and not cooldown_reduction_potion_cooldown) or (cooldown_reduction_potion_cooldown and cooldown_reduction_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("cooldown_reduction_potion", player_pos, raycast_down)
							buff.cooldown_reduction_potion_cooldown = 0
							if damage_boost_potion_cooldown then
								buff.damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown + 1
							else
								buff.damage_boost_potion_cooldown = math.random(1, 2)
							end
							if speed_boost_potion_cooldown then
								buff.speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown + 1
							else
								buff.speed_boost_potion_cooldown = 2
							end
						end
					elseif potion_result == 4 then
						pickup_system:buff_spawn_pickup("frag_grenade_t1", player_pos, raycast_down)
					elseif potion_result == 5 then
						pickup_system:buff_spawn_pickup("fire_grenade_t1", player_pos, raycast_down)
					end
					buff.counter = 0
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
					buff.counter = buff.counter + 1
				end
			elseif talent_extension:has_talent("bardin_ranger_passive_improved_ammo") then
				pickup_system:buff_spawn_pickup("ammo_ranger_improved", player_pos, raycast_down)
			elseif talent_extension:has_talent("bardin_ranger_passive_ale") then
				local drop_result = math.random(1, 4)

				if drop_result == 1 or drop_result == 2 then
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

--IB
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_ability_cooldown_on_damage_taken", {
    bonus = 0.25
})

mod:hook_origin(CareerAbilityDRIronbreaker, "_run_ability", function(self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
	local career_extension = self._career_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	CharacterStateHelper.play_animation_event(owner_unit, "iron_breaker_active_ability")

	local buffs = {
		"bardin_ironbreaker_activated_ability",
		"bardin_ironbreaker_activated_ability_block_cost",
		"bardin_ironbreaker_activated_ability_attack_intensity_decay_increase"
	}

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_range_and_duration") then
		table.clear(buffs)

		buffs = {
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration",
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration_attack_intensity_decay_increase"
		}
	end

	local targets = FrameTable.alloc_table()
	targets[1] = owner_unit
	local range = 10
	local duration = 10

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_range_and_duration") then
		duration = 10
		range = 15
	end

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_power_buff_allies") then
		local side = Managers.state.side.side_by_unit[owner_unit]
		local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
		local num_targets = #player_and_bot_units

		for i = 1, num_targets, 1 do
			local target_unit = player_and_bot_units[i]
			local ally_position = POSITION_LOOKUP[target_unit]
			local owner_position = POSITION_LOOKUP[owner_unit]
			local distance_squared = Vector3.distance_squared(owner_position, ally_position)
			local range_squared = range * range

			if distance_squared < range_squared then
				local buff_to_add = "bardin_ironbreaker_activated_ability_power_buff"
				local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
				local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")
				local buff_template_name_id = NetworkLookup.buff_templates[buff_to_add]

				if is_server then
					target_buff_extension:add_buff(buff_to_add)
					network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, false)
				else
					network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, true)
				end
			end
		end
	end

	local stagger = true
	local taunt_bosses = talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_bosses")

	if is_server then
		local target_override_extension = ScriptUnit.extension(owner_unit, "target_override_system")

		target_override_extension:taunt(range, duration, stagger, taunt_bosses)
	else
		network_transmit:send_rpc_server("rpc_taunt", owner_unit_id, range, duration, stagger, taunt_bosses)
	end

	local num_targets = #targets

	for i = 1, num_targets, 1 do
		local target_unit = targets[i]
		local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
		local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")

		for j, buff_name in ipairs(buffs) do
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			if is_server then
				target_buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})
				network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, true)
			end
		end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("ability_shout")
		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_ironbreaker_enter")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_bardin_ironbreaker_enter", owner_unit, 0)
	end

	self:_play_vfx()
	self:_play_vo()
	career_extension:start_activated_ability_cooldown()
end)

--Slayer Talents
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_increased_defence", {
	stat_buff = "damage_taken",
	multiplier = -0.2
})
table.insert(PassiveAbilitySettings.dr_2.buffs, "gs_bardin_slayer_increased_defence")
PassiveAbilitySettings.dr_2.perks = {
	{
		display_name = "career_passive_name_dr_2b",
		description = "career_passive_desc_dr_2b_2"
	},
	{
		display_name = "career_passive_name_dr_2c",
		description = "career_passive_desc_dr_2c"
	},
	{
		display_name = "rebaltourn_career_passive_name_dr_2d",
		description = "rebaltourn_career_passive_desc_dr_2d_2"
	}
}
mod:add_text("rebaltourn_career_passive_name_dr_2d", "Juggernaut")
mod:add_text("rebaltourn_career_passive_desc_dr_2d_2", "Reduces damage taken by 20%.")
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_damage_reduction_on_melee_charge_action_buff", {
	multiplier = -0.25
})
mod:modify_talent("dr_slayer", 5, 2, {
	description_values = {
		{
			value_type = "percent",
			value = -0.25
		},
		{
			value = 5
		}
	}
})
mod:modify_talent("dr_slayer", 2, 1, {
	description = "gs_slayer_weapon_combos_desc",
	description_values = {},
	buffs = {
		"bardin_slayer_attack_speed_on_double_one_handed_weapons",
		"bardin_slayer_power_on_double_two_handed_weapons"
	}
})
mod:add_text("gs_slayer_weapon_combos_desc", "Gain 15%% power if wielding 2 2handed weapons. Gain 10%% attackspeed if wielding 2 1handed weapons. Dead talent if not.")


mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance_buff", {
	icon = "victor_zealot_attack_speed_on_health_percent",
	stat_buff = "critical_strike_chance",
	max_stacks = 1,
	bonus = 0.2
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance", {
	activation_health = 0.7,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_crit_chance_buff",
	update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance_buff_2", {
	icon = "victor_zealot_attack_speed_on_health_percent",
	stat_buff = "critical_strike_chance",
	max_stacks = 1,
	bonus = 0.3
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance_2", {
	activation_health = 0.3,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_crit_chance_buff_2",
	update_func = "activate_buff_on_health_percent"
})

mod:modify_talent("dr_slayer", 2, 3, {
	description = "gs_bardin_slayer_crit_chance_desc",
	buffs = {
		"gs_bardin_slayer_crit_chance",
		"gs_bardin_slayer_crit_chance_2"
	}
})
mod:add_text("gs_bardin_slayer_crit_chance_desc", "Gain 10%% extra crit chance if under 70%% total health. Gain 50%% extra crit chance if under 30%% total health.")
mod:add_proc_function("gs_add_bardin_slayer_passive_buff", function(player, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local player_unit = player.player_unit
	local buff_system = Managers.state.entity:system("buff_system")

	if Unit.alive(player_unit) then
		local buff_name = "bardin_slayer_passive_stacking_damage_buff"
		local talent_extension = ScriptUnit.extension(player_unit, "talent_system")
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

		if talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_name = "gs_bardin_slayer_passive_increased_max_stacks"
		end
		buff_system:add_buff(player_unit, buff_name, player_unit, false)

		if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(player_unit, "bardin_slayer_passive_movement_speed", player_unit, false)
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_dodge_range", player_unit, false)
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_dodge_speed", player_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_movement_speed_extra", player_unit, false)
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_dodge_range_extra", player_unit, false)
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_dodge_speed_extra", player_unit, false)
		end

		if talent_extension:has_talent("gs_bardin_slayer_passive_stacking_crit_buff", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_stacking_crit_buff", player_unit, false)
		end

		if talent_extension:has_talent("gs_bardin_slayer_passive_stacking_crit_buff", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_stacking_crit_buff_extra", player_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_cooldown_reduction", player_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_system:add_buff(player_unit, "gs_bardin_slayer_passive_cooldown_reduction_extra", player_unit, false)
		end
	end
end)
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_stacking_damage_buff_on_hit", {
	buff_func = "gs_add_bardin_slayer_passive_buff"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_increased_max_stacks", {
	max_stacks = 4,
	multiplier = 0.1,
	duration = 2,
	refresh_durations = true,
	icon = "bardin_slayer_passive",
	stat_buff = "increased_weapon_damage"
})

mod:add_talent("dr_slayer", 2, 2, "gs_bardin_slayer_passive_increased_max_stacks",{
	description = "bardin_slayer_passive_increased_max_stacks_desc",
	name = "bardin_slayer_passive_increased_max_stacks",
	buffer = "server",
	num_ranks = 1,
	icon = "bardin_slayer_passive_increased_max_stacks",
	description_values = {
		{
			value = 1
		}
	},
	buffs = {}
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_movement_speed_extra", {
	max_stacks = 4,
	multiplier = 1.1,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"move_speed"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_range", {
	max_stacks = 3,
	multiplier = 1.05,
	duration = 2,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"distance_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_range_extra", {
	max_stacks = 4,
	multiplier = 1.05,
	duration = 2,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"distance_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_speed", {
	max_stacks = 3,
	multiplier = 1.05,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"speed_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_speed_extra", {
	max_stacks = 4,
	multiplier = 1.05,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"speed_modifier"
	}
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_stacking_crit_buff", {
	max_stacks = 3,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	refresh_durations = true,
	stat_buff = "power_level",
	duration = 2,
	multiplier = 0.05
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_stacking_crit_buff_extra", {
	max_stacks = 4,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	refresh_durations = true,
	stat_buff = "power_level",
	duration = 2,
	multiplier = 0.05
})
mod:add_talent("dr_slayer", 4, 2, "gs_bardin_slayer_passive_stacking_crit_buff", {
	description = "bardin_slayer_passive_stacking_crit_buff_desc",
	name = "bardin_slayer_passive_stacking_crit_buff_name",
	buffer = "server",
	num_ranks = 1,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	description_values = {},
	buffs = {}
})
mod:add_text("bardin_slayer_passive_stacking_crit_buff_desc", "Each stack of Trophy Hunter increases power by 5%%.")
mod:add_text("bardin_slayer_passive_stacking_crit_buff_name", "Blood Drunk")
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_cooldown_reduction", {
	icon = "bardin_slayer_passive_cooldown_reduction_on_max_stacks",
	stat_buff = "cooldown_regen",
	max_stacks = 3,
	refresh_durations = true,
	duration = 2,
	multiplier = 0.67
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_cooldown_reduction_extra", {
	icon = "bardin_slayer_passive_cooldown_reduction_on_max_stacks",
	stat_buff = "cooldown_regen",
	max_stacks = 4,
	refresh_durations = true,
	duration = 2,
	multiplier = 0.67
})
mod:modify_talent("dr_slayer", 4, 3, {
	description = "gs_bardin_slayer_passive_cooldown_reduction_desc",
	description_values = {}
})
mod:add_text("gs_bardin_slayer_passive_cooldown_reduction_desc", "Each stack of Trophy Hunter increases cooldown regeneration by 67%%.")

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling_buff", {
	icon = "bardin_slayer_push_on_dodge",
	stat_buff = "damage_taken",
	max_stacks = 1,
	multiplier = -0.3
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling", {
	activation_health = 0.3,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_dr_scaling_buff",
	update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling_buff_2", {
	icon = "bardin_slayer_push_on_dodge",
	stat_buff = "damage_taken",
	max_stacks = 1,
	multiplier = -0.3
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling_2", {
	activation_health = 0.5,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_dr_scaling_buff_2",
	update_func = "activate_buff_on_health_percent"
})

mod:modify_talent("dr_slayer", 5, 3, {
	description = "gs_bardin_slayer_push_on_dodge_desc",
	server = "both",
	buffs = {
		"bardin_slayer_push_on_dodge",
		"gs_bardin_slayer_dr_scaling",
		"gs_bardin_slayer_dr_scaling_2"
	}
})
mod:add_text("gs_bardin_slayer_push_on_dodge_desc", "Effective dodges pushes nearby small enemies out of the way. When below 30%% total health you gain 30%% damage reduction. When below 20%% you gain 60%% damage reduction.")

DamageProfileTemplates.slayer_leap_landing_impact.default_target.power_distribution.impact = 1.2


--Engineer Talents
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_melee_power_free_shot_stat", {
	multiplier = 0.20 -- 0.10
})
mod:modify_talent("dr_engineer", 2, 3, {
    description_values = {
		{
			value_type = "percent",
			value = 0.2 --BuffTemplates.bardin_engineer_melee_power_free_shot_stat.multiplier
		},
		{
			value = 5 --BuffTemplates.bardin_engineer_melee_power_free_shot_counter.max_stacks
		},
		{
			value_type = "percent",
			value = 0.15 --BuffTemplates.bardin_engineer_melee_power_range_power_buff.multiplier
		},
		{
			value = 10 --BuffTemplates.bardin_engineer_melee_power_range_power_buff.duration
		}
	},
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_stacking_damage_reduction_buff", {
	max_stacks = 4, -- 3
	multiplier = -0.10 -- -0.05
})
mod:modify_talent("dr_engineer", 5, 1, {
    description_values = {
        {
			value = 5 --BuffTemplates.bardin_engineer_stacking_damage_reduction.update_frequency
		},
		{
			value = 4 --BuffTemplates.bardin_engineer_stacking_damage_reduction_buff.max_stacks
		},
		{
			value_type = "percent",
			value = -0.10 --BuffTemplates.bardin_engineer_stacking_damage_reduction_buff.multiplier
		}
	},
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff_long_attack_speed", {
	multiplier = 0.05
})
mod:modify_talent("dr_engineer", 4, 3, {
		description_values = {
		{
			value_type = "percent",
			value = 0.05 --BuffTemplates.bardin_engineer_pump_buff_long_attack_speed.multiplier
		}
	},
})
mod:modify_talent("dr_engineer", 5, 2, {
	description = "rebaltourn_bardin_engineer_upgraded_grenades_desc",
	description_values = {},
})
mod:add_text("rebaltourn_bardin_engineer_upgraded_grenades_desc", "Bardin's Bombs gain the effect of both regular Bombs and Incendiary Bombs. You also start the mission with 2 bombs.")

mod:modify_talent("dr_engineer", 4, 1, {
		description = "rebaltourn_bardin_engineer_pump_buff_desc",
		description_values = {
		{
			value_type = "percent",
			value = 0.15 --BuffTemplates.bardin_engineer_pump_buff.multiplier
		}
	},
})
mod:add_text("rebaltourn_bardin_engineer_pump_buff_desc", "Upon reaching 5 stacks of Pressure Bardin gains 15%% power.")
BuffTemplates.bardin_engineer_power_on_max_pump_buff.buffs[1].duration = nil
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_pump_buff", {
    max_stack_data = {
        buffs_to_add = {
            "bardin_engineer_pump_exhaustion_buff"
        },
        --[[talent_buffs_to_add = {
            bardin_engineer_power_on_max_pump = {
                buff_to_add = "bardin_engineer_power_on_max_pump_buff",
                rpc_sync = true
            }
        }]]
    },
    update_func = "bardin_engineer_power_on_max_pump"
})
mod:add_buff_function("bardin_engineer_power_on_max_pump", function (unit, buff, params)
    if Unit.alive(unit) then
        local buff_to_add_name = "bardin_engineer_power_on_max_pump_buff"
        local buff_name = "bardin_engineer_pump_buff"
        local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
        if talent_extension:has_talent("bardin_engineer_pump_buff_long") then
            buff_name = "bardin_engineer_pump_buff_long"
        end
        if talent_extension:has_talent("bardin_engineer_power_on_max_pump") then
            local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
            local current_stacks = buff_extension:num_buff_type(buff_name)
            local max_stacks = 5 --tonumber(BuffTemplates[buff_name].buffs[1].max_stacks)
            local has_buff = buff_extension:has_buff_type(buff_to_add_name)

            if current_stacks == max_stacks and not has_buff then
                buff_extension:add_buff(buff_to_add_name)
            elseif current_stacks < max_stacks and has_buff then
                local remove_buff_template = buff_extension:get_buff_type(buff_to_add_name)
                if remove_buff_template then
                    local remove_buff_id = remove_buff_template.id
                    buff_extension:remove_buff(remove_buff_id)
                end
            end
        end
    end
end)
--Increased Super-Armor damage with Gromril-Plated Shot
DamageProfileTemplates.engineer_ability_shot_armor_pierce.armor_modifier_near.attack = {
	1,
	1,
	1,
	1,
	0.5,
	0.4
}
DamageProfileTemplates.engineer_ability_shot_armor_pierce.armor_modifier_far.attack = {
	1,
	1,
	1,
	1,
	0.5,
	0.4
}
--Gromril Shots spread + longer range
Weapons.bardin_engineer_career_skill_weapon_special.default_spread_template = "repeating_handgun"
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.range = 100

-- Shade Talents
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_buff", {
--    multiplier = 0, -- -0.45
--})
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_crit", {
--    duration = 6, --4
--})
--mod:modify_talent("we_shade", 6, 1, {
--    description = "rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2",
--    description_values = {},
--})
--mod:add_text("rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2", "After leaving stealth, Kerillian gains 100%% melee critical strike chance for 6 seconds, but no longer gains a damage bonus on attacking.")
--
---- Vanish Cooldown
--mod:add_proc_function("kerillian_shade_stealth_on_backstab_kill", function (player, buff, params)
--    local player_unit = player.player_unit
--    local local_player = player.local_player
--    local bot_player = player.bot_player
--    local killing_blow_table = params[1]
--    local backstab_multiplier = killing_blow_table[DamageDataIndex.BACKSTAB_MULTIPLIER]
--
--    if Unit.alive(player_unit) and backstab_multiplier and backstab_multiplier > 1 then
--        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
--        local status_extension = ScriptUnit.extension(player_unit, "status_system")
--        local buffs_to_add = {
--            "kerillian_shade_passive_stealth_on_backstab_kill_buff_1",
--			"kerillian_shade_passive_stealth_on_backstab_kill_buff_2",
--            "kerillian_shade_passive_stealth_on_backstab_kill_buff_3",
--            "kerillian_shade_passive_stealth_on_backstab_kill_cooldown",
--        }
--
--        if local_player or (Managers.state.network.is_server and bot_player) then
--            status_extension:set_invisible(true)
--            status_extension:set_noclip(true)
--
--            local network_manager = Managers.state.network
--            local network_transmit = network_manager.network_transmit
--
--            local remove_buff_template = buff_extension:get_buff_type("kerillian_shade_passive_stealth_on_backstab_kill")
--            if remove_buff_template then
--                local remove_buff_id = remove_buff_template.id
--                buff_extension:remove_buff(remove_buff_id)
--            end
--
--            for i = 1, #buffs_to_add, 1 do
--                local buff_name = buffs_to_add[i]
--                local unit_object_id = network_manager:unit_game_object_id(player_unit)
--                local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
--
--                if Managers.state.network.is_server then
--                    buff_extension:add_buff(buff_name, {
--                        attacker_unit = player_unit
--                    })
--                    network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
--                else
--                    network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
--                end
--            end
--        end
--    end
--end)
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill", {
--    event = "on_kill",
--    event_buff = true,
--    buff_func = "kerillian_shade_stealth_on_backstab_kill"
--})
--mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_buff_1", {
--    max_stacks = 1,
--    duration = 0.1,
--    delayed_buff_name = "kerillian_shade_activated_ability_short",
--    buff_after_delay = true,
--    is_cooldown = true,
--    --icon = "kerillian_shade_passive_stealth_on_backstab_kill"
--})
--mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_buff_2", {
--    max_stacks = 1,
--    duration = 0.1,
--    delayed_buff_name = "kerillian_shade_end_activated_ability",
--    buff_after_delay = true,
--    is_cooldown = true,
--    --icon = "kerillian_shade_passive_stealth_on_backstab_kill"
--})
--mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_buff_3", {
--    name = "kerillian_shade_activated_ability_short_1",
--    refresh_durations = true,
--    continuous_effect = "fx/screenspace_shade_skill_01",
--    max_stacks = 1,
--    icon = "kerillian_shade_passive_stealth_on_backstab_kill",
--    duration = 3,
--}, {deactivation_effect = "fx/screenspace_shade_skill_02"})
--mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_cooldown", {
--    max_stacks = 1,
--    duration = 2.9,
--    is_cooldown = true,
--    delayed_buff_name = "kerillian_shade_passive_stealth_on_backstab_kill",
--    buff_after_delay = true,
--    icon = "kerillian_shade_passive_stealth_on_backstab_kill"
--})
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_short", {
--    duration = 2.9,
--    icon = nil,
--    continuous_effect = nil,
--}, {deactivation_effect = nil})
--
--
-- SotT Talents
--mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
--    amount_to_add = 2 -- 3
--})
--mod:modify_talent("we_thornsister", 5, 2, {
--    description_values = {
--        {
--            value = 2
--        }
--    }
--})
--mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_avatar", {
--    max_stack_data = {
--        buffs_to_add = {
--            "kerillian_thorn_sister_avatar_buff_1",
--            "kerillian_thorn_sister_avatar_buff_2",
--            --"kerillian_thorn_sister_avatar_buff_3",
--            --"kerillian_thorn_sister_avatar_buff_4"
--        }
--    }
--})
--mod:modify_talent("we_thornsister", 4, 3, {
--    description = "rebaltourn_kerillian_thorn_sister_avatar_desc",
--    description_values = {},
--})
--mod:add_text("rebaltourn_kerillian_thorn_sister_avatar_desc", "Consuming Radiance grants Kerillian 20%% extra attack speed and move speed for 10 seconds.")
--
--local WALL_SHAPES = table.enum("linear", "radial")
--
--mod:hook_origin(ActionCareerWEThornsisterTargetWall, "client_owner_start_action", function(self, new_action, t, chain_action_data, power_level, action_init_data)
--    action_init_data = action_init_data or {}
--
--	ActionCareerWEThornsisterTargetWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)
--
--	self._valid_segment_positions_idx = 0
--	self._current_segment_positions_idx = 1
--
--	self._weapon_extension:set_mode(false)
--
--	self._target_sim_gravity = new_action.target_sim_gravity
--	self._target_sim_speed = new_action.target_sim_speed
--	self._target_width = new_action.target_width
--	self._target_thickness = new_action.target_thickness
--	self._vertical_rotation = new_action.vertical_rotation
--	self._wall_shape = WALL_SHAPES.linear
--
--	if self.talent_extension:has_talent("kerillian_thorn_sister_explosive_wall") then
--		self._target_thickness = 3
--		self._target_width = 3
--		self._wall_shape = WALL_SHAPES.radial
--		self._num_segmetns_to_check = 3
--		self._radial_center_offset = 0.5
--		self._bot_target_unit = true
--    elseif self.talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
--        self._target_thickness = 4
--		self._target_width = 4
--		self._wall_shape = WALL_SHAPES.radial
--		self._num_segmetns_to_check = 10
--		self._radial_center_offset = 1.2
--		self._bot_target_unit = true
--	else
--		local half_thickness = self._target_thickness / 2
--		self._num_segmetns_to_check = math.floor(self._target_width / half_thickness)
--		self._bot_target_unit = false
--	end
--
--	local max_segments = self._max_segments
--	local segment_count = self._num_segmetns_to_check
--
--	if max_segments < segment_count then
--		local segment_positions = self._segment_positions
--
--		for i = max_segments, segment_count, 1 do
--			for idx = 1, 2, 1 do
--				segment_positions[idx][i + 1] = Vector3Box()
--			end
--		end
--
--		self._max_segments = segment_count
--	end
--
--	self:_update_targeting()
--end)
--
--mod:hook_origin(ActionCareerWEThornsisterWall, "client_owner_start_action", function(self, new_action, t, chain_action_data, power_level, action_init_data)
--	action_init_data = action_init_data or {}
--
--	ActionCareerWEThornsisterWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)
--
--	local target_data = chain_action_data
--	local num_segments = (target_data and target_data.num_segments) or 0
--
--	if num_segments > 0 then
--		self:_play_vo()
--
--		local position = target_data.position:unbox()
--		local rotation = target_data.rotation:unbox()
--		local segments = target_data.segments
--
--		self:_spawn_wall(num_segments, segments, rotation)
--
--		local explosion_template = "we_thornsister_career_skill_wall_explosion"
--		local scale = 1
--		local career_extension = self.career_extension
--		local career_power_level = career_extension:get_career_power_level()
--		local area_damage_system = Managers.state.entity:system("area_damage_system")
--
--		if self.talent_extension:has_talent("kerillian_thorn_sister_explosive_wall") then
--			explosion_template = "we_thornsister_career_skill_explosive_wall_explosion"
--        elseif self.talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
--            explosion_template = "victor_captain_activated_ability_stagger_ping_debuff"
--		elseif self.talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
--			explosion_template = "we_thornsister_career_skill_debuff_wall_spawn_explosion"
--		end
--
--		area_damage_system:create_explosion(self.owner_unit, position, rotation, explosion_template, scale, "career_ability", career_power_level, false)
--		career_extension:start_activated_ability_cooldown()
--	end
--end)
--
--local UNIT_NAMES = {
--	default = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01",
--	bleed = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_bleed",
--	poison = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_poison"
--}
--local WALL_TYPES = table.enum("default", "bleed", "poison")
--SpawnUnitTemplates.thornsister_thorn_wall_unit = {
--	spawn_func = function (source_unit, position, rotation, state_int, group_spawn_index)
--		local UNIT_NAME = UNIT_NAMES[WALL_TYPES.default]
--		local UNIT_TEMPLATE_NAME = "thornsister_thorn_wall_unit"
--		local wall_index = state_int
--		local despawn_sound_event = "career_ability_kerillian_sister_wall_disappear"
--		local life_time = 6
--		local area_damage_params = {
--			radius = 0.3,
--			area_damage_template = "we_thornsister_thorn_wall",
--			invisible_unit = false,
--			nav_tag_volume_layer = "temporary_wall",
--			create_nav_tag_volume = true,
--			aoe_dot_damage = 0,
--			aoe_init_damage = 0,
--			damage_source = "career_ability",
--			aoe_dot_damage_interval = 0,
--			damage_players = false,
--			source_unit = source_unit,
--			life_time = life_time
--		}
--		local props_params = {
--			life_time = life_time,
--			owner_unit = source_unit,
--			despawn_sound_event = despawn_sound_event
--		}
--		local health_params = {
--			health = 20
--		}
--		local buffs_to_add = nil
--		local source_talent_extension = ScriptUnit.has_extension(source_unit, "talent_system")
--
--		if source_talent_extension then
--            if source_talent_extension:has_talent("kerillian_thorn_sister_explosive_wall") or source_talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
--                local life_time_mult = 0.17
--                local life_time_bonus = 0
--                area_damage_params.create_nav_tag_volume = false
--                area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
--                props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
--                UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
--            elseif source_talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
--                UNIT_NAME = UNIT_NAMES[WALL_TYPES.poison]
--            end
--		end
--
--		local extension_init_data = {
--			area_damage_system = area_damage_params,
--			props_system = props_params,
--			health_system = health_params,
--			death_system = {
--				death_reaction_template = "thorn_wall",
--				is_husk = false
--			},
--			hit_reaction_system = {
--				is_husk = false,
--				hit_reaction_template = "level_object"
--			}
--		}
--		local wall_unit = Managers.state.unit_spawner:spawn_network_unit(UNIT_NAME, UNIT_TEMPLATE_NAME, extension_init_data, position, rotation)
--		local random_rotation = Quaternion(Vector3.up(), math.random() * 2 * math.pi - math.pi)
--
--		Unit.set_local_rotation(wall_unit, 0, random_rotation)
--
--		local buff_extension = ScriptUnit.has_extension(wall_unit, "buff_system")
--
--		if buff_extension and buffs_to_add then
--			for i = 1, #buffs_to_add, 1 do
--				buff_extension:add_buff(buffs_to_add[i])
--			end
--		end
--
--		local thorn_wall_extension = ScriptUnit.has_extension(wall_unit, "props_system")
--
--		if thorn_wall_extension then
--			thorn_wall_extension.wall_index = wall_index
--			thorn_wall_extension.group_spawn_index = group_spawn_index
--		end
--	end
--}
-- Bloodrazor Thicket
--DamageProfileTemplates.thorn_wall_explosion_improved_damage.armor_modifier.attack = {
--	0.65,
--	0.325,
--	1.25,
--	0.75,
--	0.5,
--	0.1
--}
--DamageProfileTemplates.thorn_wall_explosion_improved_damage.armor_modifier.impact = {
--	0,
--	0,
--	0,
--	0,
--	0,
--	0
--}
--ExplosionTemplates.victor_captain_activated_ability_stagger_ping_debuff.explosion = {
--    use_attacker_power_level = true,
--    radius = 7,
--    no_prop_damage = true,
--    max_damage_radius = 2,
--    always_hurt_players = false,
--    alert_enemies = true,
--    alert_enemies_radius = 15,
--    attack_template = "drakegun",
--    damage_type = "grenade",
--    damage_profile = "slayer_leap_landing_impact",
--    ignore_attacker_unit = true,
--    no_friendly_fire = true,
--}
--ExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion.explosion.dot_template_name = nil


-- Bounty Hunter Talents
-- Indisctiminate blast cdr upped to 60%
mod:add_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun_cdr", {
    multiplier = -0.6, -- -0.25
    stat_buff = "activated_cooldown",
})
mod:modify_talent("wh_bountyhunter", 6, 3, {
    buffs = {
        "victor_bountyhunter_activated_ability_blast_shotgun_cdr",
    },
})
mod:modify_talent("wh_bountyhunter", 4, 1, {
    description = "rebaltourn_victor_bountyhunter_blessed_combat_desc",
    description_values = {},
})
mod:add_text("rebaltourn_victor_bountyhunter_blessed_combat_desc", "Melee strikes makes up to the next 6 ranged shots deal 15%% more damage. Ranged hits makes up to the next 6 melee strikes deal 15%% more damage.")
PassiveAbilitySettings.wh_2.perks = {
	{
		display_name = "career_passive_name_wh_2b",
		description = "career_passive_desc_wh_2b_2"
	},
	{
		display_name = "career_passive_name_wh_2c",
		description = "career_passive_desc_wh_2c_2"
	},
	{
		display_name = "rebaltourn_career_passive_name_wh_2d",
		description = "rebaltourn_career_passive_desc_wh_2d_2"
	}
}
mod:add_text("rebaltourn_career_passive_name_wh_2d", "Blessed Kill")
mod:add_text("rebaltourn_career_passive_desc_wh_2d_2", "Melee kills reset the cooldown of Blessed Shots.")

-- Battle Wizard Talents
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05 -- -0.1
})
mod:modify_talent("bw_adept", 5, 1, {
    description = "rebaltourn_sienna_adept_damage_reduction_on_ignited_enemy_desc",
    description_values = {
        {
            value_type = "percent",
            value = -0.05 --BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.multiplier
        }
    },
})
mod:add_text("rebaltourn_sienna_adept_damage_reduction_on_ignited_enemy_desc", "Igniting an enemy reduces damage taken by 5%% for 5 seconds. Stacks up to 3 times.")

mod:modify_talent_buff_template("bright_wizard", "sienna_adept_cooldown_reduction_on_burning_enemy_killed", {
    cooldown_reduction = 0.02 --0.03
})
mod:modify_talent("bw_adept", 5, 2, {
    description = "rebaltourn_sienna_adept_cooldown_reduction_on_burning_enemy_killed_desc",
    description_values = {
        {
            value_type = "percent",
            value = 0.02 --BuffTemplates.sienna_adept_cooldown_reduction_on_burning_enemy_killed.cooldown_reduction
        }
    },
})
mod:add_text("rebaltourn_sienna_adept_cooldown_reduction_on_burning_enemy_killed_desc", "Killing a burning enemy reduces the cooldown of Fire Walk by 2%%. 0.5 second cooldown.")

mod:modify_talent("bw_adept", 6, 1, {
    description = "rebaltourn_sienna_adept_activated_ability_cooldown_desc",
})

mod:add_text("rebaltourn_sienna_adept_activated_ability_cooldown_desc", "Reduces the cooldown of Fire Walk by 50%%.")

mod:modify_talent_buff_template("bright_wizard", "sienna_adept_activated_ability_cooldown", {
    multiplier = -0.5 -- -0.3
})

mod:modify_talent("bw_adept", 6, 2, {
    description = "rebaltourn_sienna_adept_activated_ability_explosion_desc",
	buffs = {
        "sienna_adept_activated_ability_explosion_buff"
    },
})
mod:add_text("rebaltourn_sienna_adept_activated_ability_explosion_desc", "Fire Walk explosion radius and burn damage increased. No longer leaves a burning trail. Cooldown of Fire Walk reduced by 30%%.")

mod:add_talent_buff_template("bright_wizard", "sienna_adept_activated_ability_explosion_buff", {
    stat_buff = "activated_cooldown",
	multiplier = -0.3
})

-- Pyromancer Talents
-- Should probs increase by 5% stacks, but this is easier
mod:modify_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_buff", {
    bonus = 0.05 -- 0.1
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_2", {
    buff_to_add = "sienna_scholar_crit_chance_above_health_threshold_2_buff",
	update_func = "activate_buff_on_health_percent",
	activation_health = 0.65
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_2_buff", {
    max_stacks = 1,
    icon = "sienna_scholar_crit_chance_above_health_threshold",
    stat_buff = "critical_strike_chance",
    bonus = 0.05
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_3", {
    buff_to_add = "sienna_scholar_crit_chance_above_health_threshold_3_buff",
	update_func = "activate_buff_on_health_percent",
	activation_health = 0.5
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_3_buff", {
    max_stacks = 1,
    icon = "sienna_scholar_crit_chance_above_health_threshold",
    stat_buff = "critical_strike_chance",
    bonus = 0.05
})
mod:modify_talent("bw_scholar", 2, 3, {
    buffs = {
        "sienna_scholar_crit_chance_above_health_threshold",
        "sienna_scholar_crit_chance_above_health_threshold_2",
        "sienna_scholar_crit_chance_above_health_threshold_3"
    },
    description = "rebaltourn_sienna_scholar_crit_chance_above_health_threshold_desc",
    description_values = {},
})
mod:add_text("rebaltourn_sienna_scholar_crit_chance_above_health_threshold_desc", "Critical strike chance is increased by 5.0%% while above 50.0%% health, increased by 10.0%% while above 65.0%% health and increased by 15.0%% while above 80.0%% health.")

mod:modify_talent("bw_scholar", 5, 2, {
	buffs = {
		"traits_ranged_remove_overcharge_on_crit"
	},
	description = "rebaltourn_traits_ranged_remove_overcharge_on_crit_desc",
	description_values = {},
})
mod:add_text("rebaltourn_traits_ranged_remove_overcharge_on_crit_desc", "Ranged critical hits refund the overcharge cost of the attack.")


mod:add_talent_buff_template("bright_wizard", "sienna_scholar_activated_ability_dump_overcharge_buff", {
    max_stacks = 1,
    icon = "sienna_scholar_activated_ability_dump_overcharge",
    stat_buff = "critical_strike_chance",
    bonus = 0.3,
    duration = 10,
    refresh_durations = true,
})
mod:modify_talent("bw_scholar", 6, 1, {
	description = "rebaltourn_sienna_scholar_activated_ability_dump_overcharge_buff_desc",
	description_values = {},
})
mod:add_text("rebaltourn_sienna_scholar_activated_ability_dump_overcharge_buff_desc", "The Burning Head also removes all overcharge and grants 30%% increased crit chance for 10 seconds.")

PassiveAbilitySettings.bw_1.perks = {
	{
		display_name = "career_passive_name_bw_1b",
		description = "career_passive_desc_bw_1b_2"
	},
	{
		display_name = "rebaltourn_career_passive_name_bw_1c",
		description = "rebaltourn_career_passive_desc_bw_1c_2"
	}
}

mod:add_text("rebaltourn_career_passive_name_bw_1c", "Complete Control")
mod:add_text("rebaltourn_career_passive_desc_bw_1c_2", "No longer slowed from being overcharged.")


