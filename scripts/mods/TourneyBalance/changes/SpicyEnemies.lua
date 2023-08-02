local mod = get_mod("TourneyBalance")

--Buffs for enemies used in Dutch Spice. Not put in Dutch Spice itself because that would be problematic if ran with a balance mod like this one.
Managers.package:load("resource_packages/mutators/mutator_curse_bolt_of_change", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_belakor_totems", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_grey_wings", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_corrupted_flesh", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_khorne_champions", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_blood_storm", "global")
Managers.package:load("resource_packages/dlcs/morris_ingame", "global")

BuffTemplates.mark_of_nurgle.buffs[3].aoe_init_difficulty_damage[5] = { 10, 2, 0 }
BuffTemplates.mark_of_nurgle.buffs[3].aoe_dot_difficulty_damage[5] = { 20, 0, 0 }

mod:add_buff_template("nurgle_debuff_adder", {
    apply_buff_func = "add_buffs",
    add_buffs_data = {
        buffs_to_add = {
                "nurgle_debuff_dutch_aoe_movement",
                "nurgle_debuff_dutch_aoe_attack_speed",
                "nurgle_debuff_dutch_aoe_health",
                "nurgle_debuff_dutch_fx",
                "nurgle_health_buff_dutch",
                "gs_nurgle_decal"
            }
    }
})
mod:add_buff_template("nurgle_debuff_dutch_aoe_movement", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "nurgle_movement_debuff_dutch",
    range_check = {
        unit_left_range_func = "unit_left_range_champions_aoe",
        radius = 5,
        update_rate = 1,
        unit_entered_range_func = "unit_entered_range_champions_aoe"
    }
})

