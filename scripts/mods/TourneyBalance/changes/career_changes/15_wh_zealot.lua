local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local shared_utils = require("scripts/mods/TourneyBalance/_api/shared_utils")
local is_local = shared_utils.is_local
local reduce_cooldown_on_owner = shared_utils.reduce_cooldown_on_owner

--[[
	$BEGIN_TB
		---
		## Zealot
		### Career Ability
		- Turn green hp into white hp on ult.

		### Passives
		**Fiery Faith**
		- Healing and temporary health gained beyond max health is stored as Overhealth for the whole team (up to 100).
		- Damage taken by Zealot or his allies is absorbed by Overhealth first. The remaining amount is shown as a buff icon for all players.
		- Damage absorbed by Overhealth still charges the hit player's career ability at full effectiveness, as if the health had been lost.

		**Ironheart**
		- Fixed invincibility not proccing on client.

		**Chasten (new)**
		- Increases attack speed by 5%.
		- Increases healing received by 30%.

		### Talents
		**Castigate**
		- Now grants 15% attack speed while below 20% health (from 10% below 50% health, 20% below 20% health).

		**Smite**
		- Added random crits.

		**Unbending Purpose**
		- Change to 20% melee power (from 5% power).

		**Holy Fortitude**
		- Reduced healing received to 10% per stack (from 15%).

		**Flagellant's Zeal**
		- Increased power buff duration to 15 seconds (from 5).
	$END_TB
]]

--[[

	Ultimate

]]
--Turn green hp into white hp on ult
mod:hook_safe(CareerAbilityWHZealot, "_run_ability", function(self)
    local unit = self._owner_unit
    local health_extension = ScriptUnit.extension(unit, "health_system")
    local perm_health = health_extension:current_permanent_health()
    health_extension:convert_to_temp(perm_health)
end)

--[[

    Passives

]]
-- Ironheart
-- Fix Zealot invulnerability desync/invincibility bug: this proc runs on both client and server, and the
-- server is always faster to evaluate the killing blow. The original code only added the buff locally via
-- buff_extension:add_buff, so the server could already consider the owner unkillable without ever telling
-- the client. The client must defer to whatever the server has already synced instead of re-evaluating the
-- killing blow itself, and the server must use mod_api.add_buff so the invulnerability buff actually replicates.
mod_api.insert_proc_function("victor_zealot_gain_invulnerability", function (owner_unit, buff, params)
    local status_extension = ScriptUnit.extension(owner_unit, "status_system")

    if not Managers.state.network.is_server and ALIVE[owner_unit] then
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

        return buff_extension:has_buff_type("victor_zealot_invulnerability_on_lethal_damage_taken")
    end

    if ALIVE[owner_unit] and not status_extension:is_knocked_down() then
        local health_extension = ScriptUnit.extension(owner_unit, "health_system")
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
        local already_unkillable = buff_extension:has_buff_perk("invulnerable") or buff_extension:has_buff_perk("ignore_death")

        if already_unkillable then
            return false
        end

        local damage = params[2]
        local current_health = health_extension:current_health()
        local killing_blow = current_health <= damage
        local template = buff.template
        local buff_to_add = template.buff_to_add

        if killing_blow then
            mod_api.add_buff(owner_unit, buff_to_add)

            return true
        end
    end
end)

--[[
    Fiery Faith - Overhealth
]]
-- THP Zealot gains beyond his max health (e.g. while at full health) is stored in a team-wide overhealth pool
-- (max 100). Damage taken by any hero is absorbed by the pool first. The pool is server-authoritative; its
-- rounded-up amount is synced to every peer to drive a local-only buff icon whose stack count shows the pool.
local OVERHEALTH_MAX = 100
local OVERHEALTH_PASSIVE_BUFF = "victor_zealot_passive_increased_damage" -- Fiery Faith parent buff
local OVERHEALTH_ICON_BUFF = "tb_victor_zealot_overhealth_icon"
local OVERHEALTH_NETWORK_ID = "tb_zealot_overhealth"
local NUMB_TO_PAIN_BUFF = "markus_knight_ability_invulnerability_buff"
local OVERHEALTH_ULT_REGEN_MODIFIER = 1 -- absorbed damage charges the ult like the health had been lost (Numb to Pain stays at 20%, 03_es_knight.lua)

