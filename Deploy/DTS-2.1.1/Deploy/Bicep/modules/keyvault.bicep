targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object

param keyVaultProps object

//param keyvaultSubnetId string
param StorageAccountsArr array

@description('Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
//@secure()
param entities  array 

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId

//var cmkMainStorageKeyName ='cmk-${StorageAccountsArr[0]}-${DeployObject.SolutionName}'
//output cmkMainStorageKeyName string = cmkMainStorageKeyName
//var cmkAuditStorageKeyName = 'cmk-${StorageAccountsArr[1]}-${DeployObject.SolutionName}'
//var cmkSqlDatabaseKeyName = 'cmk-sqldb-${DeployObject.SolutionName}'

//var webapp_dns_name  = '.usgovcloudapi.net'
//var privateKeyVaultDnsZoneName = 'privatelink.vaultcore${webapp_dns_name}'
//var privateKeyVaultEndpointName = 'pep-kv-${DeployObject.SolutionName}'

resource applicationInsights 'Microsoft.insights/components@2020-02-02' existing = {
	name: SolutionObj.appInsightsName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}
var keyvaultSubnetId  = '${virtualNetwork.id}/subnets/${SolutionObj.keyvaultSubnetName}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
	name: SolutionObj.logAnalyticsWorkspaceName				
}

/**/
resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: SolutionObj.managedUserName  
}
output managedUserClientId string = managedUser.properties.clientId
//*/


// -- Private DNS Zones --
resource keyvaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.keyVault_PrivateDnsZoneName
	location: 'global'
	tags: tags
	resource keyvaultDnsZoneLink 'virtualNetworkLinks' = {
	name: '${keyvaultDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}
//*/

// -- Private Endpoints --

resource keyvaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.keyVault_PrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: keyvaultSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: '${DeployObject.KeyVaultName}-PrivateLinkConnection'
		properties: {
			privateLinkServiceId: keyVault.id
			groupIds: [
			'vault'
			]
		}
		}
	]
	}

	resource keyvaultPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' =  {
	name: 'keyvaultPrivateDnsZoneGroup' 
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'config'
			properties: {
			privateDnsZoneId: keyvaultDnsZone.id
			}
		}
		]
	}
	}//keyvaultPrivateEndpointDnsZoneGroup
}//keyvaultPrivateEndpoint
//*/

output AzureResourcesKeyVault bool = DeployObject.AzureResources.KeyVault
output KeyVaultExists bool = DeployObject.KeyVaultExists

//var keyvaultURI =  'https://${DeployObject.KeyVaultName}.vault.usgovcloudapi.net/'
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
	name: DeployObject.KeyVaultName
	location: location
	tags: tags
	properties: {
	enabledForDeployment: keyVaultProps.enabledForDeployment
	enabledForTemplateDeployment: keyVaultProps.enabledForTemplateDeployment
	enabledForDiskEncryption: keyVaultProps.enabledForDiskEncryption
	enableSoftDelete: keyVaultProps.enableSoftDelete
	softDeleteRetentionInDays: keyVaultProps.softDeleteRetentionInDays
	enableRbacAuthorization:keyVaultProps.enableRbacAuthorization
	enablePurgeProtection:keyVaultProps.enablePurgeProtection
	tenantId: tenantId
	accessPolicies: [
		{
		objectId: managedUser.properties.principalId
		tenantId: tenantId
			permissions: {
			 keys: keyVaultProps.keysPermissions
			 secrets:keyVaultProps.secrets
			 certificates:keyVaultProps.certificates
		}
		}
		{
		objectId: SolutionObj.CurrUserId
		tenantId: tenantId
		permissions: {
			keys: keyVaultProps.keysPermissions
			secrets:keyVaultProps.secrets
			certificates:keyVaultProps.certificates
		}
		}
	]
	sku: {
		name: keyVaultProps.skuName
		family: keyVaultProps.family
	}
	networkAcls: {
		defaultAction: 'Deny'
		bypass: 'AzureServices'
		ipRules:  (DeployObject.DebugFlag) ? [
		{
			value: SolutionObj.myIP
			action: 'Allow'
		}
		] : []
		virtualNetworkRules: [
			{
				id: keyvaultSubnetId
				ignoreMissingVnetServiceEndpoint: true
			}
		]
		}
	}//properties 
}//keyVault

