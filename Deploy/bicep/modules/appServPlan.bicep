targetScope = 'resourceGroup'

param location string

param DeployObject object 
param SolutionObj object 
param tags object

param appServicePlanSku object

resource applicationInsights 'Microsoft.insights/components@2020-02-02' existing = {
	name: SolutionObj.appInsightsName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
	name: DeployObject.KeyVaultName
}
//*/

resource secret_APPLICATIONINSIGHTS_CONNECTION_STRING 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
	name: 'APPLICATIONINSIGHTS-CONNECTION-STRING'
	parent: keyVault
	tags:tags
	properties: {
	value: applicationInsights.properties.ConnectionString
	attributes:{
		enabled:true
	}
	}
}

resource secret_APPINSIGHTS_INSTRUMENTATIONKEY 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' =  {
	name: 'APPINSIGHTS-INSTRUMENTATIONKEY'
	parent: keyVault
	tags:tags
	properties: {
	value: applicationInsights.properties.InstrumentationKey
	attributes:{
		enabled:true
	}
	}
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
	name: SolutionObj.aspName
	location: location
	tags: tags
	sku: {
	name: appServicePlanSku.Name
	capacity: appServicePlanSku.capacity
	/*
	tier: appServicePlanSku.tier
	size: appServicePlanSku.size
	family: appServicePlanSku.family

	*/
	}
	kind: 'app'
}

output appServiceResourceId string = appServicePlan.id

