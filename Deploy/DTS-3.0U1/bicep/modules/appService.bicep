// Parameters
@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the App Service/Web App')
param webAppName string

@description('Location for the App Service Plan and related resources')
param location string

@description('Size of the App Service Plan')
param appServicePlanSize string

@description('Tier of the App Service Plan')
param appServicePlanTier string

@description('Indicates if the App Service Plan should be reserved. Specifically for Linux.')
param reserved bool = false

@description('Operating System Type (Windows/Linux)')
param osType string

@description('Array of application settings for the App Service')
param appSettings array

@description('Name of the private endpoint for App Service')
param privateEndpointName string

@description('Name of the private DNS for App Service')
param privateDnsName string

@description('Name of the Virtual Network the private endpoint is connected to')
param vnetName string

@description('Name of the subnet the private endpoint is connected to')
param subnetName string

@description('The Log Analytics workspace ID for monitoring and diagnostics.')
param workspaceId string

param tags object

// Variables
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

// App Service Plan Resource
resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: appServicePlanName
  location: location
  kind: osType
  tags: tags
  sku: {
    name: appServicePlanSize
    tier: appServicePlanTier
  }
  properties: osType == 'Linux' ? {
    reserved: reserved
  } : {}
}

// App Service/Web App Resource
resource webApp 'Microsoft.Web/sites@2021-01-01' = {
  name: webAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: appSettings
    }
    httpsOnly: true
  }
}

// Private Endpoint for the App Service
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'plsConnection'
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnetId
    }
  }
}

// Private DNS Zone
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsName
  location: 'global'
  tags: tags
}

// Link between Private DNS Zone and Virtual Network
// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
//   name: '${privateDnsName}/${vnetName}-vnet-link'
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: resourceId('Microsoft.Network/virtualNetworks', vnetName)
//     }
//     registrationEnabled: false
//   }
// }

resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: appServicePlan.name
  scope: appServicePlan
  properties: {
    workspaceId: workspaceId
    logs: [
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}

resource wepdiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: webApp.name
  scope: webApp
  properties: {
    workspaceId: workspaceId
    logs: [
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output webAppUrl string = webApp.properties.defaultHostName
