targetScope = 'subscription'

//output environmentOutput object = environment()

@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'test'
  'prod'
  'dev'
])
param EnvironmentType string

@description('This determines if we are deploying the DTP (Transfer) or DPP (DPP)')
@allowed([
  'All'
  'Transfer'
  'Pickup'  
])
param Solution string

@description('The Azure region into which the resources should be deployed.')
param location string = deployment().location

param CurrUserName string 
param CurrUserId string 
param TimeStamp string
param DepDate string = TimeStamp
param DepTime string = split(TimeStamp, ' ')[1]
 
output SolutionInParam string = Solution

param resourceTags object = {  
  DeployDate: DepDate
  DeployTime: DepTime
  Environment: EnvironmentType
  DeployedBy: CurrUserName
  Owner: CurrUserName
  Solution: Solution
}

param RoleDefinitionId string
param CryptoEncryptRoleId string

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(3)
@maxLength(30)
param AppName string

@description('BaseName for the resource group.  Final name will indicate environmentType as well')
param ResourceGroupName  string 

@secure()
@description('API App Registrations\' ID created by the PowerShell')
param ApiClientId string

@secure()
@description('The API App Registration\' secret created by the PowerShell')
param ApiClientSecret string

param virtualNetworkObj object

param storageAccountSkuName string
param StorageAccountsArr array

param appServicePlanSku object
param keyVaultProps object

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

//This array is being used to create the secrets in the keyvault
param  entities array = [
  {  
    secretName: 'ApiClientId'
    secretValue: ApiClientId
    enabled: true
  }
  {    
    secretName: 'ApiClientSecret'
    secretValue: ApiClientSecret
    enabled: true
  }  
  {    
    secretName: 'RoleDefinitionId'
    secretValue: RoleDefinitionId
    enabled: true
  }
 {
    secretName: 'sqlServerAdministratorLogin'
    secretValue: sqlServerAdministratorLogin
    enabled: true
  }
  {
    secretName: 'sqlServerAdministratorPassword'
    secretValue: sqlServerAdministratorPassword
    enabled: true
  }
]

//param azureCloud string = environment().name
param workspaceLocation string = (environment().name == 'AzureUSGovernment') ?  'usgovvirginia' : deployment().location

//output environmentName string = environment().name
//output AzureCloudFlag bool = (environment().name == 'AzureUSGovernment')
var SolutionName = '${AppName}-${EnvironmentType}'
@description('The name of the virtual network for virtual network integration.')
var vNetName = 'vnet-${SolutionName}'
var mainStorageDeployment  = 'mainStorage-${SolutionName}'
var auditStorageDeployment  = 'auditStorage-${SolutionName}'
//var functionAppName = 'func-api-${SolutionName}'
var functionAppName = '${AppName}api'
var planName = 'asp-${SolutionName}'
var keyVaultName = 'kv-${SolutionName}'
var managedUserName = 'id-${SolutionName}'
var keyvaultSubnetName = 'snet-keyvault-${SolutionName}'
var storageSubnetName = 'snet-storage-${SolutionName}'
var appServiceName = 'webapp-${SolutionName}'
var webappSubnetName = 'snet-webapp-${SolutionName}'

var sqlServerName = 'sql-${SolutionName}'
var sqlDatabaseName = 'sqldb-${SolutionName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: ResourceGroupName
  location: location
  tags: resourceTags  
}
module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: vNetName  
  params: {
    location: resourceGroup.location
    SolutionName: SolutionName
    virtualNetworkObj: virtualNetworkObj
    tags: resourceTags
  }
}


var vnetId = virtualNetwork.outputs.vnetId
var keyvaultSubnetId  = '${vnetId}/subnets/${keyvaultSubnetName}'
module keyVault 'modules/keyvault.bicep'={
  scope:resourceGroup
  name: keyVaultName
  params:{
    location:resourceGroup.location
    tags: resourceTags
    managedUserName: managedUserName
    SolutionName: SolutionName
    entities : entities 
    keyVaultName: keyVaultName
    keyVaultProps: keyVaultProps
    keyvaultSubnetId: keyvaultSubnetId    
    StorageAccountsArr: StorageAccountsArr
    CurrUserId: CurrUserId
    Solution: Solution
    //CryptoEncryptRoleId: CryptoEncryptRoleId
  }
  dependsOn: [
    virtualNetwork
  ]
}

//output CryptoEncryptRoleId string = CryptoEncryptRoleId
//output  roleDefinitionIdToSet string = keyVault.outputs.roleDefinitionIdToSet
module appServicePlan 'modules/appServPlan.bicep' ={
  scope:resourceGroup
  name : planName
  dependsOn:[
    virtualNetwork
    keyVault
  ]
  params:{
    location:resourceGroup.location
    aspName:planName
    tags: resourceTags
    SolutionName: SolutionName
    appServicePlanSku: appServicePlanSku
    workspaceLocation: workspaceLocation  }
}
//output ConnectionString string = appServicePlan.outputs.ConnectionString
//output InstrumentationKey string = appServicePlan.outputs.InstrumentationKey

var planId = appServicePlan.outputs.planId
var webappSubnetId  = '${vnetId}/subnets/${webappSubnetName}'

module appService 'modules/appService.bicep' = {
  scope: resourceGroup
  name: appServiceName
  dependsOn:[
    virtualNetwork
    keyVault
  ]
  params:{
    location:resourceGroup.location
    SolutionName: SolutionName
    tags: resourceTags
    planId:planId
    webSiteName: AppName
    webappSubnetId: webappSubnetId
    vnetId : vnetId
  }
}

