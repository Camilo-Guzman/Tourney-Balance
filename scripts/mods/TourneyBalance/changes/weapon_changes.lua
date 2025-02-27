local mod = get_mod("TourneyBalance")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[

██████╗░░█████╗░███╗░░██╗░██████╗░███████╗██████╗░
██╔══██╗██╔══██╗████╗░██║██╔════╝░██╔════╝██╔══██╗
██████╔╝███████║██╔██╗██║██║░░██╗░█████╗░░██║░░██║
██╔══██╗██╔══██║██║╚████║██║░░╚██╗██╔══╝░░██║░░██║
██║░░██║██║░░██║██║░╚███║╚██████╔╝███████╗██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝░╚═════╝░╚══════╝╚═════╝░

]]

--[[

	GENERAL

]]
-- Flamethrowers (Flamestorm and Drakegun)
Weapons.drakegun_template_1.actions.action_one.shoot_charged.damage_interval = 0.30
Weapons.staff_flamethrower_template .actions.action_one.shoot_charged.damage_interval = 0.30

local POSITION_TWEAK = -1.5
local SPRAY_RANGE = math.abs(POSITION_TWEAK) + 10
local MAX_TARGETS = 19

mod:hook_origin(ActionFlamethrower, "_select_targets", function (self, world, show_outline)
    local owner_unit = self.owner_unit
	local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
	local position_offset = Vector3(0, 0, -0.4)
	local player_position = first_person_extension:current_position() + position_offset
	local first_person_unit = self.first_person_unit
	local player_rotation = Unit.world_rotation(first_person_unit, 0)
	local player_direction = Vector3.normalize(Quaternion.forward(player_rotation))
	local ignore_hitting_allies = not Managers.state.difficulty:get_difficulty_settings().friendly_fire_ranged
	local start_point = player_position + player_direction * POSITION_TWEAK
	local broadphase_radius = 6
	local blackboard = BLACKBOARDS[owner_unit]
	local side = blackboard.side
	local ai_units = {}
	local ai_units_n = AiUtils.broadphase_query(player_position + player_direction * broadphase_radius, broadphase_radius, ai_units)
	local physics_world = World.get_data(world, "physics_world")

	PhysicsWorld.prepare_actors_for_overlap(physics_world, start_point, SPRAY_RANGE * SPRAY_RANGE)

	if ai_units_n > 0 then
		local targets = self.targets
		local v, q, m = Script.temp_count()
		local num_hit = 0

		for i = 1, ai_units_n do
			local hit_unit = ai_units[i]
			local hit_position = POSITION_LOOKUP[hit_unit] + Vector3.up()

			if targets[hit_unit] == nil then
				local is_enemy = side.enemy_units_lookup[hit_unit]

				if (is_enemy or not ignore_hitting_allies) and self:_is_infront_player(player_position, player_direction, hit_position) and self:_check_within_cone(start_point, player_direction, hit_unit, is_enemy) then
					targets[#targets + 1] = hit_unit
					targets[hit_unit] = false

					if is_enemy and ScriptUnit.extension(hit_unit, "health_system"):is_alive() then
						num_hit = num_hit + 1
					end
				end

				if MAX_TARGETS <= num_hit then
					break
				end
			end
		end

		Script.set_temp_count(v, q, m)
	end
end)

-- Handgun (Bardin and Kruber)
local handgun_dropoff_ranges = {
	dropoff_end = 100,
	dropoff_start = 50,
}
DamageProfileTemplates.shot_sniper.default_target.range_modifier_settings = handgun_dropoff_ranges


--[[

	KRUBER

]]

-- Manbow
function add_chain_actions(action_no, action_from, new_data)
    local value = "allowed_chain_actions"
    local row = #action_no[action_from][value] + 1
    action_no[action_from][value][row] = new_data
end

for _, weapon in ipairs{
    "longbow_empire_template",
} do
    local weapon_template = Weapons[weapon]
    local action_one = weapon_template.actions.action_one
    local action_two = weapon_template.actions.action_two
    add_chain_actions(action_one, "shoot_charged_heavy", {
        sub_action = "default",
        start_time = 0, -- 0.3
        action = "action_wield",
        input = "action_wield",
        end_time = math.huge
    })
end

Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].start_time = 0.25
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].sub_action = "default"
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].action = "action_one"
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].release_required = "action_two_hold"
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].input = "action_one"

Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.reload_event_delay_time = 0.1
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.override_reload_time = nil
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[2].start_time = 0.68

Weapons.longbow_empire_template.actions.action_one.default.allowed_chain_actions[2].start_time = 0.4
Weapons.longbow_empire_template.actions.action_one.default.override_reload_time = 0.15
Weapons.longbow_empire_template.actions.action_two.default.heavy_aim_flow_delay = nil
Weapons.longbow_empire_template.actions.action_two.default.heavy_aim_flow_event = nil
Weapons.longbow_empire_template.actions.action_two.default.aim_zoom_delay = 100
Weapons.longbow_empire_template.ammo_data.reload_time = 0
Weapons.longbow_empire_template.ammo_data.reload_on_ammo_pickup = true

SpreadTemplates.empire_longbow.continuous.still = {max_yaw = 0.25, max_pitch = 0.25 }
SpreadTemplates.empire_longbow.continuous.moving = {max_yaw = 0.4, max_pitch = 0.4 }
SpreadTemplates.empire_longbow.continuous.crouch_still = {max_yaw = 0.75, max_pitch = 0.75 }
SpreadTemplates.empire_longbow.continuous.crouch_moving = {max_yaw = 2, max_pitch = 2 }
SpreadTemplates.empire_longbow.continuous.zoomed_still = {max_yaw = 0, max_pitch = 0}
SpreadTemplates.empire_longbow.continuous.zoomed_moving = {max_yaw = 0.4, max_pitch = 0.4 }
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_still = {max_yaw = 0, max_pitch = 0 }
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_moving = {max_yaw = 0.4, max_pitch = 0.4 }

function add_chain_actions(action_no, action_from, new_data)
    local value = "allowed_chain_actions"
    local row = #action_no[action_from][value] + 1
    action_no[action_from][value][row] = new_data
end

for _, weapon in ipairs{
    "longbow_empire_template",
} do
    local weapon_template = Weapons[weapon]
    local action_one = weapon_template.actions.action_one
    local action_two = weapon_template.actions.action_two
    add_chain_actions(action_one, "shoot_charged", {
        sub_action = "default",
        start_time = 0, -- 0.3
        action = "action_wield",
        input = "action_wield",
        end_time = math.huge
    })
end

Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].start_time = 0.4
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].sub_action = "default"
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].action = "action_one"
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].release_required = "action_two_hold"
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].input = "action_one"

Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[2].start_time = 0.7
Weapons.longbow_empire_template.actions.action_one.shoot_charged.reload_event_delay_time = 0.15
Weapons.longbow_empire_template.actions.action_one.shoot_charged.override_reload_time = nil
Weapons.longbow_empire_template.actions.action_one.shoot_charged.speed = 11000

Weapons.longbow_empire_template.actions.action_two.default.aim_zoom_delay = 0.01
Weapons.longbow_empire_template.actions.action_two.default.heavy_aim_flow_event = nil
Weapons.longbow_empire_template.actions.action_two.default.default_zoom = "zoom_in_trueflight"
Weapons.longbow_empire_template.actions.action_two.default.buffed_zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }
DamageProfileTemplates.arrow_sniper_kruber.armor_modifier_near.attack = { 1, 1.25, 1.5, 1, 0.75, 0.25 }
DamageProfileTemplates.arrow_carbine.default_target.boost_curve_coefficient = 0.6 -- 1.25
DamageProfileTemplates.arrow_carbine.default_target.boost_curve_coefficient_headshot = 0.8 -- 1
DamageProfileTemplates.arrow_sniper_kruber.critical_strike.attack_armor_power_modifer = { 1, 1, 1, 1, 0.75, 0.5 }


--[[

	BARDIN
	
]]

-- Trollhammer
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack = {
	1,
	0.5,
	3,
	1,
	0.25
}
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[2] = 0.6
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[6] = 0.6
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack[1] = 0.6
Weapons.dr_deus_01_template_1.ammo_data.reload_time = 4

--Strength boost reduction
DamageProfileTemplates.dr_deus_01_explosion.default_target.boost_curve_coefficient = 0.5
DamageProfileTemplates.dr_deus_01_glance.default_target.boost_curve_coefficient = 0.5
DamageProfileTemplates.dr_deus_01_explosion.default_target.boost_curve_type = "tank_curve"
DamageProfileTemplates.dr_deus_01_glance.default_target.boost_curve_type = "tank_curve"
DamageProfileTemplates.dr_deus_01.default_target.boost_curve_coefficient = 0.5


--[[

	KERILLIAN

]]

--Hagbane
DamageProfileTemplates.poison = {
	is_dot = true,
	charge_value = "n/a",
	no_stagger_damage_reduction_ranged = true,
	no_stagger = true,
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25
	},
	armor_modifier = {
		attack = {
			1.6,
			1,
			3,
			1,
			0.5,
			0.2
		},
		impact = {
			1,
			1,
			3,
			1,
			0.5,
			0
		}
	},
	default_target = {
		attack_template = "arrow_poison_aoe",
		damage_type = "arrow_poison_dot",
		power_distribution = {
			attack = 0.035,
			impact = 0
		}
	}
}

