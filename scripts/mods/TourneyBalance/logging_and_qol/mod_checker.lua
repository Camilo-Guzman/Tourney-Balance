--[[
    
    ModChecker is checking what mods are currently installed by the player and their team, cross references that information with
    a dedicated table which notes which mods are actually allowed to be used and displays the once missing from that list
    in an UI window on screen. Additionally it shares the checked information with the rest of the team displaying their status on screen as well.

    2025-07-31 - Janoti!

]]

local mod = get_mod("TourneyBalance")

-- Mod Tables
-- Subject to change
local allowed_mods_id = {

--Required
    "2545022878", --TourneyBalance
    "1835393505", --Cata 3 & Deathwish
    "2170475262", --Beastmen Loader
    "2456507597", --No Beastmen
    "3041453243", --Linesman Onslaught & Daredevil
    --"1384087820", --True solo qol tweaks (Not needed anymore)

    --"1619024877", --Onslaught
    --"2179403386", --OnslaughtPlus
    --"2559718905", --DutchSpice
    --"1694820325", --A Quiet Drink

--Sanctioned
    "1369573612", --VMF, Vermintide Mod Framework
    "1374248490", --penlight lua libraries
    "1389872347", --Simple Ui (this mod exist twice for some reason and has two names)
    "1467751760", --HideBuffs, Ui Tweaks
    "1397265260", --Numeric Ui
    "1460327284", --BossKillTimer
    "1384066089", --Neuter Ult Effects
    "1431393962", --Bestiary
    "1498992606", --Countries in Lobby Browser
    "1421155919", --Mission timer
    "1487862316", --Reroll Improvements
    "1464907434", --Armory
    "1502859403", --Notice Key Pickup
    "1445717962", --Loadout Manager
    "1402971136", --Needii
    "1495937978", --Host Quick Play Games
    "1569650837", --Crosshairs Fix
    "1395453301", --Skip Intro
    "2699340287", --Korean Chat
    "1388911015", --Chat Block
    "1652856346", --Dodge Count UI
    "1467945840", --Blood for the blood god
    "1593460250", --Crosshair Kill Confirmation
    "1459917022", --Parry Indicator
    "1448714756", --No Wobble
    "1383433646", --Persistent Ammo Counter
    "2038263753", --Remove Hanged Corpses
    "1384094638", --Crosshair Customization
    "1383452616", --Killfeed Tweaks
    "1623948024", --Hi-Def UI Scaling
    "1516618647", --Friendly Fire Indicator
    "1498189723", --Customizable Zoom Sensitivity
    "1504702573", --Streaming Info

--Allowed
    "1422758813", --More Items Library
    "1425249043", --Give Weapon
    "1391114686", --Skip Cutscenes
    "3370372364", --GiveWeaponFix
    "1687843693", --SaveWeapon
    "2824452077", --Give Weapon Supplement - Remove CW Traits
    "1840873216", --Casual Mode
    "2820987626", --Give Weapon zh support
    "3368543012", --Neuter Ult Effects (TEMP)
    "3366928597", --UI Tweaks Temp
    "2826469917", --UI Tweaks (zh)
    "2477335429", --Restart Level
    "1769554507", --Accessibility Captions
    "3008293345", --Accessibility Captions 2.0
    "1609917710", --More Corpses
    "1405221659", --Less Annoying Friendly Fire
    "2490345007", --More Skins
    "1391113873", --More Hats
    "1423536193", --Give all Hats, Skins, and Paintings
    "1584145468", --No Overcharge Damage Indicator
    "2134585757", --Choose Grail Knight Quests
    "2827932341", --Life's Hard Everywhere
    "2493528647", --SlaughterHouse
    "2990935500", --SnowyEnemyRemoval
    "2955881987", --Set Garbage
    "2827840248", --Ph. Indicator
    "2525452894", --Vermintide Analytics
    "3216778139", --Disable Fog (Replacement for TrueSoloQOL)
    "1498748049", --Colorful Unique Weapons (Version 2.something)
    "2760973758", --Headshot Counter
    "2503071508", --DisplayTeamName
    "2385964757", --DPS Meter
    "1545823051", --Duct Tape Mod
    "2418326943", --Fix Restart Sound Bug
    "2134634186", --Choose Weather
    "2174425628", --Hat Control
    "2993715887", --Maps for mission selection
    "2801810157", --Clock Time (Specifically when players are playing outside of the normal tourney time)

--Balance Mods
    --"2503948895", --ClassBalance
    --"3302053065", --Linesman Balance
    --"3141239720", --Kite together
    --"2705276978", --Core's Big Rebalance
    --"2874461307", --Live Remasted

--Goober / Linesman Event exclusive
    --"2688241862", --Sons of Sigmar - Gooby only
    --"1393694530", --Spawn Tweaks - Gooby only
    --"1460857124", --Chat Wheel
    "2803255292", --Specials Sound Cues Fix
    "2824402636", --Less Corpses
    "3214214805", --Straight to Keep and Quit Game
    "2866794030", --Waypoints
    "3082495950", --NoSmokeBountyHunter&EnsorcelledReaperNoVFX
    "2649047582", --Remove Ability Bobbing
    "1642545164", --Disable Friendly Fire Dialogue

--Debug
    --"3348952854", --TourneyBalanceBeta
    --"3153107118", --lan Lobby
}

