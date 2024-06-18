targetScope = 'resourceGroup'

param location string

param DeployObject object 
param SolutionObj object
param tags object


resource applicationInsights 'Microsoft.insights/components@2020-02-02' = {
	name: SolutionObj.appInsightsName
	location: location
	kind: 'web'
	tags: tags
	properties: {
	Application_Type: 'web'
	RetentionInDays: 90
	IngestionMode: 'ApplicationInsights'
	publicNetworkAccessForIngestion: 'Enabled'
	publicNetworkAccessForQuery: 'Enabled'
	}
}

/**/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
	name: SolutionObj.logAnalyticsWorkspaceName
	location: DeployObject.DefaultWorkspaceLocation
	tags:tags
}
//*/

output appInsightsConnString string = applicationInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey
output workspaceResourceId string = logAnalyticsWorkspace.id

