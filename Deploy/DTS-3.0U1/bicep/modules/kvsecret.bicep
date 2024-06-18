@description('The name of the Key Vault where the secret will be saved.')
param keyvaultName string

@description('The name of the secret in Key Vault.')
param secretName string

@description('The value of the secret that will be saved in Key Vault.')
@secure()
param secretValue string

resource kv_secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}

output secretUri string = kv_secret.properties.secretUri
