local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local shared_utils = require("scripts/mods/TourneyBalance/_api/shared_utils")
local is_local = shared_utils.is_local
local reduce_cooldown_on_owner = shared_utils.reduce_cooldown_on_owner
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	$BEGIN_TB
		---
		## Zealot
		### Career Ability
		- Turn green hp into white hp on ult.

		### Passives
		**Fiery Faith**
		- Fiery Faith stacks are doubled while on the last life (up to 12). This also applies to Castigate, Crusade, Holy Fortitude and Armour of Faith.
		- Damage taken by Zealot converts into Overhealth for his allies (max 100).
		- Damage taken by his allies is absorbed by Overhealth first.
        - Can hit trade with it.

		**Ironheart**
		- Fixed invincibility not proccing on client.

		**Chasten (new)**
		- Increases attack speed by 10%.
		- Increases healing received by 30%.

		### Talents
		**Castigate**
		- Now grants 1.25% attack speed per Fiery Faith stack (from 10% below 50% health, 20% below 20% health).

		**Smite**
		- Added random crits.

		**Unbending Purpose**
		- Change to 20% melee power (from 5% power).

		**Holy Fortitude**
		- Reduced healing received to 10% per stack (from 15%).

		**Crusade**
		- Each stack also grants 2.5% attack speed.

		**Devotion**
		- Now removes all movement penalties like Waywatcher's Fervent Huntress (from only no slowdown when hit).
		- Grants immunity to knockback from ranged projectiles and Warpfire.

		**Redemption through Blood**
		- Additionally increases melee damage by 5% for every missing half stamina shield.

		**Calloused Withou and Within**
		- Additionally decreases Heart of Iron's cooldown to 60 seconds.

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
-- Talent row 5 col 3 swaps in a longer invulnerability whose expiry starts a shorter cooldown (see Talents below)
local IRONHEART_INVULNERABILITY_BUFF = "victor_zealot_invulnerability_on_lethal_damage_taken"
local IRONHEART_TALENT_INVULNERABILITY_BUFF = "tb_victor_zealot_invulnerability_on_lethal_damage_taken_talent"
local IRONHEART_TALENT = "victor_zealot_reduced_damage_taken"

-- Fix Zealot invulnerability desync/invincibility bug: this proc runs on both client and server, and the
-- server is always faster to evaluate the killing blow. The original code only added the buff locally via
-- buff_extension:add_buff, so the server could already consider the owner unkillable without ever telling
-- the client. The client must defer to whatever the server has already synced instead of re-evaluating the
-- killing blow itself, and the server must use mod_api.add_buff so the invulnerability buff actually replicates.
mod_api.insert_proc_function("victor_zealot_gain_invulnerability", function (owner_unit, buff, params)
    local status_extension = ScriptUnit.extension(owner_unit, "status_system")

    if not Managers.state.network.is_server and ALIVE[owner_unit] then
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

        return buff_extension:has_buff_type(IRONHEART_INVULNERABILITY_BUFF) or buff_extension:has_buff_type(IRONHEART_TALENT_INVULNERABILITY_BUFF)
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
        local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

        if talent_extension and talent_extension:has_talent(IRONHEART_TALENT) then
            buff_to_add = IRONHEART_TALENT_INVULNERABILITY_BUFF
        end

        if killing_blow then
            mod_api.add_buff(owner_unit, buff_to_add)

            return true
        end
    end
end)

--[[
    Fiery Faith - Overhealth
]]
-- Damage Zealot takes is stored in a team-wide overhealth pool (max 50). Damage taken by his teammates is
-- absorbed by the pool first; Zealot himself never draws from it. The pool is server-authoritative; its
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
-- Fiery Faith stacks and the talents stacking with them (Castigate, Crusade, Holy Fortitude, Armour of Faith):
-- vanilla's activate_buff_stacks_based_on_health_chunks (server-controlled stacks that replicate to clients), except
-- while Zealot is on his last life (the next knockdown kills him) the number of stacks and the stack cap are doubled.
-- Each stack buff's max_stacks must fit the doubled count; the parent's max_stacks still caps the normal count at 6.
local FIERY_FAITH_MAX_STACKS = 6
local FIERY_FAITH_LAST_LIFE_STACK_MULTIPLIER = 2
local FIERY_FAITH_DOUBLED_MAX_STACKS = FIERY_FAITH_MAX_STACKS * FIERY_FAITH_LAST_LIFE_STACK_MULTIPLIER

