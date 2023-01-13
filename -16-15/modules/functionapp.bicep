targetScope = 'resourceGroup'

param location string

param tags object

param serverFarmId string
param storageAccountName string
param ApiClientId string

@secure()
param ApiClientSecret string
param functionSubnetId string
param RoleDefinitionId string 

param SolutionObj object
//var AppName = SolutionObj.AppName
var Solution = SolutionObj.Solution
var Environment = SolutionObj.Environment
var SolutionName = SolutionObj.SolutionName 
var WebSiteName = SolutionObj.WebSiteName
var FunctionAppName = SolutionObj.FunctionAppName

var vNetName = 'vnet-${SolutionName}'
var funcPrivateEndpointName ='pep-func-${SolutionName}'

var functionRuntime = 'dotnet'
var netFrameworkVersion = 'v6.0'
@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId
var subscriptionID = subscription().subscriptionId
output subscriptionID string = subscriptionID
//var privateDNSZoneName  = 'privatelink.azurewebsites.us'
var keyVaultName = 'kv-${SolutionName}'
//var functionAppKeySecretName = 'FunctionAppHostKey'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name:vNetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
  name: keyVaultName
}

var functionSubnetName = '/subnets/snet-function-${SolutionName}'
var subnetId = '${virtualNetwork.id}${functionSubnetName}'
output subnetId string = subnetId

resource functionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' existing = {
  parent: virtualNetwork
  name: functionSubnetName
}
//output functionSubnetId string = functionSubnet.id
output functionSubnetName string = functionSubnet.name

resource mainStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
  name:storageAccountName
}

resource webapp 'Microsoft.Web/sites@2020-06-01' existing = {
  name: WebSiteName
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: FunctionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  properties: {
    enabled: true
    serverFarmId: serverFarmId
    httpsOnly: true
    clientAffinityEnabled: true
    storageAccountRequired: false
    clientCertMode: 'Required'    
    virtualNetworkSubnetId: functionSubnetId
    keyVaultReferenceIdentity: 'SystemAssigned'
    hostNameSslStates: [
      {
        name: (environment().name == 'AzureUSGovernment') ? '${FunctionAppName}.azurewebsites.us' : '${FunctionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: (environment().name == 'AzureUSGovernment') ? '${FunctionAppName}.scm.azurewebsites.us' : '${FunctionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]  
  }
}

resource ftp_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: functionApp
  name: 'ftp'
  kind: 'functionApp'  
  location: location
  properties: {
    allow: true
  }
}

resource scm_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: functionApp
  name: 'scm'
  kind: 'functionApp'
  location: location
  properties: {
    allow: true
  }
}


param baseTime string = utcNow('u')
var add3Years = dateTimeAdd(baseTime, 'P3Y')
output add3years string = add3Years

// Specifying configuration for the SAS token; not all possible fields are included
//Examples of valid permissions settings for a container include rw, rd, rl, wd, wl, and rl.
var sasConfig = {
  //canonicalizedResource: '/blob/${mainStorageAccount.name}/mycontainer/some/path/test.py' // Specific blob in the container
  signedResourceTypes: 'sc'
  signedPermission: 'rw'
  signedServices: 'b'
  signedExpiry: add3Years
  signedProtocol: 'https'
  keyToSign: 'key1'
}

// Alternatively, we could use listServiceSas function
var sasToken = mainStorageAccount.listAccountSas(mainStorageAccount.apiVersion, sasConfig).accountSasToken
//output sasToken string = sasToken
// Connection string based on a SAS token
//output connectionStringSAS string = 'BlobEndpoint=${mainStorageAccount.properties.primaryEndpoints.blob};SharedAccessSignature=${sasToken}'
//output sasTokenOut string = mainStorageAccount.listServiceSas(mainStorageAccount.apiVersion, sasConfig).serviceSasToken
// Connection string based on a SAS token
var connectionStringSAS  = '${mainStorageAccount.properties.primaryEndpoints.blob}?${sasToken}'
//output connectionStringSAS string = connectionStringSAS

resource apiFunctionApp_WebConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: functionApp
  name: 'web'  
  properties: {         
    publishingUsername: '$functionAppName'
    scmType: 'None'
    webSocketsEnabled: false
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    vnetName: 'snet-functionintegration-${SolutionName}'
    vnetRouteAllEnabled: true
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://${webapp.properties.defaultHostName}'
        //(environment().name == 'AzureUSGovernment') ? 'https://${appName}.azurewebsites.us' : 'https://${appName}.azurewebsites.net'
        'https://${functionApp.properties.defaultHostName}'
        //(environment().name == 'AzureUSGovernment') ? 'https://${functionAppName}.azurewebsites.us' : 'https://${functionAppName}.azurewebsites.net'
        'http://localhost:3000'

      ]
      supportCredentials: true
    }
    netFrameworkVersion:  netFrameworkVersion
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    //ftpsState: 'Disabled'
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


