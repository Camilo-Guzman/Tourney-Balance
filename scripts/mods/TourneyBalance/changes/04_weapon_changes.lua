local mod = get_mod("TourneyBalance")

-- general and fixes
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/general_weapon_changes")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/weapon_fixes")
-- career ability
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/career_ability/bw_pyromancer_ult")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/career_ability/we_thornsister_blackvenom")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/career_ability/we_waystalker_trueflight")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/career_ability/wh_bountyhunter_shotgun")
-- melee
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/1h_axe")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/1h_hammer")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/1h_sword")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/2h_hammer")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/2h_sword")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/bw_crowbill")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/bw_dagger")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/bw_flaming_flail")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/bw_mace")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/bw_scythe")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/dr_2h_axe")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/dr_dual_axes")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/es_bret_sword")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/es_bret_sword_and_shield")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/es_halberd")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/es_mace_and_sword")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/es_spear_and_shield")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/es_tuskgor_spear")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/we_1h_sword")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/we_2h_sword")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/we_dual_daggers")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/we_dual_swords")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/we_glaive")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/we_spear")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/wh_axe_and_falchion")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/wh_falchion")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/wh_flail")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/wh_hammer_and_tome")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/melee/wh_holy_hammer")
-- ranged
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/bw_beam")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/bw_bolt")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/bw_conflag")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/bw_coruscation")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/bw_fireball")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/bw_soulstealer")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/crossbows")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/dr_pistol")
--
--mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/dr_throwing_axes")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/dr_trollhammer")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/es_manbow")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/we_hagbane")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/we_javelin")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/we_moonfire")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/we_staff")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/we_swiftbow")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/wh_brace_of_pistols")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/ranged/wh_griffin_foot")

--[[
	Damage profile linking + weapon defaults MUST run after weapon_changes: they finalize
	and validate whatever weapon_changes registered into NewDamageProfileTemplates/Weapons,
	and only fill in a default where weapon_changes left a field unset. Reordering these
	ahead of weapon_changes will silently break or overwrite its customizations.
]]
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/_damage_profile_setup")
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes/_weapon_defaults_setup")

