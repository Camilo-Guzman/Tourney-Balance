local mod = get_mod("TourneyBalance")

local function updateValues()
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

-- Ability Cooldown Changes
-- Battle Wizard
ActivatedAbilitySettings.bw_2[1].cooldown = 60

-- Passives Changes
-- Bounty Hunter
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")