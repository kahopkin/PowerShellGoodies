param functionAppName string
param storageAccountName string
param appServicePlanName string
param privateEndpointName string
param virtualNetworkName string 
param functionSubnetName string 
param functionIntegrationSubnetName string
param location string = resourceGroup().location
param tags object
param suffix string
param settings array
param tags object


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: virtualNetworkName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
  }
  properties: {
    reserved: false
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    storageAccountRequired: false
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2021-04-01').keys[0].value};EndpointSuffix=${suffix}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2021-04-01').keys[0].value};EndpointSuffix=${suffix}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
      ]
    }
  }
}

resource functionApp_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' =  {
    name: privateEndpointName
    location: location
    tags: tags
    properties: {
        subnet: {
            id: '${virtualNetwork.id}/subnets/snet-function-${functionSubnetName}'
        }
        privateLinkServiceConnections: [
        {
            name: privateEndpointName
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

resource functionApp_VirtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
		parent: functionApp
		name: '${functionAppName}-virtualNetworkConnection'
		properties: {
		vnetResourceId: '${virtualNetwork.id}${functionIntegrationSubnetName}'
		isSwift: true
		}
	}