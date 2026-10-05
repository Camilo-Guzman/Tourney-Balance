local mod = get_mod("TourneyBalance")
local mod_api = require("scripts/mods/TourneyBalance/_api/_mod_api")

--[[
	$BEGIN_TB
		---
		## Huntsman
		### Career Ability
		- Ultimate cooldown reduced to 60s (from 90s).
		- Reload speed buff from ultimate reduced to 25% (from 40%).

		### Passives
		**Poacher's Mark**
		- Added 15% increased reload speed.

		**Call out Weakness**
		- Aura range increased to 20 (from 5).

		### Talents
		**Burst of Enthusiasm**
		- Ranged kills restore thp equal to a quarter of bloodlust.
		
		**Longshanks**
		- Makes all ranged attacks pin point accurate and removes aim punch.
	$END_TB
]]

--[[

	Ultimate

]]
-- cooldown reduction
mod_api.update_career_ability_cooldown("es_1", 60)

--[[

	Passives

]]
--[[
	Poacher's Mark
]]
-- passive reload speed
mod_api.insert_talent_buff_template("empire_soldier", "tb_markus_huntsman_reload_passive", {
    stat_buff = "reload_speed",
	max_stacks = 1,
	multiplier = -0.15
})
-- ranged weapon zoom
mod_api.insert_career_passives("es_1", {
	"tb_markus_huntsman_reload_passive"
})
mod_api.insert_text("career_passive_desc_es_1b", "Double effective range for ranged weapons and 15% increased reload speed.")

--[[
	Hunter's Prowl
	Blend In
	Concealed Strikes
]]
-- Adjustment from passive. Ult reload speed nerf, because 15% was moved to passive
mod_api.update_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability_increased_reload_speed", {
	multiplier = -0.25 -- -0.4
})
--[[
	Head Down and Hidden
]]
-- Adjustment from passive. Ult reload speed nerf, because 15% was moved to passive
mod_api.update_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability_increased_reload_speed_duration", {
	multiplier = -0.25 -- -0.4
})


--[[
	Call out Weakness
]]
-- crit aura increased radius
mod_api.update_talent_buff_template("empire_soldier", "markus_huntsman_passive_crit_aura", {
    range = 20 -- 5
})


--[[

	Talents

]]
--[[
	Longshanks 
]]
-- 10% movement speed replaced with no pinpoint accuracy
mod_api.insert_talent_buff_template("empire_soldier", "tb_markus_huntsman_sniper_buff_1", {
    multiplier = -1,
    stat_buff = "reduced_spread",
})
mod_api.insert_talent_buff_template("empire_soldier", "tb_markus_huntsman_sniper_buff_2", {
    multiplier = -1,
    stat_buff = "reduced_spread_hit",
})
mod_api.insert_talent_buff_template("empire_soldier", "tb_markus_huntsman_sniper_buff_3", {
    multiplier = -3,
    stat_buff = "reduced_spread_moving",
})
mod_api.insert_talent_buff_template("empire_soldier", "tb_markus_huntsman_sniper_buff_4", {
    multiplier = -3,
    stat_buff = "reduced_spread_shot",
})
mod_api.update_talent("es_huntsman", 5, 3, {
    num_ranks = 1,
	description = "tb_markus_huntsman_sniper_desc",
    description_values = {},
    buffs = {
        "tb_markus_huntsman_sniper_buff_1",
		"tb_markus_huntsman_sniper_buff_2",
		"tb_markus_huntsman_sniper_buff_3",
		"tb_markus_huntsman_sniper_buff_4"
    },
})
mod_api.insert_text("tb_markus_huntsman_sniper_desc", "Makes all ranged attacks pin point accurate and removes aim punch.")