output keyvaulturi string = keyVault.properties.vaultUri


resource cmk_MainStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
	parent: keyVault
	name: SolutionObj.cmkMainStorageKeyName
	//tags: tags
	properties: {
	attributes: {
		enabled: true
	}
	keySize: 2048
	kty:'RSA'
	}
}//cmk_MainStorage

output cmk_MainStorageKeyId string = cmk_MainStorage.id
output cmk_MainStorageKeyUri string = cmk_MainStorage.properties.keyUri
output cmk_MainStorageKeyWithVersion string = cmk_MainStorage.properties.keyUriWithVersion
resource cmk_AuditStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' ={
	parent: keyVault
	name: SolutionObj.cmkAuditStorageKeyName
 // tags: tags
	properties: {
	attributes: {
		enabled: true
	}
	keySize: 2048
	kty:'RSA'
	}
}//cmk_AuditStorage

output cmk_AuditStorageKeyId string = cmk_AuditStorage.id
output cmk_AuditStorageKeyUri string = cmk_AuditStorage.properties.keyUri
output cmk_AuditStorageKeyWithVersion string = cmk_AuditStorage.properties.keyUriWithVersion

resource cmk_SqlDatabaseKey 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' ={
	parent: keyVault
	name: SolutionObj.cmkSqlKeyName
	properties: {
	attributes: {
		enabled: true
	}
	keySize: 2048
	kty:'RSA'
	}
}//cmk_SqlDatabaseKey

//output cmk_SqlkeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
output cmkSqlKeyUri string = cmk_SqlDatabaseKey.properties.keyUri 
output cmkSqlKeyId string =  cmk_SqlDatabaseKey.id 

//Create secrets with the API appId, secret, SQL admin login info
resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret  in entities: {
	name: secret.secretName
	parent: keyVault
	tags:tags
	properties: {
	value: secret.secretValue
	attributes:{
	enabled:secret.enabled
	}
	}
}]



resource secret_APPLICATIONINSIGHTS_CONNECTION_STRING 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
	name: 'APPLICATIONINSIGHTS-CONNECTION-STRING'
	parent: keyVault
	tags:tags
	properties: {
	value: applicationInsights.properties.ConnectionString
	attributes:{
		enabled:true
	}
	}
}

resource secret_APPINSIGHTS_INSTRUMENTATIONKEY 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' =  {
	name: 'APPINSIGHTS-INSTRUMENTATIONKEY'
	parent: keyVault
	tags:tags
	properties: {
	value: applicationInsights.properties.InstrumentationKey
	attributes:{
		enabled:true
	}
	}
}

/*

resource createRgLock 'Microsoft.Authorization/locks@2016-09-01' = if(!DeployObject.DebugFlag ){
	name: 'KeyVaultLock'
	//scope: (DeployObject.KeyVaultExists) ? existingKeyVault : keyVault
	scope:  keyVault
	properties: {
	level: 'CanNotDelete'
	notes: 'KeyVault should not be deleted.'
	}
}

*/


var settingName = 'Send to Workspace and Audit Storage'
//resource keyVaultDiagnosticsSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
resource keyVaultDiagnosticsSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: settingName
	scope: keyVault
	properties: {
	workspaceId: logAnalyticsWorkspace.id
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



/*output CryptoEncryptRoleIdIn string = CryptoEncryptRoleId
output roleDefinitionIdToSet string = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', CryptoEncryptRoleId)

resource encryptionUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
	name: CryptoEncryptRoleId
	scope: keyVault
	properties: {
	description: 'Read metadata of keys and perform wrap/unwrap operations. Only works for key vaults that use the "Azure role-based access control" permission model.'
	principalId: managedUser.properties.principalId
	principalType: 'ServicePrincipal'
	roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', CryptoEncryptRoleId)
	}
}
//*/


output usrIdName string = managedUser.id
output keyVaultId string = keyVault.id
