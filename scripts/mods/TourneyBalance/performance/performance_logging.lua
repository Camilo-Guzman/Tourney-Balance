local mod = get_mod("TourneyBalance")

--[[

    Test of Logging Performance Data in the Console Log of the Host of the game
    All Data collection code is written by Prismism
    The Log printing and collection of basic info like time and formatting is done by Janoti!
    2025-02-20

]]

local in_keep
local in_level
local is_server

local cache
local stats
local previous_game_stats

local interval = 5 --mod:get("interval")
local next_trigger = interval

local onslaught_mod_name = "Onslaught"
local onslaughtplus_mod_name = "OnslaughtPlus"
local spicyonslaught_mod_name = "SpicyOnslaught"
local empowered_mod_name = "Empowered"
local linesman_mod_name = "Daredevil"
local dutch_mod_name = "DutchSpice"
local deathwish_mod_name = "catas"
local onslaught_squared_mutator_name = "OnslaughtSquared"
local linesman_mutator_name = "Daredevil+"

mod.start_time = nil

-- all names of the human players with indication who is the host
local function get_player_names()
    local players = Managers.player:human_players() --human_and_bot_players() if you want bots too
    local player_names = ""

    local host_name = LobbyInternal.user_name(host)

    for _, player in pairs(players) do
        local player_name = player:name()
        if host_name == player_name then
            player_name = player_name .. " (Host)"
        end
        player_names = player_names .. " | " .. player_name
    end

    return string.sub(player_names, 4)
end

-- current date and time in UTC0
local function get_time()
    -- https://www.lua.org/pil/22.1.html
    return os.date("!%d.%m.%Y %X")
end

-- save the time to a variable
local function save_start_time()
    mod.start_time = get_time()
end

-- On mission start, after cutscene ends
mod:hook_safe(CutsceneSystem, "flow_cb_deactivate_cutscene_cameras", save_start_time)


-- localize the current level_key and return it
local function get_localized_map_name()
    local game_localize = Managers.localizer
    local level_key = Managers.state.game_mode._level_key

    local display_name_reference = LevelSettings[level_key].display_name
    local localized_map_name = game_localize:_base_lookup(display_name_reference)
    
    return localized_map_name
end

-- get highest percentage value in the table
-- multiply it to be shown in decimal and reduce to three indices after comma
local function get_completion_percentage(percentages_completed)
    local percentage_completed = ""
    local percentage_number = 0

    for _, percentage in pairs(percentages_completed) do
        if percentage > percentage_number then
            percentage_number = percentage
            percentage_completed = string.sub(tostring(percentage * 100), 1, 6)
        end
    end

    return percentage_completed
end

-- figure out if Deathwish or any Onslaught Mod is turned on (credits to prismism)
-- added difficulty system for mods like Linesman and also theoretically Dense
local function is_mod_mutator_enabled(mod_name, mutator_name, difficulty_level)

    -- failsave in case the players doesnt have a mutator mod installed
    if not get_mod(mod_name) then
        return false
    end

    local other_mod = get_mod(mod_name)
    local mod_is_enabled = false
    local mutator_is_enabled = false
    local mod_difficulty_level = false

    if other_mod then
        local mutator = other_mod:persistent_table(mutator_name)
        mod_is_enabled = other_mod:is_enabled()
        mutator_is_enabled = mutator.active
        if other_mod.difficulty_level == difficulty_level then
            mod_difficulty_level = true
        end
    end
    if other_mod.difficulty_level then
        return mod_is_enabled and mutator_is_enabled and mod_difficulty_level
    else
        return mod_is_enabled and mutator_is_enabled
    end
end

-- figure out the current difficulty that is being played
local get_difficulty = function()
    local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
    local base_difficulty_name = difficulty_settings.display_name
    local base_difficulty = Localize(base_difficulty_name)

    local onslaught_mod = ""
    local deathwish_mod = ""

    if is_mod_mutator_enabled(deathwish_mod_name, deathwish_mod_name, 0) then
        deathwish_mod = " Deathwish"
    end

    if is_mod_mutator_enabled(onslaught_mod_name, onslaught_mod_name, 0) then
        onslaught_mod = " Onslaught"
    end
    if is_mod_mutator_enabled(onslaughtplus_mod_name, onslaughtplus_mod_name, 0) then
        onslaught_mod = " OnslaughtPlus"
    end
    if is_mod_mutator_enabled(linesman_mod_name, linesman_mod_name, 0) then
        onslaught_mod = " Daredevil"
    end
    if is_mod_mutator_enabled(linesman_mod_name, linesman_mutator_name, 1) then
        onslaught_mod = " Linesbaby"
    end
    if is_mod_mutator_enabled(linesman_mod_name, linesman_mutator_name, 2) then
        onslaught_mod = " Linesboy"
    end
    if is_mod_mutator_enabled(linesman_mod_name, linesman_mutator_name, 3) then
        onslaught_mod = " Linesman"
    end
    if is_mod_mutator_enabled(onslaughtplus_mod_name, onslaught_squared_mutator_name, 0) then
        onslaught_mod = " OnslaughtSquared"
    end
    if is_mod_mutator_enabled(dutch_mod_name, dutch_mod_name, 0) then
        onslaught_mod = " DutchSpicy"
    end
    if is_mod_mutator_enabled(spicyonslaught_mod_name, spicyonslaught_mod_name, 0) then
        onslaught_mod = " Spicy"
    end
    if is_mod_mutator_enabled(empowered_mod_name, empowered_mod_name, 0) then
        onslaught_mod = " Empowered"
    end

    return base_difficulty .. deathwish_mod .. onslaught_mod
