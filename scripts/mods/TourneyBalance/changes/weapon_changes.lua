local mod = get_mod("TourneyBalance")

--Bounty Shotgun ability FF reduction
DamageProfileTemplates.shot_shotgun_ability.critical_strike.attack_armor_power_modifer = { 1, 0.1, 0.2, 0, 1, 0.025 }
DamageProfileTemplates.shot_shotgun_ability.critical_strike.impact_armor_power_modifer = { 1, 0.5, 200, 0, 1, 0.05 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.attack = { 1, 0.1, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.impact = { 1, 0.5, 100, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.attack = { 1, 0, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.impact = { 1, 0.5, 200, 0, 1, 0 }

--Piercing Shot Crit FF fix
DamageProfileTemplates.arrow_sniper_ability_piercing.critical_strike.attack_armor_power_modifer = { 1, 1, 1, 0.25, 1, 0.25 }
DamageProfileTemplates.arrow_sniper_ability_piercing.critical_strike.impact_armor_power_modifer = { 1, 1, 0, 0, 1, 1 }

-- Bloodrazor Thicket 
DamageProfileTemplates.thorn_wall_explosion_improved_damage.armor_modifier.attack = {
	0.5,
	0.1,
	2,
	0.75,
	0.3,
	0.25
}
BuffTemplates.thorn_sister_wall_bleed.buffs[1].duration = 3

-- Moonbow
--Weapons.we_deus_01_template_1.actions.action_one.default.drain_amount = 7
--Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.drain_amount = 9
--Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.drain_amount = 11
--DamageProfileTemplates.we_deus_01_small_explosion.armor_modifier.attack = {
--	0.5,
--	0.25,
--	1.5,
--	1,
--	0.75,
--	0
--}
--DamageProfileTemplates.we_deus_01_small_explosion_glance.armor_modifier.attack = {
--	0.5,
--	0.25,
--	1.5,
--	1,
--	0.75,
--	0
--}
--DamageProfileTemplates.we_deus_01_large_explosion.armor_modifier.attack = {
--	0.5,
--	0.25,
--	1.5,
--	1,
--	0.75,
--	0
--}
--DamageProfileTemplates.we_deus_01_large_explosion_glance.armor_modifier.attack = {
--	0.5,
--	0.25,
--	1.5,
--	1,
--	0.75,
--	0
--}
--DamageProfileTemplates.we_deus_01_dot.armor_modifier.attack = {
--	1,
--	0.35,
--	1.5,
--	1,
--	0.5,
--	0
--}
--DamageProfileTemplates.we_deus_01_dot.armor_modifier.attack = {
--	1,
--	0.35,
--	1.5,
--	1,
--	0.5,
--	0
--}
--DamageProfileTemplates.we_deus_01.armor_modifier.attack = {
--	1,
--	0.75,
--	1,
--	0.75,
--	0.75,
--	0.25
--}
--DamageProfileTemplates.we_deus_01.default_target.boost_curve_coefficient_headshot = 1.75
--EnergyData.we_waywatcher.depletion_cooldown = 7.5
--EnergyData.we_maidenguard.depletion_cooldown = 7.5
--EnergyData.we_shade.depletion_cooldown = 7.5
--EnergyData.we_thornsister.depletion_cooldown = 7.5


-- Trollhammer
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack = {
	1,
	0.5,
	3,
	1,
	0.25
}
Weapons.dr_deus_01_template_1.ammo_data.reload_time = 4
--Conservative doesnt proc if Trollhammer equiped
mod:add_proc_function("replenish_ammo_on_headshot_ranged", function (player, buff, params)
	local player_unit = player.player_unit
	local attack_type = params[2]
	local hit_zone_name = params[3]

	if Unit.alive(player_unit) and hit_zone_name == "head" and (attack_type == "instant_projectile" or attack_type == "projectile") then
		local ranged_buff_type = params[5]

		if ranged_buff_type and ranged_buff_type == "RANGED_ABILITY" then
			return
		end

		local weapon_slot = "slot_ranged"
		local ammo_amount = buff.bonus
		local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
		local slot_data = inventory_extension:get_slot_data(weapon_slot)
		local right_unit_1p = slot_data.right_unit_1p
		local left_unit_1p = slot_data.left_unit_1p
		local ammo_extension = GearUtils.get_ammo_extension(right_unit_1p, left_unit_1p)

		if slot_data then
			local item_data = slot_data.item_data
			local item_name = item_data.name
			if item_name == "dr_deus_01" then
				return
			end
		end

		if ammo_extension then
			ammo_extension:add_ammo_to_reserve(ammo_amount)
		end
	end
end)
--Removed Grenadier from proccing on Trollhammer
mod:hook(ActionGrenadeThrower, "client_owner_post_update", function(func, self, dt, t, world, can_damage)
	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
		self.state = "shooting"
	end

	if self.state == "shooting" then
		local owner_unit = self.owner_unit

		if not Managers.player:owner(self.owner_unit).bot_player then
			Managers.state.controller_features:add_effect("rumble", {
				rumble_effect = "crossbow_fire"
			})
		end

		local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
		local position, rotation = first_person_extension:get_projectile_start_position_rotation()
		local spread_extension = self.spread_extension
		local current_action = self.current_action

		if spread_extension then
			rotation = spread_extension:get_randomised_spread(rotation)

			spread_extension:set_shooting()
		end

		local angle = ActionUtils.pitch_from_rotation(rotation)
		local speed = current_action.speed
		local target_vector = Vector3.normalize(Vector3.flat(Quaternion.forward(rotation)))
		local lookup_data = current_action.lookup_data

		ActionUtils.spawn_player_projectile(owner_unit, position, rotation, 0, angle, target_vector, speed, self.item_name, lookup_data.item_template_name, lookup_data.action_name, lookup_data.sub_action_name, self._is_critical_strike, self.power_level)

		local fire_sound_event = self.current_action.fire_sound_event

		if fire_sound_event then
			first_person_extension:play_hud_sound_event(fire_sound_event)
		end

		if self.ammo_extension and not self.extra_buff_shot then
			local ammo_usage = current_action.ammo_usage
			self.ammo_extension:use_ammo(ammo_usage)
		end


		local add_spread = not self.extra_buff_shot

		if self:_update_extra_shots(self.owner_buff_extension, 1) then
			self.state = "waiting_to_shoot"
			self.time_to_shoot = t + 0.1
			self.extra_buff_shot = true
		else
			self.state = "shot"
		end

		first_person_extension:reset_aim_assist_multiplier()
	end

	if self.state == "shot" and self.active_reload_time then
		local owner_unit = self.owner_unit
		local input_extension = ScriptUnit.extension(owner_unit, "input_system")

		if self.active_reload_time < t then
			local ammo_extension = self.ammo_extension

			if (input_extension:get("weapon_reload") or input_extension:get_buffer("weapon_reload")) and ammo_extension:can_reload() then
				local status_extension = ScriptUnit.extension(self.owner_unit, "status_system")

				status_extension:set_zooming(false)

				local weapon_extension = ScriptUnit.extension(self.weapon_unit, "weapon_system")

				weapon_extension:stop_action("reload")
			end
		elseif input_extension:get("weapon_reload") then
			input_extension:add_buffer("weapon_reload", 0)
		end
	end
end)

--Masterwork Pistol
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.impact_data.damage_profile = "shot_sniper_pistol_burst"
local shotgun_dropoff_ranges = {
	dropoff_start = 8,
	dropoff_end = 15
}
NewDamageProfileTemplates.shot_sniper_pistol_burst = {
	charge_value = "instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1.4,
			1,
			1,
			0.75,
			0.5
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier_near = {
		attack = {
			1,
			1,
			1,
			1,
			0.75,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			1,
			1,
			1,
			0.75,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0
		}
	},
	cleave_distribution = {
		attack = 0.3,
		impact = 0.3
	},
	default_target = {
		headshot_boost_boss = 0.5,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 1,
		attack_template = "shot_sniper",
		power_distribution_near = {
			attack = 1,
			impact = 0.5
		},
		power_distribution_far = {
			attack = 0.5,
			impact = 0.5
		},
		range_dropoff_settings = shotgun_dropoff_ranges
	}
}

--Duck foot
balanced_barrels =  { {	yaw = -1, pitch = 0, shot_count = 2 }, { yaw = -0.5, pitch = 0, shot_count = 2 },	{ yaw = 0, pitch = 0, shot_count = 4 }, { yaw = 0.5,  pitch = 0, shot_count = 2 }, { yaw = 1, pitch = 0, shot_count = 2 } }
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels = balanced_barrels
DamageProfileTemplates.shot_duckfoot.cleave_distribution.attack = 0.05
DamageProfileTemplates.shot_duckfoot.cleave_distribution.impact = 0.05

--Coruscation
Weapons.bw_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.6
Weapons.bw_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.5
Weapons.bw_deus_01_template_1.actions.action_one.default.total_time = 0.65
Weapons.bw_deus_01_template_1.actions.action_one.default.shot_count = 15
DamageProfileTemplates.staff_magma.default_target.power_distribution_near.attack = 0.1
DamageProfileTemplates.staff_magma.default_target.power_distribution_far.attack = 0.05
PlayerUnitStatusSettings.overcharge_values.magma_basic = 4
ExplosionTemplates.magma.aoe.duration = 3
ExplosionTemplates.magma.aoe.damage_interval = 1
PlayerUnitStatusSettings.overcharge_values.magma_charged_2 = 10
PlayerUnitStatusSettings.overcharge_values.magma_charged = 14
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod:add_buff_template("burning_magma_dot", {
        duration = 3,
        name = "burning_magma_dot",
        remove_buff_func = "remove_dot_damage",
        end_flow_event = "smoke",
        start_flow_event = "burn",
        reapply_start_flow_event = true,
        apply_buff_func = "start_dot_damage",
        death_flow_event = "burn_death",
        time_between_dot_damages = 1.5,
        refresh_durations = true,
        damage_type = "burninating",
        damage_profile = "burning_dot",
        update_func = "apply_dot_damage",
        reapply_buff_func = "reapply_dot_damage",
        max_stacks = 15,
        perk = buff_perks.burning
})

--Burning Head
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.attack = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.attack = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.attack_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.75
}
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.attack = 0.5
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.impact = 0.5

--Conflag
DamageProfileTemplates.geiser.targets[1].power_distribution.attack = 0.5
ExplosionTemplates.conflag.aoe.duration = 10
ExplosionTemplates.conflag.aoe.damage_interval = 2

--Melee
--Flaming Flail
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_left.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.heavy_attack.anim_time_scale = 1
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.impact = 0.375
DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.attack = 0.6
DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.impact = 0.25
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.attack = 0.35

--2h Sword
--bop
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.35
--Heavies
DamageProfileTemplates.heavy_slashing_linesman.targets[2].power_distribution.attack = 0.4
DamageProfileTemplates.heavy_slashing_linesman.targets[2].armor_modifier = { attack = { 1, 0.4, 2, 1, 1 }, impact = { 1, 0.5, 0.5, 1, 1} }
DamageProfileTemplates.heavy_slashing_linesman.targets[3].power_distribution.attack = 0.25
DamageProfileTemplates.heavy_slashing_linesman.targets[4].power_distribution.attack = 0.20
DamageProfileTemplates.heavy_slashing_linesman.default_target.power_distribution.attack = 0.14
--lights
DamageProfileTemplates.medium_slashing_linesman.targets[1].power_distribution.attack = 0.275
DamageProfileTemplates.medium_slashing_linesman.targets[2].power_distribution.attack = 0.2
DamageProfileTemplates.medium_slashing_linesman.targets[3].power_distribution.attack = 0.15
DamageProfileTemplates.medium_slashing_linesman.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman.targets[3].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman.default_target.power_distribution.attack = 0.1
DamageProfileTemplates.medium_slashing_linesman.cleave_distribution.impact = 0.4

--Mace and Sword
--lights 1,2
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT

--lights 3,4
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left.damage_profile = "light_slashing_linesman_finesse"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right_diagonal.damage_profile = "light_slashing_linesman_finesse"

--Heavy
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.hit_mass_count = nil
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.hit_mass_count = nil
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_right = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_right = "mace_sword_heavy"
--Bopp
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_left = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_right = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.anim_time_scale = 1.15
NewDamageProfileTemplates.mace_sword_bopp = {
	stagger_duration_modifier = 1.5,
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	cleave_distribution = {
		attack = 0.2,
		impact = 0.2
	},
	armor_modifier = {
		attack = {
			1,
			0.5,
			2.5,
			1,
			0.9,
			0.5
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.075,
			impact = 0.075
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
}
NewDamageProfileTemplates.mace_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.5,
			1.5,
			1,
			0.75,
			0.5
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.6,
			0.5
		},
		impact_armor_power_modifer = {
			0.9,
			0.5,
			1,
			1,
			0.75
		}
	},
    charge_value = "heavy_attack",
    cleave_distribution = {
        attack = 0.15,
        impact = 0.3
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075,
            impact = 0.075
        }
    },
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.275,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					1.5,
					1,
					0.75,
					0.5
				},
				impact = {
					1,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			},

		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	melee_boost_override = 6
}



