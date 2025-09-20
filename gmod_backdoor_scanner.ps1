# =============================================================================
# BCScan - Version PowerShell
# Script PowerShell pour détecter les backdoors dans les addons GMod
# Compatible Windows 10/11, PowerShell 5.1+
# =============================================================================

param(
    [Parameter(Mandatory=$true, HelpMessage="Chemin vers le dossier addons de GMod")]
    [Alias("d")]
    [string]$Directory,
    
    [Parameter(HelpMessage="Fichier de sortie du rapport (défaut: scan_results.txt)")]
    [Alias("o")]
    [string]$OutputFile = "scan_results.txt",
    
    [Parameter(HelpMessage="Afficher l'aide")]
    [Alias("h")]
    [switch]$Help
)

# Configuration du script
$VERSION = "1.0.0"
$SCRIPT_NAME = "BCScan"

# Variables globales
$script:TotalFiles = 0
$script:InfectedFiles = 0
$script:TotalDetections = 0
$script:ScanResults = @()

# Fonction d'affichage du header
function Write-Header {
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host "        $SCRIPT_NAME v$VERSION" -ForegroundColor Blue
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host ""
}

# Fonction d'aide
function Show-Help {
    Write-Header
    Write-Host "Usage:" -ForegroundColor Green
    Write-Host "  .\bcscan.ps1 -Directory <path> [-OutputFile <file>]"
    Write-Host ""
    Write-Host "Paramètres:" -ForegroundColor Green
    Write-Host "  -Directory, -d    Chemin vers le dossier addons de GMod (OBLIGATOIRE)"
    Write-Host "  -OutputFile, -o   Fichier de sortie (défaut: scan_results.txt)"
    Write-Host "  -Help, -h         Afficher cette aide"
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Green
    Write-Host '  .\bcscan.ps1 -d "C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons"'
    Write-Host '  .\bcscan.ps1 -Directory "D:\GMod\addons" -OutputFile "rapport_backdoors.txt"'
    Write-Host ""
}

# Patterns de détection (extraits du code PHP KVacDoor)
$BackdoorPatterns = @{
    # Fonctions Lua dangereuses (niveau 1)
    'RunString' = @{Name = 'RunString Function'; Level = 1}
    'RunStringEx' = @{Name = 'RunStringEx Function'; Level = 1}
    'CompileString' = @{Name = 'CompileString Function'; Level = 1}
    
    # Fonctions HTTP (niveau 0)
    'http\.Fetch' = @{Name = 'http.Fetch Function'; Level = 0}
    'http\.Post' = @{Name = 'http.Post Function'; Level = 0}
    'HTTP' = @{Name = 'HTTP Function'; Level = 0}
    
    # Panels de backdoors spécifiques (niveau 3)
    'RunHASHOb' = @{Name = 'John Ducksent Obfuscator'; Level = 3}
    'kvac\.' = @{Name = 'KVacDoor Panel'; Level = 3}
    'kvacdoor\.' = @{Name = 'KVacDoor Panel'; Level = 3}
    'gblk' = @{Name = 'GHackDoor Panel'; Level = 3}
    'local hash1 = sep' = @{Name = 'Cipher-Panel Obfuscated'; Level = 3}
    'local OMEGA' = @{Name = 'Omega Panel Obfuscated'; Level = 3}
    'function\(__,anti_lag\)' = @{Name = 'Omega Panel Obfuscated'; Level = 3}
    'local chat_admin' = @{Name = 'Omega Panel Obfuscated'; Level = 3}
    'omega-project\.cz' = @{Name = 'Omega Panel'; Level = 3}
    'local file = "api_connect\.php"' = @{Name = 'Omega Panel Obfuscated'; Level = 3}
    'gvac' = @{Name = 'GVacDoor Panel | Enigma'; Level = 3}
    'cipher-panel' = @{Name = 'Cipher-Panel'; Level = 3}
    'RunningDuck' = @{Name = 'GHackDoor Obfusator'; Level = 3}
    '7,26,13,15' = @{Name = 'KVacDoor Panel Obfuscated'; Level = 3}
    '24,5,1,9,30,66,63,5,1,28,0,9,68,93,64,76,10,25,2,15,24,5,3,2,68,69,76,4,24,24,28,66,42,9,24,15,4,68,78,4,24,24,28,31,86,67,67,11,26,13,15,66,15,22' = @{Name = 'GVacDoor Panel Obfuscated'; Level = 3}
    '11,22,1,3' = @{Name = 'KVacDoor Panel Obfuscated'; Level = 3}
}

