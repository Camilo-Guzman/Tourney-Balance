local mod = get_mod("TourneyBalance")

return {
	name = mod:localize("mod_name"),
	is_togglable = false,
	description = mod:localize("mod_description"),
	options = {
		widgets = {
			{
				setting_id = "tourney_checks",
				type = "group",
				sub_widgets = {
					{
						setting_id = "tourney_mode",
						type = "checkbox",
						title = "tourney_mode_title",
						tootlip = "tourney_mode_description",
						default_value = false,
					},
					{
						setting_id = "tourney_display_mods",
						type = "checkbox",
						title = "tourney_display_mods_title",
						tootlip = "tourney_display_mods_description",
						default_value = false,
					},
				},
			},
			{
				setting_id = "qol",
				type = "group",
				sub_widgets = {
					{
						type = "checkbox",
						setting_id = "disable_bots",
						default_value = true,
						title = "disable_bots_title",
						tooltip = "disable_bots_description",
					},
					{
						setting_id = "pause",
						type = "keybind",
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						function_name = "do_pause",
						title = "pause_title",
						tooltip = "pause_description",
						default_value = {},
					},
					{
						setting_id = "restart",
						type = "keybind",
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						function_name = "restart_level",
						title = "restart_title",
						tooltip = "restart_description",
						default_value = {},
					},
				},
			},
			{
				type = "checkbox",
				setting_id = "performance_logging",
				default_value = false,
				title = "performance_logging_title",
				tooltip = "performance_logging_description",
			},
		}
	}
}
