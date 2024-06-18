targetScope = 'resourceGroup'

param location string

param DeployObject object 
param SolutionObj object
param tags object

//param serverFarmId string
param storageAccountName string

param ApiClientId string
//param AppServicePrincipalId string

//@secure()
//param ApiClientSecret string
param functionSubnetId string
//param RoleDefinitionId string 


var AppName = DeployObject.AppName
var Solution = DeployObject.Solution
var Environment = DeployObject.Environment
var SolutionName = DeployObject.SolutionName 
var WebSiteName = SolutionObj.WebSiteName
var FunctionAppName = SolutionObj.FunctionAppName


var funcPrivateEndpointName ='pep-func-${SolutionName}'

var functionRuntime = 'dotnet'
var netFrameworkVersion = 'v6.0'
@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId
var subscriptionID = subscription().subscriptionId
output subscriptionID string = subscriptionID
//var privateDNSZoneName  = 'privatelink.azurewebsites.us'
//var keyVaultName = (length('kv-${SolutionName}') >23 ) ? substring('kv-${SolutionName}',0,24) : 'kv-${SolutionName}'

//var functionAppKeySecretName = 'FunctionAppHostKey'
//var SolutionNameSt = '${toLower(AppName)}${toLower(Solution)}${toLower(DeployObject.Environment)}'
//var auditStAccountName = (length('staudit${SolutionNameSt}001') >23 ) ? substring('staudit${SolutionNameSt}001',0,24) : 'staudit${SolutionNameSt}001'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
	name: DeployObject.KeyVaultName
}

var subnetId = '${virtualNetwork.id}${functionSubnetName}'
output subnetId string = subnetId

var functionSubnetName = '/subnets/snet-function-${SolutionName}'
resource functionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' existing = {
	parent: virtualNetwork
	name: functionSubnetName
}
//output functionSubnetId string = functionSubnet.id
output functionSubnetName string = functionSubnet.name


resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
	name:storageAccountName
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
	name:SolutionObj.auditStorageAccountName
}

var aspName = 'asp-${SolutionName}'
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
	name: aspName
}
resource webapp 'Microsoft.Web/sites@2020-06-01' existing = {
	name: WebSiteName
}

var appInsightsName = 'appi-${SolutionName}' 
resource apiAppInsights 'microsoft.insights/components@2020-02-02' existing= {
	name: appInsightsName  
}


var hostnamesslstate_default  = '${FunctionAppName}.azurewebsites.us'
var hostnamesslstate_scm  =  '${FunctionAppName}.scm.azurewebsites.us'
output hostnamesslstate_scm string = hostnamesslstate_scm

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
	name: FunctionAppName
	location: location
	tags: tags
	kind: 'functionapp'
	identity: {
	type: 'SystemAssigned'
	}
	properties: {
	enabled: true
	serverFarmId: appServicePlan.id
	httpsOnly: true
	clientAffinityEnabled: true
	storageAccountRequired: false
	clientCertMode: 'Required'
	virtualNetworkSubnetId: functionSubnetId
	keyVaultReferenceIdentity: 'SystemAssigned'
	hostNameSslStates: [
		{
		name: hostnamesslstate_default
		//name: '${FunctionAppName}.azurewebsites.us'
		sslState: 'Disabled'
		hostType: 'Standard'
		}
		{
		//name: '${FunctionAppName}.scm.azurewebsites.us'
		name: hostnamesslstate_scm
		sslState: 'Disabled'
		hostType: 'Repository'
		}
	]
	}
}



resource functionApp_ftp_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
	parent: functionApp
	name: 'ftp'
	kind: 'functionApp'
	location: location
	properties: {
	allow: true
	}
}

resource functionApp_scm_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
	parent: functionApp
	name: 'scm'
	kind: 'functionApp'
	location: location
	properties: {
	allow: true
	}
}


param baseTime string = utcNow('u')
var add3Years = dateTimeAdd(baseTime, 'P3Y')
output add3years string = add3Years

// Specifying configuration for the SAS token; not all possible fields are included
//Examples of valid permissions settings for a container include rw, rd, rl, wd, wl, and rl.
var sasConfig = {
	//canonicalizedResource: '/blob/${mainStorageAccount.name}/mycontainer/some/path/test.py' // Specific blob in the container
	signedResourceTypes: 'sc'
	signedPermission: 'rw'
	signedServices: 'b'
	signedExpiry: add3Years
	signedProtocol: 'https'
	keyToSign: 'key1'
}

