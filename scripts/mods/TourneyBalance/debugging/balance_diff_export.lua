local mod = get_mod("TourneyBalance")

--[[

	Balance diff export (dev tool, off by default)

	Snapshots the weapon/damage-profile data tables *before* any of this mod's own
	changes run, then on demand (via chat command) snapshots again and recursively
	diffs the two into a flat list of {path, before, after} entries - the raw data
	feeding the auto-generated "weapon changes" doc page. Posted as JSON to a local
	listener via Managers.curl (see EXPORT_URL below) rather than written to disk,
	since VMF mods have no confirmed file-write path but Managers.curl + cjson are
	proven in production (RatNet, Lifes Hard Everywhere both POST JSON externally).

	ENABLED must be flipped to true and the mod reloaded (full game restart, not just
	a hot-reload - see note above `before_snapshot` below) for this file to do
	anything. This file must load before 00_spicy_enemies/01_thp_stagger_damage_changes/
	02_career_changes/03_weapon_changes - see TourneyBalance.lua dofile order.

	Usage: run a local listener on EXPORT_URL's port that writes the POST body to a
	file, then in-game run "/tb_export_weapon_diff".

]]

local ENABLED = false

if not ENABLED then
	return
end

local EXPORT_URL = "http://localhost:4545/weapon-diff"

-- Tables mutated by this mod's weapon/damage-profile changes. Extend this list if a
-- future change touches something not already covered here - an unused entry just
-- costs a bit of snapshot time, it can't cause a false diff, since the diff only
-- reports fields that actually differ between the two snapshots.
--
-- NewDamageProfileTemplates deliberately isn't tracked separately: _damage_profile_setup.lua
-- merges every entry from it into DamageProfileTemplates, so tracking both would report
-- the same new/changed profile twice, once under each top-level name.
local TRACKED_GLOBALS = {
	"Weapons",
	"DamageProfileTemplates",
	"SpreadTemplates",
	"ExplosionTemplates",
	"ActionTemplates",
	"PowerLevelTemplates",
	"PlayerUnitStatusSettings",
	"EnergyData",
	"DotTypeLookup",
	"BalefireBurnDotLookup",
	"BalefireDots",
	"BuffTemplates",
}

-- Globals whose entries should be diffed as one atomic unit - full "before" table vs
-- full "after" table - rather than recursed into field-by-field. A damage profile or
-- buff template reads as one coherent definition: if a change touches 2 of its 15
-- fields, "before: {the whole 15-field profile}, after: {the whole 15-field profile}"
-- documents the change far better than 2 leaf-level entries scattered among
-- everything else that changed, with no indication they belong to the same entry.
-- BuffTemplates belongs here because mod_api.insert_buff_template/insert_talent_buff_template
-- always do a full BuffTemplates[name] = {...} replace, same as DamageProfileTemplates -
-- e.g. burning_magma_dot is a genuine vanilla Winds of Magic buff (morris_buff_settings.lua)
-- that insert_buff_template silently overwrites wholesale, not a brand new name.
local ATOMIC_ENTRY_GLOBALS = {
	DamageProfileTemplates = true,
	BuffTemplates = true,
}

local FUNCTION_PLACEHOLDER = "<function>"

-- Keys the engine stamps onto a table at resolve/use time rather than anything a
-- change file ever assigns - e.g. lookup_data ({sub_action_name, action_name,
-- item_template_name}) gets attached to an action's sub-action table the first time
-- something actually resolves it, purely so that code can trace the table back to
-- where it lives. It's derivable from the path itself and never reflects an authored
-- change, so it's dropped at snapshot time rather than diffed - excluding it here
-- (not just from ATOMIC_ENTRY_FIELD_NAMES output) means it can never leak into any
-- diff shape, including nested inside an atomic entry's full before/after table.
local EXCLUDED_KEYS = {
	lookup_data = true,
}

-- Deep-clones a value. Functions/userdata/threads become a placeholder string -
-- neither diffable nor JSON-encodable as anything meaningful. `seen` (keyed by
-- original table identity) guards against cycles and against re-cloning a table
-- that's shared by reference from two different paths (e.g. two weapons pointing at
-- the same ActionTemplates entry) - both places get the same clone, matching the
-- original aliasing instead of silently duplicating it.
local function snapshot_value(value, seen)
	local value_type = type(value)

	if value_type == "table" then
		if seen[value] then
			return seen[value]
		end

		local copy = {}
		seen[value] = copy

		for k, v in pairs(value) do
			if not EXCLUDED_KEYS[k] then
				copy[snapshot_value(k, seen)] = snapshot_value(v, seen)
			end
		end

		return copy
	elseif value_type == "function" or value_type == "userdata" or value_type == "thread" then
		return FUNCTION_PLACEHOLDER
	elseif value_type == "number" then
		-- cjson can't represent IEEE-754 NaN/Infinity (no JSON literal for either),
		-- and math.huge end_time/similar "never" sentinels are common in weapon data.
		if value ~= value then
			return "NaN"
		elseif value == math.huge then
			return "Infinity"
		elseif value == -math.huge then
			return "-Infinity"
		end
		return value
	else
		return value
	end
