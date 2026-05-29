@echo off
echo VERMINTIDE MOD BUILDER (OFFICIAL & OPEN BETA)
echo #############################################
echo. 

echo [System] Renaming folder to TourneyBalance...
ren "mods\Tourney-Balance-Open-Beta" "TourneyBalance" || (
    echo.
    echo [ERROR] Access Denied or folder not found.
    echo [ERROR] Please ensure all folders and files are closed for this build process to finish.
    echo [ERROR] Canceling script...
    pause
    exit /b 1
)

:: Set a base path variable to keep the code clean
set "MOD_PATH=mods\TourneyBalance"

echo [System] Cleaning up old build folders...
if exist "%MOD_PATH%\bundleV2" rmdir /s /q "%MOD_PATH%\bundleV2"
if exist "%MOD_PATH%\bundleV2-Open-Beta" rmdir /s /q "%MOD_PATH%\bundleV2-Open-Beta"
echo.

echo ==================================================
echo Building "Tourney Balance Official"
echo ==================================================
echo. 
vmb build "TourneyBalance" -g 2
echo.

echo [System] Isolating Official build outputs...
ren "%MOD_PATH%\bundleV2" "bundleV2-Official"
ren "%MOD_PATH%\itemV2.cfg" "itemV2-Official.cfg"

echo [System] Preparing Open Beta configuration...
ren "%MOD_PATH%\itemV2-Open-Beta.cfg" "itemV2.cfg"
echo.

echo ==================================================
echo Building "Tourney Balance Open Beta"
echo ==================================================
echo. 
vmb build "TourneyBalance" -g 2
echo.

echo [System] Isolating Open Beta build outputs...
ren "%MOD_PATH%\bundleV2" "bundleV2-Open-Beta"
echo.

echo ==================================================
echo Restoring files and folder names...
echo ==================================================
ren "%MOD_PATH%\itemV2.cfg" "itemV2-Open-Beta.cfg"
ren "%MOD_PATH%\itemV2-Official.cfg" "itemV2.cfg"
ren "%MOD_PATH%\bundleV2-Official" "bundleV2"

echo [System] Restoring root folder name to Tourney-Balance-Open-Beta...
ren "mods\TourneyBalance" "Tourney-Balance-Open-Beta"
echo.

echo Done! Both variants have been built successfully.
pause