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
:: --- START OF LOCAL BRANCH GUARD ---
:: Query Git targeting the specific repository folder path
for /f "tokens=*" %%i in ('git -C "mods\%target_folder%" rev-parse --abbrev-ref HEAD 2^>nul') do set "CURRENT_BRANCH=%%i"

:: Check if the branch matches "exp"
if /i "%CURRENT_BRANCH%"=="exp" goto block_build

goto allow_build

:block_build
echo [BLOCK] Repository "mods\%target_folder%" is on branch "%CURRENT_BRANCH%".
echo [BLOCK] Building is strictly forbidden on the experimental branch!
echo.
pause
exit /b 1

:allow_build
:: --- END OF LOCAL BRANCH GUARD ---
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
echo.

echo ==================================================
echo Building "Tourney Balance Official"
echo ==================================================
echo. 
vmb build "TourneyBalance" -g 2
echo.

echo [System] Restoring root folder name to %target_folder%...
ren "mods\TourneyBalance" "%target_folder%" || (
    echo [ERROR] Failed to restore folder name.
)
echo.

echo Done! Both variants have been built successfully.
pause