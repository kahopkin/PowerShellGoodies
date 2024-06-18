targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object
param tags object

param keyVaultProps object

//param keyvaultSubnetId string
param StorageAccountsArr array
output StorageAccountsArrOut array = StorageAccountsArr

@description('Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
//@secure()
param entities  array 

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId

resource applicationInsights 'Microsoft.insights/components@2020-02-02' existing = {
	name: SolutionObj.appInsightsName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

var keyvaultSubnetId  = '${virtualNetwork.id}/subnets/${SolutionObj.keyvaultSubnetName}'
output keyvaultSubnetId string = keyvaultSubnetId


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
	name: SolutionObj.logAnalyticsWorkspaceName				
}

/**/
resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: SolutionObj.managedUserName  
}
output managedUserClientId string = managedUser.properties.clientId
//*/

/**/
// -- Private DNS Zones --
resource keyvaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
	name: SolutionObj.keyVaultPrivateDnsZoneName
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
var webappPrivateEndpointName = 'pep-site-${DeployObject.SolutionName}'
output webappPrivateEndpointNameOut string = webappPrivateEndpointName
resource keyvaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: SolutionObj.keyVaultPrivateEndpointName
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
	resource keyvaultPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
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
//NEW
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
//resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' =  {
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
			keys: keyVaultProps.keys
			secrets:keyVaultProps.secrets
			certificates:keyVaultProps.certificates
		}
		}
		{
		objectId: SolutionObj.CurrUserId
		tenantId: tenantId
		permissions: {
			keys: keyVaultProps.keys
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
//*/

/**/
//EXISTING
resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = if(DeployObject.KeyVaultExists) {
	name: DeployObject.KeyVaultName 
}
//*/
//output keyvaulturi string = (DeployObject.KeyVaultExists) ? existingKeyVault.properties.vaultUri : keyVault.properties.vaultUri
output keyvaulturi string = keyVault.properties.vaultUri


resource cmk_AuditStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
	parent: keyVault
	name: SolutionObj.cmkAuditStorageKeyName
	//tags: tags
	properties: {
	attributes: {
		enabled: true
	}
	keySize: 2048
	kty:'RSA'
	}
}

resource cmk_MainStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' ={
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
}


resource cmk_SqlDatabaseKey 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
	parent: keyVault
	name: SolutionObj.cmkSqlKeyName
	properties: {
	attributes: {
		enabled: true
	}
	keySize: 2048
	kty:'RSA'
	}
}


