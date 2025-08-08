local mod = get_mod("TourneyBalance")

NewBreedTweaks = NewBreedTweaks or {} --table.clone(BreedTweaks)
NewBreedTweaks.bloodlust_health = {
	beastmen_horde = 1.5,
    chaos_roamer = 3,
    skaven_special = 8,
    chaos_warrior = 20,
    skaven_elite = 8,
    beastmen_roamer = 3,
    chaos_elite = 10,
    beastmen_elite = 15,
    skaven_horde = 1,
    chaos_special = 10,
    skaven_roamer = 2,
    monster = 35,
    chaos_horde = 1.5
}

Breeds.beastmen_bestigor.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_elite
Breeds.beastmen_gor.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_roamer
Breeds.beastmen_gor_dummy.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_roamer
Breeds.beastmen_minotaur.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.beastmen_standard_bearer.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_elite
Breeds.beastmen_ungor_archer.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_horde
Breeds.beastmen_ungor.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_horde
Breeds.beastmen_ungor_dummy.bloodlust_health = NewBreedTweaks.bloodlust_health.beastmen_horde
Breeds.chaos_berzerker.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_elite
Breeds.chaos_corruptor_sorcerer.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_special
Breeds.chaos_exalted_champion_warcamp.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.chaos_exalted_sorcerer_drachenfels.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.chaos_exalted_sorcerer.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.chaos_fanatic.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_horde
Breeds.chaos_marauder_with_shield.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_roamer
Breeds.chaos_marauder.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_roamer
Breeds.chaos_marauder_tutorial.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_roamer
Breeds.chaos_mutator_sorcerer.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_special
--Breeds.chaos_plague_sorcerer.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_special
Breeds.chaos_raider.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_elite
Breeds.chaos_raider_tutorial.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_elite
Breeds.chaos_spawn.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
--Breeds.chaos_tentacle_sorcerer.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_special
Breeds.chaos_troll.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.chaos_vortex_sorcerer.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_special
Breeds.chaos_warrior.bloodlust_health = NewBreedTweaks.bloodlust_health.chaos_warrior
Breeds.skaven_clan_rat_with_shield.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_roamer
Breeds.skaven_clan_rat.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_roamer
Breeds.skaven_clan_rat_tutorial.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_roamer
Breeds.skaven_explosive_loot_rat.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_roamer
Breeds.skaven_grey_seer.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.skaven_gutter_runner.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_special
Breeds.skaven_loot_rat.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_special
Breeds.skaven_pack_master.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_special
Breeds.skaven_plague_monk.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_elite
Breeds.skaven_poison_wind_globadier.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_special
Breeds.skaven_rat_ogre.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.skaven_ratling_gunner.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_special
Breeds.skaven_slave.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_horde
Breeds.skaven_storm_vermin_champion.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.skaven_storm_vermin_warlord.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.skaven_storm_vermin_with_shield.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_elite
Breeds.skaven_storm_vermin.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_elite
Breeds.skaven_storm_vermin_commander.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_elite
Breeds.skaven_stormfiend_boss.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.skaven_stormfiend.bloodlust_health = NewBreedTweaks.bloodlust_health.monster
Breeds.skaven_warpfire_thrower.bloodlust_health = NewBreedTweaks.bloodlust_health.skaven_special

