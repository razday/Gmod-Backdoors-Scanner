# =============================================================================
# BCScan - PowerShell Version
# PowerShell script to detect backdoors in GMod addons
# Compatible Windows 10/11, PowerShell 5.1+
# =============================================================================

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to GMod addons folder")]
    [Alias("d")]
    [string]$Directory,
    
    [Parameter(HelpMessage="Output report file (default: scan_results.txt)")]
    [Alias("o")]
    [string]$OutputFile = "scan_results.txt",
    
    [Parameter(HelpMessage="Show help")]
    [Alias("h")]
    [switch]$Help
)

# Configuration
$VERSION = "1.0.0"
$SCRIPT_NAME = "BCScan"

# Global variables
$script:TotalFiles = 0
$script:InfectedFiles = 0
$script:TotalDetections = 0
$script:ScanResults = @()

# Function to display header
function Write-Header {
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host "        $SCRIPT_NAME v$VERSION" -ForegroundColor Blue
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host ""
}

# Help function
function Show-Help {
    Write-Header
    Write-Host "Usage:" -ForegroundColor Green
    Write-Host "  .\bcscan.ps1 -Directory <path> [-OutputFile <file>]"
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Green
    Write-Host "  -Directory, -d    Path to GMod addons folder (REQUIRED)"
    Write-Host "  -OutputFile, -o   Output file (default: scan_results.txt)"
    Write-Host "  -Help, -h         Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host '  .\bcscan.ps1 -d "C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons"'
    Write-Host '  .\bcscan.ps1 -Directory "D:\GMod\addons" -OutputFile "backdoor_report.txt"'
    Write-Host ""
}

# Detection patterns (extracted from KVacDoor PHP code)
$BackdoorPatterns = @{
    # Dangerous Lua functions (level 1)
    'RunString' = @{Name = 'RunString Function'; Level = 1}
    'RunStringEx' = @{Name = 'RunStringEx Function'; Level = 1}
    'CompileString' = @{Name = 'CompileString Function'; Level = 1}
    
    # HTTP functions (level 0)
    'http\.Fetch' = @{Name = 'http.Fetch Function'; Level = 0}
    'http\.Post' = @{Name = 'http.Post Function'; Level = 0}
    'HTTP' = @{Name = 'HTTP Function'; Level = 0}
    
    # Specific backdoor panels (level 3)
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

# Function to get emoji based on danger level
function Get-DangerEmoji {
    param([int]$Level)
    
    switch ($Level) {
        0 { return "[SUSPECT]" }
        1 { return "[DANGER]" }
        3 { return "[CRITICAL]" }
        default { return "[UNKNOWN]" }
    }
}

# Function to get color based on level
function Get-ColorByLevel {
    param([int]$Level)
    
    switch ($Level) {
        0 { return "Yellow" }
        1 { return "Magenta" }
        3 { return "Red" }
        default { return "White" }
    }
}

# Function to initialize report file
function Initialize-Report {
    param([string]$FilePath, [string]$ScanDirectory)
    
    $reportContent = @"
================================================================================
                          BCSCAN - SCAN REPORT
================================================================================
Scan date: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
Scanned folder: $ScanDirectory
Script version: $VERSION
OS: $($env:OS) - PowerShell $($PSVersionTable.PSVersion)

================================================================================
                              SCAN RESULTS
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
            
            # Console display
            Write-Host "[INFECTED] $relativePath" -ForegroundColor Red
            
            # Add to report
            Add-Content -Path $OutputFile -Value "INFECTED FILE: $relativePath" -Encoding UTF8
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
        Write-Host "[ERROR] Cannot read: $relativePath" -ForegroundColor Yellow
        return $false
    }
}

