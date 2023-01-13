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
//param EnvironmentType string
param Environment string
@description('The Azure region into which the resources should be deployed.')
param location string = deployment().location

/*param CurrUserName string 
param CurrUserId string 
//*/
param TimeStamp string
param DeployDate string =TimeStamp //= split(TimeStamp, ' ')[0]
param DeployTime string = split(TimeStamp, ' ')[1]

param DeployObject object

param Tags object = {  
  DeployDate: DeployDate
  DeployTime: DeployTime
  Environment: Environment
  DeployedBy: DeployObject.CurrUserName
  Owner: DeployObject.CurrUserName
  Solution: Solution
}

param SolutionName string = '${toLower(AppName)}-${toLower(Solution)}-${toLower(Environment)}'

//Parameters from the parameter file:
param virtualNetworkObj object
param storageAccountSkuName string
param StorageAccountsArr array

param appServicePlanSku object
param keyVaultProps object

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object
//*/

//This array is being used to create the secrets in the keyvault
param  entities array = (Solution == 'Transfer') ?  [
  {  
    secretName: 'ApiClientId'
    secretValue: (Solution == 'Transfer') ? DeployObject.TransferAppObj.APIAppRegAppId : DeployObject.PickupAppObj.APIAppRegAppId
    enabled: true
  } 
  {  
    secretName: 'ApiClientSecret'
    secretValue: (Solution == 'Transfer') ? DeployObject.TransferAppObj.APIAppRegClientSecret : DeployObject.PickupAppObj.APIAppRegClientSecret
    enabled: true
  } 
  {    
    secretName: 'RoleDefinitionId'
    secretValue: (Solution == 'Transfer') ? DeployObject.TransferAppObj.RoleDefinitionId :  DeployObject.PickupAppObj.RoleDefinitionId
    enabled: true
  } 
  {
    secretName: 'SqlServerAdministratorLogin'
    secretValue: (Solution == 'Transfer') ?  DeployObject.TransferAppObj.SqlAdmin : DeployObject.PickupAppObj.SqlAdmin
    enabled: true
  }
  {
    secretName: 'SqlServerAdministratorPassword'
    secretValue: (Solution == 'Transfer') ?  DeployObject.TransferAppObj.SqlAdminPwd : DeployObject.PickupAppObj.SqlAdminPwd
    enabled: true
  } 
] : [
  {  
    secretName: 'ApiClientId'
    secretValue: (Solution == 'Transfer') ? DeployObject.TransferAppObj.APIAppRegAppId : DeployObject.PickupAppObj.APIAppRegAppId
    enabled: true
  } 
  {  
    secretName: 'ApiClientSecret'
    secretValue: (Solution == 'Transfer') ? DeployObject.TransferAppObj.APIAppRegClientSecret : DeployObject.PickupAppObj.APIAppRegClientSecret
    enabled: true
  } 
  {    
    secretName: 'RoleDefinitionId'
    secretValue: (Solution == 'Transfer') ? DeployObject.TransferAppObj.RoleDefinitionId :  DeployObject.PickupAppObj.RoleDefinitionId
    enabled: true
  }  
]



//param WebSiteName string = (Solution == 'Transfer') ?  '${toLower(DeployObject.TransferAppObj.ClientAppRegName)}${toLower(Solution)}' : '${toLower(DeployObject.PickupAppObj.ClientAppRegName)}${toLower(Solution)}' 
//param FunctionAppName string = (Solution == 'Transfer') ?  '${toLower(DeployObject.TransferAppObj.APIAppRegName)}${toLower(Solution)}' : '${toLower(DeployObject.PickupAppObj.APIAppRegName)}${toLower(Solution)}' 

param WebSiteName string = (Solution == 'Transfer') ?  '${toLower(DeployObject.TransferAppObj.ClientAppRegName)}' : '${toLower(DeployObject.PickupAppObj.ClientAppRegName)}' 
param FunctionAppName string = (Solution == 'Transfer') ?  '${toLower(DeployObject.TransferAppObj.APIAppRegName)}' : '${toLower(DeployObject.PickupAppObj.APIAppRegName)}'

//var CurrUserName = DeployObject.CurrUserName
var CurrUserId = DeployObject.CurrUserId