-- Fixed Vanguard not proccing when you killed an enemy which is staggered
local dead_units = {}
local damage_source_procs = {
	charge_ability_hit_blast = "on_charge_ability_hit_blast",
	charge_ability_hit = "on_charge_ability_hit"
}
local unit_get_data = Unit.get_data
mod:hook_origin(DamageUtils, "server_apply_hit", function (t, attacker_unit, target_unit, hit_zone_name, hit_position, attack_direction, hit_ragdoll_actor, damage_source, power_level, damage_profile, target_index, boost_curve_multiplier, is_critical_strike, can_damage, can_stagger, blocking, shield_breaking_hit, backstab_multiplier, first_hit, total_hits, source_attacker_unit, optional_predicted_damage)
	source_attacker_unit = source_attacker_unit or attacker_unit

	local buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

	if buff_extension and damage_source_procs[damage_source] then
		buff_extension:trigger_procs(damage_source_procs[damage_source], target_unit, target_index)
	end

	local target_alive = HEALTH_ALIVE [target_unit]
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

				if current_fall_distance >= MinFallDistanceForBonus then
					attack_power_level = attack_power_level * FallingPowerLevelBonusMultiplier
				end
			end
		end

		local added_dot = false

		if buff_extension then
			local witch_hunter_bleed = buff_extension:has_buff_perk("victor_witchhunter_bleed_on_critical_hit") and (damage_profile.charge_value == "light_attack" or damage_profile.charge_value == "heavy_attack") and not buff_extension:has_buff_perk("victor_witchhunter_bleed_on_critical_hit_disable")
			local kerillian_bleed = buff_extension:has_buff_perk("kerillian_critical_bleed_dot") and damage_profile.charge_value == "projectile" and not buff_extension:has_buff_perk("kerillian_critical_bleed_dot_disable")
			local generic_melee_bleed = buff_extension:has_buff_perk("generic_melee_bleed") and (damage_profile.charge_value == "light_attack" or damage_profile.charge_value == "heavy_attack")
			local custom_dot_name

			if witch_hunter_bleed or kerillian_bleed or generic_melee_bleed then
				custom_dot_name = "weapon_bleed_dot_whc"
			elseif buff_extension:has_buff_perk("sienna_unchained_burn_push") and damage_profile and damage_profile.is_push then
				custom_dot_name = "burning_dot_unchained_push"
			end

			if custom_dot_name then
				local custom_dot = FrameTable.alloc_table()

				custom_dot.dot_template_name = custom_dot_name

				local added_custom_dot = DamageUtils.apply_dot(damage_profile, target_index, power_level, target_unit, attacker_unit, hit_zone_name, damage_source, boost_curve_multiplier, is_critical_strike, nil, source_attacker_unit, custom_dot)

				added_dot = added_dot or added_custom_dot
			end
		end

		if (not damage_profile.require_damage_for_dot or attack_power_level ~= 0) and not added_dot then
			local added_profile_dot = DamageUtils.apply_dot(damage_profile, target_index, power_level, target_unit, attacker_unit, hit_zone_name, damage_source, boost_curve_multiplier, is_critical_strike, nil, source_attacker_unit, nil)

			added_dot = added_dot or added_profile_dot
		end

		if not HEALTH_ALIVE [target_unit] then -- If it dies make it say it just died
			just_died = true
		end
		DamageUtils.add_damage_network_player(damage_profile, target_index, attack_power_level, target_unit, attacker_unit, hit_zone_name, hit_position, attack_direction, damage_source, hit_ragdoll_actor, boost_curve_multiplier, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier, source_attacker_unit)
	elseif shield_breaking_hit then
		local shield_extension = ScriptUnit.has_extension(target_unit, "ai_shield_system")

		if shield_extension then
			local item_actually_dropped = shield_extension:break_shield()

			if item_actually_dropped and buff_extension then
				buff_extension:trigger_procs("on_broke_shield", target_unit)
			end
		end

		blocking = false
	end

	if target_alive and not damage_profile.no_stagger or just_died and not damage_profile.no_stagger then --if just died still go through and stagger ai
		local stagger_power_level = power_level

		if not can_stagger then
			stagger_power_level = 0
		end

		DamageUtils.stagger_ai(t, damage_profile, target_index, stagger_power_level, target_unit, attacker_unit, hit_zone_name, attack_direction, boost_curve_multiplier, is_critical_strike, blocking, damage_source, source_attacker_unit, optional_predicted_damage)
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

local function do_damage_calculation(attacker_unit, damage_source, original_power_level, damage_output, hit_zone_name, damage_profile, target_index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, range_scalar_multiplier, static_base_damage, is_player_friendly_fire, has_power_boost, difficulty_level, target_unit_armor, target_unit_primary_armor, has_crit_head_shot_killing_blow_perk, has_crit_backstab_killing_blow_perk, target_max_health, target_unit)
	if damage_profile and damage_profile.no_damage then
		return 0
	end

	local difficulty_settings = DifficultySettings[difficulty_level]
	local power_boost_damage = 0
	local head_shot_boost_damage = 0
	local head_shot_min_damage = 1
	local power_boost_min_damage = 1
	local multiplier_type = DamageUtils.get_breed_damage_multiplier_type(breed, hit_zone_name)
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
			local power_boost_attack_power, _ = ActionUtils.get_power_level_for_target(target_unit, original_power_level, damage_profile, target_index, is_critical_strike, attacker_unit, hit_zone_name, power_boost_armor, damage_source, breed, range_scalar_multiplier, difficulty_level, target_unit_armor, target_unit_primary_armor)
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
			local attack_power, _ = ActionUtils.get_power_level_for_target(target_unit, original_power_level, damage_profile, target_index, is_critical_strike, attacker_unit, hit_zone_name, nil, damage_source, breed, range_scalar_multiplier, difficulty_level, target_unit_armor, target_unit_primary_armor)
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
			elseif backstab_multiplier and backstab_multiplier > 1 and has_crit_backstab_killing_blow_perk and damage_profile.charge_value == "heavy_attack" then
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
	local is_friendly_fire = not static_base_damage and Managers.state.side:is_ally(attacker_unit, target_unit)
	local target_is_hero = breed and breed.is_hero
	local range_scalar_multiplier  = 0

	if damage_profile and not static_base_damage then
		local target_settings = (damage_profile.targets and damage_profile.targets[target_index]) or damage_profile.default_target
		range_scalar_multiplier = ActionUtils.get_range_scalar_multiplier(damage_profile, target_settings, attacker_unit, target_unit)
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

	local calculated_damage = do_damage_calculation(attacker_unit, damage_source, original_power_level, damage_output, hit_zone_name, damage_profile, target_index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, range_scalar_multiplier, static_base_damage, is_friendly_fire, has_power_boost, difficulty_level, target_unit_armor, target_unit_primary_armor, has_crit_head_shot_killing_blow_perk, has_crit_backstab_killing_blow_perk, unit_max_health, target_unit)

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

	if is_player_friendly_fire then
		if damage_profile and damage_profile.max_friendly_damage then
			if calculated_damage > damage_profile.max_friendly_damage then
				calculated_damage = damage_profile.max_friendly_damage
			end
		end
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

local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[

	THP Talents

]]

