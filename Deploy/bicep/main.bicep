targetScope = 'subscription'


@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(3)
@maxLength(30)
param AppName string

@description('This determines if we are deploying the DTP (Transfer) or DPP (DPP)')
@allowed([
	'All'
	'Transfer'
	'Pickup'  
])
param Solution string 

@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
	'Test'
	'Prod'
	'Dev'
])

param Environment string
@description('The Azure region into which the resources should be deployed.')

/*
//output environmentOutput object = environment()
output AppName string = AppName
output Solution string = Solution
output Environment string = Environment
//*/

param location string = deployment().location

param DeployObject object



param TimeStamp string
param DeployDate string = TimeStamp //= split(TimeStamp, ' ')[0]
param DeployTime string = split(TimeStamp, ' ')[1]

param Tags object = {
	DeployDate: DeployDate
	DeployTime: DeployTime
	Environment: DeployObject.Environment
	DeployedBy: DeployObject.CurrUserName
	Owner: DeployObject.CurrUserName
	Solution: DeployObject.Solution
}

//param SolutionName string = '${toLower(DeployObject.AppName)}-${toLower(DeployObject.Solution)}-${toLower(DeployObject.Environment)}'

//Parameters from the parameter file:
param storageAccountSkuName string
param StorageAccountsArr array

param appServicePlanSku object
param keyVaultProps object

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object
//*/

//This array is being used to create the secrets in the keyvault
param  entities array =  [
	{
	secretName: 'ApiClientId'
	secretValue: DeployObject.APIAppRegAppId
	enabled: true
	} 
	{
	secretName: 'ApiClientSecret'
	secretValue: DeployObject.APIAppRegSecret
	enabled: true
	} 
	{
	secretName: 'RoleDefinitionId'
	secretValue: DeployObject.RoleDefinitionId
	enabled: true
	} //*/
	{
	secretName: 'SqlServerAdministratorLogin'
	secretValue:  DeployObject.SqlAdmin
	enabled: true
	}
	{
	secretName: 'SqlServerAdministratorPassword'
	secretValue:  DeployObject.SqlAdminPwd
	enabled: true
	} 
] //entities

//param WebSiteName string =  '${toLower(DeployObject.ClientAppRegName)}' 
//param FunctionAppName string = '${toLower(DeployObject.APIAppRegName)}' 

//param WebSiteName string =  '${toLower(DeployObject.ClientAppRegName)}' 
//param FunctionAppName string = '${toLower(DeployObject.APIAppRegName)}' 


param SolutionNameSt string = '${toLower(DeployObject.AppName)}${toLower(DeployObject.Solution)}${toLower(DeployObject.Environment)}'

param protocol string = 'https://'

