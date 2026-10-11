local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local shared_utils = require("scripts/mods/TourneyBalance/_api/shared_utils")
local is_local = shared_utils.is_local
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--[[
	$BEGIN_TB
		---
		## Zealot
		### Career Ability
		- Turn green hp into white hp on ult.

		### Passives
		**Ironheart**
		- Fixed invincibility not proccing on client.

		**Chasten (new)**
		- Increases healing received by 30%.

		### Talents
		**Smite**
		- Added random crits.
		- Now grants a guaranteed critical strike every 4 hits (from 5).

		**Unbending Purpose**
		- Increased power to 10% (from 5%).
		- Additionally increases melee power by 10%.

		**Crusade**
		- Additionally grants a chance to avoid damage from enemy hits equal to the movement speed bonus (5% per stack, up to 30%).
		- Devotion's 30% movement speed after taking damage increases this chance by another 30% while active.
		- Movement speed trinkets (5%) and speed potions (50%) also add to this chance, up to 100%.

		**Holy Fortitude**
		- Reduced healing received to 10% per stack (from 15%).

		**Devotion**
		- Now removes all movement penalties (melee attacks, slowing debuffs) instead of only the slowdown when hit. Ranged weapons still slow him down.
		- Grants immunity to knockback from ranged projectiles and Warpfire.

		**Redemption through Blood**
		- Additionally reduces Heart of Iron's cooldown by 1 second for every half stamina shield restored.
		- Additionally increases melee damage by 5% for every half stamina shield restored, until stamina is next restored by this talent.

		**Calloused Without and Within**
		- Additionally sets Heart of Iron's cooldown to a fixed 100 seconds (from 120).
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
local IRONHEART_INVULNERABILITY_BUFF = "victor_zealot_invulnerability_on_lethal_damage_taken"
-- Added on every peer when the invulnerability expires, the server's copy is the one gating the next proc
-- (shortened by Redemption through Blood, fixed duration with Calloused Without and Within, see Talents below)
local IRONHEART_COOLDOWN_BUFF = "victor_zealot_invulnerability_cooldown"

-- Fix Zealot invulnerability desync/invincibility bug: this proc runs on both client and server, and the
-- server is always faster to evaluate the killing blow. The original code only added the buff locally via
-- buff_extension:add_buff, so the server could already consider the owner unkillable without ever telling
-- the client. The client must defer to whatever the server has already synced instead of re-evaluating the
-- killing blow itself, and the server must use mod_api.add_buff so the invulnerability buff actually replicates.
mod_api.insert_proc_function("victor_zealot_gain_invulnerability", function (owner_unit, buff, params)
    local status_extension = ScriptUnit.extension(owner_unit, "status_system")

    if not Managers.state.network.is_server and ALIVE[owner_unit] then
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

        return buff_extension:has_buff_type(IRONHEART_INVULNERABILITY_BUFF)
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

        if killing_blow then
            mod_api.add_buff(owner_unit, buff.template.buff_to_add)

            return true
        end
    end
end)

--[[
    Chasten - listed
]]
-- 30% healing received (moved from Holy Fortitude)
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_chasten_healing_received", {
    stat_buff = "healing_received",
    multiplier = 0.3,
})
mod_api.insert_career_passives("wh_1", {
    "tb_victor_zealot_chasten_healing_received",
})
mod_api.insert_perk_text("tb_wh_1d", "Chasten", "Increases healing received by 30%.")
mod_api.insert_career_perk_descriptions("wh_1", "tb_wh_1d")

--[[

	Talents

]]
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
-- Every 4 hits grant a guaranteed crit: the counter grants the crit buff and resets when it reaches max stacks
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_counter_buff", {
    max_stacks = 4, -- 5
})
mod_api.insert_text("victor_zealot_crit_count_desc", "Every 4 hits grant a guaranteed critical strike. Critical strikes can still occur randomly.")
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
-- Vanilla 10% power, plus 10% melee power. Damage is calculated on the server, where this talent's buffs live.
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_power", {
    multiplier = 0.1, -- 0.05
})
mod_api.insert_talent_buff_template("witch_hunter", "tb_victor_zealot_melee_power", {
    max_stacks = 1,
    stat_buff = "power_level_melee",
    multiplier = 0.1,
})
mod_api.update_talent("wh_zealot", 2, 3, {
    description = "zealot_unbending_purpose_desc",
    description_values = {},
    buffs = {
        "victor_zealot_power",
        "tb_victor_zealot_melee_power",
    },
})
mod_api.insert_text("zealot_unbending_purpose_desc", "Increases power by 10.0% and melee power by 10.0%.")

