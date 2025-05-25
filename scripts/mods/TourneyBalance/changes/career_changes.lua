local mod = get_mod("TourneyBalance")

local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
██████╗░░█████╗░░██████╗░██████╗██╗██╗░░░██╗███████╗░██████╗
██╔══██╗██╔══██╗██╔════╝██╔════╝██║██║░░░██║██╔════╝██╔════╝
██████╔╝███████║╚█████╗░╚█████╗░██║╚██╗░██╔╝█████╗░░╚█████╗░
██╔═══╝░██╔══██║░╚═══██╗░╚═══██╗██║░╚████╔╝░██╔══╝░░░╚═══██╗
██║░░░░░██║░░██║██████╔╝██████╔╝██║░░╚██╔╝░░███████╗██████╔╝
╚═╝░░░░░╚═╝░░╚═╝╚═════╝░╚═════╝░╚═╝░░░╚═╝░░░╚══════╝╚═════╝░
]]

--[[

	Footknight

]]
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive", {
    range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura", {
    multiplier = -0.1
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_range", {
    buff_to_add = "markus_knight_passive_defence_aura_range",
	update_func = "activate_buff_on_distance",
	remove_buff_func = "remove_aura_buff",
	range = 40
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura_range", {
    multiplier = -0.1
})
mod:add_text("career_passive_desc_es_2a_2", "Aura that reduces damage taken by 10%")
mod:modify_talent_buff_template("empire_soldier", "markus_knight_guard_defence", {
	buff_to_add = "markus_knight_guard_defence_buff",
	stat_buff = "damage_taken",
	update_func = "activate_buff_on_closest_distance",
	remove_buff_func = "remove_aura_buff",
	range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_guard", {
	buff_to_add = "markus_knight_passive_power_increase_buff",
	stat_buff = "power_level",
	remove_buff_func = "remove_aura_buff",
	icon = "markus_knight_passive_power_increase",
	update_func = "activate_buff_on_closest_distance",
	range = 20
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity", {
	buff_to_add = "markus_knight_damage_taken_ally_proximity_buff",
	range = 20,
	update_func = "activate_party_buff_stacks_on_ally_proximity",
	chunk_size = 1,
	max_stacks = 3,
	remove_buff_func = "remove_party_buff_stacks"
})
mod:add_buff_function("activate_party_buff_stacks_on_ally_proximity", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local range = 20
	local range_squared = range * range
	local chunk_size = template.chunk_size
	local buff_to_add = template.buff_to_add
	local max_stacks = template.max_stacks
	local side = Managers.state.side.side_by_unit[owner_unit]

	if not side then
		return
	end

	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
	local own_position = POSITION_LOOKUP[owner_unit]
	local num_nearby_allies = 0
	local allies = #player_and_bot_units

	for i = 1, allies do
		local ally_unit = player_and_bot_units[i]

		if ally_unit ~= owner_unit then
			local ally_position = POSITION_LOOKUP[ally_unit]
			local distance_squared = Vector3.distance_squared(own_position, ally_position)

			if distance_squared < range_squared then
				num_nearby_allies = num_nearby_allies + 1
			end

			if math.floor(num_nearby_allies / chunk_size) == max_stacks then
				break
			end
		end
	end

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	for i = 1, allies do
		local unit = player_and_bot_units[i]

		if ALIVE[unit] then
			if not buff.stack_ids[unit] then
				buff.stack_ids[unit] = {}
			end

			local unit_position = POSITION_LOOKUP[unit]
			local distance_squared = Vector3.distance_squared(own_position, unit_position)
			local buff_extension = ScriptUnit.extension(unit, "buff_system")

			if range_squared < distance_squared then
				local stack_ids = buff.stack_ids[unit]

				for i = 1, #stack_ids do
					local stack_ids = buff.stack_ids[unit]
					local buff_id = table.remove(stack_ids)

					buff_system:remove_server_controlled_buff(unit, buff_id)
				end
			else
				local num_chunks = math.floor(num_nearby_allies / chunk_size)
				local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

				if num_buff_stacks < num_chunks then
					local difference = num_chunks - num_buff_stacks
					local stack_ids = buff.stack_ids[unit]

					for i = 1, difference do
						local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
						stack_ids[#stack_ids + 1] = buff_id
					end
				elseif num_chunks < num_buff_stacks then
					local difference = num_buff_stacks - num_chunks
					local stack_ids = buff.stack_ids[unit]

					for i = 1, difference do
						local buff_id = table.remove(stack_ids)

						buff_system:remove_server_controlled_buff(unit, buff_id)
					end
				end
			end
		end
	end
end)

--[[

	Ranger Veteran

]]
-- New Ranged damage and effective range passive
mod:add_talent_buff_template("dwarf_ranger", "dwarf_ranger_ranged_power", {
	max_stacks = 1,
	multiplier = 0.1,
	stat_buff = "power_level_ranged",
})
table.insert(PassiveAbilitySettings.dr_3.buffs, "dwarf_ranger_ranged_power")
table.insert(PassiveAbilitySettings.dr_3.buffs, "markus_huntsman_passive_no_damage_dropoff")
mod:add_text("career_passive_desc_dr_3c_2", "Double effective range for ranged weapons, 10% increased ranged power, and 15% increased reload speed.")

--[[

	Bounty Hunter

]]
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")

--[[

██╗░░░██╗██╗░░░░░████████╗██╗███╗░░░███╗░█████╗░████████╗███████╗
██║░░░██║██║░░░░░╚══██╔══╝██║████╗░████║██╔══██╗╚══██╔══╝██╔════╝
██║░░░██║██║░░░░░░░░██║░░░██║██╔████╔██║███████║░░░██║░░░█████╗░░
██║░░░██║██║░░░░░░░░██║░░░██║██║╚██╔╝██║██╔══██║░░░██║░░░██╔══╝░░
╚██████╔╝███████╗░░░██║░░░██║██║░╚═╝░██║██║░░██║░░░██║░░░███████╗
░╚═════╝░╚══════╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝
]]

--[[

	Huntsman

]]
ActivatedAbilitySettings.es_1[1].cooldown = 75

--[[
	
	Footknight

]]
-- Made Widecharge the standard Footknight ult
ActivatedAbilitySettings.es_2[1].cooldown = 40

-- baseline ult buff
mod:hook(CareerAbilityESKnight, "_run_ability", function (func, self, ...)
	func(self, ...)

    local owner_unit = self._owner_unit
    local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local status_extension = self._status_extension

	-- increase radius of explosion and double cleave of explosion and normal charge
	status_extension.do_lunge.damage.on_interrupt_blast.radius = 4 --3
	PowerLevelTemplates.cleave_distribution_markus_knight_charge = {
		attack = 4, --2 
		impact = 4, --2
	}

	if talent_extension:has_talent("markus_knight_wide_charge", "empire_soldier", true) then
		-- remove buffs from baseline ult if battering ram is selected
		PowerLevelTemplates.cleave_distribution_markus_knight_charge = {
			attack = 2,
			impact = 2,
		}
		status_extension.do_lunge.damage.on_interrupt_blast.radius = 3 --3 --remove buff from baseline for battering ram specifically
		status_extension.do_lunge.damage.width = 5
		status_extension.do_lunge.damage.interrupt_on_max_hit_mass = false
	end

end)


--[[

	Grail Knight

]]
ActivatedAbilitySettings.es_4[1].cooldown = 60
mod:add_text("markus_questing_knight_crit_can_insta_kill_desc", "Critical Strikes instantly slay enemies if their current health is less than 3 times the amount of damage of the Critical Strike. Half effect versus Lords and Monsters.")
mod:modify_talent_buff_template("empire_soldier", "markus_questing_knight_crit_can_insta_kill",  {
	damage_multiplier = 3
})
local side_quest_challenge_gs = {
	reward = "markus_questing_knight_passive_strength_potion",
	type = "kill_enemies",
	amount = {
		1,
		100,
		125,
		150,
		175,
		200,
		250,
		250
	}
}

mod:hook_origin(PassiveAbilityQuestingKnight, "_get_side_quest_challenge", function(self)
	local side_quest_challenge = side_quest_challenge_gs

	return side_quest_challenge
end)

-- Sweep Nerf (no infinite damage cleave)
--infinite stagger cleave stays
--old damage numbers but heavy linesman instead (potentially too good against berzerkers)
--start window shorter for better visual feedback
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.unlimited_cleave = false
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.damage_window_start = 0.05
DamageProfileTemplates.questing_knight_career_sword_tank.cleave_distribution.attack = 0.5

--[[

	Ranger Veteran

]]
-- surprise guest now has 30% CDR
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_activated_ability_stealth_outside_of_smoke", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3,
	max_stacks = 1
})
mod:add_text("bardin_ranger_activated_ability_stealth_outside_of_smoke_desc", "Disengage's stealth does not break on moving beyond the smoke cloud. Reduces the cooldown of Disengage by 30%")

