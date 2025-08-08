local mod = get_mod("TourneyBalance")

--[[

    Basic QOL features to remove the necessity of unreliable and a multitude of other mods
    Code snippets originally made by PropJoe in the mods Helpers and TrueSoloQOL

    Janoti! - 2025-08-07

]]

-- Pause.
mod.paused = false
mod.do_pause = function()
	if not Managers.player.is_server then
		mod:echo(mod:localize("not_server"))
		return
	end

	if mod.paused then
		Managers.state.debug:set_time_scale(13)
		mod.paused = false
		mod:echo(mod:localize("game_unpaused"))
	else
		Managers.state.debug:set_time_scale(1)
		mod.paused = true
		mod:echo(mod:localize("game_paused"))
	end
end
mod:command("pause", mod:localize("pause_command_description"), function() mod.do_pause() end)

-- Restart
mod.restart_level = function()
	mod:pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo(mod:localize("restart_in_keep"))
			return
		else
			if Managers.state.game_mode then
				Managers.state.game_mode:retry_level()
			end
		end
	end)
end
mod:command("restart", mod:localize("restart_level_command_description"), function() mod.restart_level() end)

-- Disable the bots.
mod:hook(GameModeAdventure, "_handle_bots",
function(func, self, ...)
	local original_cap_num_bots = script_data.cap_num_bots

	if mod:get("disable_bots") then
		script_data.cap_num_bots = 0
	end

	func(self, ...)

	script_data.cap_num_bots = original_cap_num_bots
end)
-- Prevent a crash with disabled bots.
mod:hook(AdventureSpawning, "force_update_spawn_positions", function(func, ...)
	if not mod:get("disable_bots") then
		return func(...)
	end

	pcall(func, ...)
end)