--Javelin
DamageProfileTemplates.thrown_javelin.armor_modifier_near.attack = { 1, 0.7, 1.1, 1, 0.75, 0.25 }
DamageProfileTemplates.thrown_javelin.armor_modifier_far.attack = { 1, 0.7, 1.1, 1, 0.75, 0.25 }
DamageProfileTemplates.thrown_javelin.cleave_distribution = { attack = 0.8, impact = 0.8 }
DamageProfileTemplates.thrown_javelin.default_target = {
	boost_curve_coefficient_headshot = 1.6,
	boost_curve_type = "smiter_curve",
	boost_curve_coefficient = 1,
	attack_template = "projectile_javelin",
	power_distribution_near = {
		attack = 0.8,
		impact = 0.85
	},
	power_distribution_far = {
		attack = 0.8,
		impact = 0.85
	},
	range_modifier_settings = {	dropoff_start = 30,	dropoff_end = 50 }
}

-- Moonfirebow
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
mod:add_buff_template("we_deus_01_dot_charged", {
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

-- Swiftbow
DamageProfileTemplates.arrow_machinegun.cleave_distribution.attack = 0.25
DamageProfileTemplates.arrow_machinegun.cleave_distribution.impact = 0.25
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.attack = 0.25
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.impact = 0.25
DamageProfileTemplates.arrow_machinegun.critical_strike.attack_armor_power_modifer = {
								1,
								0.25,
								1,
								1,
								1,
								0.25,
							}
DamageProfileTemplates.arrow_machinegun.armor_modifier_near.attack = {
								1,
								0.1,
								1,
								1,
								0.5,
								0,
							}
DamageProfileTemplates.arrow_machinegun.armor_modifier_far.attack = {
								1,
								0.1,
								1,
								1,
								0.5,
								0,
							}
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_coefficient = 0.6
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_coefficient_headshot = 1
DamageProfileTemplates.arrow_machinegun.default_target.boost_curve_type = "linesman_curve"
DamageProfileTemplates.arrow_machinegun.default_target.power_distribution_near.attack = 0.3 	
DamageProfileTemplates.arrow_machinegun.default_target.power_distribution_far.attack = 0.25	
DamageProfileTemplates.arrow_machinegun.friendly_fire_multiplier = 0.15
DamageProfileTemplates.arrow_machinegun.shield_break = false

--Charged Shots
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.attack = 0.44 -- 0.5
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.far = 0.35	--0.4



--Deepwood Staff
VortexTemplates.spirit_storm.time_of_life = { 5,5 }
VortexTemplates.spirit_storm.reduce_duration_per_breed = { chaos_warrior = 0.5 }

--Staff can lift chemists
--Weapons.staff_life.actions.action_two.default.prioritized_breeds.chaos_plague_sorcerer = 1
--Breeds.chaos_plague_sorcerer.controllable = true

-- Trueflight FF crit reduced
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
	friendly_fire_multiplier = 0.25
}
DamageProfileTemplates.arrow_sniper_ability_piercing.friendly_fire_multiplier = 0.25



-- Bloodrazor Thicket 
DamageProfileTemplates.thorn_wall_explosion_improved_damage.armor_modifier.attack = {
	0.5,
	0.1,
	2,
	0.75,
	0.3,
	0.25
}
BuffTemplates.thorn_sister_wall_bleed.buffs[1].duration = 3

--[[

	SALTZPYRE

]]

--Bounty Shotgun ability FF reduction
DamageProfileTemplates.shot_shotgun_ability.critical_strike.attack_armor_power_modifer = { 1, 0.1, 0.2, 0, 1, 0.025 }
DamageProfileTemplates.shot_shotgun_ability.critical_strike.impact_armor_power_modifer = { 1, 0.5, 200, 0, 1, 0.05 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.attack = { 1, 0.1, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.impact = { 1, 0.5, 200, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.attack = { 1, 0, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.impact = { 1, 0.5, 200, 0, 1, 0 }

--Duck foot
local balanced_barrels =  { {	yaw = -1, pitch = 0, shot_count = 2 }, { yaw = -0.5, pitch = 0, shot_count = 2 },	{ yaw = 0, pitch = 0, shot_count = 4 }, { yaw = 0.5,  pitch = 0, shot_count = 2 }, { yaw = 1, pitch = 0, shot_count = 2 } }
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels = balanced_barrels
DamageProfileTemplates.shot_duckfoot.cleave_distribution.attack = 0.05
DamageProfileTemplates.shot_duckfoot.cleave_distribution.impact = 0.05

-- Brace of Pistols buff
Weapons.brace_of_pistols_template_1.ammo_data.max_ammo = 50
Weapons.brace_of_pistols_template_1.ammo_data.reload_time = 0.8

--[[

	SIENNA

]]

--Bolt
DamageProfileTemplates.fire_spear_3.armor_modifier_near.attack = { 1.01, 0.8, 1.5, 1, 1, 0.4 }
DamageProfileTemplates.fire_spear_3.armor_modifier_far.attack = { 1.01, 0.8, 1.5, 1, 1, 0.4 }

--Beam
DamageProfileTemplates.beam_shot.default_target.power_distribution_near.attack = 0.85
Weapons.staff_blast_beam_template_1.actions.action_two.default.aim_zoom_delay = 0.01
Weapons.staff_blast_beam_template_1.actions.action_one.default.default_zoom = "zoom_in"
Weapons.staff_blast_beam_template_1.actions.action_one.default.zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }
Weapons.staff_blast_beam_template_1.actions.action_one.default.zoom_condition_function = function ()
	return true
end
PlayerUnitStatusSettings.overcharge_values.beam_staff_shotgun = 5
Weapons.staff_blast_beam_template_1.actions.action_two.charged_beam.spread_template_override = "spear"
Weapons.staff_blast_beam_template_1.actions.action_two.charged_beam.damage_window_start = 0.01
Weapons.staff_blast_beam_template_1.actions.action_one.shoot_charged.damage_profile = "beam_blast"
local carbine_dropoff_ranges = {
	dropoff_start = 15,
	dropoff_end = 30
}
NewDamageProfileTemplates.beam_blast = {
	charge_value = "projectile",
	dot_balefire_variant = true,
	no_stagger_damage_reduction_ranged = true,
	dot_template_name = "burning_dot_1tick",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.2,
			1,
			1,
			0.7,
			0.15
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.25
		}
	},
	armor_modifier = {
		attack = {
			1,
			0,
			1,
			1,
			0.6,
			0
		},
		impact = {
			1,
			0.25,
			1,
			1,
			1,
			0
		}
	},
	cleave_distribution = {
		attack = 0.05,
		impact = 0.05
	},
	default_target = {
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient = 0.5,
		attack_template = "flame_blast",
		power_distribution_near = {
			attack = 0.1,
			impact = 0.275
		},
		power_distribution_far = {
			attack = 0.05,
			impact = 0.15
		},
		range_modifier_settings = carbine_dropoff_ranges
	}
}

local INDEX_POSITION = 1
local INDEX_ACTOR = 4

mod:hook_origin(ActionBeam, "client_owner_post_update", function(self, dt, t, world, can_damage)
	local owner_unit = self.owner_unit
	local current_action = self.current_action
	local is_server = self.is_server
	local input_extension = ScriptUnit.extension(self.owner_unit, "input_system")
	local buff_extension = self.owner_buff_extension
	local status_extension = self.status_extension

	if current_action.zoom_thresholds and input_extension:get("action_three") then
		status_extension:switch_variable_zoom(current_action.buffed_zoom_thresholds)
	end

	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
		self.state = "shooting"
	end

	self.overcharge_timer = self.overcharge_timer + dt

	if current_action.overcharge_interval <= self.overcharge_timer then
		local overcharge_amount = PlayerUnitStatusSettings.overcharge_values.charging

		self.overcharge_extension:add_charge(overcharge_amount)

		self._is_critical_strike = ActionUtils.is_critical_strike(owner_unit, current_action, t)
		self.overcharge_timer = 0
		self.overcharge_target_hit = false
	end

	if self.state == "shooting" then
		if not Managers.player:owner(self.owner_unit).bot_player and not self._rumble_effect_id then
			self._rumble_effect_id = Managers.state.controller_features:add_effect("persistent_rumble", {
				rumble_effect = "reload_start"
			})
		end

		local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
		local current_position, current_rotation = first_person_extension:get_projectile_start_position_rotation()
		local direction = Quaternion.forward(current_rotation)
		local physics_world = World.get_data(self.world, "physics_world")
		local range = current_action.range or 30
		local result = PhysicsWorld.immediate_raycast_actors(physics_world, current_position, direction, range, "static_collision_filter", "filter_player_ray_projectile_static_only", "dynamic_collision_filter", "filter_player_ray_projectile_ai_only", "dynamic_collision_filter", "filter_player_ray_projectile_hitbox_only")
		local beam_end_position = current_position + direction * range
		local hit_unit, hit_position = nil

		if result then
			local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
			local owner_player = self.owner_player
			local allow_friendly_fire = DamageUtils.allow_friendly_fire_ranged(difficulty_settings, owner_player)

			for _, hit_data in pairs(result) do
				local potential_hit_position = hit_data[INDEX_POSITION]
				local hit_actor = hit_data[INDEX_ACTOR]
				local potential_hit_unit = Actor.unit(hit_actor)
				potential_hit_unit, hit_actor = ActionUtils.redirect_shield_hit(potential_hit_unit, hit_actor)

				if potential_hit_unit ~= owner_unit then
					local breed = Unit.get_data(potential_hit_unit, "breed")
					local hit_enemy = nil

					if breed then
						local is_enemy = DamageUtils.is_enemy(owner_unit, potential_hit_unit)
						local node = Actor.node(hit_actor)
						local hit_zone = breed.hit_zones_lookup[node]
						local hit_zone_name = hit_zone.name
						hit_enemy = (allow_friendly_fire or is_enemy) and hit_zone_name ~= "afro"
					else
						hit_enemy = true
					end

					if hit_enemy then
						hit_position = potential_hit_position - direction * 0.15
						hit_unit = potential_hit_unit

						break
					end
				end
			end

			if hit_position then
				beam_end_position = hit_position
			end

			if hit_unit then
				local health_extension = ScriptUnit.has_extension(hit_unit, "health_system")

				if health_extension then
					if hit_unit ~= self.current_target then
						self.ramping_interval = 0.4
						self.damage_timer = 0
						self._num_hits = 0
					end

					if self.damage_timer >= current_action.damage_interval * self.ramping_interval then
						Managers.state.entity:system("ai_system"):alert_enemies_within_range(owner_unit, POSITION_LOOKUP[owner_unit], 5)

						self.damage_timer = 0

						if health_extension then
							self.ramping_interval = math.clamp(self.ramping_interval * 1.4, 0.45, 1.5)
						end
					end

					if self.damage_timer == 0 then
						local is_critical_strike = self._is_critical_strike
						local hud_extension = ScriptUnit.has_extension(owner_unit, "hud_system")

						self:_handle_critical_strike(is_critical_strike, buff_extension, hud_extension, first_person_extension, "on_critical_shot", nil)

						if health_extension then
							local override_damage_profile = nil
							local power_level = self.power_level
							power_level = power_level * self.ramping_interval

							if hit_unit ~= self.current_target then
								self.consecutive_hits = 0
								power_level = power_level * 0.5
								override_damage_profile = current_action.initial_damage_profile or current_action.damage_profile or "default"
							else
								self.consecutive_hits = self.consecutive_hits + 1

								if self.consecutive_hits < 3 then
									override_damage_profile = current_action.initial_damage_profile or current_action.damage_profile or "default"
								end
							end

							first_person_extension:play_hud_sound_event("staff_beam_hit_enemy", nil, false)

							local check_buffs = self._num_hits > 1

							DamageUtils.process_projectile_hit(world, self.item_name, owner_unit, is_server, result, current_action, direction, check_buffs, nil, nil, self._is_critical_strike, power_level, override_damage_profile)

							self._num_hits = self._num_hits + 1

							if not Managers.player:owner(self.owner_unit).bot_player then
								Managers.state.controller_features:add_effect("rumble", {
									rumble_effect = "hit_character_light"
								})
							end

							if health_extension:is_alive() then
								local overcharge_amount = PlayerUnitStatusSettings.overcharge_values[current_action.overcharge_type]

								if is_critical_strike and buff_extension:has_buff_perk("no_overcharge_crit") then
									overcharge_amount = 0
								end

								self.overcharge_extension:add_charge(overcharge_amount * self.ramping_interval)
							end
						end
					end

					self.damage_timer = self.damage_timer + dt
					self.current_target = hit_unit
				end
			end
		end

		if self.beam_effect_id then
			local weapon_unit = self.weapon_unit
			local end_of_staff_position = Unit.world_position(weapon_unit, Unit.node(weapon_unit, "fx_muzzle"))
			local distance = Vector3.distance(end_of_staff_position, beam_end_position)
			local beam_direction = Vector3.normalize(end_of_staff_position - beam_end_position)
			local rotation = Quaternion.look(beam_direction)

			World.move_particles(world, self.beam_effect_id, beam_end_position, rotation)
			World.set_particles_variable(world, self.beam_effect_id, self.beam_effect_length_id, Vector3(0.3, distance, 0))
			World.move_particles(world, self.beam_end_effect_id, beam_end_position, rotation)
		end
	end
end)

--Coruscation
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
mod:add_buff_template("burning_magma_dot", {
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

-- Fireball
-- Removed smokecloud on charged fireball
ExplosionTemplates.fireball_charged.explosion = {
	use_attacker_power_level = true,
	radius_min = 1.25,
	sound_event_name = "drakepistol_hit",
	radius_max = 3,
	attacker_power_level_offset = 0.25,
	max_damage_radius_min = 0.5,
	alert_enemies_radius = 10,
	damage_profile_glance = "fireball_charged_explosion_glance",
	max_damage_radius_max = 2,
	alert_enemies = true,
	damage_profile = "fireball_charged_explosion",
	effect_name = "fx/wpnfx_drake_pistols_projectile_impact"
}
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.impact_data = {
	damage_profile = "staff_fireball_charged",
	aoe = ExplosionTemplates.fireball_charged
}
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.ignore_shield_hit = true
Weapons.staff_fireball_fireball_template_1.actions.action_one.default.impact_data.damage_profile = "staff_fireball_tourney"
NewDamageProfileTemplates.staff_fireball_tourney = {
	charge_value = "projectile",
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.35,
			1.5,
			1,
			1,
			0.25,
		},
		impact_armor_power_modifer = {
			1,
			0.6,
			0,
			0,
			1,
			0.25,
		},
	},
	armor_modifier = {
		attack = {
			1,
			0.35,
			1.5,
			1,
			1,
			0,
		},
		impact = {
			1,
			0.6,
			0,
			0,
			0.5,
			0,
		},
	},
	cleave_distribution = {
		attack = 0.1,
		impact = 0.1,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_coefficient = 0.75,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "linesman_curve",
		power_distribution_near = {
			attack = 0.44, --0.35,
			impact = 0.3,
		},
		power_distribution_far = {
			attack = 0.3, --0.15,
			impact = 0.15,
		},
		range_modifier_settings = carbine_dropoff_ranges,
	},
}

DamageProfileTemplates.staff_fireball_charged.cleave_distribution.attack = 1.2
DamageProfileTemplates.staff_fireball_charged.cleave_distribution.impact = 1.2
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_near.attack = 0.375
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_far.attack = 0.375
DamageProfileTemplates.staff_fireball_charged.armor_modifier.attack[5] = 1.3

-- Conflag
DamageProfileTemplates.geiser.targets[1].power_distribution.attack = 0.5
ExplosionTemplates.conflag.aoe.duration = 10
ExplosionTemplates.conflag.aoe.damage_interval = 2

Weapons.staff_fireball_geiser_template_1.actions.action_one.default.impact_data.damage_profile = "staff_conflag_tourney"
NewDamageProfileTemplates.staff_conflag_tourney = {
	charge_value = "projectile",
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.35,
			1.5,
			1,
			1,
			0.25,
		},
		impact_armor_power_modifer = {
			1,
			0.6,
			0,
			0,
			1,
			0.25,
		},
	},
	armor_modifier = {
		attack = {
			1,
			0.35,
			1.5,
			1,
			1,
			0,
		},
		impact = {
			1,
			0.6,
			0,
			0,
			0.5,
			0,
		},
	},
	cleave_distribution = {
		attack = 0.1,
		impact = 0.1,
	},
	default_target = {
		attack_template = "fireball",
		boost_curve_coefficient = 0.75,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "linesman_curve",
		power_distribution_near = {
			attack = 0.44, --0.35,
			impact = 0.3,
		},
		power_distribution_far = {
			attack = 0.3, --0.15,
			impact = 0.15,
		},
		range_modifier_settings = carbine_dropoff_ranges,
	},
}