end


local init_game = function()
    cache = {
        horde_enemy_ai_last_update = {},
        non_horde_enemy_ai_last_update = {},
    }
    stats = {
        t = {},
        dt = {},
        horde_enemies = {},
        non_horde_enemies = {},
        horde_enemy_ai_last_update = {},
        non_horde_enemy_ai_last_update = {},
        count = 0,
    }
    interval = 5 --mod:get("interval")
    next_trigger = interval
end

local get_in_inn = function()
    local level_key = Managers.state and Managers.state.game_mode:game_mode_key()
    return level_key and level_key:find("inn")
end
local get_in_morris_hub = function()
    local level_key = Managers.state and Managers.state.game_mode:game_mode_key()
    return level_key == "morris_hub"
end
local get_in_keep = function()
    return get_in_inn() or get_in_morris_hub()
end
local get_is_server = function()
    return Managers.player and Managers.player.is_server
end

mod:hook_safe(PerceptionUtils, "horde_pick_closest_target_with_spillover", function(ai_unit, blackboard, breed, t)
    cache.horde_enemy_ai_last_update[ai_unit] = t
end)

mod:hook_safe(PerceptionUtils, "pick_closest_target_with_spillover", function(ai_unit, blackboard, breed, t)
    cache.non_horde_enemy_ai_last_update[ai_unit] = t
end)

mod:hook_safe(DeathSystem, "kill_unit", function(self, unit, killing_blow)
	local breed = Unit.get_data(unit, "breed")
    if not breed then
        return
    end
    if not breed.is_player then
        cache.horde_enemy_ai_last_update[unit] = nil
        cache.non_horde_enemy_ai_last_update[unit] = nil
    end
end)

local get_all_enemies = function()
    local units = {}
	local ai_system = Managers.state.entity:system("ai_system")
    if not ai_system then
        return units
    end
	local broadphase = ai_system.group_blackboard.broadphase
    if not broadphase then
        return units
    end
	local entries = Broadphase.all(broadphase)
    for i,entry in ipairs(entries) do
        if entry[3] then
            table.insert(units, entry[3])
        end
    end
    return units
end

local is_horde = function(unit)
    local blackboard = BLACKBOARDS[unit]
    return blackboard and (blackboard.spawn_type == "horde" or blackboard.spawn_type == "horde_hidden")
end

local record_time = function(t, dt)
    stats.t[stats.count] = t
    stats.dt[stats.count] = dt
end

local record_enemy_counts = function()
    local enemies = get_all_enemies()
    local num_horde = 0
    local num_not_horde = 0
    for _,unit in ipairs(enemies) do
        if is_horde(unit) then
            num_horde = num_horde + 1
        else
            num_not_horde = num_not_horde + 1
        end
    end
    stats.horde_enemies[stats.count] = num_horde
    stats.non_horde_enemies[stats.count] = num_not_horde
end

local clean_out_enemy_ai_update_table = function()
    for unit,_ in pairs(cache.horde_enemy_ai_last_update) do
        if not Unit.alive(unit) then
            cache.horde_enemy_ai_last_update[unit] = nil
        end
    end
    for unit,_ in pairs(cache.non_horde_enemy_ai_last_update) do
        if not Unit.alive(unit) then
            cache.non_horde_enemy_ai_last_update[unit] = nil
        end
    end
end

local record_enemy_ai_update_times = function(t)
    local total = 0
    local count = 0
    for _,time in pairs(cache.horde_enemy_ai_last_update) do
        local to_add = t - time
        total = total + to_add
        count = count + 1
    end
    stats.horde_enemy_ai_last_update[stats.count] = (count > 0 and (total / count)) or "-"
    total = 0
    count = 0
    for _,time in pairs(cache.non_horde_enemy_ai_last_update) do
        local to_add = t - time
        total = total + to_add
        count = count + 1
    end
    stats.non_horde_enemy_ai_last_update[stats.count] = (count > 0 and (total / count)) or "-"