--[[

	Iron Breaker

]]
-- reduce Impenetrable from 50% DR to 28.5% Damage reduction
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_activated_ability", {
	{
		stat_buff = "damage_taken",
		multiplier = -0.285
	},
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_activated_ability_taunt_range_and_duration", {
	{
		stat_buff = "damage_taken",
		multiplier = -0.285
	},
})
mod:add_text("career_active_desc_dr_1", "Bardin taunts all nearby man-sized enemies, takes 28.5% less damage (stacks with Dwarf-Forged) and has 0 block cost for the next 10 seconds")


--[[
	
	Waystalker

]]
ActivatedAbilitySettings.we_3[1].cooldown = 65
local sniper_dropoff_ranges = {
	dropoff_start = 30,
	dropoff_end = 50
}
DamageProfileTemplates.arrow_sniper_trueflight = {
    charge_value = "projectile",
    no_stagger_damage_reduction_ranged = true,
    critical_strike = {
        attack_armor_power_modifer = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
        },
        impact_armor_power_modifer = {
            1,
            1,
            0,
            1,
            1,
            1
        }
    },
    armor_modifier_near = {
        attack = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            1
        }
    },
    armor_modifier_far = {
        attack = {
            1.5,
            1,
            2,
            0.25,
            1,
            0.6
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            0
        }
    },
    cleave_distribution = {
        attack = 0.375,
        impact = 0.375
    },
    default_target = {
        boost_curve_coefficient_headshot = 2.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 0.75,
        attack_template = "arrow_sniper",
        power_distribution_near = {
            attack = 0.5,
            impact = 0.3
        },
        power_distribution_far = {
            attack = 0.5,
            impact = 0.25
        },
        range_dropoff_settings = sniper_dropoff_ranges
    },
	max_friendly_damage = 0
}
Weapons.kerillian_waywatcher_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}