--Burning Head
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.attack = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.attack = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.attack_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.attack = 0.5
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.impact = 0.5
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}
DamageProfileTemplates.fire_spear_trueflight.friendly_fire_multiplier = 0 -- remove FF on Crit

--[[

███╗░░░███╗███████╗██╗░░░░░███████╗███████╗
████╗░████║██╔════╝██║░░░░░██╔════╝██╔════╝
██╔████╔██║█████╗░░██║░░░░░█████╗░░█████╗░░
██║╚██╔╝██║██╔══╝░░██║░░░░░██╔══╝░░██╔══╝░░
██║░╚═╝░██║███████╗███████╗███████╗███████╗
╚═╝░░░░░╚═╝╚══════╝╚══════╝╚══════╝╚══════╝

]]

--[[

	GENERAL

]]
-- Flail
--Light 1, 2, Bopp Attack Speed--
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_left.anim_time_scale = 1 * 1.25	-- 1.0
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_right.anim_time_scale = 1 * 1.35	-- 1.0
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1 * 1.3	-- 1.1

--Light 1, 2, 3, 4 Movement Speed--
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_left.buff_data.external_multiplier = 0.85	-- 0.75
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_right.buff_data.external_multiplier = 0.85	--0.75
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.buff_data.external_multiplier = 0.85	--0.75
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.buff_data.external_multiplier = 1.0	--0.75

--New Damage Profiles Applied--
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_down.damage_profile = "light_1h_flail_tb"
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_last.damage_profile = "light_1h_flail_tb"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack.damage_profile = "heavy_1h_flail_tb"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_flail_tb"

