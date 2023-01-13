targetScope = 'resourceGroup'

param location string = resourceGroup().location

param MyIP string

param SolutionObj object
var AppName = SolutionObj.AppName
var Solution = SolutionObj.Solution
var Environment = SolutionObj.Environment
var SolutionName = SolutionObj.SolutionName 
var WebSiteName = SolutionObj.WebSiteName
var FunctionAppName = SolutionObj.FunctionAppName


param tags object

param storageSubnetId string
output storageSubnetId string = storageSubnetId

param StorageAccountsArr array

@description('the sku')
param storageAccountSkuName string

var keyVaultName = 'kv-${SolutionName}'
var managedUserName = 'id-${SolutionName}'
//@description('Expiration time of the key')
//param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

var SolutionNameSt = '${toLower(AppName)}${toLower(Solution)}${toLower(Environment)}'
output SolutionNameSt string = SolutionNameSt

var webapp_dns_name  = '.usgovcloudapi.net'
var st_File_PrivateDnsZoneName = 'privatelink.file${webapp_dns_name}'
var st_File_PrivateEndpointName = 'pep-st-file-${SolutionName}'

var st_Table_PrivateDnsZoneName = 'privatelink.table${webapp_dns_name}'
var st_Table_PrivateEndpointName = 'pep-st-table-${SolutionName}'

var st_Blob_PrivateDnsZoneName = 'privatelink.blob${webapp_dns_name}'
var st_Blob_PrivateEndpointName = 'pep-st-blob-${SolutionName}'

var st_Queue_PrivateDnsZoneName = 'privatelink.queue${webapp_dns_name}'
var st_Queue_PrivateEndpointName = 'pep-st-queue-${SolutionName}'

var storageAccountName = (length('${StorageAccountsArr[0]}${SolutionNameSt}001') >23 ) ? substring('${StorageAccountsArr[0]}${SolutionNameSt}001',0,24) : '${StorageAccountsArr[0]}${SolutionNameSt}001'
output storageAccountName string = storageAccountName

var minimumTlsVersion = 'TLS1_2' 
//var auditStAccountName = (length('staudit${SolutionNameSt}001') >23 ) ? substring('staudit${SolutionNameSt}001',0,24) : 'staudit${SolutionNameSt}001'

/*
resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
  name:auditStAccountName
}
//*/
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name:'vnet-${SolutionName}'
}

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedUserName  
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}
resource webApp 'Microsoft.Web/sites@2020-06-01' existing = {
  name: WebSiteName
}

