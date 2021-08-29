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


-- Footknight Talents
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
})
mod:modify_talent("es_knight", 6, 2, {
    buffs = {
        "markus_knight_heavy_buff",
    },
    description = "rebaltourn_markus_knight_heavy_buff_desc",
    description_values = {},
})
mod:add_text("rebaltourn_markus_knight_heavy_buff_desc", "Valiant Charge increases Melee Power by 50.0%% for 6 seconds.")

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
    description_values = {},
})
mod:add_text("rebaltourn_kerillian_thorn_sister_avatar_desc", "Consuming Radiance grants Kerillian 20%% extra attack speed and move speed for 10 seconds.")


-- Bounty Hunter Talents

-- Indisctiminate blast cdr upped to 60%
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun", {
    multiplier = nil, -- -0.25
    stat_buff = nil
})
mod:add_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun_cdr", {
    multiplier = -0.4, -- -0.25
    stat_buff = "activated_cooldown",
})
mod:modify_talent("wh_bountyhunter", 6, 3, {
    buffs = {
        "victor_bountyhunter_activated_ability_blast_shotgun",
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

mod:add_talent_buff_template("bright_wizard", "rebaltourn_sienna_adept_increase_activated_ability_cooldown", {
    stat_buff = "activated_cooldown",
    multiplier = 2.025,
})
mod:modify_talent("bw_adept", 5, 3, {
    description = "rebaltourn_sienna_adept_ability_trail_double_desc",
    buffs = {
        "rebaltourn_sienna_adept_increase_activated_ability_cooldown",
    }
})
mod:add_text("rebaltourn_sienna_adept_ability_trail_double_desc", "Fire Walk can be activated a second time within 10 seconds. Cooldown of Fire Walk is increased to 90 seconds.")

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
mod:add_talent_buff_template("bright_wizard", "sienna_adept_double_ult_buff", {
    stat_buff = "activated_cooldown",
	multiplier = 0.5
})

mod:modify_talent("bw_adept", 6, 3, {
	description = "sienna_adept_ability_trail_double_desc",
	name = "sienna_adept_ability_trail_double",
	num_ranks = 1,
	icon = "sienna_adept_activated_ability_dump_overcharge",
	description_values = {
		{
			value = 10
		}
	},
	buffs = {
        "sienna_adept_double_ult_buff"
    }
})

mod:add_text("rebaltourn_career_passive_name_bw_1c", "Complete Control")
mod:add_text("rebaltourn_career_passive_desc_bw_1c_2", "No longer slowed from being overcharged.")