--Light 1, 2, Bopp Stagger Cleave
DamageProfileTemplates.light_blunt_tank_spiked.cleave_distribution.impact = 0.5			--0.25
--New Damage Profiles Flail Lights 3,4
NewDamageProfileTemplates.light_1h_flail_tb = {
	armor_modifier = {
		attack = {
			1.25,
			0.9,
			2.5,
			1,
			1,
			0.9
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.9,
			2.75,
			1,
			0.9
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 1.5,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
		[2] = {
			boost_curve_type = "smiter_curve",
			attack_template = "slashing_smiter",
			armor_modifier = {
				attack = {
					1,
					0.25,
					1,
					1,
					0.75
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	},
}

--Flail Heavy 1,2-- --Increased Target 2 Damage from 0.15 to 0.25-- --Increased Target 3 Damage from 0.075 to 0.12--
NewDamageProfileTemplates.heavy_1h_flail_tb = {
	armor_modifier = {
		attack = {
			1,
			0.25,
			1,
			1,
			0.75
		},
		impact = {
			0.75,
			0.25,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
			1.0,
			1.3,
			1.3,
			1.3
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.6,
		impact = 0.65
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "blunt_tank",
		power_distribution = {
			attack = 0.075,
			impact = 0.3
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
		[1] = {
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			boost_curve_coefficient_headshot = 1, --1.5
			armor_modifier = {
				attack = {
					1.3,
					0.8,
					1.3,
					1.3,
					1.3,
					1
				},
				impact = {
					1,
					1,
					0.5,
					1,
					0.75,
				}
			},
			power_distribution = {
				attack = 0.3,
				impact = 0.3
			}
		},
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.22, --0.25
				impact = 0.3
			}
		},
		[3] = {
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.10, --0.12
				impact = 0.3
			}
		}
	}
}

--2h Sword
--bop
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.35
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.damage_profile = "medium_slashing_smiter_2h"
--Heavies
--DamageProfileTemplates.heavy_slashing_linesman.targets[2].power_distribution.attack = 0.4
--DamageProfileTemplates.heavy_slashing_linesman.targets[2].armor_modifier = { attack = { 1, 0.4, 2, 1, 1 }, impact = { 1, 0.5, 0.5, 1, 1} }
--DamageProfileTemplates.heavy_slashing_linesman.targets[3].power_distribution.attack = 0.25
--DamageProfileTemplates.heavy_slashing_linesman.targets[4].power_distribution.attack = 0.20
--DamageProfileTemplates.heavy_slashing_linesman.default_target.power_distribution.attack = 0.14
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_two_handed_sword_heavy"
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_two_handed_sword_heavy"
NewDamageProfileTemplates.tb_two_handed_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.25,
			2,
			1,
			0.6
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.75,
		impact = 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.14,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.275
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.4,
				impact = 0.15
			},
			armor_modifier = {
				attack = { 1, 0.2, 2, 1, 0.6 },
				impact = { 1, 0.5, 0.5, 1, 1}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	}
}

--lights
--DamageProfileTemplates.medium_slashing_linesman.targets[1].power_distribution.attack = 0.275
--DamageProfileTemplates.medium_slashing_linesman.targets[2].power_distribution.attack = 0.2
--DamageProfileTemplates.medium_slashing_linesman.targets[3].power_distribution.attack = 0.15
--DamageProfileTemplates.medium_slashing_linesman.targets[1].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.medium_slashing_linesman.targets[2].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.medium_slashing_linesman.targets[3].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.medium_slashing_linesman.default_target.power_distribution.attack = 0.1
--DamageProfileTemplates.medium_slashing_linesman.cleave_distribution.impact = 0.4
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_two_handed_sword_light"
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_two_handed_sword_light"
NewDamageProfileTemplates.tb_two_handed_sword_light = {
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			1
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.3
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 1.5,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.275,
				impact = 0.15
			}
		},
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			}
		},
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.1
			}
		}
	}
}

-- 1h Axe
-- lights
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.anim_time_scale = 1.3 --1.035
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.anim_time_scale = 1.3 --1.035
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_left.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_left.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_right.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_right.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_bopp.damage_profile = "light_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_bopp.damage_profile = "light_1h_axe_tb"
NewDamageProfileTemplates.light_1h_axe_tb = {
	armor_modifier = {
		attack = {
			1.25,
			0.45,
			2.1,
			1,
			1,
			0.45
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.45,
			2.75,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 2,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets =  {
		[2] = {
			boost_curve_type = "smiter_curve",
			attack_template = "slashing_smiter",
			armor_modifier = {
				attack = {
					1,
					0.25,
					1,
					1,
					0.75
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	},
}
--Heavy
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --1
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --1
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --1
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --1

Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_axe_tb"
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.damage_profile = "heavy_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.damage_profile = "heavy_1h_axe_tb"
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.damage_profile = "heavy_1h_axe_tb"

NewDamageProfileTemplates.heavy_1h_axe_tb = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			2,
			1,
			0.75,
			1.3, -- 1,
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.75,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_blunt_smiter_2h_hammer_H",
	default_target = "default_target_slashing_smiter_finesse",
	shield_break = true,
	targets = "targets_smiter_M",
}


--2h Hammer
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_2h_hammer_heavy"
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_2h_hammer_heavy"
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_push_left_up.damage_profile = "tb_2h_hammer_heavy"
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_right.anim_time_scale = 1.2
Weapons.two_handed_hammers_template_1.actions.action_one.heavy_attack_left.anim_time_scale = 1.2

NewDamageProfileTemplates.tb_2h_hammer_heavy = {
	stagger_duration_modifier = 1.8,
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
			0.6,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.3,
		impact = 0.8
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.125
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "heavy_blunt_tank",
			power_distribution = {
				attack = 0.275,
				impact = 0.3
			},
			armor_modifier = {
				attack = {
					1.5,
					0.5,
					2,
					1,
					0.75
				},
				impact = {
					1.5,
					1,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "heavy_blunt_tank",
			power_distribution = {
				attack = 0.15,
				impact = 0.225
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.2
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75
		}
	}
}



--[[

	KRUBER

]]
--Mace and Sword
--lights 1,2
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2"
NewDamageProfileTemplates.tb_1h_hammer_light_1_2 = {
	stagger_duration_modifier = 1.25,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.75,
			0.25
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.23,
		impact = 0.6
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.225,
				impact = 0.25
			}
		},
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.175
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.35,
			1,
			1,
			0.75,
			0.25
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	}
}

--lights 3,4
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right_diagonal.damage_profile = "tb_1h_sword_light_1_2"

--Heavy
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_right = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_right = "mace_sword_heavy"
--Bopp
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_left = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_right = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.anim_time_scale = 1.15
NewDamageProfileTemplates.mace_sword_bopp = {
	stagger_duration_modifier = 1.5,
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	cleave_distribution = {
		attack = 0.2,
		impact = 0.2
	},
	armor_modifier = {
		attack = {
			1,
			0.5,
			2.5,
			1,
			0.9,
			0.5
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.075,
			impact = 0.075
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
}
NewDamageProfileTemplates.mace_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.5,
			1.5,
			1,
			0.75,
			0.5
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.6,
			0.5
		},
		impact_armor_power_modifer = {
			0.9,
			0.5,
			1,
			1,
			0.75
		}
	},
    charge_value = "heavy_attack",
    cleave_distribution = {
        attack = 0.15,
        impact = 0.3
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075,
            impact = 0.075
        }
    },
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.275,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					1.5,
					1,
					0.75,
					0.5
				},
				impact = {
					1,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			},

		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	melee_boost_override = 6
}

--1h sword
Weapons.one_handed_swords_template_1.dodge_count = 4
--light 1,2
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].boost_curve_type = "ninja_curve"
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].boost_curve_type = "ninja_curve"
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].power_distribution.attack = 0.2
--DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].power_distribution.attack = 0.15
--DamageProfileTemplates.light_slashing_linesman_finesse.default_target.power_distribution.attack = 0.125
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2"
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_sword_light_1_2"
NewDamageProfileTemplates.tb_1h_sword_light_1_2 = {
	armor_modifier = {
		attack = {
			1,
			0,
			2,
			1,
			1
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.35,
		impact = 0.2
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.125,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 2,
			attack_template = "light_slashing_linesman_hs",
			power_distribution = {
				attack = 0.2,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	},
}

--light 3
DamageProfileTemplates.light_slashing_smiter_finesse.shield_break = true
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_last.range_mod = 1.4 --1.2

--Heavies
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].armor_modifier.attack = {	1, 0.65, 2, 1, 0.75 }  --{ 1, 0.5, 1, 1, 0.75 }
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_coefficient_headshot = 1.5
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].power_distribution.attack = 0.35 --0.3
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[2].power_distribution.attack = 0.175 --0.1
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[3].power_distribution.attack = 0.1
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_left.range_mod = 1.4 --1.25
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_right.range_mod = 1.4 --1.25
DamageProfileTemplates.medium_slashing_tank_1h_finesse.cleave_distribution = "cleave_distribution_tank_L"
DamageProfileTemplates.medium_slashing_tank_1h_finesse.critical_strike = "critical_strike_stab_smiter_H"

