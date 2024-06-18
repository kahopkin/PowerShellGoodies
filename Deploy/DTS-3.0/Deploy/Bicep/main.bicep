targetScope = 'subscription'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(3)
@maxLength(30)
param AppName string

@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
	'Test'
	'Prod'
	'Dev'
])
param Environment string

@description('The Azure region into which the resources should be deployed.')
param location string = deployment().location

param TimeStamp string
param DeployDate string =TimeStamp 
param DeployTime string = split(TimeStamp, ' ')[1]

param DeployObject object

param Tags object = {
	DeployDate: DeployDate
	DeployTime: DeployTime
	Environment: DeployObject.Environment
	DeployedBy: DeployObject.CurrUserName
	Owner: DeployObject.CurrUserName
	DeployFolder : DeployObject.DeployFolder
}

//Parameters from the parameter file:
param storageAccountSkuName string
param StorageAccountsArr array

param appServicePlanSku object
param keyVaultProps object

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object
//*/

@description('The API App Registration\' secret created by the PowerShell')
@secure()
param APIAppRegSecret string 


@secure()
@description('The administrator login password for the SQL server.')
param SqlAdminPwd string 


//This array is being used to create the secrets in the keyvault
//@secure()
param  entities array = [
	{
	secretName: 'ApiClientId'
	secretValue: DeployObject.APIAppRegAppId
	enabled: true
	} 
	{
	secretName: 'ApiClientSecret'
	secretValue: APIAppRegSecret
	enabled: true
	} 
	{
	secretName: 'RoleDefinitionId'
	secretValue: DeployObject.RoleDefinitionId
	enabled: true
	} 
	{
	secretName: 'SqlServerAdministratorLogin'
	secretValue: DeployObject.SqlAdmin
	enabled: true
	}
	{
	secretName: 'SqlServerAdministratorPassword'
	secretValue: SqlAdminPwd
	enabled: true
	} 
] 

var mainStorageDeployment  = 'mainstorage-${DeployObject.SolutionName}'
var auditStorageDeployment  = 'auditStorage-${DeployObject.SolutionName}'

param SolutionNameSt string = '${toLower(DeployObject.AppName)}${toLower(DeployObject.Environment)}'

param protocol string = 'https://'

param SolutionObj object ={
	environment: DeployObject.Environment
	appName : DeployObject.AppName
	solutionName : DeployObject.SolutionName
	SolutionNameSt : SolutionNameSt
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

	addressPrefix : '${DeployObject.AddressPrefix}.0/${DeployObject.AddressSpace}'
	
	//Private DNS Zone Names:
	webappPrivateDNSZoneName : 'privatelink.${DeployObject.WebDomain}'
	keyVaultPrivateDnsZoneName : 'privatelink.vaultcore.${DeployObject.DnsSuffix}'
	blobPrivateDnsZoneName : 'privatelink.blob.core.${DeployObject.DnsSuffix}'
	filePrivateDnsZoneName : 'privatelink.file.core.${DeployObject.DnsSuffix}'
	queuePrivateDnsZoneName : 'privatelink.queue.core.${DeployObject.DnsSuffix}'
	tablePrivateDnsZoneName : 'privatelink.table.core.${DeployObject.DnsSuffix}'
	sqlPrivateDnsZoneName : 'privatelink.database.${DeployObject.DnsSuffix}'

	//Private EndPoint Names:
	keyVaultPrivateEndpointName : 'pep-kv-${DeployObject.SolutionName}'
	auditStorageBlobPrivateEndpointName : 'pep-st-blob-audit-${DeployObject.SolutionName}'
	mainStorageFilePrivateEndpointName : 'pep-st-file-${DeployObject.SolutionName}'
	mainStorageTablePrivateEndpointName : 'pep-st-table-${DeployObject.SolutionName}'
	mainStorageBlobPrivateEndpointName : 'pep-st-blob-${DeployObject.SolutionName}'
	mainStorage_Queue_PrivateEndpointName : 'pep-st-queue-${DeployObject.SolutionName}'
	webappPrivateEndpointName : 'pep-site-${DeployObject.SolutionName}'
	funcPrivateEndpointName : 'pep-func-${DeployObject.SolutionName}'
	sqlPrivateEndpointName : 'pep-sqldb-${DeployObject.SolutionName}'

	//KeyVault Key Names
	cmkMainStorageKeyName :'cmk-st-${DeployObject.SolutionName}'
	cmkAuditStorageKeyName : 'cmk-staudit-${DeployObject.SolutionName}'
	cmkSqlKeyName : 'cmk-sqldb-${DeployObject.SolutionName}'

	auditStorageDeployment : 'auditStorage-${DeployObject.SolutionName}'
	mainStorageDeployment : 'mainstorage-${DeployObject.SolutionName}'

	//Subnet Names
	keyvaultSubnetName : 'snet-keyvault-${DeployObject.SolutionName}'
	webappSubnetName : 'snet-webapp-${DeployObject.SolutionName}'
	storageSubnetName : 'snet-storage-${DeployObject.SolutionName}'
	functionIntegrationSubnetName : '/subnets/snet-functionintegration-${DeployObject.SolutionName}'
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
//*/


/*
	output APIAppRegName string = DeployObject.APIAppRegName
	output APIAppRegAppId string = DeployObject.APIAppRegAppId
	output APIAppRegObjectId string = DeployObject.APIAppRegObjectId
	output APIAppRegSecret string = DeployObject.APIAppRegSecret
	output APIAppRegServicePrincipalId string = DeployObject.APIAppRegServicePrincipalId
	output ClientAppRegName string = DeployObject.ClientAppRegName
	output ClientAppRegAppId string = DeployObject.ClientAppRegAppId
	output ClientAppRegObjectId string = DeployObject.ClientAppRegObjectId
	output ClientAppRegServicePrincipalId string = DeployObject.ClientAppRegServicePrincipalId
	output WebSiteName string = WebSiteName
	output SolutionName string = DeployObject.SolutionName
	
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
//*/

	output solutionObject object = SolutionObj

//*/

// RESOURCE GROUP
/**/
	resource dtsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
		name: DeployObject.ResourceGroupName
		location: location
		tags: Tags
	}//dtsResourceGroup
