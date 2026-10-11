--[[
	Weapon editor: breakpoint grid and hit log.

	Damage comes from TourneyBalance's own formula (mod.tb_do_damage_calculation, exposed by
	01_damage_calc_changes.lua) with everything calculate_damage would read off a target unit
	taken from the breed instead. Checked against real hits with the hit log: it matches except
	for instakill perks (Killing Shot, Murderous Prowess), which aren't modelled. Target-side
	buffs and ranged falloff are left out too.

	Every cell compares three versions of the attack's damage profile, all through TB's formula,
	so the difference is purely the weapon data:
		now      live tables, including editor edits
		TB       TourneyBalance as loaded from the files
		vanilla  the profile the action used before TourneyBalance
]]

local core = require("scripts/mods/TourneyBalance/debugging/weapon_editor/we_core")

local mod = get_mod("TourneyBalance")

local breakpoints = {}

local TB_STAGGER_DAMAGE_PER_STACK = 0.2 -- mirrors 01_damage_calc_changes.lua
local REFRESH_INTERVAL = 0.5
local MAX_HIT_LOG = 25
local BETTER_COLOR = { 120, 230, 120, 255 }
local WORSE_COLOR = { 255, 110, 90, 255 }
local INFO_COLOR = { 150, 200, 255, 255 }
local MISMATCH_COLOR = { 255, 110, 90, 255 }

-- Grid rows, grouped by category in this order. The breed list follows
-- changes/thp_stagger_damage_changes/00_bloodlust_health.lua (minus _dummy/_tutorial variants);
-- its "monster" breeds are split into bosses and lords.
breakpoints.CATEGORIES = { "Trash", "Elite", "Specials", "Boss", "Lords" }

breakpoints.BREEDS = {
	{ "skaven_slave", "Slave Rat", "Trash" },
	{ "skaven_clan_rat", "Clan Rat", "Trash" },
	{ "skaven_clan_rat_with_shield", "Shielded Clan Rat", "Trash" },
	{ "chaos_fanatic", "Fanatic", "Trash" },
	{ "chaos_marauder", "Marauder", "Trash" },
	{ "chaos_marauder_with_shield", "Shielded Marauder", "Trash" },
	{ "beastmen_ungor", "Ungor", "Trash" },
	{ "beastmen_ungor_archer", "Ungor Archer", "Trash" },
	{ "beastmen_gor", "Gor", "Trash" },

	{ "skaven_storm_vermin", "Stormvermin", "Elite" },
	{ "skaven_storm_vermin_with_shield", "Shielded Stormvermin", "Elite" },
	{ "skaven_storm_vermin_commander", "Stormvermin Commander", "Elite" },
	{ "skaven_plague_monk", "Plague Monk", "Elite" },
	{ "chaos_raider", "Mauler", "Elite" },
	{ "chaos_berzerker", "Savage", "Elite" },
	{ "chaos_warrior", "Chaos Warrior", "Elite" },
	{ "beastmen_bestigor", "Bestigor", "Elite" },

	{ "beastmen_standard_bearer", "Standard Bearer", "Specials" },
	{ "skaven_gutter_runner", "Gutter Runner", "Specials" },
	{ "skaven_pack_master", "Packmaster", "Specials" },
	{ "skaven_poison_wind_globadier", "Globadier", "Specials" },
	{ "skaven_ratling_gunner", "Ratling Gunner", "Specials" },
	{ "skaven_warpfire_thrower", "Warpfire", "Specials" },
	{ "chaos_vortex_sorcerer", "Blightstormer", "Specials" },
	{ "chaos_corruptor_sorcerer", "Leech", "Specials" },

	{ "skaven_loot_rat", "Sack Rat", "Other" },
	{ "skaven_explosive_loot_rat", "Explosive Loot Rat", "Other" },
	{ "chaos_mutator_sorcerer", "Mutator Sorcerer", "Other" },

	{ "skaven_rat_ogre", "Rat Ogre", "Boss" },
	{ "skaven_stormfiend", "Stormfiend", "Boss" },
	{ "chaos_spawn", "Chaos Spawn", "Boss" },
	{ "chaos_troll", "Bile Troll", "Boss" },
	{ "beastmen_minotaur", "Minotaur", "Boss" },

	{ "skaven_grey_seer", "Rasknitt", "Lords" },
	{ "skaven_stormfiend_boss", "Deathrattler", "Lords" },
	{ "skaven_storm_vermin_warlord", "Skarrik", "Lords" },
	{ "skaven_storm_vermin_champion", "Stormvermin Champion", "Lords" },
	{ "chaos_exalted_champion_warcamp", "Bodvarr", "Lords" },
	{ "chaos_exalted_sorcerer", "Burblespue", "Lords" },
	{ "chaos_exalted_sorcerer_drachenfels", "Nurgloth", "Lords" },
}