local overhealth_pool = 0 -- server only
local overhealth_display = 0 -- every peer, math.ceil of the pool

mod_api.insert_talent_buff_template("witch_hunter", OVERHEALTH_ICON_BUFF, {
    icon = "victor_zealot_max_stamina_on_damage_taken",
})
mod_api.insert_text("career_passive_desc_wh_1a", "Gains 5% power for every 25 health missing. Max Stacks 6. Saltzpyre overheals up to 100 Overhealth. Damage taken by the team is absorbed by Overhealth first.")

local function set_overhealth_pool(amount)
    overhealth_pool = math.clamp(amount, 0, OVERHEALTH_MAX)

    local display = math.ceil(overhealth_pool)

    if display ~= overhealth_display then
        overhealth_display = display
        mod:network_send(OVERHEALTH_NETWORK_ID, "others", display)
    end
end

mod:network_register(OVERHEALTH_NETWORK_ID, function (sender_peer_id, display)
    overhealth_display = display or 0
end)

mod:add_game_state_changed_function(function ()
    overhealth_pool = 0
    overhealth_display = 0
end)

-- Gain: overflowing THP and permanent healing (same split as vanilla add_heal's two branches)
-- Registered through the add_heal dispatcher in TourneyBalance.lua.
mod:add_player_add_heal_wrapper(function (func, self, healer_unit, heal_amount, heal_source_name, heal_type)
    local game = self.game
    local game_object_id = self.health_game_object_id
    local status_extension = self.status_extension
    local buff_extension = ScriptUnit.has_extension(self.unit, "buff_system")

    if self.is_server and game and game_object_id and heal_amount > 0 and buff_extension and buff_extension:has_buff_type(OVERHEALTH_PASSIVE_BUFF)
        and not status_extension:is_knocked_down() then
        local current_health = GameSession.game_object_field(game, game_object_id, "current_health")
        local current_temporary_health = GameSession.game_object_field(game, game_object_id, "current_temporary_health")
        local max_health = GameSession.game_object_field(game, game_object_id, "max_health")
        local overflow

        if status_extension:is_permanent_heal(heal_type) then
            -- Permanent heals convert THP into permanent health first, so only healing past max permanent health is wasted
            overflow = math.clamp(current_health + heal_amount - max_health, 0, heal_amount)
        else
            overflow = math.clamp(current_health + current_temporary_health + heal_amount - max_health, 0, heal_amount)
        end

        if overflow > 0 then
            set_overhealth_pool(overhealth_pool + overflow)
        end
    end

    return func(self, healer_unit, heal_amount, heal_source_name, heal_type)
end)

-- Hit trading: each career's passive has its own "<career>_ability_cooldown_on_damage_taken" buff with its own
-- bonus, so look it up from the hit hero's career. Cached per career; bonus is read live so balance edits apply.
local CDR_ON_DAMAGE_TAKEN_FUNC = "reduce_activated_ability_cooldown_on_damage_taken"
local cdr_buff_by_career = {} -- career_name -> buff template name, or false if the career has none

local function get_cdr_on_damage_taken_bonus(unit)
    local career_extension = ScriptUnit.has_extension(unit, "career_system")
    local career_name = career_extension and career_extension:career_name()

    if not career_name then
        return nil
    end

    local buff_name = cdr_buff_by_career[career_name]

    if buff_name == nil then
        buff_name = false

        local career_settings = CareerSettings[career_name]
        local passive_buffs = career_settings and career_settings.passive_ability and career_settings.passive_ability.buffs

        for _, passive_buff_name in ipairs(passive_buffs or {}) do
            local template = BuffTemplates[passive_buff_name]
            local sub_buff = template and template.buffs and template.buffs[1]

            if sub_buff and sub_buff.buff_func == CDR_ON_DAMAGE_TAKEN_FUNC then
                buff_name = passive_buff_name
                break
            end
        end

        cdr_buff_by_career[career_name] = buff_name
    end

    return buff_name and BuffTemplates[buff_name].buffs[1].bonus
end

-- Absorb: applied after all other damage reductions. Registered through the dispatcher in TourneyBalance.lua.
-- apply_buffs_to_damage only runs with a non-zero pool on the server, so clients always fall through.
mod:add_apply_buffs_to_damage_wrapper(function (func, current_damage, attacked_unit, attacker_unit, damage_source, ...)
    local damage = func(current_damage, attacked_unit, attacker_unit, damage_source, ...)

    -- Self-inflicted damage (THP decay, life tap, overcharge) doesn't consume the pool
    if overhealth_pool <= 0 or damage <= 0 or attacker_unit == attacked_unit then
        return damage
    end

    local side = Managers.state.side.side_by_unit[attacked_unit]

    if not side or side:name() ~= "heroes" or not Managers.player:owner(attacked_unit) then
        return damage
    end

    local status_extension = ScriptUnit.has_extension(attacked_unit, "status_system")

    if not status_extension or status_extension:is_knocked_down() or status_extension:is_dead() then
        return damage
    end

    -- Don't waste the pool on hits that won't land (Numb to Pain's wrapper zeroes damage outside this one)
    local buff_extension = ScriptUnit.has_extension(attacked_unit, "buff_system")

    if buff_extension and (buff_extension:has_buff_perk("invulnerable") or buff_extension:has_buff_type(NUMB_TO_PAIN_BUFF)) then
        return damage
    end

    local absorbed = math.min(overhealth_pool, damage)

    set_overhealth_pool(overhealth_pool - absorbed)

    -- Absorbed damage still charges the hit hero's ult, at their own career's on-damage-taken rate
    if damage_source ~= "temporary_health_degen" then
        local cdr_bonus = get_cdr_on_damage_taken_bonus(attacked_unit)

        if cdr_bonus then
            reduce_cooldown_on_owner(attacked_unit, cdr_bonus * absorbed * OVERHEALTH_ULT_REGEN_MODIFIER)
        end
    end

    return damage - absorbed
end)

-- Icon: local-only buff on the local player's unit while the pool is non-empty (not network synced)
local icon_unit = nil
local icon_buff_id = nil

mod:add_update_function(function (dt)
    local local_player = Managers.player and Managers.player:local_player_safe(1)
    local unit = local_player and local_player.player_unit

    if unit ~= icon_unit then
        icon_unit = unit
        icon_buff_id = nil
    end

    if not unit or not Unit.alive(unit) then
        return
    end

    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

    if not buff_extension then
        return
    end

    if overhealth_display > 0 and not icon_buff_id then
        icon_buff_id = buff_extension:add_buff(OVERHEALTH_ICON_BUFF)
    elseif overhealth_display <= 0 and icon_buff_id then
        buff_extension:remove_buff(icon_buff_id, true)
        icon_buff_id = nil
    end
end)

-- Stack count text shows the overhealth amount instead of the number of buff instances (always 1)
mod:hook_safe(BuffUI, "_sync_buffs", function (self)
    local widget = self._buff_name_to_widget[OVERHEALTH_ICON_BUFF]

    if not widget then
        return
    end

    local content = widget.content

    content.stack_count = overhealth_display

    if content.tb_overhealth_shown ~= overhealth_display then
        content.tb_overhealth_shown = overhealth_display
        widget.element.dirty = true
        self._dirty = true
    end
end)

--[[
    Chasten - listed
]]
-- 5% attack speed (moved from Castigate)
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_chasten_attack_speed", {
    stat_buff = "attack_speed",
    multiplier = 0.05,
})
-- 30% healing received (moved from Holy Fortitude)
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_chasten_healing_received", {
    stat_buff = "healing_received",
    multiplier = 0.3,
})
mod_api.insert_career_passives("wh_1", {
    "tb_victor_zealot_chasten_attack_speed",
    "tb_victor_zealot_chasten_healing_received",
})
mod_api.insert_perk_text("tb_wh_1d", "Chasten", "Increases attack speed by 5% and healing received by 30%.")
mod_api.insert_career_perk_descriptions("wh_1", "tb_wh_1d")