local active_mods = {}
local prohibited_mods = {}

-- Tourney Time
local is_tourney_time = false
local tourney_time = {
    start_time = {
        year = 2025,
        month = 8,
        day = 21,
        hour = 12,
        min = 0,
        sec = 0
    },
    end_time = {
        year = 2025,
        month = 9,
        day = 1,
        hour = 12,
        min = 0,
        sec = 0
    },
}

-- Title Text
local approved_mods = {
    "Tourney Approved!",
    "Tourney Approved!",
    "Tourney Approved!",
    "Tourney Approved!",
}
local prohibited_mods_detect = {
    "UNAPPROVED MODS DETECTED!",
    "UNAPPROVED MODS DETECTED!",
    "UNAPPROVED MODS DETECTED!",
    "UNAPPROVED MODS DETECTED!",
}
local teammates_have_prohibited_mods = {
    "TEAMMATES USE UNAPPROVED MODS!",
    "TEAMMATES USE UNAPPROVED MODS!",
    "TEAMMATES USE UNAPPROVED MODS!",
    "TEAMMATES USE UNAPPROVED MODS!",
}

-- Networking
local send_prohibited_mods = false

-- Data Logging
mod.unapproved_mods_data = " "
mod.teammates_unapproved_mods_data = "false"
mod.is_tourney_time_performance_logging = is_tourney_time

--[[

░██████╗██╗░░██╗░█████╗░░██╗░░░░░░░██╗  ████████╗███████╗██╗░░██╗████████╗
██╔════╝██║░░██║██╔══██╗░██║░░██╗░░██║  ╚══██╔══╝██╔════╝╚██╗██╔╝╚══██╔══╝
╚█████╗░███████║██║░░██║░╚██╗████╗██╔╝  ░░░██║░░░█████╗░░░╚███╔╝░░░░██║░░░
░╚═══██╗██╔══██║██║░░██║░░████╔═████║░  ░░░██║░░░██╔══╝░░░██╔██╗░░░░██║░░░
██████╔╝██║░░██║╚█████╔╝░░╚██╔╝░╚██╔╝░  ░░░██║░░░███████╗██╔╝╚██╗░░░██║░░░
╚═════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░  ░░░╚═╝░░░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░
]]

local font_name = "arial"
local font_material = "materials/fonts/" .. font_name
local white_color = Colors.color_definitions.white
local black_color = Colors.color_definitions.black
local red_color = Colors.color_definitions.red

-- get the current user settings for font size and position of the UI widget
local get_user_settings = function ()
    mod.font_size = mod:get("font_size")
    mod.position = {
        mod:get("position_x"),
        mod:get("position_y"),
    }
end

-- initialize the renderer to draw the text
local render_init = function ()
    local world = Managers.world:world("top_ingame_view")
    mod.renderer = UIRenderer.create(world, "material", "materials/fonts/gw_fonts")
end

-- display the text on screen
local show_text = function ()
    local renderer = mod.renderer
    local display_position = table.clone(mod.position)

    if prohibited_mods then
        for k, v in pairs(prohibited_mods) do
            local font_size = mod.font_size
            -- make title bigger than rest
            if v[1] == v[2] then
                font_size = font_size * 1.5
            end
            display_position[2] = display_position[2] - (font_size + 1)
            local display_text = v[2]
            UIRenderer.draw_text(renderer, display_text, font_material, font_size, font_name, display_position, white_color) -- also has retained_id and color_override 
        end
    end
end
mod:hook_safe(IngameHud, "update", function(self)
    -- check for visibility of UI
    if not self._currently_visible_components.EquipmentUI then
        return
    end
    if is_tourney_time or mod:get("tourney_mode") then
        show_text()
    end
end)


