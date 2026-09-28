local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local is_server = require("scripts/mods/TourneyBalance/_api/shared_utils").is_server

-- Forward-declared: defined in the Birch Stance section further down, but called from the shared
-- update_weapon_actions hook in the Oak Guard section above it.
local tb_maidenguard_update_birch_stance_damage_reduction

--[[
	$BEGIN_TB
		---
		## Handmaiden
		### Career Ability
		- Increased hitbox width/depth ult to 2/3 (from 1.5/0.4).

		### Passives
		**Dance of Seasons**
		- Added effect: Hitting enemies taunts them for 1 seconds. Does not apply to Lords and Bosses.

		**Renewal**
		- Stam regen aura range increased to 20 (from 5).
		- Healing received beyond max health is given as THP, split between allies in the aura that are not at full health.

		**Oak Guard (listed)**
		- (Added to list) Increases maximum stamina by 1.
		- Added effect: Blocking starts immediately, even mid-attack.
		- Added 40% increased healing received.

		### Talents
		**Focused Spirit**
		- Changed to 30% melee power (from 15% power).
		- Decreased reset duration to 4s (from 10s).

		**Oak Stance**
		- Increased crit chance to 10% (from 5%).
		- Added 30% crit power.

		**Asrai Alacrity**
		- Increased stacks gained to 3 (from 2).

		**Dance of Blades**
		- Increased power to 15% (from 10%) and duration to 6s (from 2s).
		- Instant dodges (1s cooldown each), tracked separately for blocking and non-blocking dodges.

		**Heart of Oak**
		- Increased health bonus to 20% (from 15%).

		**Birch Stance**
		- Added 30% reduced damage taken while blocking.

		**Quiver of Plenty**
		- Increased ammo bonus to 100% (from 40%).
	$END_TB
]]

--[[

	Ultimate

]]
-- Increased hitbox for non-bleed ult (for Power from Pain)
mod:hook(CareerAbilityWEMaidenGuard, "_run_ability", function (func, self, ...)
    func(self, ...)

    local status_extension = self._status_extension
    -- hitbox is a rectangular cube / cuboid with given width, height and length, and offset_forward changes its position relative to character's
    status_extension.do_lunge.damage.width = 2    --1.5    --width of hitbox
    status_extension.do_lunge.damage.depth_padding = 3  --0.4    --length of hitbox
    status_extension.do_lunge.damage.offset_forward = 0   --0    --position of hitbox

end)

local function tb_noop() end

-- General fix for the same underlying whereabouts-tracking crash the two hooks below also guard against
mod:hook(PlayerWhereaboutsExtension, "update", function (func, self, unit, input, dt, context, t)
    local queued_input = self._input

    if queued_input then
        local opening = queued_input.jumped or queued_input.fell
        local closing = queued_input.no_landing or queued_input.landed

        if opening and closing then
            queued_input.jumped = nil
            queued_input.fell = nil
            queued_input.no_landing = nil
            queued_input.landed = nil
        end
    end

    return func(self, unit, input, dt, context, t)
end)

--[[

    Passives

]]
--[[
    Oak Guard - listed
]]
-- 40% increased healing received (moved from Heart of Oak)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_maidenguard_oak_guard_healing_received", {
	stat_buff = "healing_received",
	multiplier = 0.4,
})
mod_api.insert_career_passives("we_2", {
    "tb_kerillian_maidenguard_oak_guard_healing_received",
})
mod_api.insert_perk_text("tb_we_2d", "Oak Guard", "Increases stamina by 1. Blocking starts instantly.")
mod_api.insert_career_perk_descriptions("we_2", "tb_we_2d")

-- Blocking starts immediately: raise the "blocking" status the instant block is pressed, independent of the
-- current weapon action, so the current attack's animation keeps playing while damage mitigation is already active.
-- Always active for the career (not tied to a talent pick), matching the other always-on base passives.
local function tb_instant_block_wielding_blockable_melee(inventory_extension)
    local equipment = inventory_extension:equipment()
    local wielded = equipment.wielded
    local weapon_template_name = wielded and (wielded.template or wielded.temporary_template)
    local weapon_template = weapon_template_name and WeaponUtils.get_weapon_template(weapon_template_name)
    local action_two = weapon_template and weapon_template.actions and weapon_template.actions.action_two

    return action_two ~= nil and action_two.default ~= nil and action_two.default.kind == "block"