param SolutionObj object ={
	environment: DeployObject.Environment
	solution : DeployObject.Solution
	appName : DeployObject.AppName
	//solutionName : '${toLower(DeployObject.AppName)}-${toLower(DeployObject.Solution)}-${toLower(DeployObject.Environment)}'
	solutionName : DeployObject.SolutionName

	minTlsVersion : '1.2'
	netFrameworkVersion: 'v6.0'
	windowsFxVersion: '6.0'
	functionRuntime : 'dotnet'
	protocol : 'https'
	webProtocol : 'https://'

	webDomain : DeployObject.WebDomain
	webAppDNSSuffix: '.${DeployObject.WebDomain}'
	dnsSuffix : DeployObject.DnsSuffix
	openIdIssuer : '${protocol}${DeployObject.OpenIdIssuer}/${subscription().tenantId}/v2.0'

	resourceGroupName:  DeployObject.ResourceGroupName

	webSiteName :  toLower(DeployObject.ClientAppRegName)
	functionAppName :  toLower(DeployObject.APIAppRegName)
	appServicePrincipalId: DeployObject.APIAppRegServicePrincipalId 

	appServiceName: 'webapp-${DeployObject.SolutionName}'
	aspName: 'asp-${DeployObject.SolutionName}'

	appInsightsName: 'appi-${DeployObject.SolutionName}'

	currUserId: DeployObject.CurrUserId
	cryptoEncryptRoleId: DeployObject.CryptoEncryptRoleId
	contributorRoleId : DeployObject.ContributorRoleId
	developerGroupId: DeployObject.DeveloperGroupId
	workspaceId: DeployObject.DefaultWorkspaceId
	workspaceLocation : DeployObject.DefaultWorkspaceLocation

	keyVaultName: (length('kv-${DeployObject.SolutionName}') >23 ) ? substring('kv-${DeployObject.SolutionName}', 0, 24) : 'kv-${DeployObject.SolutionName}'
	auditStorageAccountName: (length('staudit${SolutionNameSt}001') >23 ) ? substring('staudit${SolutionNameSt}001',0,24) : 'staudit${SolutionNameSt}001'
	mainStorageAccountName: (length('st${SolutionNameSt}001') > 23 ) ? substring('st${SolutionNameSt}001', 0, 24) : 'st${SolutionNameSt}001'
	sqlServerName:'sql-${DeployObject.SolutionName}'
	sqlDatabaseName: 'sqldb-${DeployObject.SolutionName}'  

	logAnalyticsWorkspaceName: 'log-${DeployObject.SolutionName}'
	managedUserName: 'id-${DeployObject.SolutionName}'

	myIP: DeployObject.MyIP
	nsgName:'nsg-${DeployObject.SolutionName}'
	bastionName : 'bastion-${DeployObject.SolutionName}'

	//Private DNS Zone Names:
	webappPrivateDNSZoneName : 'privatelink.${DeployObject.WebDomain}'
	keyVaultPrivateDnsZoneName : 'privatelink.vaultcore.${DeployObject.DnsSuffix}'
	blobPrivateDnsZoneName : 'privatelink.blob.core.${DeployObject.DnsSuffix}'
	filePrivateDnsZoneName : 'privatelink.file.core.${DeployObject.DnsSuffix}'
	queuePrivateDnsZoneName : 'privatelink.queue.core.${DeployObject.DnsSuffix}'
	tablePrivateDnsZoneName : 'privatelink.table.core.${DeployObject.DnsSuffix}'
	sqlPrivateDnsZoneName : 'privatelink.database.${DeployObject.DnsSuffix}'

	//Private EndPoint Names:
	funcPrivateEndpointName : 'pep-func-${DeployObject.SolutionName}'
	sqlPrivateEndpointName : 'pep-sqldb-${DeployObject.SolutionName}'
	webappPrivateEndpointName : 'pep-site-${DeployObject.SolutionName}'
	keyVaultPrivateEndpointName : 'pep-kv-${DeployObject.SolutionName}'
	auditStorageBlobPrivateEndpointName : 'pep-st-blob-audit-${DeployObject.SolutionName}'
	mainStorageFilePrivateEndpointName : 'pep-st-file-${DeployObject.SolutionName}'
	mainStorageTablePrivateEndpointName : 'pep-st-table-${DeployObject.SolutionName}'
	mainStorageBlobPrivateEndpointName : 'pep-st-blob-${DeployObject.SolutionName}'
	mainStorage_Queue_PrivateEndpointName : 'pep-st-queue-${DeployObject.SolutionName}'

	//KeyVault Key Names
	cmkMainStorageKeyName :'cmk-st-${DeployObject.SolutionName}'
	cmkAuditStorageKeyName : 'cmk-staudit-${DeployObject.SolutionName}'
	cmkSqlKeyName : 'cmk-sqldb-${DeployObject.SolutionName}'

	auditStorageDeployment : 'auditStorage-${DeployObject.SolutionName}'
	mainStorageDeployment : 'mainstorage-${DeployObject.SolutionName}'
	
	vNetName: 'vnet-${DeployObject.SolutionName}'
	addressPrefix : '${DeployObject.AddressPrefix}.0/${DeployObject.AddressSpace}'
	
	//Subnet Names
	keyvaultSubnetName : 'snet-keyvault-${DeployObject.SolutionName}'
	webappSubnetName : 'snet-webapp-${DeployObject.SolutionName}'
	storageSubnetName : 'snet-storage-${DeployObject.SolutionName}'
	functionIntegrationSubnetName : 'snet-functionintegration-${DeployObject.SolutionName}'
	functionSubnetName : '/subnets/snet-function-${DeployObject.SolutionName }'
	bastionSubnetName : 'AzureBastionSubnet'
		
	subnets: [
			{
				name: 'default'
				privateEndpointNetworkPolicies: 'enabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'keyvault' 
				privateEndpointNetworkPolicies: 'disabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'webapp'
				privateEndpointNetworkPolicies: 'disabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'storage' 
				privateEndpointNetworkPolicies: 'disabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'function' 
				privateEndpointNetworkPolicies: 'disabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'functionintegration' 
				privateEndpointNetworkPolicies: 'enabled'
				privateLinkServiceNetworkPolicies: 'enabled'
				delegations: 'Microsoft.Web/serverfarms'
			}
			{
				name: 'AzureBastionSubnet'			
				privateEndpointNetworkPolicies: 'enabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
			 {
				name: 'GatewaySubnet'			
				privateEndpointNetworkPolicies: 'enabled'
				privateLinkServiceNetworkPolicies: 'enabled'
			}
		]
}//SolutionObj

param WebSiteName string =  '${toLower(DeployObject.ClientAppRegName)}' 
param FunctionAppName string = '${toLower(DeployObject.APIAppRegName)}' 
/*
output SolutionName string = DeployObject.SolutionName
output WebSiteName string = WebSiteName
output FunctionAppName string = FunctionAppName

output WebDomain string = DeployObject.WebDomain
output DnsSuffix string = DeployObject.DnsSuffix

output webappPrivateDNSZoneName string = SolutionObj.webappPrivateDNSZoneName
output keyVaultPrivateDnsZoneName string = SolutionObj.webappPrivateDNSZoneName
output blobPrivateDnsZoneName string = SolutionObj.blobPrivateDnsZoneName
output filePrivateDnsZoneName string = SolutionObj.filePrivateDnsZoneName
output queuePrivateDnsZoneName string = SolutionObj.queuePrivateDnsZoneName
output tablePrivateDnsZoneName string = SolutionObj.tablePrivateDnsZoneName
output sqlPrivateDnsZoneName string = SolutionObj.sqlPrivateDnsZoneName

output funcPrivateEndpointName string = SolutionObj.funcPrivateEndpointName
output sqlPrivateEndpointName string = SolutionObj.sqlPrivateEndpointName
output webappPrivateEndpointName string = SolutionObj.webappPrivateEndpointName
output keyVaultPrivateEndpointName string = SolutionObj.keyVaultPrivateEndpointName
output auditStorageBlobPrivateEndpointName string = SolutionObj.auditStorageBlobPrivateEndpointName
output mainStorageFilePrivateEndpointName string = SolutionObj.mainStorageFilePrivateEndpointName
output mainStorageTablePrivateEndpointName string = SolutionObj.mainStorageTablePrivateEndpointName
output mainStorageBlobPrivateEndpointName string = SolutionObj.mainStorageBlobPrivateEndpointName
output mainStorage_Queue_PrivateEndpointName string = SolutionObj.mainStorage_Queue_PrivateEndpointName

output solutionObject object = SolutionObj

/**/
	resource dtsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
		name: SolutionObj.resourceGroupName
		location: location
		tags: Tags
	}//dtsResourceGroup
	//output resourceGroupResourceId string = dtsResourceGroup.id
