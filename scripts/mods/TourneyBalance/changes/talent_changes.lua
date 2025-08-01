local mod = get_mod("TourneyBalance")

--[[

██████╗░██╗░░░██╗███████╗███████╗  ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
██╔══██╗██║░░░██║██╔════╝██╔════╝  ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
██████╦╝██║░░░██║█████╗░░█████╗░░  █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
██╔══██╗██║░░░██║██╔══╝░░██╔══╝░░  ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
██████╦╝╚██████╔╝██║░░░░░██║░░░░░  ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░  ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

]]

local function is_server()
    return Managers.player.is_server
end
local function is_local(unit)
	local player = Managers.player:owner(unit)

	return player and not player.remote
end
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.modify_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end

    local original_buff = TalentBuffTemplates[hero_name][buff_name]
    local merged_buff = original_buff
    for i=1, #original_buff.buffs do
        if new_talent_buff.buffs[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs[i])
        elseif original_buff[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs)
        else
            merged_buff.buffs = merge(original_buff.buffs, new_talent_buff.buffs)
        end
    end

    TalentBuffTemplates[hero_name][buff_name] = merged_buff
    BuffTemplates[buff_name] = merged_buff
end
function mod.add_buff_template(self, buff_name, buff_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.add_proc_function(self, name, func)
    ProcFunctions[name] = func
end
function mod.add_buff_function(self, name, func)
    BuffFunctionTemplates.functions[name] = func
end
function mod.modify_talent(self, career_name, tier, index, new_talent_data)
	local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
	local talent_tree_index = career_settings.talent_tree_index

	local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
	local old_talent_id_lookup = TalentIDLookup[old_talent_name]
	local old_talent_id = old_talent_id_lookup.talent_id
	local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = merge(old_talent_data, new_talent_data)
end
function mod.add_buff(self, owner_unit, buff_name)
    if Managers.state.network ~= nil then
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit

        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
        local is_server = Managers.player.is_server

        if is_server then
            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

            buff_extension:add_buff(buff_name)
            network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end
    end
end
function mod.add_talent(self, career_name, tier, index, new_talent_name, new_talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index

    local new_talent_index = #Talents[hero_name] + 1

    Talents[hero_name][new_talent_index] = merge({
        name = new_talent_name,
        description = new_talent_name .. "_desc",
        icon = "icons_placeholder",
        num_ranks = 1,
        buffer = "both",
        requirements = {},
        description_values = {},
        buffs = {},
        buff_data = {},
    }, new_talent_data)

    TalentTrees[hero_name][talent_tree_index][tier][index] = new_talent_name
    TalentIDLookup[new_talent_name] = {
        talent_id = new_talent_index,
        hero_name = hero_name
    }
end

--[[

██╗░░██╗██████╗░██╗░░░██╗██████╗░███████╗██████╗░
██║░██╔╝██╔══██╗██║░░░██║██╔══██╗██╔════╝██╔══██╗
█████═╝░██████╔╝██║░░░██║██████╦╝█████╗░░██████╔╝
██╔═██╗░██╔══██╗██║░░░██║██╔══██╗██╔══╝░░██╔══██╗
██║░╚██╗██║░░██║╚██████╔╝██████╦╝███████╗██║░░██║
╚═╝░░╚═╝╚═╝░░╚═╝░╚═════╝░╚═════╝░╚══════╝╚═╝░░╚═╝

]]

--[[

	Mercenary Talents

]]

-- Helborg's Tutelage
-- Added in random crits.
Talents.empire_soldier[43].perks = nil
mod:modify_talent("es_mercenary", 2, 3, {
    description = "markus_mercenary_helborg_desc",
    description_values = {},
})
mod:add_text("markus_mercenary_helborg_desc", "Every 5 hits grant a guaranteed critical strike. Critical strikes can still occur randomly.")

-- Enhanced Training (removed downside of the talent to compete against others in the row)
mod:add_text("markus_mercenary_passive_improved_desc", "Paced Strikes now increases attack speed by 20.0%%")
mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_passive_improved", {
    targets = 3
})
mod:add_proc_function("gain_markus_mercenary_passive_proc", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local buff_template = buff.template
	local target_number = params[4]
	local attack_type = params[2]
	local buff_to_add = buff_template.buff_to_add
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_applied = true

	if ALIVE[owner_unit] and target_number and target_number >= buff_template.targets and (attack_type == "light_attack" or attack_type == "heavy_attack") then
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

		if talent_extension:has_talent("markus_mercenary_passive_improved", "empire_soldier", true) then
			if target_number >= 3 then
				buff_system:add_buff(owner_unit, "markus_mercenary_passive_improved", owner_unit, false)
			else
				buff_applied = false
			end
		elseif talent_extension:has_talent("markus_mercenary_passive_group_proc", "empire_soldier", true) then
			local side = Managers.state.side.side_by_unit[owner_unit]
			local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
			local num_units = #player_and_bot_units

			for i = 1, num_units do
				local unit = player_and_bot_units[i]

				if HEALTH_ALIVE[unit] then
					buff_system:add_buff(unit, buff_to_add, owner_unit, false)
				end
			end
		elseif talent_extension:has_talent("markus_mercenary_passive_power_level_on_proc", "empire_soldier", true) then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_power_level", owner_unit, false)
			buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
		else
			buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
		end

		if talent_extension:has_talent("markus_mercenary_passive_defence_on_proc", "empire_soldier", true) and buff_applied then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_defence", owner_unit, false)
		end
	end
end)

--[[

	Huntsman Talents

]]
ActivatedAbilitySettings.es_1[1].cooldown = 60
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_passive_crit_aura", {
    range = 20
})
mod:add_talent_buff_template("empire_soldier", "markus_huntsman_reload_passive", {
    stat_buff = "reload_speed",
	max_stacks = 1,
	multiplier = -0.15
})
table.insert(PassiveAbilitySettings.es_1.buffs, "markus_huntsman_reload_passive")
table.insert(PassiveAbilitySettings.es_1.buffs, "kerillian_waywatcher_passive_increased_zoom")
mod:add_text("career_passive_desc_es_1b", "Double effective range for ranged weapons and 15% increased reload speed.")

mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability_increased_reload_speed", {
	multiplier = -0.25
})
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability_increased_reload_speed_duration", {
	multiplier = -0.25
})
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability", {
	reload_speed_multiplier = -0.25
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_1", {
    multiplier = -1,
    stat_buff = "reduced_spread",
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_2", {
    multiplier = -1,
    stat_buff = "reduced_spread_hit",
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_3", {
    multiplier = -3,
    stat_buff = "reduced_spread_moving",
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_4", {
    multiplier = -3,
    stat_buff = "reduced_spread_shot",
})
mod:modify_talent("es_huntsman", 5, 3, {
    num_ranks = 1,
	description = "gs_sniper_desc",
    description_values = {},
    buffs = {
        "gs_sniper_buff_1",
		"gs_sniper_buff_2",
		"gs_sniper_buff_3",
		"gs_sniper_buff_4"
    },
})
mod:add_text("gs_sniper_desc", "Makes all ranged attacks pin point accurate and removes aim punch.")

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

mod:hook_origin(WeaponSpreadExtension, "extensions_ready", function (self, world, unit)
	local owner_unit = self.owner_unit
	self.owner_health_extension = ScriptUnit.extension(owner_unit, "health_system")
	self.owner_status_extension = ScriptUnit.extension(owner_unit, "status_system")
	self.owner_buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	self.owner_locomotion_extension = ScriptUnit.extension(owner_unit, "locomotion_system")
	self.owner_inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
end)

