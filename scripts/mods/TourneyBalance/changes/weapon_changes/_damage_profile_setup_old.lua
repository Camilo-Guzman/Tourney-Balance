--[[
    MUST run after weapon_changes (and any other file that adds to
    NewDamageProfileTemplates) has been dofile'd - this links/validates whatever they've
    registered. See the dofile ordering comment in TourneyBalance.lua.
]]

-- Add the new templates to the DamageProfile templates
-- Setup proper linking in NetworkLookup
for key, _ in pairs(NewDamageProfileTemplates) do
    local i = #NetworkLookup.damage_profiles + 1
    NetworkLookup.damage_profiles[i] = key
    NetworkLookup.damage_profiles[key] = i
end

-- Merge the tables together
table.merge_recursive(DamageProfileTemplates, NewDamageProfileTemplates)

-- Resolve string references (critical_strike, cleave_distribution, armor_modifier,
-- default_target, targets) to their actual PowerLevelTemplates table
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

-- Generate a "_no_damage" variant of every damage profile, with attack power zeroed out
local no_damage_templates = {}

for name, damage_profile in pairs(DamageProfileTemplates) do
	-- Skip names that are themselves a previously-generated "_no_damage" variant -
	-- DamageProfileTemplates survives a VMF mod reload, so without this check a
	-- reload would treat last run's own output as new input and compound the
	-- suffix (_no_damage_no_damage, then _no_damage_no_damage_no_damage, ...).
	local is_no_damage_variant = name:sub(-("_no_damage"):len()) == "_no_damage"

	if not is_no_damage_variant then
		local no_damage_name = name .. "_no_damage"

		if not DamageProfileTemplates[no_damage_name] then
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

DamageProfileTemplates = table.merge(DamageProfileTemplates, no_damage_templates)
