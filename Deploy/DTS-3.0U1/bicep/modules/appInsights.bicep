@description('The name of the Application Insights resource')
param appInsightsName string

@description('Location for the Application Insights resource')
param location string

@description('The Application Type for the Application Insights resource. Default is "web".')
param applicationType string = 'web'

param tags object

resource appInsights 'Microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: applicationType
  tags: tags
  properties: {
    Application_Type: applicationType
    RetentionInDays: 90
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
