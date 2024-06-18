@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location
param DeployObject object 
param SolutionObj object
param tags object


param sqlServerName string
param sqlDatabaseName string
param vnetId string
param storageSubnetId string


//var AppName = DeployObject.AppName
//var Solution = DeployObject.Solution
//var Environment = DeployObject.Environment
var SolutionName = DeployObject.SolutionName 
//var WebSiteName = SolutionObj.WebSiteName
//var FunctionAppName = SolutionObj.FunctionAppName
var MyIP = SolutionObj.MyIP

//param SqlkeyUriWithVersion string

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

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

var sqlPrivateDnsZoneName  = 'privatelink.database.usgovcloudapi.net'
var sqldbPrivateEndpointName = 'pep-sqldb-${DeployObject.SolutionName}'
//var cmkSqlDatabaseKeyName = 'cmk-sqldb-${DeployObject.SolutionName}'


/*
@allowed([
	'User'
	'Group'
	'Application'
])
param aad_admin_type string = 'User'
param aad_only_auth bool = true

//*/
var managedUserName = 'id-${DeployObject.SolutionName}'
resource managedUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing= {
	name: managedUserName  
}

resource cmk_SqlDatabaseKey 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' existing = {
	name: SolutionObj.cmkSqlKeyName
}

//output cmk_SqlDatabaseKeyUri string = cmk_SqlDatabaseKey.properties.keyUri
//output cmkSqlDatabaseKeyId string = cmk_SqlDatabaseKey.id
//var keyVaultName = (length('kv-${DeployObject.SolutionName}') >23 ) ? substring('kv-${DeployObject.SolutionName}',0,24) : 'kv-${DeployObject.SolutionName}'
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing= {
	name: DeployObject.KeyVaultName
}
//output cmk_SqlkeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
//*/

output keyvault_url string = keyVault.properties.vaultUri

//var keyvaulturi = endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' =  {
	name: sqlServerName
	tags: tags
	location: location
	identity: {
	type: 'SystemAssigned'
	} 
	properties: {
	administratorLogin: sqlServerAdministratorLogin
	administratorLoginPassword: sqlServerAdministratorPassword
	minimalTlsVersion: '1.2'

	publicNetworkAccess: 'Enabled'
	}
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
	parent: sqlServer
	tags: tags
	name: sqlDatabaseName
	location: location
	sku: sqlDatabaseSku
}

/*resource sqlServer_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
	parent: sqlServer
	name: 'AllowAllWindowsAzureIps'
}
//*/

var SqlConnectionString = 'Server=tcp:${sqlServer.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlServerDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${sqlServerAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;'
output SqlConnectionString string = SqlConnectionString
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlIdentityPrincipalId string = sqlServer.identity.principalId

/*
resource sqlServer_databases_transparentDataEncryption_master_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-02-01-preview' = {
	name: '${sqlServerName}/master/Current'
	properties: {
	state: 'Disabled'
	}
	dependsOn: [
	sqlServer
	]
}
//*/


output sqlSystemAssignedIdentityprincipalId string = sqlServer.identity.principalId

resource sqlServer_MyIP_firewallRule 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
	parent: sqlServer
	name: 'MyIP'
	properties: {
	endIpAddress: MyIP
	startIpAddress: MyIP
	}
}

resource sqlServer_KeyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
	name: 'add'
	parent: keyVault
	properties: {
	accessPolicies: [
		{
			objectId: sqlServer.identity.principalId
		permissions: {
			keys: [
			'Get'
			'UnwrapKey'
			'WrapKey'
			]
			secrets: []
			certificates: []
		}
		tenantId: tenantId
		}
	]
	}
}

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
}

/*resource sqlServer_databases_transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-02-01-preview' = {
	parent: sqlServerDatabase
	name: 'Current'
	properties: {
	state: transparentDataEncryption
	}  
}
//*/

//output cmkSqlKeykeyUriWithVersion string = cmk_SqlDatabaseKey.properties.keyUriWithVersion
/*resource sqlServerEncryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2022-02-01-preview' = {
	parent: sqlServer
	name: 'current'
	properties: {
	serverKeyName: cmk_SqlDatabaseKey.properties.keyUriWithVersion
	serverKeyType: 'AzureKeyVault'
	autoRotationEnabled: false
	}
}
//*/

// -- Private DNS Zones --
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' =  {
	name: sqlPrivateDnsZoneName
	location: 'global'
	tags: tags
	resource sqldbDnsZoneLink 'virtualNetworkLinks' = {
	name: '${sqlPrivateDnsZone.name}-link'
	location: 'global'
	properties: {
		registrationEnabled: false
		virtualNetwork: {
		id: vnetId
		}
	}
	}
}

// -- Private Endpoints --
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
	name: sqldbPrivateEndpointName
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
	}

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
	}
}






/*
resource sqlServer_current_encryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2022-02-01-preview' = {
	parent: sqlServer
	name: 'current'
	kind: 'servicemanaged'
	properties: {
	serverKeyName: 'ServiceManaged'
	serverKeyType: 'ServiceManaged'
	autoRotationEnabled: false
	}
}


//*/
/*
resource sqlServerEncryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2022-02-01-preview' = {
	parent: sqlServer
	name: 'current'
	kind: 'azurekeyvault'
	properties: {
	serverKeyName: cmk_SqlDatabaseKey.name
	serverKeyType: 'AzureKeyVault'
	autoRotationEnabled: false
	}
}
//*/

/*
resource sqlServerKey 'Microsoft.Sql/servers/keys@2022-02-01-preview' = {
	parent: sqlServer
	name: cmk_SqlDatabaseKey.name
	location: location
	kind: 'azurekeyvault'
	properties: {
	serverKeyType: 'AzureKeyVault'
	//uri: 'https://kv-dtp-stage-lt.vault.usgovcloudapi.net/keys/cmk-sql-dtp-stage-lt/86a0b4c4c70749d789f8c9000ca03c3f'
	uri: cmk_SqlDatabaseKey.properties.keyUri
	}
}

resource sqlServers_ServiceManagedKey 'Microsoft.Sql/servers/keys@2022-02-01-preview' = {
	parent: sqlServer
	name: 'ServiceManaged'
	kind: 'servicemanaged'
	properties: {
	serverKeyType: 'ServiceManaged'
	}
}
//*/

	
/*resource sqlServerDatabase_transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-02-01-preview' = {
	parent: sqlServerDatabase
	name: 'Current'
	properties: {
	state: 'Enabled'
	}
}
//*/





//var cmkSqlDatabaseKeyName = 'kv-tue-transfer-prod_cmk-sqldb-tue-transfer-prod_d2ec1edec9ca41c3bb6da0f48844026a'
/*resource sqlServer_encryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2022-02-01-preview' = {
	parent: sqlServer
	name: 'current'
	kind: 'azurekeyvault'
	properties: {
	serverKeyName: SolutionObj.cmkSqlKeyName
	serverKeyType: 'AzureKeyVault'
	autoRotationEnabled: false
	}
}
//*/ 

/*
resource sqlServerName_transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2017-03-01-preview' = {
	parent: sqlServerDatabase
	name: 'current'
	properties: {
	status: transparentDataEncryption
	}
}


//*/
