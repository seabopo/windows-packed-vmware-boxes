\
**Introduction**
================
This repo builds sys-prepped Windows Server images (VMX files) for VMware Workstation using HashiCorp Packer 
and exports them to box images for use by HashiCorp Vagrant.

This repo borrows heavily from Stefan Scherer's [Windows Packer](https://github.com/StefanScherer/packer-windows) 
and Eaksel's [packer-Win2019](https://github.com/eaksel/packer-Win2019) projects, focusing specifically on 
Windows Server 2019 and Windows 10 builds for VMware Workstation. 

Changes from Stefan Scherer's Windows Packer project:
1. Only the VMware Workstation images for Windows Server 2019 and Windows 10 are supported. 
1. Windows updates are applied during the iso build process.
1. Windows Updates and Windows Defender are not disabled for the final image.
1. UAC is no longer enabled on Windows Server 2019.
1. The VM Tools code has been replaced with Eaksel's.
1. The native zip function is used so 7zip is no longer installed / used.
1. The 'debloat' scripts are no longer run.
1. Microsoft's [SDelete](https://learn.microsoft.com/en-us/sysinternals/downloads/sdelete) and 
   [AutoLogon](https://learn.microsoft.com/en-us/sysinternals/downloads/autologon) PowerTools are permanently installed.
1. As of Packer version 1.7.0, HCL2 is the preferred way to write Packer templates, so the packer files in this 
   project has been converted from the original JSON files using the **hcl2_upgrade** command.


\
**Prerequisites**
================
- [VMware Workstation](https://www.vmware.com/products/workstation-pro.html)
    - [VMware Fusion](https://www.vmware.com/products/fusion.html) on an Intel Mac should also work but hasn't been
      tested. 
    - If you have an M1 Mac see 
      [this post](https://github.com/hashicorp/vagrant-vmware-desktop/issues/22#issuecomment-956340079) and 
      [this post](https://gist.github.com/sbailliez/f22db6434ac84eccb6d3c8833c85ad92) 
      for instructions on using Vagrant with the 
      [Fusion Tech Preview](https://customerconnect.vmware.com/downloads/get-download?downloadGroup=FUS-PUBTP-2021H1), 
      which is currently the only M1 provider supported by Vagrant
    - [UTM](https://getutm.app/) support for M1 Macs may be on the way according to 
      [this post](https://github.com/hashicorp/vagrant/issues/12518)
- [Packer](https://www.packer.io/downloads.html) 
          ( [Getting Started](https://www.packer.io/intro/getting-started/install.html) ) 
          ( [VMware Builder](https://www.packer.io/plugins/builders/vmware/iso) )
- [Vagrant](https://www.vagrantup.com/) ( [Docs](https://www.vagrantup.com/docs) )


\
**Installation**
================
1. Download and Install the following tools:
    1. [VMware Workstation](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html)
    1. Open the VMware Workstation Network editor (in edit mode) and then save the settings to generate the settings
       file needed by Packer.
    1. [Packer](https://www.packer.io/downloads)
       ( [instructions](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli) )
    1. [Vagrant](https://www.vagrantup.com/downloads) 
       ( [instructions](https://www.vagrantup.com/docs/installation) )
    1. [Vagrant VMware Utility](https://www.vagrantup.com/vmware/downloads) 
       ( [instructions](https://www.vagrantup.com/docs/providers/vmware/installation) )
    1. Run: vagrant plugin install vagrant-vmware-desktop
1. Run `packer init .` from a command prompt in your project directory to initialize Packer and download the VMware builder.


\
**Getting Started**
=======================

The project uses the following evaluation versions of Windows:
- [Windows Server 2019 180-Day Evaluation Image](https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso)
- [Windows 10 Enterprise Evaluation Image](https://software-download.microsoft.com/download/sg/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso)

If you want to use a licensed/activated image you'll need to download your own ISO and update the following items:

  - In "windows_server_2019.pkr.hcl" or "windows_10.pkr.hcl" ...
      ```
      variable "iso_checksum" {
        type    = string
        default = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
      }

      variable "iso_url" {
        type    = string
        default = "./iso/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
      }
      ```
  
- In "./answer_files/<os>/Autounattend.xml" (uncomment after updating).
    ```
    <ProductKey>
        <!-- Do not uncomment the Key element if you are using trial ISOs -->
        <!-- You must uncomment the Key element (and optionally insert your own key) if you are using retail or volume license ISOs -->
        <!-- <Key>6XBNX-4JQGW-QX6QG-74P76-72V67</Key> -->
        <WillShowUI>OnError</WillShowUI>
    </ProductKey>
    ```
 
    
\
**Build and Test**
=======================

Run the `build_ws2019.ps1` or `build_w10.ps1` script to build the sys-prepped VMware Workstation Image and the Vagrant box file.

