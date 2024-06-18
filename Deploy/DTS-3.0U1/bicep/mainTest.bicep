targetScope = 'subscription'

@description('The SQL server admin password')
@secure()
param sqlAdminPassword string

@description('The virtual machine admin password')
@secure()
param vmAdminPassword string

@description('Tags for Environment, DeployedDate and DeployedBy')
param tags object

var deploymentConfig = json(loadTextContent('../deployment-config.json'))
var location = deploymentConfig.location

// Deploy the network using the network module
module networkDeployment 'modules/network.bicep' = {
    name: 'networkDeployment'
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      location: location
      tags: tags
      vnetName: deploymentConfig.network.vnet.name
      addressPrefix: deploymentConfig.network.vnet.addressPrefix
      subnets: deploymentConfig.network.vnet.subnets
      workspaceId: logAnalyticsDeployment.outputs.workspaceId
    }
}
/*
module bastionDeployment 'modules/bastion.bicep' = {
    name: 'bastionDeployment'
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      location: location
      tags: tags
      bastionName: deploymentConfig.bastion.name
      vnetName: networkDeployment.outputs.vnetName
      bastionSubnetName: deploymentConfig.bastion.subnet.name
      workspaceId: logAnalyticsDeployment.outputs.workspaceId
    }
}//
//*/

// Log Analytics Deployment
/**/
module logAnalyticsDeployment 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {    
    logAnalyticsWorkspaceName: deploymentConfig.logAnalytics.workspaceName
    location: location
    tags: tags
    sku: deploymentConfig.logAnalytics.sku
    retentionTimeInDays: deploymentConfig.logAnalytics.retentionInDays
  }
}//
//*/


/*
module appInsightsDeployment 'modules/appInsights.bicep' = {
    name: 'appInsightsDeployment'
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      appInsightsName: deploymentConfig.appInsights.name
      location: deploymentConfig.location
      tags: tags
    }
}//
//*/


/**/
module userAssignedIdentityDeployment 'modules/userAssignedIdentity.bicep' = {
  name: 'userAssignedIdentity'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    identityName: deploymentConfig.identity.name
    location: deploymentConfig.location
    tags: tags
  }
}//
//*/



output vnetId string = resourceId('Microsoft.Network/virtualNetworks', deploymentConfig.network.vnet.name)
module keyvaults 'modules/keyvault.bicep' = [for kv in deploymentConfig.keyVaults: {
    name: kv.name
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
        keyvaultName: kv.name
        location: deploymentConfig.location
        tags: tags
        vnetName: deploymentConfig.network.vnet.name
        subnetName: 'keyvault'
        privateEndpointName: kv.privateEndpointName
        privateDnsName: kv.privateDnsName
        keysToCreate: kv.keysToCreate
        accessPolicies: [
        {
            tenantId: subscription().tenantId
            objectId: userAssignedIdentityDeployment.outputs.identityPrincipalId
            permissions: {
            keys: ['get', 'UnwrapKey', 'WrapKey']
            secrets: ['get', 'list', 'set']
            }
        }
        ]
        workspaceId: logAnalyticsDeployment.outputs.workspaceId
}
}]//
//*/


/**/
module storageDeployments 'modules/storage.bicep' = [for storageConfig in deploymentConfig.storage: {
    name: storageConfig.name
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      storageName: storageConfig.name
      storageSku: storageConfig.sku
      location: deploymentConfig.location
      tags: tags
      vnetName: deploymentConfig.network.vnet.name
      subnetName: 'storage'
      privateDnsName: storageConfig.privateDnsName
      privateEndpoints: storageConfig.services
      containers: storageConfig.containers
      queues: storageConfig.queues
      tables: storageConfig.tables
      fileShares: storageConfig.fileShares
      identityResourceId: userAssignedIdentityDeployment.outputs.identityId
      keyvaulturi: keyvaults[0].outputs.keyvaultUri
      keyName: 'cmk-${storageConfig.name}'
      workspaceId: logAnalyticsDeployment.outputs.workspaceId
    }
}]//
//*/


