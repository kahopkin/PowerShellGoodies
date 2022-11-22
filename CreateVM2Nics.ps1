<#
Create a VM with multiple NICs
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/multiple-nics?toc=%2Fazure%2Fvirtual-network%2Ftoc.json
#>

New-AzResourceGroup -Name "myResourceGroup" -Location "EastUS"

# One subnet may be for front-end traffic, the other for back-end traffic. To connect to both subnets, you then use multiple NICs on your VM.
#Define two virtual network subnets with New-AzVirtualNetworkSubnetConfig. The following example defines the subnets for mySubnetFrontEnd and mySubnetBackEnd:
$mySubnetFrontEnd = New-AzVirtualNetworkSubnetConfig -Name "mySubnetFrontEnd" `
    -AddressPrefix "192.168.1.0/24"
$mySubnetBackEnd = New-AzVirtualNetworkSubnetConfig -Name "mySubnetBackEnd" `
    -AddressPrefix "192.168.2.0/24"


#Create your virtual network and subnets with New-AzVirtualNetwork. 
$myVnet = New-AzVirtualNetwork -ResourceGroupName "myResourceGroup" `
    -Location "EastUs" `
    -Name "myVnet" `
    -AddressPrefix "192.168.0.0/16" `
    -Subnet $mySubnetFrontEnd,$mySubnetBackEnd

#Create two NICs with New-AzNetworkInterface. Attach one NIC to the front-end subnet and one NIC to the back-end subnet. 
$frontEnd = $myVnet.Subnets|?{$_.Name -eq 'mySubnetFrontEnd'}
$myNic1 = New-AzNetworkInterface -ResourceGroupName "myResourceGroup" `
    -Name "myNic1" `
    -Location "EastUs" `
    -SubnetId $frontEnd.Id

$backEnd = $myVnet.Subnets|?{$_.Name -eq 'mySubnetBackEnd'}
$myNic2 = New-AzNetworkInterface -ResourceGroupName "myResourceGroup" `
    -Name "myNic2" `
    -Location "EastUs" `
    -SubnetId $backEnd.Id

#build your VM configuration.
$cred = Get-Credential
#Define your VM with New-AzVMConfig. 
$vmConfig = New-AzVMConfig -VMName "myVM" -VMSize "Standard_DS3_v2"

#creates a Windows Server 2016 VM:
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig `
    -Windows `
    -ComputerName "myVM" `
    -Credential $cred `
    -ProvisionVMAgent `
    -EnableAutoUpdate

$vmConfig = Set-AzVMSourceImage -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2016-Datacenter" `
    -Version "latest"

#Attach the two NICs that you previously created with Add-AzVMNetworkInterface:

$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $myNic1.Id -Primary
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $myNic2.Id

#Create your VM with New-AzVM:
New-AzVM -VM $vmConfig -ResourceGroupName "myResourceGroup" -Location "EastUs"

#Add routes for secondary NICs to the OS by completing the steps in Configure the operating system for multiple NICs.