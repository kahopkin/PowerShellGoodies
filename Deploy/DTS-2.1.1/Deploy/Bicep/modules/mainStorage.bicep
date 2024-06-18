targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
//param tenantId string = subscription().tenantId


var WebSiteName = SolutionObj.WebSiteName
var FunctionAppName = SolutionObj.FunctionAppName


param StorageAccountsArr array

@description('the sku')
param storageAccountSkuName string

var vNetName = 'vnet-${DeployObject.SolutionName}'
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: vNetName
}


//var storageSubnetId  = '${vnetId}/subnets/${storageSubnetName}'
var storageSubnetName = '/subnets/snet-storage-${DeployObject.SolutionName}'
resource storageSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' existing = {
	parent: virtualNetwork
	name: storageSubnetName
}

output storageSubnetName string = storageSubnet.name

var storageSubnetId = '${virtualNetwork.id}${storageSubnet.name}'
output storageSubnetId string = storageSubnetId

//var keyVaultName = (length('kv-${DeployObject.SolutionName}') >23 ) ? substring('kv-${DeployObject.SolutionName}',0,24) : 'kv-${DeployObject.SolutionName}'
var managedUserName = 'id-${DeployObject.SolutionName}'
//@description('Expiration time of the key')
//param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

param SolutionNameSt string = '${toLower(DeployObject.AppName)}${toLower(DeployObject.Solution)}${toLower(DeployObject.Environment)}'
output SolutionNameSt string = SolutionNameSt

var webapp_dns_name  = '.usgovcloudapi.net'
//var mainStorage_File_PrivateDnsZoneName = 'privatelink.file${webapp_dns_name}'
var mainStorage_File_PrivateDnsZoneName = 'privatelink.file.core${webapp_dns_name}'
var mainStorage_File_PrivateEndpointName = 'pep-st-file-${DeployObject.SolutionName}'

//var mainStorage_Table_PrivateDnsZoneName = 'privatelink.table${webapp_dns_name}'
var mainStorage_Table_PrivateDnsZoneName = 'privatelink.table.core${webapp_dns_name}'
var mainStorage_Table_PrivateEndpointName = 'pep-st-table-${DeployObject.SolutionName}'

//var mainstorage_Blob_PrivateDnsZoneName = 'privatelink.blob${webapp_dns_name}'
//var mainstorage_Blob_PrivateDnsZoneName = 'privatelink.blob.core${webapp_dns_name}'
//var mainStorage_Blob_PrivateEndpointName = 'pep-st-blob-${DeployObject.SolutionName}'

//var mainStorage_Queue_PrivateDnsZoneName = 'privatelink.queue${webapp_dns_name}'
var mainStorage_Queue_PrivateDnsZoneName = 'privatelink.queue.core${webapp_dns_name}'
var mainStorage_Queue_PrivateEndpointName = 'pep-st-queue-${DeployObject.SolutionName}'

var mainStorageAccountName = (length('${StorageAccountsArr[0]}${SolutionNameSt}001') >23 ) ? substring('${StorageAccountsArr[0]}${SolutionNameSt}001',0,24) : '${StorageAccountsArr[0]}${SolutionNameSt}001'
output storageAccountName string = mainStorageAccountName

var minimumTlsVersion = 'TLS1_2' 
//var auditStAccountName = (length('staudit${SolutionNameSt}001') >23 ) ? substring('staudit${SolutionNameSt}001',0,24) : 'staudit${SolutionNameSt}001'

/*
resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
	name:auditStAccountName
}
//*/

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: managedUserName  
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
	name: DeployObject.KeyVaultName
}
resource webApp 'Microsoft.Web/sites@2020-06-01' existing = {
	name: WebSiteName
}

var cmkMainStKeyName = 'cmk-${StorageAccountsArr[0]}-${DeployObject.SolutionName}'
output cmkMainStKeyNameStorage string = cmkMainStKeyName
/*
//Create the full url for our account download SAS.
output blobDownloadSAS string = '${res.outputs.blobEndpoint}/?${res.outputs.allBlobDownloadSAS}'

//Create the full url for our container upload SAS.
output myContainerUploadSAS string = '${res.outputs.myContainerBlobEndpoint}?${res.outputs.myContainerUploadSAS}'
//*/
// -- Private DNS Zones --
resource mainStorage_File_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: mainStorage_File_PrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_File_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainStorage_File_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}

resource mainstorage_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.blob_PrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_Blob_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainstorage_Blob_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}

