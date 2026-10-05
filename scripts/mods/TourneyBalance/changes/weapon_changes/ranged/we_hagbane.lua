local mod = get_mod("TourneyBalance")

--[[
    Hagbane
]]
DamageProfileTemplates.poison = {
	charge_value = "n/a",
	is_dot = true,
	no_stagger = true,
	no_stagger_damage_reduction_ranged = true,
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25,
	},
	armor_modifier = {
		attack = {
			1.6, -- 1.25
			1,
			3,
			1,
			0.5,
			0.2,
		},
		impact = {
			1,
			1,
			3,
			1,
			0.5,
			0,
		},
	},
	default_target = {
		attack_template = "arrow_poison_aoe",
		damage_type = "arrow_poison_dot",
		power_distribution = {
			attack = 0.035,
			impact = 0,
		},
	},
}

DamageProfileTemplates.poison_aoe = {
	charge_value = "aoe",
	is_dot = true,
	no_friendly_fire = true,
	no_stagger = false,
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	armor_modifier = {
		attack = {
			1.25,
			0, -- 0.1
			1.5,
			1,
			1,
			0,
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.5,
			0,
		},
	},
	default_target = {
		attack_template = "arrow_poison_aoe",
		damage_type = "poison",
		dot_template_name = "aoe_poison_dot",
		power_distribution = {
			attack = 0.05,
			impact = 0.5,
		},
	},
}