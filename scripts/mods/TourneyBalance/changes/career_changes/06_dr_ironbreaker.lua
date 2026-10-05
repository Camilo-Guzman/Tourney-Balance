local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Ironbreaker
		### Career Ability
		- Reduced damage reduction during ult to 28.5% (from 50%).

		### Passives
		**CDR on Damage Taken**
		- Reduced ult cooldown gain on damage taken to 0.4 (from 0.5).

		### Talents
		**Under Pressure**
		- Base damage multiplier changed to 80% - 130% from (20% - 120%).
		- Ranged attack speed multiplier changed to 200% to 100% (from 200% - 50%) depending on overcharge.

		**Rune-Etched Shield**
		- Corrected description to melee power (from power).

		**Vengeance**
		- Grants 15% attack speed for 20s, when Gromril is lost.
	$END_TB
]]
	
--[[

	Ultimate

]]
-- reduce Impenetrable from 50% DR to 28.5% Damage reduction (why?)
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_activated_ability", {
	{
		stat_buff = "damage_taken",
		multiplier = -0.285
	},
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_activated_ability_taunt_range_and_duration", {
	{
		stat_buff = "damage_taken",
		multiplier = -0.285
	},
})
mod_api.insert_text("career_active_desc_dr_1", "Bardin taunts all nearby man-sized enemies, takes 28.5% less damage (stacks with Dwarf-Forged) and has 0 block cost for the next 10 seconds")

--[[

	Passives

]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_ability_cooldown_on_damage_taken", {
    bonus = 0.4 --0.5
})

--[[

	Talents

]]
--[[
	Under Pressure
]]
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_increased_ranged_power", {
	{
		stat_buff = "increased_weapon_damage_ranged",
	},
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_changing_ranged_power", {
	{
		stat_buff = "increased_weapon_damage_ranged",
		multiplier = -0.2 -- -0.8 -- Starting ranged power as (1 - 0.8) * base_power
	},
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_ranged_power", {
	{
		stat_buff = "increased_weapon_damage_ranged",
		multiplier = 0.05, -- 0.2 -- Damage value increase per stack. Max 10 stacks.
	},
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_changing_attack_speed", {
	{
		multiplier = 1.0, -- 1 -- Starting attack speed as (1 + 1.0) * base_attack_speed
	}
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_attack_speed", {
	{
		stat_buff = "attack_speed_drakefire",
		multiplier = -0.1 -- -0.15 -- Attack speed decrease per stack. Max 10 stacks.
	},
})
mod_api.update_talent("dr_ironbreaker", 2, 1, { --TODO: 1to1 copy bu still does not work???
    description = "bardin_ironbreaker_overcharge_increase_power_lowers_attack_speed_desc",
    description_values = {},
})
mod_api.insert_text("bardin_ironbreaker_overcharge_increase_power_lowers_attack_speed_desc", "Drake Fire base damage multiplier increases from 80% to 130% and ranged attack speed bonus decreases from 100% to 0% depending on overcharge. Removes overcharge slowdown.")

--[[
	Rune-Etched Shield description correction
]]
mod_api.insert_text("bardin_ironbreaker_party_power_on_blocked_attacks_desc", "Blocking an attack increases Bardin's melee power (and that of nearby allies) by 2.0%% for 10 seconds. Stacks 5 times.")


--[[
	Vengeance
]]
-- 15% attack speed, 100% uptime
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_stacking_buff_gromril", {
    update_frequency = 0,
})
mod_api.update_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_attack_speed", {
    multiplier = 0.03,
    duration = 20,
})
mod_api.insert_text("bardin_ironbreaker_rising_attack_speed_desc", "When Gromril is lost, gain 15.0%% attack speed for 20 seconds.")
