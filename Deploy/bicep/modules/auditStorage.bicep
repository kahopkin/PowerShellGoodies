

targetScope = 'resourceGroup'
//param tenantId string = subscription().tenantId
param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object

@description('the sku')
param storageAccountSkuName string

var minimumTlsVersion = 'TLS1_2' 

param storageSubnetId string
output storageSubnetIdParam string = storageSubnetId

/*
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}
var storageSubnetIdVar  = '${virtualNetwork.id}/subnets/${SolutionObj.storageSubnetName}'
output storageSubnetIdVar string = storageSubnetIdVar
//*/

/*
resource auditStorage_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
	name: SolutionObj.blobPrivateDnsZoneName
}
//*/

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: DeployObject.managedUserName  
}
//output managedUserPrincipalId string = managedUser.properties.principalId
//*/

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
	name: DeployObject.KeyVaultName
}
output keyvaultURI string = keyVault.properties.vaultUri

/**/
resource mainstorage_Blob_PrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing ={
	name:SolutionObj.blobPrivateDnsZoneName
}
//*/


resource auditStorage_blob_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
	name: SolutionObj.auditStorageBlobPrivateEndpointName
	location: location
	tags: tags
	properties: {
	privateLinkServiceConnections: [
		{
		name: '${SolutionObj.auditStorageBlobPrivateEndpointName}-link'
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



//resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = if(!DeployObject.AuditStorageExists)  {
resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
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
		//allowBlobPublicAccess: false
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
			 keyvaulturi: keyVault.properties.vaultUri
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
	}//properties
}//auditStorageAccount


resource existingAuditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = if (DeployObject.AuditStorageExists)  {
	name: SolutionObj.auditStorageAccountName
}


var storageAccountId = (!DeployObject.AuditStorageExists) ? auditStorageAccount.id : existingAuditStorageAccount.id
var storageAccountName = (!DeployObject.AuditStorageExists) ? auditStorageAccount.name : existingAuditStorageAccount.name
//var apiVersion = (!DeployObject.AuditStorageExists) ? auditStorageAccount.apiVersion : existingAuditStorageAccount.apiVersion
//var storageAccountKey = listKeys(storageAccountId, apiVersion).keys[0].value


 //var auditStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'
//var auditStorageAccessKeyOld = 'DefaultEndpointsProtocol=https;AccountName=${auditStorageAccount.name};AccountKey=${listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
var auditStorageAccessKey = 'DefaultEndpointsProtocol=https;AccountName=${auditStorageAccount.name};AccountKey=${listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output auditStorageAccessKey string = auditStorageAccessKey



resource secret_auditStorageAccessKey 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
	name: 'auditStorageAccessKey'
	parent: keyVault
	tags:tags
	properties: {
	value: auditStorageAccessKey
	attributes:{
	enabled:true
	}
	}
}


resource auditStAccount_blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' =  { 
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

resource auditStAccount_tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' =  {
	parent: auditStorageAccount
	name: 'default'  
}

//output AuditStorageSystemPrincipalId string = auditStorageAccount.identity.principalId
output auditStorageResourceId string = storageAccountId
output AuditStorageName string = storageAccountName