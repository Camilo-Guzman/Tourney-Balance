local mod = get_mod("TourneyBalance")

--[[

	Weapon editor spike (dev tool, off by default)

	Throwaway feasibility test for the planned in-game weapon editor. Answers six
	questions before the real tool gets built:

	1. Can a mod require Fatshark's shipped-but-dormant Imgui tools
	   (scripts/imgui/imgui_weapon_editor.lua, imgui_weapon_debug.lua)?
	      /tbs_imgui editor      /tbs_imgui debug
	2. Do Imgui windows render and take mouse/keyboard input, with game input blocked?
	      F3 toggles between interacting with the windows and playing.
	3. Does Imgui.input_float hand back single-precision values (0.225 -> 0.2249999940...)?
	      /tbs_imgui float       then, after browsing tables in the editor: /tbs_drift
	4. Does Clipboard.put work from a mod? patches.lua silently stubs it as a no-op
	   when the engine lacks it, so this reads the clipboard back to tell.
	      /tbs_clipboard
	5. Does a live edit apply to the very next hit, without re-equipping?
	      /tbs_set <path> <value>   /tbs_get <path>   /tbs_revert
	6. Round trip: edit, export with "-- vanilla:" comments, paste into the weapon file,
	   rebuild, relaunch, verify.
	      /tbs_export            (after relaunch) /tbs_verify
	7. Can breakpoints be computed without a target unit, with TB's damage formula, and
	   do they match real hits?
	      /tbs_breakpoint [breed] [hit_zone] [crit]   /tbs_hitlog

	Paths look like the change files: Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.anim_time_scale
	or DamageProfileTemplates.tb_halberd_light_slash.targets[1].power_distribution.attack.
	Only Weapons and DamageProfileTemplates are supported, and only leaf values.

	Must be dofile'd before every change file (see TourneyBalance.lua), so the vanilla
	snapshot below is taken before TourneyBalance touches anything.

]]

local ENABLED = false

if not ENABLED then
	return
end

local SUPPORTED_ROOTS = {
	Weapons = true,
	DamageProfileTemplates = true,
}

local PENDING_EDITS_SETTING = "tbs_pending_edits"
local INPUT_SERVICE_NAME = "tb_spike_imgui"
local INPUT_CAPTURE_OWNER = "TBWeaponEditorSpike"

local function report(format, ...)
	local message = string.format(format, ...)

	mod:echo("[TB spike] " .. message)
	print("[TB spike] " .. message)
end

local function deep_copy(value, seen)
	if type(value) ~= "table" then
		return value
	end

	if seen[value] then
		return seen[value]
	end

	local copy = {}
	seen[value] = copy

	for k, v in pairs(value) do
		copy[k] = deep_copy(v, seen)
	end

	return copy
end

local function capture_tables()
	local seen = {}

	return {
		Weapons = deep_copy(Weapons, seen),
		DamageProfileTemplates = deep_copy(DamageProfileTemplates, seen),
	}
end

--[[
	Snapshots
]]

-- Vanilla snapshot, kept in a global so it outlives a VMF hot reload. A reload re-runs
-- this file without resetting Weapons/DamageProfileTemplates, so a snapshot retaken then
-- would already contain TourneyBalance's changes.
local VANILLA_GLOBAL = "TB_WEAPON_EDITOR_SPIKE_VANILLA"
local vanilla = rawget(_G, VANILLA_GLOBAL)
local vanilla_tainted = false

if not vanilla then
	-- NewDamageProfileTemplates also survives a reload, so entries in it already mean
	-- this first snapshot is happening after TourneyBalance ran once (spike enabled mid-session).
	vanilla_tainted = next(NewDamageProfileTemplates) ~= nil
	vanilla = capture_tables()
	vanilla.tainted = vanilla_tainted

	rawset(_G, VANILLA_GLOBAL, vanilla)
else
	vanilla_tainted = vanilla.tainted
end

-- TourneyBalance baseline: everything loaded, before any spike edit. Exports and drift
-- checks diff against this, while "-- vanilla:" comments come from the snapshot above.
local tb_baseline = nil

local function ensure_tb_baseline()
	if not tb_baseline then
		tb_baseline = capture_tables()
		report("TB baseline captured late (on first use) - on_all_mods_loaded didn't fire first.")
	end
end

mod:add_all_mods_loaded_function(function ()
	tb_baseline = capture_tables()
end)

--[[
	Paths
]]

