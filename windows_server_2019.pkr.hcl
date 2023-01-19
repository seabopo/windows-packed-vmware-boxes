
variable "autounattend" {
  type    = string
  default = "answer_files/2019/autounattend.xml"
}

variable "unattend" {
  type    = string
  default = "answer_files/2019/unattend.xml"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
 #default = "images/iso/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
}

variable "vm_name" {
  type    = string
  default = "WS2019"
}

variable "cpus" {
  type    = string
  default = "4"
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
  default = "10m"
}

variable "winrm_timeout" {
  type    = string
  default = "1h"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "vmware-iso" "windows-server-2019" {

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
                                      "scripts/install-system-tools.bat"
                                    ]

  version                         = "14"
  vm_name                         = "${var.vm_name}"
  guest_os_type                   = "windows9srv-64"
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
  sources = ["source.vmware-iso.windows-server-2019"]

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
    vagrantfile_template = "vagrant_windows_server_2019.template"
  }
}