// Alternatively, we could use listServiceSas function
var sasToken = mainStorageAccount.listAccountSas(mainStorageAccount.apiVersion, sasConfig).accountSasToken
//output sasToken string = sasToken
// Connection string based on a SAS token
//output connectionStringSAS string = 'BlobEndpoint=${mainStorageAccount.properties.primaryEndpoints.blob};SharedAccessSignature=${sasToken}'
//output sasTokenOut string = mainStorageAccount.listServiceSas(mainStorageAccount.apiVersion, sasConfig).serviceSasToken
// Connection string based on a SAS token
var connectionStringSAS  = '${mainStorageAccount.properties.primaryEndpoints.blob}?${sasToken}'
//output connectionStringSAS string = connectionStringSAS

resource functionApp_WebConfig 'Microsoft.Web/sites/config@2021-03-01' = {
	parent: functionApp
	name: 'web'
	properties: {
	publishingUsername: '$functionAppName'
	scmType: 'None'
	webSocketsEnabled: false
	virtualApplications: [
		{
		virtualPath: '/'
		physicalPath: 'site\\wwwroot'
		preloadEnabled: true
		}
	]
	loadBalancing: 'LeastRequests'
	vnetName: 'snet-functionintegration-${DeployObject.SolutionName}'
	vnetRouteAllEnabled: true
	vnetPrivatePortsCount: 0
	cors: {
		allowedOrigins: [
		'https://${webapp.properties.defaultHostName}'
			'https://${functionApp.properties.defaultHostName}'
			'http://localhost:3000'
		]
		supportCredentials: true
	}
	netFrameworkVersion:  netFrameworkVersion
	alwaysOn: true
	managedPipelineMode: 'Integrated'
	minTlsVersion: '1.2'
	scmMinTlsVersion: '1.2'
	//ftpsState: 'Disabled'
	ipSecurityRestrictions: [
		{
		ipAddress: 'Any'
		action: 'Allow'
		priority: 1
		name: 'Allow all'
		description: 'Allow all access'
		}
	]
	scmIpSecurityRestrictions: [
		{
		ipAddress: 'Any'
		action: 'Allow'
		priority: 1
		name: 'Allow all'
		description: 'Allow all access'
		}
	]
	}
}


resource functionApp_AppSettings_Transfer 'Microsoft.Web/sites/config@2021-03-01' = {
	parent: functionApp
	name: 'appsettings'
	properties:{ 
	APPINSIGHTS_INSTRUMENTATIONKEY: apiAppInsights.properties.InstrumentationKey
	APPLICATIONINSIGHTS_CONNECTION_STRING: apiAppInsights.properties.ConnectionString 
	AuditStorageAccessKey: 'DefaultEndpointsProtocol=https;AccountName=${auditStorageAccount.name};AccountKey=${listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
	AzEnvAuthenticationEndpoint: environment().authentication.loginEndpoint
	AzEnvGraphEndpoint: environment().graph
	AzEnvKeyVaultSuffix: environment().suffixes.keyvaultDns
	AzEnvManagementEndpoint: DeployObject.ServiceManagementUrl
	//AzEnvManagementEndpoint: 'https://management.core.usgovcloudapi.net/'
	AzEnvName: environment().name
	AzEnvResourceManagerEndpoint: environment().resourceManager
	AzEnvStorageEndpointSuffix: environment().suffixes.storage
	//AzStorageAccessKey: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=AzStorageAccessKey)'
	AzStorageAccessKey : 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
	AzureWebJobsSecretStorageType: 'files'
	AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
	blobEndpoint: 'https://${mainStorageAccount.name}.blob.${environment().suffixes.storage}'
	clientID: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APIclientID)'
	clientSecret: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APIclientSecret)'
	createCTSContainer: 'false'
	ctsStorageSASUri: connectionStringSAS
	deleteAuditBlobContainerName: 'insights-logs-storagedelete'
	DtpDataStorageAccessKey: 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
	DtpTransferLifetime: '1.00:00:00'
	EnableDtsDataCleanup: false
	ExpirationCheckInterval: '0 */15 * * *' //15 minutes
	FUNCTIONS_EXTENSION_VERSION: '~4'
	FUNCTIONS_WORKER_RUNTIME: functionRuntime
	MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APIclientSecret)'
	//ftpState: 'Disabled'
	readAuditBlobContainerName: 'insights-logs-storageread'
	roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
	sentinelTimer: '0 59 23 * * *'
	SqlConnectionString: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=SqlConnectionString)'
	//storageAccountResourceID: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=storageAccountResourceID)'
	storageAccountResourceID: mainStorageAccount.id
	subscriptionID: subscriptionID
	tenantID: tenantId
	TransferAbsoluteLifetime: '60.00:00:00' //60 days
	validationTimeOut: '10'
	WEBSITE_CONTENTOVERVNET: '1'
	WEBSITE_CONTENTSHARE: toLower(FunctionAppName)
	WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
	WEBSITE_DNS_SERVER: '168.63.129.16'
	WEBSITE_RUN_FROM_PACKAGE: '1' 
	//WEBSITE_VNET_ROUTE_ALL : '1'
	writeAuditBlobContainerName: 'insights-logs-storagewrite'
	XDT_MicrosoftApplicationInsights_Mode: 'Recommended' 
	} 
}

