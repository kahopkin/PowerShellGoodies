<#
Add a NIC to an existing VM
To add a virtual NIC to an existing VM, you deallocate the VM, add the virtual NIC, then start the VM
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/multiple-nics?toc=%2Fazure%2Fvirtual-network%2Ftoc.json
#>

#Deallocate the VM with Stop-AzVM. The following example deallocates the VM named myVM in myResourceGroup:
Stop-AzVM -Name "myVM" -ResourceGroupName "myResourceGroup"

#Get the existing configuration of the VM with Get-AzVm. The following example gets information for the VM named myVM in myResourceGroup:

$vm = Get-AzVm -Name "myVM" -ResourceGroupName "myResourceGroup"
#The following example creates a virtual NIC with New-AzNetworkInterface named myNic3 that is attached to mySubnetBackEnd.
#The virtual NIC is then attached to the VM named myVM in myResourceGroup with Add-AzVMNetworkInterface:

# Get info for the back end subnet
$myVnet = Get-AzVirtualNetwork -Name "myVnet" -ResourceGroupName "myResourceGroup"
$backEnd = $myVnet.Subnets|?{$_.Name -eq 'mySubnetBackEnd'}

# Create a virtual NIC
$myNic3 = New-AzNetworkInterface -ResourceGroupName "myResourceGroup" `
    -Name "myNic3" `
    -Location "EastUs" `
    -SubnetId $backEnd.Id

# Get the ID of the new virtual NIC and add to VM
$nicId = (Get-AzNetworkInterface -ResourceGroupName "myResourceGroup" -Name "MyNic3").Id
Add-AzVMNetworkInterface -VM $vm -Id $nicId | Update-AzVm -ResourceGroupName "myResourceGroup"

<#
One of the NICs on a multi-NIC VM needs to be primary. 
If one of the existing virtual NICs on the VM is already set as primary, you can skip this step. 
The following example assumes that two virtual NICs are now present on a VM and you wish to add the first NIC ([0]) as the primary:
#>
# List existing NICs on the VM and find which one is primary
$vm.NetworkProfile.NetworkInterfaces

# Set NIC 0 to be primary
$vm.NetworkProfile.NetworkInterfaces[0].Primary = $true
$vm.NetworkProfile.NetworkInterfaces[1].Primary = $false

# Update the VM state in Azure
Update-AzVM -VM $vm -ResourceGroupName "myResourceGroup"

#Start the VM with Start-AzVm:

Start-AzVM -ResourceGroupName "myResourceGroup" -Name "myVM"