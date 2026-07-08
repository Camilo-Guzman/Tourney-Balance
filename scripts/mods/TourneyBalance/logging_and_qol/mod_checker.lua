--[[
    ModChecker is checking what mods are currently installed by the player and their team, cross references that information with
    a dedicated table which notes which mods are actually allowed to be used and displays the ones missing from that list
    in a UI window on screen. Additionally it shares the checked information with the rest of the team displaying their status on screen as well.

    2025-07-31 - Janoti!
    Updated: 2026-06-24 - Code Refactor, Performance/Stability Rewrite - mr.chen
]]

local mod = get_mod("TourneyBalance")

-- -------------------------------------------------------------------
-- Mod Tables
-- -------------------------------------------------------------------
local allowed_mods_id = {

    --Required
    "2545022878", --TourneyBalance
    "1835393505", --Cata 3 & Deathwish
    "2170475262", --Beastmen Loader
    "2456507597", --No Beastmen
    "1694820325", --A Quiet Drink

    --Mutators
    "1619024877", --Onslaught
    --"2179403386", --OnslaughtPlus
    --"2559718905", --DutchSpice
    "3041453243", --Linesman Onslaught & Daredevil

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
    --"1584145468", --No Overcharge Damage Indicator
    "2134585757", --Choose Grail Knight Quests
    --"2827932341", --Life's Hard Everywhere
    --"2493528647", --SlaughterHouse
    --"2990935500", --SnowyEnemyRemoval
    --"2955881987", --Set Garbage
    "2827840248", --Ph. Indicator
    --"2525452894", --Vermintide Analytics
    --"3216778139", --Disable Fog (Replacement for TrueSoloQOL)
    --"1498748049", --Colorful Unique Weapons (Version 2.something)
    --"2760973758", --Headshot Counter
    --"2503071508", --DisplayTeamName
    --"2385964757", --DPS Meter
    --"1545823051", --Duct Tape Mod
    --"2418326943", --Fix Restart Sound Bug
    "2134634186", --Choose Weather
    --"2174425628", --Hat Control
    --"2993715887", --Maps for mission selection
    --"2801810157", --Clock Time (Specifically when players are playing outside of the normal tourney time)

    --Balance Mods
    --"2503948895", --ClassBalance
    --"3302053065", --Linesman Balance
    --"3141239720", --Kite together
    --"2705276978", --Core's Big Rebalance
    --"2874461307", --Live Remasted

    --Goober / Linesman Event exclusive
    "3672228443", --Ubersreik 5
    "3720586440", --Tourney Seeding
    "1529868962", --Ready Up
    "2945094506", --Remove Democrocy
    "3721038774", --Crafting in modded
    "1384087820", --True solo qol tweaks (Not needed anymore)
    "2803255292", --Specials Sound Queue Fix
    "3035806430", --Chaos Spawn Dansen
    "3674660549", --No Smoke Bounty Hunter
    "3677447814", --No Flashbang Scythe
    "3738401555", --EUAUGH!
    "3687155143", --Smash Bros Home Run SFX As GK's Ultimate
    "3070697376", --Firewatch's Cursed SFX Pack
    "3116878398", --Vine Boom Overhead
    "3069125974", --Backstab SFX
    "3068430493", --Slaanesh Chaos Warrior
    "3066129604", --Sekiro Parry SFX
    "3595332090", --Tab Scoreboard
    "1679789641", --ChargeUI
    "2931963897", --Max Level
    "3173876211", --DifficultiesUnlocked

    --Debug
    --"3348952854", --TourneyBalanceBeta
    --"3153107118", --lan Lobby
}

-- Convert allowed mods into an O(1) Set for instant lookup
local allowed_set = {}
for _, id in ipairs(allowed_mods_id) do
    allowed_set[id] = true
end

-- State Variables
local is_openbeta = false
local active_mods = {}
local prohibited_mods = {}

-- Networking State
local local_send_prohibited_mods = false
local global_send_prohibited_mods = false

-- Tourney Time
local is_tourney_time = false
local tourney_time = {
    start_time = { year = 2026, month = 6, day = 25, hour = 12, min = 0, sec = 0 },
    end_time   = { year = 2026, month = 7, day = 6,  hour = 12, min = 0, sec = 0 },
}

-- Data Logging
mod.unapproved_mods_data = " "
mod.teammates_unapproved_mods_data = "false"
mod.is_tourney_time_performance_logging = false

-- -------------------------------------------------------------------
-- UI Rendering
-- -------------------------------------------------------------------
local font_name = "arial"
local font_material = "materials/fonts/" .. font_name
local white_color = Colors.color_definitions.white

local get_user_settings = function ()
    mod.font_size = 12

    -- Force position to bottom left.
    -- local screen_w = RESOLUTION_LOOKUP.res_w
    -- local screen_h = RESOLUTION_LOOKUP.res_h
    mod.position = { -- x,y
        5, 
        -10, 
    }
end

local render_init = function ()
    -- Only initialize the renderer once to prevent memory leaks
    if not mod.renderer then
        local world = Managers.world:world("top_ingame_view")
        if world then
            mod.renderer = UIRenderer.create(world, "material", "materials/fonts/gw_fonts")
        end
    end
end