mod:hook_origin(WeaponSpreadExtension, "update", function (self, unit, input, dt, context, t)
	local current_pitch = self.current_pitch
	local current_yaw = self.current_yaw
	local current_state = self.current_state
	local continuous_spread_settings = self.spread_settings.continuous
	local state_settings = continuous_spread_settings[current_state]
	local owner_buff_extension = self.owner_buff_extension
	local owner_inventory_extension = self.owner_inventory_extension
	local equipment = owner_inventory_extension:equipment()
	local slot_data = equipment.slots.slot_ranged
	local item_name = nil
	if slot_data then
		local item_data = slot_data.item_data
		item_name = item_data.name
	end

	local new_pitch = nil
	local new_yaw = nil

	if item_name == "es_blunderbuss" then
		new_pitch = state_settings.max_pitch
		new_yaw = state_settings.max_yaw
	else
		new_pitch = owner_buff_extension:apply_buffs_to_value(state_settings.max_pitch, "reduced_spread")
		new_yaw = owner_buff_extension:apply_buffs_to_value(state_settings.max_yaw, "reduced_spread")
	end
	local status_extension = self.owner_status_extension
	local locomotion_extension = self.owner_locomotion_extension
	local moving = CharacterStateHelper.is_moving(locomotion_extension)
	local crouching = CharacterStateHelper.is_crouching(status_extension)
	local zooming = CharacterStateHelper.is_zooming(status_extension)
	local new_state = nil
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

	if moving then
		if crouching then
			if zooming then
				new_state = "zoomed_crouch_moving"
			else
				new_state = "crouch_moving"
			end
		elseif zooming then
			new_state = "zoomed_moving"
		else
			new_state = "moving"
		end
	elseif crouching then
		if zooming then
			new_state = "zoomed_crouch_still"
		else
			new_state = "crouch_still"
		end
	elseif zooming then
		new_state = "zoomed_still"
	else
		new_state = "still"
	end

	if moving and not item_name == "es_blunderbuss" then
		new_pitch = owner_buff_extension:apply_buffs_to_value(new_pitch, "reduced_spread_moving")
		new_yaw = owner_buff_extension:apply_buffs_to_value(new_yaw, "reduced_spread_moving")
	end

	current_pitch = math.lerp(current_pitch, new_pitch, dt * lerp_speed_pitch)
	current_yaw = math.lerp(current_yaw, new_yaw, dt * lerp_speed_yaw)

	if current_state ~= new_state then
		self.current_state = new_state
	end

	local immediate_spread_settings = self.spread_settings.immediate
	local immediate_pitch = 0
	local immediate_yaw = 0
	local health_extension = self.owner_health_extension
	local recent_damage_type = health_extension:recently_damaged()
	local hit = recent_damage_type and not ignored_damage_types[recent_damage_type]

	if hit then
		local spread_settings = immediate_spread_settings.being_hit
		if item_name == "es_blunderbuss" then
			immediate_pitch = spread_settings.immediate_pitch
			immediate_yaw = spread_settings.immediate_yaw
		else
			immediate_pitch = owner_buff_extension:apply_buffs_to_value(spread_settings.immediate_pitch, "reduced_spread_hit")
			immediate_yaw = owner_buff_extension:apply_buffs_to_value(spread_settings.immediate_yaw, "reduced_spread_hit")
		end
		self.hit_aftermath = true
		self.hit_timer = 1.5
	end

	if self.shooting then
		local spread_settings = immediate_spread_settings.shooting
		if item_name == "es_blunderbuss" then
			immediate_pitch = spread_settings.immediate_pitch
			immediate_yaw = spread_settings.immediate_yaw
		else
			immediate_pitch = owner_buff_extension:apply_buffs_to_value(spread_settings.immediate_pitch, "reduced_spread_shot")
			immediate_yaw = owner_buff_extension:apply_buffs_to_value(spread_settings.immediate_yaw, "reduced_spread_shot")
		end
		self.shooting = false
	end

	current_pitch = current_pitch + immediate_pitch
	current_yaw = current_yaw + immediate_yaw
	self.current_pitch = math.min(current_pitch, SpreadTemplates.maximum_pitch)
	self.current_yaw = math.min(current_yaw, SpreadTemplates.maximum_yaw)
end)

mod:add_proc_function("gs_heal_on_ranged_kill", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
			return
		end

	if ALIVE[owner_unit] then
		local killing_blow_data = params[1]

		if not killing_blow_data then
			return
		end

		local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

		if attack_type and (attack_type == "projectile" or attack_type == "instant_projectile") then
			local breed = params[2]

			if breed and breed.bloodlust_health and not breed.is_hero then
				local heal_amount = (breed.bloodlust_health * 0.25) or 0

				DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
			end
		end
	end
end)
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_passive_temp_health_on_headshot", {
	bonus = nil,
	event = "on_kill",
	buff_func = "gs_heal_on_ranged_kill"
})
mod:modify_talent("es_huntsman", 4, 3, {
	description = "gs_hs_4_3_desc",
})
mod:add_text("gs_hs_4_3_desc", "Ranged kills restore thp equal to a quarter of bloodlust.")

--[[

	Footknight Talents

]]
mod:modify_talent_buff_template("empire_soldier", "markus_knight_ability_cooldown_on_damage_taken", {
	bonus = 0.35
 })
mod:modify_talent_buff_template("empire_soldier", "markus_knight_power_level_on_stagger_elite_buff", {
	duration = 15
})
mod:modify_talent("es_knight", 2, 2, {
	description_values = {
		{
			value_type = "percent",
			value = 0.15 --BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.multiplier
		},
		{
			value = 15 --BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.duration
		}
	},
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_attack_speed_on_push_buff", {
	duration = 5
})
mod:modify_talent("es_knight", 2, 3, {
	description_values = {
		{
			value_type = "percent",
			value = 0.15 --BuffTemplates.markus_knight_attack_speed_on_push_buff.multiplier
		},
		{
			value = 5 --BuffTemplates.markus_knight_attack_speed_on_push_buff.duration
		}
	},
})
mod:add_buff_function("markus_hero_time_reset", function (unit, buff, params)
	local player_unit = unit

	if Unit.alive(player_unit) then
		local career_extension = ScriptUnit.has_extension(player_unit, "career_system")

		career_extension:reduce_activated_ability_cooldown_percent(0.7)
	end
end)
mod:add_text("markus_knight_charge_reset_on_incapacitated_allies_desc", "Refunds 70% of cooldown upon allied incapacitation")
mod:modify_talent("es_knight", 2, 1, {
	description = "markus_knight_power_level_impact_desc",
	name = "markus_knight_power_level_impact",
	buffer = "server",
	num_ranks = 1,
	icon = "markus_knight_power_level_impact",
	description_values = {
		{
			value_type = "percent",
			value = 0.2
		}
	},
	buffs = {
		"markus_knight_power_level_impact"
	}
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_power_level_impact", {
	multiplier = 0.2
})
mod:add_text("markus_knight_power_level_impact_descmarkus_knight_power_level_impact_desc", "Increases stagger power by 20%.")

mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_on_stagger_elite", {
	buff_func = "buff_on_stagger_enemy"
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_buff", {
	duration = 1.5,
	multiplier = 2,
	icon = "markus_knight_improved_passive_defence_aura"
})
mod:add_text("markus_knight_cooldown_on_stagger_elite_desc", "Subjecting an elite enemy to a stagger state grants the player an accelerated cooldown of their career skill by a magnitude of 200%% for 1500 milliseconds.")

 --[[

	Grail Knight

]]
mod:modify_talent_buff_template("empire_soldier", "markus_questing_knight_ability_buff_on_kill_movement_speed", {
    duration = 25
})
mod:modify_talent("es_questingknight", 6, 2, {
    buffs = {
        "tb_cd_grail",
		"markus_questing_knight_ability_buff_on_kill"
    }
})
mod:add_talent_buff_template("empire_soldier", "tb_cd_grail", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3,
	max_stacks = 1
})
mod:add_text("markus_questing_knight_ability_buff_on_kill_desc", "Killing an enemy with Blessed Blade increases movement speed by 35%% for 25 seconds. Reduces cooldown by 30%%.")


--[[

██████╗░░█████╗░██████╗░██████╗░██╗███╗░░██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║████╗░██║
██████╦╝███████║██████╔╝██║░░██║██║██╔██╗██║
██╔══██╗██╔══██║██╔══██╗██║░░██║██║██║╚████║
██████╦╝██║░░██║██║░░██║██████╔╝██║██║░╚███║
╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░╚══╝

]]

--[[

	Ranger Veteran Talents

]]


mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_passive", {
	buff_func = "gs_bardin_ranger_scavenge_proc"
})

-- Foe Feller
-- Now grants 15% AS. (5% before)
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_attack_speed", {
	multiplier = 0.15
})
mod:modify_talent("dr_ranger", 2, 3, {
    description = "ranger_veteran_foe_feller_attack_speed_desc",
    description_values = {},
})
mod:add_text("ranger_veteran_foe_feller_attack_speed_desc", "Increases attack speed by 15.0%.")


--Ales
Weapons.bardin_survival_ale.actions.action_one.default.total_time = 0.8

