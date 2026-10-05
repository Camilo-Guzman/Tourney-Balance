local mod = get_mod("TourneyBalance")

--[[
    Standalone fixes.
]]

-- Blocks interacting with the Skulls of Fury 2023 mutator pickup prop.
mod:hook(InteractionDefinitions.pickup_object.client, "can_interact", function(func, interactor_unit, interactable_unit, data, config, world)
    if Unit.has_data(interactable_unit, "unit_name") then
        if Unit.get_data(interactable_unit, "unit_name") == "units/mutator/skulls_2023/pup_skull_of_fury" then
            return false
        end
    end
    return func(interactor_unit, interactable_unit, data, config, world)
end)
