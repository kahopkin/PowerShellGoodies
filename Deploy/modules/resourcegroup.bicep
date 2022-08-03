targetScope = 'subscription'

param ResourceGroupName  string
param location string 
param tags object

//Create the resourcegroup
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: ResourceGroupName
  tags: tags
  location: location
}

output resourceGroupId string = resourceGroup.id
