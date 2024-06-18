param principalObjId string

@description('Key vault name where the key to use is stored')
param keyVaultName string

param permissionsObj object

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
	name: '${keyVaultName}/add'
	properties: {
	accessPolicies: [
		{
		tenantId: subscription().tenantId
			objectId: principalObjId
		permissions: {
			keys:  permissionsObj.keys
			secrets: permissionsObj.secrets
			certificates:permissionsObj.certificates
		}
		}
	]
	}
}

output keyVaultName string = keyVaultName
//output principalObjId string = principalObj.identity.principalId
output principalObjId string = principalObjId
