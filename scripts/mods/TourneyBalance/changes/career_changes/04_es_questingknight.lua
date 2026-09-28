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
		**Virtue of the Ideal**
		- Increased power per stack to 10% (from 8%).

		**Virtue of Heroism**
		- Heavy attacks can no longer be interrupted.
		- Charging a heavy attack past the point where it becomes available now adds up to 30% extra heavy attack damage (full bonus at 0.67s longer), on top of the flat 30%.

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

		**Virtue of Stoicism**
		- Now regenerates 25% of damage taken as temporary health after 5s, and another 25% after 7s (from 50% after 5s).

		**Virtue of Discipline**
		- Increased duration to 10s (from 6s).

		**Virtue of the Joust**
		- Removes the movement penalty from melee weapons and Blessed Blade (attacking, charging heavy attacks and blocking).

		**Virtue of the Impetuous Knight**
		- Buff is now granted on using Blessed Blade (from on killing an enemy with Blessed Blade).
		- Increased buff duration to 25s (from 15s).
		- Added 30% cooldown reduction.
		- The buff now also grants immunity to knockback from Warpfire Throwers, Ratling Gunners, Ungor Archer arrows, Stormfiends and the Deathrattler.

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
mod_api.insert_text("find_grimoire", "Find a Grimoire or gain health")
mod_api.insert_text("find_tome", "Find a Tome or land headshots")
mod_api.insert_text("tb_team_use_ultimates", "Kill a Monster or use career abilities")

-- Cooldown regeneration reward: 20% base, 30% with Virtue of the Grail (improved rewards)
BuffTemplates.markus_questing_knight_passive_cooldown_reduction.buffs[1].multiplier = 0.2 -- 0.1
BuffTemplates.markus_questing_knight_passive_cooldown_reduction_improved.buffs[1].multiplier = 0.3 -- 0.15
mod_api.insert_text("markus_questing_knight_passive_cooldown_reduction", "+20%% Cooldown Regeneration")
mod_api.insert_text("markus_questing_knight_passive_cooldown_reduction_improved", "+30%% Cooldown Regeneration")

-- Grimoire/Tome quests: the goal is the health/headshot count, so the vanilla quest HUD counts them down.
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
	Virtue of the Ideal
]]
-- 10% power per stack (from 8%)
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_kills_buff_power_stacking_buff", {
	multiplier = 0.1 --0.08
})
mod_api.update_talent("es_questingknight", 2, 1, {
	description_values = { -- update description
		{
			value_type = "percent",
			value = 0.1, -- buff_tweak_data.markus_questing_knight_kills_buff_power_stacking_buff.multiplier
		},
		{
			value = 10, -- duration
		},
		{
			value = 3, -- max_stacks
		},
	},
})

--[[
	Virtue of Knightly Temper
]]
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_crit_can_insta_kill",  {
	damage_multiplier = 3 --4
})
mod_api.insert_text("markus_questing_knight_crit_can_insta_kill_desc", "Critical Strikes instantly slay enemies if their current health is less than 3 times the amount of damage of the Critical Strike. Half effect versus Lords and Monsters.")

--[[
	Virtue of Heroism
]]
-- Heavy attacks can't be interrupted. The perk is read on the owner's client (CharacterStateHelper), while the
-- heavy attack power stays server side, hence buffer "both" (vanilla "server").
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_uninterruptible_heavy", {
	max_stacks = 1,
	perks = {
		"uninterruptible_heavy"
	}
})
mod_api.update_talent("es_questingknight", 2, 3, {
	buffer = "both",
	buffs = {
		"markus_questing_knight_charged_attacks_increased_power",
		"tb_grail_uninterruptible_heavy"
	}
})
mod_api.insert_text("markus_questing_knight_charged_attacks_increased_power_desc", "Increases heavy attack damage by 30%% charging up to 300%%. Heavy attacks can no longer be interrupted.")

