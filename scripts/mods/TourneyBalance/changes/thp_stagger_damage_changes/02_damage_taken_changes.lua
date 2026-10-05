local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

-- Incoming damage buffs/mitigation (Gromril, overcharge conversion, shared health pool, etc.)
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
local unit_get_data = Unit.get_data

-- Base implementation for the apply_buffs_to_damage dispatcher (TourneyBalance.lua), which owns the single
-- hook_origin on DamageUtils.apply_buffs_to_damage. Other files wrap it via mod:add_apply_buffs_to_damage_wrapper.
mod:set_apply_buffs_to_damage(function(current_damage, attacked_unit, attacker_unit, damage_source, victim_units, damage_type, buff_attack_type, first_hit, source_attacker_unit)
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
				-- Shade's Exploit Weakness: poison/bleed/burn each individually add 20%, stacking additively (up to 60% for all three)
				if attacker_unit_buff_extension:has_buff_perk("kerillian_shade_increased_damage_on_poisoned_or_bleeding_enemy") then
					local exploit_weakness_bonus = 0

					if attacked_buff_extension:has_buff_perk("poisoned") then
						exploit_weakness_bonus = exploit_weakness_bonus + 0.2
					end

					if attacked_buff_extension:has_buff_perk("bleeding") then
						exploit_weakness_bonus = exploit_weakness_bonus + 0.2
					end

					if Managers.state.status_effect:unit_is_burning(attacked_unit) then
						exploit_weakness_bonus = exploit_weakness_bonus + 0.2
					end

					damage = damage * (1 + exploit_weakness_bonus)
				else
					local has_poison_or_bleed = attacked_buff_extension:has_buff_perk("poisoned") or attacked_buff_extension:has_buff_perk("bleeding")

					if has_poison_or_bleed then
						damage = attacker_unit_buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_poisoned_or_bleeding")
					end
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
