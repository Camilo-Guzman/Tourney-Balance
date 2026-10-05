local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
    Moonfirebow
]]
DamageProfileTemplates.we_deus_01_charged.default_target.power_distribution_near.attack = 0.75
DamageProfileTemplates.we_deus_01_charged.default_target.power_distribution_far.attack = 0.75
DamageProfileTemplates.we_deus_01_charged.default_target.boost_curve_coefficient_headshot = 1.75
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[1] = 1.2
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[1] = 1.2
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[2] = 0.8
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[2] = 0.8
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[3] = 1.5
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[3] = 1.5
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[4] = 0.5
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[4] = 0.5
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[5] = 1.5
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[5] = 1.5
DamageProfileTemplates.we_deus_01_charged.armor_modifier.attack[6] = 0.25
DamageProfileTemplates.we_deus_01_charged.armor_modifier_far.attack[6] = 0.25

-- DoT Nerf from Bloh Bloh
mod_api.insert_buff_template("we_deus_01_dot_charged", {
    apply_buff_func = "start_dot_damage",
    damage_profile = "we_deus_01_dot",
    damage_type = "burninating",
    name = "we_deus_01_dot_charged",
    ticks = 1,
    time_between_dot_damages = 0.75,
    update_func = "apply_dot_damage",
    update_start_delay = 0.75,
    perks = {
        buff_perks.burning_elven_magic,
    },
})

-- Energy recharge rate nerf.
EnergyData.we_waywatcher = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 5,
	recharge_rate = 1 -- 1.5
}
EnergyData.we_maidenguard = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 5,
	recharge_rate = 1 -- 1.5
}
EnergyData.we_shade = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 5,
	recharge_rate = 1 -- 1.5
}
EnergyData.we_thornsister = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 5,
	recharge_rate = 1 -- 1.5
}

