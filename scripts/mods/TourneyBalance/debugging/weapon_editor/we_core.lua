--[[
	Weapon editor: stateless helpers shared by the entry file, the exporter and the UI.

	Paths are arrays of keys starting at a global, e.g.
	{ "Weapons", "two_handed_halberds_template_1", "actions", "action_one", "light_attack_left", "anim_time_scale" }
	and print the same way the change files write them:
	Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.anim_time_scale
]]

local core = {}

-- Keys the engine stamps onto tables at runtime, never authored by a change file
core.EXCLUDED_KEYS = {
	lookup_data = true,
}

function core.deep_copy(value, seen)
	if type(value) ~= "table" then
		return value
	end

	seen = seen or {}

	if seen[value] then
		return seen[value]
	end

	local copy = {}
	seen[value] = copy

	for k, v in pairs(value) do
		copy[k] = core.deep_copy(v, seen)
	end

	return copy
end

function core.deep_equal(a, b)
	if a == b then
		return true
	end

	if type(a) == "number" and type(b) == "number" then
		return math.abs(a - b) <= 1e-6
	end

	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end

	for k, v in pairs(a) do
		if not core.EXCLUDED_KEYS[k] and not core.deep_equal(v, b[k]) then
			return false
		end
	end

	for k in pairs(b) do
		if not core.EXCLUDED_KEYS[k] and a[k] == nil then
			return false
		end
	end

	return true
end

function core.values_equal(a, b)
	if type(a) == "number" and type(b) == "number" then
		return math.abs(a - b) <= 1e-6
	end

	return a == b
end

--[[
	Paths
]]

function core.parse_path(path)
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

local function format_key(key)
	if type(key) == "number" then
		return "[" .. key .. "]"
	elseif key:match("^[%a_][%w_]*$") then
		return "." .. key
	end

	return string.format("[%q]", key)
end