--[[
    Crusade
]]
-- Chance to avoid an enemy hit equal to the movement speed bonus from Crusade (5% per stack), Devotion (30%), movement speed trinket (5%), speed potion (50%), so 100% is reachable when stacked.
local CRUSADE_TALENT = "victor_zealot_passive_move_speed"
local CRUSADE_MOVE_SPEED_BUFF = "victor_zealot_passive_move_speed_buff"
local CRUSADE_AVOID_CHANCE_PER_STACK = 0.05
local DEVOTION_MOVE_SPEED_BUFF = "victor_zealot_move_speed_on_damage_taken_buff"
local DEVOTION_AVOID_CHANCE = 0.3
local TRINKET_MOVE_SPEED_BUFF = "properties_movespeed"
local TRINKET_AVOID_CHANCE = 0.05
local POTION_MOVE_SPEED_BUFF = "potion_movement_buff" -- shared by every speed potion variant
local POTION_AVOID_CHANCE = 0.5
local CRUSADE_TRINKET_NETWORK_ID = "tb_zealot_crusade_movespeed_trinket"
local CRUSADE_TRINKET_CHECK_INTERVAL = 1

local crusade_trinket_by_peer = {} -- server only, peer id -> whether that remote player has a movement speed trinket

mod:network_register(CRUSADE_TRINKET_NETWORK_ID, function (sender_peer_id, has_trinket)
    if Managers.state.network and Managers.state.network.is_server then
        crusade_trinket_by_peer[sender_peer_id] = has_trinket or nil
    end
end)

-- Remote owner: reports its trinket whenever it changes, and again on every new unit
local crusade_trinket_unit = nil
local crusade_trinket_sent = nil
local crusade_trinket_timer = 0

mod:add_update_function(function (dt)
    crusade_trinket_timer = crusade_trinket_timer + dt

    if crusade_trinket_timer < CRUSADE_TRINKET_CHECK_INTERVAL then
        return
    end

    crusade_trinket_timer = 0

    local network_manager = Managers.state.network

    if not network_manager or network_manager.is_server then
        return
    end

    local local_player = Managers.player and Managers.player:local_player_safe(1)
    local unit = local_player and local_player.player_unit

    if not ALIVE[unit] then
        return
    end

    local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

    if not talent_extension or not buff_extension or not talent_extension:has_talent(CRUSADE_TALENT) then
        return
    end

    local has_trinket = buff_extension:has_buff_type(TRINKET_MOVE_SPEED_BUFF)

    if unit ~= crusade_trinket_unit or has_trinket ~= crusade_trinket_sent then
        crusade_trinket_unit = unit
        crusade_trinket_sent = has_trinket
        mod:network_send(CRUSADE_TRINKET_NETWORK_ID, network_manager.network_transmit.server_peer_id, has_trinket)
    end
end)

local function has_movespeed_trinket(unit, buff_extension)
    local player = Managers.player:owner(unit)

    if player and player.remote then
        return crusade_trinket_by_peer[player.peer_id]
    end

    return buff_extension:has_buff_type(TRINKET_MOVE_SPEED_BUFF)
end

local function crusade_avoid_chance(unit)
    local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

    if not talent_extension or not buff_extension or not talent_extension:has_talent(CRUSADE_TALENT) then
        return 0
    end

    local chance = buff_extension:num_buff_type(CRUSADE_MOVE_SPEED_BUFF) * CRUSADE_AVOID_CHANCE_PER_STACK

    if buff_extension:has_buff_type(DEVOTION_MOVE_SPEED_BUFF) then
        chance = chance + DEVOTION_AVOID_CHANCE
    end

    if buff_extension:has_buff_type(POTION_MOVE_SPEED_BUFF) then
        chance = chance + POTION_AVOID_CHANCE
    end

    if has_movespeed_trinket(unit, buff_extension) then
        chance = chance + TRINKET_AVOID_CHANCE
    end

    return chance