end

local trigger = function(dt)
    local t = Managers.time:time("game")
    stats.count = stats.count + 1
    record_time(t, dt)
    record_enemy_counts()
    clean_out_enemy_ai_update_table()
    record_enemy_ai_update_times(t)
    local s = stats
    local c = stats.count
end

mod.update = function(dt)
    if not in_level or not is_server then
        return
    end
    next_trigger = next_trigger - dt
    if next_trigger <= 0 then
        next_trigger = next_trigger + interval
        trigger(dt)
    end
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateIngame" and status == "enter" then
        is_server = get_is_server()
        in_keep = get_in_keep()
        in_level = not in_keep
        if in_keep then
            previous_game_stats = stats
        end
        init_game()
    elseif state_name == "StateLoading" and status == "enter" then
        in_level = false
    end
end

local get_recorded_data = function()
    local s = in_keep and previous_game_stats or stats
    if not s or s.count == 0 then
        return "No Performance Data Recorded"
    end

    local one_dp = 10
    local four_dp = 10000
    local round = math.round

    local output = "Time (seconds),Update Time (seconds),Number of Horde Enemies,Number of Non-Horde Enemies,Time Since Horde Enemy AI Update,Time Since Non-Horde Enemy AI Update\n"
    for i=1,s.count do
        local t = round(s.t[i]*one_dp)/one_dp
        local dt = round(s.dt[i]*four_dp)/four_dp
        local horde_enemy_ai_last_update = type(s.horde_enemy_ai_last_update[i]) == "number" and round(s.horde_enemy_ai_last_update[i]*four_dp)/four_dp or s.horde_enemy_ai_last_update[i]
        local non_horde_enemy_ai_last_update = type(s.non_horde_enemy_ai_last_update[i]) == "number" and round(s.non_horde_enemy_ai_last_update[i]*four_dp)/four_dp or s.non_horde_enemy_ai_last_update[i]
        output = output..t..","..dt..","..s.horde_enemies[i]..","..s.non_horde_enemies[i]..","..horde_enemy_ai_last_update..","..non_horde_enemy_ai_last_update.."\n"
    end

    return output
end

-- log varies data to the console log at the end of the game
local function print_performance_data_to_log(self, reason, checkpoint_available, percentages_completed)
	if reason == "won" or reason == "lost" then
    
        local players_in_party = get_player_names()
        local map_name = get_localized_map_name()
        local start_time = mod.start_time or "Finished before cutscene end - "
        local time = start_time .. " - " ..  get_time()
        local percentage_completed = get_completion_percentage(percentages_completed) or "N/A"
        local difficulty = get_difficulty() or "N/A"
        local data = get_recorded_data()

        mod:info(
            "\n"
            .. "\n"
            .. "Players,Map,Result,Time (UTC0),Difficulty,Completion"
            .. "\n" .. players_in_party .. "," .. map_name .. "," .. reason .. "," .. time .. "," .. difficulty .. "," .. percentage_completed
            .. "\n" .. data
        )

        mod.start_time = nil
	end
end

-- log varies data to the console log at the end of the game
local function print_performance_data_to_log_restart()
    local reason = "restart"
    local players_in_party = get_player_names()
    local map_name = get_localized_map_name()
    local start_time = mod.start_time or "Finished before cutscene end - "
    local time = start_time .. " - " ..  get_time()
    local percentage_completed = "N/A"
    local difficulty = get_difficulty() or "N/A"
    local data = get_recorded_data()

    mod:info(
        "\n"
        .. "\n"
        .. "Players,Map,Result,Time (UTC0),Difficulty,Completion"
        .. "\n" .. players_in_party .. "," .. map_name .. "," .. reason .. "," .. time .. "," .. difficulty .. "," .. percentage_completed
        .. "\n" .. data
    )

    mod.start_time = nil
end

-- On mission won/lost
mod:hook_safe(StateIngame, "gm_event_end_conditions_met", print_performance_data_to_log)

-- On mission restarted/won/lost
mod:hook_safe(GameModeManager, "retry_level", function (self)
    print_performance_data_to_log_restart()
end)

-- command to copy the pure data to the the players clipboard
mod:command("perf_csv", "Copy stored performance data to your clipboard in a comma-separated-values format", function()
    local s = in_keep and previous_game_stats or stats
    if not s or s.count == 0 then
        mod:echo("No performance data recorded. Clipboard not modified.")
        return
    end

    local data = get_recorded_data()
    Clipboard.put(data)

    mod:echo("Performance data (csv) copied to clipboard.")
end)