@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location
param tags object
param sqlServerName string
param sqlDatabaseName string
param vnetId string
param storageSubnetId string

param SolutionObj object
//var AppName = SolutionObj.AppName
var Solution = SolutionObj.Solution
var Environment = SolutionObj.Environment
var SolutionName = SolutionObj.SolutionName 
//var WebSiteName = SolutionObj.WebSiteName
//var FunctionAppName = SolutionObj.FunctionAppName

//param SqlkeyUriWithVersion string

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
//var cmkSqlDatabaseName = 'cmk-sqldb-${SolutionName}'
//var managedUserName = 'id-${SolutionName}'
var keyVaultName = 'kv-${SolutionName}'

/*
@allowed([
  'User'
  'Group'
  'Application'
])
param aad_admin_type string = 'User'
param aad_only_auth bool = true


resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing= {
  name: managedUserName  
}

//*/
/*
resource cmk_SqlDatabaseKey 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' existing = {
  name: cmkSqlDatabaseName
}
//*/
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
  name: keyVaultName
}
//output cmk_SqlkeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
//*/
resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = if(Solution == 'Transfer') {
  name: sqlServerName
  tags: tags
  location: location 
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: (Environment == 'Prod') ? 'Disabled' : 'Enabled'
  }
}

var SqlConnectionString = 'Server=tcp:${sqlServer.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${sqlServerAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;'
output SqlConnectionString string = SqlConnectionString

resource secret_SqlConnectionString 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if(Solution == 'Transfer') {
  name: 'SqlConnectionString'
  parent: keyVault
  tags:tags
  properties: {
    value: SqlConnectionString
    attributes:{
    enabled:true
    }
  }
}
/* identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedUser.id}': {}
    } 
  } 
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    //primaryUserAssignedIdentityId: managedUser.id
    //keyId: SqlkeyUriWithVersion   
    /*administrators: {
      login: aad_admin_name
      sid: aad_admin_objectid
      tenantId: subscription().tenantId
      principalType: aad_admin_type
      azureADOnlyAuthentication: aad_only_auth
    }
  */


resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = if(Solution == 'Transfer') {
  parent: sqlServer
  tags: tags
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

// -- Private DNS Zones --
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(Solution == 'Transfer') {
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
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if(Solution == 'Transfer' && Environment == 'Prod') {
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

