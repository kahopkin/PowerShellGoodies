targetScope = 'resourceGroup'

param location string

param DeployObject object 
param SolutionObj object 
param tags object

param aspName string



param appServicePlanSku object


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