mod_api.insert_buff_function("tb_activate_fiery_faith_stacks", function (unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    local health_extension = ScriptUnit.extension(unit, "health_system")
    local buff_extension = ScriptUnit.extension(unit, "buff_system")
    local status_extension = ScriptUnit.extension(unit, "status_system")
    local buff_system = Managers.state.entity:system("buff_system")
    local template = buff.template
    local buff_to_add = template.buff_to_add
    local chunk_size = template.chunk_size
    local uncursed_max_health = health_extension:get_uncursed_max_health()
    local damage_taken = health_extension:get_damage_taken("uncursed_max_health")
    local max_stacks = math.min(math.floor(uncursed_max_health / chunk_size) - 1, template.max_stacks)
    local num_chunks = math.clamp(math.floor(damage_taken / chunk_size), 0, max_stacks)

    if status_extension:wounded_and_on_last_wound() then
        num_chunks = num_chunks * FIERY_FAITH_LAST_LIFE_STACK_MULTIPLIER
    end

    local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)
    local stack_ids = buff.stack_ids

    if not stack_ids then
        stack_ids = {}
        buff.stack_ids = stack_ids
    end

    for _ = num_buff_stacks + 1, num_chunks do
        stack_ids[#stack_ids + 1] = buff_system:add_buff(unit, buff_to_add, unit, true)
    end

    for _ = num_chunks + 1, num_buff_stacks do
        buff_system:remove_server_controlled_buff(unit, table.remove(stack_ids, 1))
    end
end)
-- Fiery Faith power stacks. Crusade, Holy Fortitude and Armour of Faith are switched over in the Talents section.
local function use_fiery_faith_stacks(parent_buff_name, stack_buff_name)
    mod_api.update_talent_buff_template("witch_hunter", parent_buff_name, {
        update_func = "tb_activate_fiery_faith_stacks", -- "activate_buff_stacks_based_on_health_chunks"
    })
    mod_api.update_talent_buff_template("witch_hunter", stack_buff_name, {
        max_stacks = FIERY_FAITH_DOUBLED_MAX_STACKS, -- 6
    })
end

use_fiery_faith_stacks("victor_zealot_passive_increased_damage", "victor_zealot_passive_damage")
mod_api.insert_text("career_passive_desc_wh_1a", "Gains 5% power for every 25 health missing. Max Stacks 6, doubled while on the last life. Saltzpyre's damage taken is converted into up to 100 Overhealth. Damage taken by allies is absorbed by Overhealth first.")

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

-- Gain and absorb: applied after all other damage reductions, so Zealot's gain is the damage he actually takes. Registered through the dispatcher in TourneyBalance.lua.
-- apply_buffs_to_damage only runs for players on the server.
mod:add_apply_buffs_to_damage_wrapper(function (func, current_damage, attacked_unit, attacker_unit, damage_source, ...)
    local damage = func(current_damage, attacked_unit, attacker_unit, damage_source, ...)

    -- Self-inflicted damage (THP decay, life tap, overcharge) neither fills nor consumes the pool
    if damage <= 0 or attacker_unit == attacked_unit then
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

    local buff_extension = ScriptUnit.has_extension(attacked_unit, "buff_system")

    if not buff_extension then
        return damage
    end

    -- Hits that won't land neither fill nor consume the pool (Numb to Pain's wrapper zeroes damage outside this one)
    if buff_extension:has_buff_perk("invulnerable") or buff_extension:has_buff_type(NUMB_TO_PAIN_BUFF) then
        return damage
    end

    -- Zealot converts the damage he takes into overhealth for his teammates
    if buff_extension:has_buff_type(OVERHEALTH_PASSIVE_BUFF) then
        set_overhealth_pool(overhealth_pool + damage)

        return damage
    end

    if overhealth_pool <= 0 then
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
-- 10% attack speed (moved from Castigate)
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_chasten_attack_speed", {
    stat_buff = "attack_speed",
    multiplier = 0.1, -- 0.05
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
mod_api.insert_perk_text("tb_wh_1d", "Chasten", "Increases attack speed by 10% and healing received by 30%.")
mod_api.insert_career_perk_descriptions("wh_1", "tb_wh_1d")

--[[

	Talents

]]
--[[
    Castigate
]]
-- 1.25% attack speed per Fiery Faith stack (from 10% below 50% health, 20% below 20% health). Same chunks and
-- last-life doubling as the Fiery Faith power stacks, so the count always matches them. Stacks are server-controlled,
-- so the talent's buffs live on the server.
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_castigate", {
    buff_to_add = "tb_victor_zealot_castigate_buff",
    chunk_size = 25,
    max_stacks = FIERY_FAITH_MAX_STACKS,
    update_func = "tb_activate_fiery_faith_stacks",
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_castigate_buff", {
    icon = "victor_zealot_attack_speed_on_health_percent",
    max_stacks = FIERY_FAITH_DOUBLED_MAX_STACKS,
    stat_buff = "attack_speed",
    multiplier = 0.0125,
})
mod_api.update_talent("wh_zealot", 2, 1, {
    buffer = "server",
    description = "zealot_castigate_desc",
    description_values = {},
    buffs = {
        "tb_victor_zealot_castigate",
    },
})
mod_api.insert_text("zealot_castigate_desc", "Increases attack speed by 1.25% for every stack of Fiery Faith.")

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
-- 10% healing received per stack, stacks doubled on the last life
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_passive_healing_received_buff", {
    multiplier = 0.1 -- 0.15
})
use_fiery_faith_stacks("victor_zealot_passive_healing_received", "victor_zealot_passive_healing_received_buff")
mod_api.update_talent("wh_zealot", 4, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.1, -- 0.15
        },
    },
})