end

mod:add_apply_buffs_to_damage_wrapper(function (func, current_damage, attacked_unit, attacker_unit, damage_source, victim_units, damage_type, ...)
    -- Only enemy hits, level kill volumes and forced deaths still go through
    if current_damage > 0 and damage_type ~= "forced" and damage_source ~= "volume_insta_kill" and attacker_unit ~= attacked_unit then
        local side_manager = Managers.state.side
        local attacked_side = side_manager.side_by_unit[attacked_unit]
        local attacker_side = side_manager.side_by_unit[attacker_unit]

        if attacker_side and attacker_side ~= attacked_side and math.random() < crusade_avoid_chance(attacked_unit) then
            current_damage = 0
        end
    end

    return func(current_damage, attacked_unit, attacker_unit, damage_source, victim_units, damage_type, ...)
end)
mod_api.update_talent("wh_zealot", 4, 1, {
    description = "tb_victor_zealot_passive_move_speed_desc",
    description_values = {},
})
mod_api.insert_text("tb_victor_zealot_passive_move_speed_desc", "Each stack of Fiery Faith also increases movement speed by 5.0%. Chance to avoid damage based on movement speed bonus.")

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
    Devotion
]]
-- No movement penalties (melee attacks, slowing debuffs), ranged weapon actions still slow
-- Also immune to knockback from Warpfire and projectiles, like Grail Knight after Blessed Blade
local DEVOTION_NO_MOVEMENT_PENALTIES_BUFF = "tb_victor_zealot_devotion_no_movement_penalties"

mod_api.insert_talent_buff_template("witch_hunter", DEVOTION_NO_MOVEMENT_PENALTIES_BUFF, {
    max_stacks = 1,
})
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
        DEVOTION_NO_MOVEMENT_PENALTIES_BUFF,
        "tb_victor_zealot_devotion_no_knockback",
    },
})

-- Attacking, aiming and slowing debuffs (bile, plague, fire, etc.) all slow the player through buffs that scale the
-- movement settings. Those buffs are simply never added while Saltzpyre has Devotion, except for ranged weapon actions
-- (below). Weapon actions also use them to speed the player up (movetech, external multiplier above 1), those are kept.
local DEVOTION_MOVEMENT_SPEED_SETTINGS = {
    move_speed = true,
    crouch_move_speed = true,
    walk_move_speed = true,
}

local function tb_devotion_is_movement_penalty_buff(buff_name, template)
    -- Never gate these: they undo every lerped slowdown, so blocking them leaves the player stuck slowed
    if not template.buffs or string.find(buff_name, "^planted_return_to_normal") then
        return false
    end

    for _, sub_buff in ipairs(template.buffs) do
        local path = sub_buff.path_to_movement_setting_to_modify
        local multiplier = sub_buff.multiplier

        if path and DEVOTION_MOVEMENT_SPEED_SETTINGS[path[1]] then
            -- actions (melee swings, aiming) and debuffs use the lerped variant, the multiplier of actions is passed in externally
            local is_lerp_penalty = sub_buff.apply_buff_func == "apply_action_lerp_movement_buff" and not sub_buff.bonus and (type(multiplier) ~= "number" or multiplier <= 1)
            local is_static_penalty = sub_buff.apply_buff_func == "apply_movement_buff" and type(multiplier) == "number" and multiplier < 1

            if is_lerp_penalty or is_static_penalty then
                return true
            end
        end
    end

    return false
end

-- Ranged weapon actions keep their slowdown. Weapon action buffs are only ever added through
-- ActionUtils.update_action_buff_data, so it marks which unit is adding them.
local action_buff_owner_unit = nil

mod:hook(ActionUtils, "update_action_buff_data", function (func, action_buff_data, buff_data, owner_unit, t)
    action_buff_owner_unit = owner_unit
    func(action_buff_data, buff_data, owner_unit, t)
    action_buff_owner_unit = nil
end)

local function tb_devotion_is_ranged_action_buff(unit)
    if unit ~= action_buff_owner_unit then
        return false
    end

    local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")

    return inventory_extension and inventory_extension:get_wielded_slot_name() == "slot_ranged"
end

