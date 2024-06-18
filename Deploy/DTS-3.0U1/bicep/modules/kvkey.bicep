@description('The name of the Key Vault where the key will be stored')
param keyvaultName string

@description('The name of the key to be created')
param keyName string

param tags object

resource kvKey 'Microsoft.KeyVault/vaults/keys@2022-11-01' = {
  name: '${keyvaultName}/${keyName}'
  tags: tags
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: [
      'encrypt' // rights need to be reviewed and set to least privellaged.
      'decrypt'
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
    ]
  }
}

// output
output keyId string = kvKey.id
output keyUriWithVersion string = kvKey.properties.keyUriWithVersion
