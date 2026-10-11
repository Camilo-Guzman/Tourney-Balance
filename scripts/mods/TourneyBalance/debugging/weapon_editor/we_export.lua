--[[
	Weapon editor: turns the current edits into Lua for the weapon change files.

	- Weapons edits             one assignment per field, "-- vanilla: X" (plus "prev TB: Y"
	                            when TourneyBalance had already changed it)
	- TourneyBalance profiles   the whole NewDamageProfileTemplates.tb_x = { ... } block,
	                            re-printed to replace the existing one. Preset names that are
	                            still untouched stay names, every field that differs from the
	                            vanilla profile it replaced gets a "-- vanilla:" comment
	- vanilla profiles          one assignment per field, or the whole sub-table where the
	                            editor copied a shared preset (a leaf assignment there would
	                            change the preset for every other weapon too)
]]

local core = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_core")

local export = {}

local MAX_LISTED_USERS = 6

local function key_text(key, in_sequence)
	if in_sequence then
		return ""
	elseif type(key) == "number" then
		return "[" .. key .. "] = "
	elseif key:match("^[%a_][%w_]*$") then
		return key .. " = "
	end

	return string.format("[%q] = ", key)
end

local function key_label(key)
	return type(key) == "number" and ("[" .. key .. "]") or tostring(key)
end

-- vanilla_node: the matching vanilla table, or false when there is nothing to compare against
local function leaf_comment(value, vanilla_node, key)
	if vanilla_node == false then
		return ""
	end

	local vanilla_value = vanilla_node[key]

	if type(vanilla_value) == "table" then
		return " -- vanilla: <table>"
	elseif core.values_equal(value, vanilla_value) then
		return ""
	end

	return " -- vanilla: " .. core.format_value(vanilla_value)
end

local function preset_comment(ctx, preset_name, live_preset, vanilla_node, key)
	if vanilla_node == false then
		return ""
	end

	local vanilla_value = vanilla_node[key]

	if vanilla_value == nil then
		return " -- vanilla: none"
	elseif type(vanilla_value) ~= "table" then
		return " -- vanilla: " .. core.format_value(vanilla_value)
	elseif core.deep_equal(live_preset, vanilla_value) then
		return ""
	end

	local vanilla_preset = ctx.vanilla_preset_names[vanilla_value]

	if vanilla_preset == preset_name then
		return " -- preset values changed since vanilla"
	elseif vanilla_preset then
		return string.format(" -- vanilla: %q", vanilla_preset)
	end

	return " -- vanilla: inline table (differs)"
end