resource mainStorage_Queue_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: mainStorage_Queue_PrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_Queue_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainStorage_Queue_PrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}

resource mainStorage_Table_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: mainStorage_Table_PrivateDnsZoneName
	location: 'global'
	tags: tags
	resource mainStorage_Table_DnsZoneLink 'virtualNetworkLinks' = {
	name: '${mainStorage_Table_PrivateDnsZone.name}-link'
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
resource mainStorage_Blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.mainStorage_Blob_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId

	}
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.mainStorage_Blob_PrivateEndpointName}-link'
		properties: {
			privateLinkServiceId: mainStorageAccount.id
			groupIds: [
			'blob'
			]
		}
		}
	]
	}

	resource mainStorage_Blob_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
	name: '${mainstorage_Blob_PrivateDnsZone.name}-PrivateDnsZoneGroup'
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'config'
			properties: {
			privateDnsZoneId: mainstorage_Blob_PrivateDnsZone.id
			}
		}
		]
	}
	}
}


resource mainStorage_File_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: mainStorage_File_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${mainStorage_File_PrivateEndpointName}-link'
		properties: {
			privateLinkServiceId: mainStorageAccount.id
			groupIds: [
			'file'
			]
		}
		}
	]
	}

	resource mainStorage_File_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
	name: '${mainStorage_File_PrivateEndpoint.name}-PrivateDnsZoneGroup'
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'config'
			properties: {
			privateDnsZoneId: mainStorage_File_PrivateDnsZone.id
			}
		}
		]
	}
	}
}

resource mainStorage_Table_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: mainStorage_Table_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${mainStorage_Table_PrivateEndpointName}-link'
		properties: {
			privateLinkServiceId: mainStorageAccount.id
			groupIds: [
			'table'
			]
		}
		}
	]
	}

	resource mainStorage_Table_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
	name: '${mainStorage_Table_PrivateEndpoint.name}-PrivateDnsZoneGroup'
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'config'
			properties: {
			privateDnsZoneId: mainStorage_Table_PrivateDnsZone.id
			}
		}
		]
	}
	}
}

resource mainStorage_Queue_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: mainStorage_Queue_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${mainStorage_Queue_PrivateEndpointName}-link'
		properties: {
			privateLinkServiceId: mainStorageAccount.id
			groupIds: [
			'queue'
			]
		}
		}
	]
	}

	resource mainStorage_Queue_PrivateDnsZoneGroup 'privateDnsZoneGroups' = {
	name: '${mainStorage_Queue_PrivateDnsZone.name}-PrivateDnsZoneGroup'
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'config'
			properties: {
			privateDnsZoneId: mainStorage_Queue_PrivateDnsZone.id
			}
		}
		]
	}
	}
}


var keyvaulturi = endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri

resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
	name: SolutionObj.mainStorageAccountName
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
	allowBlobPublicAccess: false
	minimumTlsVersion: minimumTlsVersion 
	networkAcls: {
		bypass: 'AzureServices'
		defaultAction: 'Deny'
		ipRules: [
		{
			value: DeployObject.MyIP
			action: 'Allow'
		}
		]
	}
	supportsHttpsTrafficOnly: true
	encryption: {
		identity: {
		userAssignedIdentity: managedUser.id
		} 
		keyvaultproperties: {
			keyvaulturi: keyvaulturi
		keyname: cmkMainStKeyName
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
	} 
	accessTier: 'Hot'
	}

}

//output MainStorageSystemAssignedprincipalId string = mainStorageAccount.identity.principalId

/*var SystemAssignedPrincipalId = mainStorageAccount.identity.principalId

//Key Vault Crypto Service Encryption User
resource CryptotorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
	scope: subscription()
	
	name: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
}
//*/
/*resource cryptoRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
	scope: keyVault
	name: guid(resourceGroup().id, SystemAssignedPrincipalId, ReaderRoleDefinition.id)
	properties: {
	roleDefinitionId: CryptotorRoleDefinition.id
	principalId: SystemAssignedPrincipalId
	principalType: 'ServicePrincipal'
	}
}
//*/
/*resource mainStorageKeyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
	name: 'add'
	parent: keyVault
	properties: {
	accessPolicies: [
		{
			objectId: mainStorageAccount.identity.principalId
		permissions: {
			certificates: []
			keys: []
			secrets: [
			'Get'
			]
			}
		tenantId: tenantId
		}
	]
	}
}

//*/
//output mainStorageSystemAssignedPrincipalIdentity object = mainStorageAccount.identity
//output mainStuserIdentity object = mainStorageAccount.identity
//output mainStuserPrincipalId string = mainStorageAccount.identity.principalId
//output mainStuserAssignedIdentities object  = mainStorageAccount.identity.userAssignedIdentities