end

local function tb_instant_block_set_blocking(unit, status_extension, blocking, t)
    status_extension:set_blocking(blocking)

    if blocking then
        status_extension.timed_block = t + 0.5
    end

    local network_manager = Managers.state.network
    local game = network_manager:game()
    local go_id = game and network_manager:unit_game_object_id(unit)

    if go_id then
        if is_server() then
            network_manager.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, blocking)
        else
            network_manager.network_transmit:send_rpc_server("rpc_set_blocking", go_id, blocking)
        end
    end
end

-- Let real weapon action system go first, so push chaining back into block on continued hold happens completely untouched.
mod:hook(CharacterStateHelper, "update_weapon_actions", function (func, t, unit, input_extension, inventory_extension, health_extension)
    func(t, unit, input_extension, inventory_extension, health_extension)

    local career_extension = ScriptUnit.has_extension(unit, "career_system")

    if not career_extension or career_extension:career_name() ~= "we_maidenguard" then
        return
    end

    local status_extension = ScriptUnit.extension(unit, "status_system")

    if tb_instant_block_wielding_blockable_melee(inventory_extension) then
        local wants_block = input_extension:get("action_two_hold")

        if wants_block and not status_extension.blocking then
            tb_instant_block_set_blocking(unit, status_extension, true, t)

            status_extension._tb_instant_block_forced_block = true
        elseif status_extension._tb_instant_block_forced_block and not wants_block then
            tb_instant_block_set_blocking(unit, status_extension, false, t)

            status_extension._tb_instant_block_forced_block = false
        end
    end

    --[[
        Birch Stance
    ]]
    tb_maidenguard_update_birch_stance_damage_reduction(unit, status_extension)
end)

--[[
    Renewal
]]
-- Replace the vanilla Renewal perk text (career_passive_name_we_2b) instead of adding a second Renewal entry
mod_api.insert_text("career_passive_desc_we_2b_2", "Aura that increases stamina regeneration speed by 100%. Kerillian's gains 40% increased healing received and shares overflowing healing as temporary health to injured teammates.")
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_stamina_regen_aura", {
	range = 20 -- 5
})

-- Any healing (THP or permanent) Handmaiden gains beyond her max health is divided evenly between the alive allies inside the Renewal aura
-- that are not at full health, and given to them as THP. Registered through the add_heal dispatcher in TourneyBalance.lua.
local RENEWAL_AURA_BUFF = "kerillian_maidenguard_passive_stamina_regen_aura"
local RENEWAL_SHARE_HEAL_TYPE = "heal_from_proc"
local renewal_sharing = false -- guards against the share heals re-entering this wrapper
local renewal_recipients = {}

local function get_renewal_aura_range()
    local template = BuffTemplates[RENEWAL_AURA_BUFF]
    local sub_buff = template and template.buffs and template.buffs[1]

    return (sub_buff and sub_buff.range) or 20
end