--Halberd
--light 1
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[2].power_distribution.attack = 0.225
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[3].power_distribution.attack = 0.15
--DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.4
--DamageProfileTemplates.medium_slashing_axe_linesman.targets[1].armor_modifier.attack[1] = 1.25
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].start_time = 0.5
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.damage_profile = "tb_halberd_light_slash"
NewDamageProfileTemplates.tb_halberd_light_slash = {
	armor_modifier = "armor_modifier_axe_linesman_M",
	critical_strike = "critical_strike_axe_linesman_M",
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.25
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1.25,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.225,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.1
			}
		}
	}
}

--light 2
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile = "tb_halberd_light_stab"
NewDamageProfileTemplates.tb_halberd_light_stab = {
    charge_value = "light_attack",
	cleave_distribution = {
        attack = 0.075,
        impact = 0.075
    },
    critical_strike = {
        attack_armor_power_modifer = {
            1,
            .8,
            2.5,
            1,
            1
        },
        impact_armor_power_modifer = {
            1,
            1,
            1,
            1,
            1
        }
    },
    armor_modifier = {
        attack = {
            1,
            .7,
            2.25,
            1,
            0.75
        },
        impact = {
            1,
            0.75,
            1,
            1,
            0.75
        }
    },
    default_target = {
        boost_curve_coefficient_headshot = 2,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 1,
        attack_template = "stab_smiter",
        power_distribution = {
            attack = 0.25,
            impact = 0.125
        }
    },
    melee_boost_override = 2.5
}

--Heavy 2
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].armor_modifier.attack[1] = 1.15
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].power_distribution.attack = 0.45
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[2].power_distribution.attack = 0.35
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[3].power_distribution.attack = 0.25
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[4].power_distribution.attack = 0.15
--DamageProfileTemplates.heavy_slashing_linesman_polearm.default_target.power_distribution.attack = 0.10
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_halberd_heavy_slash"
NewDamageProfileTemplates.tb_halberd_heavy_slash = {
	armor_modifier = "armor_modifier_linesman_H",
	critical_strike = "critical_strike_linesman_H",
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_linesman_executioner_H",
	default_target =  {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			},
			armor_modifier = {
				attack = {
					1.15,
					0.5,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.35,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	},
}
--Heavy 1
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile = "tb_halberd_heavy_stab"
NewDamageProfileTemplates.tb_halberd_heavy_stab = {
    charge_value = "heavy_attack",
   	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
    critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.56,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.3,
			2,
			1,
			0.75
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75
		}
	},
	default_target = {
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "heavy_stab_smiter",
		power_distribution = {
			attack = 0.2,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 0.75,
			attack_template = "heavy_stab_smiter",
			armor_modifier = {
				attack = {
					1,
					0.56,
					2,
					1,
					0.75
				},
				impact = {
					1,
					0.65,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			}
		}
	},
	melee_boost_override = 2.5
}
--light 3 and push stab
--DamageProfileTemplates.medium_slashing_smiter_2h.default_target.boost_curve_coefficient_headshot = 2.5
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_down.damage_profile = "tb_halberd_light_chop"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_last.damage_profile = "tb_halberd_light_chop"
NewDamageProfileTemplates.tb_halberd_light_chop = {
    charge_value = "light_attack",
	cleave_distribution = {
        attack = 0.075,
        impact = 0.075
    },
    critical_strike = {
        attack_armor_power_modifer = {
            1.25,
            .76,
            2.5,
            1,
            1
        },
        impact_armor_power_modifer = {
            1,
            1,
            1,
            1,
            1
        }
    },
    armor_modifier = {
        attack = {
            1.25,
            .76,
            2.5,
            1,
            0.75
        },
        impact = {
            1,
            0.8,
            1,
            1,
            0.75
        }
    },
    default_target = {
        boost_curve_coefficient_headshot = 1.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 1,
        attack_template = "stab_smiter",
        power_distribution = {
            attack = 0.325,
            impact = 0.2
        }
    },
    melee_boost_override = 2.5,
	shield_break = true
}

--Spear and Shield
Weapons.es_deus_01_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.es_deus_01_template.actions.action_one.heavy_attack_right.damage_profile = "medium_slashing_smiter_es_01"

-- Bretonnian Longsword
--Bret Sword Light 2, Heavy 1 & 2 buffs
--1H Axe Heavy attack buff
Weapons.bastard_sword_template.actions.action_one.light_attack_right.damage_profile = "bret_sword_light_2"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_left.damage_profile = "bret_sword_heavy_1_2"
Weapons.bastard_sword_template.actions.action_one.heavy_attack_right.damage_profile = "bret_sword_heavy_1_2"
--Light
NewDamageProfileTemplates.bret_sword_light_2 = {
	armor_modifier = "armor_modifier_linesman_M",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_linesman_M",
	critical_strike = "critical_strike_linesman_M",
	default_target = "default_target_linesman_M",
	targets = {
		{
			attack_template = "slashing_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.225,
				impact = 0.15,
			},
		},
		{
			attack_template = "slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.2, -- 0.125,
				impact = 0.125,
			},
		},
		{
			attack_template = "light_slashing_linesman",
			boost_curve_type = "linesman_curve",
			power_distribution = {
				attack = 0.15, -- 0.1,
				impact = 0.1,
			},
		},
	},
}
--Heavy
NewDamageProfileTemplates.bret_sword_heavy_1_2 = {
	armor_modifier = "armor_modifier_axe_linesman_H",
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.455, -- 0.35,
		impact = 0.455, -- 0.35,
	},
	critical_strike = "critical_strike_axe_linesman_H",
	default_target = "default_target_axe_linesman_H",
	targets = "targets_axe_linesman_H",
}


--[[

	BARDIN

]]
--2h Axe
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.damage_profile = "heavy_2h_axe_tb"
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_2h_axe_tb"
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.slide_armour_hit = true --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.slide_armour_hit = true --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT --nil
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_up.anim_time_scale = 0.9 --0.81
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.1
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_bopp.damage_profile = "bopp_2h_axe_tb"
NewDamageProfileTemplates.heavy_2h_axe_tb = {
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.6,
			2,
			1,
			1,
			0.75
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.6,
		impact = 0.35
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.75,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.125
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 0.75,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.5
			},
			armor_modifier = {
				attack = {
					0.9,
					0.5,
					2,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 0.75,
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.125
			}
		}
	}
}

NewDamageProfileTemplates.bopp_2h_axe_tb = {
	armor_modifier = {
		attack = {
			0.9,
			0,
			1.5,
			1,
			0.75
		},
		impact = {
			0.9,
			0.5,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.275,
		impact = 0.6
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.075,
			impact = 0.075
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	}
}

--1h hammer
Weapons.one_handed_hammer_template_1.dodge_count = 4
Weapons.one_handed_hammer_template_2.dodge_count = 4
Weapons.one_handed_hammer_priest_template.dodge_count = 4

--light 1, 2, bop
--DamageProfileTemplates.light_blunt_tank.cleave_distribution.attack = 0.23
--DamageProfileTemplates.light_blunt_tank_diag.targets[1].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.light_blunt_tank_diag.targets[2].boost_curve_coefficient_headshot = 2
--DamageProfileTemplates.light_blunt_tank_diag.targets[1].power_distribution.attack = 0.225 --0.175
--DamageProfileTemplates.light_blunt_tank_diag.armor_modifier.attack = { 1, 0.35, 1, 1, 0.75, 0.25 } --{ 1, 0, 1, 1, 0 }
--DamageProfileTemplates.light_blunt_tank_diag.critical_strike.attack_armor_power_modifer = {	1, 0.5, 1, 0.75, 0.35 } --{ 1, 0.5, 1, 1, 0.25 }
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_left.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_01.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_right.damage_profile = "tb_1h_hammer_light_1_2"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_02.damage_profile = "tb_1h_hammer_light_1_2"

--light 3, 4
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_last.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_last.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.damage_profile = "tb_1h_hammer_light_3_4"
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.damage_profile = "tb_1h_hammer_light_3_4"
NewDamageProfileTemplates.tb_1h_hammer_light_3_4 = {
	armor_modifier = {
		attack = {
			1.25,
			0.65,
			3,
			1,
			1.25,
			0.6
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.25,
			0.75,
			2.75,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets = "targets_smiter_L"
}

--Heavies
--DamageProfileTemplates.medium_blunt_smiter_1h.armor_modifier.attack = { 1, 0.8, 2.5, 0.75, 1 } -- { 1, 0.8, 1.75, 0.75, 0.8 }
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.damage_profile = "tb_1h_hammer_heavy"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "tb_1h_hammer_heavy"
NewDamageProfileTemplates.tb_1h_hammer_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75
		}
	},
	critical_strike = "critical_strike_smiter_M",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = "default_target_smiter_M",
	targets = "targets_smiter_M",
	shield_break = true
}

--Dual Axes
--Heavies
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack.anim_time_scale = 0.925  --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_2.anim_time_scale = 1.1 --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_3.additional_critical_strike_chance = 0.2 --0
--push
Weapons.dual_wield_axes_template_1.actions.action_one.push.damage_profile_inner = "light_push"
Weapons.dual_wield_axes_template_1.actions.action_one.push.fatigue_cost = "action_stun_push"


