
targetScope = 'resourceGroup'

param location string = resourceGroup().location

param DeployObject object 
param SolutionObj object 
param tags object

//var SolutionName = DeployObject.SolutionName 

param webSiteName string
param webappSubnetId string

@description('Name must be privatelink.azurewebsites.us')
var webapp_dns_name  = '.azurewebsites.us' 

@description('Name must be privatelink.azurewebsites.us')
//var privateDNSZone_name  = 'privatelink.azurewebsites.us-${DeployObject.SolutionName}'
var webapp_privateDNSZoneName  =  'privatelink.azurewebsites.us'




//var Environment = split(DeployObject.SolutionName,'-')[2]
var alwaysOn = false
var functionRuntime = 'dotnet'
//var currentStack = 'dotnet'
var netFrameworkVersion = 'v4.0'

//var vNetName = 'vnet-${DeployObject.SolutionName}'
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
	name: DeployObject.VirtualNetworkName
}

resource apiAppInsights 'microsoft.insights/components@2020-02-02' existing =  {
	name: 'appi-${DeployObject.SolutionName}'  
}

var aspName = 'asp-${DeployObject.SolutionName}'
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
	name: aspName
}

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
	name: webSiteName
	tags: tags
	kind: 'app'
	location: location
	properties: {
	httpsOnly: true
	siteConfig: {
		netFrameworkVersion:  netFrameworkVersion
		alwaysOn: alwaysOn
	}
	hostNameSslStates: [
		{
		name: '${webSiteName}.azurewebsites.us'
		sslState: 'Disabled'
		hostType: 'Standard'
		}
		{
		name: '${webSiteName}.scm.azurewebsites.us'
		sslState: 'Disabled'
		hostType: 'Repository'
		}
	]
	serverFarmId: appServicePlan.id
	clientAffinityEnabled: true
	}
}

resource webapp_config 'Microsoft.Web/sites/config@2021-03-01' = {
	parent: webapp
	name: 'web'
	properties: {
	windowsFxVersion:'6.0'
	numberOfWorkers: 1
	defaultDocuments: [
		'Default.htm'
		'Default.html'
		'Default.asp'
		'index.htm'
		'index.html'
		'iisstart.htm'
		'default.aspx'
		'index.php'
		'hostingstart.html'
	]
	netFrameworkVersion: SolutionObj.netFrameworkVersion
	requestTracingEnabled: false
	remoteDebuggingEnabled: false
	httpLoggingEnabled: false
	acrUseManagedIdentityCreds: false
	logsDirectorySizeLimit: 35
	detailedErrorLoggingEnabled: false
	publishingUsername: '$dtpdev'
	scmType: 'None'
	use32BitWorkerProcess: true
	webSocketsEnabled: false
	alwaysOn: true
	managedPipelineMode: 'Integrated'
	virtualApplications: [
		{
		virtualPath: '/'
		physicalPath: 'site\\wwwroot'
		preloadEnabled: true
		}
	]
	loadBalancing: 'LeastRequests' 
	autoHealEnabled: false
	vnetRouteAllEnabled: false
	vnetPrivatePortsCount: 0
	publicNetworkAccess : 'Disabled'
	localMySqlEnabled: false
	ipSecurityRestrictions: [
		{
		ipAddress: 'Any'
		action: 'Allow'
		priority: 1
		name: 'Allow all'
		description: 'Allow all access'
		}
	]
	scmIpSecurityRestrictions: [
		{
		ipAddress: 'Any'
		action: 'Allow'
		priority: 1
		name: 'Allow all'
		description: 'Allow all access'
		}
	]
	scmIpSecurityRestrictionsUseMain: false
	http20Enabled: false
	minTlsVersion: '1.2'
	scmMinTlsVersion: '1.0'
	ftpsState: 'AllAllowed'
	preWarmedInstanceCount: 0
	functionAppScaleLimit: 0
	functionsRuntimeScaleMonitoringEnabled: false
	minimumElasticInstanceCount: 0 
	}
}

