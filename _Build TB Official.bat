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
echo.

echo ==================================================
echo Building "Tourney Balance Official"
echo ==================================================
echo. 
vmb build "TourneyBalance" -g 2
echo.

echo [System] Restoring root folder name to Tourney-Balance-Open-Beta...
ren "mods\TourneyBalance" "Tourney-Balance-Open-Beta"
echo.

echo Done! Both variants have been built successfully.
pause