local mod = get_mod("TourneyBalance")

local function updateValues()
	local we = TalentBuffTemplates.wood_elf
	we.kerillian_shade_activated_ability_quick_cooldown_buff.buffs[1].multiplier = 0
	we.kerillian_shade_activated_ability_quick_cooldown_crit.buffs[1].duration = 6
	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end

	return

end

mod.on_enabled = function (self)
	mod:echo("enable")
	updateValues()

	return
end