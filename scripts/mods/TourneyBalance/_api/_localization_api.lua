local localization_api = {}

--[[
    Localization framework: insert_text/insert_talent_text register strings that
    _quick_localize resolves before falling back to vanilla localization.

    Plain require module and not attached to `mod`. Require caching ensures persistency of 
    _localization_database table. mod:hook("Localize", ...) wires _quick_localize into base game's
    Localize function in TourneyBalance.lua and is treated as initialization.

    Example usage:
        Arguments: text, name, description can be localized

        -- Plain text - defaults to "en":
        insert_text("my_string_id", "Foot Knight")

        -- Multi-language table of text:
        insert_text("my_string_id", {
            en = "Foot Knight",
            de = "Ritter zu Fuß",
        })
        -- a client with language_id "de" sees "Ritter zu Fuß"
        -- every other language falls back to "en"
]]

local _language_id = Application.user_setting("language_id")
local _localization_database = {}

function localization_api._quick_localize(text_id)
    local text_translations = _localization_database[text_id]
    if text_translations then
        return text_translations[_language_id] or text_translations["en"]
    end
end

function localization_api.insert_text(text_id, text)
    if type(text) == "table" then
        _localization_database[text_id] = text
    else
        _localization_database[text_id] = {
            en = text
        }
    end
end

function localization_api.insert_talent_text(talent_name, name, description)
    localization_api.insert_text(talent_name, name)
    localization_api.insert_text(talent_name .. "_desc", description)
end

function localization_api.insert_perk_text(perk_name, name, description)
    localization_api.insert_text("career_passive_name_" .. perk_name, name)
    localization_api.insert_text("career_passive_desc_" .. perk_name, description)
end

return localization_api