local function tb_devotion_allows_buff(unit, template, params)
    if mod:is_action_movement_speed_up(params) or tb_devotion_is_ranged_action_buff(unit) then
        return true
    end

    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

    return not (buff_extension and buff_extension:has_buff_type(DEVOTION_NO_MOVEMENT_PENALTIES_BUFF))
end

-- Penalty buffs are gated once through apply_condition, so the check only runs when one of them is added.
-- Done after all mods load so templates added by later files are covered too.
mod:add_all_mods_loaded_function(function ()
    local penalty_buff_names = {}

    for buff_name, template in pairs(BuffTemplates) do
        if tb_devotion_is_movement_penalty_buff(buff_name, template) then
            penalty_buff_names[#penalty_buff_names + 1] = buff_name
        end
    end

    for _, buff_name in ipairs(penalty_buff_names) do
        mod:add_buff_apply_condition(buff_name, tb_devotion_allows_buff)
    end
end)
mod_api.insert_text("tb_victor_zealot_move_speed_on_damage_taken_desc", "Taking damage increases movement speed by 30% for 2 seconds. No longer affected by movement penalties, melee weapon slowdown, and knockback from ranged projectiles and Warpfire.")

--[[
    Redemption through Blood
]]
-- Every half stamina shield (one fatigue point) restored reduces Heart of Iron's cooldown by 1 second, and grants 5%
-- melee damage until the next time stamina is restored this way (a proc restoring nothing keeps the current bonus).
-- Stamina only exists on the owner's machine, which runs this proc, but the server's cooldown is the one gating Heart
-- of Iron and melee damage is calculated on the server, so the owner reports the restored points to the server.
-- The owner shortens its own cooldown copy (the icon) and shows the melee damage bonus on a local-only icon.
local REDEMPTION_COOLDOWN_REDUCTION_PER_POINT = 1
local REDEMPTION_MELEE_DAMAGE_PER_POINT = 0.05
local REDEMPTION_NETWORK_ID = "tb_zealot_redemption_restored_stamina"
local REDEMPTION_MELEE_DAMAGE_BUFF = "tb_victor_zealot_redemption_melee_damage" -- server only, multiplier set on add
local REDEMPTION_ICON_BUFF = "tb_victor_zealot_redemption_melee_damage_icon" -- owner only, stack count = damage %

local redemption_melee_damage_buff_ids = setmetatable({}, { __mode = "k" }) -- server only, unit -> buff id

mod_api.insert_talent_buff_template("witch_hunter", REDEMPTION_MELEE_DAMAGE_BUFF, {
    max_stacks = 1,
    stat_buff = "increased_weapon_damage_melee",
    multiplier = 0,
})
mod_api.insert_talent_buff_template("witch_hunter", REDEMPTION_ICON_BUFF, {
    max_stacks = 1,
    icon = "victor_zealot_max_stamina_on_damage_taken",
})

local function reduce_ironheart_cooldown(unit, amount)
    local buff_extension = ALIVE[unit] and ScriptUnit.has_extension(unit, "buff_system")
    local cooldown_buff = buff_extension and buff_extension:get_non_stacking_buff(IRONHEART_COOLDOWN_BUFF)

    if cooldown_buff and cooldown_buff.duration then
        cooldown_buff.duration = math.max(cooldown_buff.duration - amount, 0)
    end
end

-- Server: replaces the previous melee damage bonus with one sized to the latest restore
local function set_redemption_melee_damage(unit, restored_points)
    local buff_extension = ALIVE[unit] and ScriptUnit.has_extension(unit, "buff_system")

    if not buff_extension then
        return
    end

    buff_extension:remove_buff(redemption_melee_damage_buff_ids[unit])
    redemption_melee_damage_buff_ids[unit] = buff_extension:add_buff(REDEMPTION_MELEE_DAMAGE_BUFF, {
        external_optional_multiplier = restored_points * REDEMPTION_MELEE_DAMAGE_PER_POINT,
    })
end

-- Owner: the icon's stack count shows the current melee damage bonus in %
local function set_redemption_icon(unit, restored_points)
    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

    if not buff_extension then
        return
    end

    local icon_buff = buff_extension:get_non_stacking_buff(REDEMPTION_ICON_BUFF)

    if not icon_buff then
        buff_extension:add_buff(REDEMPTION_ICON_BUFF)
        icon_buff = buff_extension:get_non_stacking_buff(REDEMPTION_ICON_BUFF)
    end

    if icon_buff then
        icon_buff.tb_redemption_damage_percent = math.round(restored_points * REDEMPTION_MELEE_DAMAGE_PER_POINT * 100)
    end
end

mod:hook_safe(BuffUI, "_add_buff", function (self, buff)
    local damage_percent = buff.tb_redemption_damage_percent

    if damage_percent then
        local widget = self._buff_name_to_widget[REDEMPTION_ICON_BUFF]

        if widget then
            widget.content.stack_count = damage_percent
        end
    end
end)

mod:network_register(REDEMPTION_NETWORK_ID, function (sender_peer_id, restored_points)
    if not Managers.state.network or not Managers.state.network.is_server then
        return
    end

    local player = Managers.player:player_from_peer_id(sender_peer_id)
    local unit = player and player.player_unit

    if unit then
        reduce_ironheart_cooldown(unit, restored_points * REDEMPTION_COOLDOWN_REDUCTION_PER_POINT)
        set_redemption_melee_damage(unit, restored_points)
    end
end)

local restore_stamina_on_enemy_damage_taken = ProcFunctions.restore_stamina_on_enemy_damage_taken
mod_api.insert_proc_function("tb_restore_stamina_on_enemy_damage_taken_redemption", function (owner_unit, buff, params)
    local status_extension = ScriptUnit.has_extension(owner_unit, "status_system")

    if not status_extension or not is_local(owner_unit) then
        return restore_stamina_on_enemy_damage_taken(owner_unit, buff, params)
    end

    local fatigue_points = status_extension:current_fatigue_points()

    restore_stamina_on_enemy_damage_taken(owner_unit, buff, params)

    local restored_points = fatigue_points - status_extension:current_fatigue_points()

    if restored_points <= 0 then
        return
    end

    local network_manager = Managers.state.network

    reduce_ironheart_cooldown(owner_unit, restored_points * REDEMPTION_COOLDOWN_REDUCTION_PER_POINT)
    set_redemption_icon(owner_unit, restored_points)

    if not network_manager then
        return
    end

    if network_manager.is_server then
        set_redemption_melee_damage(owner_unit, restored_points)
    else
        mod:network_send(REDEMPTION_NETWORK_ID, network_manager.network_transmit.server_peer_id, restored_points)
    end
end)
mod_api.update_talent_buff_template("witch_hunter", "victor_zealot_max_stamina_on_damage_taken", {
    buff_func = "tb_restore_stamina_on_enemy_damage_taken_redemption", -- "restore_stamina_on_enemy_damage_taken"
})
mod_api.update_talent("wh_zealot", 5, 2, {
    description = "tb_victor_zealot_max_stamina_on_damage_taken_desc",
})
mod_api.insert_text("tb_victor_zealot_max_stamina_on_damage_taken_desc", "Taking damage fully restores stamina. Every half stamina shield restored this this way reduces Heart of Iron's cooldown by 1 second and grants 5% melee damage bonus.")

--[[
    Calloused Without and Within
]]
-- Heart of Iron's cooldown is a fixed 100 seconds (from 120). Checked through the talent itself instead of a talent
-- buff, since the cooldown buff is added on every peer and the talent's buffs only live on the server.
local CALLOUSED_TALENT = "victor_zealot_reduced_damage_taken"
local CALLOUSED_IRONHEART_COOLDOWN = 100

mod_api.update_talent_buff_template("witch_hunter", IRONHEART_COOLDOWN_BUFF, {
    duration_modifier_func = function (unit, sub_buff_template, duration)
        local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

        if talent_extension and talent_extension:has_talent(CALLOUSED_TALENT) then
            return CALLOUSED_IRONHEART_COOLDOWN
        end

        return duration
    end,
})
mod_api.update_talent("wh_zealot", 5, 3, {
    description = "tb_victor_zealot_reduced_damage_taken_desc",
    description_values = {},
})
mod_api.insert_text("tb_victor_zealot_reduced_damage_taken_desc", "Reduces damage taken by 10% and Heart of Iron's cooldown to 100 seconds.")
