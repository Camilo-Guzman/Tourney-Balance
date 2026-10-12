local mod = get_mod("TourneyBalance")

local WEAPON_EDITOR_WORKSHOP_ID = 3818239110
local WEAPON_EDITOR_NAMES = {
	WeaponEditor = true,
	["Weapon Editor"] = true,
}

local STAGGER_DAMAGE_PER_STACK = 0.2

local function weapon_editor_enabled()
	local mod_manager = Managers.mod
	local mods = mod_manager and rawget(mod_manager, "_mods")

	if type(mods) ~= "table" then
		return false
	end

	for _, entry in ipairs(mods) do
		if entry.enabled and (tonumber(entry.id) == WEAPON_EDITOR_WORKSHOP_ID or WEAPON_EDITOR_NAMES[entry.name]) then
			return true
		end
	end

	return false
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

if not rawget(_G, "WEAPON_EDITOR_STATE") and not rawget(_G, "WEAPON_EDITOR_VANILLA_SNAPSHOT") and weapon_editor_enabled() then
	local seen = {}

	rawset(_G, "WEAPON_EDITOR_VANILLA_SNAPSHOT", {
		taken_by = "TourneyBalance",
		tables = {
			Weapons = deep_copy(Weapons, seen),
			DamageProfileTemplates = deep_copy(DamageProfileTemplates, seen),
			PowerLevelTemplates = deep_copy(PowerLevelTemplates, seen),
			ExplosionTemplates = deep_copy(ExplosionTemplates, seen),
			SpreadTemplates = deep_copy(SpreadTemplates, seen),
		},
	})
end

local function stagger_multiplier(damage_profile, stagger_number, attacker_unit, difficulty_settings)
	local stagger = stagger_number or 0

	if damage_profile.no_stagger_damage_reduction_ranged then
		stagger = math.max(1, stagger)
	end

	local buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")
	local has_mainstay = buff_extension and buff_extension:has_buff_perk("linesman_stagger_damage")

	stagger = math.min(stagger, has_mainstay and 3 or 2)

	return difficulty_settings.min_stagger_damage_coefficient + stagger * STAGGER_DAMAGE_PER_STACK
end

local EXPORT_KEY_ORDER = {
	profile = {
		order = {
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
		},
		unknown_before = "default_target",
	},
	target = {
		order = {
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
		},
		unknown_before = "armor_modifier",
	},
}

mod:add_all_mods_loaded_function(function ()
	local weapon_editor = get_mod("WeaponEditor")

	if not (weapon_editor and weapon_editor.register_balance_mod) then
		return
	end

	weapon_editor.register_balance_mod({
		name = "TourneyBalance",
		label = "TB",
		profile_prefix = "tb_",
		authored_profiles_global = "NewDamageProfileTemplates",
		export_key_order = EXPORT_KEY_ORDER,
		damage_calculation = mod.tb_do_damage_calculation,
		stagger_multiplier = stagger_multiplier,
		add_calculate_damage_observer = function (observer)
			mod:add_calculate_damage_observer(observer)
		end,
		add_apply_buffs_to_damage_wrapper = function (wrapper)
			mod:add_apply_buffs_to_damage_wrapper(wrapper)
		end,
		legacy_settings_mod = "TourneyBalance",
		legacy_edits_setting = "tbwe_saved_edits",
		legacy_forks_setting = "tbwe_saved_forks",
	})
end)