mod:add_player_add_heal_wrapper(function (func, self, healer_unit, heal_amount, heal_source_name, heal_type)
    local unit = self.unit
    local game = self.game
    local game_object_id = self.health_game_object_id
    local status_extension = self.status_extension
    local overflow = 0

    if self.is_server and not renewal_sharing and game and game_object_id and heal_amount > 0
        and not status_extension:is_knocked_down() then
        local career_extension = ScriptUnit.has_extension(unit, "career_system")

        if career_extension and career_extension:career_name() == "we_maidenguard" then
            local current_health = GameSession.game_object_field(game, game_object_id, "current_health")
            local current_temporary_health = GameSession.game_object_field(game, game_object_id, "current_temporary_health")
            local max_health = GameSession.game_object_field(game, game_object_id, "max_health")

            if status_extension:is_permanent_heal(heal_type) then
                -- Permanent heals convert THP into permanent health first, so only healing past max permanent health is wasted
                overflow = math.clamp(current_health + heal_amount - max_health, 0, heal_amount)
            else
                overflow = math.clamp(current_health + current_temporary_health + heal_amount - max_health, 0, heal_amount)
            end
        end
    end

    local result = func(self, healer_unit, heal_amount, heal_source_name, heal_type)

    if overflow <= 0 then
        return result
    end

    local side = Managers.state.side.side_by_unit[unit]
    local player_and_bot_units = side and side.PLAYER_AND_BOT_UNITS

    if not player_and_bot_units then
        return result
    end

    local range = get_renewal_aura_range()
    local range_sq = range * range
    local position = POSITION_LOOKUP[unit]
    local num_recipients = 0

    table.clear(renewal_recipients)

    -- Recipients: alive, standing allies in the aura that are not at full health (Handmaiden is full, so she never qualifies)
    for i = 1, #player_and_bot_units do
        local ally_unit = player_and_bot_units[i]

        if ally_unit ~= unit and HEALTH_ALIVE[ally_unit] then
            local ally_position = POSITION_LOOKUP[ally_unit]
            local ally_status_extension = ScriptUnit.has_extension(ally_unit, "status_system")
            local ally_health_extension = ScriptUnit.has_extension(ally_unit, "health_system")
            local ally_game_object_id = ally_health_extension and ally_health_extension.health_game_object_id

            if ally_position and position and ally_game_object_id and Vector3.distance_squared(position, ally_position) <= range_sq
                and ally_status_extension and not ally_status_extension:is_knocked_down() then
                local ally_current_health = GameSession.game_object_field(game, ally_game_object_id, "current_health")
                local ally_current_temporary_health = GameSession.game_object_field(game, ally_game_object_id, "current_temporary_health")
                local ally_max_health = GameSession.game_object_field(game, ally_game_object_id, "max_health")

                if ally_current_health + ally_current_temporary_health < ally_max_health then
                    num_recipients = num_recipients + 1
                    renewal_recipients[num_recipients] = ally_health_extension
                end
            end
        end
    end

    if num_recipients == 0 then
        return result
    end

    local share = overflow / num_recipients

    renewal_sharing = true

    for i = 1, num_recipients do
        renewal_recipients[i]:add_heal(unit, share, nil, RENEWAL_SHARE_HEAL_TYPE)
    end

    renewal_sharing = false
    table.clear(renewal_recipients)

    return result
end)

--[[
    Dance of Season
    + 1s taunt on hit
]]
mod_api.insert_proc_function("tb_maidenguard_taunt_on_hit", function (owner_unit, buff, params)
    if not is_server() then
        return
    end

    local hit_unit = params[1]

    if not hit_unit or not HEALTH_ALIVE[hit_unit] then
        return
    end

    local ai_extension = ScriptUnit.has_extension(hit_unit, "ai_system")

    if not ai_extension then
        return
    end

    local breed = ai_extension:breed()

    if breed.ignore_taunts or breed.boss then
        return
    end

    local blackboard = ai_extension:blackboard()
    local t = Managers.time:time("game")

    blackboard.taunt_unit = owner_unit
    blackboard.taunt_end_time = t + buff.template.taunt_duration
    blackboard.target_unit = owner_unit
    blackboard.target_unit_found_time = t
end)
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_maidenguard_taunt_on_hit", {
    buff_func = "tb_maidenguard_taunt_on_hit",
    event = "on_hit",
    taunt_duration = 1,
})
mod_api.insert_career_passives("we_2", {
    "tb_kerillian_maidenguard_taunt_on_hit",
})
mod_api.insert_text("career_passive_desc_we_2a_2", "Increased dodge distance by 15%. Hitting enemies taunts them for 1 seconds (excludes Lords and Bosses).")

