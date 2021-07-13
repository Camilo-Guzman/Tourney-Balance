local mod = get_mod("TourneyBalance")

local function updateValues()
	local es = TalentBuffTemplates.empire_soldier
	es.markus_knight_passive.buffs[1].range = 20
	es.markus_knight_power_level_on_stagger_elite_buff.buffs[1].duration = 15
	es.markus_knight_attack_speed_on_push_buff.buffs[1].duration = 5
	es.markus_knight_cooldown_buff.buffs[1].duration = 0.75
	es.markus_knight_cooldown_buff.buffs[1].multiplier = 3
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

--Ability cooldown changes
ActivatedAbilitySettings.bw_2[1].cooldown = 60

--Footknight Talents
--mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive", {
--	range = 20
--})

--mod:modify_talent_buff_template("empire_soldier", "markus_knight_power_level_on_stagger_elite_buff", {
--	duration = 15
--})
--mod:add_text("markus_knight_attack_speed_on_push_buff_desc", "Pushing an enemy increases attack speed by 15%% for 3 seconds.")

--mod:modify_talent_buff_template("empire_soldier", "markus_knight_attack_speed_on_push_buff", {
	--duration = 5,
	--multiplier = 0.15
--})
--mod:add_text("markus_knight_power_level_on_stagger_elite_buff_desc", "Staggering an elite enemy increases power by 15%% for 10 seconds.")



--mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_buff", {
	--duration = 0.75,
	--multiplier = 3
--})
--mod:add_text("markus_knight_cooldown_buff_desc", "Staggering an Elite enemy accelarates the cooldown of nearby allies by 200%% for 0.75 ")
-- Shade Talents
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_buff", {
--    multiplier = 0, -- -0.45
--})
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_crit", {
--    duration = 6, --4
--})
--mod:modify_talent("we_shade", 6, 1, {
--    description = "rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2",
--    description_values = {},
--})

--mod:add_text("rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2", "After leaving stealth, Kerillian gains 100%% melee critical strike chance for 6 seconds, but no longer gains a damage bonus on attacking.")