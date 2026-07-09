local mod = get_mod("TourneyBalance")


-- Boon of Shallya 40%
local trait_data = WeaponTraits.traits.necklace_increased_healing_received
if trait_data and trait_data.description_values and trait_data.description_values[1] then
    trait_data.description_values[1].value = 0.4
end
local buff_data = BuffTemplates.trait_necklace_increased_healing_received
if buff_data and buff_data.buffs and buff_data.buffs[1] then
    buff_data.buffs[1].multiplier = 0.4
end