resource apiFunctionApp_AppSettings_Transfer 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: (Solution == 'Transfer') ? {        
    //APPINSIGHTS_INSTRUMENTATIONKEY:(Environment != 'Prod') ? '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APPINSIGHTS_INSTRUMENTATIONKEY)' :''
    //APPLICATIONINSIGHTS_CONNECTION_STRING: (Environment != 'Prod') ?'@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APPLICATIONINSIGHTS_CONNECTION_STRING)':''
    armTemplateQueueName: 'deployarmtemplates' 
    authEndpoint: environment().authentication.loginEndpoint    
    AuditStorageAccessKey: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=AuditStorageAccessKey)' 
    AzStorageAccessKey: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=AzStorageAccessKey)' 
    AzureWebJobsSecretStorageType: 'blob'    
    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=AzureWebJobsStorage)' 
    blobEndpoint: 'https://${mainStorageAccount.name}.blob.${environment().suffixes.storage}'    
    clientID: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=clientID)'     
    clientSecret: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=clientSecret)' 
    completedContainerName: 'completedcontainers'    
    createCTSContainer:  'false' 
    ctsStorageSASUri:  connectionStringSAS 
    deleteAuditBlobContainerName:  'insights-logs-storagedelete' 
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    FUNCTIONS_EXTENSION_VERSION: '~4'    
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: ApiClientSecret 
    ftpState: 'Disabled'
    readAuditBlobContainerName:  'insights-logs-storageread' 
    roleDefinitionId:RoleDefinitionId
    sentinelTimer: '0 59 23 * * *' 
    SqlConnectionString: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=SqlConnectionString)' 
    storageAccountResourceID: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=storageAccountResourceID)'
    subscriptionID: subscriptionID
    tenantID: tenantId  
    transfersTableName: 'transfers'    
    transferValidationQueueName :  'status'
    validationTimeOut: '10' 
    WEBSITE_CONTENTOVERVNET:'1'    
    WEBSITE_RUN_FROM_PACKAGE: '1'
    WEBSITE_DNS_SERVER: '168.63.129.16'
    //WEBSITE_CONTENTSHARE: toLower(FunctionAppName) 
    //WEBSITE_CONTENTSHARE:contentShare    
    //WEBSITE_VNET_ROUTE_ALL : '1'    
    writeAuditBlobContainerName:  'insights-logs-storagewrite' 
    //XDT_MicrosoftApplicationInsights_Mode: 'Recommended'    
  } : {
    applyRBACTimerInterval:  '0 00 * * * *'
    //APPINSIGHTS_INSTRUMENTATIONKEY:(Environment != 'Prod') ? '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APPINSIGHTS_INSTRUMENTATIONKEY)' :''
    //APPLICATIONINSIGHTS_CONNECTION_STRING: (Environment != 'Prod') ?'@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=APPLICATIONINSIGHTS_CONNECTION_STRING)':''
    authEndpoint: environment().authentication.loginEndpoint            
    AzStorageAccessKey: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=AzStorageAccessKey)' 
    AzureWebJobsSecretStorageType: 'blob'    
    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=AzureWebJobsStorage)' 
    blobEndpoint: 'https://${mainStorageAccount.name}.blob.${environment().suffixes.storage}'    
    clientID: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=clientID)'     
    clientSecret: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=clientSecret)' 
    completedContainerName: 'completedcontainers'
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    FUNCTIONS_EXTENSION_VERSION: '~4'    
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: ApiClientSecret 
    ftpState: 'Disabled'    
    roleDefinitionId:RoleDefinitionId        
    storageAccountResourceID: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=storageAccountResourceID)'
    subscriptionID: subscriptionID
    tenantID: tenantId  
    transfersTableName: 'CompletedContainers'
    transferCompilationRequestsQueueName:  'compilationrequests'    
    WEBSITE_CONTENTOVERVNET:'1'    
    WEBSITE_RUN_FROM_PACKAGE: '1'
    WEBSITE_DNS_SERVER: '168.63.129.16'
    //WEBSITE_CONTENTSHARE: toLower(FunctionAppName) 
    //WEBSITE_CONTENTSHARE:contentShare    
    //WEBSITE_VNET_ROUTE_ALL : '1'        
    //XDT_MicrosoftApplicationInsights_Mode: 'Recommended'    
  }
}