end

local function capture_snapshot()
	local seen = {}
	local snapshot = {}

	for _, global_name in ipairs(TRACKED_GLOBALS) do
		local value = rawget(_G, global_name)
		if value ~= nil then
			snapshot[global_name] = snapshot_value(value, seen)
		end
	end

	return snapshot
end

-- Captured now, before any of this mod's other files have run - this is "official"
-- data as far as this mod is concerned. Any OTHER mod that loaded earlier than
-- TourneyBalance is baked into this baseline too, so for a clean official-vs-mod
-- diff, generate it in a session with only TourneyBalance enabled.
--
-- This only runs once, at the point this chunk first executes. A VMF hot-reload
-- re-runs the file but does NOT reset Weapons/DamageProfileTemplates/etc. back to
-- vanilla first (same base-game-global-outlives-a-reload behavior covered in
-- mod_api.md's known quirks) - so a "before" snapshot taken on a hot-reload would
-- actually be "vanilla + whatever this mod already applied last time", not true
-- vanilla. Get this snapshot from a fresh game launch, not a reload.
local before_snapshot = capture_snapshot()

-- DamageProfileTemplates entries auto-generated by _damage_profile_setup.lua's
-- "_no_damage" pass are mechanical clones of their base profile (only
-- power_distribution.attack zeroed) - reporting them as an independent change would
-- just duplicate whatever already got reported for the base profile they were cloned
-- from, and a name ending in "_no_damage" is never something a weapon change
-- meaningfully points at directly either.
local function is_no_damage_variant(name)
	return type(name) == "string" and name:sub(-("_no_damage"):len()) == "_no_damage"
end

-- Field names that hold a DamageProfileTemplates key as their value - damage_profile,
-- damage_profile_aoe, bot_damage_profile, damage_profile_glance, and similar. Matched
-- by substring rather than an exhaustive list of every variant vanilla uses, since a
-- name this function doesn't recognize just silently skips the enrichment below
-- rather than breaking anything.
local function is_damage_profile_field(field_name)
	return type(field_name) == "string" and field_name:find("damage_profile", 1, true) ~= nil
end

local function last_path_segment(path)
	return path:match("([^.%[%]]+)$")
end

-- Field names that should be diffed as one atomic unit wherever they appear, at any
-- depth inside a non-atomic global - same rationale as ATOMIC_ENTRY_GLOBALS above,
-- just for collection-shaped fields nested inside Weapons rather than a whole
-- top-level named table. These are fields this mod always reassigns wholesale (a
-- literal "= { ... }" covering the whole collection) rather than editing
-- element-by-element, so recursing into them scatters one coherent change - a
-- rewritten breed-priority list, a rewritten chain-action sequence - into a pile of
-- unrelated-looking add/remove/change entries with individual elements that don't
-- mean anything in isolation (e.g. "index 3 of allowed_chain_actions" depends on the
-- whole transition list around it). Extend this list as more wholesale-reassignment
-- cases turn up.
local ATOMIC_ENTRY_FIELD_NAMES = {
	prioritized_breeds = true,
	allowed_chain_actions = true,
	baked_sweep = true,
	hit_mass_count = true,
}

-- cjson drops a table key whose value is Lua nil (there's nothing to encode), so a
-- brand new field would otherwise show up in the JSON as "before" simply missing from
-- the entry (instead of explicitly "there was nothing here before"), and symmetrically
-- a removed field would show up as "after" simply missing (instead of explicitly
-- "nothing is here anymore").
local function coerce_missing(value)
	if value == nil then
		return "None"
	end
	return value
end

-- Structural equality, ignoring table identity - used only to decide *whether*
-- something inside an atomic entry changed, never to describe *what* changed (that's
-- the point: the caller reports the whole before/after table either way).
local function deep_equal(a, b)
	if a == b then
		return true
	end

	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end

	for k, v in pairs(a) do
		if not deep_equal(v, b[k]) then
			return false
		end
	end

	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

-- Recursively diffs two snapshots, appending {path, before, after} entries to `out`.
-- Only recurses where BOTH sides are tables - a key that's a table on one side and
-- nil/non-table on the other (a brand new or fully removed branch) is recorded as a
-- single entry with the whole sub-table as before/after, rather than exploded into
-- one entry per leaf field. Existing branches present on both sides get diffed
-- leaf-by-leaf, including array-shaped tables (index-by-index) - except a field name
-- listed in ATOMIC_ENTRY_FIELD_NAMES, which always reports as one atomic entry
-- instead, even when both sides are tables.
--
-- `before_damage_profiles`/`after_damage_profiles` are the two snapshots' whole
-- DamageProfileTemplates tables, threaded through purely so a leaf whose field name
-- looks like a damage-profile reference can resolve both the old and new profile it
-- points to - a bare "before: sword_attack_1, after: tb_custom_template" string diff
-- says nothing about what actually changed, since the two names aren't otherwise
-- related the way an old/new number is.
local function diff_into(path, before, after, out, before_damage_profiles, after_damage_profiles)
	if before == after then
		-- Reference/primitive equality only - two different table clones of
		-- identical content still fall through to the table branch below, which
		-- correctly finds zero differences (just costs a bit more walking).
		return
	end

	if ATOMIC_ENTRY_FIELD_NAMES[last_path_segment(path)] then
		if not deep_equal(before, after) then
			out[#out + 1] = {
				path = path,
				before = coerce_missing(before),
				after = coerce_missing(after),
			}
		end
		return
	end

	if type(before) == "table" and type(after) == "table" then
		local seen_keys = {}

		for k in pairs(before) do
			seen_keys[k] = true
		end
		for k in pairs(after) do
			seen_keys[k] = true
		end

		for k in pairs(seen_keys) do
			local child_path
			if type(k) == "string" then
				child_path = (path == "") and k or (path .. "." .. k)
			else
				child_path = path .. "[" .. tostring(k) .. "]"
			end

			diff_into(child_path, before[k], after[k], out, before_damage_profiles, after_damage_profiles)
		end
	else
		local entry = {
			path = path,
			before = coerce_missing(before),
			after = coerce_missing(after),
		}

		-- Not a simple value change - the string itself changed identity, not just
		-- magnitude, so pull in the full profile each side actually resolves to.
		if type(before) == "string" and type(after) == "string"
			and not is_no_damage_variant(before) and not is_no_damage_variant(after)
			and is_damage_profile_field(last_path_segment(path))
		then
			local before_profile = before_damage_profiles and before_damage_profiles[before]
			local after_profile = after_damage_profiles and after_damage_profiles[after]

			if before_profile then
				entry.before_profile = before_profile
			end
			if after_profile then
				entry.after_profile = after_profile
			end
		end

		out[#out + 1] = entry
	end
end

local function diff_snapshots(before, after)
	local out = {}
	local before_damage_profiles = before.DamageProfileTemplates
	local after_damage_profiles = after.DamageProfileTemplates

	for _, global_name in ipairs(TRACKED_GLOBALS) do
		local before_global = before[global_name]
		local after_global = after[global_name]

		if ATOMIC_ENTRY_GLOBALS[global_name] then
			local seen_names = {}

			if type(before_global) == "table" then
				for name in pairs(before_global) do
					if not is_no_damage_variant(name) then
						seen_names[name] = true
					end
				end
			end
			if type(after_global) == "table" then
				for name in pairs(after_global) do
					if not is_no_damage_variant(name) then
						seen_names[name] = true
					end
				end
			end

			-- Entry order (across all globals, not just this one) is handled by
			-- weapon-diff-listener.mjs sorting the whole array by path after
			-- receiving it - simpler to do once in JS than per-global here, and it
			-- also covers Weapons/BuffTemplates/etc., not just DamageProfileTemplates.
			for name in pairs(seen_names) do
				local before_entry = before_global and before_global[name]
				local after_entry = after_global and after_global[name]

				if not deep_equal(before_entry, after_entry) then
					out[#out + 1] = {
						path = global_name .. "." .. name,
						before = coerce_missing(before_entry),
						after = coerce_missing(after_entry),
					}
				end
			end
		else
			diff_into(global_name, before_global, after_global, out, before_damage_profiles, after_damage_profiles)
		end
	end

	return out
end

local function export_diff()
	local after_snapshot = capture_snapshot()
	local diff = diff_snapshots(before_snapshot, after_snapshot)

	mod:echo(string.format("[TourneyBalance] Weapon diff: %d changed field(s), posting to %s.", #diff, EXPORT_URL))

	local body = cjson.encode(diff)
	local headers = { "Content-Type: application/json" }

	Managers.curl:post(EXPORT_URL, body, headers, function(success, code)
		if success and code == 200 then
			mod:echo("[TourneyBalance] Weapon diff exported.")
		else
			mod:echo(string.format("[TourneyBalance] Weapon diff export failed (code %s) - is the local listener running?", tostring(code)))
		end
	end)
end

mod:command("tb_export_weapon_diff", "Diffs current weapon/damage-profile data against the pre-TourneyBalance snapshot and POSTs the JSON result to a local listener.", export_diff)
