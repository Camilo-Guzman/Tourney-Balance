local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	Coruscation
]]
Weapons.bw_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.5
Weapons.bw_deus_01_template_1.actions.action_one.default.total_time = 0.65
Weapons.bw_deus_01_template_1.actions.action_one.default.shot_count = 15
DamageProfileTemplates.staff_magma.default_target.power_distribution_near.attack = 0.12
DamageProfileTemplates.staff_magma.default_target.power_distribution_far.attack = 0.06
PlayerUnitStatusSettings.overcharge_values.magma_basic = 4
ExplosionTemplates.magma.aoe.duration = 3
ExplosionTemplates.magma.aoe.damage_interval = 1
PlayerUnitStatusSettings.overcharge_values.magma_charged_2 = 10
PlayerUnitStatusSettings.overcharge_values.magma_charged = 14
mod_api.insert_buff_template("burning_magma_dot", {
	duration = 3,
	name = "burning_magma_dot",
	end_flow_event = "smoke",
	start_flow_event = "burn",
	update_start_delay = 0.75,
	reapply_start_flow_event = true,
	apply_buff_func = "start_dot_damage",
	death_flow_event = "burn_death",
	time_between_dot_damages = 1.5,
	refresh_durations = true,
	damage_type = "burninating",
	damage_profile = "burning_dot",
	update_func = "apply_dot_damage",
	reapply_buff_func = "reapply_dot_damage",
	max_stacks = 15,
	perks = { buff_perks.burning }
})

