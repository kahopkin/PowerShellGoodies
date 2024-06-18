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
/*
output AppName string = AppName
output Solution string = Solution
output Environment string = Environment
//*/
@description('The Azure region into which the resources should be deployed.')
param location string = deployment().location


param TimeStamp string
param DeployDate string =TimeStamp //= split(TimeStamp, ' ')[0]
param DeployTime string = split(TimeStamp, ' ')[1]

param DeployObject object

param Tags object = {
	DeployDate: DeployDate
	DeployTime: DeployTime
	Environment: DeployObject.Environment
	DeployedBy: DeployObject.CurrUserName
	Owner: DeployObject.CurrUserName
	Solution: DeployObject.Solution
}

//Parameters from the parameter file:
param storageAccountSkuName string
param StorageAccountsArr array

param appServicePlanSku object
param keyVaultProps object

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object
//*/

//This array is being used to create the secrets in the keyvault
param  entities array = [
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
	} 
	{
	secretName: 'SqlServerAdministratorLogin'
	secretValue: DeployObject.SqlAdmin
	enabled: true
	}
	{
	secretName: 'SqlServerAdministratorPassword'
	secretValue: DeployObject.SqlAdminPwd
	enabled: true
	} 
] 


param WebSiteName string =  '${toLower(DeployObject.ClientAppRegName)}' 
param FunctionAppName string = '${toLower(DeployObject.APIAppRegName)}' 

@description('BaseName for the resource group.  Final name will indicate environmentType as well')
param resourceGroupName string = DeployObject.ResourceGroupName 

param planName string = 'asp-${DeployObject.SolutionName}'

param appServiceName string = 'webapp-${DeployObject.SolutionName}'