-- Warpick
-- Animation Time for Lights reduced by 20%
-- Damage for lights reduced by approx 10%
-- Stagger Cleave set to same as damage cleave
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.anim_time_scale = 0.9 * 1.25
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.anim_time_scale = 0.9 * 1.25
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.damage_profile = "tb_warpick_lights"
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.damage_profile = "tb_warpick_lights"
Weapons.two_handed_picks_template_1.dodge_count = 3

--Heavies
--DamageProfileTemplates.heavy_blunt_smiter_charged.armor_modifier.attack[3] = 2.25
PowerLevelTemplates.armor_modifier_smiter_pick_H.attack[3] = 2.25

--Lights
NewDamageProfileTemplates.tb_warpick_lights = {
	armor_modifier = "armor_modifier_axe_linesman_M",
	critical_strike = "critical_strike_axe_linesman_M",
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.4
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.225,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1.25,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.21,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.14,
				impact = 0.1
			}
		}
	}
}


--[[

	KERILLIAN

]]
--Dual Daggers
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_left.additional_critical_strike_chance = 0.1
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_right.additional_critical_strike_chance = 0.1
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.allowed_chain_actions[5].start_time = 0.35
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.allowed_chain_actions[5].start_time = 0.35
Weapons.dual_wield_daggers_template_1.max_fatigue_points = 6

--Elf Spear
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_start = 0.27
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_end = 0.38
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_start = 0.17
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_end = 0.34
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_start = 0.19
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_end = 0.33

--Glaive
-- Buffs to push attack chain attack speed and linesman on bopp, removes linesman from heavy attack, makes both heavy attacks have the Heavy 2 profile--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.hit_mass_count = LINESMAN_HIT_MASS_COUNT	--no modifier on live--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_left_upward.anim_time_scale = 0.95*1.15		-- 1.0--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_left.anim_time_scale = 0.95*1.4			-- 1.25--
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.anim_time_scale = 0.95*1.2			-- 1.15--
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.damage_profile = "heavy_slashing_smiter_glaive"
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.hit_mass_count = NONE

--buffs cleave and stagger cleave from 8.21 and 7.46 respectively to 10.74 each --
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.36
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.impact = 0.36

--Elf 1h Sword
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.damage_profile = "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.damage_profile = "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_1h_sword_light_1_2"
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.damage_profile = "light_slashing_smiter_finesse"
Weapons.we_one_hand_sword_template_1.dodge_count = 4
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.range_mod = 1.3
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.range_mod = 1.4
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.08
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.anim_time_scale = 0.81
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[1].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].start_time = 0.5

--2h sword elf
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_bopp.anim_time_scale = 0.95
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_right_upward.anim_time_scale = 1.25
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_left_upward.anim_time_scale = 1.25
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.anim_time_scale = 1.6
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_second.anim_time_scale = 1.6
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[1].external_multiplier = 1.5
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[2].external_multiplier = 0.5
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].armor_modifier.attack = { 1, 0.9, 2.5, 1, 0.75 }
DamageProfileTemplates.heavy_slashing_smiter_stab.critical_strike.attack_armor_power_modifer = { 1, 0.9, 3, 1, 1 }
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[1].power_distribution.attack = 0.325
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[2].power_distribution.attack = 0.25
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[3].power_distribution.attack = 0.15

-- Dual Swords
-- Lights
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_left.damage_profile = "tb_dual_swords_light"
Weapons.dual_wield_swords_template_1.actions.action_one.light_attack_right.damage_profile = "tb_dual_swords_light"
NewDamageProfileTemplates.tb_dual_swords_light = {
    armor_modifier = {
        attack = {
            0.85, --1
            0,
            2,
            1,
            1
        },
        impact = {
            1,
            0.3,
            0.5,
            1,
            1
        }
    },
    critical_strike = {
        attack_armor_power_modifer = {
            0.75,
            0.5,
            1.5,
            1,
            1
        },
        impact_armor_power_modifer = {
            1,
            0.5,
            0.5,
            1,
            1
        }
    },
    charge_value = "light_attack",
    cleave_distribution = {
        attack = 0.3,
        impact = 0.2
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.125,
            impact = 0.05
        }
    },
    targets = {
        {
            boost_curve_coefficient_headshot = 2,
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient = 2,
            attack_template = "light_slashing_linesman_hs",
            power_distribution = {
                attack = 0.2,
                impact = 0.1
            }
        },
        {
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient_headshot = 2,
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.15,
                impact = 0.075
            }
        }
    },
}

-- Heavy
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_right = "tb_dual_swords_heavy"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.damage_profile_left = "tb_dual_swords_heavy"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_right = "tb_dual_swords_heavy_1"
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.damage_profile_left = "tb_dual_swords_heavy_1"
NewDamageProfileTemplates.tb_dual_swords_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.25,
			2,
			1,
			0.6
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.45,
		impact = 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.07,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.3,
				impact = 0.275
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.15
			},
			armor_modifier = {
				attack = { 1, 0.2, 2, 1, 0.6 },
				impact = { 1, 0.5, 0.5, 1, 1}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.125,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	}
}
NewDamageProfileTemplates.tb_dual_swords_heavy_1 = {
	armor_modifier = {
		attack = {
			0.75,		--1
			0.25,
			2,
			1,
			0.5		--0.6
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.45,
		impact = 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.07,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.3,
				impact = 0.275
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.15
			},
			armor_modifier = {
				attack = { 1, 0.2, 2, 1, 0.6 },
				impact = { 1, 0.5, 0.5, 1, 1}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.125,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	}
}

--[[

	SALTZPYRE

]]
--2h Hammer Priest
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "tb_2h_hammer_light_3_priest"
Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "tb_2h_hammer_heavy_2_priest"
DamageProfileTemplates.priest_hammer_heavy_blunt_tank_upper.targets[2].power_distribution.attack = 0.1
DamageProfileTemplates.priest_hammer_blunt_smiter.armor_modifier.attack[2] = 2.025
DamageProfileTemplates.priest_hammer_blunt_smiter.armor_modifier.attack[6] = 1.2
DamageProfileTemplates.priest_hammer_blunt_smiter.critical_strike.attack_armor_power_modifer[2] = 1.8
NewDamageProfileTemplates.tb_2h_hammer_light_3_priest = {
	stagger_duration_modifier = 1.5,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.3,
		impact = 0.8
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.2
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.2,
			1,
			1,
			0.75
		},
		impact = {
			1,
			1,
			0.5,
			1,
			0.75
		}
	}
}

NewDamageProfileTemplates.tb_2h_hammer_heavy_2_priest = {
	stagger_duration_modifier = 1.8,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.6,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.8
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.125
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "heavy_blunt_tank",
			power_distribution = {
				attack = 0.5,
				impact = 0.3
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					2,
					1,
					0.75
				},
				impact = {
					1.5,
					1,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "heavy_blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.225
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.2
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75
		}
	}
}

--Falchion
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_left.damage_profile = "tb_falchion_lights"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_right.damage_profile = "tb_falchion_lights"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_bopp.damage_profile = "tb_falchion_lights"
Weapons.one_hand_falchion_template_1.actions.action_one.light_attack_down.damage_profile = "light_slashing_smiter_finesse"

