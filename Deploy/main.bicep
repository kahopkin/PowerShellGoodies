targetScope = 'subscription'

@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'test'
  'prod'
  'dev'
])
param EnvironmentType string

//@description('The location into which the resources should be deployed.')
//param location string = resourceGroup().location
//param Location string

@description('The Azure region into which the resources should be deployed.')
param location string = deployment().location

param CurrUser string 

param utcValue string = utcNow('d')
param resourceTags object = {
  Environment: EnvironmentType
  DeployedBy: CurrUser
  Created: utcValue
}

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(3)
@maxLength(30)
param AppName string

param SolutionName string = '${AppName}-${EnvironmentType}'

@description('BaseName for the resource group.  Final name will indicate environmentType as well')
param ResourceGroupName  string = 'rg-${SolutionName}'

@secure()
@description('API App Registrations\' ID created by the PowerShell')
param ApiClientId string

@secure()
@description('The API App Registration\' secret created by the PowerShell')
param ApiClientSecret string

param virtualNetworkObj object
@description('The name of the virtual network for virtual network integration.')
param vnetName string = 'vnet-${SolutionName}'

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

var storageDeployment  = 'st-${SolutionName}'
var functionAppName = 'func-api-${SolutionName}'
var planName = 'plan-${SolutionName}'
var keyVaultName = 'kv-${SolutionName}'
var idName = 'id-${SolutionName}'
var keyvaultSubnetName = 'snet-keyvault-${SolutionName}'
var storageSubnetName = 'snet-storage-${SolutionName}'
var appServiceName = 'webapp-${SolutionName}'
var webappSubnetName = 'snet-webapp-${SolutionName}'
var functionSubnetName = 'snet-functionintegration-${SolutionName}'
var sqlServerName = 'sql-${SolutionName}'
var sqlDatabaseName = 'sqldb-${SolutionName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: ResourceGroupName
  location: location
  tags: resourceTags
}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: vnetName  
  params: {
    location: resourceGroup.location
    SolutionName: SolutionName
    virtualNetworkObj: virtualNetworkObj
    tags: resourceTags
  }
}

var vnetId = virtualNetwork.outputs.vnetId
var keyvaultSubnetId  = '${vnetId}/subnets/${keyvaultSubnetName}'

module keyvault 'modules/keyvault.bicep'={
  scope:resourceGroup
  name: keyVaultName
  params:{
    location:resourceGroup.location
    tags: resourceTags
    idName: idName
    SolutionName: SolutionName
    keyVaultName: keyVaultName
    keyVaultProps: keyVaultProps
    keyvaultSubnetId: keyvaultSubnetId
    vnetId: vnetId
  }
  dependsOn: [
    virtualNetwork
  ]
}
//*/

var storageSubnetId  = '${vnetId}/subnets/${storageSubnetName}'

//Run the storage module, setting scope to the resource group we just created.

module storageAccounts 'modules/storage.bicep' ={
  scope: resourceGroup
  name: storageDeployment  
  dependsOn:[
    virtualNetwork
  ]
  params: {
    location: resourceGroup.location
    EnvType : EnvironmentType
    AppName: AppName
    tags: resourceTags
    storageAccountSkuName:storageAccountSkuName
    StorageAccountsArr: StorageAccountsArr
    vnetId : virtualNetwork.outputs.vnetId
    storageSubnetId: storageSubnetId
  }
}

module appServicePlan 'modules/appServPlan.bicep' ={
  scope:resourceGroup
  name : planName
  dependsOn:[
    virtualNetwork
  ]
  params:{
    location:resourceGroup.location
    planName:planName
    tags: resourceTags
    appServicePlanSku: appServicePlanSku
  }
}

//output appServplanId string = appServicePlan.outputs.planId

var planId = appServicePlan.outputs.planId

var webappSubnetId  = '${vnetId}/subnets/${webappSubnetName}'

module appService 'modules/appService.bicep' = {
  scope: resourceGroup
  name: appServiceName
  dependsOn:[
    virtualNetwork
  ]
  params:{
    location:resourceGroup.location
    SolutionName: SolutionName
    tags: resourceTags
    planId:planId
    websiteName: AppName
    webappSubnetId: webappSubnetId
    vnetId : vnetId
  }
}

var mainStorageName= storageAccounts.outputs.mainStorageName
var functionSubnetId  = '${vnetId}/subnets/${functionSubnetName}'
output funcSubnetId string = functionSubnetId

module functionApp 'modules/functionapp.bicep' ={
  scope: resourceGroup
  name: functionAppName
  dependsOn:[
    virtualNetwork
    sqlServer
  ]
  params:{
    functionAppName: functionAppName
    location: resourceGroup.location
    SolutionName: SolutionName
    tags: resourceTags
    serverFarmId : planId
    mainStorageName : mainStorageName
    ApiClientId: ApiClientId
    ApiClientSecret: ApiClientSecret
    vnetId: vnetId
    sqlServerName: sqlServerName
    vnetName: vnetName
    functionSubnetId: functionSubnetId    
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
  }
}

//output virtfunctionsubnetid string = functionApp.outputs.virtfunctionsubnetid
//output adminLogin string = functionApp.outputs.adminLogin

module sqlServer 'modules/sqlserver.bicep'={
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
 }
 dependsOn: [
  storageAccounts
  virtualNetwork
]
}
//*/

//output sqlconnstring string = functionApp.outputs.sqlconnstring

//output site string = SiteName
//output apiAppId string = ApiClientId
//output secret string = ApiClientSecret

/*
output vnetId string = virtualNetwork.outputs.vnetId
output mainStorageName string = storageAccounts.outputs.mainStorageName
output mainStorageId string = storageAccounts.outputs.mainStorageId

output auditStorageName string = storageAccounts.outputs.auditStorageName
output auditStorageId string = storageAccounts.outputs.auditStorageId
//*/

//output nsgId string = virtualNetwork.outputs.nsgId
//output vnetName string = virtualNetwork.outputs.vnetName
