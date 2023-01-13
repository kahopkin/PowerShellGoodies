targetScope = 'resourceGroup'

param location string = resourceGroup().location

param SolutionObj object
var AppName = SolutionObj.AppName
var Solution = SolutionObj.Solution
var Environment = SolutionObj.Environment
var SolutionName = SolutionObj.SolutionName 
//var WebSiteName = SolutionObj.WebSiteName
//var FunctionAppName = SolutionObj.FunctionAppName

param MyIP string
param tags object

var SolutionNameSt = '${toLower(AppName)}${toLower(Solution)}${toLower(Environment)}'
output SolutionNameStAudit string = SolutionNameSt

var auditStAccountName = (length('staudit${SolutionNameSt}001') >23 ) ? substring('staudit${SolutionNameSt}001',0,24) : 'staudit${SolutionNameSt}001'
output auditStAccountName string = auditStAccountName

param storageSubnetId string
//output storageSubnetId string = storageSubnetId


@description('the sku')
param storageAccountSkuName string
var managedUserName = 'id-${SolutionName}'
var keyVaultName = 'kv-${SolutionName}'
//@description('Expiration time of the key')
//param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

var webapp_dns_name  = '.usgovcloudapi.net'

//var st_audit_PrivateEndpointName='pep-st-audit-${SolutionName}'
var st_blob_audit_PrivateEndpointName= 'pep-st-blob-audit-${SolutionName}'
var st_Blob_PrivateDnsZoneName = 'privatelink.blob${webapp_dns_name}'

var minimumTlsVersion = 'TLS1_2' 

/*
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name:'vnet-${SolutionName}'
}
resource webapp 'Microsoft.Web/sites@2020-06-01' existing = {
  name: AppName
}
*/
resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedUserName  
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}


//var cmkMainStKeyName = 'cmk-${StorageAccountsArr[0]}-${SolutionName}'
var cmkAuditKeyName='cmk-staudit-${SolutionName}'
output cmkAuditStKeyNameStorage string = cmkAuditKeyName
/*
resource keyVault_addAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: mainStorageAccount.identity.principalId
        permissions: {          
            keys: [
              'unwrapKey'
              'wrapKey'
              'get'
            ]          
        }
      }
      {
        tenantId: tenantId
        objectId: auditStorageAccount.identity.principalId
        permissions: {          
            keys: [
              'unwrapKey'
              'wrapKey'
              'get'
            ]          
        }
      }
    ]
  }
}
//*/

/*
//Create the full url for our account download SAS.
output blobDownloadSAS string = '${res.outputs.blobEndpoint}/?${res.outputs.allBlobDownloadSAS}'

//Create the full url for our container upload SAS.
output myContainerUploadSAS string = '${res.outputs.myContainerBlobEndpoint}?${res.outputs.myContainerUploadSAS}'
//*/

resource st_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing ={//} if(Environment == 'Prod'){
    name:st_Blob_PrivateDnsZoneName
}


resource staudit_blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = if(Environment == 'Prod'){  //if(Environment == 'Prod' && Solution == 'Transfer'){
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

  
  /*resource st_Blob_PrivateDnsZoneGroup 'privateDnsZoneGroups' existing = {
    name: '${st_Blob_PrivateDnsZone.name}-PrivateDnsZoneGroup'    
  }*/

  resource st_blob_audit__PrivateDnsZoneGroup 'privateDnsZoneGroups' =   if(Environment == 'Prod'){//if(Environment == 'Prod' && Solution == 'Transfer'){
    name: '${staudit_blob_PrivateEndpoint.name}-PrivateDnsZoneGroup'    
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

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' ={ // if(Solution == 'Transfer') {
  name: auditStAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  /*identity: {
    type: 'SystemAssigned'
  }//*/
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedUser.id}': {}
    } 
  }   
  properties: {
    //publicNetworkAccess: (Environment == 'Prod') ? 'Disabled' : 'Enabled' 
    publicNetworkAccess: 'Enabled' 
    allowBlobPublicAccess: (Environment == 'Prod') ? false : true
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {    
      bypass: 'AzureServices'            
      defaultAction: (Environment == 'Prod') ? 'Deny' : 'Allow'      
      ipRules:  (Environment == 'Prod') ? [
        /*{
          value: MyIP
          action: 'Allow'
        }*/
      ]:[
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
        keyname: cmkAuditKeyName
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

var auditStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${auditStorageAccount.name};AccountKey=${listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output auditStorageAccessKey string = auditStorageAccessKey
resource secret_AuditStorageAccessKey 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = { //if(Solution == 'Transfer'){
  name: 'AuditStorageAccessKey'
  parent: keyVault
  tags:tags
  properties: {
    value: auditStorageAccessKey
    attributes:{
    enabled:true
    }
  }
}


resource auditStAccount_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' ={ // if(Solution == 'Transfer'){
  parent: auditStorageAccount
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
  }
}


resource auditStAccount_fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {//if(Solution == 'Transfer'){
  parent: auditStorageAccount
  name: 'default' 
  properties: {   
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource auditStAccount_queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {//if(Solution == 'Transfer'){
  parent: auditStorageAccount
  name: 'default' 
}

resource auditStAccount_tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = {//if(Solution == 'Transfer'){
  parent: auditStorageAccount
  name: 'default'  
}

output auditStorageId string =  auditStorageAccount.id
output auditStorageAccountName string = auditStorageAccount.name 



//output ctsStorageId string = ctsStorageAccount.id
//output ctsStorageName string = ctsStorageAccount.name

// Use sasConfig to generate an Account SAS token
//output sasToken string = ctsStorageAccount.listAccountSas(ctsStorageAccount.apiVersion, sasConfig).accountSasToken
//output sasToken string = mainStorageAccount.listAccountSas(mainStorageAccount.apiVersion, sasConfig).accountSasToken


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
