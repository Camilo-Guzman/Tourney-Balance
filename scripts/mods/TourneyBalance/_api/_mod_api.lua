local mod_api = {}

local localization_api = require("scripts/mods/TourneyBalance/_api/_localization_api")
local talent_api = require("scripts/mods/TourneyBalance/_api/_talent_api")
local buff_api = require("scripts/mods/TourneyBalance/_api/_buff_api")

--[[
    Flat call surface over three underlying APIs (plain require modules):
    - Localization text registration (_localization_api.lua)
    - TalentTree scoped registration (_talent_api.lua)
    - Generic buff/proc registration (_buff_api.lua)

    This file exists so consumer can do `local mod_api = require(".../_mod_api")` once and call
    `mod_api.X(...)` without caring which of the three APIs a given function actually comes from. 
    Function origins documented below:

        _localization_api.lua : _quick_localize
                                insert_text
                                insert_talent_text
                                insert_perk_text

        _talent_api.lua       : update_career_ability_cooldown
                                insert_career_passives
                                insert_career_perk_descriptions
                                remove_career_passives
                                remove_career_perk_description
                                insert_talent_buff_template
                                update_talent_buff_template
                                insert_talent
                                update_talent

        _buff_api.lua         : insert_buff_template
                                insert_buff_function
                                insert_proc_function
                                add_buff

    Naming conventions inspired by databases:
        insert: Adds new entry, if non-existent;
                Modifies existing entry, otherwise.
        update: Modifies existing entry

    IMPORTANT: prefix "tb_" whenever insert_* function call creates a NEW entry.

    Collision safety: merge_into asserts no two source tables define the same key, so future name
    collisions between the sub-APIs fail loudly at load time instead of silently shadowing.
]]

local function merge_into(dst, src)
    for name, func in pairs(src) do
        assert(dst[name] == nil, "_mod_api: '" .. name .. "' is defined in more than one sub-API - give one of them a distinct name instead of re-exporting a silent collision")
        dst[name] = func
    end
end

merge_into(mod_api, localization_api)
merge_into(mod_api, talent_api)
merge_into(mod_api, buff_api)

return mod_api