var mainStorageDeployment  = 'mainstorage-${DeployObject.SolutionName}'
var auditStorageDeployment  = 'auditStorage-${DeployObject.SolutionName}'


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

	vNetName: 'vnet-${DeployObject.SolutionName}'
	addressPrefix : '${DeployObject.AddressPrefix}.0/${DeployObject.AddressSpace}'
	subnets: [
			{
				name: 'default'
				privateEndpointNetworkPolicies: 'enabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'keyvault' 
				privateEndpointNetworkPolicies: 'disabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'webapp'
				privateEndpointNetworkPolicies: 'disabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'function' 
				privateEndpointNetworkPolicies: 'disabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'storage' 
				privateEndpointNetworkPolicies: 'disabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			{
				name: 'functionintegration' 
				privateEndpointNetworkPolicies: 'enabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
				delegations: 'Microsoft.Web/serverfarms'
			}
			{
				name: 'AzureBastionSubnet'			
				privateEndpointNetworkPolicies: 'enabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			/*
			{
				name: 'GatewaySubnet'			
				privateEndpointNetworkPolicies: 'enabled'
				//privateLinkServiceNetworkPolicies: 'enabled'
			}
			//*/
		]
	//Subnet Names
	keyvaultSubnetName : 'snet-keyvault-${DeployObject.SolutionName}'
	webappSubnetName : 'snet-webapp-${DeployObject.SolutionName}'
	storageSubnetName : 'snet-storage-${DeployObject.SolutionName}'
	functionIntegrationSubnetName : 'snet-functionintegration-${DeployObject.SolutionName}'
	functionSubnetName : '/subnets/snet-function-${DeployObject.SolutionName }'
	bastionSubnetName : 'AzureBastionSubnet'

	//Private DNS Zone Names:
	webapp_privateDNSZoneName : 'privatelink.${DeployObject.WebDomain}'
	keyVault_PrivateDnsZoneName : 'privatelink.vaultcore.${DeployObject.DnsSuffix}'
	blob_PrivateDnsZoneName : 'privatelink.blob.core.${DeployObject.DnsSuffix}'
	file_PrivateDnsZoneName : 'privatelink.file.core.${DeployObject.DnsSuffix}'
	queue_PrivateDnsZoneName : 'privatelink.queue.core.${DeployObject.DnsSuffix}'
	table_PrivateDnsZoneName : 'privatelink.table.core.${DeployObject.DnsSuffix}'
	sql_PrivateDnsZoneName : 'privatelink.database.${DeployObject.DnsSuffix}'

	//Private EndPoint Names:
	funcPrivateEndpointName : 'pep-func-${DeployObject.SolutionName}'
	sqldb_PrivateEndpointName : 'pep-sqldb-${DeployObject.SolutionName}'
	webapp_PrivateEndpointName : 'pep-site-${DeployObject.SolutionName}'
	keyVault_PrivateEndpointName : 'pep-kv-${DeployObject.SolutionName}'
	auditStorage_Blob_PrivateEndpointName : 'pep-st-blob-audit-${DeployObject.SolutionName}'
	mainStorage_File_PrivateEndpointName : 'pep-st-file-${DeployObject.SolutionName}'
	mainStorage_Table_PrivateEndpointName : 'pep-st-table-${DeployObject.SolutionName}'
	mainStorage_Blob_PrivateEndpointName : 'pep-st-blob-${DeployObject.SolutionName}'
	mainStorage_Queue_PrivateEndpointName : 'pep-st-queue-${DeployObject.SolutionName}'

	//KeyVault Key Names
	cmkMainStorageKeyName :'cmk-st-${DeployObject.SolutionName}'
	cmkAuditStorageKeyName : 'cmk-staudit-${DeployObject.SolutionName}'
	cmkSqlKeyName : 'cmk-sqldb-${DeployObject.SolutionName}'

	auditStorageDeployment : 'auditStorage-${DeployObject.SolutionName}'
	mainStorageDeployment : 'mainstorage-${DeployObject.SolutionName}'
}//SolutionObj


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

	output SolutionName string = DeployObject.SolutionName
	output WebSiteName string = WebSiteName
	output FunctionAppName string = FunctionAppName

	output WebDomain string = DeployObject.WebDomain
	output DnsSuffix string = DeployObject.DnsSuffix

	output webapp_privateDNSZoneName string = SolutionObj.webapp_privateDNSZoneName
	output keyVault_PrivateDnsZoneName string = SolutionObj.webapp_privateDNSZoneName
	output blob_PrivateDnsZoneName string = SolutionObj.blob_PrivateDnsZoneName
	output file_PrivateDnsZoneName string = SolutionObj.file_PrivateDnsZoneName
	output queue_PrivateDnsZoneName string = SolutionObj.queue_PrivateDnsZoneName
	output table_PrivateDnsZoneName string = SolutionObj.table_PrivateDnsZoneName
	output sql_PrivateDnsZoneName string = SolutionObj.sql_PrivateDnsZoneName

	output funcPrivateEndpointName string = SolutionObj.funcPrivateEndpointName
	output sqldb_PrivateEndpointName string = SolutionObj.sqldb_PrivateEndpointName
	output webapp_PrivateEndpointName string = SolutionObj.webapp_PrivateEndpointName
	output keyVault_PrivateEndpointName string = SolutionObj.keyVault_PrivateEndpointName
	output auditStorage_Blob_PrivateEndpointName string = SolutionObj.auditStorage_Blob_PrivateEndpointName
	output mainStorage_File_PrivateEndpointName string = SolutionObj.mainStorage_File_PrivateEndpointName
	output mainStorage_Table_PrivateEndpointName string = SolutionObj.mainStorage_Table_PrivateEndpointName
	output mainStorage_Blob_PrivateEndpointName string = SolutionObj.mainStorage_Blob_PrivateEndpointName
	output mainStorage_Queue_PrivateEndpointName string = SolutionObj.mainStorage_Queue_PrivateEndpointName
//*/



/**/
	resource dtsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
		name: resourceGroupName
		location: location
		tags: Tags
	}//dtsResourceGroup
//*/

/*
	output resourceGroupResourceId string = dtsResourceGroup.id
//*/

/*
	output appInsightsName string = SolutionObj.appInsightsName
	output logAnalyticsWorkspaceName string = SolutionObj.logAnalyticsWorkspaceName
//*/

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
//*/

output DeployObjectManagedUserName string = DeployObject.ManagedUserName
output SolutionObjManagedUserName string = SolutionObj.ManagedUserName

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

/*
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
//*/

//BASTION OUTPUTS
/*
	output bastionHostName string =   SolutionObj.bastionName
	output subnetId string =  bastion.outputs.subnetId
	output bastionAddressPrefix string =  bastion.outputs.bastionAddressPrefix
	output bastionSubnetName string =  bastion.outputs.bastionSubnetName
//*/


