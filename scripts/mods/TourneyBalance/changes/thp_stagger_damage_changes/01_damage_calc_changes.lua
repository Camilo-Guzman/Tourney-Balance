local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

-- Fixes the cannons crashing the game in "Return of the Reik"
mod:hook(DamageUtils, "stagger_ai", function (func, t, damage_profile, target_index, power_level, target_unit, attacker_unit, hit_zone_name, attack_direction, boost_curve_multiplier, is_critical_strike, blocked, damage_source, source_attacker_unit, optional_predicted_damage)
	if not attacker_unit then
		if not POSITION_LOOKUP[target_unit] then
			return
		end
		attacker_unit = target_unit
	end
	if not POSITION_LOOKUP[target_unit] and (not target_unit or not Unit.alive(target_unit)) then
		return
	end
	return func(t, damage_profile, target_index, power_level, target_unit, attacker_unit, hit_zone_name, attack_direction, boost_curve_multiplier, is_critical_strike, blocked, damage_source, source_attacker_unit, optional_predicted_damage)
end)

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

		local is_direct_hit = not (damage_profile and (damage_profile.is_dot or damage_profile.is_explosion))
		-- Excludes push/shield-slam splash hits, i.e. only the center/damage-dealing hit can generate stagger count.
		local is_center_hit = not damage_profile.no_damage
		local mainstay_item_data = rawget(ItemMasterList, damage_source)
		local mainstay_weapon_template_name = mainstay_item_data and mainstay_item_data.template
		local mainstay_weapon_template = mainstay_weapon_template_name and Weapons[mainstay_weapon_template_name]
		local mainstay_buff_type = mainstay_weapon_template and mainstay_weapon_template.buff_type
		local is_melee_hit = mainstay_buff_type == "MELEE_1H" or mainstay_buff_type == "MELEE_2H"

		if is_direct_hit and is_center_hit and is_melee_hit and buff_extension and buff_extension:has_buff_perk("linesman_stagger_damage") then
			local target_buff_extension = ScriptUnit.has_extension(target_unit, "buff_system")
			local mainstay_target_breed = Unit.get_data(target_unit, "breed")
			-- Mainstay stagger counts are not applied to bosses/lords
			local is_boss_or_lord = mainstay_target_breed and (mainstay_target_breed.boss or mainstay_target_breed.lord_damage_reduction)

			if target_buff_extension and not is_boss_or_lord then
				target_buff_extension:add_buff("tb_mainstay_stagger_mark_buff")

				--[[
					Foot Knight: Have At Thee! / Inspiring Blow - Proc from Mainstay stagger count
				]]
				if mainstay_target_breed and mainstay_target_breed.elite then
					local attacker_talent_extension = ScriptUnit.has_extension(attacker_unit, "talent_system")

					if attacker_talent_extension then
						if attacker_talent_extension:has_talent("markus_knight_power_level_on_stagger_elite", "empire_soldier", true) then
							mod_api.add_buff(attacker_unit, "markus_knight_power_level_on_stagger_elite_buff")
						end

						if attacker_talent_extension:has_talent("markus_knight_cooldown_on_stagger_elite", "empire_soldier", true) then
							-- Self only, matching the regular on_stagger proc (career_changes/03_es_knight.lua);
							-- separate/weaker buff than that one since Mainstay procs far more often.
							mod_api.add_buff(attacker_unit, "tb_markus_knight_cooldown_buff_mainstay")
						end
					end
				end
			end
		end
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

-- Stagger marks on the target:
-- Mainstay marks (dummy_stagger) only count for attackers with Mainstay.
-- Bulwark marks (tb_tank_stagger_mark_buff stacks) count for every attacker.
local function add_stagger_marks(target_unit, has_mainstay, stagger_number)
	local target_buff_extension = ScriptUnit.has_extension(target_unit, "buff_system")

	if not target_buff_extension then
		return stagger_number
	end

	if has_mainstay then
		stagger_number = target_buff_extension:apply_buffs_to_value(stagger_number, "dummy_stagger")
	end

	return stagger_number + target_buff_extension:num_buff_type("tb_tank_stagger_mark_buff")
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

local MURDEROUS_PROWESS_MAX_TARGETS = 2

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

		local is_melee = damage_profile and (damage_profile.charge_value == "light_attack" or damage_profile.charge_value == "heavy_attack")

		-- Shade's Ruthless Precision: melee headshots count as backstabs (_check_backstab doesn't know the hit zone).
		-- Sound and on_backstab procs: 11_we_shade.lua
		if breed and (not backstab_multiplier or backstab_multiplier <= 1) and is_melee and buff_extension:has_buff_perk("tb_headshot_counts_as_backstab") and DamageUtils.get_breed_damage_multiplier_type(breed, hit_zone_name) == "headshot" then
			backstab_multiplier = buff_extension:apply_buffs_to_value(1, "backstab_multiplier")
		end

		-- Shade's Murderous Prowess (the only source of this perk): the charged crit backstab instakill only applies to the
		-- first MURDEROUS_PROWESS_MAX_TARGETS enemies an attack hits. Melee target_index counts the enemies hit, starting at 1
		if has_crit_backstab_killing_blow_perk and target_index and target_index > MURDEROUS_PROWESS_MAX_TARGETS then
			has_crit_backstab_killing_blow_perk = false
		end
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
		local has_mainstay = buff_extension and buff_extension:has_buff_perk("linesman_stagger_damage")

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

			stagger_number = add_stagger_marks(target_unit, has_mainstay, stagger_number)

			if not damage_profile.no_stagger_damage_reduction_ranged then
				stagger_number = apply_buffs_to_stagger_damage(attacker_unit, target_unit, target_index, hit_zone_name, is_critical_strike, stagger_number)
			end
		elseif dummy_unit_armor then
			stagger_number = add_stagger_marks(target_unit, has_mainstay, 0)

			if damage_profile.no_stagger_damage_reduction_ranged then
				local stagger_number_override = 1
				stagger_number = math.max(stagger_number_override, stagger_number)
			end

			if not damage_profile.no_stagger_damage_reduction_ranged then
				stagger_number = apply_buffs_to_stagger_damage(attacker_unit, target_unit, target_index, hit_zone_name, is_critical_strike, stagger_number)
			end
		end

		stagger_number = math.min(stagger_number, has_mainstay and 3 or 2) -- Cap: 3 for Mainstay users (0%/40%/60%), 2 for everyone else

		local min_stagger_damage_coefficient = difficulty_settings.min_stagger_damage_coefficient
		--local stagger_damage_multiplier = difficulty_settings.stagger_damage_multiplier
		local stagger_damage_multiplier = 0.2 -- fixed 20% per stagger count (1/2 -> 20%/40%), regardless of difficulty_settings.stagger_damage_multiplier

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

	-- Templar's Knowledge/I Shall Judge You All
	if calculated_damage and calculated_damage > 0 and attacker_unit and target_unit then
		local attacker_talent_extension = ScriptUnit.has_extension(attacker_unit, "talent_system")

		if attacker_talent_extension and attacker_talent_extension:has_talent("victor_witchhunter_improved_damage_taken_ping") then
			local is_direct_hit = not (damage_profile and (damage_profile.is_dot or damage_profile.is_explosion))
			if is_direct_hit then
				local target_buff_extension = ScriptUnit.has_extension(target_unit, "buff_system")
				-- Templars Knowledge
				if target_buff_extension and target_buff_extension:has_buff_type("defence_debuff_enemies") and not (breed and breed.boss) then
					calculated_damage = calculated_damage * 1.25
				end
			end
		end
	end

	return calculated_damage
end)