--1h sword
Weapons.one_handed_swords_template_1.dodge_count = 4
--light 1,2
DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].boost_curve_type = "ninja_curve"
DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].power_distribution.attack = 0.2
DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].power_distribution.attack = 0.15
DamageProfileTemplates.light_slashing_linesman_finesse.default_target.power_distribution.attack = 0.125
--light 3
DamageProfileTemplates.light_slashing_smiter_finesse.shield_break = true
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_last.range_mod = 1.4 --1.2

--Heavies
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].armor_modifier.attack = {	1, 0.75, 2, 1, 0.75 }  --{ 1, 0.5, 1, 1, 0.75 }
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].power_distribution.attack = 0.4 --0.3
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[2].power_distribution.attack = 0.2 --0.1
DamageProfileTemplates.medium_slashing_tank_1h_finesse.cleave_distribution = "cleave_distribution_tank_L"
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_left.range_mod = 1.4 --1.25

--1h hammer
Weapons.one_handed_hammer_template_1.dodge_count = 4
Weapons.one_handed_hammer_template_2.dodge_count = 4
Weapons.one_handed_hammer_priest_template.dodge_count = 4

--light 1, 2, bop (Also affects hammer and shield light 2, mace and sword light 3,4)
DamageProfileTemplates.light_blunt_tank.cleave_distribution.attack = 0.23
DamageProfileTemplates.light_blunt_tank_diag.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.light_blunt_tank_diag.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.light_blunt_tank_diag.targets[1].power_distribution.attack = 0.225 --0.175
DamageProfileTemplates.light_blunt_tank_diag.armor_modifier.attack = { 1, 0.35, 1, 1, 0.75, 0.25 } --{ 1, 0, 1, 1, 0 }
DamageProfileTemplates.light_blunt_tank_diag.critical_strike.attack_armor_power_modifer = {	1, 0.5, 1, 0.75, 0.35 } --{ 1, 0.5, 1, 1, 0.25 }

