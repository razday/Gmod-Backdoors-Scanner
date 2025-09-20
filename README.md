# BCScan - Windows Guide

## 🚀 Installation and Usage on Windows

### Method 1: Simple usage with .bat file (RECOMMENDED)

1. **Double-click** on `run_scanner_en.bat`
2. **Enter the path** to your GMod addons folder
3. **Wait** for the scan to complete
4. **Check** the automatically generated report

**Typical path examples:**
```
C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons
D:\Games\Steam\steamapps\common\GarrysMod\garrysmod\addons
```

### Method 2: Direct PowerShell usage

1. **Open PowerShell** (right-click Start menu → Windows PowerShell)
2. **Navigate** to the folder containing the script:
   ```powershell
   cd "C:\Users\eliott\Downloads\kvacdoor-main"
   ```
3. **Execute** the scanner:
   ```powershell
   .\gmod_backdoor_scanner.ps1 -Directory "C:\path\to\addons"
   ```

### Method 3: With advanced parameters

```powershell
# Scan with custom report
.\gmod_backdoor_scanner.ps1 -d "C:\GMod\addons" -o "my_report.txt"

# Show help
.\gmod_backdoor_scanner.ps1 -Help
```

## 🔧 Windows Troubleshooting

### "Execution Policy" Error
If you get an execution policy error:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```


### Paths with spaces
Use quotes for paths containing spaces:
```powershell
.\gmod_backdoor_scanner.ps1 -Directory "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons"
```

## 📊 Windows Output Example

```
================================================
        BCScan v1.0.0
================================================

Configuration:
  Folder to scan: C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
  Report file: scan_results.txt

Starting scan of: C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
Total .lua files to scan: 1247

[INFECTED] addon_suspect\lua\autorun\server\init.lua
  [CRITICAL] KVacDoor Panel (Level: 3)
  [SUSPECT] http.Fetch Function (Level: 0)

[CLEAN] addon_clean\lua\init.lua
[INFECTED] other_addon\lua\backdoor.lua
  [CRITICAL] Omega Panel (Level: 3)

================================================
              SCAN SUMMARY
================================================
Files analyzed: 1247
Infected files: 2
Clean files: 1245
Total detections: 3

WARNING: Backdoors have been detected!
Check the full report: scan_results.txt

Scan completed successfully!
Scan duration: 02:34
Report saved: scan_results.txt
```



## ⚡ Windows Version Advantages

✅ **Graphical interface** - Windows progress bar  
✅ **Native integration** - Works with pre-installed PowerShell  
✅ **Easy double-click** - Usage via .bat file  
✅ **Timestamped reports** - Automatic filename generation  
✅ **Space handling** - Windows paths with spaces supported  
✅ **UTF-8 encoding** - Special character support  

## 🛡️ Security

The script:
- **Does not modify any files** - Read-only
- **Stays local** - No internet connection
- **Open source** - Readable and modifiable code
- **No data sent** - Everything stays on your PC

## 📞 Support

In case of problems:
1. Check that PowerShell is installed (Windows 10/11 have it by default)
2. Use the .bat file for simplified usage  
3. Check paths (use quotes for spaces)