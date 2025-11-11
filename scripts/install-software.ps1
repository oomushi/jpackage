# Esecuzione in PowerShell all'interno della VM Windows

# Creazione di una directory temporanea
$TempDir = "C:\TempPacker"
if (-not (Test-Path $TempDir)) {
    New-Item -Path $TempDir -ItemType Directory | Out-Null
}

## 1. Installazione di OpenJDK 17 (Eclipse Temurin)
Write-Host "Inizio installazione OpenJDK 17 (Temurin)..."

$JavaInstaller = "$TempDir\jdk-17.msi"
# Utilizziamo l'installer MSI ufficiale di Adoptium (Temurin)
$JavaURL = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B8/OpenJDK17U-jdk_x64_windows_hotspot_17.0.9_8.msi" 

# Scarica l'installer
Invoke-WebRequest -Uri $JavaURL -OutFile $JavaInstaller

# Installa in modalità silenziosa (/qn). ADDLOCAL="ALL" imposta le variabili d'ambiente.
Start-Process -FilePath msiexec -ArgumentList "/i $JavaInstaller /qn /L*V C:\TempPacker\java_install.log INSTALLLEVEL=3 ADDLOCAL=ALL" -Wait

Remove-Item $JavaInstaller -Force

## 2. Installazione di WiX Toolset 3
Write-Host "Inizio installazione WiX Toolset 3..."
$WixInstaller = "$TempDir\wix311.exe"
# Versione 3.11.2, l'ultima della serie 3.x
$WixURL = "https://wixtoolset.org/releases/v3.11.2/wix311.exe" 

# Scarica l'installer
Invoke-WebRequest -Uri $WixURL -OutFile $WixInstaller

# Installa in modalità silenziosa (/passive e /q)
Start-Process -FilePath $WixInstaller -ArgumentList "/install /passive /norestart /q" -Wait

Remove-Item $WixInstaller -Force

Remove-Item $TempDir -Recurse -Force
Write-Host "Installazioni software completate."

