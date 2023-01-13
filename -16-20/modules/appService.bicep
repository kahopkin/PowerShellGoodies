
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param SolutionObj object
//var AppName = SolutionObj.AppName
//var Solution = SolutionObj.Solution
var SolutionName = SolutionObj.SolutionName 
var Environment = SolutionObj.Environment

param tags object
param planId string
param webSiteName string
param vnetId string
param webappSubnetId string

@description('Name must be privatelink.azurewebsites.us')
var webapp_dns_name  = (environment().name == 'AzureUSGovernment') ? '.azurewebsites.us' : '.azurewebsites.net'

@description('Name must be privatelink.azurewebsites.us')
//var privateDNSZone_name  = 'privatelink.azurewebsites.us-${SolutionName}'
var privateDNSZoneName  = (environment().name == 'AzureUSGovernment') ? 'privatelink.azurewebsites.us' : ''

//@description('Link name between your Private Endpoint and your Web App')
var privateLinkConnectionName  = 'clientSite_privateEndpointConnections'

var webappPrivateEndpointName = 'pep-site-${SolutionName}'

//var Environment = split(SolutionName,'-')[2]
var alwaysOn = false
var functionRuntime = 'dotnet'
//var currentStack = 'dotnet'
var netFrameworkVersion = 'v4.0'


/*resource apiAppInsights 'microsoft.insights/components@2020-02-02' existing =  if(Environment != 'Prod'){
  name: 'appi-${SolutionName}'  
}
//*/


resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  tags: tags
  kind: 'app'
  location: location
  properties: {  
    httpsOnly: true         
    siteConfig: {     
      netFrameworkVersion:  netFrameworkVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: planId
    clientAffinityEnabled: true
  }
}

/*
resource webappMetadata 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'metadata'
  kind: 'string'
  parent: webapp
  properties: {    
    name: 'CURRENT_STACK'
    value: currentStack    
  }
}
//*/

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
  properties: (Environment != 'Prod') ? {    
    //APPINSIGHTS_INSTRUMENTATIONKEY: (Environment != 'Prod') ? apiAppInsights.properties.InstrumentationKey : ''
    //APPLICATIONINSIGHTS_CONNECTION_STRING: (Environment != 'Prod') ? apiAppInsights.properties.ConnectionString: ''
    //ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    //DiagnosticServices_EXTENSION_VERSION:'disabled'
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    XDT_MicrosoftApplicationInsights_Mode:'Recommended'
    
  }:{   
    FUNCTIONS_WORKER_RUNTIME: functionRuntime
    }  
}

resource webapp_hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: webapp
  name: '${webSiteName}${webapp_dns_name}'
  properties: {
    siteName: webSiteName
    hostNameType: 'Verified'
  }
}


resource webapp_privateEndpoint 'Microsoft.Network/privateEndpoints@2020-03-01' = if(Environment == 'Prod') {
  name: webappPrivateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: webappSubnetId
    }
    privateLinkServiceConnections: [
     {
        name: privateLinkConnectionName        
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
  name: privateDNSZoneName
  location: 'global'
  tags: tags
}

/*
resource ftp_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: webapp
  name: 'ftp'
  location: location
  tags: tags
  properties: {
    allow: true
  }
}

resource scm_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: webapp
  name: 'scm'
  location: location
  tags:tags
  properties: {
    allow: true
  }
}
//*/

/*
resource privateDnsZone_api_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: webapp_privateDNSZone
  name: 'depguideapi'
  properties: {
    metadata: {
      creator: 'created by private endpoint pep-dtp-api-dts-prod-lt-001 with resource guid b9ffa792-eb6e-4d37-91f8-74ede6a9a63c'
    }
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.10.0.68'
      }
    ]
  }
}
//*/

resource webapp_privateDNSZoneVirutalNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =  if(Environment == 'Prod'){
  parent: webapp_privateDNSZone
  name: '${privateDNSZoneName}-link'
  tags: tags
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource webapp_privateEndpoint_privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' =  if(Environment == 'Prod'){
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
/*
resource privateDnsZone_webApp_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: webapp_privateDNSZone
  name: 'depguide.scm'
  properties: {   
    ttl: 10
    aRecords: [
      {
        ipv4Address: webapp_privateEndpoint.properties.networkInterfaces.
      }
    ]
  }
}
//*/
output appServiceNameOut string = webapp.name
output appServiceAppHostName string = webapp.properties.defaultHostName
output pdnsz_websiteId string = webapp_privateEndpoint_privateDnsZoneGroup.id
var webAppInboundIP = reference(webSiteName, '2020-06-01', 'Full').properties.inboundIpAddress
output webAppInboundIP string = webAppInboundIP



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
//*/

//var webAppInboundIP  = reference(webSiteName), '2020-06-01', 'Full').properties.inboundIpAddress
//output test string = webAppInboundIP.
