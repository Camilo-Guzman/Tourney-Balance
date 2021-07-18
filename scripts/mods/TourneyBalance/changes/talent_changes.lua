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

-- Footknight Talents
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive", {
    range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_power_level_on_stagger_elite_buff", {
    duration = 15
})
mod:modify_talent("es_knight", 2, 2, {
    description_values = {
        {
            value_type = "percent",
            value = BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.multiplier
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
            value = BuffTemplates.markus_knight_attack_speed_on_push_buff.multiplier
        },
        {
            value = 5 --BuffTemplates.markus_knight_attack_speed_on_push_buff.duration
        }
    },
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_buff", {
    duration = 0.75,
    multiplier = 3,
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

--Made Widecharge the standard Footknight ult
mod:hook(CareerAbilityESKnight, "_run_ability", function(func, self)
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

--Engineer Talents
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


-- Shade Talents
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_buff", {
    multiplier = 0, -- -0.45
})
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_crit", {
    duration = 6, --4
})
mod:modify_talent("we_shade", 6, 1, {
    description = "rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2",
    description_values = {},
})
mod:add_text("rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2", "After leaving stealth, Kerillian gains 100%% melee critical strike chance for 6 seconds, but no longer gains a damage bonus on attacking.")

-- Vanish Cooldown
mod:add_proc_function("kerillian_shade_stealth_on_backstab_kill", function (player, buff, params)
    local player_unit = player.player_unit
    local local_player = player.local_player
    local bot_player = player.bot_player
    local killing_blow_table = params[1]
    local backstab_multiplier = killing_blow_table[DamageDataIndex.BACKSTAB_MULTIPLIER]

    if Unit.alive(player_unit) and backstab_multiplier and backstab_multiplier > 1 then
        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
        local status_extension = ScriptUnit.extension(player_unit, "status_system")
        local buffs_to_add = {
            "kerillian_shade_passive_stealth_on_backstab_kill_buff_1",
			"kerillian_shade_passive_stealth_on_backstab_kill_buff_2",
            "kerillian_shade_passive_stealth_on_backstab_kill_buff_3",
            "kerillian_shade_passive_stealth_on_backstab_kill_cooldown",
        }

        if local_player or (Managers.state.network.is_server and bot_player) then
            status_extension:set_invisible(true)
            status_extension:set_noclip(true)

            local network_manager = Managers.state.network
            local network_transmit = network_manager.network_transmit
            
            local remove_buff_template = buff_extension:get_buff_type("kerillian_shade_passive_stealth_on_backstab_kill")
            if remove_buff_template then
                local remove_buff_id = remove_buff_template.id
                buff_extension:remove_buff(remove_buff_id)
            end

            for i = 1, #buffs_to_add, 1 do
                local buff_name = buffs_to_add[i]
                local unit_object_id = network_manager:unit_game_object_id(player_unit)
                local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

                if Managers.state.network.is_server then
                    buff_extension:add_buff(buff_name, {
                        attacker_unit = player_unit
                    })
                    network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
                else
                    network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
                end
            end   
        end
    end
end)
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill", {
    event = "on_kill",
    event_buff = true,
    buff_func = "kerillian_shade_stealth_on_backstab_kill"
})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_buff_1", {
    max_stacks = 1,
    duration = 0.1,
    delayed_buff_name = "kerillian_shade_activated_ability_short",
    buff_after_delay = true,
    is_cooldown = true,
    --icon = "kerillian_shade_passive_stealth_on_backstab_kill"
})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_buff_2", {
    max_stacks = 1,
    duration = 0.1,
    delayed_buff_name = "kerillian_shade_end_activated_ability",
    buff_after_delay = true,
    is_cooldown = true,
    --icon = "kerillian_shade_passive_stealth_on_backstab_kill"
})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_buff_3", {
    name = "kerillian_shade_activated_ability_short_1",
    refresh_durations = true,
    continuous_effect = "fx/screenspace_shade_skill_01",
    max_stacks = 1,
    icon = "kerillian_shade_passive_stealth_on_backstab_kill",
    duration = 3,
}, {deactivation_effect = "fx/screenspace_shade_skill_02"})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill_cooldown", {
    max_stacks = 1,
    duration = 2.9,
    is_cooldown = true,
    delayed_buff_name = "kerillian_shade_passive_stealth_on_backstab_kill",
    buff_after_delay = true,
    icon = "kerillian_shade_passive_stealth_on_backstab_kill"
})
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_short", {
    duration = 2.9,
    icon = nil,
    continuous_effect = nil,
}, {deactivation_effect = nil})


-- SotT Talents
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
    amount_to_add = 2 -- 3
})
mod:modify_talent("we_thornsister", 5, 2, {
    description_values = {
        {
            value = 2
        }
    }
})
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_avatar", {
    max_stack_data = {
        buffs_to_add = {
            "kerillian_thorn_sister_avatar_buff_1",
            "kerillian_thorn_sister_avatar_buff_2",
            --"kerillian_thorn_sister_avatar_buff_3",
            --"kerillian_thorn_sister_avatar_buff_4"
        }
    }
})
mod:modify_talent("we_thornsister", 4, 3, {
    description = "rebaltourn_kerillian_thorn_sister_avatar_desc",
})
mod:add_text("rebaltourn_kerillian_thorn_sister_avatar_desc", "Consuming Radiance grants Kerillian 20%% extra attack speed and move speed for 10 seconds.")


-- Bounty Hunter Talents

-- Indisctiminate blast cdr upped to 60% (Doesnt work and i dont understand why...
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun", {
	required_target_number = 1,
    multiplier = -0.6 -- -0.25
})


-- Battle Wizard Talents
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05 -- -0.1
})
mod:modify_talent("bw_adept", 5, 2, {
    description_values = {
        {
            value_type = "percent",
            value = -0.05 --BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.multiplier
        },
        {
            value = BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.duration
        },
        {
            value = BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.max_stacks
        }
    },
})