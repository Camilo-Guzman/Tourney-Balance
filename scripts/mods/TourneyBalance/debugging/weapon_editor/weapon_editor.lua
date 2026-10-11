local mod = get_mod("TourneyBalance")

--[[

	Weapon editor (dev tool, off by default)

	Edit Weapons/DamageProfileTemplates values live in game, then export them as Lua to
	paste into the weapon change files. Every exported value carries a "-- vanilla:" comment.

	Flow:
		/tbwe                open/close the editor window (F3 switches between using it and playing)
		edit values          they apply to the next swing/hit, no re-equip needed. Damage profiles
		                     open with an "attack sheet" (per-target columns, armor types named)
		fork                 copy a profile into a new tb_ profile and point this attack (or all
		                     attacks of the weapon using it) at it - exports as a new block
		breakpoints          button on any attack (or /tbwe_breakpoints): hits-to-kill grid comparing
		                     now / TB / vanilla, plus a hit log checking predictions against real hits
		/tbwe_export         copies the export to the clipboard (and the console log)
		paste, rebuild, restart
		                     on launch, edits that are now in the files are dropped automatically,
		                     anything else is re-applied, and /tbwe_status reports which is which

	Snapshots:
		vanilla      taken when this file loads, before any change file runs (see TourneyBalance.lua)
		TB baseline  taken once all mods have loaded, before any editor edit

	Solo/host only: the server resolves damage from its own tables.

	Shared tables: vanilla profiles hold PowerLevelTemplates presets (and sometimes each
	other's sub-tables) by reference. Editing a damage profile field inside one copies it into
	that profile first, so the edit can't leak into every other weapon using the same preset.
	Weapons tables shared between templates are only flagged - the change files share them too.

]]

local ENABLED = false

if not ENABLED then
	return
end

local core = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_core")
local export = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_export")
local ui = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_ui")
local breakpoints = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_breakpoints")

local SUPPORTED_ROOTS = {
	Weapons = true,
	DamageProfileTemplates = true,
}

local SAVED_EDITS_SETTING = "tbwe_saved_edits"
local SAVED_FORKS_SETTING = "tbwe_saved_forks"
local INPUT_SERVICE_NAME = "tb_weapon_editor"
local INPUT_CAPTURE_OWNER = "TBWeaponEditor"

local function report(format, ...)
	local message = string.format(format, ...)

	mod:echo("[Weapon editor] " .. message)
	print("[Weapon editor] " .. message)
end

local function capture_tables()
	-- One shared `seen`, so a profile's reference to a PowerLevelTemplates preset is still
	-- the same table as the snapshot's own copy of that preset
	local seen = {}

	return {
		Weapons = core.deep_copy(Weapons, seen),
		DamageProfileTemplates = core.deep_copy(DamageProfileTemplates, seen),
		PowerLevelTemplates = core.deep_copy(PowerLevelTemplates, seen),
	}
end

--[[
	State - kept in a global so it outlives a VMF hot reload, which re-runs the change files
	without resetting Weapons/DamageProfileTemplates
]]

local STATE_GLOBAL = "TB_WEAPON_EDITOR_STATE"
local state = rawget(_G, STATE_GLOBAL)

if state then
	-- Change files just re-ran over the live tables and may have overwritten edits
	state.needs_reapply = true
else
	state = {
		-- NewDamageProfileTemplates also survives a reload, so entries in it already mean
		-- this first snapshot happens after TourneyBalance ran once (enabled mid-session)
		vanilla_tainted = next(NewDamageProfileTemplates) ~= nil,
		vanilla = capture_tables(),
		tb_baseline = nil,
		edits = {},
		cow = {},
		forks = {},
		needs_reapply = false,
	}

	rawset(_G, STATE_GLOBAL, state)
end

-- State carried over a hot reload from an older version of this file
state.forks = state.forks or {}

local editor = {
	state = state,
	core = core,
	report = report,
	window_open = false,
	interacting = false,
	selected_template = nil,
	ui_state = {},
	-- Bumped on every edit/revert so cached breakpoint grids know to recompute
	edit_generation = 0,
	breakpoints_open = false,
	breakpoint_target = nil, -- keys of the sub-action shown in the breakpoint window
}

-- A fork was created or deleted: cached profile lists are stale
function editor.on_profiles_changed()
	ui.invalidate_profile_caches(editor)
end

--[[
	Shared-table lookups (built on first use)
]]

local preset_names = nil -- live PowerLevelTemplates table (and sub-table) -> "name.sub.path"
local profile_owner_counts = nil -- live DamageProfileTemplates sub-table -> number of profiles holding it
local weapon_owners = nil -- live Weapons actions sub-table -> { template names }

local function build_preset_names()
	preset_names = setmetatable({}, { __mode = "k" })

	local function visit(t, label, depth)
		if preset_names[t] or depth > 5 then
			return
		end

		preset_names[t] = label

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
end

local function build_profile_owner_counts()
	profile_owner_counts = setmetatable({}, { __mode = "k" })

	for _, profile in pairs(DamageProfileTemplates) do
		local seen = {}

		local function visit(t, depth)
			if seen[t] or depth > 6 then
				return
			end

			seen[t] = true
			profile_owner_counts[t] = (profile_owner_counts[t] or 0) + 1

			for _, v in pairs(t) do
				if type(v) == "table" then
					visit(v, depth + 1)
				end
			end
		end

		if type(profile) == "table" then
			visit(profile, 1)
		end
	end
end

local function build_weapon_owners()
	weapon_owners = setmetatable({}, { __mode = "k" })

	for template_name, template in pairs(Weapons) do
		local actions = type(template) == "table" and template.actions

		if type(actions) == "table" then
			local seen = {}

			local function visit(t, depth)
				if seen[t] or depth > 6 then
					return
				end

				seen[t] = true

				local owners = weapon_owners[t]

				if not owners then
					owners = {}
					weapon_owners[t] = owners
				end

				owners[#owners + 1] = template_name

				for k, v in pairs(t) do
					if type(v) == "table" and not core.EXCLUDED_KEYS[k] then
						visit(v, depth + 1)
					end
				end
			end

			visit(actions, 1)
		end
	end
end

-- Name of the live PowerLevelTemplates preset this table is (or lives inside), or nil
function editor.preset_name(t)
	if not preset_names then
		build_preset_names()
	end

	return preset_names[t]
end

local function is_shared_profile_table(t)
	if editor.preset_name(t) then
		return true
	end

	if not profile_owner_counts then
		build_profile_owner_counts()
	end

	return (profile_owner_counts[t] or 0) > 1
end

-- Other templates whose actions also hold this exact table, or nil
function editor.weapon_sharing(t, current_template_name)
	if not weapon_owners then
		build_weapon_owners()
	end

	local owners = weapon_owners[t]

	if not owners or #owners < 2 then
		return nil
	end

	local others = {}

	for _, name in ipairs(owners) do
		if name ~= current_template_name then
			others[#others + 1] = name
		end
	end

	table.sort(others)

	return others
end

-- Every action field that points at this profile, plus what it pointed at in vanilla
function editor.profile_users(profile_name)
	local users = {}

	local function scan(t, keys, depth)
		for k, v in pairs(t) do
			if type(k) == "string" and v == profile_name and k:find("damage_profile", 1, true) then
				local field_keys = core.append_key(keys, k)

				users[#users + 1] = {
					keys = field_keys,
					vanilla_profile = core.snapshot_value(state.vanilla, field_keys),
				}
			elseif type(v) == "table" and depth < 3 and not core.EXCLUDED_KEYS[k] then
				scan(v, core.append_key(keys, k), depth + 1)
			end
		end
	end

	for template_name, template in pairs(Weapons) do
		local actions = type(template) == "table" and template.actions

		if type(actions) == "table" then
			for action_name, action in pairs(actions) do
				if type(action) == "table" then
					for sub_action_name, sub_action in pairs(action) do
						if type(sub_action) == "table" then
							scan(sub_action, { "Weapons", template_name, "actions", action_name, sub_action_name }, 1)
						end
					end
				end
			end
		end
	end

	table.sort(users, function (a, b)
		return core.format_path(a.keys) < core.format_path(b.keys)
	end)

	return users
end

--[[
	Edits
]]

local function save_edits()
	local paths = {}

	for path in pairs(state.edits) do
		paths[#paths + 1] = path
	end

	table.sort(paths)

	local lines = {}

	for _, path in ipairs(paths) do
		lines[#lines + 1] = path .. "\t" .. core.encode_value(state.edits[path].value)
	end

	mod:set(SAVED_EDITS_SETTING, table.concat(lines, "\n"))
end

local function flush_mechanism_cache()
	-- Templates with mechanism_overrides are shallow-copied and cached per mechanism
	if MechanismOverrides and MechanismOverrides.mechanism_switched then
		MechanismOverrides.mechanism_switched()
	end
end

-- Swaps each shared table on the way to the edited field for a private copy
local function copy_on_write(keys)
	local node = DamageProfileTemplates[keys[2]]

	for i = 3, #keys - 1 do
		local child = node[keys[i]]

		if type(child) ~= "table" then
			return
		end

		if is_shared_profile_table(child) then
			local clone = core.deep_copy(child)
			local prefix = core.sub_keys(keys, i)

			node[keys[i]] = clone
			state.cow[core.format_path(prefix)] = {
				keys = prefix,
				original = child,
			}
			child = clone
		end

		node = child
	end
end

-- Puts shared tables back once no edit underneath them is left
local function restore_unused_copies()
	for cow_path, record in pairs(state.cow) do
		local in_use = false

		for path in pairs(state.edits) do
			if core.path_is_under(path, cow_path) then
				in_use = true

				break
			end
		end

		if not in_use then
			local _, ancestors = core.live_value(record.keys)
			local parent = ancestors[#ancestors]

			if type(parent) == "table" then
				parent[record.keys[#record.keys]] = record.original
			end

			state.cow[cow_path] = nil
		end
	end
end

function editor.apply_edit(keys, value)
	if #keys < 3 or not SUPPORTED_ROOTS[keys[1]] then
		return false, "only Weapons.* and DamageProfileTemplates.* fields can be edited"
	end

	local current, ancestors = core.live_value(keys)

	if #ancestors ~= #keys - 1 or type(ancestors[#ancestors]) ~= "table" then
		return false, "path doesn't resolve"
	end

	if type(current) == "table" then
		return false, "not a leaf value"
	end

	if current ~= nil and type(current) ~= type(value) then
		return false, string.format("type mismatch (field is %s, got %s)", type(current), type(value))
	end

	if keys[1] == "DamageProfileTemplates" then
		copy_on_write(keys)
	end

	local _, write_ancestors = core.live_value(keys)

	write_ancestors[#write_ancestors][keys[#keys]] = value
	editor.edit_generation = editor.edit_generation + 1

	local path = core.format_path(keys)
	local baseline = core.snapshot_value(state.tb_baseline, keys)

	if core.values_equal(value, baseline) then
		state.edits[path] = nil

		restore_unused_copies()
	else
		state.edits[path] = {
			keys = keys,
			value = value,
			baseline = baseline,
		}
	end

	flush_mechanism_cache()
	save_edits()

	return true
end

function editor.revert_matching(predicate)
	local count = 0

	for path, edit in pairs(state.edits) do
		if predicate(path, edit) then
			local _, ancestors = core.live_value(edit.keys)
			local parent = ancestors[#ancestors]

			if type(parent) == "table" and #ancestors == #edit.keys - 1 then
				parent[edit.keys[#edit.keys]] = edit.baseline
			end

			state.edits[path] = nil
			count = count + 1
		end
	end

	restore_unused_copies()
	flush_mechanism_cache()
	save_edits()

	editor.edit_generation = editor.edit_generation + 1

	return count
end

function editor.revert_edit(path)
	return editor.revert_matching(function (edit_path)
		return edit_path == path
	end)
end

function editor.revert_template(template_name)
	return editor.revert_matching(function (_, edit)
		return edit.keys[1] == "Weapons" and edit.keys[2] == template_name
	end)
end

function editor.revert_profile(profile_name)
	return editor.revert_matching(function (_, edit)
		return edit.keys[1] == "DamageProfileTemplates" and edit.keys[2] == profile_name
	end)
end

function editor.revert_all()
	return editor.revert_matching(function ()
		return true
	end)
end

function editor.edit_count()
	local count = 0

	for _ in pairs(state.edits) do
		count = count + 1
	end

	return count
end

--[[
	Forks: a copy of an existing profile under a new tb_ name, with the chosen actions pointed
	at it - the same thing the change files do by hand with NewDamageProfileTemplates.tb_x
]]

local function save_forks()
	local names = table.keys(state.forks)

	table.sort(names)

	local lines = {}

	for _, name in ipairs(names) do
		lines[#lines + 1] = name .. "\t" .. state.forks[name].source
	end

	mod:set(SAVED_FORKS_SETTING, table.concat(lines, "\n"))
end

-- Builds the profile the way the change files + _damage_profile_setup.lua would:
-- an authored copy that names untouched PowerLevelTemplates presets, and a live copy that
-- references them (so a later edit copies the preset first, like any other shared table).
local function create_fork(source_name, new_name)
	local source = DamageProfileTemplates[source_name]
	local preset_by_table = {}

	for name, preset in pairs(PowerLevelTemplates) do
		if type(preset) == "table" then
			preset_by_table[preset] = name
		end
	end

	local authored, live = {}, {}

	for k, v in pairs(source) do
		if type(v) == "table" and preset_by_table[v] then
			authored[k] = preset_by_table[v]
			live[k] = v
		else
			authored[k] = core.deep_copy(v)
			live[k] = core.deep_copy(v)
		end
	end

	NewDamageProfileTemplates[new_name] = authored
	DamageProfileTemplates[new_name] = live

	-- _damage_profile_setup.lua gives every profile a zero-attack "_no_damage" twin, which
	-- area_damage_system.lua looks up by name at runtime
	local no_damage = core.deep_copy(live)

	for _, target in ipairs(type(no_damage.targets) == "table" and no_damage.targets or {}) do
		if target.power_distribution then
			target.power_distribution.attack = 0
		end
	end

	if type(no_damage.default_target) == "table" and no_damage.default_target.power_distribution then
		no_damage.default_target.power_distribution.attack = 0
	end

	DamageProfileTemplates[new_name .. "_no_damage"] = no_damage

	-- Hits send the profile as a NetworkLookup id. The table errors on unknown keys, hence rawget.
	local lookup = NetworkLookup.damage_profiles

	if not rawget(lookup, new_name) then
		local index = #lookup + 1

		lookup[index] = new_name
		lookup[new_name] = index
	end

	-- Edits inside the fork compare against (and revert to) its values at fork time
	state.tb_baseline.DamageProfileTemplates[new_name] = core.deep_copy(live)
	state.forks[new_name] = {
		source = source_name,
	}

	if profile_owner_counts then
		build_profile_owner_counts()
	end

	if editor.on_profiles_changed then
		editor.on_profiles_changed()
	end
end

function editor.fork_profile(source_name, new_name, field_keys_list)
	if type(new_name) ~= "string" or not new_name:match("^tb_[%w_]+$") then
		return false, "name must start with tb_ and contain only letters, digits and _"
	end

	if DamageProfileTemplates[new_name] or NewDamageProfileTemplates[new_name] then
		return false, new_name .. " already exists"
	end

	if not DamageProfileTemplates[source_name] then
		return false, "unknown source profile " .. tostring(source_name)
	end

	create_fork(source_name, new_name)
	save_forks()

	for _, field_keys in ipairs(field_keys_list) do
		local ok, err = editor.apply_edit(field_keys, new_name)

		if not ok then
			report("Couldn't point %s at %s: %s", core.format_path(field_keys), new_name, err)
		end
	end

	report("Forked %s into %s for %d attack(s).", source_name, new_name, #field_keys_list)

	return true
end

function editor.delete_fork(name)
	if not state.forks[name] then
		return
	end

	-- Point every field using it back first, then drop edits inside it
	editor.revert_matching(function (_, edit)
		return (edit.keys[1] == "Weapons" and edit.value == name) or (edit.keys[1] == "DamageProfileTemplates" and edit.keys[2] == name)
	end)

	NewDamageProfileTemplates[name] = nil
	DamageProfileTemplates[name] = nil
	DamageProfileTemplates[name .. "_no_damage"] = nil
	state.tb_baseline.DamageProfileTemplates[name] = nil
	state.forks[name] = nil

	save_forks()

	if editor.on_profiles_changed then
		editor.on_profiles_changed()
	end

	report("Deleted fork %s.", name)
end

local function restore_saved_forks()
	local saved = mod:get(SAVED_FORKS_SETTING)

	if type(saved) ~= "string" or saved == "" then
		return
	end

	for line in saved:gmatch("[^\n]+") do
		local name, source = line:match("^(.-)\t(.*)$")

		-- Already defined means the exported block made it into the files
		if name and not DamageProfileTemplates[name] then
			if DamageProfileTemplates[source] then
				create_fork(source, name)
			else
				report("Couldn't restore fork %s: source %s no longer exists", name, source)
			end
		end
	end

	save_forks()
end

-- After a hot reload the change files overwrote whatever they set, so put the edits back
local function reapply_edits()
	local edits = state.edits

	state.edits = {}

	for _, edit in pairs(edits) do
		editor.apply_edit(edit.keys, edit.value)
	end

	state.needs_reapply = false
end

local function restore_saved_edits()
	local saved = mod:get(SAVED_EDITS_SETTING)

	if type(saved) ~= "string" or saved == "" then
		return
	end

	local restored, landed, failed = 0, 0, 0

	for line in saved:gmatch("[^\n]+") do
		local path, encoded = line:match("^(.-)\t(.*)$")

		if path then
			local keys = core.parse_path(path)
			local value = core.decode_value(encoded)

			if core.values_equal(core.snapshot_value(state.tb_baseline, keys), value) then
				landed = landed + 1
			elseif editor.apply_edit(keys, value) then
				restored = restored + 1
			else
				failed = failed + 1
				report("Couldn't restore saved edit %s", path)
			end
		end
	end

	save_edits()

	editor.last_restore = {
		restored = restored,
		landed = landed,
		failed = failed,
	}

	report("Last session's edits: %d now in the files (dropped), %d re-applied, %d failed.", landed, restored, failed)
end

mod:add_all_mods_loaded_function(function ()
	if not state.tb_baseline then
		state.tb_baseline = capture_tables()

		-- Forks first: saved edits may point actions at them or edit inside them
		restore_saved_forks()
		restore_saved_edits()
	elseif state.needs_reapply then
		reapply_edits()
	end
end)

--[[
	Export
]]

local function put_on_clipboard(text)
	if not rawget(_G, "Clipboard") then
		return false
	end

	local ok = pcall(Clipboard.put, text)

	if not ok then
		return false
	end

	local read_ok, read_back = pcall(Clipboard.get)

	return read_ok and read_back == text
end

function editor.export()
	if editor.edit_count() == 0 and next(state.forks) == nil then
		report("Nothing to export.")
		return
	end

	local text, count = export.build(editor)

	print("[Weapon editor] ---- export begin ----")
	print(text)
	print("[Weapon editor] ---- export end ----")

	if put_on_clipboard(text) then
		report("Exported %d edit(s) to the clipboard.", count)
	else
		report("Clipboard unavailable - the export is in the console log between the begin/end markers.")
	end
end

--[[
	Window and input
]]

rawset(_G, "TBWeaponEditorKeymaps", rawget(_G, "TBWeaponEditorKeymaps") or {
	win32 = {
		tb_weapon_editor_toggle = {
			"keyboard",
			"f3",
			"pressed",
		},
	},
})

local function set_interacting(interacting)
	if editor.interacting == interacting then
		return
	end

	local input_manager = Managers.input

	if input_manager then
		local ok, err = pcall(function ()
			if not input_manager:get_input_service(INPUT_SERVICE_NAME) then
				input_manager:create_input_service(INPUT_SERVICE_NAME, "TBWeaponEditorKeymaps")
				input_manager:map_device_to_service(INPUT_SERVICE_NAME, "keyboard")
				input_manager:map_device_to_service(INPUT_SERVICE_NAME, "mouse")
				input_manager:map_device_to_service(INPUT_SERVICE_NAME, "gamepad")
			end

			local method = interacting and "capture_input" or "release_input"

			input_manager[method](input_manager, ALL_INPUT_METHODS, 1, INPUT_SERVICE_NAME, INPUT_CAPTURE_OWNER)
		end)

		if not ok then
			report("Input capture failed: %s", tostring(err))
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

	editor.interacting = interacting
end

local function open_window()
	if editor.window_open then
		return
	end

	if state.needs_reapply then
		reapply_edits()
	end

	if not editor.selected_template then
		pcall(editor.select_wielded, true)
	end

	Imgui.open_imgui()

	editor.window_open = true

	set_interacting(true)
	report("F3 switches between using the editor and playing.")
end

local function close_window()
	if not editor.window_open then
		return
	end

	set_interacting(false)
	Imgui.close_imgui()

	editor.window_open = false
end

function editor.close()
	close_window()
end

-- First attack (sorted by name, action_one first) of the selected template that has a damage profile
local function default_breakpoint_target()
	local template = editor.selected_template and Weapons[editor.selected_template]
	local actions = template and template.actions

	if type(actions) ~= "table" then
		return nil
	end

	local action_names = core.sorted_keys(actions)

	table.sort(action_names, function (a, b)
		if a == "action_one" or b == "action_one" then
			return a == "action_one"
		end

		return a < b
	end)

	for _, action_name in ipairs(action_names) do
		local action = actions[action_name]

		if type(action) == "table" then
			for _, sub_action_name in ipairs(core.sorted_keys(action)) do
				local sub_action = action[sub_action_name]

				if type(sub_action) == "table" then
					local left_name, right_name = ActionUtils.get_damage_profile_name(sub_action, sub_action.weapon_action_hand)

					if left_name or right_name then
						return { "Weapons", editor.selected_template, "actions", action_name, sub_action_name }
					end
				end
			end
		end
	end

	return nil
end

function editor.toggle_breakpoints()
	editor.breakpoints_open = not editor.breakpoints_open

	if editor.breakpoints_open and not editor.breakpoint_target then
		editor.breakpoint_target = default_breakpoint_target()
	end
end

-- keys: path of a sub-action, e.g. { "Weapons", template, "actions", action, sub_action }
function editor.show_breakpoints(keys)
	editor.breakpoint_target = keys
	editor.breakpoints_open = true
end

function editor.select_template(template_name)
	if Weapons[template_name] then
		editor.selected_template = template_name
	end
end

function editor.select_wielded(silent)
	local player = Managers.player and Managers.player:local_player()
	local unit = player and player.player_unit

	if not (unit and Unit.alive(unit)) then
		if not silent then
			report("No player unit.")
		end

		return
	end

	local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
	local slot_data = inventory_extension:get_slot_data(inventory_extension:get_wielded_slot_name())
	local item_data = slot_data and slot_data.item_data
	local template_name = item_data and (item_data.temporary_template or item_data.template)

	if template_name and Weapons[template_name] then
		editor.select_template(template_name)
	elseif not silent then
		report("Wielded item has no weapon template.")
	end
end

mod:add_update_function(function ()
	if not editor.window_open then
		return
	end

	if Keyboard.pressed(Keyboard.button_index("f3")) then
		set_interacting(not editor.interacting)
	end

	local ok, do_close = pcall(ui.draw, editor)

	if not ok then
		report("Window error, closing: %s", tostring(do_close))
		close_window()

		return
	elseif do_close then
		close_window()

		return
	end

	if editor.breakpoints_open then
		local t = Managers.time and Managers.time:time("main") or 0
		local bp_ok, bp_close = pcall(breakpoints.draw, editor, t)

		if not bp_ok then
			report("Breakpoint window error, closing it: %s", tostring(bp_close))

			editor.breakpoints_open = false
		elseif bp_close then
			editor.breakpoints_open = false
		end
	end
end)

mod:add_calculate_damage_observer(breakpoints.on_calculate_damage)

-- Input services and the cursor stack don't survive a level/state change cleanly
mod:add_game_state_changed_function(function ()
	close_window()
end)

--[[
	Commands
]]

mod:command("tbwe", "Weapon editor: open/close the editor window.", function ()
	if editor.window_open then
		close_window()
	else
		open_window()
	end
end)

mod:command("tbwe_breakpoints", "Weapon editor: show/hide the breakpoint window (opens the editor too).", function ()
	open_window()
	editor.toggle_breakpoints()
end)

mod:command("tbwe_export", "Weapon editor: copy all edits as Lua (with vanilla comments) to the clipboard.", function ()
	editor.export()
end)

mod:command("tbwe_revert_all", "Weapon editor: revert every edit to the TB baseline.", function ()
	report("Reverted %d edit(s).", editor.revert_all())
end)

mod:command("tbwe_status", "Weapon editor: list current edits and what happened to last session's.", function ()
	local restore = editor.last_restore

	if restore then
		report("At launch: %d edit(s) were in the files (dropped), %d re-applied, %d failed.", restore.landed, restore.restored, restore.failed)
	end

	local paths = {}

	for path in pairs(state.edits) do
		paths[#paths + 1] = path
	end

	table.sort(paths)
	report("%d edit(s) pending export.", #paths)

	for _, path in ipairs(paths) do
		local edit = state.edits[path]

		report("  %s = %s (TB %s)", path, core.format_value(edit.value), core.format_value(edit.baseline))
	end
end)

if state.vanilla_tainted then
	report("Vanilla snapshot was taken after TourneyBalance already ran - restart the game for correct vanilla comments.")
end