//*/

/**/
	output resourceGroupResourceId string = dtsResourceGroup.id
//*/

/**/
	output appInsightsName string = SolutionObj.appInsightsName
	output logAnalyticsWorkspaceName string = SolutionObj.logAnalyticsWorkspaceName
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
/**/
	output appInsightsConnString string = appInsights.outputs.appInsightsConnString
	output workspaceResourceId string = appInsights.outputs.workspaceResourceId
//*/



/**/
	output managedUserExists bool = DeployObject.ManagedUserExists
	output AzureResourcesManagedUser bool = DeployObject.AzureResources.ManagedUser
//*/

//MANAGED USER
/**/
	//module managedUser 'modules/managedUser.bicep' = if(DeployObject.AzureResources.ManagedUser) {
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

/**/
	output VirtualNetworkExists bool = DeployObject.VirtualNetworkExists
	output AzureResourcesVirtualNetwork bool = DeployObject.AzureResources.VirtualNetwork
//*/

//VIRTUAL NETWORK
/**/
	//module virtualNetwork 'modules/virtualNetwork.bicep' = if(DeployObject.AzureResources.VirtualNetwork) {
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
/**/
	output vnetResourceId string = virtualNetwork.outputs.vnetResourceId
	output nsgResourceId string = virtualNetwork.outputs.nsgResourceId 
//*/


//BASTION
/**/
	module bastion 'modules/bastion.bicep'= {
	//module bastion 'modules/bastion.bicep'= if(DeployObject.Environment  == 'Prod' && DeployObject.AzureResources.VirtualNetwork){
		scope: dtsResourceGroup
		name: SolutionObj.bastionName
		params: {
			location:dtsResourceGroup.location
			tags: Tags
			SolutionObj: SolutionObj
			DeployObject: DeployObject
			} 
		dependsOn:[
			virtualNetwork
		]
	} //bastion
//*/


//BASTION OUTPUTS
/**/
	output bastionHostName string =  SolutionObj.bastionName
	output subnetId string = bastion.outputs.subnetId
	output bastionAddressPrefix string = bastion.outputs.bastionAddressPrefix
	output bastionSubnetName string = bastion.outputs.bastionSubnetName 
//*/


/**/
	output AzureResourcesKeyVault bool = DeployObject.AzureResources.KeyVault
	output KeyVaultExists bool = DeployObject.KeyVaultExists
//*/

/**/
	//param keyvaultSubnetName string= 'snet-keyvault-${DeployObject.SolutionName}'
	//var keyvaultSubnetId  = '${vnetId}/subnets/${SolutionObj.keyvaultSubnetName}'
//*/

//KEYVAULT
/**/
	//module keyVault 'modules/keyvault.bicep' = if(DeployObject.AzureResources.KeyVault) {
	module keyVault 'modules/keyvault.bicep'= {
		scope:dtsResourceGroup
		name: DeployObject.KeyVaultName
		params:{
			location:dtsResourceGroup.location
			tags: Tags
			SolutionObj: SolutionObj
			DeployObject: DeployObject
			entities : entities
			keyVaultProps: keyVaultProps
		}
		dependsOn: [
			appInsights
			virtualNetwork
			managedUser
		]
	}//keyVault
