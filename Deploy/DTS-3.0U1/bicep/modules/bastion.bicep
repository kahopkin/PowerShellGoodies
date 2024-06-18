@description('The Azure region where the resources should be deployed.')
param location string

@description('The name of the Azure Bastion host to create.')
param bastionName string

@description('The name of the virtual network where Azure Bastion should be deployed.')
param vnetName string

@description('The name of the subnet within the virtual network specifically for Azure Bastion.')
param bastionSubnetName string

@description('The Log Analytics workspace ID for monitoring and diagnostics.')
param workspaceId string

param tags object

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${bastionName}-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, bastionSubnetName)
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource bastionDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: bastion
  name: bastionName
  properties: {
    workspaceId: workspaceId    
    logs: [
      {
        category: 'BastionAuditLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}