resource webapp_appSettings 'Microsoft.Web/sites/config@2021-03-01' = {
	parent: webapp
	name: 'appsettings'
	properties:  {
	APPINSIGHTS_INSTRUMENTATIONKEY: apiAppInsights.properties.InstrumentationKey
	APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
	APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
	APPLICATIONINSIGHTS_CONNECTION_STRING: apiAppInsights.properties.ConnectionString
	ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
	DiagnosticServices_EXTENSION_VERSION:'~3'
	FUNCTIONS_WORKER_RUNTIME: functionRuntime
	InstrumentationEngine_EXTENSION_VERSION: 'disabled'
	SnapshotDebugger_EXTENSION_VERSION: 'disabled'
	XDT_MicrosoftApplicationInsights_BaseExtensions: '~1'
	XDT_MicrosoftApplicationInsights_Java: '1'
	XDT_MicrosoftApplicationInsights_Mode:'Recommended'
	XDT_MicrosoftApplicationInsights_NodeJS: 'Disabled'
	XDT_MicrosoftApplicationInsights_PreemptSdk: 'Disabled' 
	}
}


resource webapp_hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
	parent: webapp
	name: '${webSiteName}${webapp_dns_name}'
	properties: {
	siteName: webSiteName
	hostNameType: 'Verified'
	}
}

var webappSubnetIdInMain  = '${virtualNetwork.id}/subnets/${webappSubnetName}'
output webappSubnetIdInMain string = webappSubnetIdInMain
var webappSubnetName = 'snet-webapp-${DeployObject.SolutionName}'
output webappSubnetNameOut string = webappSubnetName
var webappSubnetIdLocal  = '${virtualNetwork.id}/subnets/${webappSubnetName}'
output webappSubnetIdLocal string = webappSubnetIdLocal
output webappSubnetIdParam string = webappSubnetId
var webappPrivateEndpointName = 'pep-site-${DeployObject.SolutionName}'
output webapp_PrivateEndpointName string = SolutionObj.webapp_PrivateEndpointName

//@description('Link name between your Private Endpoint and your Web App')
var privateLinkConnectionName  = 'clientSite_privateEndpointConnections'


//var webappSubnetId  = '${virtualNetwork.id}/subnets/${SolutionObj.webappSubnetName}'

resource webapp_privateEndpoint 'Microsoft.Network/privateEndpoints@2020-03-01' =  {
	name: webappPrivateEndpointName
	location: location
	tags: tags
	properties: {
	subnet: {
		id: webappSubnetId
	}
	privateLinkServiceConnections: [
	 {
		name: privateLinkConnectionName
			properties: {
			privateLinkServiceId: webapp.id
			groupIds: [
			'sites'
			]
		}
		}
	]
	}
}



resource webapp_ftp_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
	parent: webapp
	name: 'ftp'
	location: location
	tags: tags
	properties: {
	allow: true
	}
}

resource webapp_scm_PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
	parent: webapp
	name: 'scm'
	location: location
	tags:tags
	properties: {
	allow: true
	}
}
//*/

/*
resource privateDnsZone_api_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
	parent: webapp_privateDNSZone
	name: 'depguideapi'
	properties: {
	metadata: {
		creator: 'created by private endpoint pep-dtp-api-dts-prod-lt-001 with resource guid b9ffa792-eb6e-4d37-91f8-74ede6a9a63c'
	}
	ttl: 10
	aRecords: [
		{
		ipv4Address: '10.10.0.68'
		}
	]
	}
}
//*/

resource webapp_privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
	name: webapp_privateDNSZoneName
	location: 'global'
	tags: tags
}



resource webapp_privateDNSZoneVirutalNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =  {
	parent: webapp_privateDNSZone
	name: '${webapp_privateDNSZoneName}-link'
	tags: tags
	location: 'global'
	properties: {
	registrationEnabled: false
	virtualNetwork: {
		id: virtualNetwork.id
	}
	}
}//webapp_privateDNSZoneVirtualNetworkLink

resource webapp_privateEndpoint_privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' =  {
	parent: webapp_privateEndpoint
	name: 'dnsgroupname'
	properties: {
	privateDnsZoneConfigs: [
		{
		name: 'config1'
		properties: {
			privateDnsZoneId: webapp_privateDNSZone.id
		}
		}
	]
	}
}//webapp_privateEndpoint_privateDnsZoneGroup

/*
resource privateDnsZone_webApp_scm 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
	parent: webapp_privateDNSZone
	name: 'depguide.scm'
	properties: { 
	ttl: 10
	aRecords: [
		{
		ipv4Address: webapp_privateEndpoint.properties.networkInterfaces.
		}
	]
	}
}
//*/
output appServiceNameOut string = webapp.name
output appServiceAppHostName string = webapp.properties.defaultHostName
output pdnsz_websiteId string = webapp_privateEndpoint_privateDnsZoneGroup.id

var webAppInboundIP = reference(webSiteName, '2020-06-01', 'Full').properties.inboundIpAddress
output webAppInboundIP string = webAppInboundIP