# Function to recursively scan a directory
function Scan-Directory {
    param([string]$DirectoryPath)
    
    Write-Host "Starting scan of: $DirectoryPath" -ForegroundColor Blue
    Write-Host ""
    
    # Count total number of .lua files
    try {
        $luaFiles = Get-ChildItem -Path $DirectoryPath -Filter "*.lua" -Recurse -File -ErrorAction Stop
        $script:TotalFiles = $luaFiles.Count
    }
    catch {
        Write-Host "Error accessing folder: $_" -ForegroundColor Red
        exit 1
    }
    
    if ($script:TotalFiles -eq 0) {
        Write-Host "No .lua files found in specified folder." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Total .lua files to scan: $($script:TotalFiles)" -ForegroundColor Blue
    Write-Host ""
    
    # Initialize report
    Initialize-Report -FilePath $OutputFile -ScanDirectory $DirectoryPath
    
    $currentFile = 0
    
    # Scan all .lua files
    foreach ($file in $luaFiles) {
        $currentFile++
        $percentage = [math]::Round(($currentFile / $script:TotalFiles) * 100, 1)
        
        Write-Progress -Activity "Scanning..." -Status "File $currentFile/$($script:TotalFiles) ($percentage%)" -PercentComplete $percentage
        
        Scan-File -FilePath $file.FullName -BasePath $DirectoryPath
    }
    
    Write-Progress -Activity "Scanning..." -Completed
}

# Function to generate final summary
function Generate-Summary {
    $cleanFiles = $script:TotalFiles - $script:InfectedFiles
    $infectionRate = if ($script:TotalFiles -gt 0) { 
        [math]::Round(($script:InfectedFiles / $script:TotalFiles) * 100, 2) 
    } else { 
        0 
    }
    
    # Add summary to report
    $summaryContent = @"

================================================================================
                               SCAN SUMMARY
================================================================================
Files analyzed: $($script:TotalFiles)
Infected files: $($script:InfectedFiles)
Clean files: $cleanFiles
Total detections: $($script:TotalDetections)

Infection rate: $infectionRate%

================================================================================
                          END OF SCAN REPORT
================================================================================
"@
    
    Add-Content -Path $OutputFile -Value $summaryContent -Encoding UTF8
    
    # Display summary in console
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host "              SCAN SUMMARY" -ForegroundColor Blue
    Write-Host "================================================" -ForegroundColor Blue
    Write-Host "Files analyzed: $($script:TotalFiles)" -ForegroundColor Green
    Write-Host "Infected files: $($script:InfectedFiles)" -ForegroundColor Red
    Write-Host "Clean files: $cleanFiles" -ForegroundColor Green
    Write-Host "Total detections: $($script:TotalDetections)" -ForegroundColor Yellow
    Write-Host ""
    
    if ($script:InfectedFiles -gt 0) {
        Write-Host "WARNING: Backdoors have been detected!" -ForegroundColor Red
        Write-Host "Check the full report: $OutputFile" -ForegroundColor Yellow
    } else {
        Write-Host "SUCCESS: No backdoors detected! Your addons appear to be clean." -ForegroundColor Green
    }
    
    Write-Host ""
}

# Main function
function Main {
    # Check for help
    if ($Help) {
        Show-Help
        return
    }
    
    Write-Header
    
    # Check prerequisites
    if (-not $Directory) {
        Write-Host "Error: You must specify a folder to scan with -Directory" -ForegroundColor Red
        Write-Host ""
        Show-Help
        return
    }
    
    if (-not (Test-Path -Path $Directory)) {
        Write-Host "Error: Folder '$Directory' does not exist." -ForegroundColor Red
        return
    }
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "Warning: This script requires PowerShell 5.0 or higher" -ForegroundColor Yellow
    }
    
    # Start scan
    Write-Host "Configuration:" -ForegroundColor Green
    Write-Host "  Folder to scan: " -NoNewline -ForegroundColor White
    Write-Host $Directory -ForegroundColor Yellow
    Write-Host "  Report file: " -NoNewline -ForegroundColor White
    Write-Host $OutputFile -ForegroundColor Yellow
    Write-Host ""
    
    $startTime = Get-Date
    
    try {
        Scan-Directory -DirectoryPath $Directory
        Generate-Summary
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-Host "Scan completed successfully!" -ForegroundColor Blue
        Write-Host "Scan duration: $($duration.ToString('mm\:ss'))" -ForegroundColor Cyan
        Write-Host "Report saved: $OutputFile" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during scan: $_" -ForegroundColor Red
    }
}

# Execute main script
Main