# Fonction pour obtenir l'émoji selon le niveau de dangerosité
function Get-DangerEmoji {
    param([int]$Level)
    
    switch ($Level) {
        0 { return "[SUSPECT]" }
        1 { return "[DANGER]" }
        3 { return "[CRITICAL]" }
        default { return "[UNKNOWN]" }
    }
}

# Fonction pour obtenir la couleur selon le niveau
function Get-ColorByLevel {
    param([int]$Level)
    
    switch ($Level) {
        0 { return "Yellow" }
        1 { return "Magenta" }
        3 { return "Red" }
        default { return "White" }
    }
}

# Fonction pour initialiser le fichier de rapport
function Initialize-Report {
    param([string]$FilePath, [string]$ScanDirectory)
    
    $reportContent = @"
================================================================================
                          BCSCAN - RAPPORT DE SCAN
================================================================================
Date du scan: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
Dossier scanné: $ScanDirectory
Script version: $VERSION
OS: $($env:OS) - PowerShell $($PSVersionTable.PSVersion)

================================================================================
                              RÉSULTATS DE SCAN
================================================================================

"@
    
    $reportContent | Out-File -FilePath $FilePath -Encoding UTF8
}

# Fonction principale de scan d'un fichier
function Scan-File {
    param(
        [string]$FilePath,
        [string]$BasePath
    )
    
    $relativePath = $FilePath.Replace($BasePath, "").TrimStart('\')
    $detections = @()
    
    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        
        # Test de chaque pattern
        foreach ($pattern in $BackdoorPatterns.Keys) {
            if ($content -match $pattern) {
                $detection = $BackdoorPatterns[$pattern]
                $detections += @{
                    Name = $detection.Name
                    Level = $detection.Level
                }
                $script:TotalDetections++
            }
        }
        
        # Si des détections ont été trouvées
        if ($detections.Count -gt 0) {
            $script:InfectedFiles++
            
            # Affichage console
            Write-Host "[INFECTED] $relativePath" -ForegroundColor Red
            
            # Ajout au rapport
            Add-Content -Path $OutputFile -Value "FICHIER INFECTÉ: $relativePath" -Encoding UTF8
            Add-Content -Path $OutputFile -Value "----------------------------------------" -Encoding UTF8
            
            foreach ($detection in $detections) {
                $emoji = Get-DangerEmoji -Level $detection.Level
                $color = Get-ColorByLevel -Level $detection.Level
                
                Write-Host "  $emoji $($detection.Name) (Niveau: $($detection.Level))" -ForegroundColor $color
                Add-Content -Path $OutputFile -Value "  $emoji $($detection.Name) (Niveau: $($detection.Level))" -Encoding UTF8
            }
            
            Add-Content -Path $OutputFile -Value "" -Encoding UTF8
            Write-Host ""
            
            # Stockage des résultats
            $script:ScanResults += @{
                FilePath = $relativePath
                Detections = $detections
            }
            
            return $true
        } else {
            Write-Host "[CLEAN] $relativePath" -ForegroundColor Green
            return $false
        }
    }
    catch {
        Write-Host "[ERROR] Impossible de lire: $relativePath" -ForegroundColor Yellow
        return $false
    }
}

