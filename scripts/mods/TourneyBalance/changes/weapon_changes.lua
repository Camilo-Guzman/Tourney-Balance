local mod = get_mod("TourneyBalance")

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
Weapons.we_deus_01_template_1.actions.action_one.default.drain_amount = 7
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.drain_amount = 9
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.drain_amount = 11
DamageProfileTemplates.we_deus_01_small_explosion.armor_modifier.attack = {
	0.5,
	0.25,
	1.5,
	1,
	0.75,
	0
}
DamageProfileTemplates.we_deus_01_small_explosion_glance.armor_modifier.attack = {
	0.5,
	0.25,
	1.5,
	1,
	0.75,
	0
}
DamageProfileTemplates.we_deus_01_large_explosion.armor_modifier.attack = {
	0.5,
	0.25,
	1.5,
	1,
	0.75,
	0
}
DamageProfileTemplates.we_deus_01_large_explosion_glance.armor_modifier.attack = {
	0.5,
	0.25,
	1.5,
	1,
	0.75,
	0
}
DamageProfileTemplates.we_deus_01_dot.armor_modifier.attack = {
	1,
	0.35,
	1.5,
	1,
	0.5,
	0
}
DamageProfileTemplates.we_deus_01_dot.armor_modifier.attack = {
	1,
	0.35,
	1.5,
	1,
	0.5,
	0
}
DamageProfileTemplates.we_deus_01.armor_modifier.attack = {
	1,
	0.75,
	1,
	0.75,
	0.75,
	0.25
}
DamageProfileTemplates.we_deus_01.default_target.boost_curve_coefficient_headshot = 1.75
EnergyData.we_waywatcher.depletion_cooldown = 7.5
EnergyData.we_maidenguard.depletion_cooldown = 7.5
EnergyData.we_shade.depletion_cooldown = 7.5
EnergyData.we_thornsister.depletion_cooldown = 7.5


-- Trollhammer
ExplosionTemplates.dr_deus_01.explosion.attack_type = "projectile"
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack = {
	1,
	0.5,
	3,
	1,
	0.25
}

--Masterwork Pistol
DamageProfileTemplates.shot_sniper_pistol.armor_modifier_near.attack =  { 
	1,
	1.2, 
	1, 
	1, 
	0.75, 
	0 
}
DamageProfileTemplates.shot_sniper_pistol.critical_strike.attack_armor_power_modifer  =  { 
	1,
	1.2, 
	1, 
	1, 
	0.75, 
	0 
}

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


		local procced = self:_check_extra_shot_proc(self.owner_buff_extension)
		local add_spread = not self.extra_buff_shot

		if procced then
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

--Coruscation
ExplosionTemplates.magma.aoe.duration = 3
PlayerUnitStatusSettings.overcharge_values.magma_charged_2 = 16
PlayerUnitStatusSettings.overcharge_values.magma_charged = 14

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


