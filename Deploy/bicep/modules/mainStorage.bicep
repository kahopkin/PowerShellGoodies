targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object


@description('the sku')
param storageAccountSkuName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

var storageSubnetName = '/subnets/snet-storage-${DeployObject.SolutionName}'
resource storageSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' existing = {
	parent: virtualNetwork
	name: storageSubnetName
}

output storageSubnetName string = storageSubnet.name

var storageSubnetId = '${virtualNetwork.id}${storageSubnet.name}'
output storageSubnetId string = storageSubnetId

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: DeployObject.ManagedUserName  
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
	name: DeployObject.KeyVaultName
}
var keyvaultURI = endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri
output keyvaultURIOut string = keyvaultURI

resource webApp 'Microsoft.Web/sites@2020-06-01' existing = {
	name: SolutionObj.webSiteName
}


param SolutionNameSt string = '${toLower(DeployObject.AppName)}${toLower(DeployObject.Solution)}${toLower(DeployObject.Environment)}'
output SolutionNameSt string = SolutionNameSt


var minimumTlsVersion = 'TLS1_2' 



// -- Private DNS Zones --
resource mainStorage_File_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.filePrivateDnsZoneName
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
}//mainStorage_File_PrivateDnsZone

resource mainstorage_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.blobPrivateDnsZoneName
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
}//mainstorage_Blob_PrivateDnsZone

resource mainStorage_Queue_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.queuePrivateDnsZoneName
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
}//mainStorage_Queue_PrivateDnsZone

resource mainStorage_Table_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.tablePrivateDnsZoneName
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
}//mainStorage_Table_PrivateDnsZone

// -- Private Endpoints --
resource mainStorage_Blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.mainStorageBlobPrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId

	}
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.mainStorageBlobPrivateEndpointName}-link'
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
}//mainStorage_Blob_PrivateEndpoint


resource mainStorage_File_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.mainStorageFilePrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.mainStorageFilePrivateEndpointName}-link'
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
	}//mainStorage_File_PrivateDnsZoneGroup
}//mainStorage_File_PrivateEndpoint

resource mainStorage_Table_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.mainStorageTablePrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.mainStorageTablePrivateEndpointName}-link'
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
	}//mainStorage_Table_PrivateDnsZoneGroup
}//mainStorage_Table_PrivateEndpoint

resource mainStorage_Queue_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.mainStorage_Queue_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.mainStorage_Queue_PrivateEndpointName}-link'
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
	}//mainStorage_Queue_PrivateDnsZoneGroup
}//mainStorage_Queue_PrivateEndpoint


resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = if (!DeployObject.MainStorageExists)  {
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
	accessTier: 'Hot'
	supportsHttpsTrafficOnly: true
	networkAcls: {
		bypass: 'AzureServices'
		defaultAction: 'Deny'
		ipRules:  (DeployObject.DebugFlag) ? [
			{
				value: SolutionObj.myIP
				action: 'Allow'
			}
			] : []
	}
	 encryption: {
		identity: {
			userAssignedIdentity: managedUser.id
			}
		keySource: 'Microsoft.Keyvault'
		keyvaultproperties: {
			keyvaulturi: keyvaultURI
			keyname: SolutionObj.cmkMainStorageKeyName
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
		} //services
		}//encryption
	}//properties
}//resource mainStorageAccount

resource mainStorage_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
//resource mainStorage_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = if(!DeployObject.MainStorageExists){
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
			'${SolutionObj.webProtocol}${webApp.properties.defaultHostName}'
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
}//mainStorage_blobServices


resource mainStorage_fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' ={
	parent: mainStorageAccount
	name: 'default'
	properties: {
	shareDeleteRetentionPolicy: {
		enabled: true
		days: 7
	}
	}
}//mainStorage_fileservices

resource mainStorage_fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
	parent: mainStorage_fileservices
	name: SolutionObj.functionAppName
	properties: {
	accessTier: 'TransactionOptimized'
	shareQuota: 5120
	enabledProtocols: 'SMB'
	}  
}//mainStorage_fileshare


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
var storageAccountId = (!DeployObject.MainStorageExists) ?  mainStorageAccount.id : existingMainStorageAccount.id
var storageAccountName = (!DeployObject.MainStorageExists) ?  mainStorageAccount.name :existingMainStorageAccount.name
var apiVersion = (!DeployObject.MainStorageExists) ? mainStorageAccount.apiVersion :existingMainStorageAccount.apiVersion
var storageAccountKey =  listKeys(storageAccountId, apiVersion).keys[0].value
output storageAccountIdOut string = storageAccountId
output storageAccountNameOut string = storageAccountName
output apiVersionOut string = apiVersion
output storageAccountKeyOut string = storageAccountKey
//*/
var storageAccountName =   mainStorageAccount.name 
var storageAccountId = mainStorageAccount.id
var apiVersion = mainStorageAccount.apiVersion 
var storageAccountKey =  listKeys(storageAccountId, apiVersion).keys[0].value
//var allowedOrigins = DeployObject.WebSiteExists ? '${SolutionObj.webProtocol}${webApp.properties.defaultHostName}'
//'${SolutionObj.webProtocol}${webApp.properties.defaultHostName}'



var MainStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'
resource secret_MainStorageAccessKey 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
	name: 'MainStorageAccessKey'
	parent: keyVault
	tags:tags
	properties: {
	value: MainStorageAccessKey
	attributes:{
		enabled:true
	}
	}
}

/**/
var settingName = 'Send to Workspace and Audit Storage'
resource diagnosticsSettingsBlob_MainStorage 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  if(DeployObject.DefaultWorkspaceId != null) {
	name: settingName
	scope: mainStorage_blobServices
	properties: {
	workspaceId: SolutionObj.workspaceId
	storageAccountId: resourceId('Microsoft.Storage/storageAccounts', SolutionObj.auditStorageAccountName)
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
	dependsOn:[
	 mainStorageAccount
	]
}
//*/


output MainStorageName string = mainStorageAccount.name
output MainStorageResourceId string = mainStorageAccount.id
output MainStorageBlobEndpoint string = mainStorageAccount.properties.primaryEndpoints.blob
//output MainStorageAccessKey string = MainStorageAccessKey

/*
output MainStorageResourceUsed string =  (DeployObject.MainStorageExists) ? 'Using existingMainStorageAccount' : 'Using NEW MainStorageAccount'
output MainStorageResourceId string =  (DeployObject.MainStorageExists) ? existingMainStorageAccount.id : mainStorageAccount.id
output MainStorageBlobEndpoint string = (DeployObject.MainStorageExists) ? existingMainStorageAccount.properties.primaryEndpoints.blob : mainStorageAccount.properties.primaryEndpoints.blob
//output MainStorageAccessKey string = MainStorageAccessKey
//*/


/*
output MainStorageName string = newMainStorageAccount.name
output MainStorageSystemPrincipalId string = (DeployObject.MainStorageExists) ? existingMainStorageAccount.identity.principalId //newMainStorageAccount.identity.principalId

output MainStorageResourceId string = (DeployObject.MainStorageExists) ? existingMainStorageAccount.id : newMainStorageAccount.id
output mainStorageBlobEndpoint string = (DeployObject.MainStorageExists) ? existingMainStorageAccount.properties.primaryEndpoints.blob : newMainStorageAccount.properties.primaryEndpoints.blob
output MainStorageAccessKey string = MainStorageAccessKey
//*/
//output blobDiagnosticsSettingId string = diagnosticsSettingsBlob_MainStorage.id

//output AzureWebJobsStorage string = AzureWebJobsStorage
//*/