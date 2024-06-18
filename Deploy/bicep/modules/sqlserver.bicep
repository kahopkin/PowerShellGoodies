
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object 
param tags object

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

//param cmkSqlKeyUriWithVersion string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

@description('Enable/Disable Transparent Data Encryption')
@allowed([
	'Enabled'
	'Disabled'
])
param transparentDataEncryption string = 'Enabled'
output transparentDataEncryption string = transparentDataEncryption
//*/


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

var storageSubnetId  = '${virtualNetwork.id}/subnets/${SolutionObj.storageSubnetName}'
output storageSubnetIdOut string = storageSubnetId

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
	name: DeployObject.ManagedUserName  
}
//*/


resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
	name: DeployObject.KeyVaultName
}
//*/

var keyvaulturi = endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri
output keyvaulturi string = keyvaulturi



resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' =  {
	name: SolutionObj.sqlServerName
	tags: tags
	location: location
	identity: { 
	type: 'SystemAssigned,UserAssigned'
	userAssignedIdentities: {
		'${managedUser.id}': {}
	} 
	}
	properties: {
	administratorLogin: sqlServerAdministratorLogin
	administratorLoginPassword: sqlServerAdministratorPassword
	minimalTlsVersion: '1.2' 
	publicNetworkAccess: 'Enabled'
	version:'12.0'
	primaryUserAssignedIdentityId: managedUser.properties.principalId 
	}  
}


resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
	parent: sqlServer
	tags: tags
	name: SolutionObj.sqlDatabaseName
	location: location
	sku: sqlDatabaseSku  
}
//*/




param permissionsObj object = {
	name: 'permissions' 
	keys: [
		'get'
		'wrapKey'
		'unwrapKey'
		]
	secrets: []
	certificates: []
}

module addSqlIdentityAccessPolicy 'nested_addObjectAccessPolicy.bicep' = {
	name: 'addAccessPolicy'
	scope: resourceGroup(resourceGroup().name)
	params: {
	//principalObj: reference(sqlServer.id, '2019-06-01-preview', 'Full')
	principalObj: sqlServer
	keyVaultName: keyVault.name
	objType: 'sqlserver'
	permissionsObj: permissionsObj 
	} 
	//dependsOn:[sqlServer]
}
//*/


var SqlConnectionString = 'Server=tcp:${sqlServer.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlServerDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${sqlServerAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;'
output SqlConnectionString string = SqlConnectionString
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlSystemPrincipalId string = sqlServer.identity.principalId