//*/

//APP INSIGHTS
/**/
	module appInsights 'modules/appInsights.bicep' =  {
		scope: dtsResourceGroup
		name:SolutionObj.appInsightsName
		params:{
		location:dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		}
	}//appInsights
//*/

//APP INSIGHTS OUTPUTS:
/*
	output appInsightsConnString string = appInsights.outputs.appInsightsConnString
	output workspaceResourceId string = appInsights.outputs.workspaceResourceId
//*/

/*
output managedUserExists bool = DeployObject.ManagedUserExists
output AzureResourcesManagedUser bool = DeployObject.AzureResources.ManagedUser
/**/

//MANAGED USER
/**/
	module managedUser 'modules/managedUser.bicep' = {
		scope: dtsResourceGroup
		name: DeployObject.ManagedUserName
		params:{
		location: dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		keyVaultProps: keyVaultProps 
		}
	}//managedUser
//*/


//MANAGED USER OUTPUTS:
/**/
	output ManagedUserName string = managedUser.outputs.ManagedUserName
	output ManagedUserResourceId string = managedUser.outputs.ManagedUserResourceId
	output ManagedUserPrincipalId string = managedUser.outputs.ManagedUserPrincipalId
//*/



/*
	output VirtualNetworkExists bool = DeployObject.VirtualNetworkExists
	output AzureResourcesVirtualNetwork bool = DeployObject.AzureResources.VirtualNetwork
//*/

