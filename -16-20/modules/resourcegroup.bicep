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

/*
//hardcoded because that is a built in role
//https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
@description('Specifies the role definition ID used in the role assignment.')
param roleDefinitionID string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Specifies the principal ID assigned to the role.')
param principalId string

var roleAssignmentName= guid(principalId, roleDefinitionID, resourceGroup().id)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
  }
}

*/
output resourceGroupId string = resourceGroup.id
