targetScope = 'resourceGroup'

param location string = resourceGroup().location
param SolutionName string 
param tags object
param keyVaultProps object
param keyVaultName string
param keyvaultSubnetId string

param idName string 
param vnetId string

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId

var privateKeyVaultDnsZoneName = 'privatelink.keyvault.${SolutionName}'
var privateKeyVaultEndpointName = 'pep-kv-${SolutionName}'

resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: idName
  location: location
  tags: tags
}


resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enabledForDeployment: keyVaultProps.enabledForDeployment
    enabledForTemplateDeployment: keyVaultProps.enabledForTemplateDeployment
    enabledForDiskEncryption: keyVaultProps.enabledForDiskEncryption
    vaultUri: 'https://${keyVaultName}.vault.usgovcloudapi.net/'
    tenantId: tenantId 
    accessPolicies: [
      {
        objectId: keyVaultProps.objectId
        tenantId: tenantId
        permissions: {
          keys: keyVaultProps.keysPermissions
          secrets:keyVaultProps.secrets
          certificates:keyVaultProps.certificates
        }
      }
    ]
    sku: {
      name: keyVaultProps.skuName
      family: keyVaultProps.family
    }
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'      
      virtualNetworkRules: [
        {
          id: keyvaultSubnetId
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
  } 
}


// -- Private DNS Zones --

resource keyvaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateKeyVaultDnsZoneName
  location: 'global'
  tags: tags
  resource keyvaultDnsZoneLink 'virtualNetworkLinks' = {
    name: '${keyvaultDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}
//*/

// -- Private Endpoints --

resource keyvaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateKeyVaultEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: keyvaultSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyKeyvaultPrivateLinkConnection'
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }

  resource keyvaultPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'keyvaultPrivateDnsZoneGroup'        
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'          
          properties: {
            privateDnsZoneId: keyvaultDnsZone.id
          }
        }
      ]
    }
  }
}
//*/
output usrIdName string = managedId.id
output keyVaultId string = keyvault.id

/*
resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret in secretsObject.secrets: {
  name: secret.secretName
  parent: keyvault
  properties: {
    value: secret.secretValue
  }
}]

*/