mod:add_buff_template("nurgle_debuff_dutch_aoe_movement", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "nurgle_movement_debuff_dutch",
    range_check = {
        radius = 5,
        update_rate = 0.01,
        only_players = true,
        unit_left_range_func = "unit_left_range_generic_buff",
        unit_entered_range_func = "unit_entered_range_generic_buff"
    }
})
mod:add_buff_template("nurgle_movement_debuff_dutch", {
	multiplier = 0.5,
    max_stacks = 1,
    remove_buff_func = "remove_movement_buff",
    apply_buff_func = "apply_movement_buff",
    path_to_movement_setting_to_modify = {
        "move_speed"
    }
})
mod:add_buff_template("nurgle_debuff_dutch_aoe_attack_speed", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "nurgle_attack_speed_debuff_dutch",
    range_check = {
        radius = 5,
        update_rate = 0.01,
        only_players = true,
        unit_left_range_func = "unit_left_range_generic_buff",
        unit_entered_range_func = "unit_entered_range_generic_buff"
    }
})
mod:add_buff_template("nurgle_attack_speed_debuff_dutch", {
	stat_buff = "attack_speed",
	multiplier = -0.2,
    max_stacks = 1,
    icon = "icon_nurgle"
})
mod:add_buff_template("nurgle_buff_dutch_aoe", {
    name = "belakor_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "nurgle_mass_buff_dutch",
    range_check = {
        unit_left_range_func = "unit_left_range_champions_aoe",
        radius = 5,
        update_rate = 1,
        unit_entered_range_func = "unit_entered_range_champions_aoe"
    }
})
mod:add_buff_template("nurgle_mass_buff_dutch", {
    multiplier = 1,
    name = "nurgle_mass_buff_dutch",
    stat_buff = "hit_mass_amount",
    max_stacks = 1
})
mod:add_buff_template("ai_health_buff_dutch", {
    remove_buff_func = "remove_max_health_buff_for_ai",
    name = "ai_health_buff_dutch",
    apply_buff_func = "apply_max_health_buff_for_ai",
    multiplier = 1,
})
mod:add_buff_template("nurgle_debuff_dutch_fx", {
    start_sound_event_name = "Play_curse_corrupted_flesh_loop",
    name = "nurgle_fx",
    mark_particle = "fx/deus_corrupted_flesh_01",
    buff_func = "remove_mark_of_nurgle",
    event = "on_death",
    remove_buff_func = "remove_mark_of_nurgle",
    apply_buff_func = "apply_mark_of_nurgle",
    stop_sound_event_name = "Stop_curse_corrupted_flesh_loop"
})
mod:add_buff_template("gs_nurgle_decal", {
	decal = "units/decals/decal_vortex_circle_inner",
	name = "nurgle_decal",
	decal_scale = 5,
	buff_func = "remove_linked_unit",
    event = "on_death",
    remove_buff_func = "remove_generic_decal",
	apply_buff_func = "apply_generic_decal_linked",
})
mod:add_buff_template("gs_nurgle_decal_remover", {
    event = "on_death",
    remove_buff_func = "remove_deus_rally_flag",
    name = "deus_rally_flag_lifetime",
})
mod:add_buff_template("tzeentch_buff_adder", {
    apply_buff_func = "add_buffs",
    add_buffs_data = {
        buffs_to_add = {
                "tzeentch_buff_dutch_aoe",
                "tzeentch_champion_decal",
                "tzeentch_buff_dutch_fx",
            }
    }
})
mod:add_buff_template("tzeentch_buff_dutch_aoe", {
    name = "belakor_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "tzeentchian_barier_buff",
    range_check = {
        unit_left_range_func = "unit_left_range_champions_aoe",
        radius = 6,
        update_rate = 1,
        unit_entered_range_func = "unit_entered_range_champions_aoe"
    }
})
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod:add_buff_template("tzeentchian_barier_buff", {
    remove_buff_func = "remove_attach_particle",
    name = "tzeentch_barier_effect",
    buff_func = "remove_linked_unit",
    event = "on_death",
    apply_buff_func = "apply_attach_particle",
    particle_fx = "fx/magic_wind_metal_blade_dance_01",
    max_stacks = 1,
    perk = buff_perks.invulnerable_ranged
})
mod:add_buff_template("tzeentch_debuff_dutch_aoe", {
    name = "belakor_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "tzeentch_debuff_no_crits_dutch",
    range_check = {
        radius = 6,
        update_rate = 0.01,
        only_players = true,
        unit_left_range_func = "unit_left_range_generic_buff",
        unit_entered_range_func = "unit_entered_range_generic_buff"
    }
})
mod:add_buff_template("tzeentch_debuff_no_crits_dutch", {
    icon = "icon_tzeentch",
    max_stacks = 1,
    perk = "no_random_crits",
    stat_buff = "critical_strike_chance",
    bonus = -1.5
})
mod:add_buff_template("tzeentch_buff_dutch_fx", {
    remove_buff_func = "remove_attach_particle",
    name = "belakor_grey_wings_particle",
    apply_buff_func = "apply_attach_particle",
    particle_fx = "fx/blk_grey_wings_01"
})
mod:add_buff_template("tzeentch_champion_decal", {
	decal = "units/decals/deus_decal_aoe_bluefire_02",
	name = "nurgle_decal",
	decal_scale = 6,
	buff_func = "remove_linked_unit",
    event = "on_death",
    remove_buff_func = "remove_generic_decal",
	apply_buff_func = "apply_generic_decal_linked",
})
mod:add_buff_template("belakor_buff_adder", {
    apply_buff_func = "add_buffs",
    add_buffs_data = {
        buffs_to_add = {
                "belakor_buff_dutch_aoe",
                "belakor_champion_decal",
                "belakor_buff_dutch_fx",
            }
    }
})
mod:add_buff_template("slaanesh_health_debuff_dutch_aoe", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "slaanesh_health_debuff_dutch",
    range_check = {
        radius = 6,
        update_rate = 0.01,
        only_players = true,
        unit_left_range_func = "unit_left_range_generic_buff",
        unit_entered_range_func = "unit_entered_range_generic_buff"
    }
})
mod:add_buff_template("slaanesh_health_debuff_dutch", {
	stat_buff = "max_health",
	multiplier = -0.2,
    max_stacks = 1,
    icon = "icon_slaanesh",
})
mod:add_buff_template("slaanesh_stagger_buff_dutch_aoe", {
    name = "belakor_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "slaanesh_stagger_buff_dutch",
    range_check = {
        unit_left_range_func = "unit_left_range_champions_aoe",
        radius = 6,
        update_rate = 1,
        unit_entered_range_func = "unit_entered_range_champions_aoe"
    }
})
mod:add_buff_template("slaanesh_stagger_buff_dutch", {
    multiplier = 1,
    name = "slaanesh_stagger_buff_dutch",
    stat_buff = "stagger_resistance",
    max_stacks = 1
})
mod:add_buff_template("belakor_buff_dutch_fx", {
    name = "belakor_fx",
    mark_particle = "fx/blk_grey_wings_01",
    buff_func = "remove_mark_of_nurgle",
    event = "on_death",
    remove_buff_func = "remove_mark_of_nurgle",
    apply_buff_func = "apply_mark_of_nurgle",
})
mod:add_buff_template("belakor_champion_decal", {
	decal = "units/decals/deus_decal_aoe_cursedchest_01",
	name = "nurgle_decal",
	decal_scale = 6,
	buff_func = "remove_linked_unit",
    event = "on_death",
    remove_buff_func = "remove_generic_decal",
	apply_buff_func = "apply_generic_decal_linked",
})

mod:add_buff_function("apply_generic_decal_linked", function(unit, buff, params, world)
    local z_offset = buff.template.decal_z_offset or 0
    local position = Vector3.copy(POSITION_LOOKUP[unit])
    position.z = position.z + z_offset
    local decal_unit_name = buff.template.decal
    local decal_unit = Managers.state.unit_spawner:spawn_local_unit(decal_unit_name, position)
    local scale = buff.template.decal_scale or 1

    World.link_unit(Unit.world(unit), decal_unit, unit, 0)

    Unit.set_local_scale(decal_unit, 0, Vector3(scale, scale, scale))

    buff.linked_decal = decal_unit
end)

