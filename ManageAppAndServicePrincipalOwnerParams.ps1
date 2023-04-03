
& "$PSScriptRoot\GetAzureADToken.ps1"    
& "$PSScriptRoot\GetAzureContext.ps1"
#ManageAppAndServicePrincipalOwnerParams

$CloudEnvironment="AzureUSGovernment"

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

$CurrUserName="Jane Doe (Test User)"
$CurrUserFirst="Jane"
$CurrUserPrincipalName="janedoe@bmtndev.onmicrosoft.us"
$CurrUserId="71841acf-4751-4add-8649-0c50c6b75f10"

$MyIP="141.156.182.114"

$CryptoEncryptRoleId="e147488a-f6f5-4113-8e2d-b22465e65bf6"
$ContributorRoleId="b24988ac-6180-42a0-ab88-20f7382dd24c"


$APIAppRegName="DtsTransferAPI"
$APIAppRegAppId="ed4f4b20-2742-4b90-9675-3ab01fd4e785"
$APIAppRegObjectId="94bcb02c-d634-4467-9066-d94ec3f4e2ef"
$APIAppRegSecret="dk3T5Pk0a56V-M.P4ccP0N37.p5O~T8.qV"
$APIAppRegServicePrincipalId="e9c305cd-af9b-4eb5-80e1-638969773838"

$AppName = $APIAppRegName
$website = $APIAppRegName + ".azurewebsites.us"

Write-Host -ForegroundColor Magenta "`n ManageAppAndServicePrincipalOwnerParams[39]:: "
Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
Write-Host -ForegroundColor Green "`$AppName=`"$AppName`""    
Write-Host -ForegroundColor Cyan "`$website=`"$website`""
Write-Host -ForegroundColor DarkYellow "`$TenantId=`"$TenantId`""
Write-Host -ForegroundColor Yellow "`$CurrUserPrincipalName=`"$CurrUserPrincipalName`""



#.\ManageAppAndServicePrincipalOwner.ps1 -Add "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56"
#$AccessToken = GetAzureADToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret
#$AccessToken = GetMsGraphToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret

# Add bob@contoso.com as owner to both app and service principal
.\ManageAppAndServicePrincipalOwner.ps1 `
    -TenantId $TenantId `
    -Add $CurrUserPrincipalName `
    -Application `
    -AppId $APIAppRegAppId `
    -UserObjectId $CurrUserId
 

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