//(Solution == 'Transfer') ?  DeployObject.TransferAppObj. : DeployObject.PickupAppObj. 
@description('BaseName for the resource group.  Final name will indicate environmentType as well')
var resourceGroupName  = (Solution == 'Transfer') ?  DeployObject.TransferAppObj.ResourceGroupName : DeployObject.PickupAppObj.ResourceGroupName 

@description('The name of the virtual network for virtual network integration.')
var vNetName = 'vnet-${SolutionName}'
var keyvaultSubnetName = 'snet-keyvault-${SolutionName}'
//var keyVaultName = (toLower(AppName) =='dtp') ? 'kv-${SolutionName}' : 'kv-${AppName}-${Solution}-${Environment}'
var keyVaultName = 'kv-${SolutionName}'
var managedUserName = 'id-${SolutionName}'
var planName = 'asp-${SolutionName}'
param workspaceLocation string = (environment().name == 'AzureUSGovernment') ?  'usgovvirginia' : deployment().location
var appServiceName = 'webapp-${SolutionName}'
var webappSubnetName = 'snet-webapp-${SolutionName}'
var storageSubnetName = 'snet-storage-${SolutionName}'
var mainStorageDeployment  = 'mainstorage-${SolutionName}'
var auditStorageDeployment  = 'auditStorage-${SolutionName}'
var sqlServerName = 'sql-${SolutionName}'
var sqlDatabaseName = 'sqldb-${SolutionName}'

param SolutionObj object ={
  AppName : AppName
  Solution : Solution
  Environment: Environment
  SolutionName : SolutionName
  WebSiteName : WebSiteName
  FunctionAppName : FunctionAppName
}

//output environmentOutput object = environment()
output AppName string = AppName
output Solution string = Solution
output Environment string = Environment
output SolutionName string = SolutionName

output keyVaultName string = keyVaultName

output resourceGroupName string = resourceGroupName
output WebSiteName string = WebSiteName
output FunctionAppName string = FunctionAppName

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
  tags: Tags  
}


module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: vNetName  
  params: {
    location: resourceGroup.location
    SolutionName: SolutionName
    virtualNetworkObj: virtualNetworkObj
    tags: Tags
  }
}
//*/

var vnetId = virtualNetwork.outputs.vnetId
var keyvaultSubnetId  = '${vnetId}/subnets/${keyvaultSubnetName}'

module keyVault 'modules/keyvault.bicep'={
  scope:resourceGroup
  name: keyVaultName
  params:{
    location:resourceGroup.location
    tags: Tags
    managedUserName: managedUserName
    SolutionName: SolutionName
    entities : entities 
    keyVaultName: keyVaultName
    keyVaultProps: keyVaultProps
    keyvaultSubnetId: keyvaultSubnetId    
    StorageAccountsArr: StorageAccountsArr
    CurrUserId: CurrUserId
    MyIP: DeployObject.MyIP    
    Solution: Solution
  }
  dependsOn: [
    virtualNetwork
  ]
}
//*/

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
    tags: Tags    
    SolutionObj: SolutionObj
    appServicePlanSku: appServicePlanSku
    workspaceLocation: workspaceLocation  }
}

var planId = appServicePlan.outputs.planId
//*/

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
    SolutionObj: SolutionObj
    tags: Tags
    planId:planId
    webSiteName: WebSiteName
    webappSubnetId: webappSubnetId
    vnetId : vnetId
  }
}
//*/
var storageSubnetId  = '${vnetId}/subnets/${storageSubnetName}'

//Run the storage module, setting scope to the resource group we just created.


module mainStorage 'modules/mainstorage.bicep' ={
  scope: resourceGroup
  name: mainStorageDeployment  
  dependsOn:[
    virtualNetwork
    keyVault
    appService
    //auditStorage
  ]
  params: {
    location: resourceGroup.location        
    tags: Tags
    storageAccountSkuName:storageAccountSkuName
    StorageAccountsArr: StorageAccountsArr    
    storageSubnetId: storageSubnetId    
    SolutionObj: SolutionObj
    MyIP: DeployObject.MyIP
  }
}

output storageAccountNameMain string = mainStorage.outputs.storageAccountName
//*/