var cmkMainStKeyName = 'cmk-${StorageAccountsArr[0]}-${SolutionName}'
output cmkMainStKeyNameStorage string = cmkMainStKeyName
/*
//Create the full url for our account download SAS.
output blobDownloadSAS string = '${res.outputs.blobEndpoint}/?${res.outputs.allBlobDownloadSAS}'

//Create the full url for our container upload SAS.
output myContainerUploadSAS string = '${res.outputs.myContainerBlobEndpoint}?${res.outputs.myContainerUploadSAS}'
//*/
// -- Private DNS Zones --
resource st_File_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(Environment == 'Prod'){
  name: st_File_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_File_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_File_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource st_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(Environment == 'Prod'){
  name: st_Blob_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_Blob_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_Blob_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource st_Queue_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(Environment == 'Prod'){
  name: st_Queue_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_Queue_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_Queue_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource st_Table_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(Environment == 'Prod'){
  name: st_Table_PrivateDnsZoneName
  location: 'global'
  tags: tags
  resource st_Table_DnsZoneLink 'virtualNetworkLinks' = {
    name: '${st_Table_PrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

// -- Private Endpoints --
resource st_File_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if(Environment == 'Prod'){
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

resource st_Table_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if(Environment == 'Prod'){
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

resource st_Queue_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if(Environment == 'Prod'){
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

resource st_Blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if(Environment == 'Prod'){
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


resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  identity: {
    type:'UserAssigned'
    userAssignedIdentities: {
      '${managedUser.id}': {}
    } 
  } 
  /*identity: {
    type: 'SystemAssigned'
  }*/
  properties: {
    //publicNetworkAccess: (EnvType == 'prod') ? 'Disabled' : 'Enabled' 
    publicNetworkAccess: 'Enabled' 
    allowBlobPublicAccess: (Environment == 'Prod') ? false : true    
    minimumTlsVersion: minimumTlsVersion    
    networkAcls: {    
      bypass: 'AzureServices'
      defaultAction: (Environment == 'Prod') ? 'Deny' : 'Allow'
      ipRules: (Environment == 'Prod') ? [
        /*{
          value: MyIP
          action: 'Allow'
        }*/
      ]: [
        {
          value: MyIP
          action: 'Allow'
        }
      ]      
    }    
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption:true  
      identity: {
        userAssignedIdentity: managedUser.id        
      }       
      keyvaultproperties: {       
        keyvaulturi: endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri
        keyname: ((environment().name == 'AzureUSGovernment') ?  cmkMainStKeyName : null) 
      }
      services: {        
        file: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Keyvault'
    }    
    accessTier: 'Hot'
  }
}

output mainStuserIdentity object = mainStorageAccount.identity
//output mainStuserPrincipalId string = mainStorageAccount.identity.principalId
output mainStuserAssignedIdentities object  = mainStorageAccount.identity.userAssignedIdentities

resource mainStAccount_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: mainStorageAccount
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
    isVersioningEnabled: false
    cors:{
      corsRules: [
        {
          allowedOrigins: [
            'https://${webApp.properties.defaultHostName}'
          ]
          allowedMethods: [
            'GET'
            'POST'
            'PUT'
          ]
          maxAgeInSeconds: 86400
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
  }
}

resource mainStAccount_fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: mainStorageAccount
  name: 'default'  
  properties: {    
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

/*
var functionContentShareName = 'function-content-share'
resource functionContentShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccount.name}/default/${functionContentShareName}'
}
*/

resource mainStAccount_fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  parent: mainStAccount_fileservices
  name: FunctionAppName
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }  
}


resource mainStAccount_queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  parent: mainStorageAccount
  name: 'default'  
}

resource mainStAccount_tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = {
  parent: mainStorageAccount
  name: 'default'  
}


resource completedcontainers_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: mainStAccount_blobServices
  name: 'completedcontainers'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  /*dependsOn: [
    storageAccount
  ]*/
}

/*resource storageAccountName_default_import 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: mainStAccount_blobServices
  name: 'import'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  /*dependsOn: [

    storageAccount
  ]
}*/

resource deployarmtemplates_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
  parent: mainStAccount_queueServices
  name: 'deployarmtemplates'    
}

resource status_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
  parent: mainStAccount_queueServices
  name: 'status'   
}

resource transfers_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
  parent: mainStAccount_queueServices
  name: 'transfers'    
}

resource CompletedContainers_table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-09-01' = {
  parent: mainStAccount_tableServices
  name: 'CompletedContainers' 
}

resource transfers_table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-09-01' = {
  parent: mainStAccount_tableServices
  name: 'transfers' 
}

var azStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name}; AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output azStorageAccessKey string =azStorageAccessKey

resource secret_AzStorageAccessKey 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: 'AzStorageAccessKey'
  parent: keyVault
  tags:tags
  properties: {
    value: azStorageAccessKey
    attributes:{
      enabled:true
    }
  }
}

var AzureWebJobsStorage = 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name}; AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output AzureWebJobsStorage string = AzureWebJobsStorage
resource secret_AzureWebJobsStorage 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: 'AzureWebJobsStorage'
  parent: keyVault
  tags:tags
  properties: {
    value: AzureWebJobsStorage
    attributes:{
    enabled:true
    }
  }
}

resource secret_storageAccountResourceID 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: 'storageAccountResourceID'
  parent: keyVault
  tags:tags
  properties: {
    value: mainStorageAccount.id
    attributes:{
    enabled:true
    }
  }
}

/*
resource mainStorageDiagnosticsService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: mainStorageAccount
  name: 'service'
  properties: {
    storageAccountId: auditStorageAccount.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
}
//*/
output storageAccountResourceID string = mainStorageAccount.id
output mainStorageName string = mainStorageAccount.name
//output storageAccountResourceID string = mainStorageAccount.id
//output ctsStorageId string = ctsStorageAccount.id
//output ctsStorageName string = ctsStorageAccount.name

// Use sasConfig to generate an Account SAS token
//output sasToken string = ctsStorageAccount.listAccountSas(ctsStorageAccount.apiVersion, sasConfig).accountSasToken
//output sasToken string = mainStorageAccount.listAccountSas(mainStorageAccount.apiVersion, sasConfig).accountSasToken


// Alternatively, we could use listServiceSas function
//var sasToken = ctsStorageAccount.listAccountSas(ctsStorageAccount.apiVersion, sasConfig).accountSasToken
// Connection string based on a SAS token
//output connectionStringSAS string = 'BlobEndpoint=${ctsStorageAccount.properties.primaryEndpoints.blob};SharedAccessSignature=${sasToken}'


output blobEndpoint string = mainStorageAccount.properties.primaryEndpoints.blob
// 'https://satestapppreprod.blob.${environment().suffixes.storage}'
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
    minimumTlsVersion: minimumTlsVersion
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
  signedResourceTypes: 'sc'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: '2023-07-31T00:00:00Z'
  signedProtocol: 'https'
  keyToSign: 'key2'
}
//*/ 

//output keyvaultURI string = keyvault.properties.vaultUri
