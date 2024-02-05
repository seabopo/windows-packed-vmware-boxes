
#packer plugins install github.com/hashicorp/azure
#packer plugins install github.com/hashicorp/vmware
#packer plugins install github.com/hashicorp/vsphere
#packer plugins install github.com/hashicorp/vagrant

Set-Location -Path $PSScriptRoot

Clear-Variable PKR_VAR_* -Scope Global

$build = @{ localvm = $false; localbox = $true; vsphere = $false }

# packer init .\windows_10.pkr.hcl

if ( $build.localvm ) {

    packer build -only="vmware-iso.windows-10-vm" .\windows_10.pkr.hcl

}

if ( $build.localbox ) {

    packer build -only="vmware-iso.windows-10-box" .\windows_10.pkr.hcl

}

if ( $build.vsphere ) {

    packer build -var-file="windows_10_vsphere.pkrvars.hcl" -only="vsphere-iso.windows-10" .\windows_10.pkr.hcl

}