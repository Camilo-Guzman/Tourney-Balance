local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
local stagger_types = require("scripts/utils/stagger_types")

--[[
	$BEGIN_TB
		---
		## Stagger Talents
		### Careers
		**Huntsman**
		- Replaced Bulwark with Assassin.

		### Talents
		**Assassin**
		- Removed damage bonus to apply on crits.

		**Bulwark**
		- Added 10% Stagger Power.
		- Increased damage debuff duration to 10s (from 2s).
		- Changes damage debuff to apply with any stagger (from melee stagger).
		- Staggering an enemy adds 1 stagger count for 10s, up to 2 stacks.
		- Stagger counts from Bulwark benefit all player.

		**Mainstay**
		- Melee hits apply 1 stagger count for 2s, up to 2 stacks.
		- Stagger counts from Mainstay only benefit players with Mainstay.
		- Stagger count can not be applied by pushes or shield bash splash hits.
		- Stagger count can not be applied to bosses/lords.

		**Enhanced Power**
		- Increased power to 10% (from 7.5%).

		**Assassin/Bulwark/Enhanced Power/Mainstay/Smiter**
		- Reformatted description.
	$END_TB
]]

--[[

	Stagger Talents

]]
--[[
	Assassin
]]
-- Assassin Buff copy
mod_api.insert_buff_template("tb_finesse_unbalance", {
	max_display_multiplier = 0.4,
	name = "finesse_unbalance",
	display_multiplier = 0.2,
	perks = { buff_perks.finesse_stagger_damage }
})

--[[
	Bulwark
]]
-- Bulwark Damage Debuff
mod_api.insert_buff_template("tb_tank_unbalance_buff", {
	refresh_durations = true,
	name = "tank_unbalance_buff",
	stat_buff = "unbalanced_damage_taken",
	max_stacks = 1,
	duration = 10,
	bonus = 0.10,
})
-- Bulwark stagger marks (tank_stagger_counts), counted by stacks via num_buff_type in 01_damage_calc_changes.lua.
-- Visible to all players, includes bosses/lords.
mod_api.insert_buff_template("tb_tank_stagger_mark_buff", {
	refresh_durations = true,
	max_stacks = 1, -- Bulwark Stacks
	duration = 10,
})
-- Apply Bulwark Damage Debuff and stagger mark from any attack
mod_api.insert_proc_function("tb_unbalance_debuff_on_stagger", function (owner_unit, buff, params)
	local hit_unit = params[1]
	local is_dummy = Unit.get_data(hit_unit, "is_dummy")
	--local stagger_type = params[4]
	--local buff_type = params[7]

	if Unit.alive(owner_unit) and (is_dummy or Unit.alive(hit_unit)) then --and (buff_type == "MELEE_1H" or buff_type == "MELEE_2H" or stagger_type == stagger_types.explosion) then
		local buff_extension = ScriptUnit.extension(hit_unit, "buff_system")

		if buff_extension then
			buff_extension:add_buff("tb_tank_unbalance_buff")
			buff_extension:add_buff("tb_tank_stagger_mark_buff")
		end
	end
end )
-- Bulwark Buff
mod_api.insert_buff_template("tb_tank_unbalance", {
	max_display_multiplier = 0.4,
	name = "tank_unbalance",
	event_buff = true,
	buff_func = "tb_unbalance_debuff_on_stagger",
	event = "on_stagger",
	display_multiplier = 0.2,
	stat_buff = "power_level_impact",
	multiplier = 0.10
})

--[[
	Enhanced Power
]]
mod_api.insert_buff_template("tb_power_level_unbalance", {
	max_stacks = 1,
	name = "power_level_unbalance",
	stat_buff = "power_level",
	multiplier = 0.1 -- 0.075
})

--[[
	Mainstay
]]
-- Mainstay Buff copy
mod_api.insert_buff_template("tb_linesman_unbalance", {
	name = "linesman_unbalance",
	perks = { buff_perks.linesman_stagger_damage }
})
-- Mainstay stagger marks
-- Only visible to mainstay players, excludes bosses/lords.
mod_api.insert_buff_template("tb_mainstay_stagger_mark_buff", {
	refresh_durations = true,
	name = "mainstay_stagger_mark_buff",
	stat_buff = "dummy_stagger",
	max_stacks = 1, -- Mainstay stacks
	duration = 2,
	bonus = 1,
})

--[[
	Smiter
]]
-- Smiter Buff copy
mod_api.insert_buff_template("tb_smiter_unbalance", {
	max_display_multiplier = 0.4,
	name = "smiter_unbalance",
	display_multiplier = 0.2,
	perks = { buff_perks.smiter_stagger_damage }
})


--[[

	Text Localization

]]
mod_api.insert_text("assassin_name", 		"Assassin")
mod_api.insert_text("bulwark_name", 		"Bulwark")
mod_api.insert_text("enhanced_power_name", 	"Enhanced Power")
mod_api.insert_text("mainstay_name", 		"Mainstay")
mod_api.insert_text("smiter_name", 			"Smiter")

