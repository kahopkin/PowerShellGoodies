@description('The name of the Storage Account')
param storageName string

@description('The SKU of the Storage Account')
param storageSku string

@description('Location for the Storage Account and related resources')
param location string

@description('VNET name for the subnet association with private endpoint')
param vnetName string

@description('Subnet name for the association with private endpoint')
param subnetName string

@description('Name of the private DNS')
param privateDnsName string

@description('Array of private endpoints to create for the storage account')
param privateEndpoints array = []

param containers array = []

param queues array = []

param tables array = []

param fileShares array = []

param identityResourceId string

param keyName string

param keyvaulturi string

param workspaceId string

param tags object

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageName
  location: location
  tags: tags
  sku: {
    name: storageSku
  }
  identity: {   
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResourceId}': {}
    }
  } 
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    encryption: {
      identity: {
        userAssignedIdentity: identityResourceId             
      }      
      services: {
        file: {
          enabled: true
        }
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyvaulturi: keyvaulturi
        keyname: keyName
      }
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = [for endpoint in privateEndpoints: {
  name: endpoint.privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'plsConnection-${endpoint.type}'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            endpoint.type
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
  }
}]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsName
  location: 'global'
  tags: tags
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = [for (endpoint, i) in privateEndpoints: {
  parent: privateEndpoint[i]
  name: 'default-${endpoint.privateEndpointName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config-${endpoint.privateEndpointName}'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}]


// resource mainStorage_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = if (isMainStorageResource) {
//   parent: storage
//   name: 'default'
//   properties: {
//     changeFeed: {
//       enabled: false
//     }
//     restorePolicy: {
//       enabled: false
//     }
//     containerDeleteRetentionPolicy: {
//       enabled: true
//       days: 7
//     }   
//     deleteRetentionPolicy: {
//       allowPermanentDelete: false
//       enabled: true
//       days: 7
//     }
//     isVersioningEnabled: false
//     cors:{
//       corsRules: [
//         {
//           allowedOrigins: [
//             // 'https://${webApp.properties.defaultHostName}'
//           ]
//           allowedMethods: [
//             'GET'
//             'POST'
//             'PUT'
//           ]
//           maxAgeInSeconds: 86400
//           exposedHeaders: [
//             '*'
//           ]
//           allowedHeaders: [
//             '*'
//           ]
//         }
//       ]
//     }
//   }
// }

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storage
  name: 'default'
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }   
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

// Create blob containers
resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for container in (empty(containers) ? [] : containers): {
  parent:blobServices
  name: 'default-${container}'
  properties: {
    publicAccess: 'None'
  }
}]

// Create queues
resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  parent: storage
  name: 'default'
}

resource storageQueues 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = [for queue in (empty(queues) ? [] : queues): {
  parent: queueServices
  name: queue
  properties: {
  }
}]

// Tables
resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' =  {
  parent: storage
  name: 'default'  
}

resource storageTables 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-04-01' = [for table in (empty(tables) ? [] : tables): {
  parent: tableServices
  name: table
}]

// FileShares
resource fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' =  {
  parent: storage
  name: 'default'
  properties: {    
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Create file shares
resource storageFileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = [for fileShare in (empty(fileShares) ? [] : fileShares): {
  parent: fileservices
  name: fileShare
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'  }
}]

resource diagnosticsStorage 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Send to Workspace and Audit Storage'   
  scope: blobServices
  properties: {
    workspaceId: workspaceId
    storageAccountId: resourceId('Microsoft.Storage/storageAccounts', storageName)
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource diagnosticsStorage2 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(tables)) {
  name: 'Send Table Metrics to Log Analytics'   
  scope: tableServices
  properties: {
    workspaceId: workspaceId
    storageAccountId: resourceId('Microsoft.Storage/storageAccounts', storageName)
    logs: [
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

output storageId string = storage.id
