@description('Key vault name where the key to use is stored')
param keyVaultName string

param objectId string

param keyPermission array

param secretPermission array

param certPermission array

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-11-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId   
        permissions: {
          keys:  keyPermission
          secrets: secretPermission
          certificates: certPermission
        }
      }
    ]
  }
}
