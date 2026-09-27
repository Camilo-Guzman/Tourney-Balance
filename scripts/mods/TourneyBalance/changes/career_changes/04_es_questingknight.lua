local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Grail Knight
		### Passive
		**Quests** (Adventure)
		- The Grimoire and Tome quests can now roll on maps without Grimoires or Tomes.
		- Health Regeneration quest: find a Grimoire, or the team restores 3000 health (healing, temporary health or regeneration).
		- Damage Reduction quest: find a Tome, or the team lands 1000 headshots.
		- Cooldown Regeneration quest: kill a Monster, or use 50 Career Skills as a team.
		- Cooldown Regeneration reward increased to 20% (from 10%), and 30% with improved rewards (from 15%).

		### Talents
		**Virtue of Knightly Temper**
		- Reduced instant slay damage multiplier for non-Lords-and-Bosses to 3 (from 4).
		
		**Virtue of the Penitent**
		- Increased required kills as follows
		
		| Difficulty | New Value | Old Value |
		| --- | --- | --- |
		| **Recruit** | 100 | 50 |
		| **Veteran** | 150 | 60 |
		| **Champion** | 250 | 75 |
		| **Legend** | 300 | 85 |
		| **Cataclysm** | 350 | 100 |
		| **Cataclysm 2** | 400 | 100 |
		| **Cataclysm 3** | 500 | 100 |

		**Virtue of the Impetuous Knight**
		- Increased buff duration to 25s (from 15s).
		- Added 30% cooldown reduction.
		- Killing an enemy with Blessed Blade now also grants immunity to knockback from Warpfire Throwers, Ratling Gunners, Ungor Archer arrows, Stormfiends and the Deathrattler for 25s.

		**Virtue of Confidence**
		- Removed infinite damage cleave, but keep infinite stagger cleave.
		- Added heavy linesman modifier.
		- Lowered damage window start time to 0.05s (from 0.15s).
		- Damage cleave distribution lowered to 0.5 (from 100).
	$END_TB	
]]

--[[

	Passive

]]

--[[
	Quests (Adventure only - Weave, Versus and Chaos Wastes keep their own vanilla quest pools)
]]
local QUEST_HEALTH_GOAL = 3000
local QUEST_HEADSHOT_GOAL = 600
local QUEST_TEAM_ULTIMATES_GOAL = 30

local function flat_amount(amount)
	local amounts = {}

	for i = 1, 9 do
		amounts[i] = amount
	end

	return amounts
end

-- New quest: the whole team uses 50 career skills, or anyone kills a Monster (the vanilla kill_monsters condition).
-- Its progress is synced to clients like any other quest, so the template needs a NetworkLookup entry
-- (appended, same as insert_talent_buff_template does for buffs).
InGameChallengeTemplates.tb_team_use_ultimates = {
	default_target = QUEST_TEAM_ULTIMATES_GOAL,
	description = "tb_team_use_ultimates",
	events = {
		tb_hero_ability_used = function (t, data)
			return 1
		end,
		on_player_killed_enemy = function (t, data, killing_blow, breed_killed, ai_unit)
			if breed_killed.boss then
				return QUEST_TEAM_ULTIMATES_GOAL -- clamped to the required progress, completes the quest
			end
		end,
	},
}
do
	local index = #NetworkLookup.challenges + 1
	NetworkLookup.challenges[index] = "tb_team_use_ultimates"
	NetworkLookup.challenges["tb_team_use_ultimates"] = index
end

-- Grimoire and Tome quests no longer require the book to be on the map, since they can also be completed
-- by restoring health / landing headshots.
local tb_possible_challenges = {
	{
		reward = "markus_questing_knight_passive_power_level",
		type = "kill_elites",
		amount = { 1, 15, 15, 20, 20, 30, 30, 30, 10 },
	},
	{
		reward = "markus_questing_knight_passive_attack_speed",
		type = "kill_specials",
		amount = { 1, 10, 10, 15, 15, 20, 20, 20, 10 },
	},
	{
		reward = "markus_questing_knight_passive_cooldown_reduction",
		type = "tb_team_use_ultimates", -- kill_monsters, which still completes it
		amount = flat_amount(QUEST_TEAM_ULTIMATES_GOAL),
	},
	{
		reward = "markus_questing_knight_passive_health_regen",
		type = "find_grimoire", -- progress = health restored, a Grimoire pickup completes it
		amount = flat_amount(QUEST_HEALTH_GOAL), -- 1
	},
	{
		reward = "markus_questing_knight_passive_damage_taken",
		type = "find_tome", -- progress = headshots, a Tome pickup completes it
		amount = flat_amount(QUEST_HEADSHOT_GOAL), -- 1
	},
}
local GAME_MODES_WITH_OWN_QUEST_POOL = {
	weave = true,
	versus = true,
	deus = true,
}
mod:hook(PassiveAbilityQuestingKnight, "_get_possible_challenges", function (func, self)
	if GAME_MODES_WITH_OWN_QUEST_POOL[Managers.state.game_mode:game_mode_key()] then
		return func(self)
	end

	return tb_possible_challenges
end)

