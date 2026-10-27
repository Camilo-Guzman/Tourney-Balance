--[[
    Overwrite-safe replacement for _damage_profile_setup.lua, loaded from
    changes/04_weapon_changes.lua. The old file is kept only for archiving and is no longer loaded.

    Intended to be dofile'd more than once (e.g. TourneyBalance first, then a second mod
    that overrides some of its profiles by writing into the same NewDamageProfileTemplates
    global and running this again). It is also safe on a VMF reload.

    Differences from _damage_profile_setup.lua:
      * NetworkLookup.damage_profiles is only extended for names that are not registered yet.
        The original appends every name on every run, so a second run doubles the entries
        and overflows the 1024 network limit.
      * Existing profiles are merged into a clone, then replaced. merge_recursive on the
        live entry would write through the resolved PowerLevelTemplates tables that profiles
        share, changing every other profile that uses the same template.
      * "_no_damage" variants are rebuilt for every profile this run touched. The original
        only creates missing ones, so an overridden profile keeps a stale variant.
      * If new names would push past the network limit, frees unused slots: from
        DamageProfileNetworkSlotsToFree (a global list of profile names, set before this runs),
        or, when that is unset, from the versus-only "*_vs_no_damage" profiles (this breaks
        nothing in adventure mode, but those profiles are gone in versus). Logs what it does.

    Set REPLACE_WHOLE_PROFILE to true if an override should replace the profile outright
    rather than only change the fields it lists.
]]

local REPLACE_WHOLE_PROFILE = false

-- NetworkLookup tables error on a missing key (metatable set in network_lookup.lua),
-- so every read of a possibly-missing name or index below must go through rawget.
local lookup = NetworkLookup.damage_profiles

-- Mods load during boot, before network_constants.lua defines NetworkConstants, so ask the
-- engine for the limit directly and only fall back to the known value if that fails.
local max_entries = 1024
local network_constants = rawget(_G, "NetworkConstants")
local network_api = rawget(_G, "Network")

if network_constants and network_constants.damage_profile then
	max_entries = network_constants.damage_profile.max
elseif network_api and network_api.type_info then
	local ok, info = pcall(network_api.type_info, "damage_profile")

	if ok and info and info.max then
		max_entries = info.max
	end
end

-- Highest used index, found without # in case freed slots left holes.
local top = 0

for key in pairs(lookup) do
	if type(key) == "number" and key > top then
		top = key
	end
end

-- Apply the templates, and collect the names that still need a network slot.
local touched_names = {}
local new_names = {}

