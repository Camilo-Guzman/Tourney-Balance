local mod = get_mod("TourneyBalance")

-- Fixed getting unlimited thp on Vanguard when using slam
mod:hook_origin(ActionShieldSlam, "_hit", function (self, world, can_damage, owner_unit, current_action)
	local network_manager = Managers.state.network
	local physics_world = World.get_data(world, "physics_world")
	local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
	local first_person_unit = self.first_person_unit
	local unit_forward = Quaternion.forward(Unit.local_rotation(first_person_unit, 0))
	local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
	local self_pos = first_person_extension:current_position()
	local forward_offset = current_action.forward_offset or 1
	local attack_pos = self_pos + unit_forward * forward_offset
	local radius = current_action.push_radius
	local collision_filter = "filter_melee_sweep"
	local actors, actors_n = PhysicsWorld.immediate_overlap(physics_world, "shape", "sphere", "position", attack_pos, "size", radius, "types", "dynamics", "collision_filter", collision_filter, "use_global_table")
	local inner_forward_offset = forward_offset + radius * 0.65
	local inner_attack_pos = self_pos + unit_forward * inner_forward_offset
	local inner_attack_pos_near = self_pos + unit_forward
	local inner_radius = current_action.inner_push_radius or radius * 0.4
	local inner_radius_sq = inner_radius * inner_radius
	local inner_hit_units = self.inner_hit_units
	local hit_units = self.hit_units
	local unit_get_data = Unit.get_data

	if script_data.debug_weapons then
		self._drawer:sphere(attack_pos, radius, Color(255, 0, 0))
		self._drawer:sphere(inner_attack_pos_near, inner_radius, Color(0, 255, 0))
		self._drawer:sphere(inner_attack_pos, inner_radius, Color(0, 255, 0))
	end

	local target_breed_unit = self.target_breed_unit
	local target_breed_unit_health_extension = Unit.alive(target_breed_unit) and ScriptUnit.extension(target_breed_unit, "health_system")

	if target_breed_unit_health_extension then
		if not target_breed_unit_health_extension:is_alive() then
			target_breed_unit = nil
		end
	else
		target_breed_unit = nil
	end

	local side = Managers.state.side.side_by_unit[owner_unit]
	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
	local total_hits = 0
	local hit_unit_index = 1

	for i = 1, actors_n, 1 do
		repeat
			local hit_actor = actors[i]
			local hit_unit = Actor.unit(hit_actor)
			local breed = unit_get_data(hit_unit, "breed")
			local dummy = not breed and unit_get_data(hit_unit, "is_dummy")
			local hit_self = hit_unit == owner_unit
			local target_is_friendly_player = table.contains(player_and_bot_units, hit_unit)

			if not target_is_friendly_player and (breed or dummy) and not hit_units[hit_unit] then
				hit_units[hit_unit] = true
				hit_unit_index = total_hits
				total_hits = total_hits + 1

				self._num_targets_hit = self._num_targets_hit + 1

				if hit_unit == target_breed_unit then
					break
				end

				local node = Actor.node(hit_actor)
				local hit_zone = breed and breed.hit_zones_lookup[node]
				local target_hit_zone_name = (hit_zone and hit_zone.name) or "torso"
				local target_hit_position = Unit.has_node(hit_unit, "j_spine") and Unit.world_position(hit_unit, Unit.node(hit_unit, "j_spine"))
				local target_world_position = POSITION_LOOKUP[hit_unit] or Unit.world_position(hit_unit, 0)
				local hit_position = target_hit_position or target_world_position
				self.target_hit_zones_names[hit_unit] = target_hit_zone_name
				self.target_hit_unit_positions[hit_unit] = hit_position
				local attack_direction = Vector3.normalize(hit_position - self_pos)
				local hit_unit_id = network_manager:unit_game_object_id(hit_unit)
				local hit_zone_id = NetworkLookup.hit_zones[target_hit_zone_name]

				if self:_is_infront_player(self_pos, unit_forward, hit_position) then
					local distance_to_inner_position_sq = math.min(Vector3.distance_squared(target_hit_position, inner_attack_pos), Vector3.distance_squared(target_hit_position, inner_attack_pos_near))

					if distance_to_inner_position_sq <= inner_radius_sq then
						inner_hit_units[hit_unit] = true
					else
						local shield_blocked = AiUtils.attack_is_shield_blocked(hit_unit, owner_unit)
						local damage_source = self.item_name
						local damage_source_id = NetworkLookup.damage_sources[damage_source]
						local weapon_system = self.weapon_system
						local power_level = self.power_level
						local is_server = self.is_server
						local damage_profile = self.damage_profile_aoe
						local target_index = hit_unit_index
						local is_critical_strike = self._is_critical_strike

						if not dummy then
							ActionSweep._play_character_impact(self, is_server, owner_unit, hit_unit, breed, hit_position, target_hit_zone_name, current_action, damage_profile, target_index, power_level, attack_direction, shield_blocked, self.melee_boost_curve_multiplier, is_critical_strike)
						end

						weapon_system:send_rpc_attack_hit(damage_source_id, attacker_unit_id, hit_unit_id, hit_zone_id, hit_position, attack_direction, self.damage_profile_aoe_id, "power_level", power_level, "hit_target_index", target_index, "blocking", shield_blocked, "shield_break_procced", false, "boost_curve_multiplier", self.melee_boost_curve_multiplier, "is_critical_strike", self._is_critical_strike, "can_damage", true, "can_stagger", true, "first_hit", self._num_targets_hit == 1)
					end
				end
			elseif not target_is_friendly_player and not hit_units[hit_unit] and not hit_self and ScriptUnit.has_extension(hit_unit, "health_system") then
				local hit_unit_id, is_level_unit = Managers.state.network:game_object_or_level_id(hit_unit)

				if is_level_unit then
					hit_units[hit_unit] = true
					local no_player_damage = unit_get_data(hit_unit, "no_damage_from_players")

					if not no_player_damage then
						local target_hit_position = Unit.world_position(hit_unit, 0)
						local distance_to_inner_position_sq = math.min(Vector3.distance_squared(target_hit_position, inner_attack_pos), Vector3.distance_squared(target_hit_position, inner_attack_pos_near))

						if distance_to_inner_position_sq <= inner_radius_sq then
							inner_hit_units[hit_unit] = true
						else
							local hit_zone_name = "full"
							local target_index = 1
							local damage_profile = self.damage_profile_aoe
							local damage_source = self.item_name
							local power_level = self.power_level
							local is_critical_strike = self._is_critical_strike
							local attack_direction = Vector3.normalize(target_hit_position - self_pos)

							DamageUtils.damage_level_unit(hit_unit, owner_unit, hit_zone_name, power_level, self.melee_boost_curve_multiplier, is_critical_strike, damage_profile, target_index, attack_direction, damage_source)
						end
					end
				else
					hit_units[hit_unit] = true
					local hit_position = POSITION_LOOKUP[hit_unit] or Unit.world_position(hit_unit, 0)
					local distance_to_inner_position_sq = math.min(Vector3.distance_squared(hit_position, inner_attack_pos), Vector3.distance_squared(hit_position, inner_attack_pos_near))

					if distance_to_inner_position_sq <= inner_radius_sq then
						inner_hit_units[hit_unit] = true
					end

					local damage_source = self.item_name
					local damage_source_id = NetworkLookup.damage_sources[damage_source]
					local weapon_system = self.weapon_system
					local power_level = self.power_level
					local hit_zone_id = NetworkLookup.hit_zones.full
					local attack_direction = Vector3.normalize(hit_position - self_pos)

					weapon_system:send_rpc_attack_hit(damage_source_id, attacker_unit_id, hit_unit_id, hit_zone_id, hit_position, attack_direction, self.damage_profile_aoe_id, "power_level", power_level, "hit_target_index", nil, "boost_curve_multiplier", self.melee_boost_curve_multiplier, "is_critical_strike", self._is_critical_strike, "can_damage", true, "can_stagger", true)
				end
			end
		until true
	end

	if Unit.alive(target_breed_unit) and not self.hit_target_breed_unit then
		inner_hit_units[target_breed_unit] = true
	end

	local hit_index = 1

	for hit_unit, _ in pairs(inner_hit_units) do
		local breed = unit_get_data(hit_unit, "breed")
		local dummy = not breed and unit_get_data(hit_unit, "is_dummy")
		local hit_zone_name = self.target_hit_zones_names[hit_unit] or "torso"
		local target_hit_position = Unit.has_node(hit_unit, "j_spine") and Unit.world_position(hit_unit, Unit.node(hit_unit, "j_spine"))
		local target_world_position = POSITION_LOOKUP[hit_unit] or Unit.world_position(hit_unit, 0)
		local hit_position = target_hit_position or target_world_position
		local attack_direction = Vector3.normalize(hit_position - self_pos)
		local hit_unit_id, is_level_unit = network_manager:game_object_or_level_id(hit_unit)
		local hit_zone_id = NetworkLookup.hit_zones[hit_zone_name]

		if (breed or dummy) and self:_is_infront_player(self_pos, unit_forward, hit_position, current_action.push_dot) then
			local is_server = self.is_server
			local hit_default_target = hit_unit == target_breed_unit
			local damage_profile = (hit_default_target and self.damage_profile_target) or self.damage_profile
			local damage_profile_id = (hit_default_target and self.damage_profile_target_id) or self.damage_profile_id
			local target_index = 1
			local power_level = self.power_level
			local is_critical_strike = self._is_critical_strike
			local shield_blocked = AiUtils.attack_is_shield_blocked(hit_unit, owner_unit)
			local actor = Unit.find_actor(hit_unit, "c_spine") and Unit.actor(hit_unit, "c_spine")
			local actor_position_hit = actor and Actor.center_of_mass(actor)

			if not dummy and actor_position_hit then
				ActionSweep._play_character_impact(self, is_server, owner_unit, hit_unit, breed, actor_position_hit, hit_zone_name, current_action, damage_profile, target_index, power_level, attack_direction, shield_blocked, self.melee_boost_curve_multiplier, is_critical_strike)
			end

			local send_to_server = true
			local charge_value = damage_profile.charge_value or "heavy_attack"
			local buff_type = DamageUtils.get_item_buff_type(self.item_name)

			DamageUtils.buff_on_attack(owner_unit, hit_unit, charge_value, is_critical_strike, hit_zone_name, hit_index, send_to_server, buff_type)

			local damage_source_id = NetworkLookup.damage_sources[self.item_name]
			local weapon_system = self.weapon_system

			weapon_system:send_rpc_attack_hit(damage_source_id, attacker_unit_id, hit_unit_id, hit_zone_id, hit_position, attack_direction, damage_profile_id, "power_level", power_level, "hit_target_index", hit_index, "blocking", shield_blocked, "shield_break_procced", false, "boost_curve_multiplier", self.melee_boost_curve_multiplier, "is_critical_strike", is_critical_strike, "can_damage", true, "can_stagger", true, "first_hit", self._num_targets_hit == 1)

			if self.is_critical_strike and self.critical_strike_particle_id then
				World.destroy_particles(self.world, self.critical_strike_particle_id)

				self.critical_strike_particle_id = nil
			end

			if not Managers.player:owner(self.owner_unit).bot_player then
				Managers.state.controller_features:add_effect("rumble", {
					rumble_effect = "handgun_fire"
				})
			end

			self.hit_target_breed_unit = true
			hit_index = hit_index + 1
		elseif ScriptUnit.has_extension(hit_unit, "health_system") then
			if is_level_unit then
				local no_player_damage = unit_get_data(hit_unit, "no_damage_from_players")

				if not no_player_damage then
					hit_zone_name = "full"
					local target_index = 1
					local damage_profile = self.damage_profile
					local damage_source = self.item_name
					local power_level = self.power_level
					local is_critical_strike = self._is_critical_strike
					target_hit_position = Unit.world_position(hit_unit, 0)
					attack_direction = Vector3.normalize(target_hit_position - self_pos)

					DamageUtils.damage_level_unit(hit_unit, owner_unit, hit_zone_name, power_level, self.melee_boost_curve_multiplier, is_critical_strike, damage_profile, target_index, attack_direction, damage_source)
				end
			else
				local damage_source = self.item_name
				local damage_source_id = NetworkLookup.damage_sources[damage_source]
				local weapon_system = self.weapon_system
				local power_level = self.power_level
				hit_zone_id = NetworkLookup.hit_zones.full
				target_hit_position = Unit.world_position(hit_unit, 0)
				attack_direction = Vector3.normalize(target_hit_position - self_pos)

				weapon_system:send_rpc_attack_hit(damage_source_id, attacker_unit_id, hit_unit_id, hit_zone_id, target_hit_position, attack_direction, self.damage_profile_id, "power_level", power_level, "hit_target_index", nil, "boost_curve_multiplier", self.melee_boost_curve_multiplier, "is_critical_strike", self._is_critical_strike, "can_damage", true, "can_stagger", true)
			end
		end
	end

	self.state = "hit"
end)

