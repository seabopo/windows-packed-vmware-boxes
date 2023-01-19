
variable "autounattend" {
  type    = string
  default = "answer_files/w10/autounattend.xml"
}

variable "unattend" {
  type    = string
  default = "answer_files/w10/unattend.xml"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:69efac1df9ec8066341d8c9b62297ddece0e6b805533fdb6dd66bc8034fba27a" # Eval
 #default = "sha256:4B48A6283090191CDCF70F2446C63FDEC3975EF2576F6396DAE9C12CCC1D19E8" # MSDN Win10 consumer 21H2 Nov 2022
 #default = "sha256:6169B0C340FF47EC06410E7E575F8E76A2B0C4B844E07A2B49838BF7BDCB7F68" # MSDN Win10 consumer 22H2 Nov 2022
 #default = "sha256:DEDB0432E7A5186498797200B43E02057D762B20A48B2E39BB476ED75572565A" # MSDN Win10 business 21H2 Nov 2022
 #default = "sha256:BA1C32F0BDA69022A4843F05C91B90DB8DCA6EC13123D1CF7C8160828128BD64" # MSDN Win10 business 22H2 Nov 2022
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/sg/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
 #default = "images/iso/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
 #default = "images/iso/en-us_windows_10_consumer_editions_version_21h2_updated_nov_2022_x64_dvd_4456b6a1.iso"
 #default = "images/iso/en-us_windows_10_business_editions_version_21h2_updated_nov_2022_x64_dvd_645af6dc.iso"
 #default = "images/iso/en-us_windows_10_consumer_editions_version_22h2_updated_nov_2022_x64_dvd_7fd29387.iso"
 #default = "images/iso/en-us_windows_10_business_editions_version_22h2_updated_nov_2022_x64_dvd_e8577df7.iso"
}

variable "vm_name" {
  type    = string
  default = "W10e_21h2"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type    = string
  default = "81920"
}

variable "restart_timeout" {
  type    = string
  default = "15m"
}

variable "winrm_timeout" {
  type    = string
  default = "2h"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "vmware-iso" "windows-10" {

  iso_checksum                    = "${var.iso_checksum}"
  iso_url                         = "${var.iso_url}"
  output_directory                = "images/vmx/${var.vm_name}"

  floppy_files                    = [
                                      "${var.autounattend}",
                                      "${var.unattend}",
                                      "scripts/disable-screensaver.ps1",
                                      "scripts/sysprep.bat",
                                      "scripts/disable-winrm.ps1",
                                      "scripts/enable-winrm.ps1",
                                      "scripts/enable-updates.bat",
                                      "scripts/install-updates.ps1",
                                      "scripts/install-system-tools.bat",
                                      "files/PinTo10.exe"
                                    ]

  version                         = "14"
  vm_name                         = "${var.vm_name}"
  guest_os_type                   = "windows9-64"
  headless                        = "false"
  boot_wait                       = "2m"

  cpus                            = "${var.cpus}"
  memory                          = "${var.memory}"

  disk_adapter_type               = "lsisas1068"
  disk_size                       = "${var.disk_size}"
  disk_type_id                    = "0"

  vnc_port_max                    = 5980
  vnc_port_min                    = 5900
  vmx_data = {
    "RemoteDisplay.vnc.enabled"   = "false"
    "RemoteDisplay.vnc.port"      = "5900"
  }

  communicator                    = "winrm"
  winrm_username                  = "vagrant"
  winrm_password                  = "vagrant"
  winrm_timeout                   = "${var.winrm_timeout}"

  shutdown_command                = "a:/sysprep.bat"
  vmx_remove_ethernet_interfaces  = true
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build

build {
  sources = ["source.vmware-iso.windows-10"]

  provisioner "powershell" {
    scripts = ["scripts/install-vm-guest-tools.ps1"]
  }

  provisioner "windows-restart" {
    restart_timeout = "${var.restart_timeout}"
  }

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    scripts         = [
                        "scripts/enable-automatic-winrm.bat",
                        "scripts/install-system-tools.bat",
                        "scripts/compile-dotnet-assemblies.bat",
                        "scripts/compact.bat"
                      ]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = "images/box/${var.vm_name}_vmware.box"
    vagrantfile_template = "vagrant_windows_10.template"
  }
}