NewDamageProfileTemplates.tb_falchion_lights = {
	armor_modifier = {
		attack = {
			1,
			0.2,
			2,
			1,
			1
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.3,
		impact = 0.2
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.125,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 2,
			attack_template = "light_slashing_linesman_hs",
			power_distribution = {
				attack = 0.2,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient_headshot = 2,
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	},
}

-- Axe and Falchion
-- Buff to Super Armor
DamageProfileTemplates.light_slashing_smiter_dual.armor_modifier.attack[6] = 0.82
-- buff to Armor to give 2SHS w/ 50% hs rate, assassin and 10% on charm
DamageProfileTemplates.light_slashing_smiter_dual.armor_modifier.attack[2] = 0.82
-- Linesman added to falchion lights (not PA).
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_right_diagonal.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = LINESMAN_HIT_MASS_COUNT
-- Linesman removed from push attack
Weapons.dual_wield_axe_falchion_template.actions.action_one.light_attack_bopp.hit_mass_count = NONE

--[[

	SIENNA

]]
--Crowbill
Weapons.one_handed_crowbill.actions.action_one.heavy_attack.damage_profile = "crowbill_heavy_1"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_left.damage_profile = "crowbill_heavy_2"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_right_up.damage_profile = "crowbill_heavy_3"
Weapons.one_handed_crowbill.actions.action_one.light_attack_last.damage_profile = "crowbill_light_1"
Weapons.one_handed_crowbill.actions.action_one.light_attack_upper.damage_profile = "crowbill_light_2"
Weapons.one_handed_crowbill.actions.action_one.light_attack_right.damage_profile = "crowbill_light_3"
Weapons.one_handed_crowbill.actions.action_one.light_attack_left.damage_profile = "crowbill_light_4"
Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.damage_profile = "crowbill_push_attack"
Weapons.one_handed_crowbill.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.05

NewDamageProfileTemplates.crowbill_heavy_1 = { -- high damage, very difficult to headshot with
	armor_modifier = {
		attack = {
			1.66, -- 1
			1.2, -- 0.9
			2,
			1,
			1,
			1.2, -- 0.9
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.5,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.25, -- 1
			0.93, -- 0.8
			2.5,
			1,
			1,
			1, -- 0.8
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_coefficient = 1,
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.325,
				impact = 0.21,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.25,
				impact = 0.175,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.175,
				impact = 0.14,
			},
		},
	},
	shield_break = true,
}
NewDamageProfileTemplates.crowbill_heavy_2 = { -- lots of crit cleave
	armor_modifier = {
		attack = {
			1.3, -- 1
			0.9,
			2,
			1,
			1,
			0.9,
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.5,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.77, -- 1
			2,
			1,
			0.83, -- 1
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_coefficient = 1,
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.34,
				impact = 0.22,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.28,
				impact = 0.19,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.22,
				impact = 0.16,
			},
		},
		{
			attack_template = "slashing_smiter",
			boost_curve_coefficient = 2,
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.16,
				impact = 0.13,
			},
		},
	},
	shield_break = true,
}
NewDamageProfileTemplates.crowbill_heavy_3 = { -- high headshot damage,
	armor_modifier = {
		attack = {
			1,
			0.8,
			1.75,
			1,
			0.83, -- 0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75,
			1,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.73, -- 0.8
			1.75, -- 2.5
			1,
			1,
			0.8,
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "light_blunt_tank",
		boost_curve_type = "tank_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.1,
		},
	},
	targets = {
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 2, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.4,
				impact = 0.25,
			},
		},
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.75, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.325,
				impact = 0.21,
			},
		},
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.5, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.25,
				impact = 0.175,
			},
		},
		{
			attack_template = "blunt_linesman",
			boost_curve_coefficient = 2,
			boost_curve_coefficient_headshot = 1.25, -- 1
			boost_curve_type = "smiter_curve",
			power_distribution = {
				attack = 0.175,
				impact = 0.14,
			},
		},
	},
	shield_break = true,
}
NewDamageProfileTemplates.crowbill_light_1 = {
	armor_modifier = {
		attack = {
			1.143, -- 1
			1,
			2,
			1,
			1,
			0.85, -- 0.5
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.1, -- 1
			0.94, -- 1
			1.8, -- 2
			1,
			1,
			0.9, -- 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.21, -- 0.175
				impact = 0.1,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.32,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.165,
				impact = 0.091,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.16,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.12,
				impact = 0.082,
			},
		},
	},
}
NewDamageProfileTemplates.crowbill_light_2 = { -- Needs to do more damage than Light 1 to avoid Light 1->BC shennanigans
	armor_modifier = {
		attack = {
			1.14, -- 1
			1.06, -- 1
			2,
			1,
			1.05, -- 1, 1.32
			0.85, -- 0.5
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
			0.5,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.94, -- 1
			2,
			1,
			0.97, -- 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.245, -- 0.175
				impact = 0.1,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.4,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.211, -- 0.175
				impact = 0.095,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.3,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.177, -- 0.175
				impact = 0.09,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.2,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.143, -- 0.175
				impact = 0.085,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.1,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.109, -- 0.175
				impact = 0.08,
			},
		},
	},
}
NewDamageProfileTemplates.crowbill_light_3 = {
	armor_modifier = {
		attack = {
			1.2, -- 1
			1.1, -- 1
			2,
			1,
			1.1, -- 1
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = {
		attack_armor_power_modifer = {
			1.1, -- 1
			1,
			2,
			1,
			1,
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
		},
	},
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.255, -- 0.175, 0.237
				impact = 0.1,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.375,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.21, -- 0.175, 0.237
				impact = 0.094,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.25,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.165, -- 0.175, 0.237
				impact = 0.087,
			},
		},
		{	
			attack_template = "blunt_linesman",
			boost_curve_coefficient_headshot = 1.125,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.120, -- 0.175, 0.237
				impact = 0.081,
			},
		},
	}
}
NewDamageProfileTemplates.crowbill_light_4 = { -- high headshot damage, low bodyshot damage
	armor_modifier = {
		attack = {
			1, -- 1
			1.1, -- 0.5
			2.2, -- 1.5
			1,
			1.1, -- 0.75
			1.25, -- 0.5
		},
		impact = {
			1,
			1.25,
			1,
			1,
			0.75,
		},
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1, -- 0.5
			2,
			1,
			1,
			1.1, -- 1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1,
		},
	},
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	default_target = {
		attack_template = "stab_smiter",
		boost_curve_coefficient = 0.75,
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.1,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "burning_stab_fencer",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2.5, -- 1.5
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.2,
				impact = 0.2,
			},
		},
		{
			attack_template = "burning_stab_fencer",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2.32, -- 1.5
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.167,
				impact = 0.158,
			},
		},
		{
			attack_template = "burning_stab_fencer",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 2.16, -- 1.5
			boost_curve_type = "ninja_curve",
			dot_balefire_variant = true,
			dot_template_name = "burning_dot_3tick",
			power_distribution = {
				attack = 0.133,
				impact = 0.118,
			},
		},
	}
}
NewDamageProfileTemplates.crowbill_push_attack = { -- 5% crit chance to give this attack a reason to exist, should help necro
	armor_modifier = "armor_modifier_pointy_smiter_L",
	charge_value = "light_attack",
	cleave_distribution = "cleave_distribution_smiter_default",
	critical_strike = "critical_strike_pointy_smiter_L",
	default_target = {
		attack_template = "slashing_smiter",
		boost_curve_type = "smiter_curve",
		power_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
	},
	targets = {
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.175,
				impact = 0.1,
			},
		},
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.375,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.15,
				impact = 0.094,
			},
		},
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.25,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.125,
				impact = 0.088,
			},
		},
		{
			attack_template = "blunt_tank_uppercut",
			boost_curve_coefficient_headshot = 1.125,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.1,
				impact = 0.082,
			},
		},
	}
}



--Scythe
Weapons.staff_scythe.actions.action_one.heavy_attack_01.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT
Weapons.staff_scythe.actions.action_one.heavy_attack_02.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT

Weapons.staff_scythe.actions.action_one.light_attack_03.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.staff_scythe.actions.action_one.light_attack_04.hit_mass_count = LINESMAN_HIT_MASS_COUNT

local STATE_SCYTHE = "scythe"

DamageProfileTemplates.heavy_slashing_linesman_scythe_diagonal.targets[1].power_distribution.attack = 0.55    --original 0.5

Weapons.staff_scythe.actions.action_one.light_attack_01.weapon_mode_overrides[STATE_SCYTHE].damage_profile = "medium_slashing_smiter"    --bret L3
Weapons.staff_scythe.actions.action_one.light_attack_02.weapon_mode_overrides[STATE_SCYTHE].damage_profile = "staff_scythe_L2_PA"
Weapons.staff_scythe.actions.action_one.light_attack_bopp.weapon_mode_overrides[STATE_SCYTHE].damage_profile = "staff_scythe_L2_PA"

NewDamageProfileTemplates.staff_scythe_L2_PA = {
    critical_strike = {
        -- attack_armor_power_modifer = { 1, 0.5, 1.5, 1, 1 },
        attack_armor_power_modifer = { 1, 0.8, 2.5, 1, 1 },
        impact_armor_power_modifer = { 1, 1, 1, 1, 1 }
    },
	charge_value = "light_attack",
    cleave_distribution = {
        attack = 0.275,
        impact = 0.25
    },
    armor_modifier = {
        attack = { 0.9, 0, 1.8, 1, 0.75 },
        impact = { 0.9, 0.5, 1, 1, 0.75 }
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075,
            impact = 0.075
        }
    },
    targets = {
        {
            -- boost_curve_coefficient_headshot = 1.5,    --deleted
            boost_curve_coefficient = 2,    --added
            dot_template_name = "burning_dot_3tick",
            dot_balefire_variant = true,
            boost_curve_type = "linesman_curve",
            attack_template = "heavy_slashing_linesman",
            power_distribution = {
                attack = 0.4,    --0.25
                impact = 0.25    --0.2
            },
            armor_modifier = {
                -- attack = { 1, 0.5, 1.8, 1, 0.75 },
                -- impact = { 0.9, 0.75, 1, 1, 0.75 }
                attack = { 1, 0.8, 1.75, 1, 0.75 },
                impact = { 1, 0.6, 1, 1, 0.75 }
            }
        },
        {
            dot_template_name = "burning_dot_3tick",
            dot_balefire_variant = true,
            boost_curve_type = "linesman_curve",
            attack_template = "slashing_linesman",
            power_distribution = {
                attack = 0.15,
                impact = 0.125
            }
        },
        {
            boost_curve_type = "linesman_curve",
            attack_template = "light_slashing_linesman",
            power_distribution = {
                attack = 0.1,
                impact = 0.1
            }
        }
    }
}

DamageProfileTemplates.scythe_discharge = {
	no_stagger_damage_reduction = true,
	charge_value = "heavy_attack",
	is_discharge = true,
	armor_modifier = {
		attack = {
			1,
			0.25,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75,
			0
		}
	},
	default_target = {
		attack_template = "drakegun",
		damage_type = "drakegun",
		power_distribution = {
			attack = 0.07,
			impact = 0.3-- 0.5 (Contols the stagger strength)
		}
	}
}