-- The quest HUD shows Localize(<challenge template name>)
mod_api.insert_text("find_grimoire", "Find a Grimoire or gain " .. QUEST_HEALTH_GOAL .. " health")
mod_api.insert_text("find_tome", "Find a Tome or land " .. QUEST_HEADSHOT_GOAL .. " headshots")
mod_api.insert_text("tb_team_use_ultimates", "Kill a Monster or use " .. QUEST_TEAM_ULTIMATES_GOAL .. " career abilities")

-- Cooldown regeneration reward: 20% base, 30% with Virtue of the Grail (improved rewards)
BuffTemplates.markus_questing_knight_passive_cooldown_reduction.buffs[1].multiplier = 0.2 -- 0.1
BuffTemplates.markus_questing_knight_passive_cooldown_reduction_improved.buffs[1].multiplier = 0.3 -- 0.15
mod_api.insert_text("markus_questing_knight_passive_cooldown_reduction", "+20%% Cooldown Regeneration")
mod_api.insert_text("markus_questing_knight_passive_cooldown_reduction_improved", "+30%% Cooldown Regeneration")

-- Grimoire/Tome quests: the goal is the health/headshot count, so the vanilla quest HUD counts them down.
-- The whole team contributes: the server broadcasts team-wide events, and every active Grail Knight quest of that
-- type progresses (same as the vanilla book pickup events, which fire for whoever picks the book up).
-- A book pickup (vanilla event returns 1) completes the quest outright instead; progress is clamped to the goal.
-- (These templates are only used by Grail Knight quests.)
local find_grimoire_events = InGameChallengeTemplates.find_grimoire.events
local find_tome_events = InGameChallengeTemplates.find_tome.events

find_grimoire_events.player_pickup_grimoire = function (t, data, player)
	return QUEST_HEALTH_GOAL
end
find_grimoire_events.tb_hero_health_gained = function (t, data, amount)
	return amount
end
find_tome_events.player_pickup_tome = function (t, data, player)
	return QUEST_HEADSHOT_GOAL
end
find_tome_events.tb_hero_headshot = function (t, data)
	return 1
end

-- Health gains are fractional, but quest progress is synced to clients as a whole number, so keep the remainder here
local team_health_remainder = 0

mod:add_game_state_changed_function(function ()
	team_health_remainder = 0
end)

local function is_hero_player_unit(unit)
	if not unit or not Managers.player:owner(unit) then
		return false
	end

	local side = Managers.state.side.side_by_unit[unit]

	return side and side:name() == "heroes"
end

-- Grimoire alternative: health any hero (players and bots) actually gains from any heal, THP or regen
-- (overheal doesn't count). Registered through the add_heal dispatcher in TourneyBalance.lua.
mod:add_player_add_heal_wrapper(function (func, self, healer_unit, heal_amount, heal_source_name, heal_type)
	local game = self.game
	local game_object_id = self.health_game_object_id

	if not (self.is_server and game and game_object_id and heal_amount > 0 and is_hero_player_unit(self.unit)) then
		return func(self, healer_unit, heal_amount, heal_source_name, heal_type)
	end

	local health_before = GameSession.game_object_field(game, game_object_id, "current_health")
	local temporary_health_before = GameSession.game_object_field(game, game_object_id, "current_temporary_health")

	func(self, healer_unit, heal_amount, heal_source_name, heal_type)

	local health_after = GameSession.game_object_field(game, game_object_id, "current_health")
	local temporary_health_after = GameSession.game_object_field(game, game_object_id, "current_temporary_health")
	-- Permanent heals convert THP into health first, so count each pool's gain separately
	local gained = math.max(health_after - health_before, 0) + math.max(temporary_health_after - temporary_health_before, 0)

	if gained > 0 then
		local total = team_health_remainder + gained
		local whole = math.floor(total)

		team_health_remainder = total - whole

		if whole > 0 then
			Managers.state.event:trigger("tb_hero_health_gained", whole)
		end
	end
end)

-- Tome alternative: headshots by any hero on living enemies (same hit zone check as the vanilla "headshots" stat)
mod:hook(GenericHealthExtension, "add_damage", function (func, self, attacker_unit, damage_amount, hit_zone_name, ...)
	local counts = hit_zone_name == "head" and self.is_server and HEALTH_ALIVE[self.unit] and is_hero_player_unit(attacker_unit)

	func(self, attacker_unit, damage_amount, hit_zone_name, ...)

	if counts then
		Managers.state.event:trigger("tb_hero_headshot")
	end
end)

-- Team ultimates: on the server, every career skill use (host, bots, clients via rpc_ability_activated, and
-- Engineer's crank gun) triggers on_ability_activated exactly once on the activating unit's own buff extension.
mod:hook_safe(BuffExtension, "trigger_procs", function (self, event, activator_unit)
	if event ~= "on_ability_activated" or activator_unit ~= self._unit or not Managers.player.is_server then
		return
	end

	local side = Managers.state.side.side_by_unit[activator_unit]

	if side and side:name() == "heroes" then
		Managers.state.event:trigger("tb_hero_ability_used")
	end
end)

--[[

	Talents

]]

--[[
	Virtue of Knightly Temper
]]
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_crit_can_insta_kill",  {
	damage_multiplier = 3 --4
})
mod_api.insert_text("markus_questing_knight_crit_can_insta_kill_desc", "Critical Strikes instantly slay enemies if their current health is less than 2 times the amount of damage of the Critical Strike. Half of 4 effect versus Lords and Monsters.")