-- Fixed Vanguard not proccing when you killed an enemy which is staggered
local dead_units = {}
local damage_source_procs = {
	charge_ability_hit_blast = "on_charge_ability_hit_blast",
	charge_ability_hit = "on_charge_ability_hit"
}
local unit_get_data = Unit.get_data
mod:hook_origin(DamageUtils, "server_apply_hit", function (t, attacker_unit, target_unit, hit_zone_name, hit_position, attack_direction, hit_ragdoll_actor, damage_source, power_level, damage_profile, target_index, boost_curve_multiplier, is_critical_strike, can_damage, can_stagger, blocking, shield_breaking_hit, backstab_multiplier, first_hit, total_hits, source_attacker_unit)
	local buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

	if buff_extension and damage_source_procs[damage_source] then
		buff_extension:trigger_procs(damage_source_procs[damage_source], target_unit, target_index)
	end

	local target_alive = AiUtils.unit_alive(target_unit)
	local just_died = false -- Added this

	if not blocking then
		local attack_power_level = power_level

		if not can_damage then
			attack_power_level = 0
		end

		if damage_profile.charge_value == "heavy_attack" and DamageUtils.is_player_unit(attacker_unit) then
			local status_extension = ScriptUnit.has_extension(attacker_unit, "status_system")

			if status_extension then
				local current_fall_distance = status_extension:fall_distance()

				if MinFallDistanceForBonus <= current_fall_distance then
					attack_power_level = attack_power_level * FallingPowerLevelBonusMultiplier
				end
			end
		end

		local custom_dot = nil

		if buff_extension then
			if (buff_extension:has_buff_perk("victor_witchhunter_bleed_on_critical_hit") and (damage_profile.charge_value == "light_attack" or damage_profile.charge_value == "heavy_attack")) or (buff_extension:has_buff_perk("kerillian_critical_bleed_dot") and damage_profile.charge_value == "projectile") then
				custom_dot = "weapon_bleed_dot_whc"
			end

			if buff_extension:has_buff_perk("sienna_unchained_burn_push") and damage_profile and damage_profile.is_push then
				custom_dot = "burning_1W_dot_unchained_push"
			end
		end

		local source_attacker_unit = source_attacker_unit or attacker_unit
		local added_dot = nil

		if not damage_profile.require_damage_for_dot or attack_power_level ~= 0 then
			added_dot = DamageUtils.apply_dot(damage_profile, target_index, power_level, target_unit, attacker_unit, hit_zone_name, damage_source, boost_curve_multiplier, is_critical_strike, nil, source_attacker_unit, custom_dot)
		end

		
		DamageUtils.add_damage_network_player(damage_profile, target_index, attack_power_level, target_unit, attacker_unit, hit_zone_name, hit_position, attack_direction, damage_source, hit_ragdoll_actor, boost_curve_multiplier, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier, source_attacker_unit)
		
		if not AiUtils.unit_alive(target_unit) then -- If it dies make it say it just died
			just_died = true
		end
	elseif shield_breaking_hit then
		local shield_extension = ScriptUnit.has_extension(target_unit, "ai_shield_system")

		if shield_extension then
			shield_extension:break_shield()
		end

		blocking = false
	end

	if target_alive and not damage_profile.no_stagger or just_died and not damage_profile.no_stagger then --if just died still go through and stagger ai
		local stagger_power_level = power_level

		if not can_stagger then
			stagger_power_level = 0
		end

		DamageUtils.stagger_ai(t, damage_profile, target_index, stagger_power_level, target_unit, attacker_unit, hit_zone_name, attack_direction, boost_curve_multiplier, is_critical_strike, blocking, damage_source)
	end

	if unit_get_data(target_unit, "is_dummy") and not damage_profile.no_stagger and can_stagger then
		local buff_system = Managers.state.entity:system("buff_system")
		local target_settings = (damage_profile.targets and damage_profile.targets[1]) or damage_profile.default_target
		local attack_template_name = target_settings.attack_template
		local attack_template = AttackTemplates[attack_template_name]
		local stagger_value = (attack_template and attack_template.stagger_value) or 1

		for i = 1, stagger_value, 1 do
			buff_system:add_buff(target_unit, "dummy_stagger", attacker_unit, false)
		end

		local attacker_buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")

		if attacker_buff_extension then
			local item_data = rawget(ItemMasterList, damage_source)
			local weapon_template_name = item_data and item_data.template

			if weapon_template_name then
				local weapon_template = Weapons[weapon_template_name]
				local buff_type = weapon_template.buff_type

				attacker_buff_extension:trigger_procs("on_stagger", target_unit, damage_profile, attacker_unit, 1, 1, stagger_value, buff_type, target_index)
			end
		end
	end
end)