local function parse_path(path)
	local keys = {}

	for segment in path:gmatch("[^%.]+") do
		local name, rest = segment:match("^([^%[]*)(.*)$")

		if name ~= "" then
			keys[#keys + 1] = name
		end

		for index in rest:gmatch("%[(%d+)%]") do
			keys[#keys + 1] = tonumber(index)
		end
	end

	return keys
end

-- root_name replaces keys[1] (e.g. DamageProfileTemplates -> NewDamageProfileTemplates),
-- last_index stops early to name an intermediate table.
local function format_path(keys, root_name, last_index)
	local parts = { root_name or keys[1] }

	for i = 2, last_index or #keys do
		local key = keys[i]

		if type(key) == "number" then
			parts[#parts + 1] = "[" .. key .. "]"
		elseif key:match("^[%a_][%w_]*$") then
			parts[#parts + 1] = "." .. key
		else
			parts[#parts + 1] = string.format("[%q]", key)
		end
	end

	return table.concat(parts)
end

-- Walks keys[2..n] from `root`. Returns the value, plus every table passed through on the way.
local function walk(root, keys)
	local value = root
	local ancestors = {}

	for i = 2, #keys do
		if type(value) ~= "table" then
			return nil, ancestors
		end

		ancestors[#ancestors + 1] = value
		value = value[keys[i]]
	end

	return value, ancestors
end

local function live_value(keys)
	return walk(rawget(_G, keys[1]), keys)
end

local function snapshot_value(snapshot, keys)
	return (walk(snapshot and snapshot[keys[1]], keys))
end

--[[
	Values
]]

local function format_value(value)
	local value_type = type(value)

	if value == nil then
		return "none"
	elseif value_type == "number" then
		if value == math.floor(value) and math.abs(value) < 1e15 then
			return string.format("%d", value)
		end

		-- Rounded to 4 decimals and trailing zeros trimmed, so float noise never reaches the file
		local text = string.format("%.4f", value)
		text = text:gsub("0+$", "")
		text = text:gsub("%.$", "")

		return text
	elseif value_type == "string" then
		return string.format("%q", value)
	elseif value_type == "table" then
		return "<table>"
	end

	return tostring(value)
end

local function values_equal(a, b)
	if type(a) == "number" and type(b) == "number" then
		return math.abs(a - b) <= 1e-6
	end

	return a == b
end

local function parse_command_value(text)
	local number = tonumber(text)

	if number then
		return number
	elseif text == "true" then
		return true
	elseif text == "false" then
		return false
	end

	return (text:gsub("^\"(.*)\"$", "%1"))
end

-- Settings round-trip as a plain string ("path\ttype:value" per line), so this doesn't
-- depend on VMF serializing nested tables.
local function encode_value(value)
	local value_type = type(value)

	if value_type == "number" then
		return "n:" .. string.format("%.17g", value)
	elseif value_type == "boolean" then
		return "b:" .. tostring(value)
	end

	return "s:" .. tostring(value)
end

local function decode_value(text)
	local kind, raw = text:match("^(%a):(.*)$")

	if kind == "n" then
		return tonumber(raw)
	elseif kind == "b" then
		return raw == "true"
	end

	return raw
end

--[[
	Shared tables
]]

-- Maps every table reachable from a PowerLevelTemplates preset to "<preset name><sub path>".
-- Vanilla profiles hold these presets by reference after string resolution, so writing
-- into one changes every profile that uses the same preset.
local preset_owner_lookup = nil

local function get_preset_owner_lookup()
	if preset_owner_lookup then
		return preset_owner_lookup
	end

	preset_owner_lookup = {}

	local function visit(t, label, depth)
		if preset_owner_lookup[t] or depth > 4 then
			return
		end

		preset_owner_lookup[t] = label

		for k, v in pairs(t) do
			if type(v) == "table" then
				visit(v, label .. (type(k) == "number" and ("[" .. k .. "]") or ("." .. tostring(k))), depth + 1)
			end
		end
	end

	for name, preset in pairs(PowerLevelTemplates) do
		if type(preset) == "table" then
			visit(preset, name, 1)
		end
	end

	return preset_owner_lookup
end

local function find_shared_preset(ancestors)
	local lookup = get_preset_owner_lookup()

	for i = #ancestors, 1, -1 do
		local owner = lookup[ancestors[i]]

		if owner then
			return owner
		end
	end

	return nil
end

-- A tb_ profile has no vanilla twin of the same name. Its vanilla counterpart is whatever
-- profile the actions now pointing at it used before TourneyBalance.
local function find_vanilla_counterparts(profile_name)
	local names, seen = {}, {}

	for template_name, template in pairs(Weapons) do
		local actions = type(template) == "table" and template.actions

		if type(actions) == "table" then
			for action_name, action in pairs(actions) do
				if type(action) == "table" then
					for sub_action_name, sub_action in pairs(action) do
						if type(sub_action) == "table" then
							for field, value in pairs(sub_action) do
								if value == profile_name and type(field) == "string" and field:find("damage_profile", 1, true) then
									local vanilla_template = vanilla.Weapons[template_name]
									local vanilla_actions = vanilla_template and vanilla_template.actions
									local vanilla_action = vanilla_actions and vanilla_actions[action_name]
									local vanilla_sub_action = vanilla_action and vanilla_action[sub_action_name]
									local vanilla_name = vanilla_sub_action and vanilla_sub_action[field]

									if type(vanilla_name) == "string" and vanilla_name ~= profile_name and not seen[vanilla_name] then
										seen[vanilla_name] = true
										names[#names + 1] = vanilla_name
									end
								end
							end
						end
					end
				end
			end
		end
	end

	table.sort(names)

	return names
end

--[[
	Edits (test 5)
]]

local edits = {}
local edit_order = {}

local function save_pending_edits()
	local lines = {}

	for _, path in ipairs(edit_order) do
		lines[#lines + 1] = path .. "\t" .. encode_value(edits[path].value)
	end

	mod:set(PENDING_EDITS_SETTING, table.concat(lines, "\n"))
end

local function flush_mechanism_cache()
	-- Templates with mechanism_overrides are shallow-copied and cached per mechanism
	if MechanismOverrides and MechanismOverrides.mechanism_switched then
		MechanismOverrides.mechanism_switched()
	end
end

local function validate_path(path)
	local keys = parse_path(path or "")

	if #keys < 3 or not SUPPORTED_ROOTS[keys[1]] then
		report("Path must start with Weapons. or DamageProfileTemplates. and point at a field: %s", tostring(path))
		return nil
	end

	return keys
end

local function command_get(path)
	local keys = validate_path(path)

	if not keys then
		return
	end

	ensure_tb_baseline()

	local value = live_value(keys)

	report("%s\n  live: %s (raw %.17g)\n  TB baseline: %s\n  vanilla: %s", format_path(keys), format_value(value), type(value) == "number" and value or 0, format_value(snapshot_value(tb_baseline, keys)), format_value(snapshot_value(vanilla, keys)))
end

local function command_set(path, value_text)
	local keys = validate_path(path)

	if not keys then
		return
	end

	if value_text == nil then
		report("Usage: /tbs_set <path> <value>")
		return
	end

	ensure_tb_baseline()

	local old_value, ancestors = live_value(keys)
	local parent = ancestors[#ancestors]

	if type(parent) ~= "table" or #ancestors ~= #keys - 1 then
		report("Path doesn't resolve to an existing table: %s", path)
		return
	end

	if type(old_value) == "table" then
		report("Only leaf values are supported in the spike, %s is a table.", path)
		return
	end

	local new_value = parse_command_value(value_text)

	if old_value ~= nil and type(old_value) ~= type(new_value) then
		report("Type mismatch: field is %s, got %s.", type(old_value), type(new_value))
		return
	end

	local shared_preset = find_shared_preset(ancestors)

	if shared_preset then
		report("WARNING: this field lives in shared preset PowerLevelTemplates.%s - the edit applies to every profile using it.", shared_preset)
	end

	parent[keys[#keys]] = new_value

	flush_mechanism_cache()

	local normalized_path = format_path(keys)

	if not edits[normalized_path] then
		edit_order[#edit_order + 1] = normalized_path
	end

	edits[normalized_path] = {
		keys = keys,
		value = new_value,
	}

	save_pending_edits()
	report("%s: %s -> %s. Hit something to test it.", normalized_path, format_value(old_value), format_value(new_value))
end

local function command_revert()
	ensure_tb_baseline()

	for _, path in ipairs(edit_order) do
		local keys = edits[path].keys
		local _, ancestors = live_value(keys)
		local parent = ancestors[#ancestors]

		if type(parent) == "table" then
			parent[keys[#keys]] = snapshot_value(tb_baseline, keys)
		end
	end

	flush_mechanism_cache()
	report("Reverted %d edit(s) to the TB baseline.", #edit_order)

	edits, edit_order = {}, {}

	mod:set(PENDING_EDITS_SETTING, "")
end

--[[
	Export (test 6)
]]

local function vanilla_comment(vanilla_value, baseline_value, current_value)
	local parts = { "vanilla: " .. format_value(vanilla_value) }

	if not values_equal(baseline_value, vanilla_value) then
		parts[#parts + 1] = "prev TB: " .. format_value(baseline_value)
	end

	if values_equal(current_value, vanilla_value) then
		parts[#parts + 1] = "back to vanilla"
	end

	return " -- " .. table.concat(parts, ", ")
end

local function export_line(keys, current_value)
	local baseline_value = snapshot_value(tb_baseline, keys)
	local assignment = " = " .. format_value(current_value)

	if keys[1] == "DamageProfileTemplates" then
		local profile_name = keys[2]
		local authored = NewDamageProfileTemplates[profile_name]

		if authored then
			local vanilla_value
			local header

			if vanilla.DamageProfileTemplates[profile_name] then
				vanilla_value = snapshot_value(vanilla, keys)
			else
				local counterparts = find_vanilla_counterparts(profile_name)
				local counterpart = counterparts[1]

				if counterpart then
					local counterpart_keys = { "DamageProfileTemplates", counterpart }

					for i = 3, #keys do
						counterpart_keys[#counterpart_keys + 1] = keys[i]
					end

					vanilla_value = snapshot_value(vanilla, counterpart_keys)
					header = "-- vanilla counterpart: " .. table.concat(counterparts, ", ") .. (#counterparts > 1 and " (comment compares against the first)" or "")
				else
					header = "-- no vanilla counterpart found"
				end
			end

			-- In the authored block a field can still be a preset name string (resolved only
			-- later by _damage_profile_setup.lua), so a leaf path through it would index a string.
			local line = format_path(keys, "NewDamageProfileTemplates") .. assignment .. vanilla_comment(vanilla_value, baseline_value, current_value)
			local problem = nil
			local node = authored

			for i = 3, #keys - 1 do
				local child = node[keys[i]]

				if type(child) == "string" then
					problem = string.format("-- SPIKE: %s is preset \"%s\" in the authored block - needs an inline copy (real tool will do this):", format_path(keys, "NewDamageProfileTemplates", i), child)
				elseif type(child) ~= "table" then
					problem = string.format("-- SPIKE: %s is not in the authored block (filled in at setup) - needs the whole sub-table:", format_path(keys, "NewDamageProfileTemplates", i))
				end

				if problem then
					line = problem .. "\n-- " .. line

					break
				end

				node = child
			end

			return header and (header .. "\n" .. line) or line
		end
	end

	local line = format_path(keys) .. assignment .. vanilla_comment(snapshot_value(vanilla, keys), baseline_value, current_value)
	local _, ancestors = live_value(keys)
	local shared_preset = find_shared_preset(ancestors)

	if shared_preset then
		line = string.format("-- SPIKE: shared preset PowerLevelTemplates.%s - this line changes every profile using it\n%s", shared_preset, line)
	end

	return line
end

local function put_on_clipboard(text)
	if not rawget(_G, "Clipboard") then
		return false, "Clipboard global doesn't exist"
	end

	local ok, err = pcall(Clipboard.put, text)

	if not ok then
		return false, "Clipboard.put errored: " .. tostring(err)
	end

	local read_ok, read_back = pcall(Clipboard.get)

	if not read_ok then
		return false, "Clipboard.get errored: " .. tostring(read_back)
	elseif read_back ~= text then
		return false, "read-back mismatch (patches.lua stub returns \"\") - got " .. string.format("%q", tostring(read_back):sub(1, 40))
	end

	return true
end

local function command_export()
	ensure_tb_baseline()

	if #edit_order == 0 then
		report("Nothing to export - make an edit with /tbs_set first.")
		return
	end

	local lines = { "-- TB weapon editor spike export" }

	if vanilla_tainted then
		lines[#lines + 1] = "-- WARNING: vanilla snapshot was taken after TourneyBalance already ran (spike enabled mid-session) - vanilla comments are wrong"
	end

	for _, path in ipairs(edit_order) do
		local edit = edits[path]

		lines[#lines + 1] = export_line(edit.keys, live_value(edit.keys))
	end

	local text = table.concat(lines, "\n")

	print("[TB spike] ---- export begin ----")
	print(text)
	print("[TB spike] ---- export end ----")

	local ok, err = put_on_clipboard(text)

	if ok then
		report("Exported %d edit(s) to the clipboard (also in the console log).", #edit_order)
	else
		report("Clipboard failed (%s). Export is in the console log between the begin/end markers.", err)
	end
end

local function command_verify()
	local saved = mod:get(PENDING_EDITS_SETTING)

	if type(saved) ~= "string" or saved == "" then
		report("No pending edits saved - nothing to verify.")
		return
	end

	ensure_tb_baseline()

	local applied, mismatched = 0, 0

	for line in saved:gmatch("[^\n]+") do
		local path, encoded = line:match("^(.-)\t(.*)$")

		if path then
			-- Checked against the load-time baseline, not the live value: in the session that
			-- made the edit, live still holds the edit itself and would always match.
			local expected = decode_value(encoded)
			local actual = snapshot_value(tb_baseline, parse_path(path))

			if values_equal(actual, expected) then
				applied = applied + 1
			else
				mismatched = mismatched + 1
				report("MISMATCH %s: expected %s, loaded from files %s", path, format_value(expected), format_value(actual))
			end
		end
	end

	if mismatched == 0 then
		report("All %d edit(s) are now in the TB baseline - round trip OK. Cleared the pending list.", applied)
		mod:set(PENDING_EDITS_SETTING, "")
	else
		report("%d applied, %d mismatched. Pending list kept.", applied, mismatched)
	end
end

--[[
	Drift (test 3, applied): Fatshark's editor writes every visible field back each frame
	via Imgui.input_float. Differences this small are float32 rounding, not real edits.
]]

local function collect_drift(live, baseline, path, out)
	for k, v in pairs(live) do
		local child_path = type(k) == "number" and (path .. "[" .. k .. "]") or (path .. "." .. tostring(k))
		local b = baseline[k]

		if type(v) == "table" and type(b) == "table" then
			collect_drift(v, b, child_path, out)
		elseif type(v) == "number" and type(b) == "number" and v ~= b and math.abs(v - b) < 1e-5 then
			out[#out + 1] = { path = child_path, table = live, key = k, live = v, baseline = b }
		end
	end
end

local function command_drift(action)
	ensure_tb_baseline()

	local drift = {}

	for root_name in pairs(SUPPORTED_ROOTS) do
		collect_drift(rawget(_G, root_name), tb_baseline[root_name], root_name, drift)
	end

	report("%d float32-sized drift(s) vs TB baseline.", #drift)

	for i = 1, math.min(#drift, 5) do
		report("  %s: %.17g (baseline %.17g)", drift[i].path, drift[i].live, drift[i].baseline)
	end

	if action == "fix" then
		for _, entry in ipairs(drift) do
			entry.table[entry.key] = entry.baseline
		end

		report("Restored %d drifted value(s).", #drift)
	end
end

--[[
	Imgui (tests 1-3)
]]

local imgui = {
	open = false,
	interacting = false,
	guis = {},
}

rawset(_G, "TBSpikeImguiKeymaps", rawget(_G, "TBSpikeImguiKeymaps") or {
	win32 = {
		tb_spike_toggle = {
			"keyboard",
			"f3",
			"pressed",
		},
	},
})

local function set_interacting(interacting)
	if imgui.interacting == interacting then
		return
	end

	local input_manager = Managers.input

	if input_manager then
		local ok, err = pcall(function ()
			if not input_manager:get_input_service(INPUT_SERVICE_NAME) then
				input_manager:create_input_service(INPUT_SERVICE_NAME, "TBSpikeImguiKeymaps")
				input_manager:map_device_to_service(INPUT_SERVICE_NAME, "keyboard")
				input_manager:map_device_to_service(INPUT_SERVICE_NAME, "mouse")
				input_manager:map_device_to_service(INPUT_SERVICE_NAME, "gamepad")
			end

			local method = interacting and "capture_input" or "release_input"

			input_manager[method](input_manager, ALL_INPUT_METHODS, 1, INPUT_SERVICE_NAME, INPUT_CAPTURE_OWNER)
		end)

		if not ok then
			report("Input manager capture failed: %s", tostring(err))
		end
	end

	if interacting then
		ShowCursorStack.show(INPUT_CAPTURE_OWNER)
		Imgui.enable_imgui_input_system(Imgui.KEYBOARD)
		Imgui.enable_imgui_input_system(Imgui.MOUSE)
	else
		ShowCursorStack.hide(INPUT_CAPTURE_OWNER)
		Imgui.disable_imgui_input_system(Imgui.KEYBOARD)
		Imgui.disable_imgui_input_system(Imgui.MOUSE)
	end

	imgui.interacting = interacting
end

local function close_gui(name)
	if not imgui.guis[name] then
		return
	end

	imgui.guis[name] = nil

	if imgui.open and next(imgui.guis) == nil then
		set_interacting(false)
		Imgui.close_imgui()

		imgui.open = false
	end
end

local function close_all_guis()
	for name in pairs(imgui.guis) do
		close_gui(name)
	end
end

local FloatTest = {}

FloatTest.new = function ()
	return setmetatable({
		value = 0.225,
		frames = 0,
	}, {
		__index = FloatTest,
	})
end

FloatTest.update = function ()
end

local function pack(...)
	return {
		n = select("#", ...),
		...,
	}
end

FloatTest.draw = function (self)
	local do_close = Imgui.begin_window("TB Spike: float precision")
	local before = self.value
	local results = pack(Imgui.input_float("value", self.value))

	if self.frames == 0 then
		report("input_float(0.225) returned %.17g - %s. Return count %d, 2nd return: %s", results[1], results[1] == before and "exact (double)" or "ROUNDED (float32)", results.n, tostring(results[2]))
	elseif results[1] ~= before then
		report("input_float changed value: %.17g -> %.17g (2nd return: %s)", before, results[1], tostring(results[2]))
	end

	self.value = results[1]
	self.frames = self.frames + 1

	Imgui.text(string.format("stored: %.17g", self.value))

	if Imgui.button("Reset to 0.225") then
		self.value = 0.225
		self.frames = 0
	end

	Imgui.end_window()

	return do_close
end

local function create_fatshark_gui(file, class_name)
	local ok, err = pcall(require, file)

	if not ok then
		report("require(\"%s\") FAILED: %s", file, tostring(err))
		return nil
	end

	local class_object = rawget(_G, class_name)

	if not class_object then
		report("require(\"%s\") ran but %s is not defined.", file, class_name)
		return nil
	end

	local new_ok, instance = pcall(class_object.new, class_object)

	if not new_ok then
		report("%s:new() FAILED: %s", class_name, tostring(instance))
		return nil
	end

	report("require(\"%s\") OK, %s created.", file, class_name)

	return instance
end

local GUI_FACTORIES = {
	editor = function ()
		return create_fatshark_gui("scripts/imgui/imgui_weapon_editor", "ImguiWeaponEditor")
	end,
	debug = function ()
		return create_fatshark_gui("scripts/imgui/imgui_weapon_debug", "ImguiWeaponDebug")
	end,
	float = function ()
		return FloatTest.new()
	end,
}

local function command_imgui(name)
	if name == "off" then
		close_all_guis()
		report("Closed all spike windows.")
		return
	end

	local factory = GUI_FACTORIES[name]

	if not factory then
		report("Usage: /tbs_imgui editor|debug|float|off")
		return
	end

	if imgui.guis[name] then
		close_gui(name)
		return
	end

	if not rawget(_G, "Imgui") then
		report("Imgui global doesn't exist in this build.")
		return
	end

	local instance = factory()

	if not instance then
		return
	end

	if not imgui.open then
		Imgui.open_imgui()

		imgui.open = true
	end

	imgui.guis[name] = instance

	set_interacting(true)
	report("F3 toggles between using the window and playing.")
end

mod:add_update_function(function (dt)
	if not imgui.open then
		return
	end

	if Keyboard.pressed(Keyboard.button_index("f3")) then
		set_interacting(not imgui.interacting)
	end

	local t = Managers.time and Managers.time:time("game") or 0

	for name, gui in pairs(imgui.guis) do
		local update_ok, update_err = pcall(gui.update, gui, t, dt)

		if not update_ok then
			if gui._draw_chain_action_data then
				-- Chain timeline draws through Debug.gui, which may not exist in retail
				gui._draw_chain_action_data = false
				report("%s update failed with chain drawing on, disabled it: %s", name, tostring(update_err))
			else
				report("%s update FAILED, closing: %s", name, tostring(update_err))
				close_gui(name)
			end
		elseif imgui.guis[name] then
			local draw_ok, do_close = pcall(gui.draw, gui)

			if not draw_ok then
				report("%s draw FAILED, closing: %s", name, tostring(do_close))
				close_gui(name)
			elseif do_close then
				close_gui(name)
			end
		end
	end
end)

-- Input services and the cursor stack don't survive a level/state change cleanly
mod:add_game_state_changed_function(function ()
	close_all_guis()
end)

--[[
	Clipboard (test 4)
]]

local function command_clipboard()
	local text = string.format("TB spike clipboard test %d", math.random(100000, 999999))
	local ok, err = put_on_clipboard(text)

	if ok then
		report("Clipboard OK - paste somewhere, you should see: %s", text)
	else
		report("Clipboard FAILED: %s", err)
	end
end

--[[
	Breakpoints (test 7): can a breakpoint grid be computed without a target unit, using
	TB's own formula? 01_damage_calc_changes.lua replaces calculate_damage with its own copy
	of do_damage_calculation (exposed as mod.tb_do_damage_calculation), so vanilla's
	DamageUtils.custom_calculate_damage would give vanilla numbers. Both are shown so the
	difference is visible. /tbs_hitlog then checks predictions against real hits.
]]

local TB_STAGGER_DAMAGE_PER_STACK = 0.2 -- mirrors 01_damage_calc_changes.lua

local function local_player_unit()
	local player = Managers.player and Managers.player:local_player()
	local unit = player and player.player_unit

	return unit and Unit.alive(unit) and unit or nil
end

-- Unit-less prediction: everything calculate_damage reads off the target unit comes from
-- the breed instead. Crit-killing-blow perks and target-side buffs are left out.
local function predict_tb_damage(attacker_unit, damage_source, power_level, damage_profile, target_index, is_critical_strike, breed, hit_zone_name, difficulty_level, boost_damage_multiplier, backstab_multiplier, stagger_number)
	local do_damage_calculation = mod.tb_do_damage_calculation

	if not do_damage_calculation then
		return nil
	end

	local target_settings = damage_profile.targets and damage_profile.targets[target_index] or damage_profile.default_target
	local boost_curve = BoostCurves[target_settings.boost_curve_type]
	local armor, _, primary_armor = ActionUtils.get_target_armor(hit_zone_name, breed, nil)
	local buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")
	local has_power_boost = buff_extension and buff_extension:has_buff_perk("potion_armor_penetration") or false
	local difficulty_settings = DifficultySettings[difficulty_level]
	local max_health = breed.max_health and breed.max_health[difficulty_settings.rank]
	local base_damage = do_damage_calculation(attacker_unit, damage_source, power_level, DamageOutput, hit_zone_name, damage_profile, target_index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, 0, false, false, has_power_boost, difficulty_level, armor, primary_armor, false, false, max_health, nil)
	local final_damage = base_damage

	if not damage_profile.is_dot then
		final_damage = base_damage * (difficulty_settings.min_stagger_damage_coefficient + (stagger_number or 0) * TB_STAGGER_DAMAGE_PER_STACK)
	end

	return final_damage, base_damage
end

local function predict_vanilla_formula_damage(attacker_unit, damage_source, power_level, damage_profile, target_index, is_critical_strike, breed, hit_zone_name, difficulty_level)
	local ok, total = pcall(DamageUtils.custom_calculate_damage, attacker_unit, damage_source, power_level, damage_profile, target_index, 0, is_critical_strike, 1, false, nil, breed, hit_zone_name, 0, difficulty_level)

	return ok and total or nil
end

local function breed_health(breed, difficulty_level)
	local difficulty_settings = DifficultySettings[difficulty_level]

	return breed.max_health and difficulty_settings and breed.max_health[difficulty_settings.rank] or 0
end

local function hits_to_kill(health, damage)
	if not damage or damage <= 0 then
		return "-"
	end

	return tostring(math.ceil(health / DamageUtils.networkify_damage(damage)))
end

local profile_name_lookup = {}

local function profile_name(damage_profile)
	local name = profile_name_lookup[damage_profile]

	if not name then
		for template_name, template in pairs(DamageProfileTemplates) do
			profile_name_lookup[template] = template_name
		end

		name = profile_name_lookup[damage_profile] or "?"
	end

	return name
end

local function command_breakpoint(breed_name, hit_zone_name, crit_text)
	breed_name = breed_name or "skaven_clan_rat"
	hit_zone_name = hit_zone_name or "torso"

	local is_critical_strike = crit_text == "crit"
	local breed = Breeds[breed_name]

	if not breed then
		report("Unknown breed %s (e.g. skaven_slave, skaven_clan_rat, skaven_storm_vermin, chaos_marauder, chaos_raider, chaos_warrior, chaos_berzerker, beastmen_bestigor).", breed_name)
		return
	end

	local unit = local_player_unit()

	if not unit then
		report("No local player unit - run this in a level or the keep.")
		return
	end

	local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
	local slot_data = inventory_extension:get_slot_data(inventory_extension:get_wielded_slot_name())
	local item_data = slot_data and slot_data.item_data
	local template = inventory_extension:get_wielded_slot_item_template()

	if not (item_data and template and template.actions) then
		report("No wielded weapon with actions.")
		return
	end

	local career_extension = ScriptUnit.extension(unit, "career_system")
	local power_level = career_extension:get_career_power_level()
	local difficulty_level = Managers.state.difficulty:get_difficulty()
	local health = breed_health(breed, difficulty_level)
	local damage_source = item_data.name

	report("%s vs %s (%s%s) - %s, power %d, health %.2f. Per target: TB damage (hits) / vanilla formula", template.name, breed_name, hit_zone_name, is_critical_strike and ", crit" or "", difficulty_level, power_level, health)

	local action_names = table.keys(template.actions)

	table.sort(action_names)

	for _, action_name in ipairs(action_names) do
		local action = template.actions[action_name]
		local sub_action_names = table.keys(action)

		table.sort(sub_action_names)

		for _, sub_action_name in ipairs(sub_action_names) do
			local sub_action = action[sub_action_name]

			if type(sub_action) == "table" then
				local left_name, right_name = ActionUtils.get_damage_profile_name(sub_action, sub_action.weapon_action_hand)

				for _, name in ipairs({ left_name, right_name }) do
					local damage_profile = name and DamageProfileTemplates[name]

					if damage_profile then
						local cells = {}

						for target_index = 1, 3 do
							local tb_damage = predict_tb_damage(unit, damage_source, power_level, damage_profile, target_index, is_critical_strike, breed, hit_zone_name, difficulty_level, 0, 1, 0)
							local vanilla_damage = predict_vanilla_formula_damage(unit, damage_source, power_level, damage_profile, target_index, is_critical_strike, breed, hit_zone_name, difficulty_level)

							cells[#cells + 1] = string.format("T%d %.2f (%s) / %s", target_index, tb_damage or -1, hits_to_kill(health, tb_damage), vanilla_damage and string.format("%.2f", vanilla_damage) or "err")
						end

						report("  %s.%s [%s]: %s", action_name, sub_action_name, name, table.concat(cells, " | "))
					end
				end
			end
		end
	end
end

local hitlog_enabled = false
local last_hit_key, last_hit_t = nil, -1

mod:add_calculate_damage_observer(function (final_damage, base_damage, damage_output, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve, boost_damage_multiplier, is_critical_strike, damage_profile, target_index, backstab_multiplier, damage_source)
	if not hitlog_enabled or not target_unit or not damage_profile or attacker_unit ~= local_player_unit() then
		return
	end

	local breed = AiUtils.unit_breed(target_unit)

	if not breed or breed.is_hero then
		return
	end

	-- The same hit can be calculated twice in one frame (prediction + server apply)
	local t = Managers.time:time("game") or 0
	local hit_key = tostring(target_unit) .. tostring(damage_profile) .. tostring(target_index)

	if hit_key == last_hit_key and t - last_hit_t < 0.05 then
		return
	end

	last_hit_key, last_hit_t = hit_key, t

	local difficulty_level = Managers.state.difficulty:get_difficulty()
	local _, predicted_base = predict_tb_damage(attacker_unit, damage_source, original_power_level, damage_profile, target_index or 1, is_critical_strike, breed, hit_zone_name, difficulty_level, boost_damage_multiplier, backstab_multiplier, 0)
	local match = predicted_base and math.abs(predicted_base - base_damage) < 0.01

	report("%s %s T%s%s [%s] power %d: base %.2f, predicted %.2f -> %s | final %.2f (x%.2f stagger) | health %.2f, %s hits",
		breed.name, hit_zone_name, tostring(target_index), is_critical_strike and " crit" or "", profile_name(damage_profile), original_power_level,
		base_damage, predicted_base or -1, match and "MATCH" or "MISMATCH",
		final_damage, base_damage > 0 and final_damage / base_damage or 0, breed_health(breed, difficulty_level), hits_to_kill(breed_health(breed, difficulty_level), final_damage))
end)

local function command_hitlog()
	hitlog_enabled = not hitlog_enabled
	report("Hit log %s.", hitlog_enabled and "ON - hit enemies to compare predicted vs actual damage" or "OFF")
end

mod:command("tbs_breakpoint", "Weapon editor spike: breakpoints of the wielded weapon vs a breed ([breed] [hit_zone] [crit]).", command_breakpoint)
mod:command("tbs_hitlog", "Weapon editor spike: toggle logging real hits vs predicted damage.", command_hitlog)
mod:command("tbs_imgui","Weapon editor spike: open/close a test window (editor|debug|float|off).", command_imgui)
mod:command("tbs_clipboard", "Weapon editor spike: test Clipboard.put from a mod.", command_clipboard)
mod:command("tbs_get", "Weapon editor spike: show live/TB/vanilla value of a path.", command_get)
mod:command("tbs_set", "Weapon editor spike: set a Weapons/DamageProfileTemplates leaf value live.", command_set)
mod:command("tbs_revert", "Weapon editor spike: revert all spike edits to the TB baseline.", command_revert)
mod:command("tbs_export", "Weapon editor spike: export edits as Lua with vanilla comments.", command_export)
mod:command("tbs_verify", "Weapon editor spike: after rebuild+relaunch, check exported edits are now baseline.", command_verify)
mod:command("tbs_drift", "Weapon editor spike: find float32 drift vs TB baseline ('fix' restores it).", command_drift)

if vanilla_tainted then
	report("Vanilla snapshot taken after TourneyBalance already ran - restart the game for correct vanilla comments.")
end