-- Charge bonus, on top of the flat 30%: up to +30% heavy attack damage, scaling with how long the charge was held past
-- the point where the heavy attack became available
local HEROISM_CHARGE_BONUS_MAX = 2.7
local HEROISM_EXTRA_CHARGE_TIME = 1.35
local HEROISM_CHARGE_BUFF = "tb_grail_heroism_charge_damage"
local HEROISM_FULL_CHARGE_POPUP_BUFF = "tb_grail_heroism_full_charge_ready"

mod_api.insert_talent_buff_template("empire_soldier", HEROISM_CHARGE_BUFF, {
	stat_buff = "increased_weapon_damage_heavy_attack",
	variable_multiplier_max = HEROISM_CHARGE_BONUS_MAX
})
-- Center-screen popup + icon while the charge is full, like Waywatcher's Ricochet (local only, refreshed every frame)
mod_api.insert_buff_template(HEROISM_FULL_CHARGE_POPUP_BUFF, {
	max_stacks = 1,
	duration = 0.5, -- refreshed every frame while charged, so it vanishes right after release
	refresh_durations = true,
	priority_buff = true,
	icon = "markus_questing_knight_charged_attacks_increased_power",
})

-- owner_unit -> { start_t, action, has_talent, ready_time, show_popup, last_t, release_t, buff_id }, only filled for units whose
-- melee charge runs on this machine
local tb_heroism_charges = setmetatable({}, { __mode = "k" })

local function tb_is_heavy_attack(sub_action)
	local profile_name_left, profile_name_right = ActionUtils.get_damage_profile_name(sub_action)
	local damage_profile = DamageProfileTemplates[profile_name_right or profile_name_left]

	return damage_profile and damage_profile.charge_value == "heavy_attack"
end

-- Time into the charge at which releasing gives a heavy attack: the earliest release chain into a heavy (sweep or
-- shield slam), scaled by attack speed the same way WeaponUnitExtension.is_chain_action_available scales it.
-- The full bonus always needs HEROISM_EXTRA_CHARGE_TIME past this; weapons that release the heavy by themselves
-- before that only get a partial bonus, by design (only weapons that can hold the charge indefinitely reach full).
local function tb_heroism_heavy_ready_time(owner_unit, melee_start_action)
	local weapon_template = WeaponUtils.get_weapon_template(melee_start_action.lookup_data.item_template_name)
	local actions = weapon_template and weapon_template.actions
	local ready_time

	for _, chain_action in ipairs(melee_start_action.allowed_chain_actions or {}) do
		if chain_action.input == "action_one_release" and chain_action.start_time then
			local target_action = actions and actions[chain_action.action] and actions[chain_action.action][chain_action.sub_action]

			if target_action and tb_is_heavy_attack(target_action) and (not ready_time or chain_action.start_time < ready_time) then
				ready_time = chain_action.start_time
			end
		end
	end

	return ready_time and ready_time / ActionUtils.get_action_time_scale(owner_unit, melee_start_action)
end

local function tb_heroism_remove_charge_buff(owner_unit, charge_data)
	local buff_id = charge_data.buff_id

	if buff_id and buff_id ~= -1 then
		Managers.state.entity:system("buff_system"):remove_buff_synced(owner_unit, buff_id)
	end

	charge_data.buff_id = nil
end

-- Remember the current charge and show the popup once it's full (runs every frame of a melee charge, through the
-- dispatcher in TourneyBalance.lua). Talent and heavy-ready time are only looked up once per charge.
mod:add_melee_start_post_update_function(function (self, dt, t, world)
	local owner_unit = self.owner_unit
	local charge_data = tb_heroism_charges[owner_unit]

	if not charge_data then
		charge_data = {}
		tb_heroism_charges[owner_unit] = charge_data
	end

	local start_t = self.action_start_t
	local current_action = self.current_action

	if charge_data.start_t ~= start_t or charge_data.action ~= current_action then
		local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")
		local has_talent = not not (talent_extension and talent_extension:has_talent("markus_questing_knight_charged_attacks_increased_power"))
		local owner_player = Managers.player:owner(owner_unit)

		charge_data.start_t = start_t
		charge_data.action = current_action
		charge_data.has_talent = has_talent
		charge_data.ready_time = has_talent and tb_heroism_heavy_ready_time(owner_unit, current_action) or nil
		charge_data.show_popup = has_talent and owner_player and owner_player.local_player and not owner_player.bot_player
	end

	charge_data.last_t = t

	if charge_data.show_popup and charge_data.ready_time and t - start_t >= charge_data.ready_time + HEROISM_EXTRA_CHARGE_TIME then
		local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

		if buff_extension then
			buff_extension:add_buff(HEROISM_FULL_CHARGE_POPUP_BUFF)
		end
	end
end)

