$json = @'
[
{
	"squadName": "Super hero squad Alpha",
	"homeTown": "Metro City",
	"formed": 2016,
	"secretBase": "Large tent in the forest",
	"active": "True",
	"members": [{
		"name": "Molecule Man",
		"age": 29,
		"secretIdentity": "Dan Jukes",
		"powers": ["Radiation resistance",
		"Turning tiny",
		"Radiation blast"]
	},
	{
		"name": "Madame Uppercut",
		"age": 39,
		"secretIdentity": "Jane Wilson",
		"powers": ["Million tonne punch",
		"Damage resistance",
		"Superhuman reflexes"]
	},
	{
		"name": "Eternal Flame",
		"age": 1000000,
		"secretIdentity": "Unknown",
		"powers": ["Immortality",
		"Heat Immunity",
		"Inferno",
		"Teleportation",
		"Interdimensional travel"]
	}]
},
{
	"squadName": "Second squad Baker",
	"homeTown": "Metro Toronto",
	"formed": 2017,
	"secretBase": "CN tower",
	"active": "True",
	"members": [{
		"name": "Kathleen Wynne",
		"age": 49,
		"secretIdentity": "Cyan Arrah",
		"powers": ["XRay vision",
		"Invisibility",
		"Radiation blast"]
	},
	{
		"name": "Madame Butterfly",
		"age": 27,
		"secretIdentity": "Iman Angel",
		"powers": ["Magical hearing",
		"Fantastic ideas"]
	},
	{
		"name": "Gassy Misty Cloud",
		"age": 1000,
		"secretIdentity": "Puff of Smoke",
		"powers": ["Immortality",
		"Heat and Flame Immunity",
		"Impeccable hearing",
		"Xray Vision",
		"Able to jump tall buildings",
		"Teleportation",
		"Intergalactic travel"]
	}]
}]
'@

$objectOut =  $json | ConvertFrom-Json
$objectOut[0].squadName
$objectOut[0].members[0].name

$newJson = ConvertTo-Json $objectOut
$objectOut =  $json | ConvertFrom-Json
$squads = $objectOut | ConvertFrom-Json


$APIResponse = Invoke-RestMethod -Uri $Uri -Headers $Headers

$EnvironmentObj = [ordered]@{}
$AzureContext = Get-AzContext
$EnvironmentObj = $AzureContext.Environment
$EnvironmentJSON = ConvertTo-Json $EnvironmentObj

ForEach ($d in $EnvironmentObj) 
{

<#    "Project Code = " + $d.code + ", Project Description = " + $d.description
    ForEach ($e in $d.customFieldValues) {
        "CustomField Key " + $e.key + ", Name " + $e.name  + ", Value " + $e.value
    }
    #>
}

ForEach ($d in $json.Values) 
{
Write-Host $d
}


================================================================================
$json = @'