mod:add_buff_template("khorne_buff_adder", {
    apply_buff_func = "add_buffs",
    add_buffs_data = {
        buffs_to_add = {
                "khorne_buff_dutch_aoe",
                "khorne_champion_decal",
                "khorne_buff_dutch_fx",
                "khorne_prop_dutch"
            }
    }
})
mod:add_buff_template("khorne_ranged_debuff_dutch_aoe", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "curse_khorne_champions_ranged_debuff",
    range_check = {
        radius = 5,
        update_rate = 0.01,
        only_players = true,
        unit_left_range_func = "unit_left_range_generic_buff",
        unit_entered_range_func = "unit_entered_range_generic_buff"
    }
})
mod:add_buff_template("curse_khorne_champions_ranged_debuff", {
	stat_buff = "power_level_ranged",
	multiplier = -0.5,
    max_stacks = 1,
    icon = "icon_khorne",
})
mod:add_buff_template("khorne_melee_debuff_dutch_aoe", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "curse_khorne_champions_melee_debuff",
    range_check = {
        radius = 5,
        update_rate = 0.01,
        only_players = true,
        unit_left_range_func = "unit_left_range_generic_buff",
        unit_entered_range_func = "unit_entered_range_generic_buff"
    }
})
mod:add_buff_template("curse_khorne_champions_melee_debuff", {
	stat_buff = "power_level_melee",
	multiplier = 0.25,
    max_stacks = 1,
})
mod:add_buff_template("khorne_buff_dutch_aoe", {
    name = "nurgle_champions_leader",
    buff_func = "curse_khorne_champions_leader_death",
    event = "on_death",
    remove_on_proc = true,
    update_func = "update_generic_aoe",
    remove_buff_func = "remove_generic_aoe",
    apply_buff_func = "apply_generic_aoe",
    in_range_units_buff_name = "curse_khorne_champions_buff",
    range_check = {
        unit_left_range_func = "unit_left_range_champions_aoe",
        radius = 5,
        update_rate = 1,
        unit_entered_range_func = "unit_entered_range_champions_aoe"
    }
})
BuffTemplates.curse_khorne_champions_buff.buffs = {
    {
        multiplier = 0.5,
        stat_buff = "damage_dealt",
        name = "curse_khorne_champions_damage_buff",
        max_stacks = 1
    }
}
mod:add_buff_template("khorne_buff_dutch_fx", {
    name = "khorne_fx",
    mark_particle = "fx/deus_curse_khorne_champions_leader",
    buff_func = "remove_mark_of_nurgle",
    event = "on_death",
    remove_buff_func = "remove_mark_of_nurgle",
    apply_buff_func = "apply_mark_of_nurgle",
})
mod:add_buff_template("khorne_champion_decal", {
	decal = "units/decals/deus_decal_bloodstorm_inner",
	name = "khorne_decal",
	decal_scale = 5,
	buff_func = "remove_linked_unit",
    event = "on_death",
    remove_buff_func = "remove_generic_decal",
	apply_buff_func = "apply_generic_decal_linked",
})
mod:add_buff_template("khorne_prop_dutch", {
    unit_name = "units/props/deus_bloodgod_curse/deus_bloodgod_curse_01",
    name = "curse_khorne_champions_unit",
    buff_func = "remove_linked_unit",
    event = "on_death",
    remove_buff_func = "remove_linked_unit",
    apply_buff_func = "curse_khorne_champions_unit_link_unit",
    z_offset = {
        default = 2,
        chaos_raider = 2,
        beastmen_bestigor = 1.9,
        chaos_warrior = 2.4,
        skaven_storm_vermin_commander = 1.9,
        skaven_storm_vermin = 1.9,
        skaven_storm_vermin_with_shield = 1.9,
        skaven_storm_vermin_champion = 1.9
    }
})
mod:add_buff_template("khorne_prop_dutch", {
    unit_name = "units/props/deus_bloodgod_curse/deus_bloodgod_curse_01",
    name = "curse_khorne_champions_unit",
    buff_func = "remove_linked_unit",
    event = "on_death",
    remove_buff_func = "remove_linked_unit",
    apply_buff_func = "curse_khorne_champions_unit_link_unit",
    z_offset = {
        default = 2,
        chaos_raider = 2,
        beastmen_bestigor = 1.9,
        chaos_warrior = 2.4,
        skaven_storm_vermin_commander = 1.9,
        skaven_storm_vermin = 1.9,
        skaven_storm_vermin_with_shield = 1.9,
        skaven_storm_vermin_champion = 1.9
    }
})