mod:add_proc_function("gs_bardin_ranger_scavenge_proc", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local offset_position_1 = Vector3(0, 0.25, 0)
	local offset_position_2 = Vector3(0, -0.25, 0)

	if Unit.alive(owner_unit) then
		local drop_chance = buff.template.drop_chance
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
		local result = math.random(1, 100)

		if result < drop_chance * 100 then
			local player_pos = POSITION_LOOKUP[owner_unit] + Vector3.up() * 0.1
			local raycast_down = true
			local pickup_system = Managers.state.entity:system("pickup_system")

			if talent_extension:has_talent("bardin_ranger_passive_spawn_potions_or_bombs", "dwarf_ranger", true) then
				local counter = buff.counter
				local spawn_requirement = 18
				if counter == 5 then
					local randomness = math.random(1, 4)
					buff.counter = buff.counter + randomness
				end

				if not counter or counter >= spawn_requirement then
					local potion_result = math.random(1, 3)

					if potion_result >= 1 and potion_result <= 3 then
						local game_mode_key = Managers.state.game_mode:game_mode_key()
						local custom_potions = BardinScavengerCustomPotions[game_mode_key]
						local damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown
						local speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown
						local cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown

						if custom_potions then
							local custom_potion_result = math.random(1, #custom_potions)

							pickup_system:buff_spawn_pickup(custom_potions[custom_potion_result], player_pos, raycast_down)
						elseif (potion_result == 1 and not damage_boost_potion_cooldown) or (damage_boost_potion_cooldown and damage_boost_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("damage_boost_potion", player_pos, raycast_down)
							buff.damage_boost_potion_cooldown = 0
							if speed_boost_potion_cooldown then
								buff.speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown + 1
							else
								buff.speed_boost_potion_cooldown = math.random(1, 2)
							end
							if cooldown_reduction_potion_cooldown then
								buff.cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown + 1
							else
								buff.cooldown_reduction_potion_cooldown = 2
							end
						elseif (potion_result == 2 and not speed_boost_potion_cooldown) or (speed_boost_potion_cooldown and speed_boost_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("speed_boost_potion", player_pos, raycast_down)
							buff.speed_boost_potion_cooldown = 0
							if damage_boost_potion_cooldown then
								buff.damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown + 1
							else
								buff.damage_boost_potion_cooldown = math.random(1, 2)
							end
							if cooldown_reduction_potion_cooldown then
								buff.cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown + 1
							else
								buff.cooldown_reduction_potion_cooldown = 2
							end
						elseif (potion_result == 3 and not cooldown_reduction_potion_cooldown) or (cooldown_reduction_potion_cooldown and cooldown_reduction_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("cooldown_reduction_potion", player_pos, raycast_down)
							buff.cooldown_reduction_potion_cooldown = 0
							if damage_boost_potion_cooldown then
								buff.damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown + 1
							else
								buff.damage_boost_potion_cooldown = math.random(1, 2)
							end
							if speed_boost_potion_cooldown then
								buff.speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown + 1
							else
								buff.speed_boost_potion_cooldown = 2
							end
						end
					elseif potion_result == 4 then
						pickup_system:buff_spawn_pickup("frag_grenade_t1", player_pos, raycast_down)
					elseif potion_result == 5 then
						pickup_system:buff_spawn_pickup("fire_grenade_t1", player_pos, raycast_down)
					end
					buff.counter = 0
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
					buff.counter = buff.counter + 1
				end
			elseif talent_extension:has_talent("bardin_ranger_passive_improved_ammo") then
				pickup_system:buff_spawn_pickup("ammo_ranger_improved", player_pos, raycast_down)
			elseif talent_extension:has_talent("bardin_ranger_passive_ale") then
				local drop_result = math.random(1, 4)

				if drop_result == 1 or drop_result == 2 then
					pickup_system:buff_spawn_pickup("bardin_survival_ale", player_pos + offset_position_1, raycast_down)
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos + offset_position_2, raycast_down)
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
				end
			else
				pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
			end
		end
	end
end)
mod:add_text("bardin_ranger_passive_spawn_potions_or_bombs_desc", "Killing a special has a 6%% chance to drop a potion instead of a Survivalist cache.")


mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_reduced_damage_taken_headshot_buff", {
	multiplier = -0.2
})

mod:modify_talent("dr_ranger", 5, 2, {
    description_values = {
		{
			value_type = "percent",
			value = -0.2
		},
		{
			value = 7
		}
	},
})

mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_ability_free_grenade_buff", {
	duration = 10,
    refresh_durations = true
})

--[[

	Iron Breaker Talents

]]
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_ability_cooldown_on_damage_taken", {
    bonus = 0.4
})
mod:hook_origin(CareerAbilityDRIronbreaker, "_run_ability", function(self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
	local career_extension = self._career_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	CharacterStateHelper.play_animation_event(owner_unit, "iron_breaker_active_ability")

	local buffs = {
		"bardin_ironbreaker_activated_ability",
		"bardin_ironbreaker_activated_ability_block_cost",
		"bardin_ironbreaker_activated_ability_attack_intensity_decay_increase"
	}

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_range_and_duration") then
		table.clear(buffs)

		buffs = {
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration",
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration_block_cost",
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration_attack_intensity_decay_increase"
		}
	end

	local targets = FrameTable.alloc_table()
	targets[1] = owner_unit
	local range = 10
	local duration = 10

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_range_and_duration") then
		duration = 10
		range = 15
	end

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_power_buff_allies") then
		local side = Managers.state.side.side_by_unit[owner_unit]
		local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
		local num_targets = #player_and_bot_units

		for i = 1, num_targets, 1 do
			local target_unit = player_and_bot_units[i]
			local ally_position = POSITION_LOOKUP[target_unit]
			local owner_position = POSITION_LOOKUP[owner_unit]
			local distance_squared = Vector3.distance_squared(owner_position, ally_position)
			local range_squared = range * range

			if distance_squared < range_squared then
				local buff_to_add = "bardin_ironbreaker_activated_ability_power_buff"
				local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
				local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")
				local buff_template_name_id = NetworkLookup.buff_templates[buff_to_add]

				if is_server then
					target_buff_extension:add_buff(buff_to_add)
					network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, false)
				else
					network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, true)
				end
			end
		end
	end

	local stagger = true
	local taunt_bosses = talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_bosses")

	if is_server then
		local target_override_extension = ScriptUnit.extension(owner_unit, "target_override_system")

		target_override_extension:taunt(range, duration, stagger, taunt_bosses)
	else
		network_transmit:send_rpc_server("rpc_taunt", owner_unit_id, range, duration, stagger, taunt_bosses)
	end

	local num_targets = #targets

	for i = 1, num_targets, 1 do
		local target_unit = targets[i]
		local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
		local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")

		for j, buff_name in ipairs(buffs) do
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			if is_server then
				target_buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})
				network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, true)
			end
		end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("ability_shout")
		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_ironbreaker_enter")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_bardin_ironbreaker_enter", owner_unit, 0)
	end

	self:_play_vfx()
	self:_play_vo()
	career_extension:start_activated_ability_cooldown()
end)

-- Vengeance Buff
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_stacking_buff_gromril", {
    update_frequency = 3 --7
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_attack_speed", {
    multiplier = 0.06, -- 0.08
    duration = 12 -- 10
})
mod:modify_talent("dr_ironbreaker", 4, 1, {
    description = "bardin_ironbreaker_rising_attack_speed_desc",
    description_values = {},
})
mod:add_text("bardin_ironbreaker_rising_attack_speed_desc", "Periodically generate stacks (up to 5 max) of Rising Anger every 3 seconds while Gromril is active. When Gromril is lost, gain 6.0% attack speed per stack of Rising Anger for 12 seconds.")

-- Under Pressure Buff
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_increased_ranged_power", {
	{
		stat_buff = "increased_weapon_damage_ranged"   
	},
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_ranged_power", {
	{
		stat_buff = "increased_weapon_damage_ranged"   
	},
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_changing_ranged_power", {
	{
		stat_buff = "increased_weapon_damage_ranged",
		multiplier = -0.2 -- -0.8
	},
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_drakefire_attack_speed", {
	{
		stat_buff = "attack_speed_drakefire",
		multiplier = -0.05 -- -0.15
	},
})
mod:modify_talent("dr_ironbreaker", 2, 1, {
    description = "bardin_ironbreaker_overcharge_increase_power_lowers_attack_speed_desc",
    description_values = {},
})
mod:add_text("bardin_ironbreaker_overcharge_increase_power_lowers_attack_speed_desc", "Drake Fire damage increases from -20.0% to 120.0% and ranged attack speed reduces from 100.0% to 50.0% depending on overcharge. Removes overcharge slowdown.")

-- Rune-Etched Shield description correction
mod:add_text("bardin_ironbreaker_party_power_on_blocked_attacks_desc", "Blocking an attack increases Bardin's melee power (and that of nearby allies) by 2.0%% for 10 seconds. Stacks 5 times.")



--[[

	Slayer Talents

]]
PassiveAbilitySettings.dr_2.perks = {
	{
		display_name = "career_passive_name_dr_2b",
		description = "career_passive_desc_dr_2b_2"
	},
	{
		display_name = "career_passive_name_dr_2c",
		description = "career_passive_desc_dr_2c"
	}
}
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_damage_reduction_on_melee_charge_action_buff", {
	multiplier = -0.4
})
mod:modify_talent("dr_slayer", 5, 2, {
	description_values = {
		{
			value_type = "percent",
		value = -0.4
		},
		{
			value = 5
		}
	}
})
mod:modify_talent("dr_slayer", 2, 3, {
	description = "gs_bardin_slayer_crit_chance_desc"
})
mod:add_text("gs_bardin_slayer_crit_chance_desc", "Increases critical hit chance by 10%%.")
mod:add_proc_function("gs_add_bardin_slayer_passive_buff", function(owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local buff_system = Managers.state.entity:system("buff_system")

	if Unit.alive(owner_unit) then
		local buff_name = "bardin_slayer_passive_stacking_damage_buff"
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		if talent_extension:has_talent("bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_name = "bardin_slayer_passive_increased_max_stacks"
		end
		buff_system:add_buff(owner_unit, buff_name, owner_unit, false)

		if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) then
			buff_system:add_buff(owner_unit, "bardin_slayer_passive_movement_speed", owner_unit, false)
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_dodge_range", owner_unit, false)
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_dodge_speed", owner_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) then
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_cooldown_reduction", owner_unit, false)
		end
	end
end)
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_stacking_damage_buff_on_hit", {
	buff_func = "gs_add_bardin_slayer_passive_buff"
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_range", {
	max_stacks = 3,
	multiplier = 1.05,
	duration = 2,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"distance_modifier"
	}
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_speed", {
	max_stacks = 3,
	multiplier = 1.05,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"speed_modifier"
	}
})

mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_crit_chance", {
	bonus = 0.1
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_cooldown_reduction", {
	icon = "bardin_slayer_passive_cooldown_reduction_on_max_stacks",
	stat_buff = "cooldown_regen",
	max_stacks = 3,
	refresh_durations = true,
	duration = 2,
	multiplier = 0.67
})

mod:modify_talent("dr_slayer", 4, 3, {
	description = "gs_bardin_slayer_passive_cooldown_reduction_desc",
	description_values = {}
})
mod:add_text("gs_bardin_slayer_passive_cooldown_reduction_desc", "Each stack of Trophy Hunter increases cooldown regeneration by 67%.")
mod:add_talent_buff_template("dwarf_ranger", "bardin_slayer_dodge_speed", {
	multiplier = 1.1,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	path_to_movement_setting_to_modify = {
		"dodging",
		"speed_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "bardin_slayer_dodge_range", {
	multiplier = 1.1,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	path_to_movement_setting_to_modify = {
		"dodging",
		"distance_modifier"
	}
})
mod:modify_talent("dr_slayer", 5, 3, {
	description = "gs_bardin_slayer_push_on_dodge_desc",
	server = "both",
	buffs = {
		"bardin_slayer_push_on_dodge",
		"bardin_slayer_dodge_range",
		"bardin_slayer_dodge_speed"
	}
})
mod:add_text("gs_bardin_slayer_push_on_dodge_desc", "Effective dodges pushes nearby small enemies out of the way. Increases dodge range by 10%.")
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_attack_speed_on_double_one_handed_weapons", {
	multiplier = 0.15
})
mod:add_text("bardin_slayer_attack_speed_on_double_one_handed_weapons_desc", "Gain 15.0%% attack speed if wielding 2 one-handed weapons.")
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_push_on_dodge", {
	stat_buff = "damage_taken",
	multiplier = -0.15
})
mod:modify_talent("dr_slayer", 5, 3, {
	buffs = {
		"bardin_slayer_push_on_dodge"
	}
})
mod:add_text("gs_bardin_slayer_push_on_dodge_desc", "Effective dodges pushes nearby small enemies out of the way. Increases dodge range by 10% and reduces damage taken by 15%.")

-- level 20
-- Impatience - added unlisted dodge range modifier
mod:add_text("bardin_slayer_passive_movement_speed_desc", "Each stack of Trophy Hunter increases movement speed by 10.0%% and dodge range by 5.0%%.")

-- level 30
-- Parting Gift
mod:add_talent_buff_template("dwarf_ranger", "dwarf_ranger_less_burn_on_after_ult_buff", {
    icon = "bardin_ranger_passive_spawn_healing_draught",
    stat_buff = "increased_burn_dot_damage",
    multiplier = -0.52,
	max_stacks = 1,
    refresh_durations = true,
    duration = 15
})
mod:add_talent_buff_template("dwarf_ranger", "dwarf_ranger_less_burn_on_after_ult", {
    buff_func = "add_buff",
    buff_to_add = "dwarf_ranger_less_burn_on_after_ult_buff",
    event = "on_ability_cooldown_started"
})
mod:modify_talent("dr_ranger", 6, 3, {
    buffs = {
        "bardin_ranger_ability_free_grenade_buff",
        "dwarf_ranger_less_burn_on_after_ult"
    }
})
mod:add_text("bardin_ranger_ability_free_grenade_desc", "During Disengage Bardin's bomb throw will not be consumed. Only applicable to one bomb. DOT damage is reduced.")



--[[

	Outcast Engineer Talents

]]
--[[ Removed due to new Balance Patch of the official Game (6.0.0)
mod:add_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_count", {
	buff_to_add = "bardin_engineer_ranged_crit_counter_buff",
	max_stacks = 1,
	stat_buff = "critical_strike_chance_ranged",
	buff_func = "add_buff_on_first_target_hit",
	event = "on_hit",
	client_side = true,
	valid_attack_types = {
		instant_projectile = true,
		heavy_instant_projectile = true,
		projectile = true
	}
})
mod:add_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_counter_buff", {
	reset_on_max_stacks = true,
	on_max_stacks_func = "add_remove_buffs",
    max_stacks = 4,     -- 5
	is_cooldown = true,
	icon = "bardin_engineer_ranged_crit_count",
	max_stack_data = {
		buffs_to_add = {
			"bardin_engineer_ranged_crit_count_buff"
		}
	}
})
mod:add_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_count_buff", {
    event = "on_critical_shot",
    max_stacks = 1,
    stat_buff = "critical_strike_chance_ranged",
    buff_func = "dummy_function",
    remove_on_proc = true,
    icon = "bardin_engineer_ranged_crit_count",
    priority_buff = true,
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_ranged_crit_count_buff", {
    bonus = 1
})
mod:modify_talent("dr_engineer", 2,1, {
	icon = "bardin_engineer_ranged_crit_count",
	buffs = {
		"bardin_engineer_ranged_crit_count"
	}
})

mod:add_text("bardin_engineer_improved_explosives_desc", "Every 4th Ranged Attack is a guaranteed Critical Hit.")
mod:add_text("bardin_engineer_melee_power_ranged_power_desc", "Melee Power is increased by 10%%. Every 5 Melee Strikes makes Bardin's next Ranged Attack grant 15%% Ranged Power for 10 seconds.")
]]

--[[

██╗░░██╗███████╗██████╗░██╗██╗░░░░░██╗░░░░░██╗░█████╗░███╗░░██╗
██║░██╔╝██╔════╝██╔══██╗██║██║░░░░░██║░░░░░██║██╔══██╗████╗░██║
█████═╝░█████╗░░██████╔╝██║██║░░░░░██║░░░░░██║███████║██╔██╗██║
██╔═██╗░██╔══╝░░██╔══██╗██║██║░░░░░██║░░░░░██║██╔══██║██║╚████║
██║░╚██╗███████╗██║░░██║██║███████╗███████╗██║██║░░██║██║░╚███║
╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝╚══════╝╚══════╝╚═╝╚═╝░░╚═╝╚═╝░░╚══╝

]]

--[[

	Waystalker Talents

]]
mod:modify_talent_buff_template("wood_elf", "kerillian_waywatcher_passive", {
    update_func = "gs_update_kerillian_waywatcher_regen"
})

mod:add_text("career_passive_desc_we_3a_2", "Kerillian regenerates 3 health every 10 seconds. This does not replace temp health.")
mod:add_text("kerillian_waywatcher_improved_regen_desc_2", "Increases Kerillian's health regenerated from Amaranthe by 100%%.")

mod:add_buff_function("gs_update_kerillian_waywatcher_regen", function (unit, buff, params)
    local t = params.t
    local buff_template = buff.template
    local next_heal_tick = buff.next_heal_tick or 0
    local regen_cap = 1
    local network_manager = Managers.state.network
    local network_transmit = network_manager.network_transmit
    local heal_type_id = NetworkLookup.heal_types.career_skill
    local time_between_heals = buff_template.time_between_heals

    if next_heal_tick < t and Unit.alive(unit) then
        local talent_extension = ScriptUnit.extension(unit, "talent_system")
        local cooldown_talent = talent_extension:has_talent("kerillian_waywatcher_passive_cooldown_restore", "wood_elf", true)

        if cooldown_talent then
            local weapon_slot = "slot_ranged"
            local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
            local slot_data = inventory_extension:get_slot_data(weapon_slot)

            if slot_data then
                local right_unit_1p = slot_data.right_unit_1p
                local left_unit_1p = slot_data.left_unit_1p
                local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
                local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
                local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension

                if ammo_extension then
                    local ammo_bonus_fraction = 0.05
                    local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

                    ammo_extension:add_ammo_to_reserve(ammo_amount)
                end
            end
        end

        -- if Managers.state.network.is_server and not cooldown_talent then
        if Managers.state.network.is_server then
            local health_extension = ScriptUnit.extension(unit, "health_system")
            local status_extension = ScriptUnit.extension(unit, "status_system")
            local heal_amount = buff_template.heal_amount

            if talent_extension:has_talent("kerillian_waywatcher_improved_regen", "wood_elf", true) then
                regen_cap = 1
                heal_amount = heal_amount * 2
            end

            if health_extension:is_alive() and not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() then
                if talent_extension:has_talent("kerillian_waywatcher_group_regen", "wood_elf", true) then
                    local side = Managers.state.side.side_by_unit[unit]

                    if not side then
                        return
                    end

                    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

                    for i = 1, #player_and_bot_units, 1 do
                        if Unit.alive(player_and_bot_units[i]) then
                            local health_extension = ScriptUnit.extension(player_and_bot_units[i], "health_system")
                            local status_extension = ScriptUnit.extension(player_and_bot_units[i], "status_system")

                            if health_extension:current_permanent_health_percent() <= regen_cap and not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() and health_extension:is_alive() then
                                -- DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "career_passive")
                                -- local unit_object_id = network_manager:unit_game_object_id(player_and_bot_units[i])
                                -- if unit_object_id then
                                    -- network_transmit:send_rpc_server("rpc_request_heal", unit_object_id, heal_amount, heal_type_id)
                                -- end
								-- give THP first so it doesn't grant GHP + THP resulting in double regen
								DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "heal_from_proc")
								DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "career_passive")
                            end
                        end
                    end
                elseif health_extension:current_permanent_health_percent() <= regen_cap then
                    -- DamageUtils.heal_network(unit, unit, heal_amount, "career_passive")
					-- give THP first so it doesn't grant GHP + THP resulting in double regen
					DamageUtils.heal_network(unit, unit, heal_amount, "heal_from_proc")
					DamageUtils.heal_network(unit, unit, heal_amount, "career_passive")
                end
            end
        end

        buff.next_heal_tick = t + time_between_heals
    end