--[[

░██████╗░███████╗████████╗  ███╗░░░███╗░█████╗░██████╗░░██████╗
██╔════╝░██╔════╝╚══██╔══╝  ████╗░████║██╔══██╗██╔══██╗██╔════╝
██║░░██╗░█████╗░░░░░██║░░░  ██╔████╔██║██║░░██║██║░░██║╚█████╗░
██║░░╚██╗██╔══╝░░░░░██║░░░  ██║╚██╔╝██║██║░░██║██║░░██║░╚═══██╗
╚██████╔╝███████╗░░░██║░░░  ██║░╚═╝░██║╚█████╔╝██████╔╝██████╔╝
░╚═════╝░╚══════╝░░░╚═╝░░░  ╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚═════╝░

]]

-- get info about active mods of local player (Active meaning turned on in mod launcher)
local get_active_mods = function()
    VMF = get_mod("VMF")

    local all_mods = VMF.mods
    if not all_mods then
        return
    end

    for k, v in pairs(all_mods) do
        local mod_metatable = getmetatable(all_mods[k]._data)
        local active_mod = {
            mod_metatable.__index.is_enabled, -- true of false if enabled in VMF settings in game
            mod_metatable.__index.readable_name, -- localized ingame Name
            k, -- Code name
            mod_metatable.__index.workshop_id, -- ID
        }
        table.insert(active_mods, active_mod)
    end

end
-- cross reference and print function of total mods that are not allowed
local check_mods = function ()
    if not active_mods then
        return
    end

    local prohibited_mods_check = {}

    for _, v1 in pairs(active_mods) do
        for k2, v2 in pairs(allowed_mods_id) do
            if v1[4] == v2 then
                break
            elseif v1[4] ~= v2 and k2 == #allowed_mods_id then
                table.insert(prohibited_mods_check, v1)
            end
        end
    end

    -- prevent duplicates to go into the list
    for k1, v1 in pairs(prohibited_mods_check) do
        if prohibited_mods[1] then
            for k2, v2 in pairs(prohibited_mods) do
                if v1[4] == v2[4] then
                    break
                elseif v1[4] ~= v2[4] and k2 == #prohibited_mods then
                    table.insert(prohibited_mods, v1)
                end
            end
        else
            table.insert(prohibited_mods, v1)
        end
    end

end

-- Performance Logging Data
-- write all prohibited mods in usage in variable to be saved in performance data in the console log
local write_logging_mods_data = function ()
    if #prohibited_mods == 1 then
        mod.unapproved_mods_data = "None"
        return
    end

    for _, v in pairs(prohibited_mods) do
        mod.unapproved_mods_data = mod.unapproved_mods_data .. " | " .. v[2]
    end
end
-- write if prohibited mods are used by teammates in variable to be saved in performance data in the console log
local write_logging_mods_data_teammates = function ()
    mod.teammates_unapproved_mods_data = tostring(send_prohibited_mods)
end

-- Add the title to display that the local player uses or not uses prohibited mods
local add_title_display_text = function ()
    if #prohibited_mods == 0 then
        table.remove(prohibited_mods, 1)
        table.insert(prohibited_mods, 1, approved_mods)
    elseif #prohibited_mods > 0 then
        if prohibited_mods[1][1] == prohibited_mods_detect[1] then
            return
        end
        if prohibited_mods[1][1] == approved_mods[1] then
            return
        end
        table.insert(prohibited_mods, 1, prohibited_mods_detect)
    end
end
-- Remove the Title about teammates using prohibited mods
local remove_teammates_warning = function()
    if send_prohibited_mods == true then
        if prohibited_mods[2] == teammates_have_prohibited_mods then
            table.remove(prohibited_mods, 2)
            write_logging_mods_data_teammates()
        end
    end
end



--[[

███╗░░██╗███████╗████████╗░██╗░░░░░░░██╗░█████╗░██████╗░██╗░░██╗██╗███╗░░██╗░██████╗░
████╗░██║██╔════╝╚══██╔══╝░██║░░██╗░░██║██╔══██╗██╔══██╗██║░██╔╝██║████╗░██║██╔════╝░
██╔██╗██║█████╗░░░░░██║░░░░╚██╗████╗██╔╝██║░░██║██████╔╝█████═╝░██║██╔██╗██║██║░░██╗░
██║╚████║██╔══╝░░░░░██║░░░░░████╔═████║░██║░░██║██╔══██╗██╔═██╗░██║██║╚████║██║░░╚██╗
██║░╚███║███████╗░░░██║░░░░░╚██╔╝░╚██╔╝░╚█████╔╝██║░░██║██║░╚██╗██║██║░╚███║╚██████╔╝
╚═╝░░╚══╝╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░
]]

