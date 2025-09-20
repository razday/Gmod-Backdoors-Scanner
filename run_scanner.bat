@echo off
chcp 65001 >nul
title BCScan

:: =============================================================================
:: Batch Launcher for BCScan
:: Simplifies PowerShell script usage
:: =============================================================================

echo.
echo ================================================
echo                 BCScan
echo ================================================
echo.

:: PowerShell verification
powershell -Command "Get-Host" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell is not available on this system
    echo Please install PowerShell 5.0 or higher
    pause
    exit /b 1
)

:: Check if PowerShell script exists
if not exist "gmod_backdoor_scanner.ps1" (
    echo [ERROR] File gmod_backdoor_scanner.ps1 not found
    echo Make sure it's in the same folder as this batch file
    pause
    exit /b 1
)

:: Simple user interface
echo Please select your GMod addons folder:
echo.
echo Typical path examples:
echo - C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
echo - C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons
echo - D:\Games\Steam\steamapps\common\GarrysMod\garrysmod\addons
echo.

set /p addon_path="Path to addons folder: "

:: Check if path exists
if not exist "%addon_path%" (
    echo.
    echo [ERROR] Folder "%addon_path%" does not exist
    echo Check the path and try again
    pause
    exit /b 1
)

:: Report filename with timestamp
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set mytime=%mytime: =0%
set report_file=scan_report_%mydate%_%mytime%.txt

echo.
echo Configuration:
echo   Folder to scan: %addon_path%
echo   Report file: %report_file%
echo.
echo Starting scan...
echo.

:: Execute PowerShell script
powershell -ExecutionPolicy Bypass -File "gmod_backdoor_scanner.ps1" -Directory "%addon_path%" -OutputFile "%report_file%"

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo            SCAN COMPLETED SUCCESSFULLY
    echo ================================================
    echo.
    echo Report saved to: %report_file%
    echo.
    
    :: Ask if user wants to open the report
    choice /c ON /m "Do you want to Open the report or continue to Next (N)"
    if !errorlevel!==1 (
        start notepad "%report_file%"
    )
) else (
    echo.
    echo [ERROR] Scan failed
    echo Check error messages above
)

echo.
echo Press any key to close...
pause >nul