end)
--[[mod:modify_talent("we_waywatcher", 2, 1, {
	description = "kerillian_waywatcher_movement_speed_on_special_kill_desc",
	name = "kerillian_waywatcher_movement_speed_on_special_kill",
	num_ranks = 1,
	icon = "kerillian_waywatcher_movement_speed_on_special_kill",
	description_values = {
		{
			value_type = "baked_percent",
			value = 1.15
		},
		{
			value = 10
		}
	},
	buffs = {
		"kerillian_waywatcher_movement_speed_on_special_kill"
	}
}) ]]

mod:modify_talent("we_waywatcher", 2, 3, {
    description_values = {
        {
            value_type = "baked_percent",
            value = 1.20
        },
        {
            value = 10
        }
    }
})
mod:modify_talent_buff_template("wood_elf", "kerillian_waywatcher_attack_speed_on_ranged_headshot_buff", {
    duration = 10,
	multiplier = 0.20
})
--[[ mod:modify_talent("we_waywatcher", 5, 1, {
	description = "kerillian_waywatcher_extra_arrow_melee_kill_desc",
	name = "kerillian_waywatcher_extra_arrow_melee_kill",
	num_ranks = 1,
	icon = "kerillian_waywatcher_extra_arrow_melee_kill",
	description_values = {
		{
			value = 10
		}
	},
	buffs = {
		"kerillian_waywatcher_extra_arrow_melee_kill"
	}
}) ]]
mod:add_text("kerillian_waywatcher_passive_cooldown_restore_desc", "Amaranthe also restores 5.0%% ammunition every tick.")

--[[

	Handmaiden Talents

]]
-- Focused Spirit
-- Buffed to grant 30% power.
mod:add_proc_function("lr_maidenguard_reset_unharmed_buff", function (owner_unit, buff, params)
    local attacker_unit = params[1]
    local damage_amount = params[2]
    local damaged = true
    local side = Managers.state.side.side_by_unit[owner_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local shot_by_friendly = false
    local allies = (player_and_bot_units and #player_and_bot_units) or 0

    if damage_amount and damage_amount == 0 then
        damaged = false
    end

    for i = 1, allies, 1 do
        local ally_unit =  player_and_bot_units[i]
        if ally_unit == attacker_unit then
            shot_by_friendly = true
        end
    end

    if Unit.alive(owner_unit) and not shot_by_friendly and damaged then
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
        local buff_name = "kerillian_maidenguard_power_level_on_unharmed_cooldown"
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit
        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

        if is_server() then
            buff_extension:add_buff(buff_name, {
                attacker_unit = owner_unit
            })
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end

        return true
    end
end)
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_power_level_on_unharmed", {
    multiplier = 0.30,
    buff_func = "lr_maidenguard_reset_unharmed_buff",
	stat_buff = "power_level_melee",
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_power_level_on_unharmed_cooldown", {
    duration = 4
})
mod:modify_talent("we_maidenguard", 2, 1, {
    description = "elf_hm_hitless_desc",
    description_values = {},
})
mod:add_text("elf_hm_hitless_desc", "After not taking damage for 4 seconds, increases Kerillian's melee power by 30.0%. Reset upon taking damage, friendly fire will not reset the buff.")


-- Oak Stance
-- Also grants 30% crit power.
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_crit_chance", {
	bonus = 0.1
})
mod:add_talent_buff_template("wood_elf", "handmaiden_crit_power", {
	stat_buff = "critical_strike_effectiveness",
	multiplier = 0.3,
	max_stacks = 1
})
mod:modify_talent("we_maidenguard", 2, 2, {
    buffs = {
        "handmaiden_crit_power",
		"kerillian_maidenguard_crit_chance"
    },
    description = "elf_hm_increased_crit_chance_crit_power_desc",
    description_values = {},
})
mod:add_text("elf_hm_increased_crit_chance_crit_power_desc", "Increases critical strike chance by 10.0% and critical strike damage by 30.0%.")


-- Asrai Alacrity
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_push", {
    amount_to_add = 3,
    max_sub_buff_stacks = 3,
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block", {
    amount_to_add = 3,
    max_sub_buff_stacks = 3,
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_dummy_buff", {
    max_stacks = 3
})
mod:add_text("kerillian_maidenguard_speed_on_block_desc", "Blocking an attack or pushing an enemy grants the next three strikes 30%% attack speed and 10%% power.")


-- Dance of Blades
-- Now grants ~~20%~~15% damage lasting for 3.5 seconds.
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_power_on_dodge", {
	duration = 3.5,
	multiplier = 0.15
})
mod:modify_talent("we_maidenguard", 4, 2, {
    description = "elf_hm_power_or_better_dodge_desc",
    description_values = {},
})
mod:add_text("elf_hm_power_or_better_dodge_desc", "Dodging while blocking increases dodge range by 20%. Dodging while not blocking increases Kerillian's power by 15% for 3.5 seconds.")


-- Heart of Oak
-- Now grants 20% extra max health.
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_max_health", {
	multiplier = 0.2
})
mod:modify_talent("we_maidenguard", 5, 1, {
    description = "elf_hm_increased_max_health_desc",
    description_values = {},
})
mod:add_text("elf_hm_increased_max_health_desc", "Increases max health by 20.0%.")


-- Quiver of Plenty
-- Now grants 70% increased ammo.
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_max_ammo", {
	multiplier = 0.7
})
mod:modify_talent("we_maidenguard", 5, 3, {
    description = "elf_hm_increased_max_ammo_desc",
    description_values = {},
})
mod:add_text("elf_hm_increased_max_ammo_desc", "Increases ammunition amount by 70.0%.")

--[[

	Shade

]]
-- Cruelty
-- Now gives 80% crit power and 5% crit chance
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_increased_critical_strike_damage", {
	multiplier = 0.8
})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_increased_critical_strike_damage_chance_tb", {
	stat_buff = "critical_strike_chance",
	bonus = 0.05
})
mod:modify_talent("we_shade", 2, 1, {
	description = "kerillian_shade_increased_critical_strike_damage_desc",
	description_values = {},
	buffs = {
		"kerillian_shade_increased_critical_strike_damage",
		"kerillian_shade_increased_critical_strike_damage_chance_tb",
	},
})
mod:add_text("kerillian_shade_increased_critical_strike_damage_desc", "Increases critical strike damage bonus by 80.0% and critical strike chance by 5.0%.")

-- Bloodfletcher
-- Now gives 5% Ammo on backstab
mod:add_talent_buff_template("wood_elf", "kerillian_shade_backstabs_replenishes_ammunition_tb", {
	buff_func = "ammo_fraction_gain_on_backstab_tb",
	event = "on_backstab",
	ammo_bonus_fraction = 0.05,
})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_backstabs_replenishes_ammunition_cooldown_tb", {
	icon = "kerillian_shade_backstabs_replenishes_ammunition",
	duration = 2,
})
ProcFunctions.ammo_fraction_gain_on_backstab_tb = function (owner_unit, buff, params)
    local player = Managers.player:owner(owner_unit)

    if player and player.remote then
        return
    end

	local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

	if buff_extension and not buff_extension:has_buff_type("kerillian_shade_backstabs_replenishes_ammunition_cooldown_tb") then

		if Unit.alive(owner_unit) then
			local buff_template = buff.template
			local weapon_slot = "slot_ranged"
			local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
			local slot_data = inventory_extension:get_slot_data(weapon_slot)
			local right_unit_1p = slot_data.right_unit_1p
			local left_unit_1p = slot_data.left_unit_1p
			local ammo_extension = GearUtils.get_ammo_extension(right_unit_1p, left_unit_1p)
			local ammo_bonus_fraction = buff_template.ammo_bonus_fraction

			if ammo_extension then
				local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)
				ammo_extension:add_ammo_to_reserve(ammo_amount)
			end
		end

		buff_extension:add_buff("kerillian_shade_backstabs_replenishes_ammunition_cooldown_tb")
	end
end
mod:modify_talent("we_shade", 4, 3, {
    description = "kerillian_shade_backstabs_replenishes_ammunition_tb_desc",
    description_values = {},
	buffs = {
		"kerillian_shade_backstabs_replenishes_ammunition_tb",
	},
})
mod:add_text("kerillian_shade_backstabs_replenishes_ammunition_tb_desc", "Backstabs return 5% of maximum ammunition. 2 second cooldown.")