-- networking system in which the info about active mods is shared among all players
local settings_sync_package_id = "tourney_check"

-- Compare Tables --TODO (add functionality to share the entire mod list instead of a bool)
local function compare_mod_list(received_mod_list)
    -- compare the incoming table and the one already here
    -- combine the two different tables

    if not received_mod_list then
        return
    end

    send_prohibited_mods = received_mod_list
    write_logging_mods_data_teammates()

    -- comparing the lists
    --for k, v in pairs(received_mod_list) do
    --    mod.send[k] = v
    --end

    -- incoperate list into UI
    table.insert(prohibited_mods, 2, teammates_have_prohibited_mods)
end

-- Send Mods
local function sync_mods()
	mod:network_send(
		settings_sync_package_id,
		"others",
        send_prohibited_mods
	)
end

-- Receive Mods
mod:network_register(settings_sync_package_id, function(sender, mod_table)
    compare_mod_list(mod_table)
end)

-- New Player
mod.on_user_joined = function(player)
	sync_mods()
end
-- Player Left
mod.on_user_left = function(player)
	sync_mods()
    remove_teammates_warning()
end


--[[

████████╗░█████╗░██╗░░░██╗██████╗░███╗░░██╗███████╗██╗░░░██╗  ████████╗██╗███╗░░░███╗███████╗
╚══██╔══╝██╔══██╗██║░░░██║██╔══██╗████╗░██║██╔════╝╚██╗░██╔╝  ╚══██╔══╝██║████╗░████║██╔════╝
░░░██║░░░██║░░██║██║░░░██║██████╔╝██╔██╗██║█████╗░░░╚████╔╝░  ░░░██║░░░██║██╔████╔██║█████╗░░
░░░██║░░░██║░░██║██║░░░██║██╔══██╗██║╚████║██╔══╝░░░░╚██╔╝░░  ░░░██║░░░██║██║╚██╔╝██║██╔══╝░░
░░░██║░░░╚█████╔╝╚██████╔╝██║░░██║██║░╚███║███████╗░░░██║░░░  ░░░██║░░░██║██║░╚═╝░██║███████╗
░░░╚═╝░░░░╚════╝░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚══╝╚══════╝░░░╚═╝░░░  ░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚══════╝

]]

-- Check Time
local start_time = os.time(os.date("!*t", os.time(tourney_time.start_time)))
local end_time = os.time(os.date("!*t", os.time(tourney_time.end_time)))
local current_time = os.time(os.date("!*t"))
local check_tourney_time = function()
    is_tourney_time = (current_time >= start_time and current_time <= end_time)
    mod.is_tourney_time_performance_logging = is_tourney_time
end


--[[

██╗░░░░░░█████╗░░█████╗░██████╗░██╗███╗░░██╗░██████╗░
██║░░░░░██╔══██╗██╔══██╗██╔══██╗██║████╗░██║██╔════╝░
██║░░░░░██║░░██║███████║██║░░██║██║██╔██╗██║██║░░██╗░
██║░░░░░██║░░██║██╔══██║██║░░██║██║██║╚████║██║░░╚██╗
███████╗╚█████╔╝██║░░██║██████╔╝██║██║░╚███║╚██████╔╝
╚══════╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░╚══╝░╚═════╝░
]]

-- Check one after another
-- enable and disable functionality through checkbox but also function that brute force turns it on when a given time is met (aka tourney time)
local initiate_mod_checker = function ()
    render_init()
    get_user_settings()

    -- Check Time
    check_tourney_time()

    if is_tourney_time or mod:get("tourney_mode") then
        get_active_mods()
        check_mods()
        write_logging_mods_data()
        add_title_display_text()
    end
end
mod.on_all_mods_loaded = function()
    initiate_mod_checker()
end
mod.on_setting_changed = function()
    initiate_mod_checker()
end

-- Join or Leave Game
mod.on_game_state_changed_mod_checker = function()
    initiate_mod_checker()
    if #prohibited_mods > 1 then
        send_prohibited_mods = true
    else
        send_prohibited_mods = false
    end
    remove_teammates_warning()
end