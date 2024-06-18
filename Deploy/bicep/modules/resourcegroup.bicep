targetScope = 'subscription'


param location string 
param tags object
param SolutionObj object

//var ResourceGroupName = SolutionObj.resourceGroupName
//Create the resourcegroup
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
	name: SolutionObj.ResourceGroupName
	tags: tags
	location: location
}

output resourceGroupResourceId string = resourceGroup.id
