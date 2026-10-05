local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

-- Boon of Shallya 40%
local trait_data = WeaponTraits.traits.necklace_increased_healing_received
if trait_data and trait_data.description_values and trait_data.description_values[1] then
    trait_data.description_values[1].value = 0.4
end
local buff_data = BuffTemplates.trait_necklace_increased_healing_received
if buff_data and buff_data.buffs and buff_data.buffs[1] then
    buff_data.buffs[1].multiplier = 0.4
end

-- Natural Bond: health regen no longer replaces temp health (affects Chaos Wastes regen boon).
BuffFunctionTemplates.functions.update_heal_ticks = function (unit, buff, params)
    local t = params.t
    local buff_template = buff.template
    local next_heal_tick = buff.next_heal_tick or 0
    local health_extension = ScriptUnit.extension(unit, "health_system")

    if health_extension:current_permanent_health_percent() >= 1 then
        return
    end

    if next_heal_tick < t then
        if Managers.state.network.is_server and HEALTH_ALIVE[unit] then
            local heal_amount = buff_template.heal_amount

            -- Give THP first so it doesn't grant GHP + THP resulting in double regen
            DamageUtils.heal_network(unit, unit, heal_amount, "heal_from_proc")
            DamageUtils.heal_network(unit, unit, heal_amount, "career_passive")
        end

        buff.next_heal_tick = t + buff_template.time_between_heals
    end
end
-- description_values: heal_amount (1), time_between_heals (5)
mod_api.insert_text("description_trait_necklace_no_healing_health_regen_2", "Regenerates %s health every %s seconds. Cannot be healed by healing items. Health regeneration does not replace temporary health.")

--[[
    Revive Speed 
]]
-- property also speeds up pulling allies up from ledges, freeing them from Packmaster hooks
-- and rescuing them from respawn points. Uses its own stat so faster_revive talents (Maidenguard) don't apply.
StatBuffApplicationMethods.faster_rescue = "stacking_multiplier"

local revive_speed_buffs = BuffTemplates.properties_revive_speed.buffs
revive_speed_buffs[2] = {
    name = "properties_revive_speed_rescue",
    stat_buff = "faster_rescue",
    variable_multiplier = table.clone(revive_speed_buffs[1].variable_multiplier),
}

local function rescue_config(interactor_unit, config)
    local buff_extension = Unit.alive(interactor_unit) and ScriptUnit.has_extension(interactor_unit, "buff_system")
    if not buff_extension then
        return config
    end
    local duration = buff_extension:apply_buffs_to_value(config.duration, "faster_rescue")
    return setmetatable({ duration = duration }, { __index = config })
end

for _, interaction_name in ipairs({ "pull_up", "release_from_hook", "assisted_respawn" }) do
    local interaction = InteractionDefinitions[interaction_name]

    mod:hook(interaction.server, "start", function(func, world, interactor_unit, interactable_unit, data, config, t)
        return func(world, interactor_unit, interactable_unit, data, rescue_config(interactor_unit, config), t)
    end)

    mod:hook(interaction.client, "start", function(func, world, interactor_unit, interactable_unit, data, config, t)
        local modified_config = rescue_config(interactor_unit, config)
        data.rescue_duration = modified_config.duration
        return func(world, interactor_unit, interactable_unit, data, modified_config, t)
    end)

    mod:hook(interaction.client, "get_progress", function(func, data, config, t)
        local duration = data.rescue_duration or config.duration
        if duration == 0 then
            return 0
        end
        return data.start_time == nil and 0 or math.min(1, (t - data.start_time) / duration)
    end)
end