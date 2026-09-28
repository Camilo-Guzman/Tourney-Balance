local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/01_es_mercenary") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/02_es_huntsman") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/03_es_knight") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/04_es_questingknight") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/05_dr_ranger") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/06_dr_ironbreaker") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/07_dr_slayer") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/08_dr_engineer") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/09_we_waywatcher") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/10_we_maidenguard") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/11_we_shade") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/12_we_thornsister") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/13_wh_captain") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/14_wh_bountyhunter") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/15_wh_zealot") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/16_wh_priest") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/17_bw_adept") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/18_bw_scholar") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/19_bw_unchained") -- ok
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes/20_bw_necromancer") -- ok

--[[
	Timed Block Long
]]
-- Adds longer timed block window for Shade Blur with 0.75s window, instead of 0.5s.
table.insert(ProcEvents, "on_timed_block_long")
-- GenericStatusExtension.init sets status fields
mod:hook_safe(GenericStatusExtension, "init", function (self, extension_init_context, unit, extension_init_data)
	self.timed_block_long = nil
end)
-- ActionBlock.client_owner_start_action only needs to set timed_block_long once
mod:hook_safe(ActionBlock, "client_owner_start_action", function (self, new_action, t)
	self._status_extension.timed_block_long = t + 0.75
end)
-- Efficient check using ActionMeleeStart.client_owner_post_update setting timed_block first.
-- Registered through the dispatcher in TourneyBalance.lua, runs after the original.
mod:add_melee_start_post_update_function(function (self, dt, t, world)
	local status_extension = self.status_extension
	
	if status_extension.timed_block == t + 0.5 then
		status_extension.timed_block_long = t + 0.75
	end
end)
-- full override so on_timed_block_long check can run before self:add_fatigue_points(...)
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

		-- Timed block long check
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
			local weapon_template = WeaponUtils.get_weapon_template(weapon_template_name)

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
			Unit.animation_event(unit, "parry_hit_reaction")
		end

		Managers.state.entity:system("play_go_tutorial_system"):register_block()
		Managers.state.achievement:trigger_event("player_blocked_attack", player, attacking_unit)
	end

	if blocking_unit then
		local unit_pos = POSITION_LOOKUP[blocking_unit]
		local unit_rot = Unit.world_rotation(blocking_unit, 0)
		local particle_position = unit_pos + Quaternion.up(unit_rot) * Math.random() * 0.5 + Quaternion.right(unit_rot) * 0.1

		World.create_particles(self.world, "fx/wpnfx_sword_spark_parry", particle_position)
	end
end)

--[[

	Fixes

]]
-- Explosion kill credit fix
mod:hook_safe(PlayerProjectileHuskExtension, "init", function (self, extension_init_data)
	self.owner_unit = extension_init_data.owner_unit
end)

-- Fix early explosion from getting disabled
-- Removes the forced self:explode() when exiting PlayerCharacterStateOverchargeExploding without having exploded yet.
mod:hook_origin(PlayerCharacterStateOverchargeExploding, "on_exit", function (self, unit, input, dt, context, t, next_state)
	if not Managers.state.network:game() or not next_state then
		return
	end

	CharacterStateHelper.play_animation_event(unit, "cooldown_end")
	CharacterStateHelper.play_animation_event_first_person(self.first_person_extension, "cooldown_end")

	if self.falling and next_state ~= "falling" then
		ScriptUnit.extension(unit, "whereabouts_system"):set_no_landing()
	end
end)

-- Fix clients getting too much ult recharge on explosions
mod_api.insert_proc_function("reduce_activated_ability_cooldown", function (owner_unit, buff, params)
	if Unit.alive(owner_unit) then
		local attack_type = params[2]
		local target_number = params[4]
		local career_extension = ScriptUnit.extension(owner_unit, "career_system")

		if not attack_type or attack_type == "heavy_attack" or attack_type == "light_attack" then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		elseif attack_type == "aoe" then
            return
		elseif target_number and target_number == 1 then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		end
	end
end)