--[[
	Virtue of the Penitent
]]
local side_quest_challenge = {
	reward = "markus_questing_knight_passive_strength_potion",
	type = "kill_enemies",
	amount = {
		1,
		100, --50
		150, --60
		250, --75
		300, --85
		350, --100
		400, --100
		500  --100
	}
}
mod:hook_origin(PassiveAbilityQuestingKnight, "_get_side_quest_challenge", function(self)
	return side_quest_challenge
end)


--[[
	Virtue of Stoicism
]]
-- 25% as thp instead of 50%
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_health_refund_over_time", {
	heal_amount_fraction = 0.25 -- 0.5
})
mod_api.insert_text("markus_questing_knight_health_refund_over_time_desc", "25.0%% of damage taken is regenerated as temporary health after 5 seconds.")

--[[
	Virtue of the Impetuous Knight
]]
-- Duration increased to 25s
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_ability_buff_on_kill_movement_speed", {
    duration = 25, --15
})
mod_api.update_talent("es_questingknight", 6, 2, {
    buffs = {
        "tb_cd_grail",
		"markus_questing_knight_ability_buff_on_kill",
		"tb_grail_no_knockback_on_kill"
    }
})
-- Additional 30% cdr
mod_api.insert_talent_buff_template("empire_soldier", "tb_cd_grail", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3,
	max_stacks = 1
})
-- Ranged knockback immunity for 25s after killing an enemy with Blessed Blade.
-- Vanilla no_ranged_knockback perk, which the game already checks for Warpfire Thrower and Stormfiend/Deathrattler
-- warpfire pushes, and for the impact push of lightweight projectiles (Ratling Gunner, Deathrattler's guns, Ungor Archer arrows).
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_no_knockback", {
	perks = {
		"no_ranged_knockback"
	},
	duration = 25,
	max_stacks = 1,
	refresh_durations = true,
	icon = "markus_questing_knight_ability_buff_on_kill"
})
-- Applied on Blessed Blade kills, like the vanilla movement speed buff.
-- Goes through the networked add_buff proc so the perk exists on the server as well as the owner.
mod_api.insert_proc_function("tb_grail_no_knockback_on_blessed_blade_kill", function (owner_unit, buff, params)
	local killing_blow_table = params[1]

	if killing_blow_table and killing_blow_table[DamageDataIndex.DAMAGE_SOURCE_NAME] == "markus_questingknight_career_skill_weapon" then
		ProcFunctions.add_buff(owner_unit, buff, params)
	end
end)
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_no_knockback_on_kill", {
	buff_func = "tb_grail_no_knockback_on_blessed_blade_kill",
	buff_to_add = "tb_grail_no_knockback",
	event = "on_kill",
	max_stacks = 1
})
mod_api.insert_text("markus_questing_knight_ability_buff_on_kill_desc", "Killing an enemy with Blessed Blade grants 35%% movement speed and immunity to knockback from ranged projectiles and Warpfire for 25 seconds. Reduces cooldown by 30%%.")

--[[
	Virtue of Confidence

-- TODO: move to weapon changes and leave reference here.
]]
-- Remove infinite damage cleave, but keep infinite stagger cleave
-- old damage numbers but heavy linesman instead (potentially too good against berzerkers)
-- start window shorter for better visual feedback
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.unlimited_cleave = false
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.damage_window_start = 0.05 --0.15
DamageProfileTemplates.questing_knight_career_sword_tank.cleave_distribution.attack = 0.5 --100


