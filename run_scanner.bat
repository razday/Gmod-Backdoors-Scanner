@echo off
chcp 65001 >n# Vérification que le script PowerShell existe
if not exist "gmod_backdoor_scanner.ps1" (
    echo [ERREUR] Le fichier bcscan.ps1 est introuvable
    echo Assurez-vous qu'il soit dans le même dossier que ce fichier batchtitle BCScan

:: =============================================================================
:: Lanceur Batch pour BCScan
:: Simplifie l'utilisation du script PowerShell
:: =============================================================================

echo.
echo ================================================
echo                 BCScan
echo ================================================
echo.

:: Vérification de PowerShell
powershell -Command "Get-Host" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] PowerShell n'est pas disponible sur ce système
    echo Veuillez installer PowerShell 5.0 ou supérieur
    pause
    exit /b 1
)

:: Vérification que le script PowerShell existe
if not exist "gmod_backdoor_scanner.ps1" (
    echo [ERREUR] Le fichier gmod_backdoor_scanner.ps1 est introuvable
    echo Assurez-vous qu'il soit dans le même dossier que ce fichier batch
    pause
    exit /b 1
)

:: Interface utilisateur simple
echo Veuillez sélectionner votre dossier addons GMod:
echo.
echo Exemples de chemins typiques:
echo - C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
echo - C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons
echo - D:\Games\Steam\steamapps\common\GarrysMod\garrysmod\addons
echo.

set /p addon_path="Chemin vers le dossier addons: "

:: Vérification que le chemin existe
if not exist "%addon_path%" (
    echo.
    echo [ERREUR] Le dossier "%addon_path%" n'existe pas
    echo Vérifiez le chemin et réessayez
    pause
    exit /b 1
)

:: Nom du fichier de rapport avec timestamp
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set mytime=%mytime: =0%
set report_file=scan_report_%mydate%_%mytime%.txt

echo.
echo Configuration:
echo   Dossier à scanner: %addon_path%
echo   Fichier de rapport: %report_file%
echo.
echo Démarrage du scan...
echo.

:: Exécution du script PowerShell
powershell -ExecutionPolicy Bypass -File "gmod_backdoor_scanner.ps1" -Directory "%addon_path%" -OutputFile "%report_file%"

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo            SCAN TERMINÉ AVEC SUCCÈS
    echo ================================================
    echo.
    echo Le rapport a été sauvegardé dans: %report_file%
    echo.
    
    :: Demander si l'utilisateur veut ouvrir le rapport
    choice /c ON /m "Voulez-vous Ouvrir le rapport ou passer à la suite (N)"
    if !errorlevel!==1 (
        start notepad "%report_file%"
    )
) else (
    echo.
    echo [ERREUR] Le scan a échoué
    echo Vérifiez les messages d'erreur ci-dessus
)

echo.
echo Appuyez sur une touche pour fermer...
pause >nul