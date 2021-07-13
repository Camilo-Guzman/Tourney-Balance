return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TourneyBalance` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("TourneyBalance", {
			mod_script       = "scripts/mods/TourneyBalance/TourneyBalance",
			mod_data         = "scripts/mods/TourneyBalance/TourneyBalance_data",
			mod_localization = "scripts/mods/TourneyBalance/TourneyBalance_localization",
		})
	end,
	packages = {
		"resource_packages/TourneyBalance/TourneyBalance",
	},
}