--Wiz Mace
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.range_mod = 1.75
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.range_mod = 1.75
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.range_mod = 1.5
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.slide_armour_hit = true
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.slide_armour_hit = true

Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_last.damage_profile = "light_blunt_smiter_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.damage_profile = "light_blunt_smiter_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.damage_profile = "light_blunt_tank_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_right.damage_profile = "light_blunt_tank_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.damage_profile = "light_blunt_tank_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack.damage_profile = "medium_blunt_smiter_heavy_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.damage_profile = "medium_blunt_tank_upper_1h_wiz"
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.damage_profile = "medium_blunt_tank_upper_1h_wiz"

NewDamageProfileTemplates.medium_blunt_tank_upper_1h_wiz = {
	stagger_duration_modifier = 1.5,
	critical_strike = {
		attack_armor_power_modifer = {
			1.2,
			1,
			1.3,
			1.3,
			1.2
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.6,
		impact = 0.65
	},
	default_target = {
		boost_curve_type = "tank_curve",
		stagger_duration_modifier = 1.5,
		boost_curve_coefficient_headshot = 1.4,
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.3,
				impact = 0.3
			}
		},
		{
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.15,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "tank_curve",
			stagger_duration_modifier = 1.5,
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
	armor_modifier = {
		attack = {
			1.5,
			0.8,
			1.3,
			1.3,
			1.6
		},
		impact = {
			1,
			1,
			0.5,
			1,
			0.75
		}
	},
}

NewDamageProfileTemplates.medium_blunt_smiter_heavy_wiz = {
	armor_modifier = {
		attack = {
			1,
			0.9,
			1.75,
			1,
			0.75
		},
		impact = {
			1,
			0.8,
			1,
			1,
			0.7
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		boost_curve_coefficient_headshot = 1.1,
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.4,
			impact = 0.25
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	shield_break = true
}

NewDamageProfileTemplates.light_blunt_tank_wiz = {
	stagger_duration_modifier = 1.25,
	critical_strike = {
		attack_armor_power_modifer = {
			1.3,
			0.25,
			1.5,
			1,
			1.2
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.2,
		impact = 0.6
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		boost_curve_coefficient_headshot = 1.4,
		power_distribution = {
			attack = 0.05,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1.5,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.175,
				impact = 0.25
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.175
			}
		}
	},
	armor_modifier = {
		attack = {
			1.8,
			0,
			1,
			1,
			1.6
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	}
}

NewDamageProfileTemplates.light_blunt_smiter_wiz = {
	armor_modifier = {
		attack = {
			1.5,
			1.1,
			2.5,
			1,
			1.4,
			0.6
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0.25
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1.2,
			0.9,
			2.75,
			1,
			1.2
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		attack_template = "slashing_smiter",
		boost_curve_coefficient_headshot = 1.2,
		power_distribution = {
			attack = 0.25,
			impact = 0.175
		}
	},
	ignore_stagger_reduction = true,
	targets = {
		[2] = {
			boost_curve_type = "smiter_curve",
			attack_template = "slashing_smiter",
			armor_modifier = {
				attack = {
					1,
					0.25,
					1,
					1,
					0.75
				},
				impact = {
					0.75,
					0.25,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.075,
				impact = 0.075
			}
		}
	}
}

--Flaming Flail
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_left.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.heavy_attack.anim_time_scale = 1
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.impact = 0.375
--DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.attack = 0.06
DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.impact = 0.25
--DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.attack = 0.25


--[[

███████╗██╗██╗░░██╗███████╗░██████╗
██╔════╝██║╚██╗██╔╝██╔════╝██╔════╝
█████╗░░██║░╚███╔╝░█████╗░░╚█████╗░
██╔══╝░░██║░██╔██╗░██╔══╝░░░╚═══██╗
██║░░░░░██║██╔╝╚██╗███████╗██████╔╝
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░

]]

--Shield crit fix
DamageProfileTemplates.shield_slam_target = {
	stagger_duration_modifier = 1.75,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			2
		}
	},
	charge_value = "heavy_attack",
	shield_break = true,
	default_target = "default_target_slam_target_tank_M",
	armor_modifier = "armor_modifier_slam_target_tank_M"
}
DamageProfileTemplates.shield_slam = {
	stagger_duration_modifier = 1.75,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1.5
		}
	},
	charge_value = "heavy_attack",
	armor_modifier = "armor_modifier_slam_tank_M",
	default_target = "default_target_slam_tank_M"
}

--Weapon Swap Fixes (moonfire, Coru, MWP, Jav)
Weapons.we_deus_01_template_1.actions.action_one.default.total_time = 0.7
Weapons.we_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time =  0.4
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.total_time = 0.55
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.allowed_chain_actions[1].start_time = 0.45
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.total_time = 0.5 Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.allowed_chain_actions[1].start_time = 0.4

Weapons.bw_deus_01_template_1.actions.action_two.default.allowed_chain_actions[1].start_time = 0

Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.total_time = 0.3
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.allowed_chain_actions[1].start_time =  0.3

Weapons.javelin_template.actions.action_one.throw_charged.allowed_chain_actions[2].start_time = 0.3
Weapons.javelin_template.actions.action_one.default.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.default_left.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.default_chain_01.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.default_chain_02.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.default_chain_03.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.stab_01.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.stab_02.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.chain_stab_03.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.heavy_stab.allowed_chain_actions[2].start_time = 0.45

--Coghammer weapon swap buffer fix
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default = {
	aim_assist_ramp_decay_delay = 0.1,
	anim_end_event = "attack_finished",
	kind = "melee_start",
	attack_hold_input = "action_one_hold",
	aim_assist_max_ramp_multiplier = 0.4,
	aim_assist_ramp_multiplier = 0.2,
	anim_event = "attack_swing_charge",
	anim_end_event_condition_func = function (unit, end_reason)
		return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
	end,
	total_time = math.huge,
	buff_data = {
		{
			start_time = 0,
			external_multiplier = 0.6,
			buff_name = "planted_charging_decrease_movement"
		}
	},
	allowed_chain_actions = {
		{
			sub_action = "light_attack_left",
			start_time = 0,
			end_time = 0.3,
			action = "action_one",
			input = "action_one_release"
		},
		{
			sub_action = "heavy_attack_left",
			start_time = 0.6,
			end_time = 1.2,
			action = "action_one",
			input = "action_one_release"
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_two",
			input = "action_two_hold"
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_wield",
			input = "action_wield"
		},
		{
			start_time = 0.6,
			end_time = 1.2,
			blocker = true,
			input = "action_one_hold"
		},
		{
			sub_action = "heavy_attack_left",
			start_time = 1,
			action = "action_one",
			auto_chain = true
		}
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions = {
	{
		sub_action = "light_attack_right",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_right",
		start_time =1,
		action = "action_one",
		auto_chain = true
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions = {
	{
		sub_action = "light_attack_last",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_left",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_left",
		start_time = 1,
		action = "action_one",
		auto_chain = true
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions = {
	{
		sub_action = "light_attack_up_right_last",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 1,
		action = "action_one",
		auto_chain = true
	}
}
--Lights 1/2/3/4
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.anim_event = "attack_swing_up_pose"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep = {
	{
		0.31666666666666665,
		0.3103722333908081,
		0.5904569625854492,
		-0.2657968997955322,
		0.7223937511444092,
		-0.29107052087783813,
		0.5494855046272278,
		0.302474707365036
	},
	{
		0.35277777777777775,
		0.1775137186050415,
		0.6366815567016602,
		-0.19225668907165527,
		0.7879757285118103,
		-0.14280153810977936,
		0.5783776640892029,
		0.1555033177137375
	},
	{
		0.3888888888888889,
		0.051915526390075684,
		0.6041536331176758,
		-0.08548450469970703,
		0.8273890018463135,
		-0.0234444011002779,
		0.5306860208511353,
		-0.18234620988368988
	},
	{
		0.425,
		-0.12680041790008545,
		0.4566812515258789,
		-0.04089641571044922,
		0.6963638663291931,
		0.19201868772506714,
		0.41889646649360657,
		-0.5502110719680786
	},
	{
		0.46111111111111114,
		-0.26615601778030396,
		0.21436119079589844,
		-0.12140655517578125,
		0.37910813093185425,
		0.4430711269378662,
		0.2820264995098114,
		-0.7618570327758789
	},
	{
		0.49722222222222223,
		-0.1962783932685852,
		0.1402301788330078,
		-0.22664093971252441,
		0.17541848123073578,
		0.5380390882492065,
		0.08140674978494644,
		-0.8204360008239746
	},
	{
		0.5333333333333333,
		-0.13591063022613525,
		0.1464986801147461,
		-0.29386401176452637,
		0.0605529323220253,
		0.579397976398468,
		-0.1304379105567932,
		-0.8022575974464417
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions = {
	{
		sub_action = "default_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions = {
	{
		sub_action = "default_last",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_last",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
--Pushstab
Weapons.two_handed_cog_hammers_template_1.actions.action_one.push.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_one",
		release_required = "action_two_hold",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_one",
		release_required = "action_two_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "light_attack_bopp",
		start_time = 0.4,
		action = "action_one",
		end_time = 0.8,
		input = "action_one_hold",
		hold_required = {
			"action_two_hold",
			"action_one_hold"
		}
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_two",
		send_buffer = true,
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.75,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.75,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.5,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.5,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		action = "action_wield",
		input = "action_wield"
	}
}
--Heavies
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 2.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 2.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.75,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions = {
	{
		sub_action = "default_right",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one"
	},
	{
		sub_action = "default_right",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.75,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}


