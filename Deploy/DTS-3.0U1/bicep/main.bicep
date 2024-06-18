targetScope = 'subscription'

@description('The SQL server admin password')
@secure()
param sqlAdminPassword string

@description('The virtual machine admin password')
@secure()
param vmAdminPassword string

param tags object

var deploymentConfig = json(loadTextContent('../deployment-config.json'))
var location = deploymentConfig.location

// Retreive Network
resource network 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  name: deploymentConfig.network.vnet.name
}

// Retreive main KeyVault
resource mainkv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  name: deploymentConfig.keyVaults[0].name
}

// Log Analytics Deployment
module logAnalyticsDeployment 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    logAnalyticsWorkspaceName: deploymentConfig.logAnalytics.workspaceName
    location: location
    sku: deploymentConfig.logAnalytics.sku
    retentionTimeInDays: deploymentConfig.logAnalytics.retentionInDays
    tags: tags
  }
}

module bastionDeployment 'modules/bastion.bicep' = {
    name: 'bastionDeployment'
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      location: location
      bastionName: deploymentConfig.bastion.name
      vnetName: network.name
      bastionSubnetName: deploymentConfig.bastion.subnet.name
      workspaceId: logAnalyticsDeployment.outputs.workspaceId
      tags: tags
    }
}

module appInsightsDeployment 'modules/appInsights.bicep' = {
    name: 'appInsightsDeployment'
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      appInsightsName: deploymentConfig.appInsights.name
      location: deploymentConfig.location
      tags: tags
    }
}

module userAssignedIdentityDeployment 'modules/userAssignedIdentity.bicep' = {
  name: 'userAssignedIdentity'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    identityName: deploymentConfig.identity.name
    location: deploymentConfig.location
    tags: tags
  }
}

module userIdentityAccessPolicyDeployment 'modules/accessPolicy.bicep' = {
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  name: 'userIdentityAccessPolicy'
  params: {
    objectId: userAssignedIdentityDeployment.outputs.identityPrincipalId
    keyVaultName: mainkv.name
    keyPermission: ['get', 'UnwrapKey', 'WrapKey']
    secretPermission: ['get', 'list', 'set']
    certPermission: []
  }
}

module storageDeployments 'modules/storage.bicep' = [for storageConfig in deploymentConfig.storage: {
    name: storageConfig.name
    scope: resourceGroup(deploymentConfig.resourceGroupName)
    params: {
      storageName: storageConfig.name
      storageSku: storageConfig.sku
      location: deploymentConfig.location
      vnetName: deploymentConfig.network.vnet.name
      subnetName: 'storage'
      privateDnsName: storageConfig.privateDnsName
      privateEndpoints: storageConfig.services
      containers: storageConfig.containers
      queues: storageConfig.queues
      tables: storageConfig.tables
      fileShares: storageConfig.fileShares
      identityResourceId: userAssignedIdentityDeployment.outputs.identityId
      keyvaulturi: mainkv.properties.vaultUri
      keyName: 'cmk-${storageConfig.name}'
      workspaceId: logAnalyticsDeployment.outputs.workspaceId
      tags: tags
    }
    dependsOn: [userIdentityAccessPolicyDeployment]
}]

// SQL Server and SQL CMK
output uri string = mainkv.properties.vaultUri
var stKeyvault = last(split(mainkv.properties.vaultUri, '/'))

// module sqlDeployment 'modules/sql.bicep' = {
//     name: 'sqlDeployment'
//     scope: resourceGroup(deploymentConfig.resourceGroupName)
//     params: {
//       sqlServerName: deploymentConfig.sqlServer.name
//       sqlAdminName: deploymentConfig.sqlServer.sqlAdminName
//       sqlAdminPassword: sqlAdminPassword
//       location: location
//       vnetName: network.name
//       subnetName: 'storage'
//       privateDnsName: deploymentConfig.sqlServer.privateDnsName
//       privateEndpoints: deploymentConfig.sqlServer.privateEndpoints
//       databaseSku: deploymentConfig.sqlDatabase.sku
//       sqlDatabaseName: deploymentConfig.sqlDatabase.name
//       userManagedIdentityId: userAssignedIdentityDeployment.outputs.identityId
//       workspaceId: logAnalyticsDeployment.outputs.workspaceId
//       keyName: 'cmk-${deploymentConfig.sqlServer.name}'
//       keyvaultName: stKeyvault
//     }
// }