local show_text = function ()
    if not mod.renderer then return end

    local renderer = mod.renderer
    local display_position = table.clone(mod.position)
    local font_size = mod.font_size
    
    -- Determine the dynamic header based on state
    local header_text = "Tourney Approved!"
    local local_has_mods = (#prohibited_mods > 0)

    if local_has_mods and global_send_prohibited_mods then
        header_text = "EVERYONE USES UNAPPROVED MODS!"
    elseif local_has_mods then
        header_text = "UNAPPROVED MODS DETECTED!"
    elseif global_send_prohibited_mods then
        header_text = "TEAMMATES USE UNAPPROVED MODS!"
    end

    -- Draw Header (1.5x larger)
    display_position[2] = display_position[2] + (font_size * 1.2 + 1)
    UIRenderer.draw_text(renderer, header_text, font_material, font_size * 1.2, font_name, display_position, white_color)
    display_position[2] = display_position[2] + 3 -- Additional padding

    -- Draw Local Unapproved Mods
    if local_has_mods and mod:get("tourney_display_mods") then
        for _, mod_data in ipairs(prohibited_mods) do
            display_position[2] = display_position[2] + (font_size + 1)
            UIRenderer.draw_text(renderer, mod_data[2], font_material, font_size, font_name, display_position, white_color)
        end
    end
end

mod:hook_safe(IngameHud, "update", function(self)
    if not self._currently_visible_components.EquipmentUI then return end
    
    if (is_tourney_time and not is_openbeta) or mod:get("tourney_mode") then
        show_text()
    end
end)

-- -------------------------------------------------------------------
-- Data Processing
-- -------------------------------------------------------------------
local get_active_mods = function()
    local VMF = get_mod("VMF")
    if not VMF or not VMF.mods then return end

    active_mods = {} -- Clear state before repopulating
    
    for k, v in pairs(VMF.mods) do
        local mod_metatable = getmetatable(v._data)
        if mod_metatable then
            local is_enabled = mod_metatable.__index.is_enabled
            -- Only track it if it's currently enabled
            if is_enabled then
                table.insert(active_mods, {
                    is_enabled,
                    mod_metatable.__index.readable_name,
                    k,
                    mod_metatable.__index.workshop_id,
                })
            end
        end
    end
end

local check_mods = function ()
    prohibited_mods = {} -- Clear state before repopulating
    if #active_mods == 0 then return end

    local seen_prohibited = {}

    for _, mod_data in ipairs(active_mods) do
        local mod_id = mod_data[4]
        
        if not allowed_set[mod_id] and not seen_prohibited[mod_id] then
            table.insert(prohibited_mods, mod_data)
            seen_prohibited[mod_id] = true
        end
    end
    is_openbeta = (seen_prohibited["3722716715"] ~= nil)
end

local write_logging_mods_data = function ()
    if #prohibited_mods == 0 then
        mod.unapproved_mods_data = "None"
    else
        mod.unapproved_mods_data = ""
        for i, v in ipairs(prohibited_mods) do
            mod.unapproved_mods_data = mod.unapproved_mods_data .. (i > 1 and " | " or "") .. v[2]
        end
    end
    mod.teammates_unapproved_mods_data = tostring(global_send_prohibited_mods)
end

-- -------------------------------------------------------------------
-- Networking
-- -------------------------------------------------------------------
local settings_sync_package_id = "tourney_check"

mod.player_mod_status = {}
global_send_prohibited_mods = false -- The overall lobby status

local function update_global_status()
    global_send_prohibited_mods = false
    
    for peer_id, has_prohibited_mods in pairs(mod.player_mod_status) do
        if has_prohibited_mods then
            global_send_prohibited_mods = true
            break
        end
    end
    
    write_logging_mods_data()
end

local function sync_mods()
    mod:network_send(settings_sync_package_id, "others", local_send_prohibited_mods)
end

mod:network_register(settings_sync_package_id, function(sender_peer_id, received_bool)
    if received_bool ~= nil then
        mod.player_mod_status[sender_peer_id] = received_bool
        update_global_status()
    end
end)

mod.on_user_joined = function(player)
    sync_mods()
end

mod.on_user_left = function(player)
    if player and player.peer_id then
        mod.player_mod_status[player.peer_id] = nil
        update_global_status()
    end
end

-- -------------------------------------------------------------------
-- Core Initialization
-- -------------------------------------------------------------------
local check_tourney_time = function()
    local start_time = os.time(os.date("!*t", os.time(tourney_time.start_time)))
    local end_time = os.time(os.date("!*t", os.time(tourney_time.end_time)))
    local current_time = os.time(os.date("!*t"))
    
    is_tourney_time = (current_time >= start_time and current_time <= end_time)
    mod.is_tourney_time_performance_logging = is_tourney_time
end

local initiate_mod_checker = function ()
    check_tourney_time()
    render_init()
    get_user_settings()
    get_active_mods()
    check_mods()
    local_send_prohibited_mods = (#prohibited_mods > 0)
    write_logging_mods_data()

end

mod.on_all_mods_loaded = function()
    initiate_mod_checker()
end

mod.on_setting_changed = function()
    initiate_mod_checker()
end

mod.on_game_state_changed = function(status, state_name)
    initiate_mod_checker()
    
    if Managers.state.network and Managers.state.network.is_server then
        global_send_prohibited_mods = false
    end
end