//*/

//KEYVAULT OUTPUTS:
/**/
	output keyVaultURI string = keyVault.outputs.keyvaulturi
	output keyVaultId string = keyVault.outputs.keyVaultId

	output cmk_MainStorageKeyId string = keyVault.outputs.cmk_MainStorageKeyId
	output cmk_MainStorageKeyUri string = keyVault.outputs.cmk_MainStorageKeyUri

	output cmk_AuditStorageKeyId string = keyVault.outputs.cmk_AuditStorageKeyId
	output cmk_AuditStorageKeyUri string = keyVault.outputs.cmk_AuditStorageKeyUri

	output cmkSqlKeyUri string = keyVault.outputs.cmkSqlKeyUri
	output cmkSqlKeyId string =  keyVault.outputs.cmkSqlKeyId 

	//output keyvault_cmk_SqlkeyUriWithVersion string =  keyVault.outputs.cmk_SqlkeyUriWithVersion 
//*/


//APP SERVICE PLAN
/**/
	//module appServicePlan 'modules/appServPlan.bicep' = if(DeployObject.AzureResources.WebSite || DeployObject.AzureResources.FunctionApp){
module appServicePlan 'modules/appServPlan.bicep' ={
	scope:dtsResourceGroup
	name : SolutionObj.aspName
	params:{
		location:dtsResourceGroup.location
		aspName:SolutionObj.aspName
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		appServicePlanSku: appServicePlanSku
	}   
}//appServicePlan
//*/


/**/
	var webappSubnetName = 'snet-webapp-${DeployObject.SolutionName}'
	var webappSubnetId  = '${vnetId}/subnets/${webappSubnetName}'
	output webappSubnetName string = webappSubnetName
	output webappSubnetId string = webappSubnetId
//*/


//APP SERVICE
/**/
//module appService 'modules/appService.bicep' = if(DeployObject.AzureResources.WebSite) {
module appService 'modules/appService.bicep' = {
	scope: dtsResourceGroup
	name: SolutionObj.appServiceName
	params:{
		location:dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		webappSubnetId: webappSubnetId
	}
	dependsOn:[
		appInsights
		virtualNetwork
		keyVault
		appServicePlan
		appServicePlan
	]
}//appService
//*/


//AUDIT STORAGE
/**/
//module auditStorage 'modules/auditStorage.bicep' = if(DeployObject.AzureResources.AuditStorage) {
module auditStorage 'modules/auditStorage.bicep' = {
	scope: dtsResourceGroup
	name: auditStorageDeployment
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
		virtualNetwork
		managedUser
		keyVault
		appService
		//mainStorage
	]
}//auditStorage
//*/

//AUDIT STORAGE OUTPUTS:
/**/
	output AuditStorageName string = auditStorage.outputs.AuditStorageName
	output auditStResourceId string = auditStorage.outputs.auditStorageResourceId
	output auditStorageAccessKey string = auditStorage.outputs.auditStorageAccessKey
//*/
	

//MAIN STORAGE
/**/
//Run the storage module, setting scope to the resource group we just created.
//module mainStorage 'modules/mainstorage.bicep' = if(DeployObject.AzureResources.MainStorage) {
module mainStorage 'modules/mainstorage.bicep' ={
	scope: dtsResourceGroup
	name: mainStorageDeployment
	params: {
		location: dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		storageAccountSkuName:storageAccountSkuName
		StorageAccountsArr: StorageAccountsArr 
	}
	dependsOn:[
		appInsights
		virtualNetwork
		managedUser
		keyVault
		appService
		auditStorage
	]
}//mainStorage
//*/

//MAIN STORAGE OUTPUTS:
/**/
	output MainStorageResourceId string = mainStorage.outputs.MainStorageResourceId
	output MainStorageName string = mainStorage.outputs.MainStorageName
	output MainStorageBlobEndpoint string = mainStorage.outputs.MainStorageBlobEndpoint
	//output MainStorageAccessKey string = mainStorage.outputs.MainStorageAccessKey
//*/

/*
	output storageSubnetNameOut string = mainStorage.outputs.storageSubnetName
	//output MainStorageSystemAssignedprincipalId string = mainStorage.outputs.MainStorageSystemAssignedprincipalId
	//output mainStorageSystemAssignedPrincipalIdentity object =mainStorage.outputs.mainStorageSystemAssignedPrincipalIdentity
	output MainStorageAccountName string = mainStorage.outputs.storageAccountName
	output storageAccountNameMain string = mainStorage.outputs.storageAccountName
	output mainStorageNameMain string = mainStorage.outputs.mainStorageName
	//output azureWebJobsStorage string = mainStorage.outputs.AzureWebJobsStorage
	output blobEndpoint string = mainStorage.outputs.blobEndpoint
	output azStorageAccessKey string = mainStorage.outputs.azStorageAccessKey
//*/

