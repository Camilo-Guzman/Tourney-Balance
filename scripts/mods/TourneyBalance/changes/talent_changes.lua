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
mod:add_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_on_backstab_kill", {
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


-- Battle Wizard Talents
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05 -- -0.1
})
mod:modify_talent("bw_adept", 5, 2, {
    description_values = {
        {
            value_type = "percent",
            value = -0.05 --TalentBuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.multiplier
        },
        {
            value = BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.duration
        },
        {
            value = BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.max_stacks
        }
    },
})