local function print_table(ctx, authored, live, vanilla_node, indent)
	local out = ctx.out
	local in_sequence = core.is_sequence(live)

	for _, key in ipairs(core.sorted_keys(live)) do
		local authored_value = type(authored) == "table" and authored[key] or nil
		local live_value = live[key]
		local skip = false

		-- _damage_profile_setup.lua adds an empty targets table to profiles that don't author one
		if type(authored) == "table" and authored_value == nil and type(live_value) == "table" and next(live_value) == nil then
			skip = true
		end

		if not skip then
			local prefix = indent .. key_text(key, in_sequence)

			if type(live_value) == "table" then
				if type(authored_value) == "string" and live_value == PowerLevelTemplates[authored_value] then
					-- Still the untouched shared preset: keep referencing it by name
					out[#out + 1] = prefix .. string.format("%q", authored_value) .. "," .. preset_comment(ctx, authored_value, live_value, vanilla_node, key)
				else
					local vanilla_child = false
					local open = prefix .. "{"

					if vanilla_node ~= false then
						local vanilla_value = vanilla_node[key]

						if type(vanilla_value) == "table" then
							vanilla_child = vanilla_value
						else
							open = open .. " -- vanilla: " .. core.format_value(vanilla_value)
						end
					end

					out[#out + 1] = open

					print_table(ctx, type(authored_value) == "table" and authored_value or nil, live_value, vanilla_child, indent .. "\t")

					out[#out + 1] = indent .. "},"
				end
			elseif type(live_value) ~= "function" and type(live_value) ~= "userdata" then
				out[#out + 1] = prefix .. core.format_value(live_value) .. "," .. leaf_comment(live_value, vanilla_node, key)
			end
		end
	end

	if vanilla_node then
		for _, key in ipairs(core.sorted_keys(vanilla_node)) do
			if live[key] == nil then
				local vanilla_value = vanilla_node[key]

				out[#out + 1] = indent .. "-- removed: " .. key_label(key) .. " (vanilla: " .. (type(vanilla_value) == "table" and "<table>" or core.format_value(vanilla_value)) .. ")"
			end
		end
	end
end

local function vanilla_comment(ctx, keys, value, baseline)
	local vanilla_value = core.snapshot_value(ctx.state.vanilla, keys)
	local parts = { "vanilla: " .. core.format_value(vanilla_value) }

	if not core.values_equal(baseline, vanilla_value) then
		parts[#parts + 1] = "prev TB: " .. core.format_value(baseline)
	end

	return " -- " .. table.concat(parts, ", ")
end

local function sorted_edits(edits)
	table.sort(edits, function (a, b)
		return a.path < b.path
	end)

	return edits
end

local function print_users(ctx, users)
	local out = ctx.out

	for i, user in ipairs(users) do
		if i > MAX_LISTED_USERS then
			out[#out + 1] = string.format("-- ...and %d more", #users - MAX_LISTED_USERS)

			break
		end

		out[#out + 1] = "-- used by " .. core.format_path(user.keys)
	end
end

local function print_session_changes(ctx, edits)
	local out = ctx.out

	for _, edit in ipairs(edits) do
		out[#out + 1] = string.format("-- changed: %s %s -> %s", core.format_relative(edit.keys, 3), core.format_value(edit.baseline), core.format_value(edit.value))
	end
end

local function print_weapon_section(ctx, template_name, edits)
	local out = ctx.out

	out[#out + 1] = ""
	out[#out + 1] = "-- " .. template_name

	for _, edit in ipairs(sorted_edits(edits)) do
		out[#out + 1] = edit.path .. " = " .. core.format_value(edit.value) .. vanilla_comment(ctx, edit.keys, edit.value, edit.baseline)
	end
end

local function vanilla_counterparts(ctx, profile_name, users)
	if ctx.state.vanilla.DamageProfileTemplates[profile_name] then
		return { profile_name }
	end

	local names, seen = {}, {}

	for _, user in ipairs(users) do
		local name = user.vanilla_profile

		if type(name) == "string" and name ~= profile_name and not seen[name] then
			seen[name] = true
			names[#names + 1] = name
		end
	end

	table.sort(names)

	return names
end

local function print_tb_profile_section(ctx, profile_name, edits)
	local out = ctx.out
	local users = ctx.editor.profile_users(profile_name)
	local counterparts = vanilla_counterparts(ctx, profile_name, users)
	local counterpart = counterparts[1]
	local vanilla_root = counterpart and ctx.state.vanilla.DamageProfileTemplates[counterpart] or false
	local header = "NewDamageProfileTemplates." .. profile_name .. " = {"

	if counterpart then
		header = header .. " -- vanilla: " .. counterpart

		if #counterparts > 1 then
			header = header .. " (comments compare against it; also replaces " .. table.concat(counterparts, ", ", 2) .. ")"
		end
	else
		header = header .. " -- vanilla: none (new profile)"
	end

	out[#out + 1] = ""
	out[#out + 1] = "-- " .. profile_name .. ": replaces the existing block"

	print_users(ctx, users)
	print_session_changes(ctx, sorted_edits(edits))

	out[#out + 1] = header

	print_table(ctx, NewDamageProfileTemplates[profile_name], DamageProfileTemplates[profile_name], vanilla_root, "\t")

	out[#out + 1] = "}"
end

local function print_vanilla_profile_section(ctx, profile_name, edits)
	local out = ctx.out
	local state = ctx.state
	local emitted_copies = {}

	out[#out + 1] = ""
	out[#out + 1] = "-- " .. profile_name

	print_users(ctx, ctx.editor.profile_users(profile_name))

	for _, edit in ipairs(sorted_edits(edits)) do
		-- Shortest copied prefix above this field, if the editor copied a shared preset
		local copy_path, copy_record = nil, nil

		for cow_path, record in pairs(state.cow) do
			if core.path_is_under(edit.path, cow_path) and edit.path ~= cow_path and (not copy_path or #cow_path < #copy_path) then
				copy_path, copy_record = cow_path, record
			end
		end

		if copy_path then
			if not emitted_copies[copy_path] then
				emitted_copies[copy_path] = true

				local live_table = core.live_value(copy_record.keys)
				local vanilla_table = core.snapshot_value(state.vanilla, copy_record.keys)
				local shared_name = ctx.editor.preset_name(copy_record.original)
				local open = copy_path .. " = {"

				if shared_name then
					open = open .. " -- was shared preset " .. shared_name
				end

				out[#out + 1] = open

				print_table(ctx, nil, live_table, type(vanilla_table) == "table" and vanilla_table or false, "\t")

				out[#out + 1] = "}"
			end
		else
			out[#out + 1] = edit.path .. " = " .. core.format_value(edit.value) .. vanilla_comment(ctx, edit.keys, edit.value, edit.baseline)
		end
	end
end

-- Returns the export text and how many edits it covers
function export.build(editor)
	local state = editor.state
	local ctx = {
		editor = editor,
		state = state,
		out = {},
		vanilla_preset_names = {},
	}

	for name, preset in pairs(state.vanilla.PowerLevelTemplates or {}) do
		if type(preset) == "table" then
			ctx.vanilla_preset_names[preset] = name
		end
	end

	local weapon_edits, profile_edits = {}, {}
	local count = 0

	for path, edit in pairs(state.edits) do
		local bucket = edit.keys[1] == "Weapons" and weapon_edits or profile_edits
		local name = edit.keys[2]

		bucket[name] = bucket[name] or {}
		bucket[name][#bucket[name] + 1] = {
			path = path,
			keys = edit.keys,
			value = edit.value,
			baseline = edit.baseline,
		}
		count = count + 1
	end

	local out = ctx.out

	out[#out + 1] = "-- TB weapon editor export"

	if state.vanilla_tainted then
		out[#out + 1] = "-- WARNING: vanilla snapshot was taken after TourneyBalance already ran - vanilla comments are wrong"
	end

	local template_names = table.keys(weapon_edits)

	table.sort(template_names)

	for _, template_name in ipairs(template_names) do
		print_weapon_section(ctx, template_name, weapon_edits[template_name])
	end

	local profile_names = table.keys(profile_edits)

	table.sort(profile_names)

	for _, profile_name in ipairs(profile_names) do
		if NewDamageProfileTemplates[profile_name] then
			print_tb_profile_section(ctx, profile_name, profile_edits[profile_name])
		else
			print_vanilla_profile_section(ctx, profile_name, profile_edits[profile_name])
		end
	end

	return table.concat(out, "\n"), count
end

return export
