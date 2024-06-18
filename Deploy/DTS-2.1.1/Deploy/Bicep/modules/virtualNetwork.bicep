targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object

//param virtualNetworkObj object

var SolutionName = SolutionObj.SolutionName

var delegations = {
	default: []
	'Microsoft.Web/serverfarms': [
	{
		name: 'delegation'
		properties: {
		serviceName: 'Microsoft.Web/serverfarms'
		}
	}
	]
	'Microsoft.ContainerInstance/containerGroups': [
	{
		name: 'aciDelegation'
		properties: {
		serviceName: 'Microsoft.ContainerInstance/containerGroups'
		}
	}
	]
}


/*
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
	name: SolutionObj.nsgName
	location: location
	tags: tags
}
//*/

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
	name: SolutionObj.nsgName
	location: location
	tags: tags
	properties: {
	securityRules: [
		{
		name: 'AllowHttpsInBound'
		properties: {
			protocol: 'Tcp'
			sourcePortRange: '*'
			sourceAddressPrefix: 'Internet'
			destinationPortRange: '443'
			destinationAddressPrefix: '*'
			access: 'Allow'
			priority: 100
			direction: 'Inbound'
		}
		}
		{
		name: 'AllowGatewayManagerInBound'
		properties: {
			protocol: 'Tcp'
			sourcePortRange: '*'
			sourceAddressPrefix: 'GatewayManager'
			destinationPortRange: '443'
			destinationAddressPrefix: '*'
			access: 'Allow'
			priority: 110
			direction: 'Inbound'
		}
		}
		{
		name: 'AllowLoadBalancerInBound'
		properties: {
			protocol: 'Tcp'
			sourcePortRange: '*'
			sourceAddressPrefix: 'AzureLoadBalancer'
			destinationPortRange: '443'
			destinationAddressPrefix: '*'
			access: 'Allow'
			priority: 120
			direction: 'Inbound'
		}
		}
		{
		name: 'AllowBastionHostCommunicationInBound'
		properties: {
			protocol: '*'
			sourcePortRange: '*'
			sourceAddressPrefix: 'VirtualNetwork'
			destinationPortRanges: [
			'8080'
			'5701'
			]
			destinationAddressPrefix: 'VirtualNetwork'
			access: 'Allow'
			priority: 130
			direction: 'Inbound'
		}
		}
		/*
		{
		name: 'DenyAllInBound'
		properties: {
			protocol: '*'
			sourcePortRange: '*'
			sourceAddressPrefix: '*'
			destinationPortRange: '*'
			destinationAddressPrefix: '*'
			access: 'Deny'
			priority: 1000
			direction: 'Inbound'
		}
		}
		//*/
		{
		name: 'AllowSshRdpOutBound'
		properties: {
			protocol: 'Tcp'
			sourcePortRange: '*'
			sourceAddressPrefix: '*'
			destinationPortRanges: [
			'22'
			'3389'
			]
			destinationAddressPrefix: 'VirtualNetwork'
			access: 'Allow'
			priority: 100
			direction: 'Outbound'
		}
		}
		{
		name: 'AllowAzureCloudCommunicationOutBound'
		properties: {
			protocol: 'Tcp'
			sourcePortRange: '*'
			sourceAddressPrefix: '*'
			destinationPortRange: '443'
			destinationAddressPrefix: 'AzureCloud'
			access: 'Allow'
			priority: 110
			direction: 'Outbound'
		}
		}
		{
		name: 'AllowBastionHostCommunicationOutBound'
		properties: {
			protocol: '*'
			sourcePortRange: '*'
			sourceAddressPrefix: 'VirtualNetwork'
			destinationPortRanges: [
			'8080'
			'5701'
			]
			destinationAddressPrefix: 'VirtualNetwork'
			access: 'Allow'
			priority: 120
			direction: 'Outbound'
		}
		}
		{
		name: 'AllowGetSessionInformationOutBound'
		properties: {
			protocol: '*'
			sourcePortRange: '*'
			sourceAddressPrefix: '*'
			destinationAddressPrefix: 'Internet'
			destinationPortRanges: [
			'80'
			'443'
			]
			access: 'Allow'
			priority: 130
			direction: 'Outbound'
		}
		}
		/*
		{
		name: 'DenyAllOutBound'
		properties: {
			protocol: '*'
			sourcePortRange: '*'
			destinationPortRange: '*'
			sourceAddressPrefix: '*'
			destinationAddressPrefix: '*'
			access: 'Deny'
			priority: 1000
			direction: 'Outbound'
		}
		}
		//*/
	]
	}
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = if(!DeployObject.VirtualNetworkExists){
	name: DeployObject.VirtualNetworkName
	location: location
	tags: tags
	properties:{
	addressSpace:{
		addressPrefixes:[
		SolutionObj.addressPrefix
		]
	}
	 subnets: [for (subnet, i) in SolutionObj.subnets: {
		name: (contains(subnet.name, 'Bastion') || contains(subnet.name, 'GatewaySubnet')) ? subnet.name : 'snet-${subnet.name}-${SolutionObj.SolutionName}'
		properties: ( ! contains(subnet.name, 'GatewaySubnet')) ? {
			 addressPrefix: (SolutionObj.Environment == 'Prod' && contains(subnet.name, 'GatewaySubnet')) ? '${take(DeployObject.AddressPrefix,5)}.1.0/26' : (SolutionObj.Environment == 'Prod' && contains(subnet.name, 'Bastion')) ? '${DeployObject.AddressPrefix}.${i*32}/26' : '${DeployObject.AddressPrefix}.${i*32}/27'
			privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
			 privateLinkServiceNetworkPolicies: 'enabled'
			delegations: (contains(subnet, 'delegations') ? delegations[subnet.delegations] : delegations.default)
			networkSecurityGroup:{
				id: nsg.id
			}
		} : {
			addressPrefix: (SolutionObj.Environment == 'Prod' && contains(subnet.name, 'GatewaySubnet')) ? '${take(DeployObject.AddressPrefix,5)}.1.0/26' : (SolutionObj.Environment == 'Prod' && contains(subnet.name, 'Bastion')) ? '${DeployObject.AddressPrefix}.${i*32}/26' : '${DeployObject.AddressPrefix}.${i*32}/27'
			privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
			 privateLinkServiceNetworkPolicies: 'enabled'
			delegations: (contains(subnet, 'delegations') ? delegations[subnet.delegations] : delegations.default)
		}
		}]
	}
}//virtualNetwork