//VIRTUAL NETWORK
/**/
	module virtualNetwork 'modules/virtualNetwork.bicep' = {
		scope: dtsResourceGroup
		name: DeployObject.VirtualNetworkName
		params: {
		location: dtsResourceGroup.location
		//virtualNetworkObj: virtualNetworkObj
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		}
	}//virtualNetwork
	//var vnetId = virtualNetwork.outputs.vnetId
	var vnetId = virtualNetwork.outputs.vnetResourceId
//*/

// VNET OUTPUTS:
/*
	output vnetResourceId string = virtualNetwork.outputs.vnetResourceId
	output nsgResourceId string = virtualNetwork.outputs.nsgResourceId
//*/


//BASTION
/**/
	module bastion 'modules/bastion.bicep'= {
		scope: dtsResourceGroup
		name: SolutionObj.bastionName
		params: {
			location:dtsResourceGroup.location
			tags: Tags
			SolutionObj: SolutionObj
			DeployObject: DeployObject
			} 
	} //bastion

	//BASTION OUTPUTS
	output bastionHostName string =   SolutionObj.bastionName
	output subnetId string =  bastion.outputs.subnetId
	output bastionAddressPrefix string =  bastion.outputs.bastionAddressPrefix
	output bastionSubnetName string =  bastion.outputs.bastionSubnetName
//*/


/*
output AzureResourcesKeyVault bool = DeployObject.AzureResources.KeyVault
output KeyVaultExists bool = DeployObject.KeyVaultExists
//*/

//KEYVAULT
/**/
module keyVault 'modules/keyvault.bicep' =  {
	scope:dtsResourceGroup
	name: DeployObject.KeyVaultName
	params:{
	location:dtsResourceGroup.location
	tags: Tags
	SolutionObj: SolutionObj
	DeployObject: DeployObject

	entities : entities
	keyVaultProps: keyVaultProps 
	//keyvaultSubnetId: keyvaultSubnetId
	StorageAccountsArr: StorageAccountsArr
	}
	dependsOn: [
	appInsights
	virtualNetwork 
	]
}//keyVault
//*/


/**/
//KEYVAULT OUTPUTS:

	output KeyVaultName string = keyVault.name
	output KeyVaultResourceId string = keyVault.outputs.keyVaultResourceId
	output KeyVaultURI string = keyVault.outputs.keyVaultUri

	//output AuditStorageKeyName string = SolutionObj.cmkAuditStorageKeyName
	output AuditStorageKeyName string = SolutionObj.cmkAuditStorageKeyName
	output cmk_AuditStorageKeyId string = keyVault.outputs.cmk_AuditStorageKeyId
	output cmk_AuditStorageKeyUri string = keyVault.outputs.cmk_AuditStorageKeyUri
	output cmk_AuditStorageKeyWithVersion string = keyVault.outputs.cmk_AuditStorageKeyWithVersion

	//output MainStorageKeyName string = SolutionObj.cmkMainStorageKeyName
	output MainStorageKeyName string = SolutionObj.cmkMainStorageKeyName
	output cmk_MainStKeyId string = keyVault.outputs.cmk_MainStorageKeyId
	output cmk_MainStKeyUri string = keyVault.outputs.cmk_MainStorageKeyUri
	output cmk_MainStorageKeyWithVersion string = keyVault.outputs.cmk_MainStorageKeyWithVersion

	//output cmkSqlKeyName string = SolutionObj.cmkSqlKeyName
	output cmkSqlKeyName string = SolutionObj.cmkSqlKeyName
	output cmkSqlKeyUri string = keyVault.outputs.cmkSqlKeyUri
	output cmkSqlKeyId string =  keyVault.outputs.cmkSqlKeyId
	output cmkSqlKeyUriWithVersion string = keyVault.outputs.cmkSqlKeyUriWithVersion  