base_stagger_talent_text = "\n\nDeal 20% more melee damage to staggered enemies, increased to 40% against targets afflicted by more than one stagger effect."
mainstay_stagger_talent_text = "\n\nDeal 40% more melee damage to staggered enemies, increased to 60% against targets afflicted by more than one stagger effect."

mod_api.insert_text("tb_finesse_unbalance_desc",
"Melee headshots inflict 40% bonus damage. Does not stack with damage bonus from stagger effects." .. base_stagger_talent_text)
mod_api.insert_text("tb_linesman_unbalance_desc",
"Melee hits apply 1 count for 2 seconds only accounted by Mainstay. Excludes Lords and Bosses." .. mainstay_stagger_talent_text)
mod_api.insert_text("tb_power_level_unbalance_desc",
"Increases total Power Level by 10%. This is calculated before other buffs are applied." .. base_stagger_talent_text)
mod_api.insert_text("tb_tank_unbalance_desc",
"Gain 10% stagger power. Staggered enemies take 10% more damage and gain one count of stagger for 10 seconds." .. base_stagger_talent_text)
mod_api.insert_text("tb_smiter_unbalance_desc",
"The first enemy hit always counts as staggered." .. base_stagger_talent_text)

-- Replacing Stagger Talents
local FINESSE = 1
local TANK = 2
local ENHANCED_POWER = 3
local MAINSTAY = 4
local SMITER = 5
local TALENT_OPTIONS = {
	[FINESSE] = { -- Assassin
		name = "assassin_name",
		description = "tb_finesse_unbalance_desc",
		buffs = { "tb_finesse_unbalance" },
		description_values = {},
	},
	[TANK] = { -- Bulwark
		name = "bulwark_name",
		description = "tb_tank_unbalance_desc",
		buffs = { "tb_tank_unbalance" },
		description_values = {},
	},
	[ENHANCED_POWER] = { -- Enhanced Power
		name = "enhanced_power_name",
		description = "tb_power_level_unbalance_desc",
		buffs = { "tb_power_level_unbalance" },
		description_values = {},
	},
	[MAINSTAY] = { -- Mainstay
		name = "mainstay_name",
		description = "tb_linesman_unbalance_desc",
		buffs = { "tb_linesman_unbalance" },
		description_values = {},
	},
	[SMITER] = { -- Smiter
		name = "smiter_name",
		description = "tb_smiter_unbalance_desc",
		buffs = { "tb_smiter_unbalance" },
		description_values = {},
	},
}
-- career_name, talent 3-1, talent 3-2, talent 3-3
local talent_third_row = {
	{ "es_mercenary", 		MAINSTAY, 	SMITER, 	ENHANCED_POWER },
	{ "es_huntsman", 		FINESSE, 	SMITER, 	ENHANCED_POWER }, -- Bulwark > Finesse
	{ "es_knight", 			TANK, 		MAINSTAY, 	ENHANCED_POWER },
	{ "es_questingknight", 	TANK, 		SMITER, 	ENHANCED_POWER },

	{ "dr_ranger", 			TANK,		MAINSTAY, 	ENHANCED_POWER },
	{ "dr_ironbreaker", 	TANK, 		SMITER, 	ENHANCED_POWER },
	{ "dr_slayer", 			SMITER, 	MAINSTAY, 	ENHANCED_POWER },
	{ "dr_engineer", 		TANK, 		MAINSTAY, 	ENHANCED_POWER },

	{ "we_waywatcher", 		MAINSTAY, 	FINESSE, 	ENHANCED_POWER },
	{ "we_maidenguard", 	SMITER, 	MAINSTAY, 	ENHANCED_POWER },
	{ "we_shade", 			SMITER, 	FINESSE, 	ENHANCED_POWER },
	{ "we_thornsister", 	SMITER, 	MAINSTAY, 	ENHANCED_POWER },

	{ "wh_captain", 		MAINSTAY, 	FINESSE, 	ENHANCED_POWER },
	{ "wh_bountyhunter", 	SMITER, 	FINESSE, 	ENHANCED_POWER },
	{ "wh_zealot", 			SMITER, 	MAINSTAY, 	ENHANCED_POWER },
	{ "wh_priest", 			SMITER, 	MAINSTAY, 	ENHANCED_POWER },

	{ "bw_adept", 			TANK, 		SMITER, 	ENHANCED_POWER },
	{ "bw_scholar", 		SMITER, 	MAINSTAY, 	ENHANCED_POWER },
	{ "bw_unchained", 		TANK, 		MAINSTAY, 	ENHANCED_POWER },
	{ "bw_necromancer", 	MAINSTAY, 	SMITER, 	ENHANCED_POWER },
}

for i = 1, #talent_third_row do
	local entry = talent_third_row[i]
	local career = entry[1]

	for slot = 1, 3 do
		mod_api.update_talent(career, 3, slot, TALENT_OPTIONS[entry[slot + 1]])
	end
end