local HIT_ZONES = { "torso", "head" }
local STAGGER_LEVELS = { "0", "1", "2" }
local TARGET_COUNTS = { "1", "2", "3", "4", "5" }
local DISPLAY_MODES = { "hits to kill", "damage" }
local VARIANTS = { "now", "tb", "vanilla" }

--[[
	Damage
]]

function breakpoints.local_player_unit()
	local player = Managers.player and Managers.player:local_player()
	local unit = player and player.player_unit

	return unit and Unit.alive(unit) and unit or nil
end

function breakpoints.breed_health(breed, difficulty_level)
	local difficulty_settings = DifficultySettings[difficulty_level]

	return breed.max_health and difficulty_settings and breed.max_health[difficulty_settings.rank] or 0
end

function breakpoints.hits_to_kill(health, damage)
	if not damage or damage <= 0 then
		return nil
	end

	return math.ceil(health / DamageUtils.networkify_damage(damage))
end

-- Returns final damage (stagger multiplier applied) and base damage
function breakpoints.predict(attacker_unit, damage_source, power_level, damage_profile, target_index, is_critical_strike, breed, hit_zone_name, difficulty_level, boost_damage_multiplier, backstab_multiplier, stagger_number)
	local do_damage_calculation = mod.tb_do_damage_calculation

	if not do_damage_calculation then
		return nil
	end

	local target_settings = damage_profile.targets and damage_profile.targets[target_index] or damage_profile.default_target

	if not target_settings then
		return nil
	end

	local boost_curve = BoostCurves[target_settings.boost_curve_type]
	local armor, _, primary_armor = ActionUtils.get_target_armor(hit_zone_name, breed, nil)
	local buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")
	local has_power_boost = buff_extension and buff_extension:has_buff_perk("potion_armor_penetration") or false
	local difficulty_settings = DifficultySettings[difficulty_level]
	local max_health = breakpoints.breed_health(breed, difficulty_level)
	local base_damage = do_damage_calculation(attacker_unit, damage_source, power_level, DamageOutput, hit_zone_name, damage_profile, target_index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, 0, false, false, has_power_boost, difficulty_level, armor, primary_armor, false, false, max_health, nil)
	local final_damage = base_damage

	if not damage_profile.is_dot then
		final_damage = base_damage * (difficulty_settings.min_stagger_damage_coefficient + (stagger_number or 0) * TB_STAGGER_DAMAGE_PER_STACK)
	end

	return final_damage, base_damage
end

--[[
	Grid data
]]

