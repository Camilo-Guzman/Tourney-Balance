local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[

	GENERAL

]]
--[[
    Flamethrowers (Flamestorm and Drakegun)
]]
Weapons.drakegun_template_1.actions.action_one.shoot_charged.damage_interval = 0.30
Weapons.staff_flamethrower_template.actions.action_one.shoot_charged.damage_interval = 0.30

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

--[[
    Handgun (Bardin and Kruber)
]]
local handgun_dropoff_ranges = {
	dropoff_end = 100,
	dropoff_start = 50,
}
DamageProfileTemplates.shot_sniper.default_target.range_modifier_settings = handgun_dropoff_ranges

--[[
    Shotgun Bash Nerf (Blunderbuss/Grudge Raker/Griffin Foot)
]]
-- Adds max stamina, stamina consumption, and removes chaining/starting the bash below 2 stamina points.
-- chain_condition_func gates transitions from active actions (e.g. fire-into-bash, bash-into-bash)
-- condition_func gates true idle state (no current action); separate fallback state in player_character_state_helper.lua
local MIN_STAMINA_POINTS_TO_BASH = 2
local function can_start_bash(owner_unit, input_extension)

	local status_extension = ScriptUnit.extension(owner_unit, "status_system")
	local consumed_points, max_points = status_extension:current_fatigue_points()

	return max_points - consumed_points >= MIN_STAMINA_POINTS_TO_BASH
end

Weapons.blunderbuss_template_1.max_fatigue_points = 6 -- nil
Weapons.blunderbuss_template_1.actions.action_two.default.add_fatigue_on_hit = true
Weapons.blunderbuss_template_1.actions.action_two.default.condition_func = can_start_bash
Weapons.blunderbuss_template_1.actions.action_two.default.chain_condition_func = can_start_bash

Weapons.grudge_raker_template_1.max_fatigue_points = 6 -- nil
Weapons.grudge_raker_template_1.actions.action_two.default.add_fatigue_on_hit = true
Weapons.grudge_raker_template_1.actions.action_two.default.condition_func = can_start_bash
Weapons.grudge_raker_template_1.actions.action_two.default.chain_condition_func = can_start_bash

Weapons.wh_deus_01_template_1.max_fatigue_points = 6 -- nil
Weapons.wh_deus_01_template_1.actions.action_two.default.add_fatigue_on_hit = true
Weapons.wh_deus_01_template_1.actions.action_two.default.condition_func = can_start_bash
Weapons.wh_deus_01_template_1.actions.action_two.default.chain_condition_func = can_start_bash

-- Prevent weapon swap while fatigued
-- action_wield table is shared by reference across nearly every weapon (ActionTemplates.wield),
-- Needs per-weapon clone before mutating chain_condition_func, otherwise prevents weapon swapping globally.
-- The original can_wield() check is preserved and evaluated first.
local original_wield_chain_condition_func = ActionTemplates.wield.default.chain_condition_func

local function block_wield_while_fatigued(owner_unit, input_extension)
	if not original_wield_chain_condition_func(owner_unit, input_extension) then
		return false
	end

	local status_extension = ScriptUnit.extension(owner_unit, "status_system")

	return not status_extension:fatigued()
end

Weapons.blunderbuss_template_1.actions.action_wield = table.clone(ActionTemplates.wield)
Weapons.blunderbuss_template_1.actions.action_wield.default.chain_condition_func = block_wield_while_fatigued

Weapons.grudge_raker_template_1.actions.action_wield = table.clone(ActionTemplates.wield)
Weapons.grudge_raker_template_1.actions.action_wield.default.chain_condition_func = block_wield_while_fatigued

Weapons.wh_deus_01_template_1.actions.action_wield = table.clone(ActionTemplates.wield)
Weapons.wh_deus_01_template_1.actions.action_wield.default.chain_condition_func = block_wield_while_fatigued

-- Stamina consumption on shield_slam hit, if add_fatigue_on_hit is set and enemy is hit.
-- Shields go through same ActionShieldSlam class, but never set add_fatigue_on_hit.
mod:hook_safe(ActionShieldSlam, "_hit", function (self, world, can_damage, owner_unit, current_action)
	if current_action.add_fatigue_on_hit and self._num_targets_hit > 0 then
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		local status_extension = ScriptUnit.extension(owner_unit, "status_system")

		self:_handle_fatigue(buff_extension, status_extension, current_action, false)
	end
end)

--[[
	Shield Push Nerfs
]]
-- Nerfs all shields' damage_profile_inner to "medium push"
Weapons.one_handed_sword_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_sword_shield_template_2.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_hammer_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_hammer_shield_template_2.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_hand_axe_shield_template_1.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_spears_shield_template.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_hammer_shield_priest_template.actions.action_one.push.damage_profile_inner = "medium_push"
Weapons.one_handed_flail_shield_template.actions.action_one.push.damage_profile_inner = "medium_push"