--Removed bloodshot and ult interaction
mod:hook_origin(ActionCareerWEWaywatcher, "client_owner_post_update", function (self, dt, t, world, can_damage)
    local current_action = self.current_action

	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
		self.state = "shooting"
	end

	if self.state == "shooting" then
		local has_extra_shots = self:_update_extra_shots(self.owner_buff_extension, 1)
		local add_spread = not self.extra_buff_shot

		self:fire(current_action, add_spread)

		if has_extra_shots and has_extra_shots > 1 then
			self.state = "waiting_to_shoot"
			self.time_to_shoot = t + 0.1
			self.extra_buff_shot = true
		else
			self.state = "shot"
		end

		local first_person_extension = self.first_person_extension

		if self.current_action.reset_aim_on_attack then
			first_person_extension:reset_aim_assist_multiplier()
		end

		local fire_sound_event = self.current_action.fire_sound_event

		if fire_sound_event then
			local play_on_husk = self.current_action.fire_sound_on_husk

			first_person_extension:play_hud_sound_event(fire_sound_event, nil, play_on_husk)
		end

		if self.current_action.extra_fire_sound_event then
			local position = POSITION_LOOKUP[self.owner_unit]

			WwiseUtils.trigger_position_event(self.world, self.current_action.extra_fire_sound_event, position)
		end
	end
end)

mod:add_proc_function("kerillian_waywatcher_consume_extra_shot_buff", function (player, buff, params)
    local is_career_skill = params[5]
    local should_consume_shot = nil

    if is_career_skill == "RANGED_ABILITY" or is_career_skill == nil then
        should_consume_shot = false
    else
        should_consume_shot = true
    end

    return should_consume_shot
end)

