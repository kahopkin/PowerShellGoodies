
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param SolutionName string
param tags object
param planId string
param websiteName string
param vnetId string
param webappSubnetId string

@description('Name must be privatelink.azurewebsites.us')
var webapp_dns_name  = '.azurewebsites.us'

@description('Name must be privatelink.azurewebsites.us')
//var privateDNSZone_name  = 'privatelink.azurewebsites.us-${SolutionName}'
var privateDNSZone_name  = 'privatelink.azurewebsites.us'

//@description('Link name between your Private Endpoint and your Web App')
var privateLinkConnection_name  = 'clientSite_privateEndpointConnections'

var webappPrivateEndpointName = 'pep-site-${SolutionName}'

var alwaysOn = false
var functionRuntime = 'dotnet'
var currentStack = 'dotnet'
var netFrameworkVersion = 'v4.0'

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: websiteName
  tags: tags
  kind: 'app'
  location: location
  properties: {  
    httpsOnly: true         
    siteConfig: {
      appSettings: [        
        {
          name: 'DiagnosticServices_EXTENSION_VERSION'
          value: 'disabled'
        }        
      ]
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: currentStack
        }
      ]
      netFrameworkVersion:  netFrameworkVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: planId
    clientAffinityEnabled: true
  }
}

resource webapp_config 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: webapp
  name: 'web'
  properties: {
    windowsFxVersion:'6.0'
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v6.0'    
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$dtpdev'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'   
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
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
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.0'
    ftpsState: 'AllAllowed'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0    
  }
}

resource appSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: webapp
  name: 'appsettings'
  properties: {
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    
  }
}

resource webapp_hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: webapp
  name: '${websiteName}${webapp_dns_name}'
  properties: {
    siteName: websiteName
    hostNameType: 'Verified'
  }
}

resource webapp_privateEndpoint 'Microsoft.Network/privateEndpoints@2020-03-01' = {
  name: webappPrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: webappSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnection_name
        properties: {
          privateLinkServiceId: webapp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource webapp_privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZone_name
  location: 'global'
  tags: tags
}

resource webapp_privateDNSZoneVirutalNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: webapp_privateDNSZone
  name: '${privateDNSZone_name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource webapp_privateEndpoint_privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: webapp_privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: webapp_privateDNSZone.id
        }
      }
    ]
  }
}

output appServiceNameOut string = webapp.name
output appServiceAppHostName string = webapp.properties.defaultHostName
output pdnsz_websiteId string = webapp_privateEndpoint_privateDnsZoneGroup.id

/*
param webAppLogAnalyticsWorkspaceName string
param webAppInsightsName string

resource webAppLogAnalyticsWorkspace 'microsoft.operationalinsights/workspaces@2021-06-01' = {
  name: webAppLogAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource webAppInsights 'microsoft.insights/components@2020-02-02' = {
  name: webAppInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}
*/
/*
resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
  parent: appServiceApp
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
  dependsOn: [
    webAppInsights
  ]
}

resource appSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: appServiceApp
  name: 'appsettings'
  properties: {
    //APPINSIGHTS_INSTRUMENTATIONKEY: webAppInsights.properties.InstrumentationKey
    //APPLICATIONINSIGHTS_CONNECTION_STRING: webAppInsights.properties.ConnectionString
    XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
  }
}


*/