-- Stagger Talent Changes (Remove Crit from Assassin)
local function apply_buffs_to_stagger_damage(attacker_unit, target_unit, target_index, hit_zone, is_critical_strike, stagger_number)
	local attacker_buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")
	local new_stagger_number = stagger_number

	if attacker_buff_extension then
		local finesse_perk = attacker_buff_extension:has_buff_perk("finesse_stagger_damage")
		local smiter_perk = attacker_buff_extension:has_buff_perk("smiter_stagger_damage")
		local mainstay_perk = attacker_buff_extension:has_buff_perk("linesman_stagger_damage")

		if mainstay_perk and new_stagger_number > 0 then
			new_stagger_number = new_stagger_number + 1
		elseif (hit_zone == "head" or hit_zone == "neck") and finesse_perk then
			new_stagger_number = 2
		elseif smiter_perk then
			if target_index and target_index <= 1 then
				new_stagger_number = math.max(1, new_stagger_number)
			else
				new_stagger_number = stagger_number
			end
		end
	end

	return new_stagger_number
end

local function do_damage_calculation(attacker_unit, damage_source, original_power_level, damage_output, hit_zone_name, damage_profile, target_index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, is_dummy, dummy_unit_armor, dropoff_scalar, static_base_damage, is_player_friendly_fire, has_power_boost, difficulty_level, target_unit_armor, target_unit_primary_armor, has_crit_head_shot_killing_blow_perk, has_crit_backstab_killing_blow_perk, target_max_health, target_unit)
	if damage_profile and damage_profile.no_damage then
		return 0
	end

	local difficulty_settings = DifficultySettings[difficulty_level]
	local power_boost_damage = 0
	local head_shot_boost_damage = 0
	local head_shot_min_damage = 1
	local power_boost_min_damage = 1
	local multiplier_type = DamageUtils.get_breed_damage_multiplier_type(breed, hit_zone_name, is_dummy)
	local is_finesse_hit = multiplier_type == "headshot" or multiplier_type == "weakspot" or multiplier_type == "protected_weakspot"

	if is_finesse_hit or is_critical_strike or has_power_boost or (boost_damage_multiplier and boost_damage_multiplier > 0) then
		local power_boost_armor = nil

		if target_unit_armor == 2 or target_unit_armor == 5 or target_unit_armor == 6 then
			power_boost_armor = 1
		else
			power_boost_armor = target_unit_armor
		end

		local power_boost_target_damages = damage_output[power_boost_armor] or (power_boost_armor == 0 and 0) or damage_output[1]
		local preliminary_boost_damage = nil

		if type(power_boost_target_damages) == "table" then
			local power_boost_damage_range = power_boost_target_damages.max - power_boost_target_damages.min
			local power_boost_attack_power, _ = ActionUtils.get_power_level_for_target(target_unit, original_power_level, damage_profile, target_index, is_critical_strike, attacker_unit, hit_zone_name, power_boost_armor, damage_source, breed, dummy_unit_armor, dropoff_scalar, difficulty_level, target_unit_armor, target_unit_primary_armor)
			local power_boost_percentage = ActionUtils.get_power_level_percentage(power_boost_attack_power)
			preliminary_boost_damage = power_boost_target_damages.min + power_boost_damage_range * power_boost_percentage
		else
			preliminary_boost_damage = power_boost_target_damages
		end

		if is_finesse_hit then
			head_shot_min_damage = preliminary_boost_damage * 0.5
		end

		if is_critical_strike then
			head_shot_min_damage = preliminary_boost_damage * 0.5
		end

		if has_power_boost or (boost_damage_multiplier and boost_damage_multiplier > 0) then
			power_boost_damage = preliminary_boost_damage
		end
	end

	local damage, target_damages = nil
	target_damages = (static_base_damage and ((type(damage_output) == "table" and damage_output[1]) or damage_output)) or damage_output[target_unit_armor] or (target_unit_armor == 0 and 0) or damage_output[1]

	if type(target_damages) == "table" then
		local damage_range = target_damages.max - target_damages.min
		local percentage = 0

		if damage_profile then
			local attack_power, _ = ActionUtils.get_power_level_for_target(target_unit, original_power_level, damage_profile, target_index, is_critical_strike, attacker_unit, hit_zone_name, nil, damage_source, breed, dummy_unit_armor, dropoff_scalar, difficulty_level, target_unit_armor, target_unit_primary_armor)
			percentage = ActionUtils.get_power_level_percentage(attack_power)
		end

		damage = target_damages.min + damage_range * percentage
	else
		damage = target_damages
	end

	local backstab_damage = nil

	if backstab_multiplier then
		backstab_damage = (power_boost_damage and damage < power_boost_damage and power_boost_damage * (backstab_multiplier - 1)) or damage * (backstab_multiplier - 1)
	end

	if not static_base_damage then
		local power_boost_amount = 0
		local head_shot_boost_amount = 0

		if has_power_boost then
			if target_unit_armor == 1 then
				power_boost_amount = power_boost_amount + 0.75
			elseif target_unit_armor == 2 then
				power_boost_amount = power_boost_amount + 0.6
			elseif target_unit_armor == 3 then
				power_boost_amount = power_boost_amount + 0.5
			elseif target_unit_armor == 4 then
				power_boost_amount = power_boost_amount + 0.5
			elseif target_unit_armor == 5 then
				power_boost_amount = power_boost_amount + 0.5
			elseif target_unit_armor == 6 then
				power_boost_amount = power_boost_amount + 0.3
			else
				power_boost_amount = power_boost_amount + 0.5
			end
		end

		if boost_damage_multiplier and boost_damage_multiplier > 0 then
			if target_unit_armor == 1 then
				power_boost_amount = power_boost_amount + 0.75
			elseif target_unit_armor == 2 then
				power_boost_amount = power_boost_amount + 0.3
			elseif target_unit_armor == 3 then
				power_boost_amount = power_boost_amount + 0.75
			elseif target_unit_armor == 4 then
				power_boost_amount = power_boost_amount + 0.5
			elseif target_unit_armor == 5 then
				power_boost_amount = power_boost_amount + 0.5
			elseif target_unit_armor == 6 then
				power_boost_amount = power_boost_amount + 0.2
			else
				power_boost_amount = power_boost_amount + 0.5
			end
		end

		local target_settings = damage_profile and ((damage_profile.targets and damage_profile.targets[target_index]) or damage_profile.default_target)

		if is_finesse_hit then
			if damage > 0 then
				if target_unit_armor == 3 then
					head_shot_boost_amount = head_shot_boost_amount + ((target_settings and (target_settings.headshot_boost_boss or target_settings.headshot_boost)) or 0.25)
				else
					head_shot_boost_amount = head_shot_boost_amount + ((target_settings and target_settings.headshot_boost) or 0.5)
				end
			elseif target_unit_primary_armor == 6 and damage == 0 then
				head_shot_boost_amount = head_shot_boost_amount + (target_settings and (target_settings.headshot_boost_heavy_armor or 0.25))
			elseif target_unit_armor == 2 and damage == 0 then
				head_shot_boost_amount = head_shot_boost_amount + ((target_settings and (target_settings.headshot_boost_armor or target_settings.headshot_boost)) or 0.5)
			end

			if multiplier_type == "protected_weakspot" then
				head_shot_boost_amount = head_shot_boost_amount * 0.25
			end
		end

		if multiplier_type == "protected_spot" then
			power_boost_amount = power_boost_amount - 0.5
			head_shot_boost_amount = head_shot_boost_amount - 0.5
		end

		if damage_profile and damage_profile.no_headshot_boost then
			head_shot_boost_amount = 0
		end

		local crit_boost = 0

		if is_critical_strike then
			crit_boost = (damage_profile and damage_profile.crit_boost) or 0.5

			if damage_profile and damage_profile.no_crit_boost then
				crit_boost = 0
			end
		end

		local attacker_buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")

		if boost_curve and (power_boost_amount > 0 or head_shot_boost_amount > 0 or crit_boost > 0) then
			local modified_boost_curve, modified_boost_curve_head_shot = nil
			local boost_coefficient = (target_settings and target_settings.boost_curve_coefficient) or DefaultBoostCurveCoefficient
			local boost_coefficient_headshot = (target_settings and target_settings.boost_curve_coefficient_headshot) or DefaultBoostCurveCoefficient

			if boost_damage_multiplier and boost_damage_multiplier > 0 then
				if breed and breed.boost_curve_multiplier_override then
					boost_damage_multiplier = math.clamp(boost_damage_multiplier, 0, breed.boost_curve_multiplier_override)
				end

				boost_coefficient = boost_coefficient * boost_damage_multiplier
				boost_coefficient_headshot = boost_coefficient_headshot * boost_damage_multiplier
			end

			if power_boost_amount > 0 then
				modified_boost_curve = DamageUtils.get_modified_boost_curve(boost_curve, boost_coefficient)
				power_boost_amount = math.clamp(power_boost_amount, 0, 1)
				local boost_multiplier = DamageUtils.get_boost_curve_multiplier(modified_boost_curve or boost_curve, power_boost_amount)
				power_boost_damage = math.max(math.max(power_boost_damage, damage), power_boost_min_damage) * boost_multiplier
			end

			if head_shot_boost_amount > 0 or crit_boost > 0 then
				local target_unit_buff_extension = target_unit and ScriptUnit.has_extension(target_unit, "buff_system")
				modified_boost_curve_head_shot = DamageUtils.get_modified_boost_curve(boost_curve, boost_coefficient_headshot)
				head_shot_boost_amount = math.clamp(head_shot_boost_amount + crit_boost, 0, 1)
				local head_shot_boost_multiplier = DamageUtils.get_boost_curve_multiplier(modified_boost_curve_head_shot or boost_curve, head_shot_boost_amount)
				head_shot_boost_damage = math.max(math.max(power_boost_damage, damage), head_shot_min_damage) * head_shot_boost_multiplier

				if attacker_buff_extension and is_critical_strike then
					head_shot_boost_damage = head_shot_boost_damage * attacker_buff_extension:apply_buffs_to_value(1, "critical_strike_effectiveness")
				end

				if attacker_buff_extension and is_finesse_hit then
					head_shot_boost_damage = head_shot_boost_damage * attacker_buff_extension:apply_buffs_to_value(1, "headshot_multiplier")
				end

				if target_unit_buff_extension and is_finesse_hit then
					head_shot_boost_damage = head_shot_boost_damage * target_unit_buff_extension:apply_buffs_to_value(1, "headshot_vulnerability")
				end
			end
		end

		if breed and breed.armored_boss_damage_reduction then
			damage = damage * 0.8
			power_boost_damage = power_boost_damage * 0.5
			backstab_damage = backstab_damage and backstab_damage * 0.75
		end

		if breed and breed.boss_damage_reduction then
			damage = damage * 0.45
			power_boost_damage = power_boost_damage * 0.5
			head_shot_boost_damage = head_shot_boost_damage * 0.5
			backstab_damage = backstab_damage and backstab_damage * 0.75
		end

		if breed and breed.lord_damage_reduction then
			damage = damage * 0.2
			power_boost_damage = power_boost_damage * 0.25
			head_shot_boost_damage = head_shot_boost_damage * 0.25
			backstab_damage = backstab_damage and backstab_damage * 0.5
		end

		damage = damage + power_boost_damage + head_shot_boost_damage

		if backstab_damage then
			damage = damage + backstab_damage
		end

		if attacker_buff_extension then
			if multiplier_type == "headshot" then
				damage = attacker_buff_extension:apply_buffs_to_value(damage, "headshot_damage")
			else
				damage = attacker_buff_extension:apply_buffs_to_value(damage, "non_headshot_damage")
			end
		end

		if is_critical_strike then
			local killing_blow_triggered = nil

			if hit_zone_name == "head" and has_crit_head_shot_killing_blow_perk then
				killing_blow_triggered = true
			elseif backstab_multiplier and backstab_multiplier > 1 and has_crit_backstab_killing_blow_perk then
				killing_blow_triggered = true
			end

			if killing_blow_triggered and breed then
				local boss = breed.boss
				local primary_armor = breed.primary_armor_category

				if not boss and not primary_armor then
					if target_max_health then
						damage = target_max_health
					else
						local breed_health_table = breed.max_health
						local difficulty_rank = difficulty_settings.rank
						local breed_health = breed_health_table[difficulty_rank]
						damage = breed_health
					end
				end
			end
		end
	end

	if is_player_friendly_fire then
		local friendly_fire_multiplier = difficulty_settings.friendly_fire_multiplier

		if damage_profile and damage_profile.friendly_fire_multiplier then
			friendly_fire_multiplier = friendly_fire_multiplier * damage_profile.friendly_fire_multiplier
		end

		if friendly_fire_multiplier then
			damage = damage * friendly_fire_multiplier
		end
	end

	local heavy_armor_damage = false

	return damage, heavy_armor_damage
