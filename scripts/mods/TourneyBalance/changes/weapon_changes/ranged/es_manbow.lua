local mod = get_mod("TourneyBalance")

--[[
    Manbow
]]
local function add_chain_actions(action_no, action_from, new_data)
	local value = "allowed_chain_actions"
	local row = #action_no[action_from][value] + 1
	action_no[action_from][value][row] = new_data
end

local action_one = Weapons.longbow_empire_template.actions.action_one
local action_two = Weapons.longbow_empire_template.actions.action_two

add_chain_actions(action_one, "shoot_charged_heavy", {
	sub_action = "default",
	start_time = 0, -- 0.3
	action = "action_wield",
	input = "action_wield",
	end_time = math.huge
})
add_chain_actions(action_one, "shoot_charged", {
	sub_action = "default",
	start_time = 0, -- 0.3
	action = "action_wield",
	input = "action_wield",
	end_time = math.huge
})

action_one.shoot_charged_heavy.allowed_chain_actions[4].start_time = 0.25
action_one.shoot_charged_heavy.allowed_chain_actions[4].sub_action = "default"
action_one.shoot_charged_heavy.allowed_chain_actions[4].action = "action_one"
action_one.shoot_charged_heavy.allowed_chain_actions[4].release_required = "action_two_hold"
action_one.shoot_charged_heavy.allowed_chain_actions[4].input = "action_one"

action_one.shoot_charged_heavy.reload_event_delay_time = 0.1
action_one.shoot_charged_heavy.override_reload_time = nil
action_one.shoot_charged_heavy.allowed_chain_actions[2].start_time = 0.68

action_one.default.allowed_chain_actions[2].start_time = 0.4
action_one.default.override_reload_time = 0.15
action_two.default.heavy_aim_flow_delay = nil
action_two.default.heavy_aim_flow_event = nil
action_two.default.aim_zoom_delay = 100

Weapons.longbow_empire_template.ammo_data.reload_time = 0
Weapons.longbow_empire_template.ammo_data.reload_on_ammo_pickup = true

SpreadTemplates.empire_longbow.continuous.still = { max_yaw = 0.25, max_pitch = 0.25 }
SpreadTemplates.empire_longbow.continuous.moving = { max_yaw = 0.4, max_pitch = 0.4 }
SpreadTemplates.empire_longbow.continuous.crouch_still = { max_yaw = 0.75, max_pitch = 0.75 }
SpreadTemplates.empire_longbow.continuous.crouch_moving = { max_yaw = 2, max_pitch = 2 }
SpreadTemplates.empire_longbow.continuous.zoomed_still = { max_yaw = 0, max_pitch = 0 }
SpreadTemplates.empire_longbow.continuous.zoomed_moving = { max_yaw = 0.4, max_pitch = 0.4 }
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_still = { max_yaw = 0, max_pitch = 0 }
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_moving = { max_yaw = 0.4, max_pitch = 0.4 }

action_one.shoot_charged.allowed_chain_actions[4].start_time = 0.4
action_one.shoot_charged.allowed_chain_actions[4].sub_action = "default"
action_one.shoot_charged.allowed_chain_actions[4].action = "action_one"
action_one.shoot_charged.allowed_chain_actions[4].release_required = "action_two_hold"
action_one.shoot_charged.allowed_chain_actions[4].input = "action_one"

action_one.shoot_charged.allowed_chain_actions[2].start_time = 0.7
action_one.shoot_charged.reload_event_delay_time = 0.15
action_one.shoot_charged.override_reload_time = nil
action_one.shoot_charged.speed = 11000

action_two.default.aim_zoom_delay = 0.01
action_two.default.heavy_aim_flow_event = nil
action_two.default.default_zoom = "zoom_in_trueflight"
action_two.default.buffed_zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }

DamageProfileTemplates.arrow_sniper_kruber.armor_modifier_near.attack = { 1, 1.25, 1.5, 1, 0.75, 0.25 }
DamageProfileTemplates.arrow_sniper_kruber.critical_strike.attack_armor_power_modifer = { 1, 1, 1, 1, 0.75, 0.5 }
DamageProfileTemplates.arrow_carbine.default_target.boost_curve_coefficient = 0.6 -- 1.25
DamageProfileTemplates.arrow_carbine.default_target.boost_curve_coefficient_headshot = 0.8 -- 1
