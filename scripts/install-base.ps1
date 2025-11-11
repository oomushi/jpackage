# Imposta l'esecuzione con le Guest Additions di VirtualBox
$ErrorActionPreference = "Stop"

# --- 1. CONFIGURAZIONE WINRM ---
# Abilita WinRM se non è già attivo (dovrebbe esserlo, ma è una sicurezza in più)
Write-Host "Configurazione WinRM..."
winrm quickconfig -q

# Abilita l'accesso WinRM da qualsiasi host (necessario per Packer)
winrm set winrm/config/service/Auth @{Basic="true"}
winrm set winrm/config/service/Auth @{CredSSP="true"}
winrm set winrm/config/service/Auth @{Kerberos="true"}
winrm set winrm/config/service/Auth @{Negotiate="true"}
winrm set winrm/config/service/Auth @{Cim="true"}

# Consenti la connessione WinRM da qualsiasi IP (necessario per VirtualBox NAT/Host-Only)
winrm set winrm/config/Listener?Address=*+Transport=HTTP @{UrlPrefix="wsman"}
netsh advfirewall firewall add rule name="WinRM-inbound" dir=in action=allow protocol=TCP localport=5985

# --- 2. CONFIGURAZIONE UTENTE VAGRANT ---
Write-Host "Configurazione utente Vagrant..."
# Non richiedere password per la connessione (migliora l'affidabilità di WinRM)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1

# --- 3. PULIZIA E DISABILITAZIONE ---
Write-Host "Pulizia del sistema e disabilitazione OOBE..."

# Disabilita UAC per l'utente Vagrant
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# Imposta la rete come 'privata' per evitare blocchi
Set-NetConnectionProfile -InterfaceIndex (Get-NetAdapter).InterfaceIndex -NetworkCategory Private

# --- 4. Installazione Guest Additions di VirtualBox ---
# Questo script si aspetta che Packer abbia montato l'ISO delle Guest Additions
Write-Host "Installazione VirtualBox Guest Additions..."
$MountDrive = Get-Volume | Where-Object { $_.FileSystemLabel -eq "VBox_Gas" } | Select-Object -ExpandProperty DriveLetter
$VBoxInstaller = "$($MountDrive):\VBoxWindowsAdditions.exe"

if (Test-Path $VBoxInstaller) {
    # /s è il flag per l'installazione silenziosa
    Start-Process -FilePath $VBoxInstaller -ArgumentList "/S" -Wait
    Write-Host "Guest Additions installate."
} else {
    Write-Host "ATTENZIONE: VBoxWindowsAdditions.exe non trovato. Potrebbe causare problemi."
}

# Riavvia alla fine. Questo è CRUCIALE per applicare Guest Additions e WinRM.
# Packer si riconnetterà automaticamente dopo il riavvio.
Write-Host "Riavvio in corso..."
Restart-Computer -Force

