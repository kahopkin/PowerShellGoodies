targetScope = 'resourceGroup'

param location string
param planName string

param appServicePlanSku object
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: planName
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
