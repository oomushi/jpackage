// Variabili
variable "vm_name" {
  type    = string
  default = "windows-11-custom"
}

// !!! MODIFICA: Inserisci il percorso al tuo file ISO di Windows 11
variable "iso_path" {
  type    = string
  default = "./Win11_25H2_Italian_x64.iso" 
}

// Credenziali per l'installazione (definite in Autounattend.xml)
variable "win_user" {
  type    = string
  default = "vagrant" 
}

variable "win_password" {
  type    = string
  default = "VagrantPassword123" 
}


// Definizione della sorgente (Builder) VirtualBox
source "virtualbox-iso" "win11" {
  vm_name           = var.vm_name
  guest_os_type     = "Windows11_64"
  iso_url           = var.iso_path
  
  // !!! MODIFICA: Sostituisci con l'hash SHA256 esatto del tuo ISO
  iso_checksum      = "sha256:TODO_REPLACE_WITH_YOUR_ISO_CHECKSUM" 

  // File di risposta non assistita e cartella degli strumenti
  floppy_files      = ["Autounattend.xml", "scripts"] // Il "floppy" è mappato come unità temporanea

  // Requisiti hardware minimi per Windows 11
  cpus              = 4
  memory            = 4096 
  disk_size         = 80000 // 80 GB in MB

  // Comunicazione tramite WinRM (necessaria dopo l'installazione base)
  communicator      = "winrm"
  winrm_username    = var.win_user
  winrm_password    = var.win_password
  winrm_timeout     = "5m"
  
  // Sequenza di boot per l'avvio dall'ISO
  // Questa sequenza è una stima e potrebbe richiedere aggiustamenti
  boot_wait         = "10s"
  boot_command      = ["<f12><enter>", "<wait2s>", "<f12><enter>", "<wait2s>", "<enter>"]
}

// Processo di Build
build {
  sources = [source.virtualbox-iso.win11]

  // PRIMO Provisioner: Configurazione di base (es. WinRM, Guest Additions)
  // Questo script è cruciale per la comunicazione.
  provisioner "shell" {
    // Il file viene copiato tramite floppy_files e il Provisioner lo esegue
    execute_command = "powershell -ExecutionPolicy ByPass -File \"C:/Windows/System32/Temp/install-base.ps1\""
    scripts         = ["scripts/install-base.ps1"]
  }
  
  // SECONDO Provisioner: Installazione del software richiesto
  provisioner "shell" {
    execute_command = "powershell -ExecutionPolicy ByPass -File \"C:/Windows/System32/Temp/install-software.ps1\""
    scripts         = ["scripts/install-software.ps1"]
  }

  // Post-Processor: Crea la Vagrant Box
  post-processor "vagrant" {
    output = "${var.vm_name}.box"
  }
}

