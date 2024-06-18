@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location
param DeployObject object 
param SolutionObj object
param tags object


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

param cmkSqlKeyUriWithVersion string


var storageSubnetId  = '${virtualNetwork.id}/subnets/${SolutionObj.storageSubnetName}'


@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

@description('Enable/Disable Transparent Data Encryption')
@allowed([
	'Enabled'
	'Disabled'
])
param transparentDataEncryption string = 'Enabled'

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId


/*
	@allowed([
		'User'
		'Group'
		'Application'
	])
	param aad_admin_type string = 'User'
	param aad_only_auth bool = true
//*/

resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing= {
	name: DeployObject.ManagedUserName  
}//managedUser

resource cmk_SqlDatabaseKey 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' existing = {
	name: SolutionObj.cmkSqlKeyName
}//cmk_SqlDatabaseKey

//output cmk_SqlDatabaseKeyUri string = cmk_SqlDatabaseKey.properties.keyUri
//output cmkSqlDatabaseKeyId string = cmk_SqlDatabaseKey.id
//var keyVaultName = (length('kv-${DeployObject.SolutionName}') >23 ) ? substring('kv-${DeployObject.SolutionName}',0,24) : 'kv-${DeployObject.SolutionName}'
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
	name: DeployObject.KeyVaultName
}//keyVault
//output cmk_SqlkeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
//*/

output keyvault_url string = keyVault.properties.vaultUri

//var keyvaulturi = endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri

/**/
	resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' =  {
		name: DeployObject.SqlServerName
		tags: tags
		location: location
		identity: { 
		type: 'SystemAssigned,UserAssigned'
		userAssignedIdentities: {
			'${managedUser.id}': {}
		}
		}
		properties: {
		administratorLogin: DeployObject.SqlAdmin
		administratorLoginPassword: sqlServerAdministratorPassword
		minimalTlsVersion: '1.2'
			publicNetworkAccess: 'Enabled'
		version:'12.0'
		primaryUserAssignedIdentityId: managedUser.properties.principalId
		}
	}//sqlServer
//*/


resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
	parent: sqlServer
	tags: tags
	name: DeployObject.SqlServerName
	location: location
	sku: sqlDatabaseSku
}//sqlServerDatabase

param permissionsObj object = {
	name: 'permissions' 
	keys: [
		'get'
		'wrapKey'
		'unwrapKey'
		]
	secrets: []
	certificates: []
}//permissionsObj

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
}//addSqlIdentityAccessPolicy
//*/

var keyVersion = last(split(cmkSqlKeyUriWithVersion,'/'))
output sqlKeyVersion string = keyVersion

var sqlServerKeyName = '${SolutionObj.keyVaultName}_${SolutionObj.cmkSqlKeyName}_${keyVersion}'
output sqlServerKeyName string = sqlServerKeyName

resource sqlServerKey 'Microsoft.Sql/servers/keys@2020-02-02-preview' = {
	parent: sqlServer
	name: '${sqlServerKeyName}'
	properties: {
	serverKeyType: 'AzureKeyVault'
	uri: cmkSqlKeyUriWithVersion
	//uri: '${reference(resourceId(keyVaultResourceGroupName, 'Microsoft.KeyVault/vaults/', keyVaultName), '2018-02-14-preview', 'Full').properties.vaultUri}keys/${keyName}/${keyVersion}'
	}
	dependsOn: [addSqlIdentityAccessPolicy]
}//
//*/

/**/
	resource sqlServerEncryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2020-02-02-preview' = {
		parent: sqlServer
		name: 'current'
		//kind: 'azurekeyvault'
		properties: {
		serverKeyName: sqlServerKeyName
		serverKeyType: 'AzureKeyVault'
		}
		dependsOn: [
		sqlServerKey
		]
	}//sqlServerEncryptionProtector
//*/


var SqlConnectionString = 'Server=tcp:${sqlServer.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlServerDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${DeployObject.SqlAdminPwd};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;'
output SqlConnectionString string = SqlConnectionString
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlIdentityPrincipalId string = sqlServer.identity.principalId



resource secret_SqlConnectionString 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
	name: 'SqlConnectionString'
	parent: keyVault
	tags:tags
	properties: {
	value: SqlConnectionString
	attributes:{
	enabled:true
	}
	}
}//


resource sqlServerDatabase_TransparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-02-01-preview' = {
	parent: sqlServerDatabase
	name: 'Current'
	properties: {
	state: transparentDataEncryption
	}
}
//*/


// -- Private DNS Zones --
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' =  {
	name: SolutionObj.sqlPrivateDnsZoneName
	location: 'global'
	tags: tags
	resource sqldbDnsZoneLink 'virtualNetworkLinks' = {
	name: '${sqlPrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: virtualNetwork.id
		}
	}
	}
}//

// -- Private Endpoints --
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' ={
	name: SolutionObj.sqlPrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: storageSubnetId
	}
	privateLinkServiceConnections: [
		{
		name: 'sql_privateLinkServiceConnection'
		properties: {
			privateLinkServiceId: sqlServer.id
			groupIds: [
			'sqlServer'
			]
		}
		}
	]
	}//

	resource sqldbPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
	name: 'default'
 
	properties: {
		privateDnsZoneConfigs: [
		{
			name: 'config'
			properties: {
			privateDnsZoneId: sqlPrivateDnsZone.id
			}
		}
		]
	}
	}//
}//


@description('Allow Azure services to access server.')
param allowAzureIPs bool = true
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = if (allowAzureIPs) {
	parent: sqlServer
	name: 'AllowAllWindowsAzureIps'
	properties: {
	endIpAddress: '0.0.0.0'
	startIpAddress: '0.0.0.0'
	}
}
//*/

output sqlSystemPrincipalId string = sqlServer.identity.principalId
