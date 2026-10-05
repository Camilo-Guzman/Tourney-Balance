local shared_utils = {}

--[[
    is_server() - Checks if the current machine is the server (host).

    is_local(unit) - Checks if a specific unit is controlled by the local player.

    Use case: Check is_local(unit) first to decide whether a client-side proc should react at all
    (so it fires once, for the client whose own unit was involved, not redundantly on every client
    watching it happen); check is_server() separately to decide HOW to commit a change to shared
    game state. Apply and broadcast if this client is authoritative, or ask the server to do else.
]]
function shared_utils.is_server()
    return Managers.player.is_server
end

function shared_utils.is_local(unit)
    local player = Managers.player:owner(unit)
    return player and not player.remote
end

--[[
    reduce_cooldown_on_owner(unit, amount) - Reduces a hero's ult cooldown by a flat amount from any peer.
    Cooldown lives on the owning peer only (CareerExtension doesn't sync), same routing as CareerSystem's own rpc.
]]
function shared_utils.reduce_cooldown_on_owner(unit, amount)
    local owner_player = Managers.player:owner(unit)

    if not owner_player then
        return
    end

    if not owner_player.remote then
        local career_extension = ScriptUnit.has_extension(unit, "career_system")

        if career_extension then
            career_extension:reduce_activated_ability_cooldown(amount)
        end

        return
    end

    local network_manager = Managers.state.network
    local unit_id = network_manager:unit_game_object_id(unit)

    if unit_id then
        network_manager.network_transmit:send_rpc("rpc_reduce_activated_ability_cooldown", owner_player:network_id(), unit_id, amount, 1, false)
    end
end

--[[
    reduce_cooldown_percent_on_owner(unit, fraction) - Same as reduce_cooldown_on_owner, but by a fraction of the
    max cooldown (0.1 = 10%), through the percent variant of the same rpc.
]]
function shared_utils.reduce_cooldown_percent_on_owner(unit, fraction)
    local owner_player = Managers.player:owner(unit)

    if not owner_player then
        return
    end

    if not owner_player.remote then
        local career_extension = ScriptUnit.has_extension(unit, "career_system")

        if career_extension then
            career_extension:reduce_activated_ability_cooldown_percent(fraction)
        end

        return
    end

    local network_manager = Managers.state.network
    local unit_id = network_manager:unit_game_object_id(unit)

    if unit_id then
        network_manager.network_transmit:send_rpc("rpc_reduce_activated_ability_cooldown_percent", owner_player:network_id(), unit_id, fraction, 1, false)
    end
end

return shared_utils


