targetScope = 'resourceGroup'
//param tenantId string = subscription().tenantId
param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object

@description('the sku')
param storageAccountSkuName string

var minimumTlsVersion = 'TLS1_2' 


//var SolutionName = DeployObject.SolutionName 

//var SolutionNameSt = '${toLower(DeployObject.AppName)}${toLower(DeployObject.Solution)}${toLower(DeployObject.Environment)}'
//output SolutionNameStAudit string = SolutionNameSt

//var auditStAccountName = (length('staudit${SolutionNameSt}001') >23 ) ? substring('staudit${SolutionNameSt}001',0,24) : 'staudit${SolutionNameSt}001'
//output auditStAccountName string = auditStAccountName

param storageSubnetId string
//output storageSubnetId string = storageSubnetId

//var managedUserName = 'id-${SolutionName}'
//var keyVaultName = (length('kv-${SolutionName}') >23 ) ? substring('kv-${SolutionName}',0,24) : 'kv-${SolutionName}'


/*
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name:'vnet-${SolutionName}'
}
resource webapp 'Microsoft.Web/sites@2020-06-01' existing = {
	name: DeployObject.AppName
}
*/

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: DeployObject.ManagedUserName  
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
	name: DeployObject.KeyVaultName
}

var keyvaulturi = endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri
output keyvaulturi string = keyvaulturi
//var cmkMainStKeyName = 'cmk-${StorageAccountsArr[0]}-${SolutionName}'
//var cmkAuditStorageKeyName='cmk-staudit-${SolutionName}'
//output cmkAuditStKeyNameStorage string = cmkAuditStorageKeyName

resource mainstorage_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing ={
	name:SolutionObj.blob_PrivateDnsZoneName
}


resource auditStorage_blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
	name: SolutionObj.auditStorage_Blob_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.auditStorage_Blob_PrivateEndpointName}-link'
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
	

	resource auditStorage_blob_PrivateDnsZoneGroup 'privateDnsZoneGroups' =   {
	name: '${auditStorage_blob_PrivateEndpoint.name}-PrivateDnsZoneGroup'
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'privatelink-blob-core-usgovcloudapi-net'
			properties: {
			privateDnsZoneId: mainstorage_Blob_PrivateDnsZone.id
			}
		}
		]
	}
	}//auditStorage_blob_PrivateDnsZoneGroup
}//auditStorage_blob_PrivateEndpoint


resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' ={ 
	name: SolutionObj.auditStorageAccountName
	location: location
	tags: tags
	kind: 'StorageV2'
	sku: {
	name: storageAccountSkuName
	}
	identity: { 
	type: 'UserAssigned'
	userAssignedIdentities: {
		'${managedUser.id}': {}
	} 
	}
	properties: {
	publicNetworkAccess: 'Enabled'
	allowBlobPublicAccess:  false
	minimumTlsVersion: minimumTlsVersion
	networkAcls: {
		bypass: 'AzureServices'

			defaultAction:  'Deny'
		ipRules:  (DeployObject.DebugFlag) ? [
		{
			value: SolutionObj.myIP
			action: 'Allow'
		}
		] : []
	}
	supportsHttpsTrafficOnly: true
	accessTier: 'Hot'
	encryption: {
		identity: {
		userAssignedIdentity: managedUser.id
		}
		keySource: 'Microsoft.Keyvault'
		keyvaultproperties: {
		keyvaulturi: keyvaulturi
		keyname: SolutionObj.cmkAuditStorageKeyName
		}
		requireInfrastructureEncryption:true
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
			}//services
	}
	}
}//auditStorageAccount

/*
resource existingAuditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = if (DeployObject.AuditStorageExists)  {
	name: SolutionObj.auditStorageAccountName
}

*/


var auditStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${auditStorageAccount.name};AccountKey=${listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output auditStorageAccessKey string = auditStorageAccessKey
resource secret_AuditStorageAccessKey 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = { 
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


resource auditStAccount_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = { 
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


resource auditStAccount_fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
	parent: auditStorageAccount
	name: 'default' 
	properties: { 
	shareDeleteRetentionPolicy: {
		enabled: true
		days: 7
	}
	}
}

resource auditStAccount_queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
	parent: auditStorageAccount
	name: 'default' 
}

resource auditStAccount_tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = {
	parent: auditStorageAccount
	name: 'default'  
}

output auditStorageId string =  auditStorageAccount.id
output auditStorageResourceId string = auditStorageAccount.id
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