-- Shimmer Strike
-- protects from proccing multiple times per swing
mod:add_talent_buff_template("wood_elf", "shimmer_abuser", {
	duration = 0.1,
	max_stacks = 1
})
-- removes a shimmer charge when you kill an elite/special
mod:add_talent_buff_template("wood_elf", "shimmer_handler", {
	buff_func = "shimmer_control",
	buff_to_remove = "shimmer_charges",
	event = "on_kill_elite_special",
	max_stacks = 1
})
mod:add_talent_buff_template("wood_elf", "shimmer_activator", {
	buff_func = "add_buff_reff_buff_stack",
	buff_to_add = "shimmer_charges",
	event = "on_ability_activated",
	max_stacks = 1,
	amount_to_add = 4,                                                -- gives 4 shimmer uses when you ult
	reference_buff = "shimmer_handler"
})
-- controls how many shimmer uses you have left
mod:add_talent_buff_template("wood_elf", "shimmer_charges", {
	buff_func = "shade_activated_ability_on_hit",
	max_stacks = 4,                                              -- maximum shimmer uses at once
	icon = "kerillian_shade_passive_stealth_on_backstab_kill"
})
mod:add_talent_buff_template("wood_elf", "kerillian_shade_ult_invis_combo_window", {
	buff_func = "shade_combo_stealth_extend_on_kill",
	duration = 0.3,
	refresh_durations = true,
	event = "on_kill_elite_special",
	extend_time = 1,                                           
	max_stacks = 1,
	icon = "kerillian_shade_passive_stealth_on_backstab_kill",
	remove_buff_func = "kerillian_shade_missed_combo_window"
})
mod:add_proc_function("shade_combo_stealth_on_hit", function (owner_unit, buff, params)
	if ALIVE[owner_unit] then
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		
		if not buff_extension:has_buff_type("kerillian_shade_ult_invis_combo_blocker") then
			if buff_extension:num_buff_stacks("shimmer_charges") > 0 then                    -- only gives shimmer buff if you have charges
				buff_extension:add_buff("kerillian_shade_ult_invis_combo_window")
			end
			if buff_extension:num_buff_stacks("shimmer_charges") <= 0 then                   -- always removes invis if you have no charges and hit an enemy
				buff_extension:remove_buff(buff.id)
			end
		end
	end
end)
mod:add_proc_function("shimmer_control", function (owner_unit, buff, params)
	if ALIVE[owner_unit] then
		local buff_template = buff.template
		local buff_name = buff_template.buff_to_remove
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		local buffs = buff_extension:get_stacking_buff(buff_name)
		
		if buffs then
			local num_stacks = #buffs
			
			if not buff_extension:has_buff_type("shimmer_abuser") then
				if num_stacks > 0 then
					local buff_id = buffs[num_stacks].id

					buff_extension:remove_buff(buff_id)
					buff_extension:add_buff("shimmer_abuser")
				end
			end
		end
	end
end)
mod:modify_talent("we_shade", 6, 1, {
	description = "kerillian_shade_activated_stealth_combo_desc_tb",
	description_values = {},
	buffs = {
		"shimmer_activator",             -- adds necessary buffs to shimmer talent to handle having capped uses
		"shimmer_handler"
	}
})
mod:add_text("kerillian_shade_activated_stealth_combo_desc_tb", "Leaving Infiltrate grants stealth for 3 seconds. Killing an Elite or Special extends this duration by 1 second up to a maximum of 4 times.")



--[[

	Sister of the Thorn Talents

]]

-- longer duration for radiant inheritance
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_team_buff_aura", {
	duration = 20
})
mod:modify_talent("we_thornsister", 4, 3, {
    description = "sister_inheritance_desc",
    description_values = {},
})
mod:add_text("sister_inheritance_desc", "Consuming Radiance grants Kerillian and nearby allies 15% power and 5% critical strike chance for 20 seconds.")

-- shorter cd for burst ult
mod:modify_talent("we_thornsister", 6, 3, {
    buffs = {
        "tb_cd_thorn"
    }
})
mod:add_talent_buff_template("wood_elf", "tb_cd_thorn", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3,
	max_stacks = 1
})
mod:add_text("kerillian_thorn_sister_debuff_wall_desc_2", "Thornwake instead causes roots to burst from the ground, staggering enemies and applying Blackvenom to them. Reduces cooldown by 30%%.")


--[[

░██████╗░█████╗░██╗░░░░░████████╗███████╗██████╗░██╗░░░██╗██████╗░███████╗
██╔════╝██╔══██╗██║░░░░░╚══██╔══╝╚════██║██╔══██╗╚██╗░██╔╝██╔══██╗██╔════╝
╚█████╗░███████║██║░░░░░░░░██║░░░░░███╔═╝██████╔╝░╚████╔╝░██████╔╝█████╗░░
░╚═══██╗██╔══██║██║░░░░░░░░██║░░░██╔══╝░░██╔═══╝░░░╚██╔╝░░██╔══██╗██╔══╝░░
██████╔╝██║░░██║███████╗░░░██║░░░███████╗██║░░░░░░░░██║░░░██║░░██║███████╗
╚═════╝░╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚══════╝╚═╝░░░░░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝

]]
--[[

	Bounty Hunter Talents

]]
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_railgun_delayed_add", {
    max_stacks = 1,
    multiplier = 0.8,
})
mod:add_text("victor_bountyhunter_activated_ability_railgun_desc_2", "Modifies Victor's sidearm to fire two powerful bullets in a straight line. Scoring a headshot with this attack will reduce the cooldown of Locked and Loaded by 80%%. This can only happen once")

--[[ mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_increased_melee_damage_on_no_ammo_add", {
    event = "on_hit"
})

mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_attack_speed_on_no_ammo_buff", {
    multiplier = 0.15,
    duration = 10
})
mod:add_text("victor_bountyhunter_power_burst_on_no_ammo_desc", "Ranged critical hits give 15%% ranged power and 15%% attack speed for 10 seconds.")
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_power_on_no_ammo_buff", {
    multiplier = 0.15,
    stat_buff = "power_level_ranged",
    duration = 10
})
MeleeBuffTypes = {
	MELEE_1H = true,
	MELEE_2H = true
}
mod:add_proc_function("add_buff_on_out_of_ammo", function (owner_unit, buff, params)
    if Unit.alive(owner_unit) then
        local buff_type = params[5]
        local is_critical = params[6]

        if is_critical and not MeleeBuffTypes[buff_type] then

            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
            local buff_template = buff.template
            local buffs = buff_template.buffs_to_add

            for i = 1, #buffs do
                local buff_name = buffs[i]
                local network_manager = Managers.state.network
                local network_transmit = network_manager.network_transmit
                local unit_object_id = network_manager:unit_game_object_id(owner_unit)
                local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

                if is_server() then
                    buff_extension:add_buff(buff_name, {
                        attacker_unit = owner_unit
                    })
                    network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
                else
                    network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
                end
            end
        end
    end
end) ]]


mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_activate_passive_on_melee_kill", {
	activation_buff = "victor_bountyhunter_blessed_melee_damage_buff",
	buff_to_add = "victor_bountyhunter_blessed_melee_attack_speed_buff",
	update_func = "activate_buff_on_other_buff",
})

mod:add_talent_buff_template("witch_hunter", "victor_bountyhunter_blessed_melee_attack_speed_buff", {
	stat_buff = "attack_speed",
	multiplier = 0.15,
	max_stacks = 1,
})

mod:add_text("victor_bountyhunter_weapon_swap_buff_desc", "Melee strikes make up to the next 6 ranged shots deal 15%% more damage. Ranged hits make up to the next 6 melee strikes deal 15%% more damage and grants 15%% attack speed for the next 6 strikes.")

mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_stacking_damage_reduction_on_elite_or_special_kill_buff", {
	max_stacks = 20
})
mod:modify_talent("wh_bountyhunter", 5, 3, {
    description_values = {
		{
			value_type = "percent",
			value = -0.01
		},
		{
			value = 20
		}
	},
})

-- Indisctiminate blast cdr upped to 60%
mod:add_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun_cdr", {
    multiplier = -0.6, -- -0.25
    stat_buff = "activated_cooldown",
})
mod:add_text("victor_bountyhunter_activated_ability_blast_shotgun_desc", " Modifies Victor's sidearm to fire two blasts of shield-penetrating pellets in a devastating cone. Reduces cooldown of Locked and Loaded by 60%%.")
mod:modify_talent("wh_bountyhunter", 6, 3, {
    buffs = {
        "victor_bountyhunter_activated_ability_blast_shotgun_cdr",
    },
})
PassiveAbilitySettings.wh_2.perks = {
	{
		display_name = "career_passive_name_wh_2b",
		description = "career_passive_desc_wh_2b_2"
	},
	{
		display_name = "career_passive_name_wh_2c",
		description = "career_passive_desc_wh_2c_2"
	},
	{
		display_name = "rebaltourn_career_passive_name_wh_2d",
		description = "rebaltourn_career_passive_desc_wh_2d_2"
	}
}
mod:add_text("rebaltourn_career_passive_name_wh_2d", "Blessed Kill")
mod:add_text("rebaltourn_career_passive_desc_wh_2d_2", "Melee kills reset the cooldown of Blessed Shots.")

--[[

	Zealot

]]

-- Smite
-- Added in random crits.
Talents.witch_hunter[4].perks = nil
mod:modify_talent("wh_zealot", 2, 2, {
    description = "zealot_crit_smite_desc",
    description_values = {},
})
mod:add_text("zealot_crit_smite_desc", "Every 5 hits grant a guaranteed critical strike. Critical strikes can still occur randomly.")