-- Firebomb fix? Fire damage starts ealier.
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod_api.insert_buff_template("burning_dot_fire_grenade", {
	apply_buff_func = "start_dot_damage",
	damage_profile = "burning_dot_firegrenade",
	damage_type = "burninating",
	duration = 6,
	name = "burning_dot_fire_grenade",
	time_between_dot_damages = 1,
	update_func = "apply_dot_damage",
	update_start_delay = 0.75, -- 1
	perks = {
		buff_perks.burning,
	},
	max_stacks_func = function (unit, template)
		local breed = AiUtils.unit_breed(unit)

		if breed and breed.is_player then
			local mechanism_name = Managers.mechanism:current_mechanism_name()

			if mechanism_name == "versus" then
				return 1
			end
		end

		return math.huge
	end,
	refresh_durations_func = function (unit, template)
		local breed = AiUtils.unit_breed(unit)

		if breed and breed.is_player then
			local mechanism_name = Managers.mechanism:current_mechanism_name()

			if mechanism_name == "versus" then
				return true
			end
		end

		return false
	end,
	duration_modifier_func = function (unit, sub_buff_template, duration, buff_extension, params)
		local is_versus = Managers.mechanism:current_mechanism_name() == "versus"

		if not is_versus then
			return duration
		end

		local breed = AiUtils.unit_breed(unit)

		if breed and breed.is_player then
			local versus_player_duration = 2

			return versus_player_duration
		end

		return duration
	end,
})
-- Reduce super amour damage
DamageProfileTemplates.burning_dot_firegrenade.default_target.armor_modifier.attack[6] = 0.25 -- 0.5

-- Remove Stam-Tech
local DOUBLE_TAP_DODGES = {
	move_left_pressed = Vector3Box(-Vector3.right()),
	move_right_pressed = Vector3Box(Vector3.right()),
	move_back_pressed = Vector3Box(-Vector3.forward()),
}

-- Stam-Tech: Internal Cooldown
local STAM_TECH_COOLDOWN = 120

CharacterStateHelper.check_to_start_dodge = function (unit, input_extension, status_extension, t)
	if status_extension:dodge_locked() or not status_extension:can_dodge(t) then
		return false
	end

	local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)
	local input = CharacterStateHelper.get_movement_input(input_extension)
	local double_tap_dodge = input_extension.double_tap_dodge
	local start_dodge = false
	local dodge_direction = Vector3(0, 0, 0)
	local dodge_hold = input_extension:get("dodge_hold")
	local manual_dodge = input_extension:get("dodge")
	local dodge_input = manual_dodge or input_extension:get("jump") and dodge_hold
	local input_length = Vector3.length(input)
	local using_keyboard = not Managers.input:is_device_active("gamepad")
	local stationary_dodge = Application.user_setting("toggle_stationary_dodge")

	if double_tap_dodge then
		for input, dir in pairs(DOUBLE_TAP_DODGES) do
			if input_extension:get(input) then
				local was_double_tap = input_extension:was_double_tap(input, t, Application.user_setting("double_tap_dodge_threshold"))

				for input, dir in pairs(DOUBLE_TAP_DODGES) do
					input_extension:clear_double_tap(input)
				end

				if was_double_tap then
					start_dodge = true
					dodge_direction = dir:unbox()

					break
				end

				input_extension:start_double_tap(input, t)

				break
			end
		end
	end

	if not start_dodge and dodge_input and input_length > input_extension.minimum_dodge_input then
		local normalized_input = input / input_length
		local x = normalized_input.x
		local y = normalized_input.y
		local abs_x = math.abs(x)
		local forward_ok = y <= 0 or not using_keyboard and abs_x > 0.9239 or manual_dodge and abs_x > 0.707

		if forward_ok then
			start_dodge = true

			if y > 0 then
				dodge_direction = Vector3(math.sign(x), 0, 0)
			else
				dodge_direction = normalized_input
			end
		end
	elseif dodge_input and stationary_dodge then
		start_dodge = true
		dodge_direction = -Vector3.forward()
	end

	if start_dodge then
		Managers.state.entity:system("play_go_tutorial_system"):register_dodge(dodge_direction)

		-- Stam-Tech Internal CD check
		-- fatigue can only exceed MAX_FATIGUE via the unclamped wield-swap rescale in GenericStatusExtension.update
		if status_extension.fatigue > PlayerUnitStatusSettings.MAX_FATIGUE then
			local last_stam_tech_t = status_extension._stam_tech_last_t
			if not last_stam_tech_t or t - last_stam_tech_t >= STAM_TECH_COOLDOWN then
				status_extension._stam_tech_last_t = t
				status_extension:add_fatigue_points("action_dodge")
			end
		end

		status_extension:set_dodge_locked(true)
		status_extension:add_dodge_cooldown()

		local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
	end

	return start_dodge, dodge_direction
end