@description('The name of the Key Vault')
param keyvaultName string

@description('Location for the Key Vault and related resources')
param location string

@description('VNET name for the subnet association with private endpoint')
param vnetName string

@description('Subnet name for the association with private endpoint')
param subnetName string

@description('Name of the private endpoint')
param privateEndpointName string

@description('Name of the private DNS')
param privateDnsName string

// @description('Array of identities and their permissions to the Key Vault')
// param accessPolicies array = []

param keysToCreate array

param workspaceId string

param tags object

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    tenantId: subscription().tenantId
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    accessPolicies: [ ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpointName // Use the passed-in parameter
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'plsConnection'
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsName
  location: 'global'
  tags: tags
}

// resource privateDnsZoneARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZone
//   name: privateEndpointName
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: privateEndpoint.properties.privateLinkServiceConnections[0].properties.
//       }
//     ]
//   }
// }

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

module kvKeysModule 'kvkey.bicep' = [for keyName in keysToCreate: {
  name: keyName
  params: {
    keyName: keyName
    keyvaultName: kv.name
    tags: tags
  }
}]

resource kvDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${keyvaultName} Keyvault to Log Analytics'
  scope: kv
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output keyvaultId string = kv.id
output keyvaultUri string = kv.properties.vaultUri
