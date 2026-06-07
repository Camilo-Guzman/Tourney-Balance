@echo off
echo VERMINTIDE MOD BUILDER (OFFICIAL & OPEN BETA)
echo #############################################
echo. 

:: Check for both folders
if exist "mods\Tourney-Balance" if exist "mods\Tourney-Balance-Open-Beta" (
    echo [System] Both Tourney-Balance and Tourney-Balance-Open-Beta detected.
    echo.
    echo In which repository would you like to build?
    echo [1] Tourney-Balance
    echo [2] Tourney-Balance-Open-Beta
    echo.
    
    :choice_loop
    set /p user_choice="Enter your choice (1 or 2): "
    
    if "%user_choice%"=="1" (
        set "target_folder=Tourney-Balance"
        goto proceed_rename
    )
    if "%user_choice%"=="2" (
        set "target_folder=Tourney-Balance-Open-Beta"
        goto proceed_rename
    )
    
    echo Invalid choice. Please enter 1 or 2.
    goto choice_loop
)

:: Fallback if only one of them exists
if exist "mods\Tourney-Balance-Open-Beta" (
    set "target_folder=Tourney-Balance-Open-Beta"
    goto proceed_rename
)
if exist "mods\Tourney-Balance" (
    set "target_folder=Tourney-Balance"
    goto proceed_rename
)

echo [ERROR] Neither target folder was found in the mods directory.
pause
exit /b 1

:proceed_rename
echo [System] Renaming %target_folder% to TourneyBalance...
ren "mods\%target_folder%" "TourneyBalance" || (
    echo.
    echo [ERROR] Access Denied or folder not found.
    echo [ERROR] Please ensure all folders and files are closed for this build process to finish.
    echo [ERROR] Canceling script...
    pause
    exit /b 1
)

echo [System] Successfully renamed folder to TourneyBalance!

::
::
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

echo [System] Restoring root folder name to %target_folder%...
ren "mods\TourneyBalance" "%target_folder%" || (
    echo [ERROR] Failed to restore folder name.
)
echo.

echo Done! Both variants have been built successfully.
pause