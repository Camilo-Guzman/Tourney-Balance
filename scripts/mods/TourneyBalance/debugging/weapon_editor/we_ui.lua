--[[
	Weapon editor: the Imgui window.

	Every widget label ends in "##<full path>" so identically named fields in different
	tables (attack/impact, target 1/target 2, ...) stay separate Imgui items.

	Values are only written when the user actually changes a field - never echoed back
	every frame - so browsing can't alter anything. Numbers are edited as text (see
	draw_number_field) to avoid Imgui.input_float's 3-decimal display and float32 rounding.
]]

local core = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_core")

local ui = {}

local ITEM_WIDTH = 160
local SEARCH_WIDTH = 280
local MAX_SEARCH_RESULTS = 40
local SEARCH_SOURCES = {
	{
		root = "Weapons",
		prefix = "",
	},
	{
		root = "ExplosionTemplates",
		prefix = "[explosion] ",
	},
	{
		root = "SpreadTemplates",
		prefix = "[spread] ",
	},
}
local EDITED_COLOR = { 255, 200, 80, 255 }
local WARNING_COLOR = { 255, 120, 90, 255 }
local INFO_COLOR = { 150, 200, 255, 255 }

--[[
	Dropdown lists for string fields with a known set of values
]]

local dropdowns = {}

-- String fields that name an entry of another editable global (opened in place, like profiles)
local LINKED_GLOBALS = {
	explosion_template = "ExplosionTemplates",
	aoe = "ExplosionTemplates",
	aoe_name = "ExplosionTemplates",
	default_spread_template = "SpreadTemplates",
	spread_template_override = "SpreadTemplates",
	spread_template = "SpreadTemplates",
}

