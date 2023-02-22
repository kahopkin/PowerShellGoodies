#ManageAppAndServicePrincipalOwnerParams
$DeploymentName="DeploymentName"
$DeployMode="DeployMode"
$CloudEnvironment="AzureUSGovernment"
$Location="Location"
$Environment="Environment"
$AppName="AppName"
$Solution="All"
$BicepFile="c:\github\dtp\Deploy\main.bicep"
$TemplateParameterFile="c:\github\dtp\Deploy\TemplateParameterFile"
$OutFileJSON="OutFileJSON"
$LogFile="LogFile"
$SubscriptionName="BMA-05: Dev"
$SubscriptionId="2b2df691-421a-476f-bfb6-7b7e008d6041"
$TenantName="BMTN Development"
$TenantId="f4d5d7b9-c690-4cb5-aa35-3ccf8f7b25f0"
$ActiveDirectoryAuthority="https://login.microsoftonline.us/"
$AzureKeyVaultDnsSuffix="vault.usgovcloudapi.net"
$GraphUrl="https://graph.windows.net/"
$ManagementPortalUrl="https://portal.azure.us/"
$ServiceManagementUrl="https://management.core.usgovcloudapi.net/"
$StorageEndpointSuffix="core.usgovcloudapi.net"
$CurrUserName="Kat Hopkins (CA)"
$CurrUserFirst="Kat"
$CurrUserId="1f1f0e38-6e1c-4875-b7ea-80a526039896"
$CurrUserPrincipalName="kahopkins.ca@bmtndev.onmicrosoft.us"
$MyIP="141.156.182.114"
$StepCount="1"
$CryptoEncryptRoleId="e147488a-f6f5-4113-8e2d-b22465e65bf6"
$ContributorRoleId="b24988ac-6180-42a0-ab88-20f7382dd24c"
$StartTime="02/22/2023 13:09:50"
$EndTime="EndTime"
$Duration="Duration"
$TransferAppObj="System.Collections.Specialized.OrderedDictionary"
$PickupAppObj="System.Collections.Specialized.OrderedDictionary"

$DeploymentName="Dts_Pickup_Prod_Kat"
$AppName="DtsPickupProd"
$Environment="Prod"
$Location="usgovvirginia"
$Solution="Pickup"
$ResourceGroupName="rg-dts-pickup-prod"
$RoleDefinitionId="RoleDefinitionId"
$RoleDefinitionFile="c:\github\dtp\Deploy\DPPStorageBlobDataRead.json"
$APIAppRegName="DtsPickupProdAPI"
$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
$APIAppRegObjectId="d71aa82b-df1e-4b76-8d36-38cbe82259fe"
$APIAppRegSecret=".Xr.Tuf8Zl.LC2WsAv2vz6zAIi3Wm_FgG2"
$APIAppRegServicePrincipalId="f477df7c-04ee-4236-848e-241fc3cbd6d1"
$APIAppRegExists="True"
$ClientAppRegName="DtsPickupProd"
$ClientAppRegAppId="207a5236-095f-48d3-b96a-c3b6a5a1da75"
$ClientAppRegObjectId="d04207b0-7721-4d4e-90bc-f690db3775a9"
$ClientAppRegSecret=".-KU~jvW42.5pyxA5t3tK2OljcW_2DpRTo"
$ClientAppRegServicePrincipalId="896ababe-74f5-4c73-90d2-ae679f526e1d"
$ClientAppRegExists="True"
$BuildFlag="1"
$PublishFlag="1"
$StartTime="02/22/2023 13:09:53"
$EndTime="EndTime"
$Duration="Duration"

$AppName = $APIAppRegName
$website = $APIAppRegName + ".azurewebsites.us"


Write-Host -ForegroundColor Magenta "`n ManageAppAndServicePrincipalOwner[266]:: "
Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
Write-Host -ForegroundColor Green "`$AppName=`"$AppName`""    
Write-Host -ForegroundColor Cyan "`$website=`"$website`""
Write-Host -ForegroundColor DarkYellow "`$TenantId=`"$TenantId`""
Write-Host -ForegroundColor Yellow "`$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
    
#.\ManageAppAndServicePrincipalOwner.ps1 -Add "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56"
$AccessToken = GetAzureADToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret

# Add bob@contoso.com as owner to both app and service principal
.\ManageAppAndServicePrincipalOwner.ps1 `
    -TenantId $TenantId `
    -Add $CurrUserPrincipalName `
    -Application `
    -AppId $APIAppRegAppId `
    -UserObjectId $CurrUserId `
    -AccessToken $AccessToken

<#
# List owners for the app in the contoso.com tenant
.\ManageAppAndServicePrincipalOwner.ps1 `
    -List -Application `
    -AppId $AppId`
    -TenantId $TenantId | ft userPrincipalName

# List owners for the app's service principal in the contoso.com tenant
.\ManageAppAndServicePrincipalOwner.ps1 `
    -List -ServicePrincipal `
    -AppId $AppId `
    -TenantId $TenantId | ft userPrincipalName

# Remove bob@contoso.com as an owner for the app, and output the acces token to $at for subsequent reuse
.\ManageAppAndServicePrincipalOwner.ps1 `
    -Remove "bob@contoso.com" `
    -Application `
    -AppId $AppId `
    -AccessTokenOut ([ref] $at)

    #>