--[[
    Crusade
]]
-- Each stack also grants 2.5% attack speed, stacks doubled on the last life. The second sub-buff needs its own name
-- so num_buff_type (counted by the first sub-buff's name) and max_stacks keep working per stack.
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_passive_move_speed", {
    update_func = "tb_activate_fiery_faith_stacks", -- "activate_buff_stacks_based_on_health_chunks"
})
mod_api.insert_talent_buff_template("witch_hunter", "victor_zealot_passive_move_speed_buff", {
    {
        apply_buff_func = "apply_movement_buff",
        icon = "victor_zealot_passive_move_speed",
        max_stacks = FIERY_FAITH_DOUBLED_MAX_STACKS, -- 6
        multiplier = 1.05,
        remove_buff_func = "remove_movement_buff",
        path_to_movement_setting_to_modify = {
            "move_speed",
        },
    },
    {
        name = "tb_victor_zealot_passive_move_speed_attack_speed",
        max_stacks = FIERY_FAITH_DOUBLED_MAX_STACKS,
        stat_buff = "attack_speed",
        multiplier = 0.025,
    },
})
mod_api.update_talent("wh_zealot", 4, 1, {
    description = "tb_victor_zealot_passive_move_speed_desc",
    description_values = {},
})
mod_api.insert_text("tb_victor_zealot_passive_move_speed_desc", "Increases movement speed by 5% and attack speed by 2.5% for every 25 health missing, up to 6 stacks, doubled while on the last life.")

--[[
    Armour of Faith
]]
-- Stacks doubled on the last life
use_fiery_faith_stacks("victor_zealot_passive_damage_taken", "victor_zealot_passive_damage_taken_buff")

--[[
    Devotion
]]
-- No movement penalties, like Waywatcher's Fervent Huntress
-- Also immune to knockback from Warpfire and projectiles, like Grail Knight after Blessed Blade
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_devotion_no_knockback", {
    max_stacks = 1,
    perks = {
        buff_perks.no_ranged_knockback,
    },
})
mod_api.update_talent("wh_zealot", 5, 1, {
    description = "tb_victor_zealot_move_speed_on_damage_taken_desc",
    description_values = {},
    buffs = {
        "victor_zealot_move_speed_on_damage_taken",
        "tb_fervent_huntress_no_movement_penalties",
        "tb_victor_zealot_devotion_no_knockback",
    },
})
mod_api.insert_text("tb_victor_zealot_move_speed_on_damage_taken_desc", "Taking damage increases movement speed by 30% for 2 seconds. Saltzpyre is no longer affected by movement penalties and immune to knockback from ranged projectiles and Warpfire.")

--[[
    Redeption through Blood
]]
-- 5% melee damage per missing stamina shield. Stamina only exists on the owner's machine, but melee damage is
-- calculated on the server, so the owner reports its missing shields to the server, which keeps that many
-- server-controlled stacks (replicated to every peer).
local MISSING_STAMINA_NETWORK_ID = "tb_zealot_missing_stamina"
local MISSING_STAMINA_DAMAGE_BUFF = "tb_victor_zealot_melee_damage_per_missing_stamina_buff"
local MISSING_STAMINA_MAX_STACKS = 10
local FATIGUE_POINTS_PER_SHIELD = 1 --2

local missing_stamina_stack_ids = setmetatable({}, { __mode = "k" }) -- server only, unit -> server buff ids

