@description('Name for the Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('Location for the Log Analytics workspace')
param location string

@description('Sku for the Log Analytics workspace: PerGB2018 (default), Free, Standalone, PerNode, Premium, Unlimited, CapacityReservation, and PerGB2019 are valid options')
param sku string = 'PerGB2018'

@description('Retention time in days. Minimum of 30 and maximum of 730.')
param retentionTimeInDays int = 30

param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionTimeInDays
  }
}

output workspaceId string = logAnalytics.id
output workspaceName string = logAnalytics.name
