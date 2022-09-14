New-AzResourceGroup -Name TestResourceGroup -Location centralus
$frontendSubnet = New-AzVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix "10.0.1.0/24"



$backendSubnet = New-AzVirtualNetworkSubnetConfig -Name backendSubnet -AddressPrefix "10.0.2.0/24"
$backendSubnet ='snet-functionintegration-kat-prod'


$virtualNetwork = New-AzVirtualNetwork -Name MyVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix "10.0.0.0/24" -Subnet $frontendSubnet,$backendSubnet


$vnet = Get-AzVirtualNetwork -Name $virtualNetworkName
Remove-AzVirtualNetworkSubnetConfig -Name $backendSubnet -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

Remove-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $ResourceGroupName



$SubscriptionId='093847b0-f0dd-428f-a0b0-bd4245b99339'

$ResourceGroupName='rg-kat-prod'
$Location = "usgovvirginia"
$virtualNetworkName ='vnet-kat-prod'
$functionintegrationSubnet = 'snet-functionintegration-kat-prod'
az rest --method delete --uri https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$virtualNetworkName/subnets/$functionintegrationSubnet/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default?api-version=2018-10-01



$subnet = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $ResourceGroupName | Get-AzVirtualNetworkSubnetConfig -Name $functionintegrationSubnet
Get-AzDelegation -Name "myDelegation" -Subnet $subnet


DELETE  Service Association
 https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}/subnets/{subnetName}/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default?api-version=2018-10-01

DELETE Network Profle
 https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkProfiles/{networkProfileName}?api-version=2020-05-01  

az rest --method delete --uri https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$virtualNetworkName/subnets/$functionintegrationSubnet/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default?api-version=2018-10-01


az account get-access-token --resource https://management.azure.us/
$SubscriptionId='093847b0-f0dd-428f-a0b0-bd4245b99339'
$ResourceGroupName='rg-kat-prod'
$Location = "usgovvirginia"
$virtualNetworkName ='vnet-kat-prod'
$functionintegrationSubnet = 'snet-functionintegration-kat-prod'

az rest --method delete --uri https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$virtualNetworkName/subnets/$functionintegrationSubnet/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default?api-version=2018-10-01

az rest --method delete --uri https://management.azure.com/subscriptions/093847b0-f0dd-428f-a0b0-bd4245b99339/resourceGroups/rg-kat-prod/providers/Microsoft.Network/virtualNetworks/vnet-kat-prod/subnets/snet-functionintegration-kat-prod/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default?api-version=2018-10-01


Get-AzPrivateEndpoint -ResourceGroupName $ResourceGroupName -ExpandResource networkinterfaces