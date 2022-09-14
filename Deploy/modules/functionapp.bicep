targetScope = 'resourceGroup'

param location string
param SolutionName string
param tags object
param functionAppName string
param serverFarmId string
param mainStorageName string
param sqlServerName string
//param vnetName string
//param ctsStorageName string
//param connectionStringSAS string
param ApiClientId string
@secure()
param ApiClientSecret string
param functionSubnetId string
param vnetId string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

var funcPrivateEndpointName ='pep-func-${SolutionName}'
@description('The name of the virtual network subnet to be associated with the Azure Function app.')
var functionSubnetName = '/subnets/snet-function-${SolutionName}'
//var functionSubnetName = 'snet-function-${SolutionName}'
var subnetId = '${vnetId}${functionSubnetName}'
@description('The name of the virtual network subnet used for allocating IP addresses for private endpoints.')

var functionRuntime = 'dotnet'
var netFrameworkVersion = 'v6.0'
var tenantId = subscription().tenantId

/*
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  name: vnetName  
}

resource functionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' existing = {
  name: functionSubnetName
}
*/
resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
  name:mainStorageName
}
/*
resource ctsStorageAccount'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
  name:ctsStorageName
}
*/
resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  name:sqlServerName
}
resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  name: 'sqldb-${SolutionName}'
}

//output virtfunctionsubnetid string = functionSubnet.id
//output test string = ctsStorageAccount.listAccountSas()
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  identity:{
    type:'SystemAssigned'
  }
  tags: tags
  kind: 'functionapp'
  properties: {      
    serverFarmId: serverFarmId
    httpsOnly: true
    clientAffinityEnabled: true
    storageAccountRequired: false
    clientCertMode: 'Required'    
    virtualNetworkSubnetId: functionSubnetId
    keyVaultReferenceIdentity: 'SystemAssigned'
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.us'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}.scm.azurewebsites.us'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]  
  }
}


resource function_WebConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: functionApp
  name: 'web'  
  properties: {         
    publishingUsername: '$functionAppName'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    vnetName: 'snet-functionintegration-${SolutionName}'
    vnetRouteAllEnabled: true
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://${functionAppName}.azurewebsites.us'
        'http://localhost:3000'
      ]
      supportCredentials: true
    }
    netFrameworkVersion:  netFrameworkVersion
    alwaysOn: true
    minTlsVersion: '1.2'
    ftpsState: 'Disabled'
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
  }
}

resource apiAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    authEndpoint: 'https://login.microsoftonline.us'        
    AuditStorageAccessKey: 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    AzStorageAccessKey : 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name}; AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    AzureWebJobsSecretStorageType: 'files'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name}; AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    blobEndpoint: 'https://${mainStorageAccount.name}.blob.core.usgovcloudapi.net/'
    clientID: ApiClientId
    clientSecret:ApiClientSecret
    completedContainerName: 'completedcontainers'    
    createCTSContainer: 'false'
    ctsStorageSASUri: 'blobServiceSasUrl'
    deleteAuditBlobContainerName: 'insights-logs-storagedelete'
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    FUNCTIONS_EXTENSION_VERSION: '~4'            
    readAuditBlobContainerName: 'insights-logs-storageread'    
    roleDefinitionId:'a04aad57-4986-4269-ad2a-325c867557f0'
    sentinelTimer: '0 59 23 * * *'    
    SqlConnectionString:'Server=tcp:${sqlServer.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${sqlServerAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;'
    storageAccountResourceID: serverFarmId        
    tenantID: tenant().tenantId    
    validationTimeOut: '10'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}' 
    WEBSITE_CONTENTOVERVNET:'1'    
    WEBSITE_CONTENTSHARE: functionAppName    
    WEBSITE_DNS_SERVER: '168.63.129.16'
    WEBSITE_RUN_FROM_PACKAGE: '1'
    writeAuditBlobContainerName:'insights-logs-storagewrite'
    XDT_MicrosoftApplicationInsights_Mode: 'Recommended'    
  }
}

/*
resource funcAuthSetting 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'authsettings'
  kind: 'string'
  parent: functionApp
  properties: {    
    clientId: ApiClientId
    //clientSecret: ApiClientSecret    
    clientSecretSettingName: 'clientSecret'    
    defaultProvider: 'AzureActiveDirectory'
    enabled: true    
    issuer:  'https://sts.windows.net/${tenantId}'
    validateIssuer: true
    unauthenticatedClientAction:'RedirectToLoginPage'
  }
}
//*/

resource funcAuthSettginsv2 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'authsettingsV2'
  kind: 'string'
  parent: functionApp
  properties: {
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        isAutoProvisioned: true
        registration: {
          clientId: ApiClientId
          clientSecretSettingName: 'clientSecret'
          openIdIssuer: 'https://sts.windows.net/${tenantId}'
        }         
    }
  }
}
}
//*/

//output adminLogin string = sqlServer.properties.administratorLogin
//output sqlconnstring string = '${sqlServer.name}${environment().suffixes.sqlServerHostname}'

resource functionhostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: functionApp  
  name: '${functionAppName}.azurewebsites.us'
  properties: {
    siteName: functionAppName
    hostNameType: 'Verified'
  }
}


resource func_privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {  
  name: funcPrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: funcPrivateEndpointName        
        properties: {
          privateLinkServiceId: functionApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]

  }
}

resource functionApp_virtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
  parent: functionApp
  name: '${functionAppName}-virtualNetworkConnection'  
  properties: {
    vnetResourceId: functionSubnetId
    isSwift: true
  }
}
/*
resource func_privateEndpointConnection 'Microsoft.Web/sites/privateEndpointConnections@2021-03-01' = {
  parent: functionApp
  name: funcPrivateEndpointName  
  properties: {
    privateLinkServiceConnectionState: {
      status: 'Approved'
      actionsRequired: 'None'
    }
  }
}

resource functionApp_virtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
  parent: functionApp
  name: '${functionAppName}-virtualNetworkConnection'  
  properties: {
    vnetResourceId: functionSubnetId
    isSwift: true
  }
}

//*/

/*
resource function_virtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
  parent: functionApp
  name:'${funcPrivateEndpointName}-link'
  properties: {
    vnetResourceId: functionSubnetId
  }
}
//*/


/*
resource func_privateEndpointConnection 'Microsoft.Web/sites/privateEndpointConnections@2021-03-01' = {  
  parent: functionApp
  name: '${funcPrivateEndpointName}-connection'
  properties: {
    privateLinkServiceConnectionState: {
      status: 'Approved'
      actionsRequired: 'None'
    }
  }
}
//*/
var functionAppUrl = 'https://${functionApp.properties.defaultHostName}'
output functionAppHostName string = functionApp.properties.defaultHostName
output functionAppUrl string = functionAppUrl