-- Unbending Purpose
-- Now grants 20% melee power.
mod:modify_talent_buff_template("witch_hunter", "victor_zealot_power", {
	stat_buff = "power_level_melee",
	multiplier = 0.2
})
mod:modify_talent("wh_zealot", 2, 3, {
    description = "zealot_unbending_purpose_desc",
    description_values = {},
})
mod:add_text("zealot_unbending_purpose_desc", "Increases melee power by 20.0%.")


--[[

	Warrior Priest Talents

]]
mod:modify_talent_buff_template("witch_hunter", "victor_priest_5_2", {
	buff_to_add = "victor_priest_5_2_speed_buff",
})

mod:add_talent_buff_template("witch_hunter", "victor_priest_5_2_speed_buff", {
	multiplier = 1.1,
	apply_buff_func = "apply_movement_buff",
	max_stacks = 1,
	remove_buff_func = "remove_movement_buff",
	path_to_movement_setting_to_modify = {
		"move_speed",
	},
})

-- reduce long bubble to 7 seconds (Unyielding Blessing)
CareerConstants.wh_priest.talent_6_1_improved_ability_duration = 7 --10 --this should already change the description as well
mod:add_text("victor_priest_6_1_desc_new", "Shield of Faith now lasts 7 seconds. The shielded hero's attacks cause the shield to pulse, staggering nearby enemies.")

mod:add_text("career_active_desc_wh_priest", "Saltzpyre imbues himself or an ally with a shield, rendering them immune to damage for 5 seconds. Upon expiring, the shield explodes, inflicting damage on nearby enemies. Hold to target allies.") -- just because FS formatting is awful
mod:add_text("victor_priest_5_2_desc", "Bless the party with 10%% increased movement speed. Fly you fools.")
mod:add_text("victor_priest_5_2", "Prayer of Flight")
mod:add_text("victor_priest_6_2_desc", "Shield of Faith always affects Victor as well. Shield of Faith now lasts 3 seconds.")

local spell_params = {}
local spell_params_improved = {
	external_optional_duration = CareerConstants.wh_priest.talent_6_1_improved_ability_duration,
}
local spell_params_double= {
	external_optional_duration = 3
}
local spell_buffs = {
	"victor_priest_activated_ability_invincibility",
	"victor_priest_activated_ability_nuke",
}

mod:hook_origin(ActionCareerWHPriestUtility, "_add_buffs_to_target", function (target_unit, warrior_priest_unit)
	local spell_buffs = spell_buffs
	local params = spell_params
	local talent_extension = ScriptUnit.extension(warrior_priest_unit, "talent_system")

	if talent_extension:has_talent("victor_priest_6_1") then
		params = spell_params_improved
	end
	if talent_extension:has_talent("victor_priest_6_2") then
		params = spell_params_double
	end

	params.attacker_unit = warrior_priest_unit

	if ALIVE[target_unit] then
		local buff_system = Managers.state.entity:system("buff_system")

		for i = 1, #spell_buffs do
			local buff_name = spell_buffs[i]

			buff_system:add_buff_synced(target_unit, buff_name, BuffSyncType.All, params)
		end
	end
end)


--[[

░██████╗██╗███████╗███╗░░██╗███╗░░██╗░█████╗░
██╔════╝██║██╔════╝████╗░██║████╗░██║██╔══██╗
╚█████╗░██║█████╗░░██╔██╗██║██╔██╗██║███████║
░╚═══██╗██║██╔══╝░░██║╚████║██║╚████║██╔══██║
██████╔╝██║███████╗██║░╚███║██║░╚███║██║░░██║
╚═════╝░╚═╝╚══════╝╚═╝░░╚══╝╚═╝░░╚══╝╚═╝░░╚═╝

]]

--[[

	Battle Wizard Talents

]]
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_increased_burn_damage", {
    multiplier = 1.5, -- 1,
})
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_reduced_non_burn_damage", {
    multiplier = -0.3, -- -0.15,
})
mod:add_text("sienna_adept_increased_burn_damage_reduced_non_burn_damage_desc", "Burning damage over time is increased by 150.0%%. All non-burn damage is reduced by 30.0%%.")

InfiniteBurnDotLookup = InfiniteBurnDotLookup or {}
local buff_perk_names = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
local buff_templates = BuffTemplates

for template_name, template in pairs(buff_templates) do
	if not string.find(template_name, "_infinite") then
		local new_name = template_name .. "_infinite"
		local new_buff_template = table.clone(template)

		for _, sub_buff in ipairs(new_buff_template.buffs) do
			local perks = sub_buff.perks

			if perks and table.find(perks, buff_perk_names.burning) then
				sub_buff.name = "infinite_burning_dot"
				sub_buff.duration = nil
				sub_buff.on_max_stacks_overflow_func = "reapply_infinite_burn"
				sub_buff.max_stacks = 1

				InfiniteBurnDotLookup[template_name] = new_name
				buff_templates[new_name] = new_buff_template

				break
			end
		end
	end
end

mod:modify_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05, -- -0.1,
	max_stacks = 4
})
mod:modify_talent("bw_adept", 5, 1, {
    description = "rebaltourn_sienna_adept_damage_reduction_on_ignited_enemy_desc",
    description_values = {
        {
            value_type = "percent",
            value = -0.05 --BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.multiplier
        }
    },
})
mod:add_text("rebaltourn_sienna_adept_damage_reduction_on_ignited_enemy_desc", "Igniting an enemy reduces damage taken by 5%% for 5 seconds. Stacks up to 4 times.")

mod:modify_talent_buff_template("bright_wizard", "sienna_adept_cooldown_reduction_on_burning_enemy_killed", {
    cooldown_reduction = 0.02 --0.03
})
mod:modify_talent("bw_adept", 5, 2, {
    description = "rebaltourn_sienna_adept_cooldown_reduction_on_burning_enemy_killed_desc",
    description_values = {
        {
            value_type = "percent",
            value = 0.02 --BuffTemplates.sienna_adept_cooldown_reduction_on_burning_enemy_killed.cooldown_reduction
        }
    },
})
mod:add_text("rebaltourn_sienna_adept_cooldown_reduction_on_burning_enemy_killed_desc", "Killing a burning enemy reduces the cooldown of Fire Walk by 2%%. 0.5 second cooldown.")

mod:modify_talent("bw_adept", 6, 2, {
    description = "rebaltourn_sienna_adept_activated_ability_explosion_desc",
	buffs = {
        "sienna_adept_activated_ability_explosion_buff"
    },
})
mod:add_text("rebaltourn_sienna_adept_activated_ability_explosion_desc", "Fire Walk explosion radius and burn damage increased. No longer leaves a burning trail. Cooldown of Fire Walk reduced by 20%.")

mod:add_talent_buff_template("bright_wizard", "sienna_adept_activated_ability_explosion_buff", {
    stat_buff = "activated_cooldown",
	multiplier = -0.2
})

--[[

	Pyromancer Talents

]]
mod:modify_talent_buff_template("bright_wizard", "sienna_scholar_increased_attack_speed", {
	multiplier = 0.1
})
mod:modify_talent("bw_scholar", 2, 2, {
    description = "pyro_martial_study_desc",
    description_values = {},
})
mod:add_text("pyro_martial_study_desc", "Increases attack speed by 10%.")

-- Spirit Casting
mod:add_talent_buff_template("bright_wizard", "gs_sienna_scholar_crit_chance_above_health_threshold", {
	buff_to_add = "sienna_scholar_crit_chance_above_health_threshold_buff",
	update_func = "gs_activate_buff_stacks_based_on_certain_health_percentage",
	update_frequency = 0.2,
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_buff", {
	max_stacks = 2, -- 3
	icon = "sienna_scholar_crit_chance_above_health_threshold",
	stat_buff = "critical_strike_chance",
	bonus = 0.05
})

mod:modify_talent("bw_scholar", 2, 3, {
    buffs = {
        "gs_sienna_scholar_crit_chance_above_health_threshold"
    },
    description = "rebaltourn_sienna_scholar_crit_chance_above_health_threshold_desc",
    description_values = {},
})
mod:add_text("rebaltourn_sienna_scholar_crit_chance_above_health_threshold_desc", "Critical strike chance is increased by 5.0% while above 65.0% health and increased by 10.0% while above 80.0% health.")

