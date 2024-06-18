@description('The name of the User Assigned Managed Identity')
param identityName string

@description('Location for the User Assigned Managed Identity')
param location string

param tags object

resource userAssignedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
  tags: tags
}

output identityId string = userAssignedId.id
output identityPrincipalId string = userAssignedId.properties.principalId
output identityClientId string = userAssignedId.properties.clientId

