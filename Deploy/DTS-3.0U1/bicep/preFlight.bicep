targetScope = 'subscription'

param tags object

var deploymentConfig = json(loadTextContent('../deployment-config.json'))
var location = deploymentConfig.location

// Deploy the network using the network module
module networkDeployment 'modules/network.bicep' = {
  name: 'networkDeployment'
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    location: location
    vnetName: deploymentConfig.network.vnet.name
    addressPrefix: deploymentConfig.network.vnet.addressPrefix
    subnets: deploymentConfig.network.vnet.subnets
    workspaceId: logAnalyticsDeployment.outputs.workspaceId
    tags: tags
  }
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

module keyvaults 'modules/keyvault.bicep' = [for kv in deploymentConfig.keyVaults: {
  name: kv.name
  scope: resourceGroup(deploymentConfig.resourceGroupName)
  params: {
    keyvaultName: kv.name
    location: deploymentConfig.location
    vnetName: deploymentConfig.network.vnet.name
    subnetName: 'keyvault'
    privateEndpointName: kv.privateEndpointName
    privateDnsName: kv.privateDnsName
    keysToCreate: kv.keysToCreate
    workspaceId: logAnalyticsDeployment.outputs.workspaceId
    tags:tags
  }
}]