//*/


/*
output AzureResourcesWebSite bool = DeployObject.AzureResources.WebSite
output WebSiteExists bool = DeployObject.WebSiteExists
//*/

/**/
	module appServicePlan 'modules/appServPlan.bicep' ={
		scope:dtsResourceGroup
		name : SolutionObj.aspName
		params:{
		location:dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		appServicePlanSku: appServicePlanSku
		}
		dependsOn:[
		appInsights
		virtualNetwork
			keyVault
		managedUser
		]//*/
	}//appServicePlan
//*/

//APP SERVICE PLAN OUTPUTS:

	output appServiceResourceId string = appServicePlan.outputs.appServiceResourceId
//*/


/**/
	var webappSubnetName = 'snet-webapp-${DeployObject.SolutionName}'
	var webappSubnetId  = '${vnetId}/subnets/${webappSubnetName}'
	//output webappSubnetName string = webappSubnetName
	//output webappSubnetId string = webappSubnetId
//*/

//APP SERVICE
/**/
	module appService 'modules/appService.bicep' = {
		scope: dtsResourceGroup
		name: SolutionObj.appServiceName
		params:{
		location:dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
			//webSiteName: WebSiteName
		webappSubnetId: webappSubnetId
		}
		dependsOn:[
		appInsights
		managedUser
		virtualNetwork
		//privateDnsZones
		keyVault
		appServicePlan
		]
	}
//*/


//APP SERVICE OUTPUTS:
/*
	output webAppSystemPrincipalId string = appService.outputs.webAppSystemPrincipalId
	output appServiceHostName string = appService.outputs.appServiceHostName
//*/



/*
output AzureResourcesMainStorage bool = DeployObject.AzureResources.MainStorage
output MainStorageExists bool = DeployObject.MainStorageExists
//*/

/**/
module mainStorage 'modules/mainstorage.bicep' = {
	scope: dtsResourceGroup
	name: SolutionObj.mainStorageDeployment
	params: {
	location: dtsResourceGroup.location 
	tags: Tags
	SolutionObj: SolutionObj
	DeployObject: DeployObject
	storageAccountSkuName:storageAccountSkuName 
	}

	dependsOn:[
	appInsights
	managedUser
	virtualNetwork
	keyVault
	appServicePlan
	appService 
	]//*/
}
//*/

/*
//MAIN STORAGE OUTPUTS:
output MainStorageResourceId string = mainStorage.outputs.MainStorageResourceId
output MainStorageName string = mainStorage.outputs.MainStorageName
output MainStorageBlobEndpoint string = mainStorage.outputs.MainStorageBlobEndpoint
//output MainStorageAccessKey string = mainStorage.outputs.MainStorageAccessKey
//*/

/**/
output AzureResourcesAuditStorage bool = DeployObject.AzureResources.AuditStorage
output AuditStorageExists bool = DeployObject.AuditStorageExists

var storageSubnetName = 'snet-storage-${DeployObject.SolutionName}'
var storageSubnetId  = '${vnetId}/subnets/${storageSubnetName}'

output storageSubnetName string = storageSubnetName
output storageSubnetId string = storageSubnetId

/**/
module auditStorage 'modules/auditStorage.bicep' = {
	scope: dtsResourceGroup
	name: SolutionObj.auditStorageDeployment 
	params: {
	location: dtsResourceGroup.location
	tags: Tags
	SolutionObj: SolutionObj
	DeployObject: DeployObject
	storageAccountSkuName:storageAccountSkuName
	storageSubnetId: storageSubnetId
	}
	