/*
	output AzureResourcesKeyVault bool = DeployObject.AzureResources.KeyVault
	output KeyVaultExists bool = DeployObject.KeyVaultExists
//*/

/**/
	//param keyvaultSubnetName string= 'snet-keyvault-${DeployObject.SolutionName}'
	//var keyvaultSubnetId  = '${vnetId}/subnets/${SolutionObj.keyvaultSubnetName}'
	module keyVault 'modules/keyvault.bicep'={
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
		virtualNetwork
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

/**/
	module appServicePlan 'modules/appServPlan.bicep' ={
		scope:dtsResourceGroup
		name : planName
		params:{
		location:dtsResourceGroup.location 
		aspName:planName
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		appServicePlanSku: appServicePlanSku
		}
		dependsOn:[
		virtualNetwork
		]
	}//appServicePlan
//*/


/**/
	var webappSubnetName = 'snet-webapp-${DeployObject.SolutionName}'
	var webappSubnetId  = '${vnetId}/subnets/${webappSubnetName}'
	output webappSubnetName string = webappSubnetName
	output webappSubnetId string = webappSubnetId

	module appService 'modules/appService.bicep' = {
		scope: dtsResourceGroup
		name: appServiceName
		params:{
		location:dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		webSiteName: WebSiteName
		webappSubnetId: webappSubnetId
		}
		dependsOn:[
		virtualNetwork
			keyVault
		]
	}//appService
//*/

/**/
	//Run the storage module, setting scope to the resource group we just created.
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
		virtualNetwork
		keyVault
		appService
		]
	}//mainStorage
//*/

/**/
	output storageSubnetNameOut string = mainStorage.outputs.storageSubnetName
	//output MainStorageSystemAssignedprincipalId string = mainStorage.outputs.MainStorageSystemAssignedprincipalId
	//output mainStorageSystemAssignedPrincipalIdentity object =mainStorage.outputs.mainStorageSystemAssignedPrincipalIdentity
	//output MainStorageAccountName string = mainStorage.outputs.storageAccountName
	//output storageAccountNameMain string = mainStorage.outputs.storageAccountName
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
//*/

/**/
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
		virtualNetwork
		keyVault
		appService
		mainStorage
		]
	}//auditStorage
//*/

/**/
	output auditStorageAccountName string = auditStorage.outputs.auditStorageAccountName
	output auditStorageAccessKey string = auditStorage.outputs.auditStorageAccessKey
	//output auditStorageSystemAssignedprincipalId string = auditStorage.outputs.auditStorageSystemAssignedprincipalId
//*/

/**/
	var functionSubnetName = 'snet-functionintegration-${DeployObject.SolutionName}'
	var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'
	//output functionSubnetId string = functionSubnetId
//*/

/**/
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
		functionSubnetId: functionSubnetId
		}
		dependsOn:[
		virtualNetwork
		keyVault
			mainStorage
		auditStorage
		]
	}//functionApp
//*/

/**/
	output SystemAssignedIdentityId string = functionApp.outputs.SystemAssignedIdentityId
	output SystemAssignedPrincipalIdentity object = functionApp.outputs.SystemAssignedPrincipalIdentity
	output ReaderRoleDefinitionName string = functionApp.outputs.ReaderRoleDefinitionName
	output ReaderRoleDefinitionId string = functionApp.outputs.ReaderRoleDefinitionId
	//output delegatedManagedIdentityResourceId string = functionApp.outputs.delegatedManagedIdentityResourceId

	//output readerRoleAssignmentprincipalId string = functionApp.outputs.readerRoleAssignmentprincipalId
	//output readerRoleAssignmentId string = functionApp.outputs.readerRoleAssignmentId
//*/

