local mod = get_mod("TourneyBalance")

-- Kill THP
-- https://github.com/Aussiemon/Vermintide-2-Source-Code/tree/master/scripts/settings/breeds/breed_tweaks.lua#L594
NewBreedTweaks = NewBreedTweaks or {}
NewBreedTweaks.bloodlust_health = {
	beastmen_elite = 15,
	beastmen_horde = 1.5,
	beastmen_roamer = 3,
	chaos_bulwark = 35,
	chaos_elite = 10, -- 15
	chaos_horde = 1.5,
	chaos_roamer = 3,
	chaos_special = 10,
	chaos_warrior = 20, -- 30
	monster = 35, --50
	skaven_elite = 8,
	skaven_horde = 1,
	skaven_roamer = 2,
	skaven_special = 8,
}

local BLOODLUST_HEALTH_BY_BREED = {
	beastmen_bestigor = "beastmen_elite",
	beastmen_gor = "beastmen_roamer",
	beastmen_gor_dummy = "beastmen_roamer",
	beastmen_minotaur = "monster",
	beastmen_standard_bearer = "beastmen_elite",
	beastmen_ungor_archer = "beastmen_horde",
	beastmen_ungor = "beastmen_horde",
	beastmen_ungor_dummy = "beastmen_horde",
	chaos_berzerker = "chaos_elite",
	chaos_corruptor_sorcerer = "chaos_special",
	chaos_exalted_champion_warcamp = "monster",
	chaos_exalted_sorcerer_drachenfels = "monster",
	chaos_exalted_sorcerer = "monster",
	chaos_fanatic = "chaos_horde",
	chaos_marauder_with_shield = "chaos_roamer",
	chaos_marauder = "chaos_roamer",
	chaos_marauder_tutorial = "chaos_roamer",
	chaos_mutator_sorcerer = "chaos_special",
	-- chaos_plague_sorcerer = "chaos_special",
	chaos_raider = "chaos_elite",
	chaos_raider_tutorial = "chaos_elite",
	chaos_spawn = "monster",
	-- chaos_tentacle_sorcerer = "chaos_special",
	chaos_troll = "monster",
	chaos_vortex_sorcerer = "chaos_special",
	chaos_warrior = "chaos_warrior",
	skaven_clan_rat_with_shield = "skaven_roamer",
	skaven_clan_rat = "skaven_roamer",
	skaven_clan_rat_tutorial = "skaven_roamer",
	skaven_explosive_loot_rat = "skaven_roamer",
	skaven_grey_seer = "monster",
	skaven_gutter_runner = "skaven_special",
	skaven_loot_rat = "skaven_special",
	skaven_pack_master = "skaven_special",
	skaven_plague_monk = "skaven_elite",
	skaven_poison_wind_globadier = "skaven_special",
	skaven_rat_ogre = "monster",
	skaven_ratling_gunner = "skaven_special",
	skaven_slave = "skaven_horde",
	skaven_storm_vermin_champion = "monster",
	skaven_storm_vermin_warlord = "monster",
	skaven_storm_vermin_with_shield = "skaven_elite",
	skaven_storm_vermin = "skaven_elite",
	skaven_storm_vermin_commander = "skaven_elite",
	skaven_stormfiend_boss = "monster",
	skaven_stormfiend = "monster",
	skaven_warpfire_thrower = "skaven_special",
}

for breed_name, category in pairs(BLOODLUST_HEALTH_BY_BREED) do
	Breeds[breed_name].bloodlust_health = NewBreedTweaks.bloodlust_health[category]
end