-- The damage profile(s) of one action in each version of the data. Each hand of a dual
-- weapon action is its own entry.
local function resolve_profiles(editor, target_keys)
	local state = editor.state
	local sources = {
		now = {
			sub_action = core.live_value(target_keys),
			profiles = DamageProfileTemplates,
		},
		tb = {
			sub_action = core.snapshot_value(state.tb_baseline, target_keys),
			profiles = state.tb_baseline and state.tb_baseline.DamageProfileTemplates,
		},
		vanilla = {
			sub_action = core.snapshot_value(state.vanilla, target_keys),
			profiles = state.vanilla.DamageProfileTemplates,
		},
	}
	local hands = {}

	for _, variant in ipairs(VARIANTS) do
		local source = sources[variant]

		if type(source.sub_action) == "table" and source.profiles then
			local left_name, right_name = ActionUtils.get_damage_profile_name(source.sub_action, source.sub_action.weapon_action_hand)

			for hand_index, name in ipairs({ left_name or false, right_name or false }) do
				if name then
					local hand = hands[hand_index]

					if not hand then
						hand = {
							label = hand_index == 1 and "left" or "right",
							names = {},
							profiles = {},
						}
						hands[hand_index] = hand
					end

					hand.names[variant] = name
					hand.profiles[variant] = source.profiles[name]
				end
			end
		end
	end

	local result = {}

	for hand_index = 1, 2 do
		if hands[hand_index] and hands[hand_index].profiles.now then
			result[#result + 1] = hands[hand_index]
		end
	end

	return result
end

local function default_options()
	local difficulty = Managers.state and Managers.state.difficulty and Managers.state.difficulty:get_difficulty()

	return {
		use_own_power = true,
		power_level = 650,
		difficulty_index = table.find(Difficulties, difficulty) or table.find(Difficulties, "cataclysm") or 1,
		hit_zone_index = 1,
		critical = false,
		stagger_index = 1,
		target_count_index = 3,
		display_index = 1,
		-- Category -> shown in the grid
		categories = {
			Trash = true,
			Elite = true,
			Specials = true,
			Boss = true,
			Lords = true,
		},
	}
end

local function compute_grid(editor, options)
	local target_keys = editor.breakpoint_target
	local unit = breakpoints.local_player_unit()

	if not (target_keys and unit) then
		return nil
	end

	local power_level = options.power_level

	if options.use_own_power then
		local career_extension = ScriptUnit.has_extension(unit, "career_system")

		power_level = career_extension and career_extension:get_career_power_level() or power_level
	end

	local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
	local slot_data = inventory_extension:get_slot_data(inventory_extension:get_wielded_slot_name())
	local damage_source = slot_data and slot_data.item_data and slot_data.item_data.name or "default"
	local difficulty_level = Difficulties[options.difficulty_index]
	local hit_zone_name = HIT_ZONES[options.hit_zone_index]
	local stagger_number = options.stagger_index - 1
	local target_count = options.target_count_index
	local grid = {
		power_level = power_level,
		difficulty_level = difficulty_level,
		hands = {},
	}

	for _, hand in ipairs(resolve_profiles(editor, target_keys)) do
		local rows = {}
		local current_category = nil

		for _, entry in ipairs(breakpoints.BREEDS) do
			local breed = Breeds[entry[1]]
			local category = entry[3]

			if breed and options.categories[category] then
				if category ~= current_category then
					current_category = category
					rows[#rows + 1] = {
						header = category,
					}
				end

				local health = breakpoints.breed_health(breed, difficulty_level)
				local cells = {}

				for target_index = 1, target_count do
					local cell = {}

					for _, variant in ipairs(VARIANTS) do
						local profile = hand.profiles[variant]

						if profile then
							local ok, damage = pcall(breakpoints.predict, unit, damage_source, power_level, profile, target_index, options.critical, breed, hit_zone_name, difficulty_level, 0, 1, stagger_number)

							if ok and damage then
								cell[variant] = {
									damage = damage,
									hits = breakpoints.hits_to_kill(health, damage),
								}
							end
						end
					end

					cells[target_index] = cell
				end

				rows[#rows + 1] = {
					label = entry[2],
					health = health,
					cells = cells,
				}
			end
		end

		grid.hands[#grid.hands + 1] = {
			hand = hand,
			rows = rows,
		}
	end

	return grid
end

--[[
	Hit log - fed by mod:add_calculate_damage_observer (see TourneyBalance.lua)
]]

local hit_log = {
	enabled = false,
	entries = {},
	last_key = nil,
	last_t = -1,
}

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

function breakpoints.on_calculate_damage(final_damage, base_damage, damage_output, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve, boost_damage_multiplier, is_critical_strike, damage_profile, target_index, backstab_multiplier, damage_source)
	if not hit_log.enabled or not target_unit or not damage_profile or attacker_unit ~= breakpoints.local_player_unit() then
		return
	end

	local breed = AiUtils.unit_breed(target_unit)

	if not breed or breed.is_hero then
		return
	end

	-- The same hit can be calculated twice in one frame (prediction + server apply)
	local t = Managers.time:time("game") or 0
	local hit_key = tostring(target_unit) .. tostring(damage_profile) .. tostring(target_index)

	if hit_key == hit_log.last_key and t - hit_log.last_t < 0.05 then
		return
	end

	hit_log.last_key, hit_log.last_t = hit_key, t

	local difficulty_level = Managers.state.difficulty:get_difficulty()
	local _, predicted_base = breakpoints.predict(attacker_unit, damage_source, original_power_level, damage_profile, target_index or 1, is_critical_strike, breed, hit_zone_name, difficulty_level, boost_damage_multiplier, backstab_multiplier, 0)
	local health = breakpoints.breed_health(breed, difficulty_level)
	local entries = hit_log.entries

	table.insert(entries, 1, {
		text = string.format("%s %s T%s%s [%s] %.2f dmg (x%.2f stagger) - %s hits of %.0f hp", breed.name, hit_zone_name, tostring(target_index), is_critical_strike and " crit" or "", profile_name(damage_profile), final_damage, base_damage > 0 and final_damage / base_damage or 0, tostring(breakpoints.hits_to_kill(health, final_damage) or "-"), health),
		match = predicted_base ~= nil and math.abs(predicted_base - base_damage) < 0.01,
		predicted = predicted_base,
		base = base_damage,
	})

	entries[MAX_HIT_LOG + 1] = nil
end

--[[
	Window
]]

local function text_colored(text, color)
	Imgui.text_colored(text, color[1], color[2], color[3], color[4])
end

local function format_cell_value(cell_variant, display_index)
	if not cell_variant then
		return "-"
	end

	if display_index == 2 then
		return string.format("%.1f", cell_variant.damage)
	end

	return cell_variant.hits and tostring(cell_variant.hits) or "-"
end

-- now vs TB: fewer hits / more damage is better
local function cell_color(cell, display_index)
	local now, tb = cell.now, cell.tb

	if not (now and tb) then
		return nil
	end

	local now_value = display_index == 2 and -now.damage or now.hits
	local tb_value = display_index == 2 and -tb.damage or tb.hits

	if not (now_value and tb_value) or math.abs(now_value - tb_value) < 1e-3 then
		return nil
	end

	return now_value < tb_value and BETTER_COLOR or WORSE_COLOR
end

local function draw_options(options)
	options.use_own_power = Imgui.checkbox("my power level##bp_own_power", options.use_own_power)

	if not options.use_own_power then
		Imgui.same_line()

		local power_level, changed = Imgui.input_float("power##bp_power", options.power_level)

		if changed then
			options.power_level = math.floor(power_level + 0.5)
		end
	end

	options.difficulty_index = Imgui.combo("difficulty##bp_difficulty", options.difficulty_index, Difficulties)
	options.hit_zone_index = Imgui.combo("hit zone##bp_zone", options.hit_zone_index, HIT_ZONES)
	options.stagger_index = Imgui.combo("stagger stacks##bp_stagger", options.stagger_index, STAGGER_LEVELS)
	options.target_count_index = Imgui.combo("targets##bp_targets", options.target_count_index, TARGET_COUNTS)
	options.display_index = Imgui.combo("show##bp_display", options.display_index, DISPLAY_MODES)
	options.critical = Imgui.checkbox("crit##bp_crit", options.critical)

	Imgui.text("show:")

	for _, category in ipairs(breakpoints.CATEGORIES) do
		Imgui.same_line()

		options.categories[category] = Imgui.checkbox(category .. "##bp_category_" .. category, options.categories[category])
	end
end

local function options_key(editor, options)
	local shown_categories = {}

	for _, category in ipairs(breakpoints.CATEGORIES) do
		shown_categories[#shown_categories + 1] = options.categories[category] and category or "-"
	end

	return table.concat({
		table.concat(shown_categories, ","),
		tostring(editor.edit_generation),
		editor.breakpoint_target and core.format_path(editor.breakpoint_target) or "none",
		tostring(options.use_own_power),
		tostring(options.power_level),
		tostring(options.difficulty_index),
		tostring(options.hit_zone_index),
		tostring(options.critical),
		tostring(options.stagger_index),
		tostring(options.target_count_index),
	}, "|")
end

local function draw_grid(grid, options)
	text_colored(string.format("power %d, %s - cells: now | TB | vanilla (green/red: now vs TB)", grid.power_level, grid.difficulty_level), INFO_COLOR)

	local target_count = options.target_count_index

	for _, hand_grid in ipairs(grid.hands) do
		local hand = hand_grid.hand

		Imgui.separator()
		Imgui.text(string.format("%s%s", #grid.hands > 1 and (hand.label .. ": ") or "", hand.names.now))

		if hand.names.tb ~= hand.names.now or hand.names.vanilla ~= hand.names.now then
			text_colored(string.format("TB profile %s, vanilla profile %s", tostring(hand.names.tb or "-"), tostring(hand.names.vanilla or "-")), INFO_COLOR)
		end

		Imgui.columns(target_count + 2, true)
		Imgui.text("breed")
		Imgui.next_column()
		Imgui.text("hp")

		for target_index = 1, target_count do
			Imgui.next_column()
			Imgui.text("target " .. target_index)
		end

		Imgui.next_column()
		Imgui.separator()

		for _, row in ipairs(hand_grid.rows) do
			if row.header then
				-- Category divider: label in the first column, the rest of the row left empty
				Imgui.separator()
				text_colored(row.header, INFO_COLOR)

				for _ = 1, target_count + 1 do
					Imgui.next_column()
				end
			else
				Imgui.text(row.label)
				Imgui.next_column()
				Imgui.text(string.format("%.0f", row.health))

				for target_index = 1, target_count do
					Imgui.next_column()

					local cell = row.cells[target_index]
					local text = string.format("%s | %s | %s", format_cell_value(cell.now, options.display_index), format_cell_value(cell.tb, options.display_index), format_cell_value(cell.vanilla, options.display_index))
					local color = cell_color(cell, options.display_index)

					if color then
						text_colored(text, color)
					else
						Imgui.text(text)
					end
				end

				Imgui.next_column()
			end
		end

		Imgui.columns(1)
	end
end

local function draw_hit_log()
	hit_log.enabled = Imgui.checkbox("record hits##bp_hitlog", hit_log.enabled)

	Imgui.same_line()

	if Imgui.small_button("clear##bp_hitlog_clear") then
		hit_log.entries = {}
	end

	for _, entry in ipairs(hit_log.entries) do
		if entry.match then
			Imgui.text(entry.text)
		else
			text_colored(string.format("%s - formula MISMATCH (actual base %.2f, predicted %.2f)", entry.text, entry.base, entry.predicted or -1), MISMATCH_COLOR)
		end
	end
end

local function draw_body(editor, t)
	local s = editor.ui_state

	s.breakpoint_options = s.breakpoint_options or default_options()

	local options = s.breakpoint_options

	if editor.breakpoint_target then
		Imgui.text(core.format_relative(editor.breakpoint_target, 2))
	else
		Imgui.text("Pick an attack with its \"breakpoints\" button in the editor.")
	end

	if Imgui.collapsing_header("options##bp_options", true) then
		draw_options(options)
	end

	local key = options_key(editor, options)

	if editor.breakpoint_target and (key ~= s.breakpoint_key or t - (s.breakpoint_time or -math.huge) > REFRESH_INTERVAL) then
		s.breakpoint_grid = compute_grid(editor, options)
		s.breakpoint_key = key
		s.breakpoint_time = t
	end

	local grid = editor.breakpoint_target and s.breakpoint_grid

	if grid then
		if #grid.hands == 0 then
			Imgui.text("This action has no damage profile.")
		else
			draw_grid(grid, options)
		end
	elseif editor.breakpoint_target then
		Imgui.text("Needs a player unit - open this in the keep or a level.")
	end

	Imgui.separator()

	if Imgui.collapsing_header("hit log##bp_hitlog_header", false) then
		draw_hit_log()
	end
end

-- Returns true when the window should close. The body runs in a pcall so end_window is
-- always reached - an error between begin/end would leave Imgui's window stack broken.
function breakpoints.draw(editor, t)
	-- /tbwe_reset_windows: offset from the editor window so both stay grabbable
	if editor.pending_window_reset.breakpoints then
		editor.pending_window_reset.breakpoints = nil

		Imgui.set_next_window_pos(90, 90)
		Imgui.set_next_window_size(820, 700)
	end

	local do_close = Imgui.begin_window("TB Breakpoints")

	Imgui.set_window_size(820, 700, "once")

	local ok, err = pcall(draw_body, editor, t)

	Imgui.end_window()

	if not ok then
		error(err, 0)
	end

	return do_close
end

return breakpoints
