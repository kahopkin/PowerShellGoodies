 Get-AzResource -ResourceType Microsoft.Web/sites | Select Name


Get-AzRoleAssignment | Format-Table | Select RoleAssignmentName, RoleAssignmentId, RoleDefinitionName, Scope   > AzRoleAssignmentsTable

Get-AzRoleDefinition | Format-Table -AutoSize -Property Name, Id, IsCustom > AzRoleDefinitions_JAI

Get-AzRoleDefinition | Format-Table -AutoSize -Wrap -Property  Name, Id > AzRoleDefinitions_JAI
Get-AzRoleDefinition | Format-Table -AutoSize -Wrap -Property  Name, Id > AzRoleDefinitions_Commercial


Get-AzRoleDefinition | Format-Table -AutoSize -Property Name, Id, IsCustom > AzRoleDefinitions_Commercial

Get-AzRoleDefinition -Name Contributor

Get-AzRoleDefinition -Name Contributor | Select Id

$RoleAssignmentName = "Key Vault Crypto Service Encryption User"
$CustomRole = Get-AzRoleDefinition -ErrorVariable notPresent -ErrorAction SilentlyContinue | ? {$_.Name -eq $RoleAssignmentName}

Get-AzPolicyDefinition | Select -ExpandProperty "Properties" | ConvertTo-Csv  > C:\GitHub\dtpResources\AZ-Exports\bmtn\bmtnAzPolicyDefinitions.csv

$AzPolicyDefinitions =  Get-AzPolicyDefinition -SubscriptionId $SubscriptionId -Builtin | Select -ExpandProperty "Properties"

Get-AzPolicyDefinition -SubscriptionId $SubscriptionId -Builtin | ? {$_.Name -eq $RoleAssignmentName}

Get-AzPolicyDefinition | Select -ExpandProperty "Properties" | Select -ExpandProperty "displayName" | Format-Table -AutoSize > AzPolicyDefinition
Get-AzPolicyDefinition | Select -ExpandProperty "Properties" | Select-Object "displayName" | Format-Table -AutoSize > AzPolicyDefinition

#Get all built-in policy definitions from subscription
$SubscriptionId= '093847b0-f0dd-428f-a0b0-bd4245b99339'
#BMTN:
$SubscriptionId= '2b2df691-421a-476f-bfb6-7b7e008d6041'
Get-AzPolicyDefinition -SubscriptionId $SubscriptionId -Builtin | Select -ExpandProperty "Properties" | Format-Table -AutoSize > BuiltInRoles


Get-AzRoleAssignment -ResourceGroupName exampleRG



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


Get-AzPrivateEndpoint -ResourceGroupName $ResourceGroupName -ExpandResource networkinterfaces$StartTime= "09/28/2022 15:12:15"
$EndTime= "09/28/2022 15:20:52"

$Duration= New-TimeSpan -Start $StartTime -End $EndTime
Write-Output "Time difference is: $Duration"

$GeographyGroupArr = Get-AzLocation | select GeographyGroup | Sort-Object -Property  GeographyGroup 
$geoGroupArr = $( foreach ($geoGroup in $GeographyGroupArr) {
            $geoGroup.GeographyGroup}) | Sort-Object | Get-Unique
$i=0
foreach($group in $geoGroupArr){
    Write-Host "[ $i ] : $group "
    $i++
}

 Write-Host "[ X ] : Cancel and Quit"  

$geoGroupArr[$geoGroup]

 $GeographyGroupArr | Where-Object -Property Name -Contains '$geoGroupArr[$geoGroup]'
 $GeographyGroupArr | Where-Object { $_.GeographyGroup -eq '$geoGroupArr[$geoGroup]' } 


 Get-AzLocation | select Location, DisplayName, GeographyGroup| Where-Object { $_.GeographyGroup -eq 'US' } | Sort-Object -Property DisplayName




 Get-AzADUser -SignedIn

  $sites = Get-AzResource -ResourceType Microsoft.Web/sites -Name datatransfer

$Environment = Get-azEnvironment 

# Get Azure WebApps across all resource groups in your Subscription
$siteNames = Get-AzWebApp
# Get Azure WebApp Slots across all resource groups in your Subscription
$slotNames = Get-AzWebApp | Get-AzWebAppSlot
# Combine the result
$result = $siteNames + $slotNames
# Extract necessary properties from the result
$result | Format-Table -Property Name, Type, ResourceGroup, DefaultHostName