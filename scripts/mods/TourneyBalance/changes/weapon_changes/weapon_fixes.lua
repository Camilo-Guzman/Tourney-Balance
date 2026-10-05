local mod = get_mod("TourneyBalance")



--[[

	Fixes

]]
--[[
	Shield crit fix
]]
DamageProfileTemplates.shield_slam_target = {
	stagger_duration_modifier = 1.75,
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
			2
		}
	},
	charge_value = "heavy_attack",
	shield_break = true,
	default_target = "default_target_slam_target_tank_M",
	armor_modifier = "armor_modifier_slam_target_tank_M"
}
DamageProfileTemplates.shield_slam = {
	stagger_duration_modifier = 1.75,
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
			1.5
		}
	},
	charge_value = "heavy_attack",
	armor_modifier = "armor_modifier_slam_tank_M",
	default_target = "default_target_slam_tank_M"
}

--[[
	Weapon Swap Fixes Moonfire
]]
Weapons.we_deus_01_template_1.actions.action_one.default.total_time = 0.7
Weapons.we_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time =  0.4
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.total_time = 0.55
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.allowed_chain_actions[1].start_time = 0.45
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.total_time = 0.5 
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.allowed_chain_actions[1].start_time = 0.4
--[[
	Weapon Swap Fixes Coru
]]
Weapons.bw_deus_01_template_1.actions.action_two.default.allowed_chain_actions[1].start_time = 0
--[[
	Weapon Swap Fixes MWP
]]
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.total_time = 0.3
Weapons.heavy_steam_pistol_template_1.actions.action_one.shoot.allowed_chain_actions[1].start_time =  0.3
--[[
	Weapon Swap Fixes Jav
]]
Weapons.javelin_template.actions.action_one.throw_charged.allowed_chain_actions[2].start_time = 0.3
Weapons.javelin_template.actions.action_one.default.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.default_left.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.default_chain_01.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.default_chain_02.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.default_chain_03.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.stab_01.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.stab_02.allowed_chain_actions[2].start_time = 0.4
Weapons.javelin_template.actions.action_one.chain_stab_03.allowed_chain_actions[2].start_time = 0.45
Weapons.javelin_template.actions.action_one.heavy_stab.allowed_chain_actions[2].start_time = 0.45

--[[
	Coghammer weapon swap buffer fix
]]
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default = {
	aim_assist_ramp_decay_delay = 0.1,
	anim_end_event = "attack_finished",
	kind = "melee_start",
	attack_hold_input = "action_one_hold",
	aim_assist_max_ramp_multiplier = 0.4,
	aim_assist_ramp_multiplier = 0.2,
	anim_event = "attack_swing_charge",
	anim_end_event_condition_func = function (unit, end_reason)
		return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
	end,
	total_time = math.huge,
	buff_data = {
		{
			start_time = 0,
			external_multiplier = 0.6,
			buff_name = "planted_charging_decrease_movement"
		}
	},
	allowed_chain_actions = {
		{
			sub_action = "light_attack_left",
			start_time = 0,
			end_time = 0.3,
			action = "action_one",
			input = "action_one_release"
		},
		{
			sub_action = "heavy_attack_left",
			start_time = 0.6,
			end_time = 1.2,
			action = "action_one",
			input = "action_one_release"
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_two",
			input = "action_two_hold"
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_wield",
			input = "action_wield"
		},
		{
			start_time = 0.6,
			end_time = 1.2,
			blocker = true,
			input = "action_one_hold"
		},
		{
			sub_action = "heavy_attack_left",
			start_time = 1,
			action = "action_one",
			auto_chain = true
		}
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions = {
	{
		sub_action = "light_attack_right",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_right",
		start_time =1,
		action = "action_one",
		auto_chain = true
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions = {
	{
		sub_action = "light_attack_last",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_left",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_left",
		start_time = 1,
		action = "action_one",
		auto_chain = true
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions = {
	{
		sub_action = "light_attack_up_right_last",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 1,
		action = "action_one",
		auto_chain = true
	}
}
--Lights 1/2/3/4
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.anim_event = "attack_swing_up_pose"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep = {
	{
		0.31666666666666665,
		0.3103722333908081,
		0.5904569625854492,
		-0.2657968997955322,
		0.7223937511444092,
		-0.29107052087783813,
		0.5494855046272278,
		0.302474707365036
	},
	{
		0.35277777777777775,
		0.1775137186050415,
		0.6366815567016602,
		-0.19225668907165527,
		0.7879757285118103,
		-0.14280153810977936,
		0.5783776640892029,
		0.1555033177137375
	},
	{
		0.3888888888888889,
		0.051915526390075684,
		0.6041536331176758,
		-0.08548450469970703,
		0.8273890018463135,
		-0.0234444011002779,
		0.5306860208511353,
		-0.18234620988368988
	},
	{
		0.425,
		-0.12680041790008545,
		0.4566812515258789,
		-0.04089641571044922,
		0.6963638663291931,
		0.19201868772506714,
		0.41889646649360657,
		-0.5502110719680786
	},
	{
		0.46111111111111114,
		-0.26615601778030396,
		0.21436119079589844,
		-0.12140655517578125,
		0.37910813093185425,
		0.4430711269378662,
		0.2820264995098114,
		-0.7618570327758789
	},
	{
		0.49722222222222223,
		-0.1962783932685852,
		0.1402301788330078,
		-0.22664093971252441,
		0.17541848123073578,
		0.5380390882492065,
		0.08140674978494644,
		-0.8204360008239746
	},
	{
		0.5333333333333333,
		-0.13591063022613525,
		0.1464986801147461,
		-0.29386401176452637,
		0.0605529323220253,
		0.579397976398468,
		-0.1304379105567932,
		-0.8022575974464417
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions = {
	{
		sub_action = "default_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions = {
	{
		sub_action = "default_last",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_last",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
--Pushstab
Weapons.two_handed_cog_hammers_template_1.actions.action_one.push.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_one",
		release_required = "action_two_hold",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_one",
		release_required = "action_two_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "light_attack_bopp",
		start_time = 0.4,
		action = "action_one",
		end_time = 0.8,
		input = "action_one_hold",
		hold_required = {
			"action_two_hold",
			"action_one_hold"
		}
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_two",
		send_buffer = true,
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.75,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.75,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.5,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.5,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		action = "action_wield",
		input = "action_wield"
	}
}
--Heavies
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 2.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 2.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.75,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions = {
	{
		sub_action = "default_right",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one"
	},
	{
		sub_action = "default_right",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.75,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}

