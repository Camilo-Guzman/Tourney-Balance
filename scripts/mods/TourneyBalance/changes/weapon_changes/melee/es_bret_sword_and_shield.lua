local mod = get_mod("TourneyBalance")

--Bretonnian Longsword and Shield
local action_one = Weapons.one_handed_sword_shield_template_2.actions.action_one

-- Heavy Overhead (default) and Heavy Poke (default_stab_heavy) can be held indefinitely
for _, sub_action_name in ipairs({ "default", "default_stab_heavy" }) do
	local chain_actions = action_one[sub_action_name].allowed_chain_actions

	for i = #chain_actions, 1, -1 do
		if chain_actions[i].auto_chain then
			table.remove(chain_actions, i)
		end
	end
end

-- Charging the Heavy Overhead and Heavy Poke puts up the guard (Heavy Shield Bash excluded)
for _, sub_action_name in ipairs({ "default", "default_stab_heavy" }) do
	action_one[sub_action_name].blocking_charge = true
	action_one[sub_action_name].blocking_charge_start_time = 0.3
end