-- (FIX) Pin-point accuracy and remove aim-punch affecting blunderbuss
local ignored_damage_types = {
	temporary_health_degen = true,
	buff_shared_medpack_temp_health = true,
	buff_shared_medpack = true,
	buff = true,
	warpfire_ground = true,
	life_tap = true,
	health_degen = true,
	vomit_ground = true,
	wounded_dot = true,
	heal = true,
	life_drain = true
}
local function movement_spread_state(moving, crouching, zooming)
	local parts = {}
	if zooming then parts[#parts + 1] = "zoomed" end
	if crouching then parts[#parts + 1] = "crouch" end
	parts[#parts + 1] = moving and "moving" or "still"
	return table.concat(parts, "_")
end
-- extensions_ready needs no override: vanilla WeaponSpreadExtension.init already sets
-- self.item_name, so there's no equipment lookup left to add extensions_ready for.
mod:hook(WeaponSpreadExtension, "update", function (func, self, unit, input, dt, context, t)
	if self.item_name ~= "es_blunderbuss" then
		return func(self, unit, input, dt, context, t)
	end

	-- Blunderbuss is immune to reduced_spread/_moving/_hit/_shot buffs - the rest of
	-- this is otherwise identical to vanilla WeaponSpreadExtension.update.
	local current_pitch = self.current_pitch
	local current_yaw = self.current_yaw
	local current_state = self.current_state
	local state_settings = self.spread_settings.continuous[current_state]
	local new_pitch = state_settings.max_pitch
	local new_yaw = state_settings.max_yaw
	local status_extension = self.owner_status_extension
	local locomotion_extension = self.owner_locomotion_extension
	local moving = CharacterStateHelper.is_moving(locomotion_extension)
	local crouching = CharacterStateHelper.is_crouching(status_extension)
	local zooming = CharacterStateHelper.is_zooming(status_extension)
	local lerp_speed_pitch = (zooming and self.spread_lerp_speed_pitch_zoom) or self.spread_lerp_speed_pitch
	local lerp_speed_yaw = (zooming and self.spread_lerp_speed_yaw_zoom) or self.spread_lerp_speed_yaw

	if self.hit_aftermath then
		self.hit_timer = self.hit_timer - dt
		local rand = Math.random(0.5, 1)
		lerp_speed_pitch = rand
		lerp_speed_yaw = rand

		if self.hit_timer <= 0 then
			self.hit_aftermath = false
		end
	end

	local new_state = movement_spread_state(moving, crouching, zooming)
	-- (moving-spread buff intentionally skipped here: blunderbuss is immune)

	current_pitch = math.lerp(current_pitch, new_pitch, dt * lerp_speed_pitch)
	current_yaw = math.lerp(current_yaw, new_yaw, dt * lerp_speed_yaw)

	if current_state ~= new_state then
		self.current_state = new_state
	end

	local immediate_spread_settings = self.spread_settings.immediate
	local immediate_pitch = 0
	local immediate_yaw = 0
	local recent_damage_type = self.owner_health_extension:recently_damaged()
	local hit = recent_damage_type and not ignored_damage_types[recent_damage_type]

	if hit then
		local spread_settings = immediate_spread_settings.being_hit
		immediate_pitch = spread_settings.immediate_pitch
		immediate_yaw = spread_settings.immediate_yaw
		self.hit_aftermath = true
		self.hit_timer = 1.5
	end

	if self.shooting then
		local spread_settings = immediate_spread_settings.shooting
		immediate_pitch = spread_settings.immediate_pitch
		immediate_yaw = spread_settings.immediate_yaw
		self.shooting = false
	end

	self.current_pitch = math.min(current_pitch + immediate_pitch, SpreadTemplates.maximum_pitch)
	self.current_yaw = math.min(current_yaw + immediate_yaw, SpreadTemplates.maximum_yaw)
end)

--[[
	Burst of Enthusiam
]]
-- thp on ranged kill
mod_api.insert_proc_function("tb_markus_huntsman_heal_on_ranged_kill", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	if not ALIVE[owner_unit] then
		return
	end

	local killing_blow_data = params[1]

	if not killing_blow_data then
		return
	end

	local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

	if not (attack_type == "projectile" or attack_type == "instant_projectile") then
		return
	end

	local breed = params[2]

	if not (breed and breed.bloodlust_health and not breed.is_hero) then
		return
	end

	local heal_amount = (breed.bloodlust_health * 0.25) or 0

	DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
end)
mod_api.update_talent_buff_template("empire_soldier", "markus_huntsman_passive_temp_health_on_headshot", {
	bonus = nil,
	event = "on_kill",
	buff_func = "tb_markus_huntsman_heal_on_ranged_kill"
})
mod_api.update_talent("es_huntsman", 4, 3, {
	description = "tb_markus_huntsman_heal_on_ranged_kill_desc",
})
mod_api.insert_text("tb_markus_huntsman_heal_on_ranged_kill_desc", "Ranged kills restore thp equal to a quarter of bloodlust.")


