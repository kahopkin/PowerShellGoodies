targetScope = 'resourceGroup'

param location string = resourceGroup().location
param SolutionName string 
param tags object
param keyVaultProps object
param keyVaultName string
param keyvaultSubnetId string
param StorageAccountsArr array
param CurrUserId string
//param CryptoEncryptRoleId string
param Solution string
param MyIP string
//var SolutionNameSt = replace(SolutionName, '-', '')
var Environment = split(SolutionName,'-')[2]
var cmkMainStKeyName ='cmk-${StorageAccountsArr[0]}-${SolutionName}'
output cmkMainStKeyName string = cmkMainStKeyName
var cmkAuditKeyName = 'cmk-${StorageAccountsArr[1]}-${SolutionName}'
var cmkSqlDatabaseKeyName = 'cmk-sqldb-${SolutionName}'

@description('Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
//@secure()
param entities  array 

param managedUserName string 
//param vnetId string

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId

var webapp_dns_name  = '.usgovcloudapi.net'
var privateKeyVaultDnsZoneName = 'privatelink.vaultcore${webapp_dns_name}'
var privateKeyVaultEndpointName = 'pep-kv-${SolutionName}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name:'vnet-${SolutionName}'
}

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedUserName
  location: location
  tags: tags
}


resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enabledForDeployment: keyVaultProps.enabledForDeployment
    enabledForTemplateDeployment: keyVaultProps.enabledForTemplateDeployment
    enabledForDiskEncryption: keyVaultProps.enabledForDiskEncryption
    enableSoftDelete: keyVaultProps.enableSoftDelete
    softDeleteRetentionInDays: keyVaultProps.softDeleteRetentionInDays
    enableRbacAuthorization:keyVaultProps.enableRbacAuthorization
    enablePurgeProtection:keyVaultProps.enablePurgeProtection
    vaultUri: 'https://${keyVaultName}.vault.usgovcloudapi.net/'
    tenantId: tenantId 
    accessPolicies: [
      {
        objectId: managedUser.properties.principalId
        tenantId: tenantId
        permissions: {
          keys: [
            'unwrapKey'
            'wrapKey'
            'get'
          ]
        }        
      }
      {
        objectId: CurrUserId
        tenantId: tenantId
        permissions: {
          keys: keyVaultProps.keysPermissions
          secrets:keyVaultProps.secrets
          certificates:keyVaultProps.certificates
        }
      }  
      /*{
        objectId: keyVaultProps.objectId
        tenantId: tenantId
        permissions: {
          keys: keyVaultProps.keysPermissions
          secrets:keyVaultProps.secrets
          certificates:keyVaultProps.certificates
        }
      } */     
    ]
    sku: {
      name: keyVaultProps.skuName
      family: keyVaultProps.family
    }
    networkAcls: {
      defaultAction: (Environment == 'Prod') ? 'Deny' : 'Allow'
      bypass: 'AzureServices'      
      ipRules: (Environment == 'Prod') ? [
        {
          value: MyIP          
        }//*/
      ] : [{
        value: MyIP          
      }]
      virtualNetworkRules: [
        {
          id: keyvaultSubnetId
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
  } 
}

//resource cmk_MainStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = if(environment().name == 'AzureUSGovernment'){
  resource cmk_MainStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
  parent: keyVault
  name: cmkMainStKeyName
  //tags: tags
  properties: {
    attributes: {
      enabled: true      
    }
    keySize: 2048
    kty:'RSA'
  }
}

resource cmk_AuditStorage 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' ={//} if(Solution == 'Transfer') {
  parent: keyVault
  name: cmkAuditKeyName
 // tags: tags
  properties: {
    attributes: {
      enabled: true      
    }
    keySize: 2048
    kty:'RSA'
  }
}

resource cmk_SqlDatabaseKey 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = if(Solution == 'Transfer'){
  parent: keyVault
  name: cmkSqlDatabaseKeyName  
  properties: {
    attributes: {
      enabled: true      
    }
    keySize: 2048
    kty:'RSA'
  }
}
//output cmk_SqlkeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion

//Create secrets with the API appId, secret, SQL admin login info
resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret  in entities: {
  name: secret.secretName
  parent: keyVault
  tags:tags
  properties: {
    value: secret.secretValue
    attributes:{
    enabled:secret.enabled
    }
  }
}]


// -- Private DNS Zones --
resource keyvaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(Environment == 'Prod'){
  name: privateKeyVaultDnsZoneName
  location: 'global'
  tags: tags
  resource keyvaultDnsZoneLink 'virtualNetworkLinks' = {
    name: '${keyvaultDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}
//*/

// -- Private Endpoints --

resource keyvaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if(Environment == 'Prod'){
  name: privateKeyVaultEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: keyvaultSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}-PrivateLinkConnection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }

  resource keyvaultPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = if(Environment == 'Prod') {
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


/*output CryptoEncryptRoleIdIn string = CryptoEncryptRoleId
output roleDefinitionIdToSet string = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', CryptoEncryptRoleId)

resource encryptionUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: CryptoEncryptRoleId
  scope: keyVault
  properties: {          
    description: 'Read metadata of keys and perform wrap/unwrap operations. Only works for key vaults that use the "Azure role-based access control" permission model.'
    principalId: managedUser.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', CryptoEncryptRoleId)
  }
}
//*/


output usrIdName string = managedUser.id
output keyVaultId string = keyVault.id