var storageSubnetId  = '${vnetId}/subnets/${storageSubnetName}'

//Run the storage module, setting scope to the resource group we just created.
module mainStorage 'modules/mainStorage.bicep' ={
  scope: resourceGroup
  name: mainStorageDeployment  
  dependsOn:[
    virtualNetwork
    keyVault
    appService
  ]
  params: {
    location: resourceGroup.location
    EnvType : EnvironmentType
    AppName: AppName
    tags: resourceTags
    storageAccountSkuName:storageAccountSkuName
    StorageAccountsArr: StorageAccountsArr    
    storageSubnetId: storageSubnetId
    managedUserName: managedUserName
    keyVaultName: keyVaultName
    Solution: Solution
  }
}


module auditStorage 'modules/auditStorage.bicep' = if(Solution == 'Transfer'){
  scope: resourceGroup
  name: auditStorageDeployment  
  dependsOn:[
    virtualNetwork
    keyVault
    appService
    mainStorage
  ]
  params: {
    location: resourceGroup.location
    EnvType : EnvironmentType
    AppName: AppName
    tags: resourceTags
    storageAccountSkuName:storageAccountSkuName
    StorageAccountsArr: StorageAccountsArr    
    storageSubnetId: storageSubnetId
    managedUserName: managedUserName
    keyVaultName: keyVaultName
    Solution: Solution
  }
}


module sqlServer 'modules/sqlserver.bicep'= if(Solution == 'Transfer'){
  scope: resourceGroup
  name: sqlServerName
  params: {
    location:resourceGroup.location
    SolutionName: SolutionName
    tags: resourceTags
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    sqlDatabaseSku: sqlDatabaseSku
    vnetId : vnetId
    storageSubnetId: storageSubnetId
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
    Solution: Solution    
 }
 dependsOn: [
  mainStorage
  virtualNetwork
  keyVault
]
}


var storageAccountName= mainStorage.outputs.mainStorageName
var functionSubnetName = 'snet-functionintegration-${SolutionName}'
var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'

//output functionSubnetIdout string = functionSubnetId
//output EndpointSuffix string = environment().suffixes.storage
//output protocol string = environment().suffixes.keyvaultDns

module functionApp 'modules/functionapp.bicep' ={
  scope: resourceGroup
  name: functionAppName
  dependsOn:[
    virtualNetwork
    keyVault
    sqlServer
    mainStorage
  ]
  params:{
    functionAppName: functionAppName
    location: resourceGroup.location
    SolutionName: SolutionName
    tags: resourceTags
    serverFarmId : planId
    storageAccountName  : storageAccountName
    ApiClientId: ApiClientId
    //ApiClientSecret: ApiClientSecret        
    functionSubnetId: functionSubnetId    
    //sqlServerAdministratorPassword: sqlServerAdministratorPassword
    RoleDefinitionId:RoleDefinitionId
    Solution: Solution
  }
}

//*/
/*
output subnetId string = functionApp.outputs.subnetId
output functionSubnetName string = functionApp.outputs.functionSubnetName

//*/
//output contentShare string = functionApp.outputs.contentShare
//output subscriptionID string = functionApp.outputs.subscriptionID



//output appServiceAppHostName string = appService.outputs.appServiceAppHostName

//*/
//output webAppInboundIP string = appService.outputs.webAppInboundIP
//output virtfunctionsubnetid string = functionApp.outputs.virtfunctionsubnetid
//var SqlkeyUriWithVersion  = keyvault.outputs.cmk_SqlkeyUriWithVersion
//output appServplanId string = appServicePlan.outputs.planId
//output keyVaultURI string = keyvault.outputs.keyVaultId
//output resgroupName string = resourceGroup.name
//output mainStuserIdentity object = storageAccounts.outputs.mainStuserIdentity
//output mainStuserPrincipalId string = storageAccounts.outputs.mainStuserPrincipalId
//output mainStuserAssignedIdentities object = storageAccounts.outputs.mainStuserAssignedIdentities
//[reference(resourceId('Microsoft.Storage/storageAccounts', variables('uniqueResourceNameBase')),'2019-06-01', 'full').identity.principalId]",
//var ctsStorageName = storageAccounts.outputs.ctsStorageName

//output sql_cmk_SqlkeyUriWithVersion string = sqlServer.outputs.cmk_SqlkeyUriWithVersion
//output keyvault_cmk_SqlkeyUriWithVersion string = keyvault.outputs.cmk_SqlkeyUriWithVersion

//output funcSubnetId string = functionSubnetId
//output sasToken string = storageAccounts.outputs.sasToken
//output sqlconnstring string = functionApp.outputs.sqlconnstring

//output site string = SiteName
//output apiAppId string = ApiClientId
//output secret string = ApiClientSecret


//output vnetId string = virtualNetwork.outputs.vnetId
//output mainStorageName string = storageAccounts.outputs.mainStorageName
//output mainStorageId string = storageAccounts.outputs.mainStorageId

//output auditStorageName string = storageAccounts.outputs.auditStorageName
//output auditStorageId string = storageAccounts.outputs.auditStorageId


//output nsgId string = virtualNetwork.outputs.nsgId
//output vnetName string = virtualNetwork.outputs.vnetName