resource functionApp_AuthSettingsv2 'Microsoft.Web/sites/config@2022-03-01' = {
	name: 'authsettingsV2'
	kind: 'functionapp'
	parent: functionApp
	properties: {
	globalValidation: {
		requireAuthentication: true
		unauthenticatedClientAction: 'Return401'
	}
	httpSettings: {
		forwardProxy: {
		convention: 'NoProxy'
		}
		requireHttps: true
		routes: {
		apiPrefix: '/.auth'
		}
	}
	identityProviders: {
		azureActiveDirectory: {
		enabled: true
			login: {
			disableWWWAuthenticate: false
			}
		registration: {
			clientId: ApiClientId
			clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
			openIdIssuer: 'https://sts.windows.net/${tenantId}/v2.0'
			//openIdIssuer: SolutionObj.openIdIssuer
		}
		validation: {
			allowedAudiences: [
			 'api://${ApiClientId}'
			]
			defaultAuthorizationPolicy: {
			allowedPrincipals: {}
			}
		}
		}
	}
	login: {
		tokenStore: {
		enabled: true
		}
	}
	}
}
//*/

resource functionApp_HostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
	parent: functionApp
	//name: '${FunctionAppName}.azurewebsites.us'
	name: hostnamesslstate_default
	properties: {
	siteName: SolutionObj.FunctionAppName
	hostNameType: 'Verified'
	}
}

resource functionApp_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' =  {
	name: funcPrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: subnetId
	}
	privateLinkServiceConnections: [
		{
		name: funcPrivateEndpointName
			properties: {
			privateLinkServiceId: functionApp.id
			groupIds: [
			'sites'
			]
		}
		}
	]

	}
}
//*/

resource functionApp_VirtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
	parent: functionApp
	name: '${FunctionAppName}-virtualNetworkConnection'
	properties: {
	vnetResourceId: functionSubnetId
	isSwift: true
	}
}

resource ReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
	scope: subscription()
	// This is the id for Reader azure role
	name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}
output ReaderRoleDefinitionName string = ReaderRoleDefinition.name
output ReaderRoleDefinitionId string = ReaderRoleDefinition.id
output SystemAssignedIdentityId string = functionApp.identity.principalId
output SystemAssignedPrincipalIdentity object = functionApp.identity
var SystemAssignedPrincipalId  = functionApp.identity.principalId

var webapp_privateDNSZoneName  = 'privatelink.azurewebsites.us'
resource webapp_privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01' existing= {
	name: webapp_privateDNSZoneName
}
resource functionApp_privateDNSZoneVirutalNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =  {
	parent: webapp_privateDNSZone
	name: '${webapp_privateDNSZoneName}-link'
	tags: tags
	location: 'global'
	properties: {
	registrationEnabled: false
	virtualNetwork: {
		id: virtualNetwork.id
	}
	}
}

resource webapp_privateEndpoint_privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' =  {
	parent: functionApp_PrivateEndpoint
	name: 'dnsgroupname'
	properties: {
	privateDnsZoneConfigs: [
		{
		name: 'config1'
		properties: {
			privateDnsZoneId: webapp_privateDNSZone.id
		}
		}
	]
	}
}

/*
resource readerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
	scope: keyVault
	name: guid(resourceGroup().id, functionApp.identity.principalId, ReaderRoleDefinition.id)
	properties: {
	roleDefinitionId: ReaderRoleDefinition.id
	principalId: SystemAssignedPrincipalId
	principalType: 'ServicePrincipal'
	}
}
//*/