-- THP on Crit
mod:add_proc_function("rebaltourn_heal_finesse_damage_on_melee", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local heal_amount_crit = 2 -- 6.2 2THP (Previously 1.5THP in TB)
	local heal_amount_crit_hs = 4 -- 6.2 4THP (Previously 3THP in TB)
	local heal_amount_default = 0.5 -- 6.2 0.5THP newly added to gain THP even when not criting nor hsing
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

	if ALIVE[owner_unit] and breed and (attack_type == "light_attack" or attack_type == "heavy_attack") and not has_procced then
		if hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot" and critical_hit then
			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount_crit_hs, "heal_from_proc")
			buff.has_procced = true

		elseif critical_hit or hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot" then
			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount_crit, "heal_from_proc")
			buff.has_procced = true

		else
			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount_default, "heal_from_proc")
			buff.has_procced = true
		end
	end
end)
mod:add_buff_template("rebaltourn_regrowth", {
	name = "regrowth",
	event_buff = true,
	buff_func = "rebaltourn_heal_finesse_damage_on_melee",
	event = "on_hit",
	perks = { buff_perks.ninja_healing },
})

-- THP on Stagger
mod:add_proc_function("rebaltourn_heal_stagger_targets_on_melee", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	if ALIVE[owner_unit] then
		local hit_unit = params[1]
		local damage_profile = params[2]
		local attack_type = damage_profile.charge_value
		local stagger_value = params[6]
		local stagger_type = params[4]
		local target_index = params[8]
		local breed = AiUtils.unit_breed(hit_unit)
		local multiplier = buff.multiplier
		local is_push = damage_profile.is_push
		local is_discharge = damage_profile.is_discharge
		local stagger_calulation = stagger_type or stagger_value
		local heal_amount = stagger_calulation * multiplier
		local death_extension = ScriptUnit.has_extension(hit_unit, "death_system")
		local is_corpse = death_extension.death_is_done == false
		local is_shield_slam = nil

		if damage_profile.default_target.attack_template and damage_profile.default_target.attack_template == "heavy_blunt_fencer" then
			is_shield_slam = true
		end

		if is_push then
			heal_amount = 0.6
		end

		local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
      	local equipment = inventory_extension:equipment()
		local slot_data = equipment.slots.slot_melee

		if slot_data then
			local item_data = slot_data.item_data
			local weapon_template = item_data.template
			local item_name = item_data.name
			local damage_profile_aoe = Weapons[weapon_template].actions.action_one[attack_type] and Weapons[weapon_template].actions.action_one[attack_type].damage_profile_aoe or nil

			if item_name == "wh_2h_billhook" and heal_amount == 9 then
				heal_amount = 2
			end
			if item_name == "bw_ghost_scythe" and is_discharge and not is_push and heal_amount > 0 then
				heal_amount = 0.25	-- Change this number to adjust thp gain per target
			end
            if 	(item_name == "dr_shield_axe" or "dr_shield_hammer" or "es_mace_shield" or "es_sword_shield" or "wh_hammer_shield")
			 	and attack_type == "heavy_attack"
				and is_shield_slam
				and heal_amount > 0 then
					if damage_profile_aoe then
                		heal_amount = 0.75 -- nerf shield thp gain
					end
            end
    	end
		if target_index and target_index < 5 and breed and not breed.is_hero and (attack_type == "light_attack" or attack_type == "heavy_attack" or attack_type == "action_push") and not is_corpse then
			DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
		end
	end
end)
mod:add_buff_template("rebaltourn_vanguard", {
	multiplier = 1,
	name = "vanguard",
	event_buff = true,
	buff_func = "rebaltourn_heal_stagger_targets_on_melee",
	event = "on_stagger",
	perks = { buff_perks.tank_healing }
})