end

mod:hook_origin(DamageUtils, "calculate_damage", function (damage_output, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve, boost_damage_multiplier, is_critical_strike, damage_profile, target_index, backstab_multiplier, damage_source)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local breed, dummy_unit_armor, is_dummy, unit_max_health = nil

	if target_unit then
		breed = AiUtils.unit_breed(target_unit)
		dummy_unit_armor = unit_get_data(target_unit, "armor")
		is_dummy = unit_get_data(target_unit, "is_dummy")
		local target_unit_health_extension = ScriptUnit.has_extension(target_unit, "health_system")
		local is_invincible = target_unit_health_extension and target_unit_health_extension:get_is_invincible() and not is_dummy

		if is_invincible then
			return 0
		end

		if target_unit_health_extension and not is_dummy then
			unit_max_health = target_unit_health_extension:get_max_health()
		elseif breed then
			local breed_health_table = breed.max_health
			local difficulty_rank = difficulty_settings.rank
			local breed_health = breed_health_table[difficulty_rank]
			unit_max_health = breed_health
		end
	end

	local attacker_breed = nil

	if attacker_unit then
		attacker_breed = Unit.get_data(attacker_unit, "breed")
	end

	local static_base_damage = not attacker_breed or not attacker_breed.is_hero
	local is_player_friendly_fire = not static_base_damage and Managers.state.side:is_player_friendly_fire(attacker_unit, target_unit)
	local target_is_hero = breed and breed.is_hero
	local dropoff_scalar = 0

	if damage_profile and not static_base_damage then
		local target_settings = (damage_profile.targets and damage_profile.targets[target_index]) or damage_profile.default_target
		dropoff_scalar = ActionUtils.get_dropoff_scalar(damage_profile, target_settings, attacker_unit, target_unit)
	end

	local buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")
	local has_power_boost = false
	local has_crit_head_shot_killing_blow_perk = false
	local has_crit_backstab_killing_blow_perk = false

	if buff_extension then
		has_power_boost = buff_extension:has_buff_perk("potion_armor_penetration")
		has_crit_head_shot_killing_blow_perk = buff_extension:has_buff_perk("crit_headshot_killing_blow")
		has_crit_backstab_killing_blow_perk = buff_extension:has_buff_perk("crit_backstab_killing_blow")
	end

	local difficulty_level = Managers.state.difficulty:get_difficulty()
	local target_unit_armor, target_unit_primary_armor, _ = nil

	if target_is_hero then
		target_unit_armor = PLAYER_TARGET_ARMOR
	else
		target_unit_armor, _, target_unit_primary_armor, _ = ActionUtils.get_target_armor(hit_zone_name, breed, dummy_unit_armor)
	end

	local calculated_damage = do_damage_calculation(attacker_unit, damage_source, original_power_level, damage_output, hit_zone_name, damage_profile, target_index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, is_dummy, dummy_unit_armor, dropoff_scalar, static_base_damage, is_player_friendly_fire, has_power_boost, difficulty_level, target_unit_armor, target_unit_primary_armor, has_crit_head_shot_killing_blow_perk, has_crit_backstab_killing_blow_perk, unit_max_health, target_unit)

	if damage_profile and not damage_profile.is_dot then
		local blackboard = BLACKBOARDS[target_unit]
		local stagger_number = 0

		if blackboard then
			local ignore_stagger_damage_reduction = damage_profile.no_stagger_damage_reduction or breed.no_stagger_damage_reduction
			local min_stagger_number = 0
			local max_stagger_number = 2

			if blackboard.is_climbing then
				stagger_number = 2
			else
				stagger_number = math.min(blackboard.stagger or min_stagger_number, max_stagger_number)
			end

			if damage_profile.no_stagger_damage_reduction_ranged then
				local stagger_number_override = 1
				stagger_number = math.max(stagger_number_override, stagger_number)
			end

			if not damage_profile.no_stagger_damage_reduction_ranged then
				stagger_number = apply_buffs_to_stagger_damage(attacker_unit, target_unit, target_index, hit_zone_name, is_critical_strike, stagger_number)
			end
		elseif dummy_unit_armor then
			local target_buff_extension = ScriptUnit.has_extension(target_unit, "buff_system")
			stagger_number = target_buff_extension:apply_buffs_to_value(0, "dummy_stagger")

			if damage_profile.no_stagger_damage_reduction_ranged then
				local stagger_number_override = 1
				stagger_number = math.max(stagger_number_override, stagger_number)
			end

			if not damage_profile.no_stagger_damage_reduction_ranged then
				stagger_number = apply_buffs_to_stagger_damage(attacker_unit, target_unit, target_index, hit_zone_name, is_critical_strike, stagger_number)
			end
		end

		local min_stagger_damage_coefficient = difficulty_settings.min_stagger_damage_coefficient
		local stagger_damage_multiplier = difficulty_settings.stagger_damage_multiplier

		if stagger_damage_multiplier then
			local bonus_damage_percentage = stagger_number * stagger_damage_multiplier
			local target_buff_extension = ScriptUnit.has_extension(target_unit, "buff_system")

			if target_buff_extension and not damage_profile.no_stagger_damage_reduction_ranged then
				bonus_damage_percentage = target_buff_extension:apply_buffs_to_value(bonus_damage_percentage, "unbalanced_damage_taken")
			end

			local stagger_damage = calculated_damage * (min_stagger_damage_coefficient + bonus_damage_percentage)
			calculated_damage = stagger_damage
		end
	end

	local weave_manager = Managers.weave

	if target_is_hero and static_base_damage and weave_manager:get_active_weave() then
		local scaling_value = weave_manager:get_scaling_value("enemy_damage")
		calculated_damage = calculated_damage * (1 + scaling_value)
	end

	return calculated_damage
end)