# Fonction pour scanner récursivement un dossier
function Scan-Directory {
    param([string]$DirectoryPath)
    
    Write-Host "Démarrage du scan de: $DirectoryPath" -ForegroundColor Blue
    Write-Host ""
    
    # Compter le nombre total de fichiers .lua
    try {
        $luaFiles = Get-ChildItem -Path $DirectoryPath -Filter "*.lua" -Recurse -File -ErrorAction Stop
        $script:TotalFiles = $luaFiles.Count
    }
    catch {
        Write-Host "Erreur lors de l'accès au dossier: $_" -ForegroundColor Red
        exit 1
    }
    
    if ($script:TotalFiles -eq 0) {
        Write-Host "Aucun fichier .lua trouvé dans le dossier spécifié." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Nombre total de fichiers .lua à scanner: $($script:TotalFiles)" -ForegroundColor Blue
    Write-Host ""
    
    # Initialisation du rapport
    Initialize-Report -FilePath $OutputFile -ScanDirectory $DirectoryPath
    
    $currentFile = 0
    
    # Scanner tous les fichiers .lua
    foreach ($file in $luaFiles) {
        $currentFile++
        $percentage = [math]::Round(($currentFile / $script:TotalFiles) * 100, 1)
        
        Write-Progress -Activity "Scan en cours..." -Status "Fichier $currentFile/$($script:TotalFiles) ($percentage%)" -PercentComplete $percentage
        
        Scan-File -FilePath $file.FullName -BasePath $DirectoryPath
    }
    
    Write-Progress -Activity "Scan en cours..." -Completed
}

# Fonction pour générer le résumé final
function Generate-Summary {
    $cleanFiles = $script:TotalFiles - $script:InfectedFiles
    $infectionRate = if ($script:TotalFiles -gt 0) { 
        [math]::Round(($script:InfectedFiles / $script:TotalFiles) * 100, 2) 
    } else { 
        0 
    }
    
    # Ajout du résumé au rapport
    $summaryContent = @"

================================================================================
                               RÉSUMÉ DU SCAN
================================================================================
Fichiers analysés: $($script:TotalFiles)
Fichiers infectés: $($script:InfectedFiles)
Fichiers propres: $cleanFiles
Total détections: $($script:TotalDetections)

Taux d'infection: $infectionRate%

================================================================================
                          FIN DU RAPPORT DE SCAN
================================================================================
"@
    
    Add-Content -Path $OutputFile -Value $summaryContent -Encoding UTF8
    
    # Affichage du résumé en console
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host "              RÉSUMÉ DU SCAN" -ForegroundColor Blue
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host "Fichiers analysés: $($script:TotalFiles)" -ForegroundColor Green
    Write-Host "Fichiers infectés: $($script:InfectedFiles)" -ForegroundColor Red
    Write-Host "Fichiers propres: $cleanFiles" -ForegroundColor Green
    Write-Host "Total détections: $($script:TotalDetections)" -ForegroundColor Yellow
    Write-Host ""
    
    if ($script:InfectedFiles -gt 0) {
        Write-Host "WARNING: Des backdoors ont été détectées!" -ForegroundColor Red
        Write-Host "Consultez le rapport complet: $OutputFile" -ForegroundColor Yellow
    } else {
        Write-Host "SUCCESS: Aucune backdoor détectée! Vos addons semblent propres." -ForegroundColor Green
    }
    
    Write-Host ""
}

# Fonction principale
function Main {
    # Vérification de l'aide
    if ($Help) {
        Show-Help
        return
    }
    
    Write-Header
    
    # Vérification des prérequis
    if (-not $Directory) {
        Write-Host "Erreur: Vous devez spécifier un dossier à scanner avec -Directory" -ForegroundColor Red
        Write-Host ""
        Show-Help
        return
    }
    
    if (-not (Test-Path -Path $Directory)) {
        Write-Host "Erreur: Le dossier '$Directory' n'existe pas." -ForegroundColor Red
        return
    }
    
    # Vérification de PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "Attention: Ce script nécessite PowerShell 5.0 ou supérieur" -ForegroundColor Yellow
    }
    
    # Démarrage du scan
    Write-Host "Configuration:" -ForegroundColor Green
    Write-Host "  Dossier à scanner: " -NoNewline -ForegroundColor White
    Write-Host $Directory -ForegroundColor Yellow
    Write-Host "  Fichier de rapport: " -NoNewline -ForegroundColor White
    Write-Host $OutputFile -ForegroundColor Yellow
    Write-Host ""
    
    $startTime = Get-Date
    
    try {
        Scan-Directory -DirectoryPath $Directory
        Generate-Summary
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-Host "Scan terminé avec succès!" -ForegroundColor Blue
        Write-Host "Durée du scan: $($duration.ToString('mm\:ss'))" -ForegroundColor Cyan
        Write-Host "Rapport sauvegardé: $OutputFile" -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors du scan: $_" -ForegroundColor Red
    }
}

# Exécution du script principal
Main