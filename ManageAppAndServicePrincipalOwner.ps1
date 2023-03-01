#ManageAppAndServicePrincipalOwner
# Adds, lists or removes owners of Azure AD Application and ServicePrincipal objects

<#

https://gist.github.com/psignoret/6ed32528f1c01b5345d5560697ac9c83

Examples:

    # Add bob@contoso.com as owner to both app and service principal
    .\ManageAppAndServicePrincipalOwner.ps1 -Add "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56"

    # List owners for the app in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 -List -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -TenantId "contoso.com" | ft userPrincipalName

    # List owners for the app's service principal in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 -List -ServicePrincipal -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -TenantId "contoso.com" | ft userPrincipalName

    # Remove bob@contoso.com as an owner for the app, and output the acces token to $at for subsequent reuse
    .\ManageAppAndServicePrincipalOwner.ps1 -Remove "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -AccessTokenOut ([ref] $at)

   

    # Add bob@contoso.com as owner to both app and service principal
    .\ManageAppAndServicePrincipalOwner.ps1 `
        -Add "bob@contoso.com" `
        -Application `
        -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56"

    # List owners for the app in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 `
        -List -Application `
        -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" `
        -TenantId "contoso.com" | ft userPrincipalName

    # List owners for the app's service principal in the contoso.com tenant
    .\ManageAppAndServicePrincipalOwner.ps1 `
        -List -ServicePrincipal `
        -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" `
        -TenantId "contoso.com" | ft userPrincipalName

    # Remove bob@contoso.com as an owner for the app, and output the acces token to $at for subsequent reuse
    .\ManageAppAndServicePrincipalOwner.ps1 -Remove "bob@contoso.com" -Application -AppId "e1d83a3c-fea5-4315-9591-8d9f185d2d56" -AccessTokenOut ([ref] $at)
#>


<#
[CmdletBinding()]
param(
    
    # Apply action to Application
    [switch] $Application,

    # Apply action to ServicePrincipal
    [switch] $ServicePrincipal,

    # ObjectId or UPN of owner to add
    $Add = $null,
    
    $UserObjectId = $null,

    # ObjectId or UPN of owner to remove
    $Remove = $null,

    # List current owners, will happen after add/remove
    [switch] $List,

    # Tenant ID or domain name identifying the directory
    $TenantId = $null,

    # AppId identifying the application
    [Parameter(Mandatory = $true)]
    $AppId,

    # A valid access token
    $AccessToken = $null,

    # A reference to where a retrieved access token will be placed
    [ref] $AccessTokenOut,

    # Path to 'Microsoft.IdentityModel.Clients.ActiveDirectory.dll.
    $PathToAdal = $null,

    # If set, will always prompt during auth
    [switch] $Prompt
)
#>
#& "$PSScriptRoot\GetAzureADToken.ps1"
& "$PSScriptRoot\GetAzureContext.ps1"
<#
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
#>
$CurrUserName="Jane Doe (Test User)"
$CurrUserFirst="Jane"
$CurrUserPrincipalName="janedoe@bmtndev.onmicrosoft.us"
$CurrUserId="71841acf-4751-4add-8649-0c50c6b75f10"



$AppName="DtsPickupProd"

$APIAppRegName="DtsPickupProdAPI"
$APIAppRegAppId="0f803265-28e7-472f-8fb9-86e0c7d40581"
$APIAppRegObjectId="d71aa82b-df1e-4b76-8d36-38cbe82259fe"
$APIAppRegSecret=".Xr.Tuf8Zl.LC2WsAv2vz6zAIi3Wm_FgG2"
$APIAppRegServicePrincipalId="f477df7c-04ee-4236-848e-241fc3cbd6d1"

$ClientAppRegName="DtsPickupProd"
$ClientAppRegAppId="207a5236-095f-48d3-b96a-c3b6a5a1da75"
$ClientAppRegObjectId="d04207b0-7721-4d4e-90bc-f690db3775a9"
$ClientAppRegSecret=".-KU~jvW42.5pyxA5t3tK2OljcW_2DpRTo"
$ClientAppRegServicePrincipalId="896ababe-74f5-4c73-90d2-ae679f526e1d"