-- Buff and Talent Functions
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.add_buff_template(self, buff_name, buff_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.add_proc_function(self, name, func)
    ProcFunctions[name] = func
end
function mod.modify_talent(self, career_name, tier, index, new_talent_data)
	local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
	local talent_tree_index = career_settings.talent_tree_index

	local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
	local old_talent_id_lookup = TalentIDLookup[old_talent_name]
	local old_talent_id = old_talent_id_lookup.talent_id
	local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = merge(old_talent_data, new_talent_data)
end

-- THP & Stagger Buffs
mod:add_proc_function("rebaltourn_heal_finesse_damage_on_melee", function (player, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local player_unit = player.player_unit
	local heal_amount_crit = 1.5
	local heal_amount_hs = 3
	local has_procced = buff.has_procced
	local hit_unit = params[1]
	local hit_zone_name = params[3]
	local target_number = params[4]
	local attack_type = params[2]
	local critical_hit = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	if target_number == 1 then
		buff.has_procced = false
		has_procced = false
	end

	if ALIVE[player_unit] and breed and (attack_type == "light_attack" or attack_type == "heavy_attack") and not has_procced then
		if hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot" then
			buff.has_procced = true

			DamageUtils.heal_network(player_unit, player_unit, heal_amount_hs, "heal_from_proc")
		end

		if critical_hit then
			DamageUtils.heal_network(player_unit, player_unit, heal_amount_crit, "heal_from_proc")

			buff.has_procced = true
		end
	end
end)
mod:add_buff_template("rebaltourn_regrowth", {
	name = "regrowth",
	event_buff = true,
	buff_func = "rebaltourn_heal_finesse_damage_on_melee",
	event = "on_hit",
	perk = "ninja_healing",
})
mod:add_proc_function("rebaltourn_heal_stagger_targets_on_melee", function (player, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local player_unit = player.player_unit

	if ALIVE[player_unit] then
		local hit_unit = params[1]
		local damage_profile = params[2]
		local attack_type = damage_profile.charge_value
		local stagger_value = params[6]
		local stagger_type = params[4]
		local buff_type = params[7]
		local target_index = params[8]
		local breed = AiUtils.unit_breed(hit_unit)
		local multiplier = buff.multiplier
		local is_push = damage_profile.is_push
		local stagger_calulation = stagger_type or stagger_value
		local heal_amount = stagger_calulation * multiplier --stagger_value * multiplier
		local death_extension = ScriptUnit.has_extension(hit_unit, "death_system")
		local is_corpse = death_extension.death_is_done == false

		if is_push then
			heal_amount = 0.6
		end

		if target_index and target_index < 5 and breed and not breed.is_hero and (attack_type == "light_attack" or attack_type == "heavy_attack" or attack_type == "action_push") and not is_corpse then
			DamageUtils.heal_network(player_unit, player_unit, heal_amount, "heal_from_proc")
		end
	end
end)
mod:add_buff_template("rebaltourn_vanguard", {
	multiplier = 1,
	name = "vanguard",
	event_buff = true,
	buff_func = "rebaltourn_heal_stagger_targets_on_melee",
	event = "on_stagger",
	perk = "tank_healing"
})
mod:add_buff_template("rebaltourn_reaper", {
	multiplier = -0.05,
	name = "reaper",
	event_buff = true,
	buff_func = "heal_damage_targets_on_melee",
	event = "on_player_damage_dealt",
	perk = "linesman_healing",
	max_targets = 5,
	bonus = 0.25
})
mod:add_buff_template("rebaltourn_bloodlust", {
	multiplier = 0.2,
	name = "bloodlust",
	event_buff = true,
	buff_func = "heal_percentage_of_enemy_hp_on_melee_kill",
	event = "on_kill",
	perk = "smiter_healing",
})
mod:add_buff_template("rebaltourn_smiter_unbalance", {
	max_display_multiplier = 0.4,
	name = "smiter_unbalance",
	display_multiplier = 0.2,
	perk = "smiter_stagger_damage"
})
mod:add_buff_template("rebaltourn_power_level_unbalance", {
	max_stacks = 1,
	name = "power_level_unbalance",
	stat_buff = "power_level",
	multiplier = 0.1 -- 0.075
}) 
mod:add_proc_function("rebaltourn_unbalance_debuff_on_stagger", function (player, buff, params)
	local player_unit = player.player_unit
	local hit_unit = params[1]
	local is_dummy = Unit.get_data(hit_unit, "is_dummy")
	local buff_type = params[7]

	if Unit.alive(player_unit) and (is_dummy or Unit.alive(hit_unit)) and buff_type == "MELEE_1H" or buff_type == "MELEE_2H" then
		local buff_extension = ScriptUnit.extension(hit_unit, "buff_system")

		if buff_extension then
			buff_extension:add_buff("rebaltourn_tank_unbalance_buff")
		end
	end
end )
mod:add_buff_template("rebaltourn_tank_unbalance", {
	max_display_multiplier = 0.4,
	name = "tank_unbalance",
	event_buff = true,
	buff_func = "rebaltourn_unbalance_debuff_on_stagger",
	event = "on_stagger",
	display_multiplier = 0.2
})
mod:add_buff_template("rebaltourn_tank_unbalance_buff", {
	refresh_durations = true,
	name = "tank_unbalance_buff",
	stat_buff = "unbalanced_damage_taken",
	max_stacks = 1,
	duration = 5,
	bonus = 0.15,
})
mod:add_buff_template("rebaltourn_finesse_unbalance", {
	max_display_multiplier = 0.4,
	name = "finesse_unbalance",
	display_multiplier = 0.2,
	perk = "finesse_stagger_damage"
})

--Text Localization
mod:add_text("bloodlust_name", "Bloodlust")
mod:add_text("reaper_name", "Reaper")
mod:add_text("vanguard_name", "Vanguard")
mod:add_text("regrowth_name", "Regrowth")
mod:add_text("rebaltourn_regrowth_desc", "Melee critical stikes gives you 1.5 temporary health and melee headshots restore 3.5 temporary health. Mellee critical headshots restore 5 temporary health.")
mod:add_text("smiter_name", "Smiter")
mod:add_text("enhanced_power_name", "Enhanced Power")
mod:add_text("assassin_name", "Assassin")
mod:add_text("bulwark_name", "Bulwark")
mod:add_text("rebaltourn_tank_unbalance_desc", "When you stagger an enemy you deal 10%% more damage from all sources for 5 seconds.\n\nDeal 20%% more damage to staggered enemies, increased to 40%% against targets afflicted by more than one stagger effect.")
mod:add_text("rebaltourn_finesse_unbalance_desc", "Deal 20%% more damage to staggered enemies.\n\nEach hit against a staggered enemy adds another count of stagger. Headshots instead inflict 40%% bonus damage, as do strikes against enemies afflicted by more than one stagger effect.")

-- Replacing THP & Stagger Talents
local talent_first_row = {
	{
		"es_knight",
		"es_mercenary",
		"es_questingknight",
		"dr_ironbreaker",
		"wh_zealot",
		"bw_unchained",
	},
	{
		"es_huntsman",
		"dr_ranger",
		"dr_engineer",
		"wh_captain",
		"bw_scholar",
		"bw_adept",
	},
	{
		"dr_slayer",
		"we_shade",
		"we_maidenguard",
		"we_waywatcher",
		"wh_bountyhunter",
		"we_thornsister",
	},
}

for i=1, #talent_first_row[1] do
	local career = talent_first_row[1][i]
	mod:modify_talent(career, 1, 1, {
		name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
	})
	mod:modify_talent(career, 1, 2, {
		name = "reaper_name",
		description = "reaper_desc",
		buffs = {
			"rebaltourn_reaper"
		},
		description_values = {
			{
				value = BuffTemplates.rebaltourn_reaper.buffs[1].max_targets
			}
		},
	})
	mod:modify_talent(career, 1, 3, {
		name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
end
for i=1, #talent_first_row[2] do
	local career = talent_first_row[2][i]
	mod:modify_talent(career, 1, 1, {
		name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
	})
	mod:modify_talent(career, 1, 2, {
		name = "reaper_name",
		description = "reaper_desc",
		buffs = {
			"rebaltourn_reaper"
		},
		description_values = {
			{
				value = BuffTemplates.rebaltourn_reaper.buffs[1].max_targets
			}
		},
	})
	mod:modify_talent(career, 1, 3, {
		name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
end
for i=1, #talent_first_row[3] do
	local career = talent_first_row[3][i]
	mod:modify_talent(career, 1, 1, {
		name = "reaper_name",
		description = "reaper_desc",
		buffs = {
			"rebaltourn_reaper"
		},
		description_values = {
			{
				value = BuffTemplates.rebaltourn_reaper.buffs[1].max_targets
			}
		},
	})
	mod:modify_talent(career, 1, 2, {
		name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
	mod:modify_talent(career, 1, 3, {
		name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
end

local talent_third_row = {
	{
		"es_mercenary",
		"es_huntsman",
		"dr_ranger",
		"dr_slayer",
		"we_waywatcher",
		"we_shade",
		"we_thornsister",
		"wh_captain",
		"wh_bountyhunter",
		"wh_zealot",
		"bw_scholar",
	},
	{
		"es_knight",
		"es_questingknight",
		"dr_ironbreaker",
		"dr_engineer",
		"we_maidenguard",
		"bw_adept",
		"bw_unchained",
	},
}
for i=1, #talent_third_row[1] do
	local career = talent_third_row[1][i]
	mod:modify_talent(career, 3, 1, {
		name = "smiter_name",
		description = "smiter_unbalance_desc",
		buffs = {
			"rebaltourn_smiter_unbalance"
		},
		description_values = {
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_smiter_unbalance.buffs[1].display_multiplier
			},
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_smiter_unbalance.buffs[1].max_display_multiplier
			}
		}
	})
	mod:modify_talent(career, 3, 2, {
		name = "assassin_name",
		description = "rebaltourn_finesse_unbalance_desc",
		buffs = {
			"rebaltourn_finesse_unbalance"
		},
		description_values = {
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_tank_unbalance.buffs[1].display_multiplier
			},
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_tank_unbalance.buffs[1].max_display_multiplier
			}
		}
	})
	mod:modify_talent(career, 3, 3, {
		name = "enhanced_power_name",
		description = "power_level_unbalance_desc",
		buffs = {
			"rebaltourn_power_level_unbalance"
		},
		description_values = {
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_power_level_unbalance.buffs[1].multiplier
			}
		}
	})
end
for i=1, #talent_third_row[2] do
	local career = talent_third_row[2][i]
	mod:modify_talent(career, 3, 1, {
		name = "smiter_name",
		description = "smiter_unbalance_desc",
		buffs = {
			"rebaltourn_smiter_unbalance"
		},
		description_values = {
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_smiter_unbalance.buffs[1].display_multiplier
			},
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_smiter_unbalance.buffs[1].max_display_multiplier
			}
		}
	})
	mod:modify_talent(career, 3, 2, {
		name = "bulwark_name",
		description = "rebaltourn_tank_unbalance_desc",
		buffs = {
			"rebaltourn_tank_unbalance"
		},
		description_values = {},
	})
	mod:modify_talent(career, 3, 3, {
		name = "enhanced_power_name",
		description = "power_level_unbalance_desc",
		buffs = {
			"rebaltourn_power_level_unbalance"
		},
		description_values = {
			{
				value_type = "percent",
				value = BuffTemplates.rebaltourn_power_level_unbalance.buffs[1].multiplier
			}
		}
	})
end