--[[

	Talents

]]
--[[
    Focused Spirit
]]
-- Fix friendly fire reset buff
mod_api.insert_proc_function("maidenguard_reset_unharmed_buff", function (owner_unit, buff, params)
    local attacker_unit = params[1]
    local damage_amount = params[2]
    local damaged = true

    if damage_amount and damage_amount == 0 then
        damaged = false
    end

    -- Check for friendly fire
    local side = Managers.state.side.side_by_unit[owner_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local shot_by_friendly = false
    local allies = (player_and_bot_units and #player_and_bot_units) or 0

    for i = 1, allies, 1 do
        local ally_unit =  player_and_bot_units[i]
        if ally_unit == attacker_unit then
            shot_by_friendly = true
        end
    end

    if ALIVE[owner_unit] and not shot_by_friendly and damaged then
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
        local buff_name = "kerillian_maidenguard_power_level_on_unharmed_cooldown"
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit
        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

        if is_server() then
            buff_extension:add_buff(buff_name, {
                attacker_unit = owner_unit
            })
        else
            network_transmit:send_rpc_server("rpc_insert_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end

        return true
    end
end)
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_power_level_on_unharmed", {
    multiplier = 0.30, -- 0.15%
	stat_buff = "power_level_melee", -- power_level
})
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_power_level_on_unharmed_cooldown", {
    duration = 3 -- 10
})
mod_api.update_talent("we_maidenguard", 2, 1, {
    description = "kerillian_maidenguard_power_level_on_unharmed_desc",
    description_values = {},
})
mod_api.insert_text("kerillian_maidenguard_power_level_on_unharmed_desc", "After not taking damage for 3 seconds, increases Kerillian's melee power by 30.0%. Reset upon taking damage, friendly fire will not reset the buff.")


--[[
    Oak Stance
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_crit_chance", {
	bonus = 0.1 -- 0.05
})
-- Additional 30% crit power
mod_api.insert_talent_buff_template("wood_elf", "tb_kerilllian_maidenguard_crit_power", {
	stat_buff = "critical_strike_effectiveness",
	multiplier = 0.3,
	max_stacks = 1
})
mod_api.update_talent("we_maidenguard", 2, 2, {
    description = "kerillian_maidenguard_crit_chance_desc",
    description_values = {},
    buffs = {
        "tb_kerilllian_maidenguard_crit_power",
		"kerillian_maidenguard_crit_chance"
    },
})
mod_api.insert_text("kerillian_maidenguard_crit_chance_desc", "Increases critical strike chance by 10.0% and critical strike damage by 30.0%.")


--[[
    Asrai Alacrity
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_push", {
    amount_to_add = 3, -- 2
    max_sub_buff_stacks = 3, -- 2
})
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block", {
    amount_to_add = 3, -- 2
    max_sub_buff_stacks = 3, -- 2
})
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_dummy_buff", {
    max_stacks = 3 -- 2
})
mod_api.insert_text("kerillian_maidenguard_speed_on_block_desc", "Blocking an attack or pushing an enemy grants the next 3 strikes 30%% attack speed and 10%% power.")


--[[
    Dance of Blades
]]
-- Now grants 15% power lasting for 6 seconds.
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_power_on_dodge", {
	duration = 6, -- 2
	multiplier = 0.15 -- 0.1
})
mod_api.update_talent("we_maidenguard", 4, 2, {
    description = "kerillian_maidenguard_versatile_dodge_desc",
    description_values = {},
})
mod_api.insert_text("kerillian_maidenguard_versatile_dodge_desc", "Dodging while blocking increases dodge range by 20%. Dodging while not blocking increases Kerillian's power by 15% for 6 seconds. Dodging starts instantly (1 second cooldown each).")

local function tb_always_on_ground()
    return true
end

local DANCE_OF_BLADES_CANCEL_COOLDOWN = 1

-- Instant dodge: Can start mid-dodge, 1s internal cooldown for blocking and non-blocking dodge
mod:hook(PlayerCharacterStateDodging, "update", function (func, self, unit, input, dt, context, t)
    local talent_extension = ScriptUnit.extension(unit, "talent_system")
    local has_dance_of_blades = talent_extension:has_talent("kerillian_maidenguard_versatile_dodge")

    if has_dance_of_blades and not self.csm.state_next then
        local status_extension = self.status_extension
        local cancel_cd_field = status_extension.blocking and "_tb_dance_of_blades_cancel_cd_blocking" or "_tb_dance_of_blades_cancel_cd_not_blocking"
        local cancel_ready = t >= (status_extension[cancel_cd_field] or 0)

        if cancel_ready then
            local start_dodge, dodge_direction = CharacterStateHelper.check_to_start_dodge(unit, self.input_extension, status_extension, t)

            if start_dodge then
                local params = self.temp_params

                params.dodge_direction = dodge_direction

                status_extension[cancel_cd_field] = t + DANCE_OF_BLADES_CANCEL_COOLDOWN

                self.csm:change_state("dodging", params)

                return
            end
        end
    end

    if not has_dance_of_blades then
        return func(self, unit, input, dt, context, t)
    end

    --[[
        Vanilla dodging also lets a jump input near the end of the dodge cancel it straight into a real jump ("dodge-jump").
        Uncomment below to prevent mid air dodge-jumps.
    ]]
    local locomotion_extension = self.locomotion_extension
    local real_is_on_ground = locomotion_extension.is_on_ground
    --local real_jump_allowed = locomotion_extension.jump_allowed
    --local really_on_ground = real_is_on_ground(locomotion_extension)

    locomotion_extension.is_on_ground = tb_always_on_ground
    --locomotion_extension.jump_allowed = function (self)
    --    return really_on_ground and real_jump_allowed(self)
    --end

    local ok, err = pcall(func, self, unit, input, dt, context, t)

    locomotion_extension.is_on_ground = real_is_on_ground
    --locomotion_extension.jump_allowed = real_jump_allowed

    if not ok then
        error(err, 0)
    end
end)