mod:add_buff_function("gs_activate_scaling_buff_based_on_health_percentage", function(unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	if not Unit.alive(unit) then
        return
    end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local max_health = health_extension:get_max_health()
	local current_health = health_extension:current_health()
	local health_percentage = current_health / max_health
	local stacks_to_add = 0
	local max_buff_value = template.max_buff_value

	stacks_to_add = health_percentage * max_buff_value

	local buff_to_add = template.buff_to_add
	local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	if num_buff_stacks < stacks_to_add then
		local difference = stacks_to_add - num_buff_stacks

		for i = 1, difference, 1 do
			local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
			local stack_ids = buff.stack_ids
			stack_ids[#stack_ids + 1] = buff_id
		end
	elseif stacks_to_add < num_buff_stacks then
		local difference = num_buff_stacks - stacks_to_add

		for i = 1, difference, 1 do
			local stack_ids = buff.stack_ids
			local buff_id = table.remove(stack_ids, 1)

			buff_system:remove_server_controlled_buff(unit, buff_id)
		end
	end
end)

mod:add_buff_function("gs_activate_buff_stacks_based_on_certain_health_percentage", function(unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local max_health = health_extension:get_max_health()
	local current_health = health_extension:current_health()
	local health_percentage = current_health / max_health
	local stacks_to_add = 0
	--if health_percentage >= 0.5 and health_percentage < 0.65 then
		--stacks_to_add = 1
	if health_percentage >= 0.65 and health_percentage < 0.8 then
		stacks_to_add = 1 -- 2
	elseif health_percentage >= 0.8 then
		stacks_to_add = 2 -- 3
	end
	local buff_to_add = template.buff_to_add
	local num_chunks = stacks_to_add
	local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	if num_buff_stacks < num_chunks then
		local difference = num_chunks - num_buff_stacks

		for i = 1, difference, 1 do
			local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
			local stack_ids = buff.stack_ids
			stack_ids[#stack_ids + 1] = buff_id
		end
	elseif num_chunks < num_buff_stacks then
		local difference = num_buff_stacks - num_chunks

		for i = 1, difference, 1 do
			local stack_ids = buff.stack_ids
			local buff_id = table.remove(stack_ids, 1)

			buff_system:remove_server_controlled_buff(unit, buff_id)
		end
	end
end)


--[[

	Unchained Talents

]]
-- Prevent interaction between Unchained Abandon and WP bubble
--[[
mod:modify_talent_buff_template("bright_wizard", "sienna_unchained_health_to_ult", {
	update_func = "activate_buff_stacks_based_on_overcharge_chunks_unchained_tb",
})
BuffFunctionTemplates.functions.activate_buff_stacks_based_on_overcharge_chunks_unchained_tb = function (unit, buff, params)
    if is_local(unit) then

        local buff_extension = ScriptUnit.extension(unit, "buff_system")
        local has_buff = buff_extension:has_buff_type("victor_priest_activated_ability_invincibility")

        if has_buff then
            return
        end

        local overcharge_extension = ScriptUnit.extension(unit, "overcharge_system")
        local buff_extension = ScriptUnit.extension(unit, "buff_system")
        local overcharge, threshold, max_overcharge = overcharge_extension:current_overcharge_status()
        local template = buff.template
        local chunk_size = template.chunk_size
        local buff_to_add = template.buff_to_add
        local max_stacks = template.max_stacks

        if not buff.stack_ids then
            buff.stack_ids = {}
        end

        local num_chunks = math.min(math.floor(overcharge / chunk_size), max_stacks)
        local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

        if num_buff_stacks < num_chunks then
            local difference = num_chunks - num_buff_stacks

            for i = 1, difference do
                local buff_id = buff_extension:add_buff(buff_to_add)
                local stack_ids = buff.stack_ids

                stack_ids[#stack_ids + 1] = buff_id
            end
        elseif num_chunks < num_buff_stacks then
            local difference = num_buff_stacks - num_chunks

            for i = 1, difference do
                local stack_ids = buff.stack_ids
                local buff_id = table.remove(stack_ids, 1)

                buff_extension:remove_buff(buff_id)
            end
        end
    end
end
]]


--[[

	Necromancer Talents

]]
mod:add_proc_function("necromancer_crit_burst", function (owner_unit, buff, params, world, param_order)
	local is_crit = params [param_order.is_critical_strike]
	if not is_crit then
		return
	end

	local is_first_hit = params [param_order.first_hit]
	if not is_first_hit then
		return
	end

	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local exploded_already = false
	if buff_extension then
		exploded_already = buff_extension:has_buff_type("no_proc_necro")
	end
	if exploded_already then
		return
	end

	local hit_unit = params [param_order.attacked_unit]
	local is_burning, applied_this_frame = Managers.state.status_effect:has_status(hit_unit, StatusEffectNames.burning_balefire)
	if not is_burning or applied_this_frame then
		return
	end

	local damage_dealt = params [param_order.damage_amount]
	if damage_dealt <= 0 then
		return
	end

	local template = buff.template
	local side = Managers.state.side.side_by_unit [owner_unit]
	local hit_pos = POSITION_LOOKUP [hit_unit]
	if not hit_pos then

		return
	end

	local unit_storage = Managers.state.unit_storage
	local hit_go_id = unit_storage:go_id(hit_unit)
	local node_id = 0
	if Unit.has_node(hit_unit, "j_spine") then
		node_id = Unit.node(hit_unit, "j_spine")
	end

	local network_manager = Managers.state.network
	network_manager.network_transmit:send_rpc_server("rpc_play_particle_effect", NetworkLookup.effects ["fx/necromancer_cursed_explosion_blood"], hit_go_id, node_id, Vector3.zero(), Quaternion.identity(), false)
	network_manager.network_transmit:send_rpc_server("rpc_play_particle_effect", NetworkLookup.effects ["fx/necromancer_cursed_explosion_blue"], hit_go_id, node_id, Vector3(0.5, 0, 0), Quaternion.identity(), false)

	local audio_system = Managers.state.entity:system("audio_system")
	audio_system:play_audio_unit_event("Play_career_necro_ability_cursed_blood", hit_unit, "j_spine")

	local broadphase_categories = side.enemy_broadphase_categories
	local nearby_units = FrameTable.alloc_table()
	local num_nearby = AiUtils.broadphase_query(hit_pos, template.radius, nearby_units, broadphase_categories)

	if num_nearby == 0 then
		return
	end

	local t = Managers.time:time("game")
	local propagated_damage = damage_dealt * template.propagation_multiplier
	local career_extension = ScriptUnit.extension(owner_unit, "career_system")
	local power_level = career_extension:get_career_power_level()
	for i = 1, num_nearby do
		local target_unit = nearby_units [i]
		if target_unit ~= hit_unit then
			local damage_direction = Vector3.normalize(POSITION_LOOKUP [target_unit] - hit_pos)
			DamageUtils.add_damage_network(target_unit, owner_unit, propagated_damage, "torso", "buff", nil, damage_direction, "buff", nil, owner_unit, nil, nil, false, nil, nil, nil, nil, true)
			DamageUtils.stagger_ai(t, DamageProfileTemplates.necromancer_crit_burst_stagger, i + 1, power_level, target_unit, owner_unit, "torso", damage_direction, nil, nil, false, "buff", owner_unit)
		end
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local buff_to_add = "no_proc_necro"
	buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
end)

mod:add_talent_buff_template("bright_wizard", "no_proc_necro", {
	duration = 0.3
})

mod:modify_talent_buff_template("bright_wizard", "sienna_necromancer_4_1_cursed_blood", {
	propagation_multiplier = 0.10
})
DamageProfileTemplates.sienna_necromancer_blood_explosion.default_target.power_distribution.impact = 0
DamageProfileTemplates.sienna_necromancer_ability_stagger.default_target.power_distribution.impact = 0
DamageProfileTemplates.trapped_soul.default_target.power_distribution_near.impact = 0
DamageProfileTemplates.trapped_soul.default_target.power_distribution_far.impact = 0
DamageProfileTemplates.necromancer_crit_burst_stagger.default_target.power_distribution.impact = 0


mod:modify_talent_buff_template("bright_wizard", "sienna_necromancer_2_3", {
	multiplier = 0
})
mod:add_text("sienna_necromancer_2_3_desc", "Critical attacks have unlimited cleave.")
mod:add_text("career_passive_desc_bw_necromancer_c", "Killing an enemy grants 2%% crit chance for 5 seconds. Max stacks 5.")

--[[

███████╗██╗██╗░░██╗███████╗░██████╗
██╔════╝██║╚██╗██╔╝██╔════╝██╔════╝
█████╗░░██║░╚███╔╝░█████╗░░╚█████╗░
██╔══╝░░██║░██╔██╗░██╔══╝░░░╚═══██╗
██║░░░░░██║██╔╝╚██╗███████╗██████╔╝
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░

]]

-- Fix clients getting too much ult recharge on explosions
mod:add_proc_function("reduce_activated_ability_cooldown", function (owner_unit, buff, params)
	if Unit.alive(owner_unit) then
		local attack_type = params[2]
		local target_number = params[4]
		local career_extension = ScriptUnit.extension(owner_unit, "career_system")

		if not attack_type or attack_type == "heavy_attack" or attack_type == "light_attack" then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		elseif attack_type == "aoe" then
            return
		elseif target_number and target_number == 1 then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		end
	end
end)

-- Fix Stacking bug for lingering flames with Firebombs
--[[ -- In theory fixed by FS last update
mod:hook_origin(StackingBuffFunctions, "fire_grenade_dot_add", function (unit, sub_buff_template, current_num_stacks, buff_extension, new_buff_params)
	local should_add_buff = current_num_stacks < 1      -- should_add_buff = true    idk why changing this works
	local breed = AiUtils.unit_breed(unit)
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	
	if breed and breed.is_player then
	local mechanism_name = Managers.mechanism:current_mechanism_name()
	
	if mechanism_name == "versus" then
	should_add_buff = current_num_stacks < (sub_buff_template.max_player_stacks_in_versus or math.huge)
	end
	end
	
	return should_add_buff
end)]]