/*
//original
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
	name: DeployObject.VirtualNetworkName
	location: location
	tags: tags
	properties:{
	addressSpace:{
		addressPrefixes:[
		virtualNetworkObj.addressPrefix
		]
	}
	subnets: [for subnet in virtualNetworkObj.subnets: {
		name: (contains(subnet.name, 'Bastion'))? subnet.name : 'snet-${subnet.name}-${SolutionName}'
		properties: (! contains(subnet.name, 'Bastion')) ? {
		addressPrefix: subnet.ipAddressRange
		privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
		privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
		networkSecurityGroup: {
			id: nsg.id
		}
		delegations: (contains(subnet, 'delegations') ? delegations[subnet.delegations] : delegations.default)
		}:{
		addressPrefix: subnet.ipAddressRange
		privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
		privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
			delegations: (contains(subnet, 'delegations') ? delegations[subnet.delegations] : delegations.default)
		}
	}]
	}
	resource allSubnets 'subnets' existing = [for subnet in virtualNetworkObj.subnets: {
	name: '${subnet.name}-${SolutionName}'
	}]

}//virtualNetwork
*/
output nsgId string = nsg.id
output nsgResourceId string = nsg.id

output vnetId string = virtualNetwork.id
output vnetResourceId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
output vnetAddressSpace object =  virtualNetwork.properties.addressSpace
//output vnetAddressSpace object = (DeployObject.VirtualNetworkExists) ? existingVirtualNetwork.properties.addressSpace : newVirtualNetwork.properties.addressSpace


/*var allSubNets = virtualNetwork.properties.subnets
output subnetInfoArr array = [for subnet in allSubNets:  {
	name: subnet.name
	id: subnet.id  
}]
//*/