$AppName = $APIAppRegName
$website = $APIAppRegName + ".azurewebsites.us"


Write-Host -ForegroundColor Magenta "`n ManageAppAndServicePrincipalOwner[130]:: "
Write-Host -ForegroundColor Yellow "`$AppId=`"$AppId`""
Write-Host -ForegroundColor Green "`$AppName=`"$AppName`""    
Write-Host -ForegroundColor Cyan "`$website=`"$website`""
Write-Host -ForegroundColor DarkYellow "`$TenantId=`"$TenantId`""
Write-Host -ForegroundColor Yellow "`$CurrUserPrincipalName=`"$CurrUserPrincipalName`""

Function GetMsGraphToken
{
    param(
        [String] $TenantId
        ,[String] $ClientId
        ,[String] $ClientSecret
        ,[String] $Scope
        # ,$AzureContext
    )
    Write-Host -ForegroundColor Magenta "[146]`n GetMsGraphToken"
    $AzureContext = Get-AzContext  
    $Scope = $AzureContext.Environment.GraphUrl + ".default"
    Write-Host -ForegroundColor Yellow "[149]`n `$Scope =`"$Scope`""

    $oauth2tokenendpointv2 = $AzureContext.Environment.ActiveDirectoryAuthority +   $AzureContext.Tenant.Id + "/oauth2/v2.0/token"
    Write-Host -ForegroundColor Cyan "[151]`n `$oauth2tokenendpointv2 =`"$oauth2tokenendpointv2`""
    
    $scope = [System.Web.HttpUtility]::UrlEncode($Scope)
    Write-Host -ForegroundColor Green "[155]`n `$Scope =`"$Scope`""
    
    $encSecret = [System.Web.HttpUtility]::UrlEncode($ClientSecret)
    Write-Host -ForegroundColor White "[158]`n `$encSecret =`"$encSecret`""
    
    $body = "grant_type=client_credentials&scope=$($Scope)&client_id=$($ClientId)&client_secret=$($encSecret)"
    Write-Host -ForegroundColor Yellow "[161]`n `$body =`"$body`""
    
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv2 -Body $body -Method Post
    #Write-Host -ForegroundColor Cyan "[91]`n `$res =`"$res`""
    
    $authResult = $res.Content | ConvertFrom-Json
    #Write-Host -ForegroundColor Green "[95]`n `$authResult =`"$authResult`""
    
    $accessToken = $authResult.access_token
    
    #return $authResult.access_token
    return $accessToken
}


# Resolves a user ID (UPN or ObjectId) to an ObjectId
function ResolveUserObjectId ($UserId, $TenantId, $Headers) 
{
    
    Write-Host -ForegroundColor Yellow "[170]`n `$ActiveDirectoryAuthority =`"$ActiveDirectoryAuthority`""
    
    Write-Host -ForegroundColor Yellow "[178]`n `$UserId=`"$UserId`""
    Write-Host -ForegroundColor Yellow "[179]`n `$TenantId=`"$TenantId`""
    Write-Host -ForegroundColor Yellow "[180]`n `$Headers=`"$Headers`""
    # Get the User object of the additional owner
    $User = $null
    $Uri = $GraphUrl + $TenantId + "/users/$UserId`?api-version=1.6"  
    Write-Host -ForegroundColor Cyan "[184]`n `$Uri=`"$Uri`""
    try {
        $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri $Uri
        $User = ($Result.Content | ConvertFrom-Json)
        $UserId = $User.objectId
        Write-Host -ForegroundColor Yellow "[184]`n `$UserId=`"$UserId`""
        return $UserId
    } catch {
        throw "Could not find user '$UserId'"
    }
}#ResolveUserObjectId