--[[

	Handmaiden

]]
table.insert(PassiveAbilitySettings.we_2.buffs, "kerillian_maidenguard_passive_damage_reduction")
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_damage_reduction", {
	stat_buff = "damage_taken",
	multiplier = -0.3
})
PassiveAbilitySettings.we_2.perks = {
	{
        display_name = "career_passive_name_we_2b",
        description = "career_passive_desc_we_2b_2"
    },
    {
        display_name = "career_passive_name_we_2c",
        description = "career_passive_desc_we_2c_2"
    },
	{
		display_name = "rebaltourn_career_passive_name_we_2d",
		description = "rebaltourn_career_passive_desc_we_2d_2"
	}
}
mod:add_text("rebaltourn_career_passive_name_we_2d", "Bendy")
mod:add_text("rebaltourn_career_passive_desc_we_2d_2", "Reduces damage taken by 30%.")

mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_stamina_regen_aura", {
	range = 20
})

--Ult hitbox
mod:hook(CareerAbilityWEMaidenGuard, "_run_ability", function (func, self, ...)
    func(self, ...)

    local owner_unit = self._owner_unit
    local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
    local bleed = talent_extension:has_talent("kerillian_maidenguard_activated_ability_damage")

    if bleed then
        local status_extension = self._status_extension
        -- hitbox is a rectangular cube / cuboid with given width, height and length, and offset_forward changes its position relative to character's
        status_extension.do_lunge.damage.width = 1.5    --1.5    --width of hitbox
        status_extension.do_lunge.damage.depth_padding = 0.4   --0.4    --length of hitbox
        status_extension.do_lunge.damage.offset_forward = 0   --0    --position of hitbox
    else
        local status_extension = self._status_extension
        -- hitbox is a rectangular cube / cuboid with given width, height and length, and offset_forward changes its position relative to character's
        status_extension.do_lunge.damage.width = 5.0    --1.5    --width of hitbox
        status_extension.do_lunge.damage.depth_padding = 5.0   --0.4    --length of hitbox
        status_extension.do_lunge.damage.offset_forward = 0   --0    --position of hitbox
    end
end)

--[[

	Shade

]]
Breeds.chaos_exalted_sorcerer.boost_curve_multiplier_override = 2
Breeds.chaos_exalted_sorcerer_drachenfels.boost_curve_multiplier_override = 2
Breeds.chaos_spawn.boost_curve_multiplier_override = 2
Breeds.chaos_troll.boost_curve_multiplier_override = 2
Breeds.skaven_grey_seer.boost_curve_multiplier_override = 2
Breeds.skaven_rat_ogre.boost_curve_multiplier_override = 2
Breeds.skaven_storm_vermin_warlord.boost_curve_multiplier_override = 2
Breeds.skaven_stormfiend.boost_curve_multiplier_override = 2
Breeds.skaven_stormfiend_boss.boost_curve_multiplier_override = 2

mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_phasing", {
	duration = 2.5
})
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_short_blocker", {
	duration = 2.5
})
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability", {
	duration = 2.5
})
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_restealth", {
	duration = 2.5
})
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_passive_stealth_parry", {
	event = "on_timed_block_long",
})
mod:add_text("career_active_desc_we_1_2", "Kerillian becomes undetectable, can pass through enemies, and deals greatly increased melee damage. Lasts for 2.5 seconds or until she deals damage.")

--[[ 

	Sister of the Thorn

]]
ActivatedAbilitySettings.we_thornsister[1].cooldown = 60
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_temp_health_funnel_aura_buff", {
	multiplier = 0.10
})

mod:hook_origin(PassiveAbilityThornsister, "_update_extra_abilities_info", function(self, talent_extension)
    if not talent_extension then
        return
    end

    local career_ext = self._career_extension

    if not career_ext then
        return
    end

    local max_uses = self._ability_init_data.max_stacks

    if talent_extension:has_talent("kerillian_double_passive") then
        max_uses = max_uses + 1
    end

    career_ext:update_extra_ability_uses_max(max_uses)

    local cooldown = self._ability_init_data.cooldown

    if talent_extension:has_talent("kerillian_thorn_sister_faster_passive") then
        cooldown = cooldown * 0.75
    end

    career_ext:update_extra_ability_charge(cooldown)
end)

local WALL_TYPES = table.enum("default", "bleed")
local UNIT_NAMES = {
	default = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01",
	bleed = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_bleed"
}

