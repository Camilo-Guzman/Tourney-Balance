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
	- ExplosionTemplates /      one section per entry, same line style as Weapons; explosion
	  SpreadTemplates           sections note weapons still firing their own copy

	Structural edits print as a whole table (added field, rewritten array), "= nil"
	(removed field) or "= ExplosionTemplates.x" (a weapon's copy linked to the global).
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

--[[
	Key order: the order most NewDamageProfileTemplates blocks in the change files already use
	(measured across all of them), so replacing an existing block reorders as little as possible.
	Keys not listed go just before the last group (default_target/targets, power_distribution),
	A-Z among themselves; every other table is A-Z (attack before impact, as in the files).
]]

local function rank_lookup(order, unknown_before)
	local ranks = {}

	for i, key in ipairs(order) do
		ranks[key] = i
	end

	ranks.__unknown = ranks[unknown_before] - 0.5

	return ranks
end

local KEY_RANKS = {
	profile = rank_lookup({
		"armor_modifier",
		"charge_value",
		"critical_strike",
		"stagger_duration_modifier",
		"no_stagger_damage_reduction_ranged",
		"no_friendly_fire",
		"dot_balefire_variant",
		"is_dot",
		"no_stagger",
		"require_damage_for_dot",
		"dot_template_name",
		"armor_modifier_near",
		"armor_modifier_far",
		"cleave_distribution",
		"melee_boost_override",
		"ignore_stagger_reduction",
		"shield_break",
		"default_target",
		"targets",
	}, "default_target"),
	target = rank_lookup({
		"attack_template",
		"boost_curve_type",
		"boost_curve_coefficient_headshot",
		"boost_curve_coefficient",
		"stagger_duration_modifier",
		"headshot_boost_boss",
		"damage_type",
		"dot_balefire_variant",
		"power_distribution_near",
		"dot_template_name",
		"power_distribution_far",
		"armor_modifier",
		"range_modifier_settings",
		"power_distribution",
	}, "armor_modifier"),
}

local function ordered_keys(t, context)
	local keys = core.sorted_keys(t)
	local ranks = KEY_RANKS[context]

	if not ranks then
		return keys
	end

	local position = {}

	for i, key in ipairs(keys) do
		position[key] = i
	end

	table.sort(keys, function (a, b)
		local rank_a = ranks[a] or ranks.__unknown
		local rank_b = ranks[b] or ranks.__unknown

		if rank_a ~= rank_b then
			return rank_a < rank_b
		end

		return position[a] < position[b]
	end)

	return keys
end

-- Which ordering a child table gets: profile -> targets -> target, default_target -> target
local function child_context(context, key)
	if key == "default_target" or (context == "targets" and type(key) == "number") then
		return "target"
	elseif key == "targets" then
		return "targets"
	end

	return "other"
end

-- Ordering for a table printed on its own, from the last key of its path
function export.context_for_keys(keys)
	local last, previous = keys[#keys], keys[#keys - 1]

	if #keys == 2 then
		return "profile"
	end

	return child_context(previous == "targets" and "targets" or "other", last)
end

local function print_table(ctx, authored, live, vanilla_node, indent, context)
	local out = ctx.out
	local in_sequence = core.is_sequence(live)

	for _, key in ipairs(ordered_keys(live, context)) do
		local authored_value = type(authored) == "table" and authored[key] or nil
		local live_value = live[key]
		local skip = false

		-- _damage_profile_setup.lua adds an empty targets table to profiles that don't author one
		if type(authored) == "table" and authored_value == nil and type(live_value) == "table" and next(live_value) == nil then
			skip = true
		end

		-- The game stamps name = <its own key> onto profiles; never export it. A copied name makes
		-- the block claim to be another profile, which crashes the game (network lookup).
		if context == "profile" and key == "name" then
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

					print_table(ctx, type(authored_value) == "table" and authored_value or nil, live_value, vanilla_child, indent .. "\t", child_context(context, key))

					out[#out + 1] = indent .. "},"
				end
			elseif type(live_value) ~= "function" and type(live_value) ~= "userdata" then
				out[#out + 1] = prefix .. core.format_value(live_value) .. "," .. leaf_comment(live_value, vanilla_node, key)
			end
		end
	end

	if vanilla_node then
		for _, key in ipairs(core.sorted_keys(vanilla_node)) do
			-- damage_profile_templates.lua stamps name onto every vanilla profile at load
			local stamped = key == "name" and type(vanilla_node[key]) == "string"

			if live[key] == nil and not stamped then
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

local function short_value(value)
	return type(value) == "table" and "<table>" or core.format_value(value)
end

-- One edit as Lua, for every kind (see we_core.lua): a leaf assignment, a whole table,
-- a removal (= nil) or a link to a global table
local function print_edit(ctx, edit)
	local out = ctx.out
	local kind = edit.kind or "value"
	local vanilla_value = core.snapshot_value(ctx.state.vanilla, edit.keys)

	if kind == "value" then
		out[#out + 1] = edit.path .. " = " .. core.format_value(edit.value) .. vanilla_comment(ctx, edit.keys, edit.value, edit.baseline)
	elseif kind == "removed" then
		out[#out + 1] = edit.path .. " = nil -- vanilla: " .. short_value(vanilla_value)
	elseif kind == "ref" then
		out[#out + 1] = edit.path .. " = " .. edit.ref .. " -- vanilla: " .. (vanilla_value == nil and "none" or "the weapon's own copy")
	elseif kind == "table" then
		local live_table = core.live_value(edit.keys)
		local open = edit.path .. " = {"

		if type(vanilla_value) ~= "table" then
			open = open .. " -- vanilla: " .. core.format_value(vanilla_value)
		end

		out[#out + 1] = open

		if type(live_table) == "table" then
			print_table(ctx, nil, live_table, type(vanilla_value) == "table" and vanilla_value or false, "\t", export.context_for_keys(edit.keys))
		end

		out[#out + 1] = "}"
	end
end

local function print_global_section(ctx, root, name, edits)
	local out = ctx.out

	out[#out + 1] = ""
	out[#out + 1] = "-- " .. root .. "." .. name

	if root == "ExplosionTemplates" then
		for _, copy_keys in ipairs(ctx.editor.embedded_explosion_copies(name)) do
			local copy_path = core.format_path(copy_keys)

			out[#out + 1] = "-- note: " .. copy_path .. " is the weapon's own copy - its immediate blast ignores these lines unless linked:"
			out[#out + 1] = "-- " .. copy_path .. " = ExplosionTemplates." .. name
		end
	end

	for _, edit in ipairs(sorted_edits(edits)) do
		print_edit(ctx, edit)
	end
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
		out[#out + 1] = string.format("-- changed: %s %s -> %s", core.format_relative(edit.keys, 3), short_value(edit.baseline), core.describe_edit(edit))
	end
end

local function print_weapon_section(ctx, template_name, edits)
	local out = ctx.out

	out[#out + 1] = ""
	out[#out + 1] = "-- " .. template_name

	for _, edit in ipairs(sorted_edits(edits)) do
		print_edit(ctx, edit)
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

	local fork = ctx.state.forks and ctx.state.forks[profile_name]

	out[#out + 1] = ""

	if fork then
		out[#out + 1] = string.format("-- %s: new profile (forked from %s), add this block", profile_name, fork.source)
	else
		out[#out + 1] = "-- " .. profile_name .. ": replaces the existing block"
	end

	print_users(ctx, users)
	print_session_changes(ctx, sorted_edits(edits))

	out[#out + 1] = header

	print_table(ctx, NewDamageProfileTemplates[profile_name], DamageProfileTemplates[profile_name], vanilla_root, "\t", "profile")

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
		-- Shortest copied prefix above a value edit, if the editor copied a shared preset.
		-- Structural edits already print their whole table (or = nil) themselves.
		local copy_path, copy_record = nil, nil

		if (edit.kind or "value") == "value" then
			for cow_path, record in pairs(state.cow) do
				if core.path_is_under(edit.path, cow_path) and edit.path ~= cow_path and (not copy_path or #cow_path < #copy_path) then
					copy_path, copy_record = cow_path, record
				end
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

				print_table(ctx, nil, live_table, type(vanilla_table) == "table" and vanilla_table or false, "\t", export.context_for_keys(copy_record.keys))

				out[#out + 1] = "}"
			end
		else
			print_edit(ctx, edit)
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
	local global_edits = {} -- root -> entry name -> edits, for ExplosionTemplates/SpreadTemplates
	local count = 0

	for path, edit in pairs(state.edits) do
		local root = edit.keys[1]
		local bucket

		if root == "Weapons" then
			bucket = weapon_edits
		elseif root == "DamageProfileTemplates" then
			bucket = profile_edits
		else
			global_edits[root] = global_edits[root] or {}
			bucket = global_edits[root]
		end

		local name = edit.keys[2]

		bucket[name] = bucket[name] or {}
		bucket[name][#bucket[name] + 1] = {
			path = path,
			keys = edit.keys,
			kind = edit.kind,
			value = edit.value,
			ref = edit.ref,
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

	local roots = table.keys(global_edits)

	table.sort(roots)

	for _, root in ipairs(roots) do
		local names = table.keys(global_edits[root])

		table.sort(names)

		for _, name in ipairs(names) do
			print_global_section(ctx, root, name, global_edits[root][name])
		end
	end

	-- Forks export as new blocks even with no edits inside them
	for fork_name in pairs(state.forks or {}) do
		profile_edits[fork_name] = profile_edits[fork_name] or {}
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