# Default is to apply to both Application and ServicePrincipal
if (-not $Application -and -not $ServicePrincipal) {
    $Application = $true
    $ServicePrincipal = $true
}

Connect-MgGraph -Environment USGov -Scopes "Directory.AccessAsUser.All, Application.ReadWrite.All,Directory.Read.All, User.Read" -ErrorAction Stop

# If no TenantId given, use one from the Add or Remove UPNs, if a UPN is used
Write-Host -ForegroundColor Magenta "[211]`n `$Application=`"$Application`""
Write-Host -ForegroundColor Magenta "[212]`n `$ServicePrincipal=`"$ServicePrincipal`""

Write-Host -ForegroundColor Cyan "[214]`n `$TenantId=`"$TenantId`""
if ($TenantId -eq $null) 
{
    if ($Add -ne $null -and $Add.Contains("@")) 
    {
        $TenantId = $Add.Split("@")[1]
    } 
    elseif ($Remove -ne $null -and $Remove.Contains("@")) 
    {
        $TenantId = $Remove.Split("@")[1]
    } 
    else 
    {
        throw "TenantId required, or use a UPN in Add or Remove"
    }
    Write-Warning "Using '$TenantId' as TenantId"
}#if ($TenantId -eq $null) 

#$AccessToken = GetAzureADToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret
$AccessToken = GetMsGraphToken -TenantId $TenantId -ClientId $APIAppRegAppId -ClientSecret $APIAppRegSecret
Write-Host -ForegroundColor Green "[203]`n `GOT AccessToken"
#Write-Host -ForegroundColor Yellow "[204]`n `$AccessToken=`"$AccessToken`""