SpawnUnitTemplates.thornsister_thorn_wall_unit = {
	spawn_func = function (source_unit, position, rotation, state_int, group_spawn_index)
		local UNIT_NAME = UNIT_NAMES[WALL_TYPES.default]
		local UNIT_TEMPLATE_NAME = "thornsister_thorn_wall_unit"
		local wall_index = state_int
		local despawn_sound_event = "career_ability_kerillian_sister_wall_disappear"
		local life_time = 6
		local area_damage_params = {
			aoe_dot_damage = 0,
			radius = 0.3,
			area_damage_template = "we_thornsister_thorn_wall",
			invisible_unit = false,
			nav_tag_volume_layer = "temporary_wall",
			create_nav_tag_volume = true,
			aoe_init_damage = 0,
			damage_source = "career_ability",
			aoe_dot_damage_interval = 0,
			damage_players = false,
			source_attacker_unit = source_unit,
			life_time = life_time
		}
		local props_params = {
			life_time = life_time,
			owner_unit = source_unit,
			despawn_sound_event = despawn_sound_event,
			wall_index = wall_index
		}
		local health_params = {
			health = 20
		}
		local buffs_to_add = nil
		local source_talent_extension = ScriptUnit.has_extension(source_unit, "talent_system")

		if source_talent_extension then
			if source_talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
				local life_time_mult = 1
				local life_time_bonus = 4.2
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				props_params.life_time = 6 /10 *(props_params.life_time * life_time_mult + life_time_bonus)
			elseif source_talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
				local life_time_mult = 0.17
				local life_time_bonus = 0
				area_damage_params.create_nav_tag_volume = false
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
				UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
			end
		end

		local extension_init_data = {
			area_damage_system = area_damage_params,
			props_system = props_params,
			health_system = health_params,
			death_system = {
				death_reaction_template = "thorn_wall",
				is_husk = false
			},
			hit_reaction_system = {
				is_husk = false,
				hit_reaction_template = "level_object"
			}
		}
		local wall_unit = Managers.state.unit_spawner:spawn_network_unit(UNIT_NAME, UNIT_TEMPLATE_NAME, extension_init_data, position, rotation)
		local random_rotation = Quaternion(Vector3.up(), math.random() * 2 * math.pi - math.pi)

		Unit.set_local_rotation(wall_unit, 0, random_rotation)

		local buff_extension = ScriptUnit.has_extension(wall_unit, "buff_system")

		if buff_extension and buffs_to_add then
			for i = 1, #buffs_to_add do
				buff_extension:add_buff(buffs_to_add[i])
			end
		end

		local thorn_wall_extension = ScriptUnit.has_extension(wall_unit, "props_system")

		if thorn_wall_extension then
			thorn_wall_extension.group_spawn_index = group_spawn_index
		end
	end
}

mod:add_text("kerillian_thorn_sister_tanky_wall_desc_2", "Increase the width of the Thorn Wall.")
mod:add_text("kerillian_thorn_sister_faster_passive_desc", "Reduce the cooldown of Radiance by 25%%, taking damage sets the cooldown back 2 seconds.")

--[[

	Zealot

]]
--Turn green hp into white hp on ult
mod:hook_safe(CareerAbilityWHZealot, "_run_ability", function(self)
    local unit = self._owner_unit
    local health_extension = ScriptUnit.extension(unit, "health_system")
    local perm_health = health_extension:current_permanent_health()
    health_extension:convert_to_temp(perm_health)
end)

--[[

	Battle Wizard

]]
ActivatedAbilitySettings.bw_2[1].cooldown = 60

--Firetrail nerf (Fatshark please)
mod:add_buff_template("sienna_adept_ability_trail", {
    leave_linger_time = 1.5,
    name = "sienna_adept_ability_trail",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    on_max_stacks_overflow_func = "reapply_buff",
    apply_buff_func = "start_dot_damage",
    update_start_delay = 0.25,
    death_flow_event = "burn_death",
    time_between_dot_damages = 0.75,
    damage_type = "burninating",
    damage_profile = "burning_dot",
    update_func = "apply_dot_damage",
    max_stacks = 1,
    perks = { buff_perks.burning }
})

