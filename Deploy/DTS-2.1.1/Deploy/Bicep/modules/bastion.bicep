param DeployObject object 
param SolutionObj object
param tags object

@description('Azure region for Bastion and virtual network')
param location string = resourceGroup().location

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
	name: '${SolutionObj.bastionName}-pip'
	location: location
	tags: tags
	sku: {
	name: 'Standard'
	}
	properties: {
	publicIPAllocationMethod: 'Static'
	}
}


resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
	name: DeployObject.VirtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
	parent: existingVirtualNetwork
	name: SolutionObj.bastionSubnetName
}
//*/


resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
	name: SolutionObj.bastionName
	location: location
	properties: {
	ipConfigurations: [
		{
		name: 'IpConf'
		properties: {
			subnet: {
			id: subnet.id
			}
			publicIPAddress: {
			id: publicIp.id
			}
		}
		}
	]
	}
	//dependsOn:[existingVirtualNetwork]
}//bastionHost

output subnetId string = subnet.id
output bastionAddressPrefix string = subnet.properties.addressPrefix
output bastionSubnetName string = subnet.name