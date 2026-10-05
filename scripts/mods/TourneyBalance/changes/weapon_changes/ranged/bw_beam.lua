local mod = get_mod("TourneyBalance")

--[[
    Beam
]]
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

