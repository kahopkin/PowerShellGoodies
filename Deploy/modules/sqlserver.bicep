@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location
param tags object
param sqlServerName string
param sqlDatabaseName string
param vnetId string
param storageSubnetId string
param SolutionName string

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

var sqlDnsZoneName = 'privatelink.sqldb.${SolutionName}'
var sqldbPrivateEndpointName = 'pep-sqldb-${SolutionName}'

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: sqlServerName
  tags: tags
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: sqlServer
  tags: tags
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

// -- Private DNS Zones --
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: sqlDnsZoneName
  location: 'global'
  tags: tags
  resource sqldbDnsZoneLink 'virtualNetworkLinks' = {
    name: '${sqlPrivateDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

// -- Private Endpoints --
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: sqldbPrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: storageSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'sql_privateLinkServiceConnection'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }

  resource sqldbPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'default'
   
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: sqlPrivateDnsZone.id
          }
        }
      ]
    }
  }
}
