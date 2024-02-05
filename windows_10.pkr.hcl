#----------------------------------------
# Variables
#----------------------------------------

variable "autounattend" {
  type    = string
  default = "answer_files/w10/updates/autounattend.xml"
}

variable "autounattend_noupdates" {
  type    = string
  default = "answer_files/w10/noupdates/autounattend.xml"
}

variable "unattend" {
  type    = string
  default = "answer_files/w10/unattend.xml"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:EF7312733A9F5D7D51CFA04AC497671995674CA5E1058D5164D6028F0938D668"
}

variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "vm_name" {
  type    = string
  default = "W10e_22h2_020324"
}

variable "cpus" {
  type    = string
  default = "4"
}

variable "cores" {
  type    = string
  default = "4"
}

variable "memory" {
  type    = string
  default = "8192"
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

variable "ipwait_timeout" {
  type    = string
  default = "2h"
}

variable "vcenter_server_name" {
  type    = string
  default = ""
}

variable "vcenter_server_host" {
  type    = string
  default = ""
}

variable "vcenter_server_username" {
  type    = string
  default = ""
}

variable "vcenter_server_password" {
  type    = string
  default = ""
}

variable "vcenter_server_insecure" {
  type    = string
  default = true
}

#----------------------------------------
# Packer Config
#----------------------------------------

packer {
  required_version = ">= 1.8.6"
  required_plugins {
    azure = {
      version = ">= v2.0.2"
      source  = "github.com/hashicorp/azure"
    }
    vmware = {
      version = ">= v1.0.11"
      source  = "github.com/hashicorp/vmware"
    }
    vsphere = {
      version = ">= v1.2.4"
      source  = "github.com/hashicorp/vsphere"
    }
    vagrant = {
      version = ">= v1.1.2"
      source  = "github.com/hashicorp/vagrant"
    }
    // windows-update = {
    //   version = ">= 0.14.1"
    //   source  = "github.com/rgl/windows-update"
    // }
  }
}

#----------------------------------------
# VMware Workstation VM
#----------------------------------------
# https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

source "vmware-iso" "windows-10-vm" {

  iso_checksum                    = "${var.iso_checksum}"
  iso_url                         = "${var.iso_url}"
  output_directory                = "images/vmx/${var.vm_name}-vm"

  floppy_files                    = [
                                      "${var.autounattend_noupdates}",
                                      "${var.unattend}",
                                      "scripts/disable-screensaver.ps1",
                                      "scripts/sysprep.bat",
                                      "scripts/disable-winrm.ps1",
                                      "scripts/enable-winrm.ps1",
                                      "scripts/enable-updates.bat",
                                      "scripts/install-updates.ps1",
                                      "scripts/install-system-tools.bat",
                                      "scripts/install-vm-guest-tools-norestart.ps1",
                                      "files/pvscsi_win864/pvscsi.cat",
                                      "files/pvscsi_win864/pvscsi.inf",
                                      "files/pvscsi_win864/pvscsi.sys",
                                      "files/pvscsi_win864/txtsetup.oem"
                                    ]

  version                         = "19"
  vm_name                         = "${var.vm_name}"
  guest_os_type                   = "windows9-64"
  headless                        = "false"
  boot_wait                       = "2m"

  cpus                            = "${var.cpus}"
  cpu_cores                       = "${var.cores}"
  memory                          = "${var.memory}"

  disk_adapter_type               = "lsisas1068"
  disk_size                       = "${var.disk_size}"
  disk_type_id                    = "0"

  communicator                    = "winrm"
  winrm_username                  = "vagrant"
  winrm_password                  = "vagrant"
  winrm_timeout                   = "${var.winrm_timeout}"

  shutdown_command                = "a:/sysprep.bat"
  vmx_remove_ethernet_interfaces  = true
}

#----------------------------------------
# Local Vagrant Box File
#----------------------------------------
# https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

source "vmware-iso" "windows-10-box" {

  iso_checksum                    = "${var.iso_checksum}"
  iso_url                         = "${var.iso_url}"
  output_directory                = "images/vmx/${var.vm_name}"

  floppy_files                    = [
                                      "${var.autounattend_noupdates}",
                                      "${var.unattend}",
                                      "scripts/disable-screensaver.ps1",
                                      "scripts/sysprep.bat",
                                      "scripts/disable-winrm.ps1",
                                      "scripts/enable-winrm.ps1",
                                      "scripts/enable-updates.bat",
                                      "scripts/install-updates.ps1",
                                      "scripts/install-system-tools.bat",
                                      "scripts/install-vm-guest-tools-norestart.ps1",
                                      "files/pvscsi_win864/pvscsi.cat",
                                      "files/pvscsi_win864/pvscsi.inf",
                                      "files/pvscsi_win864/pvscsi.sys",
                                      "files/pvscsi_win864/txtsetup.oem"
                                    ]

  version                         = "19"
  vm_name                         = "${var.vm_name}-box"
  guest_os_type                   = "windows9-64"
  headless                        = "false"
  boot_wait                       = "2m"

  cpus                            = "${var.cpus}"
  cpu_cores                       = "${var.cores}"
  memory                          = "${var.memory}"

  disk_adapter_type               = "lsisas1068"
  disk_size                       = "${var.disk_size}"
  disk_type_id                    = "0"

  // vnc_port_max                    = 5980
  // vnc_port_min                    = 5900
  // vmx_data = {
  //   "RemoteDisplay.vnc.enabled"   = "false"
  //   "RemoteDisplay.vnc.port"      = "5900"
  // }

  communicator                    = "winrm"
  winrm_username                  = "vagrant"
  winrm_password                  = "vagrant"
  winrm_timeout                   = "${var.winrm_timeout}"

  shutdown_command                = "a:/sysprep.bat"
  vmx_remove_ethernet_interfaces  = true
}

#----------------------------------------
# VSphere Config
#----------------------------------------
# https://developer.hashicorp.com/packer/integrations/hashicorp/vsphere/latest/components/builder/vsphere-iso

source "vsphere-iso" "windows-10" {

  vcenter_server                  = var.vcenter_server_name
  host                            = "${var.vcenter_server_host}"
  username                        = "${var.vcenter_server_username}"
  password                        = "${var.vcenter_server_password}"
  insecure_connection             = "${var.vcenter_server_insecure}"

  iso_checksum                    = "${var.iso_checksum}"
  iso_url                         = "${var.iso_url}"

  floppy_files                    = [
                                      "${var.autounattend_noupdates}",
                                      "${var.unattend}",
                                      "scripts/disable-screensaver.ps1",
                                      "scripts/sysprep.bat",
                                      "scripts/disable-winrm.ps1",
                                      "scripts/enable-winrm.ps1",
                                      "scripts/enable-updates.bat",
                                      "scripts/install-updates.ps1",
                                      "scripts/install-system-tools.bat",
                                      "scripts/install-vm-guest-tools-norestart.ps1",
                                      "files/pvscsi_win864/pvscsi.cat",
                                      "files/pvscsi_win864/pvscsi.inf",
                                      "files/pvscsi_win864/pvscsi.sys",
                                      "files/pvscsi_win864/txtsetup.oem"
                                    ]

 #vm_version                      = "11"
  vm_name                         = "${var.vm_name}"
  guest_os_type                   = "windows9_64Guest"
  boot_wait                       = "2m"

# CPUs is NOT processors! Processors = CPUs/Cores
# 4 CPUs & 4 Cores = 1 Processor with 4 cores.
  CPUs                            = "${var.cpus}"
  cpu_cores                       = "${var.cores}"
  RAM                             = "${var.memory}"

  datastore                       = "ESXi-36-LUN-1"
  disk_controller_type            = ["pvscsi"]

  storage {
      disk_size = "${var.disk_size}"
      disk_thin_provisioned = true
  }

  network_adapters {
    network      = "VM Network"
   #network_card = "vmxnet3" # need driver for vmxnet3
  }

  communicator                    = "winrm"
  winrm_username                  = "vagrant"
  winrm_password                  = "vagrant"
  winrm_timeout                   = "${var.winrm_timeout}"
  ip_wait_timeout                 = "${var.ipwait_timeout}"

  #shutdown_command                = "a:/sysprep.bat"

}

#----------------------------------------
# Builder
#----------------------------------------

build {

  sources = ["source.vmware-iso.windows-10-vm","source.vmware-iso.windows-10-box","source.vsphere-iso.windows-10"]

  // provisioner "powershell" {
  //   scripts = ["scripts/install-vm-guest-tools.ps1"]
  // }

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
    only                 = ["vmware-iso.windows-10-box"]
    keep_input_artifact  = true
    output               = "images/box/${var.vm_name}_vmware.box"
    vagrantfile_template = "vagrant_windows_10.template"
  }

}