-- Heavy attack start: add the charge buff sized to how long the charge was held. Heavies are sweeps (ActionSweep) or
-- shield bashes (ActionShieldSlam), so both are hooked.
local function tb_heroism_heavy_start(self, new_action, t)
	local owner_unit = self.owner_unit
	local charge_data = tb_heroism_charges[owner_unit]

	if not charge_data then
		return
	end

	-- Dual wield heavies (weapon_action_hand "both", e.g. mace and sword) start a sweep on each hand in the same frame
	-- (CharacterStateHelper: left, then right). The first hand handles the release, the second must keep its buff.
	if charge_data.release_t == t then
		return
	end

	charge_data.release_t = t

	tb_heroism_remove_charge_buff(owner_unit, charge_data)

	-- only an attack released straight out of a charge (not Blessed Blade, pushes or chained attacks)
	local charged_last_t = charge_data.last_t

	charge_data.last_t = nil

	-- ready_time is only set when the owner has Heroism
	local ready_time = charge_data.ready_time

	if not charged_last_t or t - charged_last_t > 0.1 or not ready_time or not tb_is_heavy_attack(new_action) then
		return
	end

	local charge_fraction = math.clamp((t - charge_data.start_t - ready_time) / HEROISM_EXTRA_CHARGE_TIME, 0, 1)

	if charge_fraction <= 0 then
		return
	end

	charge_data.buff_id = Managers.state.entity:system("buff_system"):add_buff_synced(owner_unit, HEROISM_CHARGE_BUFF, BuffSyncType.LocalAndServer, {
		variable_value = charge_fraction
	})
end

local function tb_heroism_heavy_finish(self)
	local charge_data = tb_heroism_charges[self.owner_unit]

	if charge_data then
		tb_heroism_remove_charge_buff(self.owner_unit, charge_data)
	end
end

mod:hook_safe(ActionSweep, "client_owner_start_action", tb_heroism_heavy_start)
mod:hook_safe(ActionSweep, "finish", tb_heroism_heavy_finish)
mod:hook_safe(ActionShieldSlam, "client_owner_start_action", tb_heroism_heavy_start)
mod:hook_safe(ActionShieldSlam, "finish", tb_heroism_heavy_finish)

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
-- Another 25% after 7s: a second refund, same vanilla proc and remove func with a longer delay
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_health_refund_over_time_late", {
	buff_func = "add_heal_percent_of_damage_taken_over_time_buff",
	buff_to_add = "tb_grail_health_refund_over_time_late_delayed_heal",
	event = "on_damage_taken",
	heal_amount_fraction = 0.25
})
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_health_refund_over_time_late_delayed_heal", {
	duration = 7,
	max_stacks = 1,
	refresh_durations = true,
	remove_buff_func = "refund_damage_taken",
	icon = "markus_questing_knight_health_refund_over_time"
})
mod_api.update_talent("es_questingknight", 5, 1, {
	buffs = {
		"markus_questing_knight_health_refund_over_time",
		"tb_grail_health_refund_over_time_late"
	}
})
mod_api.insert_text("markus_questing_knight_health_refund_over_time_desc", "25.0%% of damage taken is regenerated as temporary health after 5 seconds, and another 25.0%% after 7 seconds.")

