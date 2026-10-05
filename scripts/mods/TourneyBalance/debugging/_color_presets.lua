--[[

	Shared color preset list for the Stagger State Visualizer's outline-color dropdowns. RGB
	values match Colors.color_definitions (scripts/utils/colors.lua) so presets match colors
	already used elsewhere in the game rather than arbitrary picks.

	stagger_state_visualizer.lua calls resolve_color() to get its final RGB: the selected
	preset's RGB, the entry's own stock RGB when "default" is selected, or the custom R/G/B
	sliders when "custom" is selected. "default" isn't a shared preset like the other 9 - it's
	the unmodified in-game color for that specific outline, so it's passed in per call instead
	of living in PRESETS.

]]

local PRESETS = {
	{ id = "white", r = 255, 	g = 255, 	b = 255 },
	{ id = "red", 	r = 227, 	g = 4, 		b = 4 	},
	{ id = "green", r = 118, 	g = 186, 	b = 0 	},
	{ id = "blue", 	r = 30, 	g = 150, 	b = 255 },
	{ id = "ghost", r = 89, 	g = 218, 	b = 158 },
	{ id = "pink",	r = 255, 	g = 70, 	b = 130 },
	{ id = "gold", 	r = 255, 	g = 215, 	b = 0 	},
}

local PRESETS_BY_ID = {}

for _, preset in ipairs(PRESETS) do
	PRESETS_BY_ID[preset.id] = preset
end

local function resolve_color(dropdown_setting_id, r_setting_id, g_setting_id, b_setting_id, default_r, default_g, default_b)
	local mod = get_mod("TourneyBalance")
	local selected = mod:get(dropdown_setting_id)

	if selected == "default" then
		return default_r, default_g, default_b
	end

	local preset = PRESETS_BY_ID[selected]

	if preset then
		return preset.r, preset.g, preset.b
	end

	return mod:get(r_setting_id), mod:get(g_setting_id), mod:get(b_setting_id)
end

return {
	presets = PRESETS,
	resolve_color = resolve_color,
}