-- THP on Cleave
mod:add_buff_template("rebaltourn_reaper", {
	multiplier = -0.05,
	name = "reaper",
	event_buff = true,
	buff_func = "heal_damage_targets_on_melee",
	event = "on_player_damage_dealt",
	perks = { buff_perks.linesman_healing },
	max_targets = 5,
	bonus = 0.25
})

-- THP on Kill
mod:add_buff_template("rebaltourn_bloodlust", {
	multiplier = 0.2,
	name = "bloodlust",
	event_buff = true,
	buff_func = "heal_percentage_of_enemy_hp_on_melee_kill",
	event = "on_kill",
	perks = { buff_perks.smiter_healing },
})

--[[

	Stagger Talents

]]
mod:add_buff_template("rebaltourn_smiter_unbalance", {
	max_display_multiplier = 0.4,
	name = "smiter_unbalance",
	display_multiplier = 0.2,
	perks = { buff_perks.smiter_stagger_damage }
})
mod:add_buff_template("rebaltourn_power_level_unbalance", {
	max_stacks = 1,
	name = "power_level_unbalance",
	stat_buff = "power_level",
	multiplier = 0.1 -- 0.075
})
mod:add_proc_function("rebaltourn_unbalance_debuff_on_stagger", function (owner_unit, buff, params)
	local hit_unit = params[1]
	local is_dummy = Unit.get_data(hit_unit, "is_dummy")
	local buff_type = params[7]

	if Unit.alive(owner_unit) and (is_dummy or Unit.alive(hit_unit)) and buff_type == "MELEE_1H" or buff_type == "MELEE_2H" then
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
	perks = { buff_perks.finesse_stagger_damage }
})

--Text Localization
mod:add_text("bloodlust_name", "Execute") -- Kill Execute
mod:add_text("reaper_name", "Carve") -- Cleave Carve
mod:add_text("vanguard_name", "Second Wind") -- Stagger Second Wind
mod:add_text("regrowth_name", "Sting") -- Crit Sting
mod:add_text("rebaltourn_regrowth_desc", "Melee Strikes restore 0.5 Temporary Health. Melee Critical Strikes and Headshots instead restore 2. Critical Headshots instead restore 4.")
--mod:add_text("rebaltourn_regrowth_desc", "Melee critical strikes gives you 1.5 temporary health and melee headshots restore 3 temporary health. Melee critical headshots restore 4.5 temporary health.")

mod:add_text("smiter_name", "Smiter")
mod:add_text("enhanced_power_name", "Enhanced Power")
mod:add_text("assassin_name", "Assassin")
mod:add_text("bulwark_name", "Bulwark")
mod:add_text("rebaltourn_tank_unbalance_desc", "When you stagger an enemy they take 15% more damage from all sources for 5 seconds.\n\nDeal 20% more damage to staggered enemies, increased to 40% against targets afflicted by more than one stagger effect.")
mod:add_text("rebaltourn_finesse_unbalance_desc", "Deal 20%% more damage to staggered enemies.\n\nEach hit against a staggered enemy adds another count of stagger. Headshots instead inflict 40%% bonus damage, as do strikes against enemies afflicted by more than one stagger effect.")

