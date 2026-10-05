local mod = get_mod("TourneyBalance")

--[[
    Throwing Axes
    anim_time_scale scales fire_time, chain start_times and the animation together,
    so the throws/recall stay visually in sync while getting faster.
]]
local throwing_axes = Weapons.one_handed_throwing_axes_template.actions

-- Light throw: release 0.4 -> 0.32s, next throw 0.65 -> 0.52s
throwing_axes.action_one.default.anim_time_scale = 1.25
-- Charged throw: release 0.2 -> 0.16s, next charge 0.55 -> 0.44s
throwing_axes.action_one.throw_charged.anim_time_scale = 1.25
-- Charge: charged throw available 0.65 -> 0.5s (same as Javelin)
throwing_axes.action_two.default.anim_time_scale = 1.3

-- Recall: first axe 1.04 -> 0.83s, every following axe 0.55 -> 0.44s
throwing_axes.weapon_reload.default.anim_time_scale = 1.6
throwing_axes.weapon_reload.catch.anim_time_scale = 1.25