/*
// SQL Server and SQL CMK
output uri string = keyvaults[0].outputs.keyvaultUri
var stKeyvault = last(split(keyvaults[0].outputs.keyvaultId, '/'))

module sqlDeployment 'modules/sql.bicep' = {
    name: 'sqlDeployment'
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      sqlServerName: deploymentConfig.sqlServer.name
      sqlAdminName: deploymentConfig.sqlServer.sqlAdminName
      sqlAdminPassword: sqlAdminPassword
      location: location
      tags: tags
      vnetName: networkDeployment.outputs.vnetName
      subnetName: 'storage'
      privateDnsName: deploymentConfig.sqlServer.privateDnsName
      privateEndpoints: deploymentConfig.sqlServer.privateEndpoints
      databaseSku: deploymentConfig.sqlDatabase.sku
      sqlDatabaseName: deploymentConfig.sqlDatabase.name
      userManagedIdentityId: userAssignedIdentityDeployment.outputs.identityId
      workspaceId: logAnalyticsDeployment.outputs.workspaceId
      keyName: 'cmk-${deploymentConfig.sqlServer.name}'
      keyvaultName: stKeyvault
    }
}//
//*/



// Module for Function Apps
/**/
module functionApp 'modules/functionApp.bicep' = [for functionApp in deploymentConfig.functionApps: {
  name: '${functionApp.name}-Deployment'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    appServicePlanName: functionApp.plan
    location: location
    tags: tags
    functionAppName: functionApp.name
    storageAccountName: functionApp.storageAccountName 
    privateEndpointName: functionApp.privateEndpointName
    vnetName: deploymentConfig.network.vnet.name 
    functionSubnetName: deploymentConfig.network.vnet.subnets[3].name
    functionIntegrationSubnetName: deploymentConfig.network.vnet.subnets[5].name
    sku: deploymentConfig.appService.plans[0]
    suffix: ''
    settings: functionApp.settings
    //workspaceId: logAnalyticsDeployment.outputs.workspaceId
  }
  dependsOn:[    
      networkDeployment
      storageDeployments
  ]
}]//
//*/





//Module for App Service Plan & App Service (Web App)
/**/
module appServiceModule 'modules/appService.bicep' = [for plan in deploymentConfig.appService.plans: {
  name: '${plan.name}-deployment'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    appServicePlanName: plan.name
    location: location       
    appServicePlanTier: plan.tier
    appServicePlanSize: plan.size
    osType: plan.osType
    reserved: plan.reserved
    webAppName: deploymentConfig.appService.webApp.name
    appSettings: deploymentConfig.appService.webApp.environmentVariables
    privateEndpointName: deploymentConfig.appService.webApp.privateEndpointName
    privateDnsName: deploymentConfig.appService.webApp.privateDnsName
    vnetName: deploymentConfig.network.vnet.name
    subnetName: 'webapp'
    workspaceId: logAnalyticsDeployment.outputs.workspaceId
  }
  dependsOn:functionApp
}]//
//*/


/*
module vmDeployments 'modules/virtualMachine.bicep' = [for vmConfig in deploymentConfig.vms: {
  name: vmConfig.name
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    vmName: vmConfig.name
    location: location
    tags: tags
    vnetName: networkDeployment.outputs.vnetName
    subnetName: vmConfig.subnetName
    ipAddress: vmConfig.ipAddress
    vmSize: vmConfig.vmSize
    adminUsername: vmConfig.adminUsername
    AdminPassword: vmAdminPassword
    dataDisks: vmConfig.dataDisks
    workspaceName: deploymentConfig.logAnalytics.workspaceName
  }
}]//
//*/


/*
// Store SQL Admin Username and Secret in Keyvault
module sqlSecret 'modules/kvsecret.bicep' = {
  name: 'kvSqlAdminPassword'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: stKeyvault
      secretName: 'sqlAdminPassword'
      secretValue: sqlAdminPassword
  }
}//
//*/


/*
module sqlAdminUserName 'modules/kvsecret.bicep' = {
  name: 'kvsqlAdminUserName'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: stKeyvault
      secretName: 'sqlAdminUserName'
      secretValue: deploymentConfig.sqlDatabase.sqlAdminName
  }
}//
//*/



// Store Vm Admin Username and Secret in Keyvault
/*
module vmSecret 'modules/kvsecret.bicep' = {
  name: 'kvVmSecret'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: stKeyvault
      secretName: 'vmAdminPassword'
      secretValue: vmAdminPassword
  }
}//
//*/


/*
module vmAdminUserName 'modules/kvsecret.bicep' = {
  name: 'kvVmAdminUserName'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: stKeyvault
      secretName: 'vmAdminUserName'
      secretValue: deploymentConfig.vms[0].adminUsername
  }
}//
//*/