--[[

	Unchained

]]
PlayerCharacterStateOverchargeExploding.on_exit = function (self, unit, input, dt, context, t, next_state)
    if not Managers.state.network:game() or not next_state then
        return
    end

    CharacterStateHelper.play_animation_event(unit, "cooldown_end")
    CharacterStateHelper.play_animation_event_first_person(self.first_person_extension, "cooldown_end")

    local career_extension = ScriptUnit.extension(unit, "career_system")
    local career_name = career_extension:career_name()

    if self.falling and next_state ~= "falling" then
        ScriptUnit.extension(unit, "whereabouts_system"):set_no_landing()
    end
end

--Explosion kill credit fix
mod:hook_safe(PlayerProjectileHuskExtension, "init", function(self, extension_init_data)
    self.owner_unit = extension_init_data.owner_unit
end)
mod:hook_origin(ActionMeleeStart, "client_owner_post_update", function (self, dt, t, world)
	local action = self.current_action
	local owner_unit = self.owner_unit
	local action_start_time = self.action_start_t
	local blocking_charge = action.blocking_charge
	local status_extension = self.status_extension

	if not status_extension.blocking and blocking_charge and t > action_start_time + self._block_delay then
		local go_id = Managers.state.unit_storage:go_id(owner_unit)

		if not LEVEL_EDITOR_TEST then
			if self.is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, true)
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_charge_blocking", go_id, true)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", go_id, true)
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_charge_blocking", go_id, true)
			end
		end

		status_extension:set_blocking(true)
		status_extension:set_charge_blocking(true)

		status_extension.timed_block = t + 0.5
		status_extension.timed_block_long = t + 0.75
	end

	if self.zoom_condition_function and self.zoom_condition_function(action.lookup_data) then
		local input_extension = self.input_extension
		local buff_extension = self.buff_extension

		if not status_extension:is_zooming() and self.aim_zoom_time <= t then
			status_extension:set_zooming(true, action.default_zoom)
		end

		if buff_extension:has_buff_perk("increased_zoom") and status_extension:is_zooming() and input_extension:get("action_three") then
			status_extension:switch_variable_zoom(action.buffed_zoom_thresholds)
		end
	end
end)
mod:hook_origin(ActionBlock, "client_owner_start_action", function (self, new_action, t)
	ActionBlock.super.client_owner_start_action(self, new_action, t)

	self.current_action = new_action
	self.action_time_started = t
	local input_extension = ScriptUnit.extension(self.owner_unit, "input_system")

	input_extension:reset_input_buffer()

	local owner_unit = self.owner_unit
	local go_id = Managers.state.unit_storage:go_id(owner_unit)

	if not LEVEL_EDITOR_TEST then
		if self.is_server then
			Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, true)
		else
			Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", go_id, true)
		end
	end

	Unit.flow_event(self.first_person_unit, "sfx_block_started")

	local status_extension = self._status_extension

	status_extension:set_blocking(true)

	status_extension.timed_block = t + 0.5
	status_extension.timed_block_long = t + 0.75