--[[
	Virtue of Discipline
]]
-- 20% power for 10s on parry (from 6s)
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_parry_increased_power_buff", {
	multiplier = 0.2, --0.2
	duration = 10, --6
})
mod_api.update_talent("es_questingknight", 5, 2, {
	description_values = { -- update description
		{
			value_type = "percent",
			value = 0.2, -- buff_tweak_data.markus_questing_knight_parry_increased_power_buff.multiplier
		},
		{
			value = 10, -- buff_tweak_data.markus_questing_knight_parry_increased_power_buff.duration
		},
	},
})

--[[
	Virtue of the Joust
]]
-- Removes the "planted_*_decrease_movement" family's move-speed penalty (attacks and holding block use these)
-- while a melee weapon or Blessed Blade is wielded. Same approach as Ranger's No Dawdling (05_dr_ranger.lua).
local TB_JOUST_MOVEMENT_PENALTY_BUFFS = {
	"planted_decrease_movement",
	"planted_fast_decrease_movement",
	"planted_charging_decrease_movement",
}
-- Grail Knight carries a second melee weapon in his ranged slot, so that slot counts too
local TB_JOUST_WEAPON_SLOTS = {
	slot_melee = true,
	slot_ranged = true,
	slot_career_skill_weapon = true,
}

local function tb_joust_removes_movement_penalty(unit)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	if not (talent_extension and talent_extension:has_talent("markus_questing_knight_push_arc_stamina_reg")) then
		return false
	end

	local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")

	return not not (inventory_extension and TB_JOUST_WEAPON_SLOTS[inventory_extension:get_wielded_slot_name()])
end

for _, buff_name in ipairs(TB_JOUST_MOVEMENT_PENALTY_BUFFS) do
	mod:add_buff_apply_condition(buff_name, function (unit, template, params)
		return mod:is_action_movement_speed_up(params) or not tb_joust_removes_movement_penalty(unit)
	end)
end
mod_api.insert_text("markus_questing_knight_push_arc_stamina_reg_desc", "Increases push angle and stamina regeneration by 30%%. Removes the movement penalty from weapons.")

--[[
	Virtue of the Impetuous Knight
]]
-- Duration increased to 25s
mod_api.update_talent_buff_template("empire_soldier", "markus_questing_knight_ability_buff_on_kill_movement_speed", {
    duration = 25, --15
})
-- Buffs granted on career skill use instead of on Blessed Blade kills
mod_api.update_talent("es_questingknight", 6, 2, {
    buffs = {
        "tb_cd_grail",
		"tb_grail_movement_speed_on_ability",
		"tb_grail_no_knockback_on_ability"
    }
})
-- Additional 30% cdr
mod_api.insert_talent_buff_template("empire_soldier", "tb_cd_grail", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3,
	max_stacks = 1
})
-- Ranged knockback immunity for 25s after using Blessed Blade.
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
-- Both applied on the Grail Knight's own career skill use. on_ability_activated procs on every local player's buffs
-- whenever anyone ults (params[1] is the activating unit), so check it's the owner, like vanilla add_buff_reff_buff_stack.
-- The networked add_buff proc puts them on the server as well as the owner.
mod_api.insert_proc_function("tb_grail_add_buff_on_own_ability", function (owner_unit, buff, params)
	if params[1] == owner_unit then
		ProcFunctions.add_buff(owner_unit, buff, params)
	end
end)
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_movement_speed_on_ability", {
	buff_func = "tb_grail_add_buff_on_own_ability",
	buff_to_add = "markus_questing_knight_ability_buff_on_kill_movement_speed",
	event = "on_ability_activated",
	max_stacks = 1
})
mod_api.insert_talent_buff_template("empire_soldier", "tb_grail_no_knockback_on_ability", {
	buff_func = "tb_grail_add_buff_on_own_ability",
	buff_to_add = "tb_grail_no_knockback",
	event = "on_ability_activated",
	max_stacks = 1
})
mod_api.insert_text("markus_questing_knight_ability_buff_on_kill_desc", "Using Blessed Blade grants 35%% movement speed and immunity to knockback from ranged projectiles and Warpfire for 25 seconds. Reduces cooldown by 30%%.")

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