local function set_missing_stamina_stacks(unit, num_stacks)
    if not ALIVE[unit] then
        return
    end

    local buff_system = Managers.state.entity:system("buff_system")
    local stack_ids = missing_stamina_stack_ids[unit]

    if not stack_ids then
        stack_ids = {}
        missing_stamina_stack_ids[unit] = stack_ids
    end

    num_stacks = math.clamp(num_stacks, 0, MISSING_STAMINA_MAX_STACKS)

    while #stack_ids < num_stacks do
        local server_buff_id = buff_system:add_buff(unit, MISSING_STAMINA_DAMAGE_BUFF, unit, true)

        if not server_buff_id then
            return
        end

        stack_ids[#stack_ids + 1] = server_buff_id
    end

    while #stack_ids > num_stacks do
        buff_system:remove_server_controlled_buff(unit, table.remove(stack_ids))
    end
end

mod:network_register(MISSING_STAMINA_NETWORK_ID, function (sender_peer_id, num_stacks)
    if not Managers.state.network or not Managers.state.network.is_server then
        return
    end

    local player = Managers.player:player_from_peer_id(sender_peer_id)
    local unit = player and player.player_unit

    if unit then
        set_missing_stamina_stacks(unit, num_stacks or 0)
    end
end)

-- Runs wherever the talent buff lives (the owner's machine, the server for bots)
mod_api.insert_buff_function("tb_victor_zealot_update_missing_stamina", function (unit, buff, params)
    local status_extension = ScriptUnit.has_extension(unit, "status_system")
    local network_manager = Managers.state.network

    if not status_extension or not network_manager then
        return
    end

    local used_fatigue_points = status_extension:current_fatigue_points()
    local missing_shields = math.floor(used_fatigue_points / FATIGUE_POINTS_PER_SHIELD)

    if missing_shields == buff.tb_missing_shields then
        return
    end

    buff.tb_missing_shields = missing_shields

    if network_manager.is_server then
        set_missing_stamina_stacks(unit, missing_shields)
    else
        mod:network_send(MISSING_STAMINA_NETWORK_ID, network_manager.network_transmit.server_peer_id, missing_shields)
    end
end)
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_melee_damage_per_missing_stamina", {
    update_func = "tb_victor_zealot_update_missing_stamina",
})
mod_api.insert_talent_buff_template("witch_hunter", MISSING_STAMINA_DAMAGE_BUFF, {
    max_stacks = MISSING_STAMINA_MAX_STACKS,
    stat_buff = "increased_weapon_damage_melee",
    multiplier = 0.05,
})
mod_api.update_talent("wh_zealot", 5, 2, {
    description = "tb_victor_zealot_max_stamina_on_damage_taken_desc",
    description_values = {},
    buffs = {
        "victor_zealot_max_stamina_on_damage_taken",
        "tb_victor_zealot_melee_damage_per_missing_stamina",
    },
})
mod_api.insert_text("tb_victor_zealot_max_stamina_on_damage_taken_desc", "Taking damage from an enemy fully restores stamina. Increases melee damage by 5% for every missing half stamina shield.")

--[[
    Calloused Without and Within
]]
-- Heart of Iron adjusted
local IRONHEART_TALENT_COOLDOWN_BUFF = "tb_victor_zealot_invulnerability_cooldown_talent"

mod_api.insert_talent_buff_template("witch_hunter", IRONHEART_TALENT_COOLDOWN_BUFF, {
    buff_to_add = "victor_zealot_gain_invulnerability_on_lethal_damage_taken",
    duration = 60,
    duration_end_func = "add_buff_local",
    icon = "victor_zealot_passive_invulnerability",
    is_cooldown = true,
    max_stacks = 1,
    refresh_durations = true,
})
mod_api.insert_buff_function("tb_add_victor_zealot_invulnerability_cooldown_talent", function (unit, buff, params)
    if Unit.alive(unit) then
        ScriptUnit.extension(unit, "buff_system"):add_buff(IRONHEART_TALENT_COOLDOWN_BUFF)
    end
end)
mod_api.insert_talent_buff_template("witch_hunter", IRONHEART_TALENT_INVULNERABILITY_BUFF, {
    icon = "victor_zealot_passive_invulnerability",
    duration = 5,
    max_stacks = 1,
    priority_buff = true,
    remove_buff_func = "tb_add_victor_zealot_invulnerability_cooldown_talent",
    stat_buff = "damage_taken",
    multiplier = -1,
    perks = {
        buff_perks.ignore_death,
    },
}, {
    activation_effect = "fx/screenspace_potion_03",
    activation_sound = "hud_gameplay_stance_tank_activate",
    deactivation_sound = "hud_gameplay_stance_deactivate",
})
mod_api.update_talent("wh_zealot", 5, 3, {
    description = "tb_victor_zealot_reduced_damage_taken_desc",
    description_values = {},
})
mod_api.insert_text("tb_victor_zealot_reduced_damage_taken_desc", "Reduces damage taken by 10%. Heart of Iron's cooldown is reduced to 60 seconds.")

--[[
    Flagellant's Zeal
]]
-- Power buff lasts 15 seconds
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_activated_ability_power_on_hit_buff", {
    duration = 10 -- 5
})
mod_api.update_talent("wh_zealot", 6, 1, {
    description_values = {
        {
            value_type = "percent",
            value = 0.02,
        },
        {
            value = 10, -- 5
        },
        {
            value = 10,
        },
    },
})


