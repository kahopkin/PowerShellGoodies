targetScope = 'resourceGroup'

param location string = resourceGroup().location
param EnvType string
param AppName string
param tags object

param vnetId string
param storageSubnetId string

param StorageAccountsArr array

@description('the sku')
param storageAccountSkuName string

var SolutionNameSt = '${toLower(AppName)}${toLower(EnvType)}'

var webapp_dns_name  = '.usgovcloudapi.net'
var SolutionName = '${toLower(AppName)}-${toLower(EnvType)}'
var st_File_PrivateDnsZoneName = 'privatelink.file${webapp_dns_name}'
var st_File_PrivateEndpointName = 'pep-st_file-${SolutionName}'

var st_Table_PrivateDnsZoneName = 'privatelink.table${webapp_dns_name}'
var st_Table_PrivateEndpointName = 'pep-st-table-${SolutionName}'

var st_Blob_PrivateDnsZoneName = 'privatelink.blob${webapp_dns_name}'
var st_Blob_PrivateEndpointName = 'pep-st-blob-${SolutionName}'

var st_Queue_PrivateDnsZoneName = 'privatelink.queue${webapp_dns_name}'
var st_Queue_PrivateEndpointName = 'pep-st-queue-${SolutionName}'

var st_audit_PrivateEndpointName='pep-st-audit-${SolutionName}'
var st_blob_audit_PrivateEndpointName= 'pep-st_blob_audit-${SolutionName}'

resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${StorageAccountsArr[0]}${SolutionNameSt}00'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: mainStorageAccount
  name: 'default'
}

/*
resource ctsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${StorageAccountsArr[2]}${SolutionNameSt}00'
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

// Specifying configuration for the SAS token; not all possible fields are included
var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: '2023-07-31T00:00:00Z'
  signedProtocol: 'https'
  keyToSign: 'key2'
}
//*/ 

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${StorageAccountsArr[1]}${SolutionNameSt}01'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }
}

/*
//Create the full url for our account download SAS.
//output blobDownloadSAS string = '${res.outputs.blobEndpoint}/?${res.outputs.allBlobDownloadSAS}'

//Create the full url for our container upload SAS.
//output myContainerUploadSAS string = '${res.outputs.myContainerBlobEndpoint}?${res.outputs.myContainerUploadSAS}'
//*/
// -- Private DNS Zones --
resource st_File_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: st_File_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_File_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_File_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

resource st_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: st_Blob_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_Blob_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_Blob_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

resource st_Queue_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: st_Queue_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_Queue_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_Queue_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

resource st_Table_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: st_Table_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_Table_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_Table_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

// -- Private Endpoints --
resource st_File_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: st_File_PrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: storageSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${st_File_PrivateEndpointName}-link'
        properties: {
          privateLinkServiceId: mainStorageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }

  resource st_File_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: '${st_File_PrivateEndpoint.name}-PrivateDnsZoneGroup'    
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: st_File_PrivateDnsZone.id
          }
        }
      ]
    }
  }
}


resource st_Table_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: st_Table_PrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: storageSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${st_Table_PrivateEndpointName}-link'
        properties: {
          privateLinkServiceId: mainStorageAccount.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
  }

  resource st_Table_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: '${st_Table_PrivateEndpoint.name}-PrivateDnsZoneGroup'    
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: st_Table_PrivateDnsZone.id
          }
        }
      ]
    }
  }
}

resource st_Queue_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: st_Queue_PrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: storageSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${st_Queue_PrivateEndpointName}-link'
        properties: {
          privateLinkServiceId: mainStorageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
  }

  resource st_Queue_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: '${st_Queue_PrivateDnsZone.name}-PrivateDnsZoneGroup'    
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: st_Queue_PrivateDnsZone.id
          }
        }
      ]
    }
  }
}

resource st_Blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: st_Blob_PrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: storageSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${st_Blob_PrivateEndpointName}-link'
        properties: {
          privateLinkServiceId: mainStorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }

  resource st_Blob_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: '${st_Blob_PrivateDnsZone.name}-PrivateDnsZoneGroup'    
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: st_Blob_PrivateDnsZone.id
          }
        }
      ]
    }
  }
}


resource st_audit_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: st_audit_PrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${st_audit_PrivateEndpointName}-link'
        properties: {
          privateLinkServiceId: auditStorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: storageSubnetId
    }
  }

  resource st_audit_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: '${st_Blob_PrivateDnsZone.name}-PrivateDnsZoneGroup'    
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: st_Blob_PrivateDnsZone.id
          }
        }
      ]
    }
  }
}

resource st_blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: st_blob_audit_PrivateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${st_blob_audit_PrivateEndpointName}-link'
        properties: {
          privateLinkServiceId: auditStorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: storageSubnetId
    }
  }

  resource st_blob_audit__PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: '${st_blob_PrivateEndpoint.name}-PrivateDnsZoneGroup'    
    properties: {      
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-core-usgovcloudapi-net'
          properties: {
            privateDnsZoneId: st_Blob_PrivateDnsZone.id
          }
        }
      ]
    }
  }
}

output mainStorageId string = mainStorageAccount.id
output mainStorageName string = mainStorageAccount.name

output auditStorageId string = auditStorageAccount.id
output auditStorageName string = auditStorageAccount.name

//output ctsStorageId string = ctsStorageAccount.id
//output ctsStorageName string = ctsStorageAccount.name

// Use sasConfig to generate an Account SAS token
//output sasToken string = ctsStorageAccount.listAccountSas(ctsStorageAccount.apiVersion, sasConfig).accountSasToken


// Alternatively, we could use listServiceSas function
//var sasToken = ctsStorageAccount.listAccountSas(ctsStorageAccount.apiVersion, sasConfig).accountSasToken
// Connection string based on a SAS token
//output connectionStringSAS string = 'BlobEndpoint=${ctsStorageAccount.properties.primaryEndpoints.blob};SharedAccessSignature=${sasToken}'


//output blobEndpoint string = 'https://satestapppreprod.blob.${environment().suffixes.storage}'
//output myContainerBlobEndpoint string = 'https://satestapppreprod.blob.${environment().suffixes.storage}/mycontainer'


/*
var privateStorageFileDnsZoneName = 'privatelink.file${webapp_dns_name}'
var privateEndpointName = 'st-file-private-endpoint-${SolutionName}'

//var privateStorageTableDnsZoneName = 'privatelink.table.${SolutionName}'
var privateStorageTableDnsZoneName = 'privatelink.table${webapp_dns_name}'
var privateEndpointStorageTableName = 'st-table-private-endpoint-${SolutionName}'

//var privateStorageBlobDnsZoneName = 'privatelink.blob.${SolutionName}'
var privateStorageBlobDnsZoneName = 'privatelink.blob${webapp_dns_name}'
var privateEndpointStorageBlobName = 'st-blob-private-endpoint-${SolutionName}'

//var privateStorageQueueDnsZoneName = 'privatelink.queue.${SolutionName}'
var privateStorageQueueDnsZoneName = 'privatelink.queue${webapp_dns_name}'
var privateEndpointStorageQueueName = 'st-queue-private-endpoint-${SolutionName}'

//*/
