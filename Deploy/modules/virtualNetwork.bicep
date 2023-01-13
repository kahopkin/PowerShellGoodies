targetScope = 'resourceGroup'

param virtualNetworkObj object
param SolutionName string

param location string = resourceGroup().location
param tags object

var virtualNetworkName  = '${virtualNetworkObj.name}-${SolutionName}'
var  nsgName  = 'nsg-${SolutionName}'

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

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  tags: tags
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties:{
    addressSpace:{
      addressPrefixes:[
        virtualNetworkObj.addressPrefix
      ]
    }
    subnets: [for subnet in virtualNetworkObj.subnets: {
      name: 'snet-${subnet.name}-${SolutionName}'
      properties: {
        addressPrefix: subnet.ipAddressRange
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        networkSecurityGroup: {
          id: nsg.id
        }
        delegations: (contains(subnet, 'delegations') ? delegations[subnet.delegations] : delegations.default)
      }
    }]
  }
  resource allSubnets 'subnets' existing = [for subnet in virtualNetworkObj.subnets: {
    name: '${subnet.name}-${SolutionName}'
  }]

}//virtualNetwork

output nsgId string = nsg.id

output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