end)
mod:hook_origin(GenericStatusExtension, "init", function (self, extension_init_context, unit, extension_init_data)
	self.world = extension_init_context.world
	self.profile_id = extension_init_data.profile_id

	fassert(self.profile_id)

	self.unit = unit
	self.pacing_intensity = 0
	self.pacing_intensity_decay_delay = 0
	self.move_speed_multiplier = 1
	self.move_speed_multiplier_timer = 1
	self.invisible = {}
	self.crouching = false
	self.blocking = false
	self.override_blocking = nil
	self.charge_blocking = false
	self.catapulted = false
	self.catapulted_direction = nil
	self.pounced_down = false
	self.on_ladder = false
	self.is_ledge_hanging = false
	self.left_ladder_timer = 0
	self.aim_unit = nil
	self.revived = false
	self.dead = false
	self.pulled_up = false
	self.overpowered = false
	self.overpowered_template = nil
	self.overpowered_attacking_unit = nil
	self._has_blocked = false
	self.my_dodge_cd = 0
	self.my_dodge_jump_override_t = 0
	self.dodge_cooldown = 0
	self.dodge_cooldown_delay = 0
	self.is_aiming = false
	self.dodge_count = 2
	self.combo_target_count = 0
	self.fatigue = 0
	self.last_fatigue_gain_time = 0
	self.show_fatigue_gui = false
	self.max_fatigue_points = 100
	self.next_hanging_damage_time = 0
	self.block_broken = false
	self.block_broken_at_t = -math.huge
	self.stagger_immune = false
	self.pushed = false
	self.pushed_at_t = -math.huge
	self.push_cooldown = false
	self.push_cooldown_timer = false
	self.timed_block = nil
	self.timed_block_long = nil
	self.shield_block = nil
	self.charged = false
	self.charged_at_t = -math.huge
	self.interrupt_cooldown = false
	self.interrupt_cooldown_timer = nil
	self.inside_transport_unit = nil
	self.using_transport = false
	self.dodge_position = Vector3Box(0, 0, 0)
	self.overcharge_exploding = false
	self.fall_height = nil
	self.under_ratling_gunner_attack = nil
	self.last_catapulted_time = 0
	self.grabbed_by_tentacle = false
	self.grabbed_by_tentacle_status = nil
	self.grabbed_by_chaos_spawn = false
	self.grabbed_by_chaos_spawn_status = nil
	self.in_vortex = false
	self.in_vortex_unit = nil
	self.near_vortex = false
	self.near_vortex_unit = nil
	self.in_liquid = false
	self.in_liquid_unit = nil
	self.in_hanging_cage_unit = nil
	self.in_hanging_cage_state = nil
	self.in_hanging_cage_animations = nil
	self.wounds = extension_init_data.wounds

	if self.wounds == -1 then
		self.wounds = math.huge
	end

	self._base_max_wounds = self.wounds
	self._num_times_grabbed_by_pack_master = 0
	self._hit_by_globadier_poison_instances = { }
	self._num_times_knocked_down = 0
	self.is_server = Managers.player.is_server
	self.update_funcs = {}

	self:set_spawn_grace_time(5)

	self.ready_for_assisted_respawn = false
	self.assisted_respawning = false
	self.player = extension_init_data.player
	self.is_bot = self.player.bot_player
	self.in_end_zone = false
	self.is_husk = self.player.remote

	if self.is_server then
		self.conflict_director = Managers.state.conflict
	end

	self._intoxication_level = 0
	self.noclip = {}
	self._incapacitated_outline_ids = {}
	self._assisted_respawn_outline_id = -1
	self._invisible_outline_id = -1
end)
mod:hook_origin(GenericStatusExtension, "blocked_attack", function (self, fatigue_type, attacking_unit, fatigue_point_costs_multiplier, improved_block, attack_direction)
	local unit = self.unit
	local inventory_extension = self.inventory_extension
	local equipment = inventory_extension:equipment()
	local blocking_unit = nil

	self:set_has_blocked(true)

	local player = self.player

	if player then
		local buff_extension = self.buff_extension
		local all_blocks_parry_buff = "power_up_deus_block_procs_parry_exotic"
		local all_blocks_parry = buff_extension:has_buff_type(all_blocks_parry_buff)
		local is_timed_block = false
		local t = Managers.time:time("game")

		if self.timed_block and (t < self.timed_block or all_blocks_parry) then
			buff_extension:trigger_procs("on_timed_block", attacking_unit)
			is_timed_block = true
		end

		if self.timed_block_long and (t < self.timed_block_long or all_blocks_parry) then
			buff_extension:trigger_procs("on_timed_block_long", attacking_unit)
			is_timed_block = true
		end

		if not player.remote then
			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
			local first_person_unit = first_person_extension:get_first_person_unit()

			if Managers.state.controller_features and player.local_player then
				Managers.state.controller_features:add_effect("rumble", {
					rumble_effect = "block"
				})
			end

			blocking_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit
			local weapon_template_name = equipment.wielded.template or equipment.wielded.temporary_template
			local weapon_template = Weapons[weapon_template_name]

			if is_timed_block then
				first_person_extension:play_hud_sound_event("Play_player_parry_success", nil, false)
			end

			self:add_fatigue_points(fatigue_type, attacking_unit, blocking_unit, fatigue_point_costs_multiplier, is_timed_block)

			local parry_reaction = "parry_hit_reaction"

			if improved_block then
				local amount = PlayerUnitStatusSettings.fatigue_point_costs[fatigue_type]

				if amount <= 2 and (attack_direction == "left" or attack_direction == "right") then
					parry_reaction = "parry_deflect_" .. attack_direction
				end

				local block_arc_event = (weapon_template and weapon_template.sound_event_block_within_arc) or "Play_player_block_ark_success"

				first_person_extension:play_hud_sound_event(block_arc_event, nil, false)
			else
				local wwise_world = Managers.world:wwise_world(self.world)
				local enemy_pos = POSITION_LOOKUP[attacking_unit]

				if enemy_pos then
					local player_pos = first_person_extension:current_position()
					local dir_to_enemy = Vector3.normalize(enemy_pos - player_pos)

					WwiseWorld.trigger_event(wwise_world, "Play_player_combat_out_of_arc_block", player_pos + dir_to_enemy)
				end
			end

			Unit.animation_event(first_person_unit, parry_reaction)
			QuestSettings.handle_bastard_block(unit, attacking_unit, true)
		else
			blocking_unit = equipment.right_hand_wielded_unit_3p or equipment.left_hand_wielded_unit_3p

			QuestSettings.handle_bastard_block(unit, attacking_unit, true)
			--self:add_fatigue_points(fatigue_type, attacking_unit, blocking_unit, fatigue_point_costs_multiplier, is_timed_block)
			Unit.animation_event(unit, "parry_hit_reaction")
		end

		Managers.state.entity:system("play_go_tutorial_system"):register_block()
	end

	if blocking_unit then
		local unit_pos = POSITION_LOOKUP[blocking_unit]
		local unit_rot = Unit.world_rotation(blocking_unit, 0)
		local particle_position = unit_pos + Quaternion.up(unit_rot) * Math.random() * 0.5 + Quaternion.right(unit_rot) * 0.1

		World.create_particles(self.world, "fx/wpnfx_sword_spark_parry", particle_position)
	end
end)
table.insert(ProcEvents, "on_timed_block_long")