--[[

	Talents

]]
--[[
    Castigate
]]
-- 15% attack speed below 20% health (single stack)
-- threshold_2 = 0 means health never drops below it, so the second stack is never added
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_attack_speed_on_health_percent", {
    threshold_1 = 0.2, -- 0.5
    threshold_2 = 0, -- 0.2
})
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_attack_speed_on_health_percent_buff", {
    multiplier = 0.15 -- 0.1
})
mod_api.update_talent("wh_zealot", 2, 1, {
    description = "zealot_castigate_desc",
    description_values = {},
})
mod_api.insert_text("zealot_castigate_desc", "Increases attack speed by 15.0% while below 20.0% health.")

--[[
    Smite
]]
-- Added in random crits: clears the vanilla "no_random_crits" talent perk
-- talent_settings_victor.lua:1453
Talents.witch_hunter[7].perks = nil
-- Same fix as Helborg's Tutelage
-- Only consume the stack on a critical hit, so cleave/dual-weapon follow-up hits don't eat it
mod_api.insert_proc_function("tb_remove_crit_count_buff_on_crit_hit_smite", function (owner_unit, buff, params)
    local is_critical = params[6]

    return is_critical and true or false
end)
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_crit_count_buff", {
    event = "on_hit", -- "on_critical_action"
    buff_func = "tb_remove_crit_count_buff_on_crit_hit_smite" -- "dummy_function"
})
mod_api.insert_text("victor_zealot_crit_count_desc", "Every 5 hits grant a guaranteed critical strike. Critical strikes can still occur randomly.")
-- (FIX) Clients get 2 stack counts per hit
local add_buff_on_first_target_hit = ProcFunctions.add_buff_on_first_target_hit
mod_api.insert_proc_function("tb_add_buff_on_first_target_hit_smite", function (owner_unit, buff, params)
    if is_local(owner_unit) then
        add_buff_on_first_target_hit(owner_unit, buff, params)
    end
end)
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_crit_count", {
    buff_func = "tb_add_buff_on_first_target_hit_smite" --"add_buff_on_first_target_hit"
})

--[[
    Unbending Purpose
]]
-- Now grants 20% melee power.
mod_api.insert_talent_buff_template("witch_hunter", "victor_zealot_power", {
	stat_buff = "power_level_melee", -- power_level
	multiplier = 0.2 -- 0.05
})
mod_api.update_talent("wh_zealot", 2, 3, {
    description = "zealot_unbending_purpose_desc",
    description_values = {},
})
mod_api.insert_text("zealot_unbending_purpose_desc", "Increases melee power by 20.0%.")

--[[
    Holy Fortitude
]]
-- 10% healing received per stack
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_passive_healing_received_buff", {
    multiplier = 0.1 -- 0.15
})
mod_api.update_talent("wh_zealot", 4, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.1, -- 0.15
        },
    },
})

--[[
    Flagellant's Zeal
]]
-- Power buff lasts 15 seconds
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_activated_ability_power_on_hit_buff", {
    duration = 15 -- 5
})
mod_api.update_talent("wh_zealot", 6, 1, {
    description_values = {
        {
            value_type = "percent",
            value = 0.02,
        },
        {
            value = 15, -- 5
        },
        {
            value = 10,
        },
    },
})