resource functionAppKeyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
	name: 'add'
	parent: keyVault
	properties: {
	accessPolicies: [
		{
		//applicationId: ApiClientId
		objectId: SystemAssignedPrincipalId
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

var functionAppUrl = 'https://${functionApp.properties.defaultHostName}'
output functionAppHostName string = functionApp.properties.defaultHostName
output functionAppUrl string = functionAppUrl


//output readerRoleAssignmentprincipalId string = readerRoleAssignment.properties.principalId
//output readerRoleAssignmentId string = readerRoleAssignment.id
//var readerAssignmentprincipalId = readerRoleAssignment.properties.principalId
//output delegatedManagedIdentityResourceId string = readerRoleAssignment.properties.delegatedManagedIdentityResourceId
//add access to the keyvault for the app
/*resource functionAppKeyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
	name: 'add'
	parent: keyVault
	properties: {
	accessPolicies: [
		{
		applicationId: ApiClientId
		objectId: readerAssignmentprincipalId
		permissions: {
			certificates: []
			keys: []
			secrets: [
			'Get'
			]
			}
		tenantId: tenantId
		}
		{
		applicationId: ApiClientId
		objectId: AppServicePrincipalId
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


//*/

//@description('The name of the virtual network subnet to be associated with the Azure Function app.')
//var functionSubnetName = '/subnets/snet-function-${SolutionName}'
//var functionSubnetName = 'snet-functionintegration-${SolutionName}'
//var functionSubnetName = 'snet-function-${SolutionName}'
//var functionSubnetName = '/subnets/snet-function-${SolutionName}'

//param connectionStringSAS string
//param ctsStorageName string
//param appServiceName string 
//@secure()
//@description('The administrator login password for the SQL server.')
//param sqlServerAdministratorPassword string
/*
var sqlServerName ='sql-${SolutionName}'
resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = if(Solution == 'Transfer'){
	name:sqlServerName
}
resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = if(Solution == 'Transfer') {
	name: 'sqldb-${SolutionName}'
}
//*/

/*
resource apiAppInsights 'microsoft.insights/components@2020-02-02' existing= {
	name: 'appi-${SolutionName}'  
}
*/

//*/

/*
resource ctsStorageAccount'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
	name:ctsStorageName
}
//*/
/*

/*
//adds secret with the function app's host key.
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
	//parent: keyvault
	name: '${DeployObject.KeyVaultName}/${functionAppKeySecretName}'
	dependsOn:[keyVault]
	properties: {
	value: listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
	}
}
//*/	
/*
resource apiLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
	name: 'log-${SolutionName}'  
}
//*/

//var contentShare  = split(SolutionName,'-')[0]
//output contentShare string = contentShare

/*
resource functionApp_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
	name: funcPrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: subnetId
	}
	privateLinkServiceConnections: [
		{
		name: funcPrivateEndpointName
			properties: {
			privateLinkServiceId: functionApp.id
			groupIds: [
			'sites'
			]
		}
		}
	]

	}
}
//*/

/*
resource functionApp_VirtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
	parent: functionApp
	name: '${functionAppName}-virtualNetworkConnection'
	properties: {
	vnetResourceId: functionSubnetId
	isSwift: true
	}
}
//*/
/*
resource privateDnsZone_api_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
	parent: webapp_privateDNSZone
	name: functionAppName
	properties: {
	ttl: 10
	aRecords: [
		{
		ipv4Address: webAppInboundIP
		}
	]
	}
}

/*
resource func_privateEndpointConnection 'Microsoft.Web/sites/privateEndpointConnections@2021-03-01' = {
	parent: functionApp
	name: funcPrivateEndpointName
	properties: {
	privateLinkServiceConnectionState: {
		status: 'Approved'
		actionsRequired: 'None'
	}
	}
}

resource functionApp_virtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
	parent: functionApp
	name: '${functionAppName}-virtualNetworkConnection'
	properties: {
	vnetResourceId: functionSubnetId
	isSwift: true
	}
}

/*
resource function_virtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
	parent: functionApp
	name:'${funcPrivateEndpointName}-link'
	properties: {
	vnetResourceId: functionSubnetId
	}
}
//*/

/*
resource func_privateEndpointConnection 'Microsoft.Web/sites/privateEndpointConnections@2021-03-01' = {
	parent: functionApp
	name: '${funcPrivateEndpointName}-connection'
	properties: {
	privateLinkServiceConnectionState: {
		status: 'Approved'
		actionsRequired: 'None'
	}
	}
}
//*/

//WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}' 

/*
resource funcAuthSetting 'Microsoft.Web/sites/config@2022-03-01' = {
	name: 'authsettings'
	kind: 'string'
	parent: functionApp
	properties: {
	clientId: ApiClientId
	//clientSecret: ApiClientSecret
	clientSecretSettingName: 'clientSecret'
	defaultProvider: 'AzureActiveDirectory'
	enabled: true
	issuer:  'https://sts.windows.net/${tenantId}'
	validateIssuer: true
	unauthenticatedClientAction:'RedirectToLoginPage'
	}
}
//*/
/*
appSettings: [
		{
			name: 'AzureWebJobsStorage'
			value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${storageAccount.name}-${appInternalServiceName}-ConnectionString)'
		}
		{
			name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
			value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${storageAccount.name}-${appInternalServiceName}-ConnectionString)'
		}
*/