module auditStorage 'modules/auditStorage.bicep' = {
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
    tags: Tags
    storageAccountSkuName:storageAccountSkuName    
    storageSubnetId: storageSubnetId
    SolutionObj: SolutionObj
    MyIP: DeployObject.MyIP
  }
}


output auditStAccountName string =auditStorage.outputs.auditStAccountName 
output auditStorageAccountName string = auditStorage.outputs.auditStAccountName 
//*/

output mainStorageNameMain string = mainStorage.name
output azureWebJobsStorage string = mainStorage.outputs.AzureWebJobsStorage
output blobEndpoint string = mainStorage.outputs.blobEndpoint
output azStorageAccessKey string = mainStorage.outputs.azStorageAccessKey
output auditStorageAccessKey string = auditStorage.outputs.auditStorageAccessKey

var mainStorageAccountName= mainStorage.outputs.mainStorageName
//*/

var functionSubnetName = 'snet-functionintegration-${SolutionName}'
var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'
module functionApp 'modules/functionapp.bicep' ={
  scope: resourceGroup
  name: FunctionAppName
  dependsOn:[
    virtualNetwork
    keyVault
    //sqlServer
  ]
  params:{    
    location: resourceGroup.location    
    tags: Tags
    serverFarmId : planId
    storageAccountName  : mainStorageAccountName
    ApiClientId: (Solution == 'Transfer') ? DeployObject.TransferAppObj.APIAppRegAppId : DeployObject.PickupAppObj.APIAppRegAppId
    ApiClientSecret: (Solution == 'Transfer') ? DeployObject.TransferAppObj.APIAppRegClientSecret : DeployObject.PickupAppObj.APIAppRegClientSecret
    functionSubnetId: functionSubnetId        
    RoleDefinitionId:(Solution == 'Transfer') ? DeployObject.TransferAppObj.RoleDefinitionId : DeployObject.PickupAppObj.RoleDefinitionId
    //connectionStringSAS: connectionStringSAS            
    SolutionObj: SolutionObj
    //MyIP: DeployObject.MyIP
  }
}
//*/


module sqlServer 'modules/sqlserver.bicep'= if(Solution == 'Transfer'){
  scope: resourceGroup
  name: sqlServerName
  params: {
    location:resourceGroup.location    
    tags: Tags
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    sqlDatabaseSku: sqlDatabaseSku
    vnetId : vnetId
    storageSubnetId: storageSubnetId
    sqlServerAdministratorLogin: (Solution == 'Transfer') ?  DeployObject.TransferAppObj.SqlAdmin : DeployObject.PickupAppObj.SqlAdmin
    sqlServerAdministratorPassword: (Solution == 'Transfer') ?  DeployObject.TransferAppObj.SqlAdminPwd : DeployObject.PickupAppObj.SqlAdminPwd
    //SqlkeyUriWithVersion: SqlkeyUriWithVersion
    SolutionObj: SolutionObj
 }
 dependsOn: [
  mainStorage
  virtualNetwork
  keyVault
]
}

 output SqlConnectionString string = (Solution == 'Transfer') ? sqlServer.outputs.SqlConnectionString : ''
//*/



/*
output cmkMainStKeyNameKeyVault string = keyVault.outputs.cmkMainStKeyName
output cmkMainStKeyNameStorage string = mainStorage.outputs.cmkMainStKeyNameStorage
output cmkAuditStKeyNameStorage string = (Solution == 'Transfer') ? auditStorage.outputs.cmkAuditStKeyNameStorage : '${Solution}'
//*/

//output functionSubnetIdout string = functionSubnetId
//output environmentSuffixesStorage string = environment().suffixes.storage
//output protocol string = environment().suffixes.keyvaultDns
//output ConnectionString string = appServicePlan.outputs.ConnectionString
//output InstrumentationKey string = appServicePlan.outputs.InstrumentationKey

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
//output storageAccountResourceID string = mainStorage.outputs.storageAccountResourceID

//output auditStorageName string = storageAccounts.outputs.auditStorageName
//output auditStorageId string = storageAccounts.outputs.auditStorageId


//output nsgId string = virtualNetwork.outputs.nsgId
//output vnetName string = virtualNetwork.outputs.vnetName
