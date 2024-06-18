@description('The name of the SQL server')
param sqlServerName string

@description('The SQL server admin name')
param sqlAdminName string

@description('The SQL server admin password')
@secure()
param sqlAdminPassword string

@description('Location for the SQL server and related resources')
param location string

@description('VNET name for the subnet association with private endpoint')
param vnetName string

@description('Subnet name for the association with private endpoint')
param subnetName string

@description('Name of the private DNS')
param privateDnsName string

@description('Array of private endpoints to create for the SQL server')
param privateEndpoints array = []

@description('The SKU for the SQL database')
param databaseSku object

@description('The name of the SQL database')
param sqlDatabaseName string

@description('The name of the Keyvault where the sql connnection string will be stored')
param keyvaultName string

// @description('')
// param keyvaulturi string

@description('')
param keyName string

@description('')
param userManagedIdentityId string

@description('')
param workspaceId string

param cmkSqlKeyUriWithVersion string

param tags object

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  tags: tags
  identity: {   
    type: 'SystemAssigned,UserAssigned'    
    userAssignedIdentities: {
      '${userManagedIdentityId}': {}
    } 
  }
  properties: {
    administratorLogin: sqlAdminName
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }
  // resource sqlServerKey 'keys@2021-11-01' = { //TODO
  //   name: keyName
  //   properties: {
  //     serverKeyType: 'AzureKeyVault'
  //     uri: formattedServerKeyName
  //   }
  // }
  

  resource encryptionProtector 'encryptionProtector@2021-11-01' = {
    name: 'current'
    properties: {
      serverKeyType: 'AzureKeyVault'
      serverKeyName: keyName
    }
  }
  // resource firewallRule 'firewallRules@2021-11-01' = { // This is NOT used if publicNetwork Access is disabled
  //   name: 'AllowAzureServices'
  //   properties: {
  //     startIpAddress: '0.0.0.0'
  //     endIpAddress: '0.0.0.0'
  //   }
  // }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: databaseSku
  tags: tags
  resource tde 'transparentDataEncryption@2021-11-01' = {
    name: 'current'
    properties: {
      state: 'Enabled'
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = [for endpoint in privateEndpoints: {
  name: endpoint.privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'plsConnection-${endpoint.type}'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            endpoint.type
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
  }
}]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsName
  location: 'global'
  tags: tags
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = [for (endpoint, i) in privateEndpoints: {
  parent: privateEndpoint[i]
  name: 'default-${endpoint.privateEndpointName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config-${endpoint.privateEndpointName}'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}]

// Retrieve sql database connection string
var sqlServerFqdn = sqlServer.properties.fullyQualifiedDomainName
var sqlConnectionString = 'Server=tcp:${sqlServerFqdn},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminName};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

// Save the connection string in KeyVault
module kvSecretModule 'kvsecret.bicep' = {
  name: 'saveSqlConnectionString'
  params: {
    keyvaultName: keyvaultName
    secretName: 'sqlConnectionString'
    secretValue: sqlConnectionString
    tags: tags
  }
}

resource sqlServerDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: sqlServerName
  scope: sqlServer
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
    ]
  }
}

output sqlServerId string = sqlServer.id
output sqlDatabaseId string = sqlDatabase.id
