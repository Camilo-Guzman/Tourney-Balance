# Tourney-Balance

This [repository](https://github.com/Camilo-Guzman/Tourney-Balance) contains the source code of the Tourney Balance mod for Warhammer: Vermintide 2. ([Steam workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2545022878))

If you would also like to join the modded scene - be it for tourneys, regular games, or just discussions about the mods in question - feel free to join [Onslaught Series](https://discord.gg/MS4vWSQrEh) and the [VT Modded Community](https://discord.gg/hyeADkwp) Discord servers!


 
---
---
---



# Tourney-Balance-Open-Beta

This [repository](https://github.com/exquilibrium/Tourney-Balance-Open-Beta) contains the source code for public testing of new features for the Tourney Balance mod. ([Steam workshop page](https://github.com/exquilibrium/Tourney-Balance-Open-Beta))

If you would like to contribute to this mod, you can create a pull request on the [Tourney-Balance-Open-Beta](https://github.com/exquilibrium/Tourney-Balance-Open-Beta) fork. **Please take note of our workflow for building and uploading the mod explained below.**

## Important Notes for Contributors
### Building the Mod
- Clone this repo into `Vermintide-Mod-Setup-master\vermintide-mod-builder\mods` using
```
git clone https://github.com/exquilibrium/Tourney-Balance-Open-Beta.git
```
- **DO NOT use "_Build Mod.bat" to build this mod** unless you know what it's doing.
- **MAKE SURE the "Tourney-Balance-Open-Beta" folder is NOT opened in any application, when trying to run the build scripts.**
- Copy the `.bat` scripts from this repository to `Vermintide-Mod-Setup-master\vermintide-mod-builder`.
- Run any script to build the mod. This will replace the local copy of your mod, allowing you to test without uploading to Steam.
    - `_Build TB All.bat` builds both the Official and Open Beta mod.
    - `_Build TB Official.bat` builds only the Official mod.
    - `_Build TB Open Beta.bat` builds only the Open Beta mod.

### Uploading the Mod
Instead of using the `_Upload Mod.bat` script to update the mod on the steam workshop page, we use GitHub workflows for handling the upload. This way we can track changes to the mod via the commit history.
- To upload the mod push your changes via [Git](https://git-scm.com/) to the Tourney-Balance-Open-Beta fork.
- This triggers the workflow in `.github/workflows/upload.yml` to upload the most recent build.
    - Depending wether the workflow was triggered on the main repository or the fork, it will upload either the official or open beta version.
    - The upload of the mod itself is handled by our steam bot account [Skavenslave](https://steamcommunity.com/profiles/76561199068515847/).

### Updating the Tourney Balance
- To update the official version of Tourney Balance simply create a pull request on the fork.
    - Make sure that the last build was made using `_Build TB All.bat`
    - Make sure that **the changes are working!!!**
- Once the pull request is merged into the main repository, the workflow will automatically trigger and upload the mod to the steam workshop.