/**/
	param sqlServerName string = 'sql-${DeployObject.SolutionName}'
	param sqlDatabaseName string = 'sqldb-${DeployObject.SolutionName}'
	module sqlServer 'modules/sqlserver.bicep'= {
		scope: dtsResourceGroup
		name: DeployObject.SqlServerName
		params: {
		location:dtsResourceGroup.location
		tags: Tags
		SolutionObj: SolutionObj
		DeployObject: DeployObject
		sqlServerName: sqlServerName
		sqlDatabaseName: sqlDatabaseName
		sqlDatabaseSku: sqlDatabaseSku
		vnetId : vnetId
		storageSubnetId: storageSubnetId
		sqlServerAdministratorLogin: DeployObject.SqlAdmin
		sqlServerAdministratorPassword: DeployObject.SqlAdminPwd 
 }
		dependsOn: [
			mainStorage
			virtualNetwork
			keyVault
		]
	}//sqlServer
//*/

/**/
	//output cmk_SqlDatabaseKeyUri string = sqlServer.outputs.cmk_SqlDatabaseKeyUri
	output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn
	output SqlConnectionString string = sqlServer.outputs.SqlConnectionString
	//output cmkSqlDatabaseKeyId string =  sqlServer.outputs.cmkSqlDatabaseKeyId
	//output sqlIdentityPrincipalName string = sqlServer.outputs.sqlIdentityPrincipalName
	output sqlIdentityPrincipalId string = sqlServer.outputs.sqlIdentityPrincipalId
	//output cmkSqlKeykeyUriWithVersion string = sqlServer.outputs.cmkSqlKeykeyUriWithVersion
//*/


output solutionObject object = SolutionObj


/*
	module roleAssignments 'modules/roleAssignments.bicep' ={
		scope
	}//roleAssignments
//*/


//*/

/*
	output cmkMainStKeyNameKeyVault string = keyVault.outputs.cmkMainStKeyName
	output cmkMainStKeyNameStorage string = mainStorage.outputs.cmkMainStKeyNameStorage
	output cmkAuditStKeyNameStorage string = auditStorage.outputs.cmkAuditStKeyNameStorage
	//output functionSubnetIdout string = functionSubnetId
	//output environmentSuffixesStorage string = environment().suffixes.storage
	//output protocol string = environment().suffixes.keyvaultDns
	//output ConnectionString string = appServicePlan.outputs.ConnectionString
	//output InstrumentationKey string = appServicePlan.outputs.InstrumentationKey

//*/


/*
	output subnetId string = functionApp.outputs.subnetId
	output functionSubnetName string = functionApp.outputs.functionSubnetName
	//output contentShare string = functionApp.outputs.contentShare
	//output subscriptionID string = functionApp.outputs.subscriptionID
	

	//output appServiceAppHostName string = appService.outputs.appServiceAppHostName

	//output webAppInboundIP string = appService.outputs.webAppInboundIP
	//output virtfunctionsubnetid string = functionApp.outputs.virtfunctionsubnetid
	//var SqlkeyUriWithVersion  = keyvault.outputs.cmk_SqlkeyUriWithVersion
	//output appServplanId string = appServicePlan.outputs.planId

	//output resgroupName string = dtsResourceGroup.name

	//output mainStuserPrincipalId string = storageAccounts.outputs.mainStuserPrincipalId
	//output mainStuserAssignedIdentities object = storageAccounts.outputs.mainStuserAssignedIdentities
	//[reference(resourceId('Microsoft.Storage/storageAccounts', variables('uniqueResourceNameBase')),'2019-06-01', 'full').identity.principalId]",
	//var ctsStorageName = storageAccounts.outputs.ctsStorageName

	//output sql_cmk_SqlkeyUriWithVersion string = sqlServer.outputs.cmk_SqlkeyUriWithVersion


	//output funcSubnetId string = functionSubnetId
	//output sasToken string = storageAccounts.outputs.sasToken
	//output sqlconnstring string = functionApp.outputs.sqlconnstring

	//output site string = SiteName
	//output apiAppId string = ApiClientId
	//output secret string = ApiClientSecret


	//output vnetId string = virtualNetwork.outputs.vnetId
	//output mainStorageName string = storageAccounts.outputs.mainStorageName
	//output storageAccountResourceID string = mainStorage.outputs.storageAccountResourceID

	//output auditStorageName string = storageAccounts.outputs.auditStorageName
	//output auditStorageId string = storageAccounts.outputs.auditStorageId


	//output nsgId string = virtualNetwork.outputs.nsgId
	//output vnetName string = virtualNetwork.outputs.vnetName

//*/