// module functionAppModule 'modules/functionApp.bicep' = [for functionApp in deploymentConfig.functionApps:{
//   name: '${functionApp.name}-functionAppDeployment'
//   scope: resourceGroup(deploymentConfig.resourceGroupName)
//   params: {
//     functionAppName: functionApp.name
//     storageAccountName: functionApp.storageAccountName
//     appServicePlanName: functionApp.appServicePlanName
//     suffix: functionApp.suffix
//     location: location
//     settings: functionApp.settings
//   }
// }]

// Module for App Service Plan & App Service (Web App)
// module appServiceModule 'modules/appService.bicep' = [for plan in deploymentConfig.appService.plans: {
//   name: '${plan.name}-deployment'
//   scope: resourceGroup(deploymentConfig.resourceGroupName)
//   params: {
//     appServicePlanName: plan.name
//     location: location
//     appServicePlanTier: plan.tier
//     appServicePlanSize: plan.size
//     osType: plan.osType
//     reserved: plan.reserved
//     webAppName: deploymentConfig.appService.webApp.name
//     appSettings: deploymentConfig.appService.webApp.environmentVariables
//     privateEndpointName: deploymentConfig.appService.webApp.privateEndpointName
//     privateDnsName: deploymentConfig.appService.webApp.privateDnsName
//     vnetName: deploymentConfig.network.vnet.name
//     subnetName: 'webapp'
//     workspaceId: logAnalyticsDeployment.outputs.workspaceId
//   }
// }]

param functionSubnetName = '/subnets/snet-function-'
// Module for Function Apps
module functionApp 'modules/functionApp.bicep' = [for functionApp in deploymentConfig.functionApps: {
  name: 'functionAppDeployment'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    appServicePlanName: deploymentConfig.appService.plan.name
    location: location
    tags: tags
    functionAppName: functionApp.name
    storageAccountName: functionApp.storageAccountName 
    privateEndpointName: functionApp.privateEndpointName
    virtualNetworkName: deploymentConfig.network.vnet.name 
    functionSubnetName: deploymentConfig.network.vnet.subnets[3].name
    functionIntegrationSubnetName: deploymentConfig.network.vnet.subnets[5].name
    suffix: ''
    // workspaceId: logAnalyticsDeployment.outputs.workspaceId
  }
  dependsOn:[
    
      networkDeployment
  ]
}]


module vmDeployments 'modules/virtualMachine.bicep' = [for vmConfig in deploymentConfig.vms: {
  name: vmConfig.name
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    vmName: take(vmConfig.name, 15)
    location: location
    vnetName: network.name
    subnetName: vmConfig.subnetName
    ipAddress: vmConfig.ipAddress
    vmSize: vmConfig.vmSize
    adminUsername: vmConfig.adminUsername
    adminPassword: vmAdminPassword
    dataDisks: vmConfig.dataDisks
    workspaceName: deploymentConfig.logAnalytics.workspaceName
    desKeyName: 'des-${vmConfig.name}'
    keyVaultName: mainkv.name
    diskEncryptionSetName: 'des-${vmConfig.name}'
    tags: tags
  }
}]

// Store SQL Admin Username and Secret in Keyvault
module sqlSecret 'modules/kvsecret.bicep' = {
  name: 'kvSqlAdminPassword'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: mainkv.name
      secretName: 'sqlAdminPassword'
      secretValue: sqlAdminPassword
  }
}

module sqlAdminUserName 'modules/kvsecret.bicep' = {
  name: 'kvsqlAdminUserName'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: mainkv.name
      secretName: 'sqlAdminUserName'
      secretValue: deploymentConfig.sqlDatabase.sqlAdminName
  }
}

// Store Vm Admin Username and Secret in Keyvault
module vmSecret 'modules/kvsecret.bicep' = {
  name: 'kvVmSecret'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: mainkv.name
      secretName: 'vmAdminPassword'
      secretValue: vmAdminPassword
  }
}

module vmAdminUserName 'modules/kvsecret.bicep' = {
  name: 'kvVmAdminUserName'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
      keyvaultName: mainkv.name
      secretName: 'vmAdminUserName'
      secretValue: deploymentConfig.vms[0].adminUsername
  }
}
