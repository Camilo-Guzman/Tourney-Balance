

local buff_api = {}

--[[
    Generic buff/proc registration with no talent-tree or hero tie-in - buffs anyone/
    anything can be given (item buffs, DoTs, enemy/AI buffs like the ones in
    SpicyEnemies.lua), plus the proc/tick callback tables those buffs reference.
    Talent-tree-scoped registration lives in the sibling file _talent_api.lua.

    insert_buff_template/insert_proc_function/insert_buff_function silently overwrite
    an existing entry with no warning if called again with the same name. Full
    behavior, data shapes, and known quirks for each function: mod_api.md.
]]

function buff_api.insert_buff_template(buff_name, buff_data)
    local new_talent_buff = {
        buffs = {
            table.merge({ name = buff_name }, buff_data),
        },
    }
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end

function buff_api.insert_proc_function(name, func)
    ProcFunctions[name] = func
end

function buff_api.insert_buff_function(name, func)
    BuffFunctionTemplates.functions[name] = func
end

--[[
    Unlike the functions above, this runs at GAMEPLAY time, not mod-load time - grants
    buff_name to owner_unit right now (call from inside a proc/buff function). Full
    behavior: mod_api.md.
]]
function buff_api.add_buff(owner_unit, buff_name)
    if Managers.state.network ~= nil then
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit

        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
        local am_server = network_manager.is_server

        if am_server then
            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

            buff_extension:add_buff(buff_name)
            network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end
    end
end

return buff_api