-- Allow dodging mid air and mid-ult
for _, state_class in ipairs({ PlayerCharacterStateJumping, PlayerCharacterStateFalling }) do
    mod:hook(state_class, "update", function (func, self, unit, input, dt, context, t)
        local talent_extension = ScriptUnit.extension(unit, "talent_system")

        if talent_extension:has_talent("kerillian_maidenguard_versatile_dodge") and not self.csm.state_next then
            local start_dodge, dodge_direction = CharacterStateHelper.check_to_start_dodge(unit, self.input_extension, self.status_extension, t)

            if start_dodge then
                local params = self.temp_params

                params.dodge_direction = dodge_direction

                self.csm:change_state("dodging", params)

                return
            end
        end

        return func(self, unit, input, dt, context, t)
    end)
end

--[[
    Heart of Oak
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_max_health", {
	multiplier = 0.2 -- 0.15
})
mod_api.update_talent("we_maidenguard", 5, 1, {
    description = "kerillian_maidenguard_max_health_desc",
    description_values = {},
    buffs = {
        "kerillian_maidenguard_max_health",
    },
})
mod_api.insert_text("kerillian_maidenguard_max_health_desc", "Increases max health by 20.0%.")

--[[
    Birch Stance
]]
-- Also grants 30% reduced damage taken while blocking
mod_api.insert_talent_buff_template("wood_elf", "tb_kerillian_maidenguard_birch_stance_damage_reduction", {
	stat_buff = "damage_taken",
	multiplier = -0.3,
})
mod_api.update_talent("we_maidenguard", 5, 2, {
    description = "kerillian_maidenguard_block_cost_desc",
    description_values = {},
})
mod_api.insert_text("kerillian_maidenguard_block_cost_desc", "Reduces block cost by 30.0% and damage taken by 30.0% while blocking.")

-- The damage reduction only applies while actually blocking. Called from the shared update_weapon_actions hook above (Oak Guard)
tb_maidenguard_update_birch_stance_damage_reduction = function (unit, status_extension)
    local talent_extension = ScriptUnit.extension(unit, "talent_system")

    if not talent_extension:has_talent("kerillian_maidenguard_block_cost") then
        return
    end

    local buff_extension = ScriptUnit.extension(unit, "buff_system")
    local has_damage_reduction = buff_extension:has_buff_type("tb_kerillian_maidenguard_birch_stance_damage_reduction")

    if status_extension.blocking and not has_damage_reduction then
        buff_extension:add_buff("tb_kerillian_maidenguard_birch_stance_damage_reduction")
    elseif not status_extension.blocking and has_damage_reduction then
        local buff = buff_extension:get_buff_type("tb_kerillian_maidenguard_birch_stance_damage_reduction")

        if buff then
            buff_extension:remove_buff(buff.id)
        end
    end
end


--[[
    Quiver of Plenty
]]
mod_api.update_talent_buff_template("wood_elf", "kerillian_maidenguard_max_ammo", {
	multiplier = 1.0, -- 0.4
})
mod_api.update_talent("we_maidenguard", 5, 3, {
    description = "kerillian_maidenguard_max_ammo_desc",
    description_values = {
        {
            value_type = "percent",
            value = 1.0,
        },
    },
})
--mod_api.insert_text("kerillian_maidenguard_max_ammo_desc", "Increased ammunition amount by 100%.")