$DeployInfo = @'
[{
    "CloudEnvironment":  "AzureUSGovernment",
    "Environment":  "prod",
    "Location":  "usgovvirginia",
    "Solution":  "All",
    "AppName":  "transferdata",
    "SqlAdmin":  "dtpadmin",
    "SqlAdminPwd":  {
                        "Length":  12
                    },
    "SqlAdminPwdPlainText":  "1qaz2wsx#EDC",
    "BicepFile":  "C:\\GitHub\\dtp\\Deploy\\main.bicep",
    "DeploymentName":  "Deployment_12-06-2022",
    "FileExists":  false,
    "SubscriptionName":  "BMA-05",
    "SubscriptionId":  "2b2df691-421a-476f-bfb6-7b7e008d6041",
    "TenantName":  "BMTN Development",
    "TenantId":  "f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0",
    "CurrUserName":  "Kat Hopkins (CA)",
    "CurrUserId":  "1f1f0e38-6e1c-4875-b7ea-80a526039896",
    "CurrUserPrincipalName":  "kahopkins.ca@bmtndev.onmicrosoft.us",
    "MyIP":  "MyIP",
    "StepCount":  1,
    "TemplateParameterFile":  "\\main.parameters.prod.json",
    "ContributorRoleId":  "b24988ac-6180-42a0-ab88-20f7382dd24c",
    "TransferAppObj":  {
                           "AppName":  "transferdata",
                           "Environment":  "prod",
                           "Location":  "usgovvirginia",
                           "Solution":  "Transfer",
                           "ResourceGroupName":  "rg-transferdata-prod",
                           "RoleDefinitionId":  "RoleDefinitionId",
                           "RoleDefinitionFile":  "C:\\GitHub\\dtp\\Deploy\\DTPStorageBlobDataReadWrite.json",
                           "BicepFile":  "C:\\GitHub\\dtp\\Deploy\\transfer-main.bicep",
                           "APIAppRegName":  "transferdataAPI",
                           "APIAppRegAppId":  "APIAppRegAppId",
                           "APIAppRegObjectId":  "APIAppRegObjectId",
                           "APIAppRegClientSecret":  "APIAppRegClientSecret",
                           "APIAppRegServicePrincipalId":  "APIAppRegServicePrincipalId",
                           "APIAppRegExists":  false,
                           "ClientAppRegName":  "transferdata",
                           "ClientAppRegAppId":  "ClientAppRegAppId",
                           "ClientAppRegObjectId":  "ClientAppRegObjectId",
                           "ClientAppRegServicePrincipalId":  "ClientAppRegServicePrincipalId",
                           "ClientAppRegExists":  false
                       },
    "PickupAppObj":  {
                         "AppName":  "transferdata",
                         "Environment":  "prod",
                         "Location":  "usgovvirginia",
                         "Solution":  "Pickup",
                         "ResourceGroupName":  "rg-transferdata-prod",
                         "RoleDefinitionId":  "RoleDefinitionId",
                         "RoleDefinitionFile":  "C:\\GitHub\\dtp\\Deploy\\DPPStorageBlobDataRead.json",
                         "BicepFile":  "C:\\GitHub\\dtp\\Deploy\\pickup-main.bicep",
                         "APIAppRegName":  "transferdataAPI",
                         "APIAppRegAppId":  "APIAppRegAppId",
                         "APIAppRegObjectId":  "APIAppRegObjectId",
                         "APIAppRegClientSecret":  "APIAppRegClientSecret",
                         "APIAppRegServicePrincipalId":  "APIAppRegServicePrincipalId",
                         "APIAppRegExists":  false,
                         "ClientAppRegName":  "transferdata",
                         "ClientAppRegAppId":  "ClientAppRegAppId",
                         "ClientAppRegObjectId":  "ClientAppRegObjectId",
                         "ClientAppRegServicePrincipalId":  "ClientAppRegServicePrincipalId",
                         "ClientAppRegExists":  false
                     },
    "Cloud":  {
                  "Name":  "AzureUSGovernment",
                  "Type":  "Built-in",
                  "EnableAdfsAuthentication":  false,
                  "OnPremise":  false,
                  "ActiveDirectoryServiceEndpointResourceId":  "https://management.core.usgovcloudapi.net/",
                  "AdTenant":  "Common",
                  "GalleryUrl":  "https://gallery.azure.com/",
                  "ManagementPortalUrl":  "https://portal.azure.us/",
                  "ServiceManagementUrl":  "https://management.core.usgovcloudapi.net/",
                  "PublishSettingsFileUrl":  "https://manage.windowsazure.us/publishsettings/index",
                  "ResourceManagerUrl":  "https://management.usgovcloudapi.net/",
                  "SqlDatabaseDnsSuffix":  ".database.usgovcloudapi.net",
                  "StorageEndpointSuffix":  "core.usgovcloudapi.net",
                  "ActiveDirectoryAuthority":  "https://login.microsoftonline.us/",
                  "GraphUrl":  "https://graph.windows.net/",
                  "GraphEndpointResourceId":  "https://graph.windows.net/",
                  "TrafficManagerDnsSuffix":  "usgovtrafficmanager.net",
                  "AzureKeyVaultDnsSuffix":  "vault.usgovcloudapi.net",
                  "DataLakeEndpointResourceId":  null,
                  "AzureDataLakeStoreFileSystemEndpointSuffix":  null,
                  "AzureDataLakeAnalyticsCatalogAndJobEndpointSuffix":  null,
                  "AzureKeyVaultServiceEndpointResourceId":  "https://vault.usgovcloudapi.net",
                  "ContainerRegistryEndpointSuffix":  "azurecr.us",
                  "AzureOperationalInsightsEndpointResourceId":  "https://api.loganalytics.us",
                  "AzureOperationalInsightsEndpoint":  "https://api.loganalytics.us/v1",
                  "AzureAnalysisServicesEndpointSuffix":  "asazure.usgovcloudapi.net",
                  "AnalysisServicesEndpointResourceId":  "https://region.asazure.usgovcloudapi.net",
                  "AzureAttestationServiceEndpointSuffix":  null,
                  "AzureAttestationServiceEndpointResourceId":  null,
                  "AzureSynapseAnalyticsEndpointSuffix":  "dev.azuresynapse.usgovcloudapi.net",
                  "AzureSynapseAnalyticsEndpointResourceId":  "https://dev.azuresynapse.usgovcloudapi.net",
                  "VersionProfiles":  [

                                      ],
                  "ExtendedProperties":  {
                                             "OperationalInsightsEndpoint":  "https://api.loganalytics.us/v1",
                                             "OperationalInsightsEndpointResourceId":  "https://api.loganalytics.us",
                                             "AzureAnalysisServicesEndpointSuffix":  "asazure.usgovcloudapi.net",
                                             "AnalysisServicesEndpointResourceId":  "https://region.asazure.usgovcloudapi.net",
                                             "AzureSynapseAnalyticsEndpointSuffix":  "dev.azuresynapse.usgovcloudapi.net",
                                             "AzureSynapseAnalyticsEndpointResourceId":  "https://dev.azuresynapse.usgovcloudapi.net",
                                             "ManagedHsmServiceEndpointResourceId":  "https://managedhsm.usgovcloudapi.net",
                                             "ManagedHsmServiceEndpointSuffix":  "managedhsm.usgovcloudapi.net",
                                             "MicrosoftGraphEndpointResourceId":  "https://graph.microsoft.us/",
                                             "MicrosoftGraphUrl":  "https://graph.microsoft.us"
                                         },
                  "BatchEndpointResourceId":  "https://batch.core.usgovcloudapi.net/"
              }
}]
'@


$json =  ConvertFrom-Json $DeployInfo

$object =  ConvertFrom-Json $DeployInfo





$i=0
foreach ($item in $DeployInfo.GetEnumerator())     
{         
    Write-Host -ForegroundColor White -BackgroundColor Black "[$i]" $item.name "=" $item.value
    #$item.name +"=" + $item.value >> $FilePath
    $i++       
}