-- root_name replaces keys[1] (e.g. DamageProfileTemplates -> NewDamageProfileTemplates),
-- last_index stops early to name an intermediate table.
function core.format_path(keys, root_name, last_index)
	local parts = { root_name or keys[1] }

	for i = 2, last_index or #keys do
		parts[#parts + 1] = format_key(keys[i])
	end

	return table.concat(parts)
end

-- True when `path` is `prefix` itself or a field somewhere below it
function core.path_is_under(path, prefix)
	if path == prefix then
		return true
	end

	local next_char = path:sub(#prefix + 1, #prefix + 1)

	return path:sub(1, #prefix) == prefix and (next_char == "." or next_char == "[")
end

-- Path from keys[first_index] onward, e.g. "targets[1].power_distribution.attack"
function core.format_relative(keys, first_index)
	local parts = {}

	for i = first_index, #keys do
		parts[#parts + 1] = format_key(keys[i])
	end

	return (table.concat(parts):gsub("^%.", ""))
end

function core.append_key(keys, key)
	local child_keys = {}

	for i = 1, #keys do
		child_keys[i] = keys[i]
	end

	child_keys[#child_keys + 1] = key

	return child_keys
end

function core.sub_keys(keys, last_index)
	local prefix = {}

	for i = 1, last_index do
		prefix[i] = keys[i]
	end

	return prefix
end

-- Walks keys[2..n] from `root`. Returns the value plus every table passed through.
function core.walk(root, keys)
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

function core.live_value(keys)
	return core.walk(rawget(_G, keys[1]), keys)
end

function core.snapshot_value(snapshot, keys)
	return (core.walk(snapshot and snapshot[keys[1]], keys))
end

--[[
	Values
]]

-- Shortest text that reads back as the exact same double, so re-printing a whole block
-- never rounds away digits nobody edited.
local function format_number(value)
	if value ~= value then
		return "0/0"
	elseif value == math.huge then
		return "math.huge"
	elseif value == -math.huge then
		return "-math.huge"
	end

	for precision = 1, 17 do
		local text = string.format("%." .. precision .. "g", value)

		if tonumber(text) == value then
			return text
		end
	end

	return string.format("%.17g", value)
end

function core.format_value(value)
	local value_type = type(value)

	if value == nil then
		return "none"
	elseif value_type == "number" then
		return format_number(value)
	elseif value_type == "string" then
		return string.format("%q", value)
	elseif value_type == "table" then
		return "<table>"
	end

	return tostring(value)
end

-- Compact Lua literal (keys sorted, exact numbers), read back by core.deserialize
function core.serialize(value)
	if type(value) ~= "table" then
		return core.format_value(value)
	end

	local parts = {}

	for _, key in ipairs(core.sorted_keys(value)) do
		local child = value[key]
		local child_type = type(child)

		if child_type ~= "function" and child_type ~= "userdata" and child_type ~= "thread" then
			local key_text = type(key) == "number" and ("[" .. key .. "]") or string.format("[%q]", key)

			parts[#parts + 1] = key_text .. "=" .. core.serialize(child)
		end
	end

	return "{" .. table.concat(parts, ",") .. "}"
end

-- Evaluates a literal from core.serialize with nothing but math.huge in scope
function core.deserialize(text)
	local chunk = loadstring("return " .. text)

	if not chunk then
		return nil
	end

	setfenv(chunk, {
		math = {
			huge = math.huge,
		},
	})

	local ok, value = pcall(chunk)

	return ok and value or nil
end

--[[
	Edits come in four kinds:
		value    a leaf set to a number/string/boolean
		table    a field set to a whole table (added field/entry, rewritten array)
		removed  a field deleted
		ref      a field pointed at a live global table (e.g. a weapon's embedded aoe copy
		         replaced by ExplosionTemplates.x itself), stored as that global's path

	Persisted as plain text ("path\tkind:payload" per line) so it doesn't depend on VMF
	serializing nested tables.
]]

function core.encode_edit(edit)
	local kind = edit.kind or "value"

	if kind == "table" then
		return "t:" .. core.serialize(edit.value)
	elseif kind == "removed" then
		return "r:"
	elseif kind == "ref" then
		return "g:" .. edit.ref
	end

	local value = edit.value
	local value_type = type(value)

	if value_type == "number" then
		return "n:" .. string.format("%.17g", value)
	elseif value_type == "boolean" then
		return "b:" .. tostring(value)
	end

	return "s:" .. tostring(value)
end

-- Returns kind, payload (value, table or ref path); nil kind when unreadable
function core.decode_edit(text)
	local tag, raw = text:match("^(%a):(.*)$")

	if tag == "n" then
		return "value", tonumber(raw)
	elseif tag == "b" then
		return "value", raw == "true"
	elseif tag == "s" then
		return "value", raw
	elseif tag == "t" then
		local value = core.deserialize(raw)

		return type(value) == "table" and "table" or nil, value
	elseif tag == "r" then
		return "removed", nil
	elseif tag == "g" then
		return "ref", raw
	end

	return nil
end

-- Short human description of an edit's new state, for lists and chat
function core.describe_edit(edit)
	local kind = edit.kind or "value"

	if kind == "table" then
		return "<table>"
	elseif kind == "removed" then
		return "removed"
	elseif kind == "ref" then
		return "-> " .. edit.ref
	end

	return core.format_value(edit.value)
end

--[[
	Tables
]]

local function key_less(a, b)
	local type_a, type_b = type(a), type(b)

	if type_a ~= type_b then
		return type_a == "number"
	end

	if type_a == "number" or type_a == "string" then
		return a < b
	end

	return tostring(a) < tostring(b)
end

-- Sorted union of the keys of up to two tables: numbers ascending, then strings A-Z
function core.sorted_keys(t, other)
	local seen, keys = {}, {}

	for _, source in ipairs({ t, other }) do
		if type(source) == "table" then
			for k in pairs(source) do
				if not seen[k] and not core.EXCLUDED_KEYS[k] then
					seen[k] = true
					keys[#keys + 1] = k
				end
			end
		end
	end

	table.sort(keys, key_less)

	return keys
end

function core.is_sequence(t)
	local count = 0

	for _ in pairs(t) do
		count = count + 1
	end

	return count > 0 and count == #t
end

return core