/**/
	var storageSubnetName = 'snet-storage-${DeployObject.SolutionName}'
	var storageSubnetId  = '${vnetId}/subnets/${storageSubnetName}'

	output storageSubnetName string = storageSubnetName
	output storageSubnetId string = storageSubnetId
/**/


/**/
	//functionSubnetName : '/subnets/snet-function-${DeployObject.SolutionName }'
	var functionSubnetName = 'snet-functionintegration-${DeployObject.SolutionName}'
	var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'
	output functionSubnetId string = functionSubnetId
//*/

//FUNCTIONAPP
/**/
	output AzureResourcesFunctionApp bool = DeployObject.AzureResources.FunctionApp
	output FunctionAppExists bool = DeployObject.FunctionAppExists
	//module functionApp 'modules/functionapp.bicep' = if(DeployObject.AzureResources.FunctionApp) {
	module functionApp 'modules/functionapp.bicep' ={
		scope: dtsResourceGroup
		name: SolutionObj.functionAppName
		params:{
			location: dtsResourceGroup.location
			tags: Tags
			SolutionObj: SolutionObj
			DeployObject: DeployObject
			storageAccountName : DeployObject.MainStorageName
			ApiClientId: DeployObject.APIAppRegAppId
		}
		dependsOn:[
			virtualNetwork
			managedUser
			keyVault
			appServicePlan
			mainStorage
			auditStorage
		]
	}//functionApp
//*/

//FUNCTIONAPP OUTPUTS:
/**/
	output functionAppDefaultHostName string = functionApp.outputs.functionAppDefaultHostName
	output functionAppSystemPrincipalId string = functionApp.outputs.functionAppSystemAssignedPrincipalId
	output functionAppUrl string = functionApp.outputs.functionAppUrl
//*/

/**/
	output SystemAssignedIdentityId string = functionApp.outputs.SystemAssignedIdentityId
	output SystemAssignedPrincipalIdentity object = functionApp.outputs.SystemAssignedPrincipalIdentity
	//output ReaderRoleDefinitionName string = functionApp.outputs.ReaderRoleDefinitionName
	//output ReaderRoleDefinitionId string = functionApp.outputs.ReaderRoleDefinitionId
	//output delegatedManagedIdentityResourceId string = functionApp.outputs.delegatedManagedIdentityResourceId

	//output readerRoleAssignmentprincipalId string = functionApp.outputs.readerRoleAssignmentprincipalId
	//output readerRoleAssignmentId string = functionApp.outputs.readerRoleAssignmentId

//*/


/**/
	var cmkSqlKeyUriWithVersion = keyVault.outputs.cmkSqlKeyUriWithVersion
	output AzureResources bool = DeployObject.AzureResources.SQL
//*/

//SQL SERVER
/**/
	//module sqlServer 'modules/sqlserver.bicep' = if( DeployObject.AzureResources.SQL) {
	module sqlServer 'modules/sqlserver.bicep' = {
		scope: dtsResourceGroup
		name: SolutionObj.sqlServerName
		params: {
			location:dtsResourceGroup.location
			tags: Tags
			DeployObject: DeployObject
			sqlDatabaseSku: sqlDatabaseSku
			sqlServerAdministratorPassword: SqlAdminPwd
			cmkSqlKeyUriWithVersion: cmkSqlKeyUriWithVersion
			SolutionObj: SolutionObj
		}
		dependsOn: [
			managedUser
			virtualNetwork
			keyVault
		]
	}//sqlServer
//*/

//SQL OUTPUTS
/**/
	output sqlServerName string = sqlServer.name
	output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn
	output SqlConnectionString string = sqlServer.outputs.SqlConnectionString
	output SqlSystemPrincipalId string = sqlServer.outputs.sqlSystemPrincipalId
//*/



//permissionsObj
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
	}//

	//output myPermissionObj object = permissionsObj
//*/


/**/
	output AzureResourcesSQL bool = DeployObject.AzureResources.SQL
	output SQLExists bool = DeployObject.SQLExists
//*/


//addSqlSystemAccessPolicy
/**/
	module addSqlSystemAccessPolicy 'modules/nested_addAccessPolicy.bicep' = if(DeployObject.AzureResources.SQL && DeployObject.SQLExists) {
		name: 'addSqlSystemAccessPolicy'
		scope: dtsResourceGroup
		params: {
			principalObjId: DeployObject.SqlSystemPrincipalId
			keyVaultName: SolutionObj.keyVaultName
			permissionsObj: permissionsObj
		}
		dependsOn:[
			keyVault
		]
	}//addSqlSystemAccessPolicy
//*/
