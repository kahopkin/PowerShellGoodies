targetScope = 'resourceGroup'

param location string
param aspName string

param SolutionObj object
//var AppName = SolutionObj.AppName
//var Solution = SolutionObj.Solution
var Environment = SolutionObj.Environment
var SolutionName = SolutionObj.SolutionName 

param appServicePlanSku object
param tags object
@description('Workspace resources are only available in usgovvirginia,usgovarizona')
param workspaceLocation string

var apiLogAnalyticsWorkspaceName ='log-${SolutionName}'
var apiInsightsName = 'appi-${SolutionName}'
var keyVaultName = 'kv-${SolutionName}'

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
  name: keyVaultName
}
//*/

/*resource apiAppInsights 'microsoft.insights/components@2020-02-02' = if(Environment != 'Prod') {
  name: apiInsightsName
  location: workspaceLocation
  kind: 'web'
  properties: {
   Application_Type: 'web'
    RetentionInDays: 90
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

var ConnectionString = (Environment != 'Prod') ? apiAppInsights.properties.ConnectionString : ''
var InstrumentationKey = (Environment != 'Prod') ? apiAppInsights.properties.InstrumentationKey : ''
resource secret_APPLICATIONINSIGHTS_CONNECTION_STRING 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if(Environment != 'Prod'){
  name: 'APPLICATIONINSIGHTS-CONNECTION-STRING'
  parent: keyVault
  tags:tags
  properties: {
    value: apiAppInsights.properties.ConnectionString
    attributes:{
      enabled:true
    }
  }
}

resource secret_APPINSIGHTS_INSTRUMENTATIONKEY 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if(Environment != 'Prod') {
  name: 'APPINSIGHTS-INSTRUMENTATIONKEY'
  parent: keyVault
  tags:tags
  properties: {
    value: apiAppInsights.properties.InstrumentationKey
    attributes:{
      enabled:true
    }
  }
}

output ConnectionString string = ConnectionString
output InstrumentationKey string = InstrumentationKey


//*/

resource apiLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: apiLogAnalyticsWorkspaceName
  location: workspaceLocation
}



//*/

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: aspName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku.Name
    tier: appServicePlanSku.tier
    size: appServicePlanSku.size
    family: appServicePlanSku.family
    capacity: appServicePlanSku.capacity
  }
  kind: 'app'
}


output planId string = appServicePlan.id
