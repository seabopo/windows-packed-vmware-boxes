
#packer plugins install github.com/hashicorp/azure
#packer plugins install github.com/hashicorp/vmware
#packer plugins install github.com/hashicorp/vsphere
#packer plugins install github.com/hashicorp/vagrant

Set-Location -Path $PSScriptRoot

Clear-Variable PKR_VAR_* -Scope Global

$build = @{ local = $true; vsphere = $false }

if ( $build.local ) {

    packer build .\windows_10.pkr.hcl

}

if ( $vsphere.azure ) {

    #$env:PKR_VAR_azure_build_virtual_network_resource_group_name    = 'chpeus2-network-admin-p'
    #$env:PKR_VAR_azure_managed_image_resource_group_name            = 'vm-images-p'

    packer build -var-file="secret.pkrvars.hcl" -only="azure-arm.ubuntu-22-04-lts" .\main.pkr.hcl

}