if ($AccessToken -eq $null) 
{

    # Load ADAL. If the path to ADAL is not defined, use script's directory
    if ($PathToAdal -eq $null) 
    {
        $PathToAdal = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    $PathToAdal = (Join-Path $PathToAdal "Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
    Write-Host -ForegroundColor Cyan "[125]`n `$PathToAdal=`"$PathToAdal`""
    
    if (-not (Test-Path -Path $PathToAdal -PathType Leaf)) 
    {
        throw "ADAL library not found at '$PathToAdal'"
    }
    Add-Type -Path $PathToAdal

    # Get an access token to Graph API using the 'Azure AD PowerShell' client ID
    $AzureContext = Get-AzContext    
    #$oauth2tokenendpointv1 = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id +"/oauth2/token"    
    #Write-Host -ForegroundColor Yellow "`$oauth2tokenendpointv1 =`"$oauth2tokenendpointv1`""

    $AuthenticationContext = $AzureContext.Environment.ActiveDirectoryAuthority + $AzureContext.Tenant.Id
    Write-Host -ForegroundColor Yellow "[146]`n `$AuthenticationContext =`"$AuthenticationContext`""
    $AuthContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext $AuthenticationContext
    
    $PromptBehavior = if ($Prompt) { "Always" } else { "Auto" }
    try {
        $AuthResult = $AuthContext.AcquireToken(
                        $GraphUrl,              
                        $APIAppRegAppId,   <# Client ID #>
                        [Uri]::new('urn:ietf:wg:oauth:2.0:oob'),  <# Redirect URI #>
                        $PromptBehavior                           <# Prompt, 'Auto' or 'Always' #>
                      )
        $AccessToken = $AuthResult.AccessToken
        if ($AccessTokenOut -ne $null) {
            $AccessTokenOut.Value = $AccessToken
        }
    } catch {
        throw $_
    }
}# ($AccessToken -eq $null) 

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/json"
}
#Write-Host -ForegroundColor Green "[163]`n `$Headers.Authorization=`"" $Headers.Authorization


# Get the Application object by AppId
$App = $null
Write-Host -ForegroundColor Magenta "[289]`n `$Application=`"$Application`""

$uri = $GraphUrl + $TenantId + "/applications?`$filter=appId eq '$AppId'&api-version=1.6"
Write-Host -ForegroundColor Green "[198]`n `$Uri=`"$Uri`""

if ($Application) 
{
    $Result = Invoke-WebRequest -Headers $Headers -Method Get -Uri $uri
    $App = ($Result.Content | ConvertFrom-Json).value[0]
    
    if ($App -eq $null) {
        Write-Warning "Application object not found for AppId '$AppId'"
    }
}#if ($Application) 

# Get the ServicePrincipal object by AppId
$SP = $null
Write-Host -ForegroundColor Magenta "[206]`n `$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
if ($ServicePrincipal) 
{
    $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/servicePrincipals?`$filter=appId eq '$AppId'&api-version=1.6"
    $SP = ($Result.Content | ConvertFrom-Json).value[0]
    if ($SP -eq $null) {
        Write-Warning "ServicePrincipal object not found for AppId '$AppId'"
    }
}#if ($ServicePrincipal) 

Write-Host -ForegroundColor Magenta "[217]`n `$Add=`"$Add`""
if ($Add -ne $null) 
{
    #function ResolveUserObjectId ($UserId, $TenantId, $Headers) 
    $UserObjectId = ResolveUserObjectId $Add $TenantId $Headers
    Write-Host -ForegroundColor Cyan "[222]`n `$UserObjectId=`"$UserObjectId`""

    # The link to the additional owner, in JSON
    $AdditionalOwnerLink = @{
        "url" = "https://graph.windows.net/$TenantId/users/$UserObjectId"
    } | ConvertTo-Json

    # Add new owner to Application
    if ($App -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Post `
                    -Uri "https://graph.windows.net/$TenantId/applications/$($App.objectId)/`$links/owners?api-version=1.6" `
                    -Body $AdditionalOwnerLink
        if ($Result.StatusCode -eq 204) {    
            Write-Host "New owner '$Add' added to Application"
        }
    }

    # Add new owner to ServicePrincipal
    if ($SP -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Post `
                    -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/`$links/owners?api-version=1.6" `
                    -Body $AdditionalOwnerLink
        if ($Result.StatusCode -eq 204) {    
            Write-Host "New owner '$Add' added to ServicePrincipal"
        }
    }
}#if ($Add -ne $null) 

Write-Host -ForegroundColor Magenta "[250]`n `$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
if ($Remove -ne $null) 
{
    
    if ($Add -ne $Remove) {
        $UserObjectId = ResolveUserObjectId $Remove $TenantId $Headers
    }

    # Remove owner from Application
    if ($App -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Delete `
                    -Uri "https://graph.windows.net/$TenantId/applications/$($App.objectId)/`$links/owners/$UserObjectId`?api-version=1.6"
        if ($Result.StatusCode -eq 204) {    
            Write-Host "Owner '$Remove' removed from Application"
        }
    }

    # Remove owner from ServicePrincipal
    if ($SP -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Delete `
                    -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/`$links/owners/$UserObjectId`?api-version=1.6"
        if ($Result.StatusCode -eq 204) {    
            Write-Host "Owner '$Remove' removed from ServicePrincipal"
        }
    }
}#if ($Remove -ne $null) 

Write-Host -ForegroundColor Magenta "[277]`n `$CurrUserPrincipalName=`"$CurrUserPrincipalName`""
if ($List) 
{
    if ($Application -and $App -ne $null -and $ServicePrincipal -and $SP -ne $null) {
        Write-Warning "Listing owners of both Application and ServicePrincipal objects may result in duplicates"
    }
    if ($Application -and $App -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/applications/$($App.objectId)/owners?api-version=1.6"
        ($Result.Content | ConvertFrom-Json).value
    }
    if ($ServicePrincipal -and $SP -ne $null) {
        $Result = Invoke-WebRequest -Headers $Headers -Method Get `
                -Uri "https://graph.windows.net/$TenantId/servicePrincipals/$($SP.objectId)/owners?api-version=1.6"
        ($Result.Content | ConvertFrom-Json).value
    }
}#if ($List) 