	dependsOn:[
	appInsights
	managedUser
	virtualNetwork
	mainStorage
	keyVault
	appServicePlan
	appService 
	]
}
/*
//AUDIT STORAGE OUTPUTS:
output AuditStorageName string = auditStorage.outputs.AuditStorageName 
output auditStResourceId string = auditStorage.outputs.auditStorageResourceId
//*/



/*
//var functionSubnetName = 'snet-functionintegration-${DeployObject.SolutionName}'
//var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'
//output functionSubnetId string = functionSubnetId
output AzureResourcesFunctionApp bool = DeployObject.AzureResources.FunctionApp
output FunctionAppExists bool = DeployObject.FunctionAppExists
/**/
var functionSubnetName = 'snet-functionintegration-${DeployObject.SolutionName}'
var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'
module functionApp 'modules/functionapp.bicep' = {
	scope: dtsResourceGroup
	name: SolutionObj.FunctionAppName
	params:{
	location: dtsResourceGroup.location
	ApiClientId: DeployObject.APIAppRegAppId
	functionSubnetId: functionSubnetId
	storageAccountName : DeployObject.MainStorageName
	tags: Tags
	SolutionObj: SolutionObj
	DeployObject: DeployObject
	}
	dependsOn:[
	appInsights
	managedUser
	virtualNetwork
	//privateDnsZones
	keyVault
	appServicePlan
	appService
	auditStorage
	mainStorage 
	]
}
/*
//FUNCTIONAPP OUTPUTS:
output functionAppDefaultHostName string = functionApp.outputs.functionAppDefaultHostName
output functionAppSystemPrincipalId string = functionApp.outputs.functionAppSystemAssignedPrincipalId
output functionAppUrl string = functionApp.outputs.functionAppUrl
//*/

/**/
param permissionsObj object =  {
	name: 'permissions' 
	keys: [
		'get'
		'wrapKey'
		'unwrapKey'
		]
	secrets: []
	certificates: []
}
//output myPermissionObj object = permissionsObj
//*/


/*
	output AzureResourcesSQL bool = DeployObject.AzureResources.SQL
	output SQLExists bool = DeployObject.SQLExists
//*/
/**/
module sqlServer 'modules/sqlserver.bicep'= {
	scope: dtsResourceGroup
	name: DeployObject.sqlServerName
	params: {
	location:dtsResourceGroup.location
	tags: Tags
	SolutionObj: SolutionObj
	DeployObject: DeployObject
	sqlDatabaseSku: sqlDatabaseSku
	sqlServerAdministratorLogin: DeployObject.SqlAdmin
	sqlServerAdministratorPassword: DeployObject.SqlAdminPwd 
 }
 dependsOn: [
	managedUser
	virtualNetwork
	keyVault
	appServicePlan
	appService
	auditStorage
	mainStorage
	functionApp
	] 
}

module addSqlSystemAccessPolicy 'modules/nested_addAccessPolicy.bicep' =  {
	name: 'addSqlSystemAccessPolicy'
	scope: dtsResourceGroup
	params: {
	principalObjId: sqlServer.outputs.sqlSystemPrincipalId
	keyVaultName: DeployObject.KeyVaultName
	permissionsObj: permissionsObj
	}
	dependsOn:  [
	keyVault 
	sqlServer
	]
}

/**/
//SQL OUTPUTS:(DeployObject.AzureResources.) ? 
output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn
output SqlConnectionString string = sqlServer.outputs.SqlConnectionString
output SqlSystemPrincipalId string = sqlServer.outputs.sqlSystemPrincipalId:''
//*/




/*
////// OUTPUTS: ////////////////
//output environmentOutput object = environment()

output SolutionObj_OpenIdIssuer string = SolutionObj.OpenIdIssuer
output SolutionObj_WebDomain string = DeployObject.WebDomain
output SolutionObj_DnsSuffix string = SolutionObj.DnsSuffix 
//*/