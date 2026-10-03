local mod = get_mod("TourneyBalance")

NewDamageProfileTemplates = NewDamageProfileTemplates or {}

--- Main update hook
-- `mod.update` is a single field that VMF calls every frame. Only one file can assign it directly.
-- Any feature needing per-frame tick should register through `mod:add_update_function(fn)` instead
-- of assigning `mod.update` itself, so multiple features can coexist.
local _update_functions = {}
function mod.add_update_function(self, func)
    _update_functions[#_update_functions + 1] = func
end
mod.update = function (dt)
    for i = 1, #_update_functions do
        _update_functions[i](dt)
    end
end

--- Settings-changed hook
-- Same single-field-collision problem as `mod.update` above: VMF calls `mod.on_setting_changed`
-- directly, so only one file can assign it directly, i.e. whichever file's  `dofile` runs last
-- silently wins. Register any features through `mod:add_setting_changed_function(fn)` instead
-- of assigning `mod.on_setting_changed` itself, so multiple features can coexist.
local _setting_changed_functions = {}
function mod.add_setting_changed_function(self, func)
    _setting_changed_functions[#_setting_changed_functions + 1] = func
end
mod.on_setting_changed = function (...)
    for i = 1, #_setting_changed_functions do
        _setting_changed_functions[i](...)
    end
end

--- IngameHud per-frame hook
-- Same problem again, but for an engine hook rather than a single mod field: mod_checker.lua and
-- 13_wh_captain.lua each used to call mod:hook_safe(IngameHud, "update", ...) independently, and
-- having this mod hook the exact same (class, method) more than once meant only one of them
-- actually ran. Register through mod:add_ingame_hud_update_function(fn) instead of calling
-- mod:hook_safe(IngameHud, "update", ...) directly, so this mod only ever installs one such hook.
local _ingame_hud_update_functions = {}
function mod.add_ingame_hud_update_function(self, func)
    _ingame_hud_update_functions[#_ingame_hud_update_functions + 1] = func
end
mod:hook_safe(IngameHud, "update", function (self)
    for i = 1, #_ingame_hud_update_functions do
        _ingame_hud_update_functions[i](self)
    end
end)

--- All-mods-loaded hook
-- Same single-field-collision problem as `mod.update`/`mod.on_setting_changed` above. This one is
-- also the right place to do cross-mod setup (e.g. get_mod("SomeOtherMod")): calling get_mod at a
-- file's own top-level load time is NOT safe, since VMF's mod load order between different mods is
-- not guaranteed - a `get_mod` there can silently return nil and get cached in a local that's never
-- refreshed, if the other mod hasn't loaded yet. By the time on_all_mods_loaded fires, every mod is
-- guaranteed loaded regardless of order. Register through mod:add_all_mods_loaded_function(fn)
-- instead of assigning mod.on_all_mods_loaded itself.
local _all_mods_loaded_functions = {}
function mod.add_all_mods_loaded_function(self, func)
    _all_mods_loaded_functions[#_all_mods_loaded_functions + 1] = func
end
mod.on_all_mods_loaded = function (...)
    for i = 1, #_all_mods_loaded_functions do
        _all_mods_loaded_functions[i](...)
    end
end

--- Game-state-changed hook
-- Same single-field-collision problem again. Register through
-- mod:add_game_state_changed_function(fn) instead of assigning mod.on_game_state_changed itself.
local _game_state_changed_functions = {}
function mod.add_game_state_changed_function(self, func)
    _game_state_changed_functions[#_game_state_changed_functions + 1] = func
end
mod.on_game_state_changed = function (...)
    for i = 1, #_game_state_changed_functions do
        _game_state_changed_functions[i](...)
    end
end

--- DamageUtils.apply_buffs_to_damage dispatcher
-- Same hook-collision problem as IngameHud above: 02_damage_taken_changes.lua replaces this function
-- with mod:hook_origin, so any other file calling mod:hook on it as well would not reliably run.
-- The base implementation is set once via mod:set_apply_buffs_to_damage(fn), and features that need to
-- wrap it register through mod:add_apply_buffs_to_damage_wrapper(fn), with fn(func, ...) shaped like a
-- mod:hook callback (func = next wrapper in line, ending at the base implementation).
-- Wrappers run in registration order, outermost first.
local _apply_buffs_to_damage_wrappers = {}
local _apply_buffs_to_damage_base = DamageUtils.apply_buffs_to_damage -- vanilla, until set_apply_buffs_to_damage replaces it
local _apply_buffs_to_damage_chain = nil -- composed lazily, rebuilt when a wrapper is added

function mod.add_apply_buffs_to_damage_wrapper(self, wrapper)
    _apply_buffs_to_damage_wrappers[#_apply_buffs_to_damage_wrappers + 1] = wrapper
    _apply_buffs_to_damage_chain = nil
end

function mod.set_apply_buffs_to_damage(self, base)
    _apply_buffs_to_damage_base = base
    _apply_buffs_to_damage_chain = nil
end

local function compose_apply_buffs_to_damage_chain()
    local chain = _apply_buffs_to_damage_base

    for i = #_apply_buffs_to_damage_wrappers, 1, -1 do
        local wrapper = _apply_buffs_to_damage_wrappers[i]
        local inner = chain

        chain = function (...)
            return wrapper(inner, ...)
        end
    end

    return chain
end

mod:hook_origin(DamageUtils, "apply_buffs_to_damage", function (...)
    if not _apply_buffs_to_damage_chain then
        _apply_buffs_to_damage_chain = compose_apply_buffs_to_damage_chain()
    end

    return _apply_buffs_to_damage_chain(...)
end)

--- PlayerUnitHealthExtension.add_heal dispatcher
-- Same hook-collision problem as IngameHud above: 04_es_questingknight.lua and 10_we_maidenguard.lua both need to
-- wrap add_heal. Register through mod:add_player_add_heal_wrapper(fn) instead of calling
-- mod:hook(PlayerUnitHealthExtension, "add_heal", ...) directly. fn(func, self, ...) is shaped like a mod:hook
-- callback (func = next wrapper in line, ending at the original add_heal).
-- Wrappers run in registration order, outermost first.
local _player_add_heal_wrappers = {}
local _player_add_heal_chain = nil -- composed lazily, rebuilt when a wrapper is added or the original changes
local _player_add_heal_chain_base = nil

function mod.add_player_add_heal_wrapper(self, wrapper)
    _player_add_heal_wrappers[#_player_add_heal_wrappers + 1] = wrapper
    _player_add_heal_chain = nil
end

mod:hook(PlayerUnitHealthExtension, "add_heal", function (func, ...)
    if not _player_add_heal_chain or _player_add_heal_chain_base ~= func then
        local chain = func

        for i = #_player_add_heal_wrappers, 1, -1 do
            local wrapper = _player_add_heal_wrappers[i]
            local inner = chain

            chain = function (...)
                return wrapper(inner, ...)
            end
        end

        _player_add_heal_chain = chain
        _player_add_heal_chain_base = func
    end

    return _player_add_heal_chain(...)
end)

--- DamageUtils.create_explosion dispatcher
-- Same hook-collision problem as IngameHud above: 13_wh_captain.lua (ISJYA marks) and 19_bw_unchained.lua (no friendly
-- fire) both need it. Register through mod:add_create_explosion_wrapper(fn) instead of calling
-- mod:hook/hook_safe(DamageUtils, "create_explosion", ...) directly. fn(func, ...) is shaped like a mod:hook
-- callback (func = next wrapper in line, ending at the original create_explosion).
-- Wrappers run in registration order, outermost first.
local _create_explosion_wrappers = {}
local _create_explosion_chain = nil -- composed lazily, rebuilt when a wrapper is added or the original changes
local _create_explosion_chain_base = nil

function mod.add_create_explosion_wrapper(self, wrapper)
    _create_explosion_wrappers[#_create_explosion_wrappers + 1] = wrapper
    _create_explosion_chain = nil
end

mod:hook(DamageUtils, "create_explosion", function (func, ...)
    if not _create_explosion_chain or _create_explosion_chain_base ~= func then
        local chain = func

        for i = #_create_explosion_wrappers, 1, -1 do
            local wrapper = _create_explosion_wrappers[i]
            local inner = chain

            chain = function (...)
                return wrapper(inner, ...)
            end
        end

        _create_explosion_chain = chain
        _create_explosion_chain_base = func
    end

    return _create_explosion_chain(...)
end)

--- ActionMeleeStart.client_owner_post_update dispatcher
-- Same hook-collision problem as IngameHud above: 02_career_changes.lua (Timed Block Long), 04_es_questingknight.lua
-- and 09_we_waywatcher.lua (Ricochet charged popup) all need to run after it. Register through mod:add_melee_start_post_update_function(fn)
-- instead of calling mod:hook/hook_safe(ActionMeleeStart, "client_owner_post_update", ...) directly.
-- fn(self, dt, t, world) runs after the original, in registration order.
local _melee_start_post_update_functions = {}
function mod.add_melee_start_post_update_function(self, func)
    _melee_start_post_update_functions[#_melee_start_post_update_functions + 1] = func
end
mod:hook(ActionMeleeStart, "client_owner_post_update", function (func, self, dt, t, world)
    func(self, dt, t, world)

    for i = 1, #_melee_start_post_update_functions do
        _melee_start_post_update_functions[i](self, dt, t, world)
    end
end)

--- CareerExtension.update dispatcher
-- Same hook-collision problem as IngameHud above: features needing a per-frame career tick (01_es_mercenary.lua,
-- On Yer Feet, Mates!) register through mod:add_career_update_function(fn)
-- instead of calling mod:hook/hook_safe(CareerExtension, "update", ...) directly.
-- fn(self, unit, input, dt, context, t) runs after the original, in registration order.
local _career_update_functions = {}
function mod.add_career_update_function(self, func)
    _career_update_functions[#_career_update_functions + 1] = func
end
mod:hook(CareerExtension, "update", function (func, self, unit, input, dt, context, t)
    func(self, unit, input, dt, context, t)

    for i = 1, #_career_update_functions do
        _career_update_functions[i](self, unit, input, dt, context, t)
    end
end)

--- Buff apply conditions
-- To stop specific buffs from being added (e.g. movement penalties), chain a condition onto the template's
-- sub-buffs instead of hooking BuffExtension.add_buff: add_buff checks sub_buff.apply_condition itself, so the
-- check only costs anything when that template is added, not on every add_buff of every unit.
-- condition(unit, sub_buff_template, params) returns false to block the sub-buff. Conditions chain, so
-- several features can gate the same template (04_es_questingknight.lua, 07_dr_slayer.lua).
-- Never gate "planted_return_to_normal_*": lerped slowdowns are undone by adding those on removal, so blocking them
-- leaves the movement setting permanently scaled down.
function mod.add_buff_apply_condition(self, buff_template_name, condition)
    local buff_template = BuffTemplates[buff_template_name]

    if not (buff_template and buff_template.buffs) then
        return
    end

    for _, sub_buff in ipairs(buff_template.buffs) do
        local original_condition = sub_buff.apply_condition

        sub_buff.apply_condition = function (unit, template, params)
            if not condition(unit, template, params) then
                return false
            end

            if original_condition then
                return original_condition(unit, template, params)
            end

            return true
        end
    end
end

-- Weapon actions pass their own multiplier to movement buffs, above 1 means the action speeds the player up
function mod.is_action_movement_speed_up(self, params)
    local external_multiplier = params and params.external_optional_multiplier

    return not not (external_multiplier and external_multiplier > 1)
end

--- In-game localization
-- Replace original strings, if _quick_localize can fetch custom strings
local localization_api = require("scripts/mods/TourneyBalance/_api/_localization_api")
mod:hook("Localize", function(func, text_id)
    local str = localization_api._quick_localize(text_id)
    if str then
        return str
    end
    return func(text_id)
end)

--[[

    Balance Changes

]]
-- Misc standalone fixes not tied to any other category
mod:dofile("scripts/mods/TourneyBalance/changes/_misc_fixes")

-- Enemies for Spicy
mod:dofile("scripts/mods/TourneyBalance/changes/00_spicy_enemies")

-- THP/Stagger/Damage Related Changes
mod:dofile("scripts/mods/TourneyBalance/changes/01_thp_stagger_damage_changes")

-- Career Changes (Ultimates/Passives/Talents)
mod:dofile("scripts/mods/TourneyBalance/changes/02_career_changes")

-- Trait & Property Changes
mod:dofile("scripts/mods/TourneyBalance/changes/03_trait_and_property_changes")

-- Balance diff export - snapshots Weapons/DamageProfileTemplates/etc. on load
-- Placed here to only export weapon changes
mod:dofile("scripts/mods/TourneyBalance/debugging/balance_diff_export")

-- Weapon Changes
mod:dofile("scripts/mods/TourneyBalance/changes/04_weapon_changes")

-- Fun Features (opt-in, settings-gated movement tech)
mod:dofile("scripts/mods/TourneyBalance/changes/05_fun_changes")


--[[

    Utility

]]
-- Performance Logging System
-- Disabled: its mod.update collided with stagger_state_visualizer.lua's
-- mod:dofile("scripts/mods/TourneyBalance/logging_and_qol/performance_logging")

-- Mod Checker
mod:dofile("scripts/mods/TourneyBalance/logging_and_qol/mod_checker")

-- Basic QOL Features
mod:dofile("scripts/mods/TourneyBalance/logging_and_qol/basic_qol")

-- Debugging Tools
mod:dofile("scripts/mods/TourneyBalance/debugging/stagger_state_visualizer")


--[[

    Merge Changes


]]
local function updateValues()
	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end
	return
end

mod.on_enabled = function (self)
	mod:echo(mod:localize("mod_enabled"))
	updateValues()
	return
end