//Create secrets with the API appId, secret, SQL admin login info
resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret  in entities:{
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


resource createRgLock 'Microsoft.Authorization/locks@2016-09-01' = if(!DeployObject.DebugFlag ){
	name: 'KeyVaultLock'
	//scope: (DeployObject.KeyVaultExists) ? existingKeyVault : keyVault
	scope:  keyVault
	properties: {
	level: 'CanNotDelete'
	notes: 'KeyVault should not be deleted.'
	}
}

var settingName = 'Send to Workspace and Audit Storage'
//resource keyVaultDiagnosticsSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
resource keyVaultDiagnosticsSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(DeployObject.DefaultWorkspaceId != null){
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


//output keyVaultResourceId string = (DeployObject.KeyVaultExists) ? existingKeyVault.id : keyVault.id 
//output keyVaultUri string = (DeployObject.KeyVaultExists) ? existingKeyVault.properties.vaultUri : keyVault.properties.vaultUri  
output keyVaultResourceId string = keyVault.id 
output keyVaultUri string = keyVault.properties.vaultUri  
output cmk_AuditStorageKeyName string = cmk_AuditStorage.name
output cmk_AuditStorageKeyId string = cmk_AuditStorage.id
output cmk_AuditStorageKeyUri string =  cmk_AuditStorage.properties.keyUri
output cmk_AuditStorageKeyWithVersion string = cmk_AuditStorage.properties.keyUriWithVersion

output cmk_MainStorageKeyName string =   cmk_MainStorage.name
output cmk_MainStorageKeyId string =  cmk_MainStorage.id
output cmk_MainStorageKeyUri string =  cmk_MainStorage.properties.keyUri
output cmk_MainStorageKeyWithVersion string = cmk_MainStorage.properties.keyUriWithVersion

output cmkSqlKeyName string = cmk_SqlDatabaseKey.name
output cmkSqlKeyId string =  cmk_SqlDatabaseKey.id 
output cmkSqlKeyUri string =  cmk_SqlDatabaseKey.properties.keyUri 
output cmkSqlKeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
/*
output cmk_AuditStorageKeyName string = (!DeployObject.KeyVaultExists) ? cmk_AuditStorage.name: ''
output cmk_AuditStorageKeyId string = (!DeployObject.KeyVaultExists) ? cmk_AuditStorage.id
output cmk_AuditStorageKeyUri string = (!DeployObject.KeyVaultExists) ?  cmk_AuditStorage.properties.keyUri
output cmk_AuditStorageKeyWithVersion string = (!DeployObject.KeyVaultExists) ? cmk_AuditStorage.properties.keyUriWithVersion

output cmk_MainStorageKeyName string = (!DeployObject.KeyVaultExists) ?   cmk_MainStorage.name
output cmk_MainStorageKeyId string = (!DeployObject.KeyVaultExists) ?  cmk_MainStorage.id
output cmk_MainStorageKeyUri string = (!DeployObject.KeyVaultExists) ?  cmk_MainStorage.properties.keyUri
output cmk_MainStorageKeyWithVersion string = (!DeployObject.KeyVaultExists) ? cmk_MainStorage.properties.keyUriWithVersion

output cmkSqlKeyName string = cmk_SqlDatabaseKey.name
output cmkSqlKeyId string =  cmk_SqlDatabaseKey.id 
output cmkSqlKeyUri string =  cmk_SqlDatabaseKey.properties.keyUri 
output cmkSqlKeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
//*/


/*

param permissionsObj object = {
	name: 'permissions' 
	keys: keyVaultProps.keys
	secrets: keyVaultProps.secrets
	certificates: keyVaultProps.certificates
}


module addCurrentUserKeyVaultAccess 'nested_addAccessPolicy.bicep' = if(DeployObject.KeyVaultExists){
	name: 'addCurrentUserKeyVaultAccess'
	scope: resourceGroup(resourceGroup().name)
	params: {
	principalObjId: DeployObject.CurrUserId
	keyVaultName: DeployObject.KeyVaultName
	permissionsObj: permissionsObj
	}
	dependsOn:[
	keyVault
	existingKeyVault
	]
}


module addDeveloperGroupKeyVaultAccessPolicy 'nested_addAccessPolicy.bicep' = if(DeployObject.KeyVaultExists){
	name: 'addDeveloperGroupKeyVaultAccessPolicy'
	scope: resourceGroup(resourceGroup().name)
	params: {
	principalObjId: SolutionObj.developerGroupId
	keyVaultName: DeployObject.KeyVaultName
	permissionsObj: permissionsObj
	}   
 
	dependsOn:[
	keyVault
	existingKeyVault
	]  
}

module addManagedUserAccessPolicy 'nested_addAccessPolicy.bicep' = if(DeployObject.KeyVaultExists && DeployObject.ManagedUserExists){
	name: 'addManagedUserKeyVaultAccess'
	scope: resourceGroup(resourceGroup().name)
	params: {
	principalObjId: managedUser.properties.principalId
	keyVaultName: DeployObject.KeyVaultName
	permissionsObj: permissionsObj
	}
	dependsOn:[
	keyVault
	existingKeyVault
	]
}
*/

	/*
resource keyvaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
	name: SolutionObj.keyVaultPrivateDnsZoneName
}
//*/