local function build_dropdown(key)
	local names = nil

	if LINKED_GLOBALS[key] then
		names = {}

		for name, entry in pairs(rawget(_G, LINKED_GLOBALS[key]) or {}) do
			if type(entry) == "table" then
				names[#names + 1] = name
			end
		end
	elseif key == "attack_template" then
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

local function report_result(editor, keys, ok, err)
	if not ok then
		editor.report("Edit rejected (%s): %s", core.format_path(keys), err)
	end
end

local function apply(editor, keys, value)
	report_result(editor, keys, editor.apply_edit(keys, value))
end

local function set_table(editor, keys, value)
	report_result(editor, keys, editor.set_table(keys, value))
end

local function remove_field(editor, keys)
	report_result(editor, keys, editor.remove_field(keys))
end

--[[
	Structure edits (structure mode): add/remove fields, add/remove/duplicate/move array entries.
	Array changes rewrite the whole array as one "table" edit, so entry indices stay consistent.
]]

-- Tables that are lists even while empty
local ARRAY_KEYS = {
	targets = true,
	allowed_chain_actions = true,
}

local function is_array(t, key)
	return core.is_sequence(t) or (next(t) == nil and ARRAY_KEYS[key] == true)
end

local function rewrite_array(editor, keys, change)
	local live = core.live_value(keys)

	if type(live) ~= "table" then
		return
	end

	local array = core.deep_copy(live)

	change(array)
	set_table(editor, keys, array)
end

-- What a new entry of an (possibly empty) array starts as
local function new_array_entry(array, keys)
	if #array > 0 then
		return core.deep_copy(array[#array])
	end

	local key = keys[#keys]

	if key == "targets" then
		local profile = core.live_value(core.sub_keys(keys, #keys - 1))

		return core.deep_copy(type(profile) == "table" and type(profile.default_target) == "table" and profile.default_target or {})
	elseif key == "allowed_chain_actions" then
		return {
			action = "action_one",
			input = "action_one",
			start_time = 0,
			sub_action = "default",
		}
	end

	return {}
end

-- "+ field" input: number, true/false, {} for an empty table, anything else a string
local function parse_new_value(text)
	local number = tonumber(text)

	if number then
		return number
	elseif text == "true" then
		return true
	elseif text == "false" then
		return false
	elseif text:match("^%s*{%s*}%s*$") then
		return {}
	end

	return (text:gsub("^\"(.*)\"$", "%1"))
end

--[[
	Per-frame caches. The tree is redrawn every frame, so anything derived from the edit list or
	from table structure is built once and reused until editor.edit_generation changes (every
	edit and revert bumps it; structure only changes through edits). Tied to the editor table
	too: this module survives a hot reload, the editor (and its generation counter) doesn't.
]]

local cache_owner, cache_generation = nil, nil
local edited_prefixes = {} -- path of every edit and every table above one -> true
local removed_by_parent = {} -- parent path -> { { path, name } } for removed fields
local field_entries_cache = {} -- table -> parent path -> sorted { key, keys, path }
local profile_users_cache = {} -- profile name -> editor.profile_users result
local sub_action_profiles_cache = {} -- sub-action table -> sorted profile names

local function refresh_caches(editor)
	if cache_owner == editor and cache_generation == editor.edit_generation then
		return
	end

	cache_owner, cache_generation = editor, editor.edit_generation
	edited_prefixes, removed_by_parent, profile_users_cache = {}, {}, {}
	field_entries_cache = setmetatable({}, {
		__mode = "k",
	})
	sub_action_profiles_cache = setmetatable({}, {
		__mode = "k",
	})

	for path, edit in pairs(editor.state.edits) do
		for last_index = 2, #edit.keys do
			edited_prefixes[core.format_path(edit.keys, nil, last_index)] = true
		end

		if edit.kind == "removed" then
			local parent_path = core.format_path(edit.keys, nil, #edit.keys - 1)
			local list = removed_by_parent[parent_path] or {}

			list[#list + 1] = {
				path = path,
				name = tostring(edit.keys[#edit.keys]),
			}
			removed_by_parent[parent_path] = list
		end
	end
end

-- True when `path` itself or anything below it is edited
local function has_edit_under(editor, path)
	refresh_caches(editor)

	return edited_prefixes[path] == true
end

-- A table's fields in display order, with each child's key path and path string precomputed.
-- Keyed by parent path too: the same table can show up under several paths (a shared preset,
-- a linked explosion).
local function field_entries(editor, t, keys, parent_path)
	refresh_caches(editor)

	local by_parent = field_entries_cache[t]

	if not by_parent then
		by_parent = {}
		field_entries_cache[t] = by_parent
	end

	local entries = by_parent[parent_path]

	if not entries then
		entries = {}

		for i, key in ipairs(core.sorted_keys(t)) do
			local child_keys = core.append_key(keys, key)

			entries[i] = {
				key = key,
				keys = child_keys,
				path = core.format_path(child_keys),
			}
		end

		by_parent[parent_path] = entries
	end

	return entries
end

local function cached_profile_users(editor, profile_name)
	refresh_caches(editor)

	local users = profile_users_cache[profile_name]

	if not users then
		users = editor.profile_users(profile_name)
		profile_users_cache[profile_name] = users
	end

	return users
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

-- Numbers are edited as text showing the exact value: Imgui.input_float only displays
-- 3 decimals (0.0625 -> 0.063) and hands back float32 values (0.225 -> 0.2249999940...).
-- A typed value is applied as soon as it parses, and kept as typed ("0.", "-") until it does.
local function draw_number_field(editor, id, value, keys, path)
	local buffers = editor.ui_state.number_buffers

	if not buffers then
		buffers = {}
		editor.ui_state.number_buffers = buffers
	end

	local entry = buffers[path]

	-- Changed from elsewhere (revert, another view of the same field): drop the typed text
	if entry and not core.values_equal(entry.value, value) then
		entry = nil
		buffers[path] = nil
	end

	local shown = entry and entry.text or core.format_value(value)
	local text = Imgui.input_text(id, shown)

	if text ~= shown then
		local number = tonumber(text)

		entry = {
			text = text,
			value = value,
		}
		buffers[path] = entry

		if number and number == number and not core.values_equal(number, value) then
			apply(editor, keys, number)

			entry.value = number
		end
	end

	if entry and entry.text == core.format_value(entry.value) then
		buffers[path] = nil
	end
end

local draw_profile

-- An explosion-template-shaped table inside a weapon is either the global entry itself
-- ("linked") or the weapon's own table.clone copy ("copy"), whose immediate blast ignores
-- edits to the global
local function explosion_link_state(value, parent_keys)
	if parent_keys[1] ~= "Weapons" or type(value.name) ~= "string" or not (value.explosion or value.aoe) then
		return nil
	end

	local global = ExplosionTemplates[value.name]

	if type(global) ~= "table" then
		return nil
	end

	return value == global and "linked" or "copy", value.name
end

local function draw_structure_buttons(editor, t, keys, key, child_keys, path, parent_is_array)
	if not editor.ui_state.structure_mode then
		return
	end

	if parent_is_array then
		Imgui.same_line()

		if Imgui.small_button("dup##dup" .. path) then
			rewrite_array(editor, keys, function (array)
				table.insert(array, key + 1, core.deep_copy(array[key]))
			end)
		end

		if key > 1 then
			Imgui.same_line()

			if Imgui.small_button("up##up" .. path) then
				rewrite_array(editor, keys, function (array)
					array[key], array[key - 1] = array[key - 1], array[key]
				end)
			end
		end

		if key < #t then
			Imgui.same_line()

			if Imgui.small_button("down##down" .. path) then
				rewrite_array(editor, keys, function (array)
					array[key], array[key + 1] = array[key + 1], array[key]
				end)
			end
		end

		Imgui.same_line()

		if Imgui.small_button("x##rm" .. path) then
			rewrite_array(editor, keys, function (array)
				table.remove(array, key)
			end)
		end
	else
		Imgui.same_line()

		if Imgui.small_button("x##rm" .. path) then
			remove_field(editor, child_keys)
		end
	end
end

-- Fields removed by an edit no longer exist in the table, so list them for reverting
local function draw_removed_fields(editor, parent_path)
	refresh_caches(editor)

	for _, removed in ipairs(removed_by_parent[parent_path] or {}) do
		text_colored(removed.name .. " (removed)", WARNING_COLOR)
		Imgui.same_line()

		if Imgui.small_button("revert##removed" .. removed.path) then
			editor.revert_edit(removed.path)
		end
	end
end

local function draw_add_controls(editor, t, keys)
	if not editor.ui_state.structure_mode then
		return
	end

	local path = core.format_path(keys)

	if is_array(t, keys[#keys]) then
		if Imgui.small_button("+ entry##add" .. path) then
			rewrite_array(editor, keys, function (array)
				array[#array + 1] = new_array_entry(array, keys)
			end)
		end

		return
	end

	local s = editor.ui_state

	s.new_fields = s.new_fields or {}

	local form = s.new_fields[path] or {
		name = "",
		value = "",
	}

	s.new_fields[path] = form

	Imgui.push_item_width(120)

	form.name = Imgui.input_text("##new_name" .. path, form.name)

	Imgui.same_line()

	form.value = Imgui.input_text("##new_value" .. path, form.value)

	Imgui.pop_item_width()
	Imgui.same_line()

	if Imgui.small_button("+ field (name, value: number / true / false / text / {})##add" .. path) then
		if not form.name:match("^[%a_][%w_]*$") then
			editor.report("Field name must be letters, digits and _ (not starting with a digit).")
		elseif t[form.name] ~= nil then
			editor.report("%s already has a field %s.", path, form.name)
		else
			local value = parse_new_value(form.value)
			local new_keys = core.append_key(keys, form.name)

			if type(value) == "table" then
				set_table(editor, new_keys, value)
			else
				apply(editor, new_keys, value)
			end

			s.new_fields[path] = nil
		end
	end
end

local function edit_table(editor, t, keys, skip_keys)
	local parent_is_array = is_array(t, keys[#keys])
	local parent_path = core.format_path(keys)

	for _, entry in ipairs(field_entries(editor, t, keys, parent_path)) do
		local key = entry.key

		if not (skip_keys and skip_keys[key]) then
			local value = t[key]
			local value_type = type(value)
			local child_keys = entry.keys
			local path = entry.path
			local name = tostring(key)

			if value_type == "table" then
				local preset = keys[1] == "DamageProfileTemplates" and editor.preset_name(value)
				local link_state, link_name = explosion_link_state(value, keys)
				local node_keys = child_keys
				local label = name

				if preset then
					label = label .. "  (preset " .. preset .. ")"
				end

				if link_state == "linked" then
					-- The global itself: edit (and export) it under its own path
					node_keys = { "ExplosionTemplates", link_name }
					label = label .. "  -> ExplosionTemplates." .. link_name
				elseif link_state == "copy" then
					label = label .. "  (own copy of ExplosionTemplates." .. link_name .. ")"
				end

				if has_edit_under(editor, path) or has_edit_under(editor, core.format_path(node_keys)) then
					label = label .. "  *"
				end

				local open = Imgui.tree_node(label .. "##" .. path)

				if link_state == "copy" then
					Imgui.same_line()

					if Imgui.small_button("link to global##link" .. path) then
						report_result(editor, child_keys, editor.link_global(child_keys, "ExplosionTemplates." .. link_name))
					end
				end

				if editor.state.edits[path] then
					Imgui.same_line()
					text_colored(core.describe_edit(editor.state.edits[path]), EDITED_COLOR)
					Imgui.same_line()

					if Imgui.small_button("revert##table" .. path) then
						editor.revert_edit(path)
					end
				end

				draw_structure_buttons(editor, t, keys, key, child_keys, path, parent_is_array)

				if open then
					edit_table(editor, core.live_value(node_keys) or value, node_keys)
					Imgui.tree_pop()
				end
			elseif value_type == "number" then
				draw_number_field(editor, name .. "##" .. path, value, child_keys, path)
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
				draw_structure_buttons(editor, t, keys, key, child_keys, path, parent_is_array)
			end

			-- Fields naming a damage profile open that profile right below them
			if value_type == "string" and name:find("damage_profile", 1, true) and DamageProfileTemplates[value] then
				if Imgui.tree_node("profile " .. value .. "##open" .. path) then
					draw_profile(editor, value, child_keys)
					Imgui.tree_pop()
				end
			end

			-- Same for fields naming an explosion or spread template
			local linked_root = value_type == "string" and LINKED_GLOBALS[key]
			local linked_entries = linked_root and rawget(_G, linked_root)

			if linked_entries and type(linked_entries[value]) == "table" then
				if Imgui.tree_node(linked_root .. "." .. value .. "##open" .. path) then
					text_colored("Shared by everything using it - exports as " .. linked_root .. " lines", INFO_COLOR)
					edit_table(editor, linked_entries[value], { linked_root, value })
					Imgui.tree_pop()
				end
			end
		end
	end

	draw_removed_fields(editor, parent_path)
	draw_add_controls(editor, t, keys)
end

--[[
	Attack sheet: the fields that matter for tuning, one column per target, armor types named
]]

local SHEET_CELL_WIDTH = 85
local ARMOR_NAMES = { "infantry", "armored", "monster", "player", "berserker", "super armor" }
local SHEET_TOP_FIELDS = { "charge_value", "melee_boost_override", "shield_break", "no_stagger_damage_reduction", "no_stagger_damage_reduction_ranged" }
local SHEET_TARGET_ROWS = {
	{ "power: attack", { "power_distribution", "attack" } },
	{ "power: impact", { "power_distribution", "impact" } },
	{ "attack template", { "attack_template" } },
	{ "boost curve", { "boost_curve_type" } },
	{ "boost coefficient", { "boost_curve_coefficient" } },
	{ "headshot coefficient", { "boost_curve_coefficient_headshot" } },
	{ "headshot boost (boss)", { "headshot_boost_boss" } },
}

-- What a missing sheet field is added as (structure mode "+"): the value the game assumes
-- when it's absent, or for strings the profile's default_target value
local SHEET_ADD_DEFAULTS = {
	boost_curve_coefficient = 1,
	boost_curve_coefficient_headshot = 1,
	headshot_boost_boss = 0,
	melee_boost_override = 1,
	attack = 0,
	impact = 0,
}

local function sheet_add_default(editor, keys)
	local key = keys[#keys]

	if SHEET_ADD_DEFAULTS[key] ~= nil then
		return SHEET_ADD_DEFAULTS[key]
	end

	local profile = DamageProfileTemplates[keys[2]]
	local default_value = profile and type(profile.default_target) == "table" and profile.default_target[key]

	if type(default_value) ~= "table" and default_value ~= nil then
		return default_value
	end

	local dropdown = dropdown_for(key)

	return dropdown and dropdown.names[1] or nil
end

-- One editable value inside a sheet. relative_keys are walked from `root` (whose path is root_keys).
local function sheet_cell(editor, root, root_keys, relative_keys)
	local keys = root_keys

	for _, key in ipairs(relative_keys) do
		keys = core.append_key(keys, key)
	end

	-- The table that would hold the value; nil when something above it is missing too
	local parent = root

	for i = 1, #relative_keys - 1 do
		parent = type(parent) == "table" and parent[relative_keys[i]] or nil
	end

	local value = type(parent) == "table" and parent[relative_keys[#relative_keys]] or nil
	local path = core.format_path(keys)
	local id = "##sheet" .. path
	local value_type = type(value)

	Imgui.push_item_width(SHEET_CELL_WIDTH)

	if value_type == "number" then
		draw_number_field(editor, id, value, keys, path)
	elseif value_type == "boolean" then
		local new_value = Imgui.checkbox(id, value)

		if new_value ~= value then
			apply(editor, keys, new_value)
		end
	elseif value_type == "string" then
		local dropdown = dropdown_for(keys[#keys])
		local index = dropdown and dropdown.index_of[value]

		if index then
			local new_index = Imgui.combo(id, index, dropdown.names)

			if new_index ~= index and dropdown.names[new_index] then
				apply(editor, keys, dropdown.names[new_index])
			end
		else
			Imgui.text(value)
		end
	elseif editor.ui_state.structure_mode and type(parent) == "table" then
		if Imgui.small_button("+" .. id) then
			local default_value = sheet_add_default(editor, keys)

			if default_value ~= nil then
				apply(editor, keys, default_value)
			end
		end
	else
		Imgui.text("-")
	end

	Imgui.pop_item_width()

	if editor.state.edits[path] then
		Imgui.same_line()
		text_colored("*", EDITED_COLOR)
	end
end

local function sheet_header(labels)
	Imgui.columns(#labels, true)

	for i, label in ipairs(labels) do
		if i > 1 then
			Imgui.next_column()
		end

		Imgui.text(label)
	end

	Imgui.next_column()
	Imgui.separator()
end

-- Armor modifier rows for each column: a target's own armor_modifier, else the profile's
local function armor_rows(editor, profile, profile_keys, columns, kind)
	for armor_index, armor_name in ipairs(ARMOR_NAMES) do
		Imgui.text(kind .. ": " .. armor_name)

		for _, column in ipairs(columns) do
			Imgui.next_column()

			if type(column.target.armor_modifier) == "table" then
				sheet_cell(editor, column.target, column.keys, { "armor_modifier", kind, armor_index })
			else
				sheet_cell(editor, profile, profile_keys, { "armor_modifier", kind, armor_index })
			end
		end

		Imgui.next_column()
	end
end

local function draw_attack_sheet(editor, profile_name)
	local profile = DamageProfileTemplates[profile_name]
	local profile_keys = { "DamageProfileTemplates", profile_name }

	local structure_mode = editor.ui_state.structure_mode

	for _, field in ipairs(SHEET_TOP_FIELDS) do
		if profile[field] ~= nil or (structure_mode and SHEET_ADD_DEFAULTS[field] ~= nil) then
			Imgui.text(field)
			Imgui.same_line()
			sheet_cell(editor, profile, profile_keys, { field })
		end
	end

	if type(profile.cleave_distribution) == "table" then
		Imgui.text("cleave: attack")
		Imgui.same_line()
		sheet_cell(editor, profile, profile_keys, { "cleave_distribution", "attack" })
		Imgui.same_line()
		Imgui.text("impact")
		Imgui.same_line()
		sheet_cell(editor, profile, profile_keys, { "cleave_distribution", "impact" })
	end

	local columns = {}

	for i, target in ipairs(type(profile.targets) == "table" and profile.targets or {}) do
		columns[#columns + 1] = {
			label = "target " .. i,
			target = target,
			keys = core.append_key(core.append_key(profile_keys, "targets"), i),
		}
	end

	if type(profile.default_target) == "table" then
		columns[#columns + 1] = {
			label = #columns > 0 and "default (rest)" or "default (all)",
			target = profile.default_target,
			keys = core.append_key(profile_keys, "default_target"),
		}
	end

	local targets_keys = core.append_key(profile_keys, "targets")

	if structure_mode and Imgui.small_button("+ target##sheet_add_target" .. profile_name) then
		rewrite_array(editor, targets_keys, function (array)
			array[#array + 1] = new_array_entry(array, targets_keys)
		end)
	end

	local labels = { "" }

	for _, column in ipairs(columns) do
		labels[#labels + 1] = column.label
	end

	sheet_header(labels)

	-- Per-column structure: remove a target, give a column its own armor_modifier or drop it
	if structure_mode then
		Imgui.text("")

		for i, column in ipairs(columns) do
			Imgui.next_column()

			local armor_keys = core.append_key(column.keys, "armor_modifier")
			local column_path = core.format_path(column.keys)

			if type(column.target.armor_modifier) == "table" then
				if Imgui.small_button("drop own armor##sheet_armor" .. column_path) then
					remove_field(editor, armor_keys)
				end
			elseif type(profile.armor_modifier) == "table" then
				if Imgui.small_button("own armor##sheet_armor" .. column_path) then
					set_table(editor, armor_keys, profile.armor_modifier)
				end
			end

			if column.keys[3] == "targets" then
				Imgui.same_line()

				if Imgui.small_button("x##sheet_rm_target" .. column_path) then
					rewrite_array(editor, targets_keys, function (array)
						table.remove(array, i)
					end)
				end
			end
		end

		Imgui.next_column()
		Imgui.separator()
	end

	for _, row in ipairs(SHEET_TARGET_ROWS) do
		Imgui.text(row[1])

		for _, column in ipairs(columns) do
			Imgui.next_column()
			sheet_cell(editor, column.target, column.keys, row[2])
		end

		Imgui.next_column()
	end

	Imgui.separator()
	armor_rows(editor, profile, profile_keys, columns, "attack")
	Imgui.separator()
	armor_rows(editor, profile, profile_keys, columns, "impact")
	Imgui.columns(1)

	local critical_strike = profile.critical_strike

	if type(critical_strike) == "table" then
		Imgui.separator()
		sheet_header({ "crit power", "attack", "impact" })

		for armor_index, armor_name in ipairs(ARMOR_NAMES) do
			Imgui.text(armor_name)
			Imgui.next_column()
			-- "modifer" is the game's own spelling
			sheet_cell(editor, profile, profile_keys, { "critical_strike", "attack_armor_power_modifer", armor_index })
			Imgui.next_column()
			sheet_cell(editor, profile, profile_keys, { "critical_strike", "impact_armor_power_modifer", armor_index })
			Imgui.next_column()
		end

		Imgui.columns(1)
	end
end

--[[
	Forking
]]

-- Every field in this template that points at the profile (drawn every frame while the fork
-- node is open, so the full Weapons scan behind it is cached)
local function template_profile_fields(editor, template_name, profile_name)
	local fields = {}

	for _, user in ipairs(cached_profile_users(editor, profile_name)) do
		if user.keys[2] == template_name then
			fields[#fields + 1] = user.keys
		end
	end

	return fields
end

local function suggested_fork_name(field_keys)
	local template_name = tostring(field_keys[2]):gsub("_template_%d+$", "")
	local base = "tb_" .. template_name .. "_" .. tostring(field_keys[5] or "attack")
	local name = base
	local suffix = 2

	while DamageProfileTemplates[name] or NewDamageProfileTemplates[name] do
		name = base .. "_" .. suffix
		suffix = suffix + 1
	end

	return name
end

local function draw_fork_controls(editor, profile_name, field_keys)
	local field_path = core.format_path(field_keys)
	local s = editor.ui_state

	s.fork_names = s.fork_names or {}
	s.fork_names[field_path] = s.fork_names[field_path] or suggested_fork_name(field_keys)

	s.fork_names[field_path] = Imgui.input_text("new name##fork_name" .. field_path, s.fork_names[field_path])

	local new_name = s.fork_names[field_path]

	if Imgui.small_button("fork for this attack##fork_one" .. field_path) then
		if editor.fork_profile(profile_name, new_name, { field_keys }) then
			s.fork_names[field_path] = nil
		end
	end

	local siblings = template_profile_fields(editor, field_keys[2], profile_name)

	if #siblings > 1 then
		Imgui.same_line()

		if Imgui.small_button(string.format("fork for all %d attacks of this weapon using it##fork_all", #siblings) .. field_path) then
			if editor.fork_profile(profile_name, new_name, siblings) then
				s.fork_names[field_path] = nil
			end
		end
	end
end

draw_profile = function (editor, profile_name, field_keys)
	local is_tb_profile = NewDamageProfileTemplates[profile_name] ~= nil
	local is_fork = editor.state.forks[profile_name] ~= nil
	local counterpart = vanilla_counterpart(editor, profile_name)
	local profile_path = "DamageProfileTemplates." .. profile_name

	if is_fork then
		text_colored(string.format("Fork of %s - exports as a new NewDamageProfileTemplates block (vanilla: %s)", editor.state.forks[profile_name].source, counterpart or "none"), INFO_COLOR)
		Imgui.same_line()

		if Imgui.small_button("delete fork##delete_fork" .. profile_path) then
			editor.delete_fork(profile_name)

			return
		end
	elseif is_tb_profile then
		text_colored(string.format("TB profile - exports as a whole NewDamageProfileTemplates block (vanilla: %s)", counterpart or "none"), INFO_COLOR)
	else
		text_colored("Vanilla profile - shared presets are copied into it on first edit", INFO_COLOR)
	end

	if has_edit_under(editor, profile_path) then
		Imgui.same_line()

		if Imgui.small_button("revert profile##" .. profile_path) then
			editor.revert_profile(profile_name)
		end
	end

	if field_keys and Imgui.tree_node("fork into a new tb_ profile##fork" .. core.format_path(field_keys)) then
		draw_fork_controls(editor, profile_name, field_keys)
		Imgui.tree_pop()
	end

	if Imgui.tree_node("attack sheet##sheet" .. profile_path, true) then
		draw_attack_sheet(editor, profile_name)
		Imgui.tree_pop()
	end

	if Imgui.tree_node("all fields##all" .. profile_path) then
		edit_table(editor, DamageProfileTemplates[profile_name], { "DamageProfileTemplates", profile_name })
		Imgui.tree_pop()
	end
end

-- After a fork is created or deleted
function ui.invalidate_profile_caches(editor)
	dropdowns = {}
	editor.ui_state.counterparts = nil
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

	s.filter = Imgui.input_text("Search weapons / explosions / spread##template_filter", s.filter or "")

	Imgui.pop_item_width()

	if s.filter == "" then
		return
	end

	if s.filter ~= s.last_filter then
		local needle = s.filter:lower()
		local results = {}

		for _, source in ipairs(SEARCH_SOURCES) do
			for name, entry in pairs(rawget(_G, source.root) or {}) do
				if type(entry) == "table" and type(name) == "string" and name:lower():find(needle, 1, true) then
					results[#results + 1] = {
						label = source.prefix .. name,
						root = source.root,
						name = name,
					}
				end
			end
		end

		table.sort(results, function (a, b)
			return a.label < b.label
		end)

		for i = #results, MAX_SEARCH_RESULTS + 1, -1 do
			results[i] = nil
		end

		s.results = results
		s.result_labels = {}

		for i, result in ipairs(results) do
			s.result_labels[i] = result.label
		end

		s.last_filter = s.filter
	end

	if #s.results > 0 then
		local picked = Imgui.list_box("##template_results", 0, s.result_labels, 8)
		local result = picked and picked > 0 and s.results[picked]

		if result then
			if result.root == "Weapons" then
				editor.select_template(result.name)
			else
				editor.select_global(result.root, result.name)
			end

			s.filter = ""
		end
	else
		Imgui.text("No matches.")
	end
end

-- An ExplosionTemplates / SpreadTemplates entry on its own
local function draw_global_entry(editor, root, name)
	local entry = rawget(_G, root)[name]
	local entry_path = root .. "." .. name

	Imgui.text(entry_path)

	if has_edit_under(editor, entry_path) then
		Imgui.same_line()

		if Imgui.small_button("revert##revert_entry") then
			editor.revert_entry(root, name)
		end
	end

	if root == "ExplosionTemplates" then
		-- table.clone'd weapon templates fire their own copy: global edits miss the immediate blast
		for _, copy_keys in ipairs(editor.embedded_explosion_copies(name)) do
			local copy_path = core.format_path(copy_keys)

			text_colored("Own copy (immediate blast ignores edits here): " .. copy_path, WARNING_COLOR)
			Imgui.same_line()

			if Imgui.small_button("link to global##link" .. copy_path) then
				report_result(editor, copy_keys, editor.link_global(copy_keys, entry_path))
			end
		end
	elseif root == "SpreadTemplates" then
		text_colored("Weapons read their spread template live - edits apply immediately", INFO_COLOR)
	end

	edit_table(editor, entry, { root, name })
end

-- Damage profile names a sub-action uses, for its tree label (cached: drawn every frame)
local function sub_action_profiles(editor, sub_action)
	refresh_caches(editor)

	if sub_action_profiles_cache[sub_action] then
		return sub_action_profiles_cache[sub_action]
	end

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

	sub_action_profiles_cache[sub_action] = names

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

	if editor.reequip_needed[template_name] then
		text_colored("Changed fields that are only read on wield/spawn (buffs, ammo) - wield this weapon and re-equip", WARNING_COLOR)
		Imgui.same_line()

		if Imgui.small_button("re-equip##reequip_template") then
			editor.reequip_wielded()
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
						local profiles = sub_action_profiles(editor, sub_action)
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
			Imgui.text(string.format("%s = %s (TB %s)", path, core.describe_edit(edit), type(edit.baseline) == "table" and "<table>" or core.format_value(edit.baseline)))
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

		if Imgui.menu_item("Re-equip weapon") then
			editor.reequip_wielded()
		end

		if Imgui.menu_item("Revert all") then
			editor.report("Reverted %d edit(s).", editor.revert_all())
		end

		Imgui.end_menu_bar()
	end

	Imgui.text(string.format("%d edit(s) | F3: %s", editor.edit_count(), editor.interacting and "editing - press to play" or "playing - press to edit"))
	Imgui.same_line()

	editor.ui_state.structure_mode = Imgui.checkbox("structure mode (add/remove fields and entries)##structure_mode", editor.ui_state.structure_mode or false)

	Imgui.push_item_width(ITEM_WIDTH)

	draw_template_picker(editor)
	Imgui.separator()

	local selected_global = editor.selected_global

	if selected_global and type(rawget(_G, selected_global.root)[selected_global.name]) == "table" then
		draw_global_entry(editor, selected_global.root, selected_global.name)
	elseif editor.selected_template and Weapons[editor.selected_template] then
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
	-- /tbwe_reset_windows: windows dragged outside the game window can't be grabbed back
	if editor.pending_window_reset.editor then
		editor.pending_window_reset.editor = nil

		Imgui.set_next_window_pos(30, 30)
		Imgui.set_next_window_size(760, 860)
	end

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