--light 3, 4  (Also affects hammer and shield bop and light 3, hammer and tome lights, dual hammers bop 2, (flaming) flail light 3,4 and sienna mace light 1,2)
--DamageProfileTemplates changes also affect 1h axe lights
DamageProfileTemplates.light_blunt_smiter.default_target.boost_curve_coefficient_headshot = 2 --1.5
DamageProfileTemplates.light_blunt_smiter.armor_modifier.attack = { 1.25, 0.65, 3, 1, 1.25, 0.6 } --{ 1.25, 0.65, 2.5, 1, 0.75, 0.6 }
DamageProfileTemplates.light_blunt_smiter.critical_strike.attack_armor_power_modifer = { 1.25, 0.75, 2.75, 1, 1 } --{ 1.25, 0.75, 2.75, 1, 1 }
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.anim_time_scale = 1.5 --1.35

--Heavies
DamageProfileTemplates.medium_blunt_smiter_1h.armor_modifier.attack = { 1, 0.8, 2.5, 0.75, 1 } -- { 1, 0.8, 1.75, 0.75, 0.8 }
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.range_mod = 1.2 --0

--Halberd
--light 1 (Also affects Glaive lights and bop and Great Axe bop)
DamageProfileTemplates.medium_slashing_axe_linesman.targets[2].power_distribution.attack = 0.225
DamageProfileTemplates.medium_slashing_axe_linesman.targets[3].power_distribution.attack = 0.15
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack =  0.4
DamageProfileTemplates.medium_slashing_axe_linesman.targets[1].armor_modifier.attack[1] = 1.25
--light 2
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile = "halberd_light_stab"
--Heavy 2 (Also affects Elf Spear heavy 1)
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].armor_modifier.attack[1] = 1.15
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].power_distribution.attack = 0.45
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[2].power_distribution.attack = 0.35
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[3].power_distribution.attack = 0.25
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[4].power_distribution.attack = 0.15
DamageProfileTemplates.heavy_slashing_linesman_polearm.default_target.power_distribution.attack = 0.10
--Heavy 1
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile = "halberd_heavy_stab"
--light 3 and push stab
DamageProfileTemplates.medium_slashing_smiter_2h.default_target.boost_curve_coefficient_headshot = 2.5
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].start_time = 0.5
NewDamageProfileTemplates.halberd_heavy_stab = {
    charge_value = "heavy_attack",
   	cleave_distribution_smiter_default = {
		attack = 0.075,
		impact = 0.075
	},
    critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.3,
			2,
			1,
			0.75
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75
		}
	},
	default_target = {
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "heavy_stab_smiter",
		power_distribution = {
			attack = 0.2,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 0.75,
			attack_template = "heavy_stab_smiter",
			armor_modifier = {
				attack = {
					1,
					0.8,
					2,
					1,
					0.75
				},
				impact = {
					1,
					0.65,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			}
		}
	},
	melee_boost_override = 2.5
}
NewDamageProfileTemplates.halberd_light_stab = {
    charge_value = "light_attack",
   	cleave_distribution_smiter_default = {
		attack = 0.075,
		impact = 0.075
	},
    critical_strike = {
		attack_armor_power_modifer = {
			1,
			1,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier = {
		attack = {
			1,
			1,
			2.25,
			1,
			0.75
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.75
		}
	},
	default_target = {
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 1,
		attack_template = "stab_smiter",
		power_distribution = {
			attack = 0.25,
			impact = 0.125
		}
	},
	melee_boost_override = 2.5
}

--Dual Axes
--Heavies
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack.anim_time_scale = 0.925  --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_2.anim_time_scale = 1.1 --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_3.additional_critical_strike_chance = 0.2 --0
--push
Weapons.dual_wield_axes_template_1.actions.action_one.push.damage_profile_inner = "light_push"
Weapons.dual_wield_axes_template_1.actions.action_one.push.fatigue_cost = "action_stun_push"