/*resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
	scope: mainStorageAccount
	name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinition.id)
	properties: {
	roleDefinitionId: contributorRoleDefinition.id
	principalId: managedIdentity.properties.principalId
	principalType: 'ServicePrincipal'
	}
}
//*/
//var SystemAssignedPrincipalId = mainStorageAccount.identity.principalId
//output mainStorageSystemAssignedPrincipalId string = SystemAssignedPrincipalId
/*resource mainStorageKeyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
	name: 'add'
	parent: keyVault
	properties: {
	accessPolicies: [
		{
			objectId: SystemAssignedPrincipalId
		permissions: {
			certificates: []
			keys: [
			'Get'
			'UnwrapKey'
			'WrapKey'
			]
			secrets: [
			'Get'
			]
			}
		tenantId: subscription().tenantId
		}
	]
	}
}
//*/
resource mainStorage_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
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

resource mainStorage_fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
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

resource mainStorage_fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
	parent: mainStorage_fileservices
	name: FunctionAppName
	properties: {
	accessTier: 'TransactionOptimized'
	shareQuota: 5120
	enabledProtocols: 'SMB'
	}  
}


resource mainStorage_queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
	parent: mainStorageAccount
	name: 'default'  
}

resource mainStorage_tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = {
	parent: mainStorageAccount
	name: 'default'  
}


resource mainStorage_completedcontainers_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
	parent: mainStorage_blobServices
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

resource mainStorage_import_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
	parent: mainStorage_blobServices
	name: 'import'
	properties: {
	immutableStorageWithVersioning: {
		enabled: false
	}
	defaultEncryptionScope: '$account-encryption-key'
	denyEncryptionScopeOverride: false
	publicAccess: 'None'
	}
}

resource mainStorage_deployarmtemplates_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
	parent: mainStorage_queueServices
	name: 'deployarmtemplates'
}

resource mainStorage_status_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
	parent: mainStorage_queueServices
	name: 'status'   
}

resource mainStorage_transfers_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
	parent: mainStorage_queueServices
	name: 'transfers'
}

resource mainStorage_completedContainers_table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-09-01' = {
	parent: mainStorage_tableServices
	name: 'CompletedContainers' 
}

resource mainStorage_transfers_table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-09-01' = {
	parent: mainStorage_tableServices
	name: 'transfers' 
}

var azStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
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

var AzureWebJobsStorage = 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
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
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
	scope: subscription()
	// This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab
	name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}
//*/


/*
//add access to the keyvault for the app
resource mainStorageKeyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
	name: 'add'
	parent: keyVault
	properties: {
	accessPolicies: [
		{
			objectId: reference(mainStorageAccount.id, '2021-09-01', 'Full').identity.principalId
		permissions: {
			certificates: []
			keys: []
			secrets: [
			'Get'
			]
			}
		tenantId: tenantId
		}
	]
	}
}
//*/

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
output mainStorageName string = mainStorageAccount.name

output blobEndpoint string = mainStorageAccount.properties.primaryEndpoints.blob
// 'https://satestapppreprod.blob.${environment().suffixes.storage}'
//output myContainerBlobEndpoint string = 'https://satestapppreprod.blob.${environment().suffixes.storage}/mycontainer'


/*
var privateStorageFileDnsZoneName = 'privatelink.file${webapp_dns_name}'
var privateEndpointName = 'st-file-private-endpoint-${DeployObject.SolutionName}'

//var privateStorageTableDnsZoneName = 'privatelink.table.${DeployObject.SolutionName}'
var privateStorageTableDnsZoneName = 'privatelink.table${webapp_dns_name}'
var privateEndpointStorageTableName = 'st-table-private-endpoint-${DeployObject.SolutionName}'

//var privateStorageBlobDnsZoneName = 'privatelink.blob.${DeployObject.SolutionName}'
var privateStorageBlobDnsZoneName = 'privatelink.blob${webapp_dns_name}'
var privateEndpointStorageBlobName = 'st-blob-private-endpoint-${DeployObject.SolutionName}'

//var privateStorageQueueDnsZoneName = 'privatelink.queue.${DeployObject.SolutionName}'
var privateStorageQueueDnsZoneName = 'privatelink.queue${webapp_dns_name}'
var privateEndpointStorageQueueName = 'st-queue-private-endpoint-${DeployObject.SolutionName}'

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
