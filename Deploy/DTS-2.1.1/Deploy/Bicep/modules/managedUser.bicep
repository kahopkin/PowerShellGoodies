targetScope = 'resourceGroup'

param DeployObject object 
param SolutionObj object
param tags object

param location string = resourceGroup().location

param keyVaultProps object


/*
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
	name: DeployObject.KeyVaultName
}
//*/

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
	name: DeployObject.ManagedUserName 
	location: location
	tags: tags
}

/*
param permissionsObj object = {
	name: 'permissions' 
	keys: keyVaultProps.keys
	secrets: keyVaultProps.secrets
	certificates: keyVaultProps.certificates
}

output myPermissionObj object = permissionsObj

module addManagedUserAccessPolicy 'nested_addAccessPolicy.bicep' = {
	name: 'addManagedUserKeyVaultAccess'
	scope: resourceGroup(resourceGroup().name)
	params: {
	principalObjId: managedUser.properties.principalId
	keyVaultName: DeployObject.KeyVaultName
	permissionsObj: permissionsObj
	}   
}
//*/


output ManagedUserName string = managedUser.name
output ManagedUserResourceId string = managedUser.id
output ManagedUserPrincipalId string = managedUser.properties.principalId