for name, template in pairs(NewDamageProfileTemplates) do
	touched_names[name] = true

	local existing = DamageProfileTemplates[name]

	if existing and not REPLACE_WHOLE_PROFILE then
		local merged = table.clone(existing)

		table.merge_recursive(merged, template)

		DamageProfileTemplates[name] = merged
	else
		DamageProfileTemplates[name] = table.clone(template)
	end

	if not rawget(lookup, name) then
		new_names[#new_names + 1] = name
	end
end

-- Only if the new names don't fit: free exactly as many unused slots as needed.
local free_indices = {}
local overflow = top + #new_names - max_entries

printf("[TB damage profiles] lookup top=%d, new names=%d, max=%d, overflow=%d", top, #new_names, max_entries, overflow)

if overflow > 0 then
	local candidates = DamageProfileNetworkSlotsToFree

	if not candidates then
		-- Default: the versus-only "<profile>_vs_no_damage" variants nothing in adventure
		-- mode uses (Class Balance frees the same kind of entries). Sorted for a stable order.
		candidates = {}

		for key in pairs(lookup) do
			if type(key) == "string" and key:sub(-("_vs_no_damage"):len()) == "_vs_no_damage" then
				candidates[#candidates + 1] = key
			end
		end

		table.sort(candidates)
	end

	for _, name in ipairs(candidates) do
		if overflow <= 0 then
			break
		end

		local index = rawget(lookup, name)

		if index and not touched_names[name] then
			free_indices[#free_indices + 1] = index
			lookup[index] = nil
			lookup[name] = nil
			overflow = overflow - 1

			printf("[TB damage profiles] freed network slot %d (%s)", index, name)
		end
	end
end

fassert(overflow <= 0, "Still %d damage profile network slots over the limit (%d). Add unused profile names to DamageProfileNetworkSlotsToFree.", overflow, max_entries)

-- Setup proper linking in NetworkLookup, filling freed slots first.
for _, name in ipairs(new_names) do
	local index = table.remove(free_indices)

	if not index then
		top = top + 1
		index = top
	end

	lookup[index] = name
	lookup[name] = index
end

-- Resolve string references (critical_strike, cleave_distribution, armor_modifier,
-- default_target, targets) to their actual PowerLevelTemplates table.
-- Already resolved fields are tables and are left alone, so re-running is harmless.
for name, damage_profile in pairs(DamageProfileTemplates) do
	if not damage_profile.targets then
		damage_profile.targets = {}
	end

	fassert(damage_profile.default_target, "damage profile [\"%s\"] missing default_target", name)

	if type(damage_profile.critical_strike) == "string" then
		local template = PowerLevelTemplates[damage_profile.critical_strike]

		fassert(template, "damage profile [\"%s\"] has no corresponding template defined in PowerLevelTemplates. Wanted template name is [\"%s\"] ", name, damage_profile.critical_strike)

		damage_profile.critical_strike = template
	end

	if type(damage_profile.cleave_distribution) == "string" then
		local template = PowerLevelTemplates[damage_profile.cleave_distribution]

		fassert(template, "damage profile [\"%s\"] has no corresponding template defined in PowerLevelTemplates. Wanted template name is [\"%s\"] ", name, damage_profile.cleave_distribution)

		damage_profile.cleave_distribution = template
	end

	if type(damage_profile.armor_modifier) == "string" then
		local template = PowerLevelTemplates[damage_profile.armor_modifier]

		fassert(template, "damage profile [\"%s\"] has no corresponding template defined in PowerLevelTemplates. Wanted template name is [\"%s\"] ", name, damage_profile.armor_modifier)

		damage_profile.armor_modifier = template
	end

	if type(damage_profile.default_target) == "string" then
		local template = PowerLevelTemplates[damage_profile.default_target]

		fassert(template, "damage profile [\"%s\"] has no corresponding template defined in PowerLevelTemplates. Wanted template name is [\"%s\"] ", name, damage_profile.default_target)

		damage_profile.default_target = template
	end

	if type(damage_profile.targets) == "string" then
		local template = PowerLevelTemplates[damage_profile.targets]

		fassert(template, "damage profile [\"%s\"] has no corresponding template defined in PowerLevelTemplates. Wanted template name is [\"%s\"] ", name, damage_profile.targets)

		damage_profile.targets = template
	end
end

-- Generate a "_no_damage" variant of every damage profile, with attack power zeroed out.
-- Variants are rebuilt for profiles touched this run, and only created when missing for the rest.
local no_damage_suffix = "_no_damage"
local no_damage_templates = {}

for name, damage_profile in pairs(DamageProfileTemplates) do
	-- Skip names that are themselves a generated variant, otherwise a rerun would
	-- compound the suffix (_no_damage_no_damage, ...).
	local is_no_damage_variant = name:sub(-no_damage_suffix:len()) == no_damage_suffix

	if not is_no_damage_variant then
		local no_damage_name = name .. no_damage_suffix

		if touched_names[name] or not DamageProfileTemplates[no_damage_name] then
			local no_damage_template = table.clone(damage_profile)

			if no_damage_template.targets then
				for _, target in ipairs(no_damage_template.targets) do
					if target.power_distribution then
						target.power_distribution.attack = 0
					end
				end
			end

			if no_damage_template.default_target.power_distribution then
				no_damage_template.default_target.power_distribution.attack = 0
			end

			no_damage_templates[no_damage_name] = no_damage_template
		end
	end
end

table.merge(DamageProfileTemplates, no_damage_templates)
