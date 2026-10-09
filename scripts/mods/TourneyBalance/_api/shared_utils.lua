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

--[[
    is_within_attack_target_cap(target_index, max_targets, damage_source, damage_profile) - Whether a melee hit is
    among the first max_targets enemies its attack hits.
    Melee target_index counts the enemies hit, starting at 1, but per sweep: an action with weapon_action_hand = "both"
    (every dual weapon's charged attacks) runs one sweep per hand, each counting from 1. Those hands get half the cap
    each instead. A hit belongs to such an action when its weapon (damage_source is the item name) has a "both" action
    using that damage profile. Keyed per weapon, since some of these profiles are shared with one-handed weapons.
]]
local dual_hand_damage_profiles = nil -- weapon template name -> { [damage_profile] = true }, built on first use

local function build_dual_hand_damage_profiles()
    dual_hand_damage_profiles = {}

    for template_name, weapon_template in pairs(Weapons) do
        for _, action in pairs(weapon_template.actions or {}) do
            for _, sub_action in pairs(action) do
                if type(sub_action) == "table" and sub_action.weapon_action_hand == "both" then
                    local profiles = dual_hand_damage_profiles[template_name] or {}

                    dual_hand_damage_profiles[template_name] = profiles

                    for _, key in ipairs({ "damage_profile_left", "damage_profile_right", "damage_profile" }) do
                        local damage_profile = sub_action[key] and DamageProfileTemplates[sub_action[key]]

                        if damage_profile then
                            profiles[damage_profile] = true
                        end
                    end
                end
            end
        end
    end
end

function shared_utils.is_dual_hand_hit(damage_source, damage_profile)
    if not dual_hand_damage_profiles then
        build_dual_hand_damage_profiles()
    end

    local item_data = damage_source and rawget(ItemMasterList, damage_source)
    local profiles = item_data and item_data.template and dual_hand_damage_profiles[item_data.template]

    return not not (profiles and profiles[damage_profile])
end

function shared_utils.is_within_attack_target_cap(target_index, max_targets, damage_source, damage_profile)
    if not target_index then
        return true
    end

    if shared_utils.is_dual_hand_hit(damage_source, damage_profile) then
        max_targets = math.max(math.floor(max_targets / 2), 1)
    end

    return target_index <= max_targets
end

return shared_utils