--[[
███████╗██╗██╗░░██╗███████╗░██████╗
██╔════╝██║╚██╗██╔╝██╔════╝██╔════╝
█████╗░░██║░╚███╔╝░█████╗░░╚█████╗░
██╔══╝░░██║░██╔██╗░██╔══╝░░░╚═══██╗
██║░░░░░██║██╔╝╚██╗███████╗██████╔╝
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░
]]

--Firebomb fix
mod:add_buff_template("burning_dot_fire_grenade", {
	duration = 6,
	name = "burning dot",
	end_flow_event = "smoke",
	start_flow_event = "burn",
	death_flow_event = "burn_death",
	 update_start_delay = 0.75,
	apply_buff_func = "start_dot_damage",
	time_between_dot_damages = 1,
	damage_type = "burninating",
	damage_profile = "burning_dot_firegrenade",
	update_func = "apply_dot_damage",
	perks = { buff_perks.burning }
})
DamageProfileTemplates.burning_dot_firegrenade.default_target.armor_modifier.attack[6] = 0.25

--Fix Hero Time not proccing if ally already disabled
mod:add_buff_function("markus_knight_movespeed_on_incapacitated_ally", function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    local side = Managers.state.side.side_by_unit[owner_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local num_units = #player_and_bot_units
    local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
    local buff_system = Managers.state.entity:system("buff_system")
    local template = buff.template
    local buff_to_add = template.buff_to_add
    local disabled_allies = 0

    for i = 1, num_units, 1 do
        local unit = player_and_bot_units[i]
        local status_extension = ScriptUnit.extension(unit, "status_system")
        local is_disabled = status_extension:is_disabled()

        if is_disabled then
            disabled_allies = disabled_allies + 1
        end
    end

	if not buff.disabled_allies then
		buff.disabled_allies = 0
	end

    if buff_extension:has_buff_type(buff_to_add) then
        if disabled_allies <= buff.disabled_allies then
            local buff_id = buff.buff_id

            if buff_id then
                buff_system:remove_server_controlled_buff(owner_unit, buff_id)

                buff.buff_id = nil
            end
        end
    elseif disabled_allies > 0 and disabled_allies > buff.disabled_allies then
        buff.buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
    end

	buff.disabled_allies = disabled_allies
end)
