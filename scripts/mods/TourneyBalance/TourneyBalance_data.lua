local mod = get_mod("TourneyBalance")

-- Builds a "preset dropdown + custom R/G/B sliders" widget. Every color group in the
-- Stagger State Visualizer's outline colors shares the same Default + presets (from
-- debugging/_color_presets.lua) + Custom; selecting Default or a preset hides the sliders
-- (show_widgets omitted), selecting Custom reveals them (show_widgets = {1, 2, 3}). Default
-- resolves to that entry's own stock in-game RGB (r_default/g_default/b_default), passed to
-- color_presets.resolve_color at the call site.
local function color_picker_widget(setting_id, r_setting_id, g_setting_id, b_setting_id, r_default, g_default, b_default)
	return {
		setting_id = setting_id,
		type = "dropdown",
		title = setting_id,
		default_value = "default",
		options = {
			{ text = "tb_color_preset_default_title", value = "default" },
			{ text = "tb_color_preset_white_title", value = "white" },
			{ text = "tb_color_preset_red_title", value = "red" },
			{ text = "tb_color_preset_green_title", value = "green" },
			{ text = "tb_color_preset_blue_title", value = "blue" },
			{ text = "tb_color_preset_ghost_title", value = "ghost" },
			{ text = "tb_color_preset_pink_title", value = "pink" },
			{ text = "tb_color_preset_gold_title", value = "gold" },
			{ text = "tb_color_preset_custom_title", value = "custom", show_widgets = {1, 2, 3} },
		},
		sub_widgets = {
			{
				type = "numeric",
				setting_id = r_setting_id,
				default_value = r_default,
				range = {0, 255},
				decimals_number = 0,
				title = r_setting_id .. "_title",
				tooltip = r_setting_id .. "_description",
			},
			{
				type = "numeric",
				setting_id = g_setting_id,
				default_value = g_default,
				range = {0, 255},
				decimals_number = 0,
				title = g_setting_id .. "_title",
				tooltip = g_setting_id .. "_description",
			},
			{
				type = "numeric",
				setting_id = b_setting_id,
				default_value = b_default,
				range = {0, 255},
				decimals_number = 0,
				title = b_setting_id .. "_title",
				tooltip = b_setting_id .. "_description",
			},
		},
	}
end

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
			{
				setting_id = "fun_features",
				type = "group",
				sub_widgets = {
					{
						type = "checkbox",
						setting_id = "jump_cancel_dodges",
						default_value = false,
						title = "jump_cancel_dodges_title",
						tooltip = "jump_cancel_dodges_description",
					},
					{
						type = "checkbox",
						setting_id = "jump_cancel_dashes",
						default_value = false,
						title = "jump_cancel_dashes_title",
						tooltip = "jump_cancel_dashes_description",
					},
				},
			},
			{
				setting_id = "debugging",
				type = "group",
				sub_widgets = {
					{
						setting_id = "stagger_state_visualizer_group",
						type = "group",
						sub_widgets = {
							{
								type = "checkbox",
								setting_id = "stagger_state_visualizer",
								default_value = false,
								title = "stagger_state_visualizer_title",
								tooltip = "stagger_state_visualizer_description",
							},
							{
								type = "checkbox",
								setting_id = "stagger_state_visualizer_include_real",
								default_value = false,
								title = "stagger_state_visualizer_include_real_title",
								tooltip = "stagger_state_visualizer_include_real_description",
							},
							{
								type = "checkbox",
								setting_id = "stagger_state_visualizer_include_mainstay",
								default_value = false,
								title = "stagger_state_visualizer_include_mainstay_title",
								tooltip = "stagger_state_visualizer_include_mainstay_description",
							},
							{
								type = "checkbox",
								setting_id = "stagger_state_visualizer_include_tank",
								default_value = false,
								title = "stagger_state_visualizer_include_tank_title",
								tooltip = "stagger_state_visualizer_include_tank_description",
							},
							{
								setting_id = "outline_colors_stagger_state_visualizer",
								type = "group",
								sub_widgets = {
									color_picker_widget("tb_stagger_count_1_color_group", "tb_stagger_count_1_color_r", "tb_stagger_count_1_color_g", "tb_stagger_count_1_color_b", 0, 255, 0),
									color_picker_widget("tb_stagger_count_2_color_group", "tb_stagger_count_2_color_r", "tb_stagger_count_2_color_g", "tb_stagger_count_2_color_b", 255, 255, 0),
									color_picker_widget("tb_stagger_count_3_color_group", "tb_stagger_count_3_color_r", "tb_stagger_count_3_color_g", "tb_stagger_count_3_color_b", 255, 0, 0),
								},
							},
						},
					},
				},
			},
		}
	}
}
