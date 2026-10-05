--[[
    MUST run after weapon_changes has been dofile'd: several checks below only apply a
    default when the relevant field is still nil, so weapon_changes's own customizations
    need to already be in place, or this will silently overwrite them with defaults. See
    the dofile ordering comment in TourneyBalance.lua.
]]

local MeleeBuffTypes = MeleeBuffTypes or {
	MELEE_1H = true,
	MELEE_2H = true
}
local RangedBuffTypes = RangedBuffTypes or {
	RANGED_ABILITY = true,
	RANGED = true
}
local WEAPON_DAMAGE_UNIT_LENGTH_EXTENT = 1.919366
local TAP_ATTACK_BASE_RANGE_OFFSET = 0.6
local HOLD_ATTACK_BASE_RANGE_OFFSET = 0.65

for item_template_name, item_template in pairs(Weapons) do
	item_template.name = item_template_name
	item_template.crosshair_style = item_template.crosshair_style or "dot"
	local attack_meta_data = item_template.attack_meta_data
	local tap_attack_meta_data = attack_meta_data and attack_meta_data.tap_attack
	local hold_attack_meta_data = attack_meta_data and attack_meta_data.hold_attack
	local set_default_tap_attack_range = tap_attack_meta_data and tap_attack_meta_data.max_range == nil
	local set_default_hold_attack_range = hold_attack_meta_data and hold_attack_meta_data.max_range == nil

	if RangedBuffTypes[item_template.buff_type] and attack_meta_data then
		attack_meta_data.effective_against = attack_meta_data.effective_against or 0
		attack_meta_data.effective_against_charged = attack_meta_data.effective_against_charged or 0
		attack_meta_data.effective_against_combined = bit.bor(attack_meta_data.effective_against, attack_meta_data.effective_against_charged)
	end

	if MeleeBuffTypes[item_template.buff_type] then
		fassert(attack_meta_data, "Missing attack metadata for weapon %s", item_template_name)
		fassert(tap_attack_meta_data, "Missing tap_attack metadata for weapon %s", item_template_name)
		fassert(hold_attack_meta_data, "Missing hold_attack metadata for weapon %s", item_template_name)
		fassert(tap_attack_meta_data.arc, "Missing arc parameter in tap_attack metadata for weapon %s", item_template_name)
		fassert(hold_attack_meta_data.arc, "Missing arc parameter in hold_attack metadata for weapon %s", item_template_name)
	end

	local actions = item_template.actions

	for action_name, sub_actions in pairs(actions) do
		for sub_action_name, sub_action_data in pairs(sub_actions) do
			local lookup_data = {
				item_template_name = item_template_name,
				action_name = action_name,
				sub_action_name = sub_action_name
			}
			sub_action_data.lookup_data = lookup_data
			local action_kind = sub_action_data.kind
			local action_assert_func = ActionAssertFuncs[action_kind]

			if action_assert_func then
				action_assert_func(item_template_name, action_name, sub_action_name, sub_action_data)
			end

			if action_name == "action_one" then
				local range_mod = sub_action_data.range_mod or 1

				if set_default_tap_attack_range and string.find(sub_action_name, "light_attack") then
					local current_attack_range = tap_attack_meta_data.max_range or math.huge
					local tap_attack_range = TAP_ATTACK_BASE_RANGE_OFFSET + WEAPON_DAMAGE_UNIT_LENGTH_EXTENT * range_mod
					tap_attack_meta_data.max_range = math.min(current_attack_range, tap_attack_range)
				elseif set_default_hold_attack_range and string.find(sub_action_name, "heavy_attack") then
					local current_attack_range = hold_attack_meta_data.max_range or math.huge
					local hold_attack_range = HOLD_ATTACK_BASE_RANGE_OFFSET + WEAPON_DAMAGE_UNIT_LENGTH_EXTENT * range_mod
					hold_attack_meta_data.max_range = math.min(current_attack_range, hold_attack_range)
				end
			end

			local impact_data = sub_action_data.impact_data

			if impact_data then
				local pickup_settings = impact_data.pickup_settings

				if pickup_settings then
					local link_hit_zones = pickup_settings.link_hit_zones

					if link_hit_zones then
						for i = 1, #link_hit_zones, 1 do
							local hit_zone_name = link_hit_zones[i]
							link_hit_zones[hit_zone_name] = true
						end
					end
				end
			end
		end
	end
end
