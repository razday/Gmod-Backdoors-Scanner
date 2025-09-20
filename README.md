# BCScan - Guide Windows

## 🚀 Installation et Utilisation sur Windows

### Méthode 1: Utilisation simple avec le fichier .bat (RECOMMANDÉ)

1. **Double-cliquez** sur `run_scanner.bat`
2. **Entrez le chemin** vers votre dossier addons GMod
3. **Attendez** que le scan se termine
4. **Consultez** le rapport généré automatiquement

**Exemples de chemins typiques :**
```
C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons
D:\Games\Steam\steamapps\common\GarrysMod\garrysmod\addons
```

### Méthode 2: Utilisation PowerShell directe

1. **Ouvrez PowerShell** (clic droit sur le menu Démarrer → Windows PowerShell)
2. **Naviguez** vers le dossier contenant le script :
   ```powershell
   cd "C:\Users\eliott\Downloads\kvacdoor-main"
   ```
3. **Exécutez** le scanner :
   ```powershell
   .\gmod_backdoor_scanner.ps1 -Directory "C:\chemin\vers\addons"
   ```

### Méthode 3: Avec paramètres avancés

```powershell
# Scan avec rapport personnalisé
.\gmod_backdoor_scanner.ps1 -d "C:\GMod\addons" -o "mon_rapport.txt"

# Afficher l'aide
.\gmod_backdoor_scanner.ps1 -Help
```

## 🔧 Dépannage Windows

### Erreur "Execution Policy"
Si vous obtenez une erreur de politique d'exécution :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```


### Chemin avec espaces
Utilisez des guillemets pour les chemins contenant des espaces :
```powershell
.\gmod_backdoor_scanner.ps1 -Directory "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons"
```

## 📊 Exemple de sortie Windows

```
================================================
        BCScan v1.0.0
================================================

Configuration:
  Dossier à scanner: C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
  Fichier de rapport: scan_results.txt

Démarrage du scan de: C:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons
Nombre total de fichiers .lua à scanner: 1247

[INFECTED] addon_suspect\lua\autorun\server\init.lua
  ⛔ KVacDoor Panel (Niveau: 3)
  🟡 http.Fetch Function (Niveau: 0)

[CLEAN] addon_propre\lua\init.lua
[INFECTED] autre_addon\lua\backdoor.lua
  ⛔ Omega Panel (Niveau: 3)

================================================
              RÉSUMÉ DU SCAN
================================================
Fichiers analysés: 1247
Fichiers infectés: 2
Fichiers propres: 1245
Total détections: 3

⚠️  ATTENTION: Des backdoors ont été détectées!
Consultez le rapport complet: scan_results.txt

Scan terminé avec succès!
Durée du scan: 02:34
Rapport sauvegardé: scan_results.txt
```



## ⚡ Avantages de la version Windows

✅ **Interface graphique** - Barre de progression Windows  
✅ **Intégration native** - Fonctionne avec PowerShell pré-installé  
✅ **Double-clic facile** - Utilisation via fichier .bat  
✅ **Rapports horodatés** - Noms de fichiers automatiques  
✅ **Gestion des espaces** - Chemins Windows avec espaces supportés  
✅ **Encodage UTF-8** - Support des caractères spéciaux  

## 🛡️ Sécurité

Le script :
- **Ne modifie aucun fichier** - Lecture seule
- **Reste local** - Aucune connexion internet
- **Open source** - Code lisible et modifiable
- **Pas de données envoyées** - Tout reste sur votre PC

## 📞 Support

En cas de problème :
1. Vérifiez que PowerShell est installé (Windows 10/11 l'ont par défaut)
2. Utilisez le fichier .bat pour une utilisation simplifiée  
3. Vérifiez les chemins (utilisez des guillemets pour les espaces)