-- Replacing THP & Stagger Talents
local talent_first_row = {
	{
		"es_knight",
		"dr_ranger",
		"dr_engineer",
		"wh_priest",
		"bw_unchained",
	},
	{
		"es_mercenary",
		"wh_zealot",
	},
	{
		"es_huntsman",
		"es_questingknight",
		"dr_ironbreaker",
		"bw_adept", -- bw
	},
	{
		"dr_slayer",
		"bw_scholar", -- pyro
		"bw_necromancer"
	},
	{
		"we_waywatcher",
	},
	{
		"we_shade",
		"we_thornsister",
		"wh_bountyhunter",
	},
	{
		"we_maidenguard",
	},
	{
		"wh_captain",
	},
}

-- Stagger | Cleave | Kill
-- Second Wind | Carve | Execute
for i=1, #talent_first_row[1] do
	local career = talent_first_row[1][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
	})
	mod:modify_talent(career, 1, 2, {
		display_name = "reaper_name",
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
		display_name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
end

-- Cleave | Kill | Stagger
-- Carve | Execute | Second Wind
for i=1, #talent_first_row[2] do
	local career = talent_first_row[2][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "reaper_name",
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
		display_name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
	mod:modify_talent(career, 1, 3, {
		display_name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
	})
end

-- Stagger | Kill | Cleave
-- Second Wind | Execute | Carve
for i=1, #talent_first_row[3] do
	local career = talent_first_row[3][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
	})
	mod:modify_talent(career, 1, 2, {
		display_name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
	mod:modify_talent(career, 1, 3, {
		display_name = "reaper_name",
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
end

-- Cleave | Kill | Crit
-- Carve | Execute | Sting
for i=1, #talent_first_row[4] do
	local career = talent_first_row[4][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "reaper_name",
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
		display_name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
	mod:modify_talent(career, 1, 3, {
		display_name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
end

-- Crit | Cleave | Kill
-- Sting | Carve | Execute
for i=1, #talent_first_row[5] do
	local career = talent_first_row[5][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
	mod:modify_talent(career, 1, 2, {
		display_name = "reaper_name",
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
		display_name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
end

-- Crit | Kill | Cleave
-- Sting | Execute | Carve
for i=1, #talent_first_row[6] do
	local career = talent_first_row[6][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
	mod:modify_talent(career, 1, 2, {
		display_name = "bloodlust_name",
		description = "bloodlust_desc_3",
		buffs = {
			"rebaltourn_bloodlust"
		}
	})
	mod:modify_talent(career, 1, 3, {
		display_name = "reaper_name",
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
end

-- Cleave | Crit | Stagger
-- Carve | Sting | Second Wind
for i=1, #talent_first_row[7] do
	local career = talent_first_row[7][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "reaper_name",
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
		display_name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
	mod:modify_talent(career, 1, 3, {
		display_name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
	})
end

-- Crit | Cleave | Stagger
-- Sting | Carve | Second Wind
for i=1, #talent_first_row[8] do
	local career = talent_first_row[8][i]
	mod:modify_talent(career, 1, 1, {
		display_name = "regrowth_name",
		description = "rebaltourn_regrowth_desc",
		buffs = {
			"rebaltourn_regrowth"
		},
		description_values = {},
	})
	mod:modify_talent(career, 1, 2, {
		display_name = "reaper_name",
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
		display_name = "vanguard_name",
		description = "vanguard_desc",
		buffs = {
			"rebaltourn_vanguard"
		}
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
		"wh_priest",
		"bw_necromancer"
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

--Dr related changes
local IGNORED_SHARED_DAMAGE_TYPES = {
	wounded_dot = true,
	suicide = true,
	knockdown_bleed = true
}
local INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_SOURCES = {
	temporary_health_degen = true,
	overcharge = true,
	life_tap = true,
	ground_impact = true,
	life_drain = true
}
local INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_TYPES = {
	warpfire_face = true,
	vomit_face = true,
	vomit_ground = true,
	poison = true,
	warpfire_ground = true,
	plague_face = true,
}
local POISON_DAMAGE_TYPES = {
	aoe_poison_dot = true,
	poison = true,
	arrow_poison = true,
	arrow_poison_dot = true
}
local POISON_DAMAGE_SOURCES = {
	skaven_poison_wind_globadier = true,
	poison_dot = true
}
local INVALID_GROMRIL_DAMAGE_SOURCE = {
	temporary_health_degen = true,
	overcharge = true,
	life_tap = true,
	ground_impact = true,
	life_drain = true
}
local IGNORE_DAMAGE_REDUCTION_DAMAGE_SOURCE = {
	life_tap = true,
	suicide = true
}
local POSITION_LOOKUP = POSITION_LOOKUP

mod:hook_origin(DamageUtils, "apply_buffs_to_damage", function(current_damage, attacked_unit, attacker_unit, damage_source, victim_units, damage_type, buff_attack_type, first_hit, source_attacker_unit)
	local damage = current_damage
	local network_manager = Managers.state.network
	local attacker_unit_buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system") or ScriptUnit.has_extension(source_attacker_unit, "buff_system")

	if attacker_unit_buff_extension then
		attacker_unit_buff_extension:trigger_procs("damage_calculation_started", attacked_unit)
	end

	local attacked_player = Managers.player:owner(attacked_unit)
	local attacker_player = Managers.player:owner(attacker_unit)

	if attacked_player then
		damage = Managers.state.game_mode:modify_player_base_damage(attacked_unit, attacker_unit, damage, damage_type)
	end

	victim_units[#victim_units + 1] = attacked_unit

	local health_extension = ScriptUnit.extension(attacked_unit, "health_system")

	if health_extension:has_assist_shield() and not IGNORED_SHARED_DAMAGE_TYPES[damage_source] then
		local attacked_unit_id = network_manager:unit_game_object_id(attacked_unit)

		network_manager.network_transmit:send_rpc_clients("rpc_remove_assist_shield", attacked_unit_id)
	end

	if ScriptUnit.has_extension(attacked_unit, "buff_system") then
		local buff_extension = ScriptUnit.extension(attacked_unit, "buff_system")

		if SKAVEN[damage_source] then
			damage = buff_extension:apply_buffs_to_value(damage, "protection_skaven")
		elseif CHAOS[damage_source] or BEASTMEN[damage_source] then
			damage = buff_extension:apply_buffs_to_value(damage, "protection_chaos")
		end

		if DAMAGE_TYPES_AOE[damage_type] then
			damage = buff_extension:apply_buffs_to_value(damage, "protection_aoe")
		end

		if not IGNORE_DAMAGE_REDUCTION_DAMAGE_SOURCE[damage_source] then
			damage = buff_extension:apply_buffs_to_value(damage, "damage_taken")

			if ELITES[damage_source] then
				damage = buff_extension:apply_buffs_to_value(damage, "damage_taken_elites")
			end
		end

		if RangedAttackTypes[buff_attack_type] then
			damage = buff_extension:apply_buffs_to_value(damage, "damage_taken_ranged")
		end

		local status_extension = attacked_player and ScriptUnit.has_extension(attacked_unit, "status_system")

		if status_extension then
			local is_knocked_down = status_extension:is_knocked_down()

			if is_knocked_down then
				damage = (damage_type ~= "overcharge" and buff_extension:apply_buffs_to_value(damage, "damage_taken_kd")) or 0
			end

			local is_disabled = status_extension:is_disabled()

			if not is_disabled then
				local valid_damage_to_overheat = not INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_SOURCES[damage_source] and not INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_TYPES[damage_type]
				local unit_side = Managers.state.side.side_by_unit[attacked_unit]
				local player_and_bot_units = unit_side.PLAYER_AND_BOT_UNITS
				local shot_by_friendly = false
				local allies = (player_and_bot_units and #player_and_bot_units) or 0

				for i = 1, allies, 1 do
					local ally_unit =  player_and_bot_units[i]
					if ally_unit == attacker_unit then
						shot_by_friendly = true
					end
				end

                local is_poison_damage = POISON_DAMAGE_TYPES[damage_type] or POISON_DAMAGE_SOURCES[damage_source]
                local is_ranged_attack = RangedAttackTypes[buff_attack_type]

				if valid_damage_to_overheat and damage > 0 and not shot_by_friendly and not is_knocked_down and not is_poison_damage and not is_ranged_attack then
					local original_damage = damage
					local new_damage = buff_extension:apply_buffs_to_value(damage, "damage_taken_to_overcharge")

					if new_damage < original_damage then
						local damage_to_overcharge = original_damage - new_damage
						damage_to_overcharge = buff_extension:apply_buffs_to_value(damage_to_overcharge, "reduced_overcharge_from_passive")
						damage_to_overcharge = DamageUtils.networkify_damage(damage_to_overcharge)

						if attacked_player.remote then
							local peer_id = attacked_player.peer_id
							local unit_id = network_manager:unit_game_object_id(attacked_unit)
							local channel_id = PEER_ID_TO_CHANNEL[peer_id]

							RPC.rpc_damage_taken_overcharge(channel_id, unit_id, damage_to_overcharge)
						else
							DamageUtils.apply_damage_to_overcharge(attacked_unit, damage_to_overcharge)
						end

						damage = new_damage
					end
				end
			end
		end

		if attacker_unit_buff_extension then
			local is_grenade = buff_attack_type == AttackTypes.grenade or DamageUtils.attacker_is_fire_bomb(attacker_unit)

			if is_grenade then
				damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "explosion_damage")
			end

			local has_burning_perk = attacker_unit_buff_extension:has_buff_perk("burning") or attacker_unit_buff_extension:has_buff_perk("burning_balefire") or attacker_unit_buff_extension:has_buff_perk("burning_elven_magic")

			if has_burning_perk then
				local side_manager = Managers.state.side
				local side = side_manager.side_by_unit[attacked_unit]

				if side then
					local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
					local num_units = #player_and_bot_units

					for i = 1, num_units, 1 do
						local unit = player_and_bot_units[i]
						local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

						if talent_extension and talent_extension:has_talent("sienna_unchained_burning_enemies_reduced_damage") then
							damage = damage * (1 + BuffTemplates.sienna_unchained_burning_enemies_reduced_damage.buffs[1].multiplier)

							break
						end
					end
				end
			end
		end

		local boss_elite_damage_cap = buff_extension:get_buff_value("max_damage_taken_from_boss_or_elite")
		local all_damage_cap = buff_extension:get_buff_value("max_damage_taken")
		local has_anti_oneshot = buff_extension:has_buff_perk("anti_oneshot")

		if has_anti_oneshot then
			local max_health = health_extension:get_max_health()
			local max_damage_allowed = max_health * 0.3

			if damage > max_damage_allowed then
				damage = max_damage_allowed
			end
		end

		local breed = ALIVE[attacker_unit] and unit_get_data(attacker_unit, "breed")

		if breed and (breed.boss or breed.elite) then
			local min_damage_cap = nil
			min_damage_cap = (not boss_elite_damage_cap or not all_damage_cap or math.min(boss_elite_damage_cap, all_damage_cap)) and ((boss_elite_damage_cap and boss_elite_damage_cap) or all_damage_cap)

			if min_damage_cap and min_damage_cap <= damage then
				damage = math.max(damage * 0.5, min_damage_cap)
			end
		elseif all_damage_cap and all_damage_cap <= damage then
			damage = math.max(damage * 0.5, all_damage_cap)
		end

		if buff_extension:has_buff_type("shared_health_pool") and not IGNORED_SHARED_DAMAGE_TYPES[damage_source] then
			local attacked_side = Managers.state.side.side_by_unit[attacked_unit]
			local player_and_bot_units = attacked_side.PLAYER_AND_BOT_UNITS
			local num_player_and_bot_units = #player_and_bot_units
			local num_players_with_shared_health_pool = 1

			for i = 1, num_player_and_bot_units, 1 do
				local friendly_unit = player_and_bot_units[i]

				if friendly_unit ~= attacked_unit then
					local friendly_buff_extension = ScriptUnit.extension(friendly_unit, "buff_system")

					if friendly_buff_extension:has_buff_type("shared_health_pool") then
						num_players_with_shared_health_pool = num_players_with_shared_health_pool + 1
						victim_units[#victim_units + 1] = friendly_unit
					end
				end
			end

			damage = damage / num_players_with_shared_health_pool
		end

		local talent_extension = ScriptUnit.has_extension(attacked_unit, "talent_system")

		if talent_extension and talent_extension:has_talent("bardin_ranger_reduced_damage_taken_headshot") then
			local has_position = POSITION_LOOKUP[attacker_unit]

			if has_position and AiUtils.unit_is_flanking_player(attacker_unit, attacked_unit) and not buff_extension:has_buff_type("bardin_ranger_reduced_damage_taken_headshot_buff") then
				damage = damage * (1 + BuffTemplates.bardin_ranger_reduced_damage_taken_headshot_buff.buffs[1].multiplier)
			end
		end

		local is_invulnerable = buff_extension:has_buff_perk("invulnerable")
		local has_gromril_armor = buff_extension:has_buff_type("bardin_ironbreaker_gromril_armour")
		local has_metal_mutator_gromril_armor = buff_extension:has_buff_type("metal_mutator_gromril_armour")
		local valid_damage_source = not INVALID_GROMRIL_DAMAGE_SOURCE[damage_source]
		local unit_side = Managers.state.side.side_by_unit[attacked_unit]

		if unit_side and unit_side:name() == "dark_pact" then
			is_invulnerable = is_invulnerable or damage_source == "ground_impact"
		end

		if is_invulnerable or ((has_gromril_armor or has_metal_mutator_gromril_armor) and valid_damage_source) then
			damage = 0
		end

		if has_gromril_armor and valid_damage_source and current_damage > 0 then
			local buff = buff_extension:get_non_stacking_buff("bardin_ironbreaker_gromril_armour")
			local id = buff.id

			buff_extension:remove_buff(id)
			buff_extension:trigger_procs("on_gromril_armour_removed")

			local attacked_unit_id = network_manager:unit_game_object_id(attacked_unit)

			network_manager.network_transmit:send_rpc_clients("rpc_remove_gromril_armour", attacked_unit_id)
		end

		if buff_extension:has_buff_type("invincibility_standard") then
			local buff = buff_extension:get_non_stacking_buff("invincibility_standard")

			if not buff.applied_damage then
				buff.stored_damage = (not buff.stored_damage and damage) or buff.stored_damage + damage
				damage = 0
			end
		end
	end

	if attacker_unit_buff_extension then
		local attacked_buff_extension = ScriptUnit.has_extension(attacked_unit, "buff_system")

		if attacker_player then
			local item_data = rawget(ItemMasterList, damage_source)
			local weapon_template_name = item_data and item_data.template

			if weapon_template_name then
				local weapon_template = Weapons[weapon_template_name]
				local buff_type = weapon_template.buff_type

				if buff_type then
					damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage")

					if attacker_unit_buff_extension:has_buff_perk("missing_health_damage") then
						local attacked_health_extension = ScriptUnit.extension(attacked_unit, "health_system")
						local missing_health_percentage = 1 - attacked_health_extension:current_health_percent()
						local damage_mult = 1 + missing_health_percentage / 2
						damage = damage * damage_mult
					end
				end

				local is_melee = MeleeBuffTypes[buff_type]
				local is_ranged = RangedBuffTypes[buff_type]

				if is_melee then
					damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_melee")

					if buff_type == "MELEE_1H" then
						damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_melee_1h")
					elseif buff_type == "MELEE_2H" then
						damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_melee_2h")
					end

					if buff_attack_type == "heavy_attack" then
						damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_heavy_attack")
					end

					if first_hit then
						damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "first_melee_hit_damage")
					end
				elseif is_ranged then
					damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_ranged")
					local attacked_health_extension = ScriptUnit.extension(attacked_unit, "health_system")

					if attacked_health_extension:current_health_percent() <= 0.9 or attacked_health_extension:current_max_health_percent() <= 0.9 then
						damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_ranged_to_wounded")
					end
				end

				local weapon_type = weapon_template.weapon_type

				if weapon_type then
					local stat_buff = WeaponSpecificStatBuffs[weapon_type].damage
					damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, stat_buff)
				end

				if is_melee or is_ranged then
					damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "reduced_non_burn_damage")
				end
			end

			if attacked_buff_extension then
				local has_poison_or_bleed = attacked_buff_extension:has_buff_perk("poisoned") or attacked_buff_extension:has_buff_perk("bleeding")

				if has_poison_or_bleed then
					damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_poisoned_or_bleeding")
				end
			end

			if damage_type == "burninating" then
				damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_burn_dot_damage")
			end
		end

		damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "damage_dealt")

		local has_balefire, applied_this_frame = Managers.state.status_effect:has_status(attacked_unit, StatusEffectNames.burning_balefire)
		if has_balefire and not applied_this_frame then
			damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_damage_to_balefire")
		end
	end

	Managers.state.game_mode:damage_taken(attacked_unit, attacker_unit, damage, damage_source, damage_type)

	if attacker_unit_buff_extension then
		attacker_unit_buff_extension:trigger_procs("damage_calculation_ended", attacked_unit)
	end

	return damage
end)


-- Shield Push Nerfs
-- Nerfs all shields' damage_profile_inner to "medium push"
Weapons.one_handed_sword_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_sword_shield_template_2.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_hammer_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_hammer_shield_template_2.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_hand_axe_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_spears_shield_template.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_hammer_shield_priest_template.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_flail_shield_template.actions.action_one.push.damage_profile_inner = "medium_push"