--[[
	Weapon editor: the Imgui window.

	Every widget label ends in "##<full path>" so identically named fields in different
	tables (attack/impact, target 1/target 2, ...) stay separate Imgui items.

	Numbers are only written when Imgui.input_float reports a change: it returns float32
	values, so writing back every frame would silently round every visible field.
]]

local core = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_core")

local ui = {}

local ITEM_WIDTH = 160
local SEARCH_WIDTH = 280
local MAX_SEARCH_RESULTS = 40
local EDITED_COLOR = { 255, 200, 80, 255 }
local WARNING_COLOR = { 255, 120, 90, 255 }
local INFO_COLOR = { 150, 200, 255, 255 }

--[[
	Dropdown lists for string fields with a known set of values
]]

local dropdowns = {}

local function build_dropdown(key)
	local names = nil

	if key == "attack_template" then
		names = table.keys(AttackTemplates)
	elseif key == "boost_curve_type" then
		names = table.keys(BoostCurves)
	elseif key:find("damage_profile", 1, true) then
		names = {}

		for name in pairs(DamageProfileTemplates) do
			if not name:find("_no_damage$") then
				names[#names + 1] = name
			end
		end
	elseif key == "charge_value" then
		local seen = {}

		names = {}

		for _, profile in pairs(DamageProfileTemplates) do
			local value = type(profile) == "table" and profile.charge_value

			if type(value) == "string" and not seen[value] then
				seen[value] = true
				names[#names + 1] = value
			end
		end
	end

	if not names then
		return false
	end

	table.sort(names)

	local index_of = {}

	for i, name in ipairs(names) do
		index_of[name] = i
	end

	return {
		names = names,
		index_of = index_of,
	}
end

local function dropdown_for(key)
	if type(key) ~= "string" then
		return nil
	end

	if dropdowns[key] == nil then
		dropdowns[key] = build_dropdown(key)
	end

	return dropdowns[key] or nil
end

--[[
	Helpers
]]

local function text_colored(text, color)
	Imgui.text_colored(text, color[1], color[2], color[3], color[4])
end

local function apply(editor, keys, value)
	local ok, err = editor.apply_edit(keys, value)

	if not ok then
		editor.report("Edit rejected (%s): %s", core.format_path(keys), err)
	end
end

local function has_edit_under(editor, path)
	for edit_path in pairs(editor.state.edits) do
		if core.path_is_under(edit_path, path) then
			return true
		end
	end

	return false
end

-- A tb_ profile has no vanilla twin of the same name: compare against the profile the
-- actions now using it pointed at before TourneyBalance
local function vanilla_counterpart(editor, profile_name)
	local s = editor.ui_state

	s.counterparts = s.counterparts or {}

	if s.counterparts[profile_name] == nil then
		local counterpart = false

		if editor.state.vanilla.DamageProfileTemplates[profile_name] then
			counterpart = profile_name
		else
			for _, user in ipairs(editor.profile_users(profile_name)) do
				if type(user.vanilla_profile) == "string" and user.vanilla_profile ~= profile_name then
					counterpart = user.vanilla_profile

					break
				end
			end
		end

		s.counterparts[profile_name] = counterpart
	end

	return s.counterparts[profile_name] or nil
end

local function vanilla_value_for(editor, keys)
	if keys[1] == "DamageProfileTemplates" then
		local counterpart = vanilla_counterpart(editor, keys[2])

		if not counterpart then
			return nil, nil
		end

		local counterpart_keys = { "DamageProfileTemplates", counterpart }

		for i = 3, #keys do
			counterpart_keys[#counterpart_keys + 1] = keys[i]
		end

		return core.snapshot_value(editor.state.vanilla, counterpart_keys), counterpart
	end

	return core.snapshot_value(editor.state.vanilla, keys), nil
end

local function draw_edit_marker(editor, keys, path)
	local edit = editor.state.edits[path]

	if not edit then
		return
	end

	local vanilla_value, counterpart = vanilla_value_for(editor, keys)
	local vanilla_label = counterpart and counterpart ~= keys[2] and ("vanilla (" .. counterpart .. ")") or "vanilla"

	Imgui.same_line()
	text_colored(string.format("TB %s | %s %s", core.format_value(edit.baseline), vanilla_label, core.format_value(vanilla_value)), EDITED_COLOR)
	Imgui.same_line()

	if Imgui.small_button("revert##" .. path) then
		editor.revert_edit(path)
	end
end

local function draw_string_field(editor, key, value, keys, path)
	local label = tostring(key) .. "##" .. path
	local dropdown = dropdown_for(key)
	local index = dropdown and dropdown.index_of[value]

	if index then
		local new_index = Imgui.combo(label, index, dropdown.names)

		if new_index ~= index and dropdown.names[new_index] then
			apply(editor, keys, dropdown.names[new_index])
		end

		return
	end

	-- Free text is buffered and only applied on the button: a half-typed anim event or
	-- template name would otherwise be live on the next swing
	local buffers = editor.ui_state.text_buffers

	if not buffers then
		buffers = {}
		editor.ui_state.text_buffers = buffers
	end

	local buffer = Imgui.input_text(label, buffers[path] or value)

	if buffer == value then
		buffers[path] = nil
	else
		buffers[path] = buffer

		Imgui.same_line()

		if Imgui.small_button("apply##" .. path) then
			buffers[path] = nil

			apply(editor, keys, buffer)
		end
	end
end

local draw_profile

local function edit_table(editor, t, keys, skip_keys)
	for _, key in ipairs(core.sorted_keys(t)) do
		if not (skip_keys and skip_keys[key]) then
			local value = t[key]
			local value_type = type(value)
			local child_keys = core.append_key(keys, key)
			local path = core.format_path(child_keys)
			local name = tostring(key)

			if value_type == "table" then
				local preset = keys[1] == "DamageProfileTemplates" and editor.preset_name(value)
				local label = name

				if preset then
					label = label .. "  (preset " .. preset .. ")"
				end

				if has_edit_under(editor, path) then
					label = label .. "  *"
				end

				if Imgui.tree_node(label .. "##" .. path) then
					edit_table(editor, value, child_keys)
					Imgui.tree_pop()
				end
			elseif value_type == "number" then
				local new_value, changed = Imgui.input_float(name .. "##" .. path, value)

				if changed then
					apply(editor, child_keys, core.round_input(new_value))
				end
			elseif value_type == "boolean" then
				local new_value = Imgui.checkbox(name .. "##" .. path, value)

				if new_value ~= value then
					apply(editor, child_keys, new_value)
				end
			elseif value_type == "string" then
				draw_string_field(editor, key, value, child_keys, path)
			else
				Imgui.text(name .. ": <" .. value_type .. ">")
			end

			if value_type ~= "table" then
				draw_edit_marker(editor, child_keys, path)
			end

			-- Fields naming a damage profile open that profile right below them
			if value_type == "string" and name:find("damage_profile", 1, true) and DamageProfileTemplates[value] then
				if Imgui.tree_node("profile " .. value .. "##open" .. path) then
					draw_profile(editor, value)
					Imgui.tree_pop()
				end
			end
		end
	end
end

draw_profile = function (editor, profile_name)
	local is_tb_profile = NewDamageProfileTemplates[profile_name] ~= nil
	local counterpart = vanilla_counterpart(editor, profile_name)

	if is_tb_profile then
		text_colored(string.format("TB profile - exports as a whole NewDamageProfileTemplates block (vanilla: %s)", counterpart or "none"), INFO_COLOR)
	else
		text_colored("Vanilla profile - shared presets are copied into it on first edit", INFO_COLOR)
	end

	local profile_path = "DamageProfileTemplates." .. profile_name

	if has_edit_under(editor, profile_path) then
		Imgui.same_line()

		if Imgui.small_button("revert profile##" .. profile_path) then
			editor.revert_profile(profile_name)
		end
	end

	edit_table(editor, DamageProfileTemplates[profile_name], { "DamageProfileTemplates", profile_name })
end

--[[
	Sections
]]

local function draw_template_picker(editor)
	local s = editor.ui_state

	if Imgui.button("Wielded weapon") then
		editor.select_wielded()
	end

	Imgui.same_line()
	Imgui.push_item_width(SEARCH_WIDTH)

	s.filter = Imgui.input_text("Search templates##template_filter", s.filter or "")

	Imgui.pop_item_width()

	if s.filter == "" then
		return
	end

	if s.filter ~= s.last_filter then
		local needle = s.filter:lower()
		local results = {}

		for template_name, template in pairs(Weapons) do
			if type(template) == "table" and template_name:lower():find(needle, 1, true) then
				results[#results + 1] = template_name
			end
		end

		table.sort(results)

		for i = #results, MAX_SEARCH_RESULTS + 1, -1 do
			results[i] = nil
		end

		s.results = results
		s.last_filter = s.filter
	end

	if #s.results > 0 then
		local picked = Imgui.list_box("##template_results", 0, s.results, 8)

		if picked and picked > 0 and s.results[picked] then
			editor.select_template(s.results[picked])

			s.filter = ""
		end
	else
		Imgui.text("No matching templates.")
	end
end

local function sub_action_profiles(sub_action)
	local names = {}

	local function scan(t, depth)
		for k, v in pairs(t) do
			if type(k) == "string" and type(v) == "string" and k:find("damage_profile", 1, true) then
				names[#names + 1] = v
			elseif type(v) == "table" and depth < 2 and not core.EXCLUDED_KEYS[k] then
				scan(v, depth + 1)
			end
		end
	end

	scan(sub_action, 1)
	table.sort(names)

	return names
end

local function draw_template(editor, template_name)
	local template = Weapons[template_name]
	local template_keys = { "Weapons", template_name }

	Imgui.text("Template: " .. template_name)

	if has_edit_under(editor, "Weapons." .. template_name) then
		Imgui.same_line()

		if Imgui.small_button("revert weapon##revert_template") then
			editor.revert_template(template_name)
		end
	end

	local actions = template.actions

	if type(actions) == "table" and Imgui.tree_node("actions##" .. template_name, true) then
		for _, action_name in ipairs(core.sorted_keys(actions)) do
			local action = actions[action_name]
			local action_keys = { "Weapons", template_name, "actions", action_name }
			local action_path = core.format_path(action_keys)

			if type(action) == "table" and Imgui.tree_node(action_name .. (has_edit_under(editor, action_path) and "  *" or "") .. "##" .. action_path) then
				for _, sub_action_name in ipairs(core.sorted_keys(action)) do
					local sub_action = action[sub_action_name]

					if type(sub_action) == "table" then
						local sub_keys = core.append_key(action_keys, sub_action_name)
						local sub_path = core.format_path(sub_keys)
						local profiles = sub_action_profiles(sub_action)
						local label = sub_action_name

						if #profiles > 0 then
							label = label .. "  [" .. table.concat(profiles, ", ") .. "]"
						end

						if has_edit_under(editor, sub_path) then
							label = label .. "  *"
						end

						if Imgui.tree_node(label .. "##" .. sub_path) then
							if #profiles > 0 and Imgui.small_button("breakpoints##bp" .. sub_path) then
								editor.show_breakpoints(sub_keys)
							end

							local others = editor.weapon_sharing(sub_action, template_name)

							if others then
								text_colored("Shared table - edits also change: " .. table.concat(others, ", "), WARNING_COLOR)
							end

							edit_table(editor, sub_action, sub_keys)
							Imgui.tree_pop()
						end
					end
				end

				Imgui.tree_pop()
			end
		end

		Imgui.tree_pop()
	end

	if Imgui.tree_node("other template fields##" .. template_name) then
		edit_table(editor, template, template_keys, {
			actions = true,
		})
		Imgui.tree_pop()
	end
end

local function draw_edit_list(editor)
	local edits = editor.state.edits
	local paths = {}

	for path in pairs(edits) do
		paths[#paths + 1] = path
	end

	table.sort(paths)

	if Imgui.collapsing_header(string.format("All edits (%d)##edit_list", #paths), false) then
		for _, path in ipairs(paths) do
			local edit = edits[path]

			if Imgui.small_button("revert##list" .. path) then
				editor.revert_edit(path)
			end

			Imgui.same_line()
			Imgui.text(string.format("%s = %s (TB %s)", path, core.format_value(edit.value), core.format_value(edit.baseline)))
		end
	end
end

local function draw_body(editor)
	if Imgui.begin_menu_bar() then
		if Imgui.menu_item("Export to clipboard") then
			editor.export()
		end

		if Imgui.menu_item("Breakpoints") then
			editor.toggle_breakpoints()
		end

		if Imgui.menu_item("Revert all") then
			editor.report("Reverted %d edit(s).", editor.revert_all())
		end

		Imgui.end_menu_bar()
	end

	Imgui.text(string.format("%d edit(s) | F3: %s", editor.edit_count(), editor.interacting and "editing - press to play" or "playing - press to edit"))
	Imgui.push_item_width(ITEM_WIDTH)

	draw_template_picker(editor)
	Imgui.separator()

	if editor.selected_template and Weapons[editor.selected_template] then
		draw_template(editor, editor.selected_template)
	else
		Imgui.text("No template selected.")
	end

	Imgui.separator()
	draw_edit_list(editor)
	Imgui.pop_item_width()
end

-- Returns true when the window should close. The body runs in a pcall so end_window is
-- always reached - an error between begin/end would leave Imgui's window stack broken.
function ui.draw(editor)
	local do_close = Imgui.begin_window("TB Weapon Editor", "menu_bar")

	Imgui.set_window_size(760, 860, "once")

	local ok, err = pcall(draw_body, editor)

	Imgui.end_window()

	if not ok then
		error(err, 0)
	end

	return do_close
end

return ui