resource apiFunctionApp_AuthSettingsv2 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'authsettingsV2'
  kind: 'functionapp'
  parent: functionApp
  properties: {
    globalValidation: {
      requireAuthentication: true
      //unauthenticatedClientAction: 'RedirectToLoginPage'
      unauthenticatedClientAction: 'Return401'
    }
    httpSettings: {
      forwardProxy: {
        convention: 'NoProxy'
      }
      requireHttps: true
      routes: {
        apiPrefix: '/.auth'
      }
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true        
        login: {
          disableWWWAuthenticate: false          
        }
        registration: {
          clientId: ApiClientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
          openIdIssuer: 'https://sts.windows.net/${tenantId}/v2.0'
        }
        validation: {
          allowedAudiences: [
              'api://${ApiClientId}'
          ]
          defaultAuthorizationPolicy: {
            allowedPrincipals: {}
          }
        }
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
  }
}
//*/

 


resource apiFunctionApp_HostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: functionApp  
  name: '${FunctionAppName}.azurewebsites.us'
  properties: {
    siteName: FunctionAppName
    hostNameType: 'Verified'
  }
}

resource apiFunctionApp_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = if(Environment == 'Prod') {  
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
//*/

resource apiFunctionApp_VirtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = if(Environment == 'Prod') {
  parent: functionApp
  name: '${FunctionAppName}-virtualNetworkConnection'  
  properties: {
    vnetResourceId: functionSubnetId
    isSwift: true
  }
}


var functionAppUrl = 'https://${functionApp.properties.defaultHostName}'
output functionAppHostName string = functionApp.properties.defaultHostName
output functionAppUrl string = functionAppUrl

//*/

//@description('The name of the virtual network subnet to be associated with the Azure Function app.')
//var functionSubnetName = '/subnets/snet-function-${SolutionName}'
//var functionSubnetName = 'snet-functionintegration-${SolutionName}'
//var functionSubnetName = 'snet-function-${SolutionName}'
//var functionSubnetName = '/subnets/snet-function-${SolutionName}'

//param connectionStringSAS string
//param ctsStorageName string
//param appServiceName string 
//@secure()
//@description('The administrator login password for the SQL server.')
//param sqlServerAdministratorPassword string
/*
var sqlServerName ='sql-${SolutionName}'
resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = if(Solution == 'Transfer'){
  name:sqlServerName
}
resource sqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = if(Solution == 'Transfer') {
  name: 'sqldb-${SolutionName}'
}
//*/

/*
resource apiAppInsights 'microsoft.insights/components@2020-02-02' existing= {
  name: 'appi-${SolutionName}'  
}
*/
/*
resource webapp_privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01' existing= {
  name: privateDNSZoneName
}
//*/

/*
resource ctsStorageAccount'Microsoft.Storage/storageAccounts@2021-09-01' existing= {
  name:ctsStorageName
}
//*/
/*

/*
//adds secret with the function app's host key.
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  //parent: keyvault
  name: '${keyVaultName}/${functionAppKeySecretName}'
  dependsOn:[keyVault]
  properties: {
    value: listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
  }
}
//*/			

/*
resource apiLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: 'log-${SolutionName}'  
}
//*/

//var contentShare  = split(SolutionName,'-')[0]
//output contentShare string = contentShare

/*
resource apiFunctionApp_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {  
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
//*/

/*
resource apiFunctionApp_VirtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
  parent: functionApp
  name: '${functionAppName}-virtualNetworkConnection'  
  properties: {
    vnetResourceId: functionSubnetId
    isSwift: true
  }
}
//*/
/*
resource privateDnsZone_api_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: webapp_privateDNSZone
  name: functionAppName
  properties: {
    ttl: 10
    aRecords: [
      {
        ipv4Address: webAppInboundIP
      }
    ]
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

//WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'DefaultEndpointsProtocol=https;AccountName=${mainStorageAccount.name};AccountKey=${listKeys(mainStorageAccount.id, mainStorageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}' 

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
/*
appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${storageAccount.name}-${appInternalServiceName}-ConnectionString)'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=${storageAccount.name}-${appInternalServiceName}-ConnectionString)'
        }
*/
